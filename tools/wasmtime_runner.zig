const std = @import("std");

const c = @cImport({
    @cInclude("wasm.h");
    @cInclude("wasmtime.h");
});

const HostState = struct {
    heap_ptr: u32 = 0,
    heap_inited: bool = false,
};

fn reportError(err: *c.wasmtime_error_t) void {
    var msg: c.wasm_name_t = undefined;
    c.wasmtime_error_message(err, &msg);
    defer c.wasmtime_error_delete(err);
    if (msg.data != null and msg.size > 0) {
        std.debug.print("wasmtime error: {s}\n", .{msg.data[0..msg.size]});
        c.wasm_byte_vec_delete(&msg);
    }
}

fn reportTrap(trap: *c.wasm_trap_t) void {
    var msg: c.wasm_message_t = undefined;
    c.wasm_trap_message(trap, &msg);
    defer c.wasm_trap_delete(trap);
    if (msg.data != null and msg.size > 0) {
        std.debug.print("trap: {s}\n", .{msg.data[0..msg.size]});
        c.wasm_byte_vec_delete(&msg);
    }
}

fn rocAllocCb(
    env: ?*anyopaque,
    caller: ?*c.wasmtime_caller_t,
    args: [*c]const c.wasmtime_val_t,
    nargs: usize,
    results: [*c]c.wasmtime_val_t,
    nresults: usize,
) callconv(.c) ?*c.wasm_trap_t {
    _ = nargs;
    _ = nresults;
    const state: *HostState = @ptrCast(@alignCast(env.?));

    var mem_extern: c.wasmtime_extern_t = undefined;
    if (!c.wasmtime_caller_export_get(caller.?, "memory", 6, &mem_extern) or mem_extern.kind != c.WASMTIME_EXTERN_MEMORY) {
        return null;
    }
    const memory = mem_extern.of.memory;

    if (!state.heap_inited) {
        var heap_extern: c.wasmtime_extern_t = undefined;
        if (c.wasmtime_caller_export_get(caller.?, "__heap_base", 11, &heap_extern) and heap_extern.kind == c.WASMTIME_EXTERN_GLOBAL) {
            var val: c.wasmtime_val_t = undefined;
            c.wasmtime_global_get(c.wasmtime_caller_context(caller.?), &heap_extern.of.global, &val);
            state.heap_ptr = @intCast(val.of.i32);
        }
        state.heap_inited = true;
    }

    const size: u32 = @intCast(args[0].of.i32);
    var alignment: u32 = @intCast(args[1].of.i32);
    if (alignment == 0) alignment = 1;

    const aligned = (state.heap_ptr + (alignment - 1)) & ~(@as(u32, alignment - 1));
    const end = aligned + size;

    const current_size = @as(u32, @intCast(c.wasmtime_memory_data_size(c.wasmtime_caller_context(caller.?), &memory)));
    if (end > current_size) {
        const need = end - current_size;
        const page_size: u32 = 65536;
        const pages = (need + page_size - 1) / page_size;
        var prev: u64 = 0;
        const grow_err = c.wasmtime_memory_grow(c.wasmtime_caller_context(caller.?), &memory, pages, &prev);
        if (grow_err != null) {
            reportError(grow_err.?);
            return null;
        }
    }

    state.heap_ptr = end;

    results[0].kind = c.WASMTIME_I32;
    results[0].of.i32 = @intCast(aligned);
    return null;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();
    _ = args_iter.next(); // exe
    const wasm_path = args_iter.next() orelse {
        std.debug.print("usage: wasmtime_runner <module.wasm>\n", .{});
        return;
    };

    const wasm_bytes = try std.fs.cwd().readFileAlloc(allocator, wasm_path, 1 << 28);
    defer allocator.free(wasm_bytes);

    const engine = c.wasm_engine_new();
    defer c.wasm_engine_delete(engine);

    const store = c.wasmtime_store_new(engine, null, null);
    defer c.wasmtime_store_delete(store);
    const context = c.wasmtime_store_context(store);

    const linker = c.wasmtime_linker_new(engine);
    defer c.wasmtime_linker_delete(linker);

    // WASI
    const wasi_config = c.wasi_config_new();
    c.wasi_config_inherit_stdout(wasi_config);
    c.wasi_config_inherit_stderr(wasi_config);
    c.wasi_config_inherit_stdin(wasi_config);
    _ = c.wasmtime_context_set_wasi(context, wasi_config);
    _ = c.wasmtime_linker_define_wasi(linker);

    // roc_alloc import
    const func_type = c.wasm_functype_new_2_1(
        c.wasm_valtype_new_i32(),
        c.wasm_valtype_new_i32(),
        c.wasm_valtype_new_i32(),
    );
    defer c.wasm_functype_delete(func_type);

    var state = HostState{};
    const err_define = c.wasmtime_linker_define_func(
        linker,
        "env",
        3,
        "roc_alloc",
        9,
        func_type,
        rocAllocCb,
        &state,
        null,
    );
    if (err_define != null) {
        reportError(err_define.?);
        return;
    }

    var module: ?*c.wasmtime_module_t = null;
    const err_module = c.wasmtime_module_new(engine, wasm_bytes.ptr, wasm_bytes.len, &module);
    if (err_module != null) {
        reportError(err_module.?);
        return;
    }
    defer c.wasmtime_module_delete(module.?);

    var instance: c.wasmtime_instance_t = undefined;
    var trap: ?*c.wasm_trap_t = null;
    const err_inst = c.wasmtime_linker_instantiate(linker, context, module.?, &instance, &trap);
    if (err_inst != null) {
        reportError(err_inst.?);
        return;
    }
    if (trap) |t| {
        reportTrap(t);
        return;
    }

    var start_extern: c.wasmtime_extern_t = undefined;
    if (!c.wasmtime_instance_export_get(context, &instance, "_start", 6, &start_extern) or start_extern.kind != c.WASMTIME_EXTERN_FUNC) {
        std.debug.print("export _start not found\n", .{});
        return;
    }

    var start_trap: ?*c.wasm_trap_t = null;
    const err_call = c.wasmtime_func_call(context, &start_extern.of.func, null, 0, null, 0, &start_trap);
    if (err_call != null) {
        reportError(err_call.?);
        return;
    }
    if (start_trap) |t| {
        reportTrap(t);
        return;
    }
}

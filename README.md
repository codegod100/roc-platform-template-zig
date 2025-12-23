# Roc platform template for Zig

A template for building [Roc platforms](https://www.roc-lang.org/platforms) using [Zig](https://ziglang.org).

## Requirements

- [Zig](https://ziglang.org/download/) 0.15.2 or later
- [Roc](https://www.roc-lang.org/) (for bundling)

## Examples

Run examples with interpreter: `roc examples/<name>.roc`

Build standalone executable: `roc build examples/<name>.roc`

Check out `examples/static_dispatch.roc` for a focused walkthrough of Roc's static dispatch (method-based) style.

## Building

```bash
# Build for all supported targets (cross-compilation)
zig build -Doptimize=ReleaseSafe

# Build for native platform only
zig build native -Doptimize=ReleaseSafe
```

## Bundling

```bash
./bundle.sh
```

This creates a `.tar.zst` bundle containing all `.roc` files and prebuilt host libraries.

## Supported Targets

| Target | Library |
|--------|---------|
| x64mac | `platform/targets/x64mac/libhost.a` |
| x64win | `platform/targets/x64win/host.lib` |
| x64musl | `platform/targets/x64musl/libhost.a` |
| arm64mac | `platform/targets/arm64mac/libhost.a` |
| arm64win | `platform/targets/arm64win/host.lib` |
| arm64musl | `platform/targets/arm64musl/libhost.a` |

Linux musl targets include statically linked C runtime files (`crt1.o`, `libc.a`) for standalone executables.

## Browser WASM Demo

We now include a minimal in-browser runner under `examples/web/index.html`. It fetches any Roc-generated WASI module (defaults to `examples/cool_skyline.wasm`), wires up the `_start` export using the browser’s WebAssembly APIs, and streams stdout/stderr into the page.

Quick start:

1. Build a WASI module, e.g. `rocn build --target=wasm32 examples/cool_skyline.roc`.
2. Serve the repo (any static file server will do) and open `examples/web/index.html`.
3. Update the “WASM URL” field if needed and click **Run WASI module** to see the output in the browser console on the page.

The JS shim currently implements only the basics (stdout/stderr, proc_exit, fd_write, etc.). Extend it as needed for more advanced WASI features (stdin, filesystem, networking, etc.).

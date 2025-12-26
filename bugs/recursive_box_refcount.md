# Bug: Recursive Box Reference Counting Crash

## Summary

Recursive nominal types using `Box` work for depth 1 but crash (segfault) at depth 2+ during reference counting cleanup.

## Environment

- **Compiler**: Zig-based Roc (`../roc/zig-out/bin/roc`)
- **Platform**: roc-platform-template-zig

## Minimal Reproduction

Save this as `bugs/recursive_box_repro.roc`:

```roc
app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

# Simple recursive nominal type with Box (required per langref)
RichDoc := [
    PlainText(Str),
    Wrapped(Box(RichDoc)),
]

main! = |_args| {
    # Depth 0: works
    plain = RichDoc.PlainText("hello")
    
    # Depth 1: works
    wrapped_once = RichDoc.Wrapped(Box.box(plain))
    
    # Depth 2: CRASHES on exit (segfault)
    _wrapped_twice = RichDoc.Wrapped(Box.box(wrapped_once))
    
    Stdout.line!("done")
    Ok({})
}
```

## Steps to Reproduce

```bash
cd roc-platform-template-zig

# Type check passes
../roc/zig-out/bin/roc check bugs/recursive_box_repro.roc
# Output: No errors found

# Run crashes
../roc/zig-out/bin/roc bugs/recursive_box_repro.roc
# Output: done
# Then: Exit code 139 (segfault)
```

## Expected Behavior

Program exits cleanly with exit code 0.

## Actual Behavior

Program prints "done" but then crashes with exit code 139 (SIGSEGV) during cleanup.

## Stack Trace

When the panic is visible (not always):

```
thread panic: integer overflow
/home/.../roc/src/eval/StackValue.zig:190:44: in decrefLayoutPtr
        const refcount_addr = unmasked_ptr - @sizeOf(isize);
                                           ^
```

## Root Cause Analysis

The crash occurs in `src/eval/StackValue.zig:decrefLayoutPtr` during reference counting cleanup. The issue is specifically with:

1. Boxed recursive nominal types
2. At nesting depth > 1
3. During the decref/cleanup phase after `main!` returns

From `src/layout/store.zig`, recursive references are only allowed inside `Box` or `List`:

```zig
// Recursive reference inside List/Box - use opaque pointer
if (pending_item.container == .box or pending_item.container == .list) {
    layout_idx = try self.insertLayout(Layout.opaquePtr());
} else {
    // Recursive reference outside of List/Box container - this is an error
    return LayoutError.TypeContainedMismatch;
}
```

The layout computation correctly uses opaque pointers, but the reference counting code doesn't properly handle the recursive structure at depth > 1.

## Related Observations

### Without Box: TypeContainedMismatch

```roc
IntList := [Nil, Cons(I64, IntList)]  # No Box

main! = |_args| {
    _empty = IntList.Nil
    Ok({})
}
```

Crashes with: `Roc crashed: Error evaluating: TypeContainedMismatch`

### Depth 1 Works

```roc
main! = |_args| {
    plain = RichDoc.PlainText("hello")
    bolded = RichDoc.Wrapped(Box.box(plain))
    
    msg = match bolded {
        PlainText(s) => s
        Wrapped(boxed) => {
            inner_msg = match Box.unbox(boxed) {
                PlainText(s) => s
                Wrapped(_) => "nested"
            }
            "**${inner_msg}**"
        }
    }
    Stdout.line!(msg)  # Prints: **hello**
    Ok({})
}
```

This works correctly!

### Recursive Render Function Crashes

```roc
render : RichDoc -> Str
render = |doc| match doc {
    PlainText(s) => s
    Wrapped(boxed) => {
        inner = render(Box.unbox(boxed))  # Recursive call
        "[${inner}]"
    }
}
```

Works for depth 1, crashes with "non-exhaustive match" at depth 2.

## Test Snapshot Status

The Roc test suite at `test/snapshots/nominal/nominal_tag_recursive_payload.md` only has a `type=snippet` test (type checking), not a runtime test:

```roc
ConsList(a) := [Nil, Node(ConsList(a))]

empty : ConsList(_a)
empty = ConsList.Nil
```

The Rust/LLVM-based tests in `crates/repl_test/src/tests.rs` have working recursive types, but they use a different compiler backend.

## Workaround

Pre-render nested content to strings instead of storing actual recursive values:

```roc
Doc := [
    Text(Str),
    Bold(Str),      # Store pre-rendered markdown, not Box(Doc)
    Join(Str),      # Store pre-rendered content
]

bold : Doc -> Doc
bold = |doc| Bold(doc.to_markdown())  # Pre-render when constructing
```

## Files to Investigate

- `src/eval/StackValue.zig` - `decrefLayoutPtr` function
- `src/layout/store.zig` - Recursive layout handling
- `src/eval/interpreter.zig` - `trimBindingList` function

## Priority

This blocks the use of true recursive data structures (trees, documents, ASTs, etc.) in the Zig-based Roc compiler.
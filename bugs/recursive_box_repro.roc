app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

## Minimal reproduction for recursive Box refcount crash
##
## See: bugs/recursive_box_refcount.md
##
## This demonstrates that:
## - Depth 0 (plain value): works
## - Depth 1 (one Box wrap): works
## - Depth 2 (nested Box wrap): CRASHES on exit with segfault
##
## Run with: ../roc/zig-out/bin/roc bugs/recursive_box_repro.roc
## Expected: Exit code 0
## Actual: Exit code 139 (SIGSEGV)

# Simple recursive nominal type with Box (required per langref)
RichDoc := [
    PlainText(Str),
    Wrapped(Box(RichDoc)),
]

main! = |_args| {
    # Depth 0: works
    plain = RichDoc.PlainText("hello")
    Stdout.line!("Created depth 0: plain")

    # Depth 1: works
    wrapped_once = RichDoc.Wrapped(Box.box(plain))
    Stdout.line!("Created depth 1: wrapped_once")

    # Depth 2: CRASHES on exit (segfault during refcount cleanup)
    _wrapped_twice = RichDoc.Wrapped(Box.box(wrapped_once))
    Stdout.line!("Created depth 2: wrapped_twice")

    Stdout.line!("All values created - about to exit...")
    Stdout.line!("(Crash occurs during cleanup after main! returns)")

    Ok({})
}

app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

## Reproduction for TypeContainedMismatch error when using recursive types without Box
##
## See: bugs/recursive_box_refcount.md
##
## This demonstrates that recursive nominal types WITHOUT Box cause:
## "Roc crashed: Error evaluating: TypeContainedMismatch"
##
## The langref says recursive types need Box or List to wrap the recursive reference.
## This test confirms that error when you forget to use Box.
##
## Run with: ../roc/zig-out/bin/roc bugs/recursive_no_box_repro.roc
## Expected: TypeContainedMismatch error

# Recursive nominal type WITHOUT Box - this is the bug trigger
IntList := [Nil, Cons(I64, IntList)]

main! = |_args| {
    # Even just creating a Nil value crashes
    _empty = IntList.Nil

    Stdout.line!("This line will never print")
    Ok({})
}

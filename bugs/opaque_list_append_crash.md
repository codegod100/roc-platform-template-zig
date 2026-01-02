# Bug: Crash when appending multiple items to List of opaque type containing Str

## Summary

The Zig-based Roc interpreter crashes with "increfDataPtrC: ORIGINAL ptr is not 8-byte aligned" when appending a second item to a `List` of an opaque type that contains a `Str` field.

## Environment

- **Roc version**: `debug-cb81e5e3` (Zig-based interpreter)
- **Commit**: `cb81e5e33a` (roc-lang/roc main branch)
- **OS**: Linux x86_64 (Ubuntu)
- **Platform**: roc-platform-template-zig

## Minimal Reproduction

```roc
app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

# Minimal reproduction: opaque type with Str field crashes on second List.append
MyRecord := { name : Str }.{}

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
    result_init : List(MyRecord)
    result_init = []
    var $result = result_init
    
    r1 : MyRecord
    r1 = { name: "first" }
    $result = List.append($result, r1)
    
    r2 : MyRecord
    r2 = { name: "second" }
    $result = List.append($result, r2)  # CRASH HERE
    
    Stdout.line!("Done: ${List.len($result).to_str()}")
    Ok({})
}
```

## Error Output

```
Roc crashed: increfDataPtrC: ORIGINAL ptr=0x7473726966 is not 8-byte aligned
```

Note: `0x7473726966` decodes to ASCII "tsrif" which is "first" backwards - suggesting the string data is being misinterpreted as a pointer.

## Expected Behavior

The program should output:
```
Done: 2
```

## Workaround

Using an inline record type instead of an opaque type works correctly:

```roc
# This works:
result_init : List({ name : Str })
result_init = []
var $result = result_init

r1 = { name: "first" }
$result = List.append($result, r1)

r2 = { name: "second" }
$result = List.append($result, r2)  # No crash
```

## Analysis

The crash occurs during reference counting (incref) when the second append happens. The error message suggests that the interpreter is treating string data as a heap pointer, causing alignment checks to fail.

This may be related to how opaque types are laid out in memory vs inline record types, or how the reference counting code handles opaque type wrappers.

## Related

This bug was discovered while trying to run `examples/hacker_news.roc` which uses:
```roc
Story := {
    id : U64,
    title : Str,
    url : Str,
    score : U64,
    by : Str,
}.{}
```

The original error was: `Roc crashed: Use-after-free: decref on already-freed memory`

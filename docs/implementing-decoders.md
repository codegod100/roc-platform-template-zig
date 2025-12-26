# Implementing Custom Decoders in Roc

This guide explains how to implement your own decoder for binary/text data in Roc.

## Overview

Decoders transform raw bytes (`List U8`) into structured Roc values. The basic pattern is:

1. **Input**: bytes to decode
2. **Output**: decoded value + remaining bytes (for chaining decoders)

## Basic Decoder Pattern

A decoder function returns a record with:
- `ok`: whether decoding succeeded
- `value`: the decoded value
- `rest`: remaining bytes after decoding

```roc
# Decode a single U8 from bytes
decode_u8 = |bytes| {
    if List.len(bytes) == 0 {
        { ok: False, value: 0u8, rest: bytes }
    } else {
        match List.first(bytes) {
            Ok(byte) => { ok: True, value: byte, rest: List.drop_first(bytes, 1) }
            Err(_) => { ok: False, value: 0u8, rest: bytes }
        }
    }
}
```

## Decoding Strings

A common pattern is length-prefixed strings:

```roc
# Format: [length_byte, ...string_bytes]
decode_string = |bytes| {
    len_result = decode_u8(bytes)
    if len_result.ok {
        str_len = len_result.value.to_u64()
        if List.len(len_result.rest) >= str_len {
            string_bytes = List.take_first(len_result.rest, str_len)
            remaining = List.drop_first(len_result.rest, str_len)
            match Str.from_utf8(string_bytes) {
                Ok(str) => { ok: True, value: str, rest: remaining }
                Err(_) => { ok: False, value: "", rest: bytes }
            }
        } else {
            { ok: False, value: "", rest: bytes }
        }
    } else {
        { ok: False, value: "", rest: bytes }
    }
}
```

## Chaining Decoders

Use the `rest` field to chain decoders sequentially:

```roc
# Decode a person: name (string) followed by age (u8)
decode_person = |bytes| {
    name_result = decode_string(bytes)
    if name_result.ok {
        age_result = decode_u8(name_result.rest)
        if age_result.ok {
            { 
                ok: True, 
                value: { name: name_result.value, age: age_result.value },
                rest: age_result.rest 
            }
        } else {
            { ok: False, value: { name: "", age: 0u8 }, rest: bytes }
        }
    } else {
        { ok: False, value: { name: "", age: 0u8 }, rest: bytes }
    }
}
```

## Usage Example

```roc
main! = |_args| {
    # Test data: "Alice" (length 5) followed by age 30
    test_bytes = [5u8, 65, 108, 105, 99, 101, 30]
    
    name_result = decode_string(test_bytes)
    if name_result.ok {
        Stdout.line!("Name: ${name_result.value}")
        
        age_result = decode_u8(name_result.rest)
        if age_result.ok {
            Stdout.line!("Age: ${age_result.value.to_str()}")
        }
    }
    Ok({})
}
```

## Tips

- Use `List.first()` with match to safely get the first byte
- Use `List.take_first()` and `List.drop_first()` to consume bytes
- Use `Str.from_utf8()` to convert byte lists to strings
- Always track remaining bytes in the `rest` field for chaining
- Use `.to_u64()` to convert U8 to U64 for length comparisons

## Alternative: Using Result Type

Instead of `ok: Bool`, you can use `Result`:

```roc
DecodeResult val : { result: Result val [TooShort], rest: List U8 }

decode_u8 : List U8 -> DecodeResult U8
decode_u8 = |bytes| {
    match List.first(bytes) {
        Ok(byte) => { result: Ok(byte), rest: List.drop_first(bytes, 1) }
        Err(_) => { result: Err(TooShort), rest: bytes }
    }
}
```

## See Also

- `examples/decoder.roc` - Working example of binary decoding
- The Roc `Decode` module (in `crates/compiler/builtins/roc/Decode.roc`) defines formal decoder abilities for more advanced use cases


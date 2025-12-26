app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

# A simple binary format decoder example
# Demonstrates manual decoding of bytes into structured data

# Decode a U8 from bytes
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

# Decode a length-prefixed string from bytes
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

main! = |_args| {
    # Test data: length-prefixed string "Alice" (5 bytes) followed by age 30
    # [5u8, 'A', 'l', 'i', 'c', 'e', 30]
    test_bytes = [5u8, 65, 108, 105, 99, 101, 30]

    Stdout.line!("Input bytes: ${Str.inspect(test_bytes)}")

    # Decode the name
    name_result = decode_string(test_bytes)
    if name_result.ok {
        Stdout.line!("Decoded name: ${name_result.value}")

        # Decode the age from remaining bytes
        age_result = decode_u8(name_result.rest)
        if age_result.ok {
            Stdout.line!("Decoded age: ${age_result.value.to_str()}")
            Stdout.line!("Remaining bytes: ${Str.inspect(age_result.rest)}")
        } else {
            Stdout.line!("Failed to decode age")
        }
    } else {
        Stdout.line!("Failed to decode name")
    }

    Ok({})
}

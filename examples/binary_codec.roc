app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

## Binary Codec - A semi-complex binary data encoding format
##
## Format specification:
## - Strings are length-prefixed (U8 length + UTF-8 bytes)
## - Lists are count-prefixed (U8 count + encoded elements)
## - Records use field count + sorted field names + values
## - Messages have: magic (4B) + version (1B) + payload
##
## Type tags (first byte):
## 0x00 = Null/Unit
## 0x01 = Bool
## 0x02 = U8
## 0x10 = Str
## 0x20 = List
## 0x30 = Record
## 0x40 = Tag (variant)

# Helper to get length as U8 (for lists up to 255 elements)
u64_to_u8 : U64 -> U8
u64_to_u8 = |n| {
    # Build byte from components using arithmetic
    # This works for values 0-255
    if n > 255 {
        255u8
    } else {
        # Use a recursive helper for safe conversion
        byte_from_u64(n)
    }
}

byte_from_u64 : U64 -> U8
byte_from_u64 = |n| {
    match n {
        0 => 0u8
        1 => 1u8
        2 => 2u8
        3 => 3u8
        4 => 4u8
        5 => 5u8
        6 => 6u8
        7 => 7u8
        8 => 8u8
        9 => 9u8
        10 => 10u8
        11 => 11u8
        12 => 12u8
        13 => 13u8
        14 => 14u8
        15 => 15u8
        _ => {
            # For values > 15, break down: n = 16*q + r
            q = n // 16
            r = n % 16
            byte_from_u64(q) * 16 + byte_from_u64(r)
        }
    }
}

len_u8 : List(a) -> U8
len_u8 = |list| u64_to_u8(List.len(list))

# ============================================================================
# Type-tagged encoding
# ============================================================================

encode_unit : {} -> List(U8)
encode_unit = |{}| [0x00]

encode_bool : Bool -> List(U8)
encode_bool = |b| {
    if b {
        [0x01, 1]
    } else {
        [0x01, 0]
    }
}

encode_u8 : U8 -> List(U8)
encode_u8 = |n| [0x02, n]

encode_str : Str -> List(U8)
encode_str = |s| {
    bytes = Str.to_utf8(s)
    List.concat([0x10, len_u8(bytes)], bytes)
}

encode_list : List(List(U8)) -> List(U8)
encode_list = |items| {
    header = [0x20, len_u8(items)]
    items.fold(header, |acc, item| List.concat(acc, item))
}

encode_record_field : List(U8), { name : Str, value : List(U8) } -> List(U8)
encode_record_field = |acc, field| {
    name_bytes = Str.to_utf8(field.name)
    acc
        .concat([len_u8(name_bytes)])
        .concat(name_bytes)
        .concat(field.value)
}

encode_record : List({ name : Str, value : List(U8) }) -> List(U8)
encode_record = |fields| {
    header = [0x30, len_u8(fields)]
    fields.fold(header, encode_record_field)
}

encode_tag : U8, List(U8) -> List(U8)
encode_tag = |tag_index, payload| {
    [0x40, tag_index, len_u8(payload)].concat(payload)
}

# ============================================================================
# Message framing
# ============================================================================

encode_message : List(U8) -> List(U8)
encode_message = |payload| {
    magic = [0x52u8, 0x4Fu8, 0x43u8, 0x42u8] # "ROCB" - Roc Binary
    version = [0x01u8]
    
    magic.concat(version).concat([len_u8(payload)]).concat(payload)
}

# ============================================================================
# Decoding helpers
# ============================================================================

decode_u8_val : List(U8) -> { ok : Bool, value : U8, rest : List(U8) }
decode_u8_val = |bytes| {
    match List.first(bytes) {
        Ok(byte) => { ok: True, value: byte, rest: List.drop_first(bytes, 1) }
        Err(_) => { ok: False, value: 0, rest: bytes }
    }
}

decode_str_payload : List(U8) -> { ok : Bool, value : Str, rest : List(U8) }
decode_str_payload = |bytes| {
    len_result = decode_u8_val(bytes)
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

decode_message : List(U8) -> { ok : Bool, version : U8, payload : List(U8) }
decode_message = |bytes| {
    # Check minimum length: magic(4) + version(1) + len(1) = 6
    if List.len(bytes) < 6 {
        { ok: False, version: 0, payload: [] }
    } else {
        # Verify magic bytes "ROCB"
        b0 = List.get(bytes, 0)
        b1 = List.get(bytes, 1)
        b2 = List.get(bytes, 2)
        b3 = List.get(bytes, 3)
        
        magic_ok = b0 == Ok(0x52) and b1 == Ok(0x4F) and b2 == Ok(0x43) and b3 == Ok(0x42)
        
        if magic_ok {
            version = match List.get(bytes, 4) {
                Ok(v) => v
                Err(_) => 0
            }
            payload_len = match List.get(bytes, 5) {
                Ok(l) => l.to_u64()
                Err(_) => 0
            }
            payload = List.drop_first(bytes, 6).take_first(payload_len)
            { ok: True, version, payload }
        } else {
            { ok: False, version: 0, payload: [] }
        }
    }
}

# ============================================================================
# Helper for hex display
# ============================================================================

to_hex_digit : U8 -> Str
to_hex_digit = |n| {
    match n {
        0 => "0"
        1 => "1"
        2 => "2"
        3 => "3"
        4 => "4"
        5 => "5"
        6 => "6"
        7 => "7"
        8 => "8"
        9 => "9"
        10 => "a"
        11 => "b"
        12 => "c"
        13 => "d"
        14 => "e"
        15 => "f"
        _ => "?"
    }
}

byte_to_hex : U8 -> Str
byte_to_hex = |b| {
    high = b // 16u8
    low = b % 16u8
    # Convert to individual hex chars
    high_char = match high {
        0u8 => "0"
        1u8 => "1"
        2u8 => "2"
        3u8 => "3"
        4u8 => "4"
        5u8 => "5"
        6u8 => "6"
        7u8 => "7"
        8u8 => "8"
        9u8 => "9"
        10u8 => "a"
        11u8 => "b"
        12u8 => "c"
        13u8 => "d"
        14u8 => "e"
        15u8 => "f"
        _ => "?"
    }
    low_char = match low {
        0u8 => "0"
        1u8 => "1"
        2u8 => "2"
        3u8 => "3"
        4u8 => "4"
        5u8 => "5"
        6u8 => "6"
        7u8 => "7"
        8u8 => "8"
        9u8 => "9"
        10u8 => "a"
        11u8 => "b"
        12u8 => "c"
        13u8 => "d"
        14u8 => "e"
        15u8 => "f"
        _ => "?"
    }
    Str.concat(high_char, low_char)
}

bytes_to_hex : List(U8) -> Str
bytes_to_hex = |bytes| {
    var $result = ""
    for byte in bytes {
        hex = byte_to_hex(byte)
        if Str.is_empty($result) {
            $result = hex
        } else {
            $result = Str.concat($result, Str.concat(" ", hex))
        }
    }
    $result
}

# ============================================================================
# Main - Demo the codec
# ============================================================================

main! = |_args| {
    Stdout.line!("=== Binary Codec Demo ===")
    Stdout.line!("")

    Stdout.line!("Encoding primitives:")
    
    unit_enc = encode_unit({})
    Stdout.line!("  unit:     ${bytes_to_hex(unit_enc)}")
    
    bool_enc = encode_bool(True)
    Stdout.line!("  bool(true): ${bytes_to_hex(bool_enc)}")
    
    u8_enc = encode_u8(42)
    Stdout.line!("  u8(42):   ${bytes_to_hex(u8_enc)}")

    Stdout.line!("")
    Stdout.line!("Encoding string:")
    str_enc = encode_str("Hello, Roc!")
    Stdout.line!("  \"Hello, Roc!\": ${bytes_to_hex(str_enc)}")

    Stdout.line!("")
    Stdout.line!("Encoding list of u8s [1, 2, 3]:")
    list_enc = encode_list([encode_u8(1), encode_u8(2), encode_u8(3)])
    Stdout.line!("  ${bytes_to_hex(list_enc)}")

    Stdout.line!("")
    Stdout.line!("Encoding record { name: \"Alice\", age: 30 }:")
    record_enc = encode_record([
        { name: "name", value: encode_str("Alice") },
        { name: "age", value: encode_u8(30) },
    ])
    Stdout.line!("  ${bytes_to_hex(record_enc)}")

    Stdout.line!("")
    Stdout.line!("Encoding tagged value Ok(42):")
    tag_enc = encode_tag(0, encode_u8(42))
    Stdout.line!("  ${bytes_to_hex(tag_enc)}")

    Stdout.line!("")
    Stdout.line!("=== Message Framing ===")
    
    payload = encode_record([
        { name: "user", value: encode_str("Bob") },
        { name: "score", value: encode_u8(99) },
    ])
    
    message = encode_message(payload)
    Stdout.line!("Full message with header:")
    Stdout.line!("  ${bytes_to_hex(message)}")
    Stdout.line!("  Length: ${List.len(message).to_str()} bytes")

    Stdout.line!("")
    Stdout.line!("=== Decoding Demo ===")
    
    # Decode the message we just encoded
    decoded_msg = decode_message(message)
    Stdout.line!("  Message decoded: ${Str.inspect(decoded_msg.ok)}")
    Stdout.line!("  Version: ${decoded_msg.version.to_str()}")
    Stdout.line!("  Payload: ${bytes_to_hex(decoded_msg.payload)}")

    # Decode a string
    test_str_bytes = List.drop_first(encode_str("Roc!"), 1) # Skip type tag
    decoded_str = decode_str_payload(test_str_bytes)
    Stdout.line!("  Decoded Str: \"${decoded_str.value}\" (expected \"Roc!\")")

    Stdout.line!("")
    Stdout.line!("=== Format Breakdown ===")
    Stdout.line!("Type tags: 00=unit, 01=bool, 02=u8, 10=str, 20=list, 30=record, 40=tag")
    Stdout.line!("Strings: [type][len][...bytes]")
    Stdout.line!("Lists: [type][count][...items]")
    Stdout.line!("Records: [type][field_count][name_len][name][value]...")
    Stdout.line!("Messages: [ROCB magic][version][len][payload]")
    Stdout.line!("")
    Stdout.line!("Done!")

    Ok({})
}

app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import MyLetters exposing [char_to_ascii_letter]

to_str = |bytes|
    match Str.from_utf8(bytes) {
        Ok(s) => s
        Err(_) => ""
    }

get_row_str = |rows, idx|
    match List.get(rows, idx) {
        Ok(r) => to_str(r)
        Err(_) => ""
    }

# Build all 6 rows in a single pass through the text
build_art = |text| {
    bytes = Str.to_utf8(text)
    var $r0 = ""
    var $r1 = ""
    var $r2 = ""
    var $r3 = ""
    var $r4 = ""
    var $r5 = ""

    for b in bytes {
        rows = char_to_ascii_letter(b).rows
        $r0 = Str.concat($r0, get_row_str(rows, 0))
        $r1 = Str.concat($r1, get_row_str(rows, 1))
        $r2 = Str.concat($r2, get_row_str(rows, 2))
        $r3 = Str.concat($r3, get_row_str(rows, 3))
        $r4 = Str.concat($r4, get_row_str(rows, 4))
        $r5 = Str.concat($r5, get_row_str(rows, 5))
    }

    { r0: $r0, r1: $r1, r2: $r2, r3: $r3, r4: $r4, r5: $r5 }
}

main! = |_args| {
    text = "Hello Roc"

    Stdout.line!("ASCII Art: ${text}")
    Stdout.line!("")

    art = build_art(text)
    Stdout.line!(art.r0)
    Stdout.line!(art.r1)
    Stdout.line!(art.r2)
    Stdout.line!(art.r3)
    Stdout.line!(art.r4)
    Stdout.line!(art.r5)

    Ok({})
}

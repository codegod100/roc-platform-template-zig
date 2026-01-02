app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

Story : { id : U64, title : Str, url : Str, score : U64, by : Str }

main! = |_args| {
    Stdout.line!("Fetching one story...")
    resp = Http.get!("https://hacker-news.firebaseio.com/v0/item/46449643.json")
    
    json = match Str.from_utf8(resp.responseBody) {
        Ok(s) => s
        Err(_) => "{}"
    }
    
    Stdout.line!("Parsing story 30 times...")
    for i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30] {
        story = parse_story(json, 12345)
        if i == 1 {
            Stdout.line!("Title: ${story.title}")
        }
    }
    
    Stdout.line!("Done!")
    Ok({})
}

parse_story : Str, U64 -> Story
parse_story = |json, id| {
    {
        id: id,
        title: get_json_string(json, "title"),
        url: get_json_string(json, "url"),
        score: get_json_number(json, "score"),
        by: get_json_string(json, "by"),
    }
}

get_json_string : Str, Str -> Str
get_json_string = |json, key| {
    pattern = "\"${key}\":"
    match split_first(json, pattern) {
        Ok({ after }) => {
            rest = Str.trim_start(after)
            if Str.starts_with(rest, "\"") {
                without_open = Str.drop_prefix(rest, "\"")
                match split_first(without_open, "\"") {
                    Ok({ before }) => before
                    Err(_) => ""
                }
            } else { "" }
        }
        Err(_) => ""
    }
}

get_json_number : Str, Str -> U64
get_json_number = |json, key| {
    pattern = "\"${key}\":"
    match split_first(json, pattern) {
        Ok({ after }) => {
            rest = Str.trim_start(after)
            digits = take_while_digit(rest)
            match str_to_u64(digits) {
                Ok(n) => n
                Err(_) => 0
            }
        }
        Err(_) => 0
    }
}

split_first : Str, Str -> Try({ before : Str, after : Str }, [NotFound])
split_first = |haystack, needle| {
    parts = Str.split_on(haystack, needle)
    match List.first(parts) {
        Ok(before) => {
            rest = List.drop_first(parts, 1)
            if List.is_empty(rest) {
                Err(NotFound)
            } else {
                after = Str.join_with(rest, needle)
                Ok({ before, after })
            }
        }
        Err(_) => Err(NotFound)
    }
}

take_while_digit : Str -> Str
take_while_digit = |s| {
    bytes = Str.to_utf8(s)
    digit_bytes = take_bytes_while(bytes, |b| b >= '0' and b <= '9')
    match Str.from_utf8(digit_bytes) {
        Ok(result) => result
        Err(_) => ""
    }
}

take_bytes_while : List(U8), (U8 -> Bool) -> List(U8)
take_bytes_while = |bytes, pred| {
    result_init : List(U8)
    result_init = []
    var $result = result_init
    var $done = Bool.False
    for byte in bytes {
        if !$done and pred(byte) {
            $result = List.append($result, byte)
        } else {
            $done = Bool.True
        }
    }
    $result
}

str_to_u64 : Str -> Try(U64, [InvalidNumStr])
str_to_u64 = |s| {
    bytes = Str.to_utf8(s)
    if List.is_empty(bytes) {
        Err(InvalidNumStr)
    } else {
        result_init : U64
        result_init = 0
        var $result = result_init
        var $valid = Bool.True
        for byte in bytes {
            if $valid and byte >= '0' and byte <= '9' {
                digit = (byte - '0').to_u64()
                $result = $result * 10 + digit
            } else {
                $valid = Bool.False
            }
        }
        if $valid { Ok($result) } else { Err(InvalidNumStr) }
    }
}

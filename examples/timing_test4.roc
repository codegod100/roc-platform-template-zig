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
    
    Stdout.line!("Parsing story 30 times with optimized parser...")
    for _ in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30] {
        _story = parse_story_fast(json, 12345)
    }
    
    story = parse_story_fast(json, 12345)
    Stdout.line!("Title: ${story.title}")
    Stdout.line!("Done!")
    Ok({})
}

parse_story_fast : Str, U64 -> Story
parse_story_fast = |json, id| {
    bytes = Str.to_utf8(json)
    {
        id: id,
        title: get_string_value(bytes, "title"),
        url: get_string_value(bytes, "url"),
        score: get_number_value(bytes, "score"),
        by: get_string_value(bytes, "by"),
    }
}

get_string_value : List(U8), Str -> Str
get_string_value = |bytes, key| {
    key_bytes = Str.to_utf8("\"${key}\":")
    match find_pattern(bytes, key_bytes) {
        Ok(pos) => {
            after = List.drop_first(bytes, pos + List.len(key_bytes))
            trimmed = skip_whitespace(after)
            match List.first(trimmed) {
                Ok(c) => 
                    if c == '"' {
                        content = List.drop_first(trimmed, 1)
                        extract_until_quote(content)
                    } else {
                        ""
                    }
                Err(_) => ""
            }
        }
        Err(_) => ""
    }
}

get_number_value : List(U8), Str -> U64
get_number_value = |bytes, key| {
    key_bytes = Str.to_utf8("\"${key}\":")
    match find_pattern(bytes, key_bytes) {
        Ok(pos) => {
            after = List.drop_first(bytes, pos + List.len(key_bytes))
            trimmed = skip_whitespace(after)
            extract_number(trimmed)
        }
        Err(_) => 0
    }
}

find_pattern : List(U8), List(U8) -> Try(U64, [NotFound])
find_pattern = |haystack, needle| {
    needle_len = List.len(needle)
    haystack_len = List.len(haystack)
    if needle_len == 0 or haystack_len < needle_len {
        Err(NotFound)
    } else {
        max_pos = haystack_len - needle_len
        find_pattern_helper(haystack, needle, 0, max_pos)
    }
}

find_pattern_helper : List(U8), List(U8), U64, U64 -> Try(U64, [NotFound])
find_pattern_helper = |haystack, needle, pos, max_pos| {
    if pos > max_pos {
        Err(NotFound)
    } else if matches_at(haystack, needle, pos) {
        Ok(pos)
    } else {
        find_pattern_helper(haystack, needle, pos + 1, max_pos)
    }
}

matches_at : List(U8), List(U8), U64 -> Bool
matches_at = |haystack, needle, pos| {
    matches_at_helper(haystack, needle, pos, 0)
}

matches_at_helper : List(U8), List(U8), U64, U64 -> Bool
matches_at_helper = |haystack, needle, pos, idx| {
    if idx >= List.len(needle) {
        Bool.True
    } else {
        match (List.get(haystack, pos + idx), List.get(needle, idx)) {
            (Ok(h), Ok(n)) => 
                if h == n {
                    matches_at_helper(haystack, needle, pos, idx + 1)
                } else {
                    Bool.False
                }
            _ => Bool.False
        }
    }
}

skip_whitespace : List(U8) -> List(U8)
skip_whitespace = |bytes| {
    match List.first(bytes) {
        Ok(b) =>
            if b == ' ' or b == '\n' or b == '\t' or b == '\r' {
                skip_whitespace(List.drop_first(bytes, 1))
            } else {
                bytes
            }
        Err(_) => bytes
    }
}

extract_until_quote : List(U8) -> Str
extract_until_quote = |bytes| {
    extract_until_quote_helper(bytes, [])
}

extract_until_quote_helper : List(U8), List(U8) -> Str
extract_until_quote_helper = |bytes, acc| {
    match List.first(bytes) {
        Ok(b) =>
            if b == '"' {
                match Str.from_utf8(acc) {
                    Ok(s) => s
                    Err(_) => ""
                }
            } else {
                extract_until_quote_helper(List.drop_first(bytes, 1), List.append(acc, b))
            }
        Err(_) => 
            match Str.from_utf8(acc) {
                Ok(s) => s
                Err(_) => ""
            }
    }
}

extract_number : List(U8) -> U64
extract_number = |bytes| {
    extract_number_helper(bytes, 0)
}

extract_number_helper : List(U8), U64 -> U64
extract_number_helper = |bytes, acc| {
    match List.first(bytes) {
        Ok(b) =>
            if b >= '0' and b <= '9' {
                extract_number_helper(List.drop_first(bytes, 1), acc * 10 + (b - '0').to_u64())
            } else {
                acc
            }
        Err(_) => acc
    }
}

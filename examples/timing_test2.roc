app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |_args| {
    Stdout.line!("Fetching stories list...")
    resp = Http.get!("https://hacker-news.firebaseio.com/v0/topstories.json")
    Stdout.line!("Got list, parsing...")
    
    body_str = match Str.from_utf8(resp.responseBody) {
        Ok(s) => s
        Err(_) => "[]"
    }
    
    story_ids = parse_id_array(body_str, 30)
    Stdout.line!("Parsed ${List.len(story_ids).to_str()} IDs")
    
    Stdout.line!("Fetching 30 stories...")
    for id in story_ids {
        story_resp = Http.get!("https://hacker-news.firebaseio.com/v0/item/${id.to_str()}.json")
        Stdout.line!("Got story ${id.to_str()}: ${story_resp.statusCode.to_str()}")
    }
    
    Stdout.line!("Done!")
    Ok({})
}

parse_id_array : Str, U64 -> List(U64)
parse_id_array = |json, max_count| {
    bytes = Str.to_utf8(json)
    truncate_pos = find_nth_comma(bytes, max_count)
    truncated_bytes = List.take_first(bytes, truncate_pos)
    filtered = List.keep_if(truncated_bytes, |b| b != '[' and b != ']' and b != ' ' and b != '\n')
    trimmed = match Str.from_utf8(filtered) {
        Ok(s) => s
        Err(_) => ""
    }
    if Str.is_empty(trimmed) {
        []
    } else {
        parts = Str.split_on(trimmed, ",")
        keep_valid_u64(parts)
    }
}

find_nth_comma : List(U8), U64 -> U64
find_nth_comma = |bytes, n| {
    pos_init : U64
    pos_init = 0
    count_init : U64
    count_init = 0
    var $pos = pos_init
    var $count = count_init
    for byte in bytes {
        $pos = $pos + 1
        if byte == ',' {
            $count = $count + 1
            if $count >= n {
                break
            }
        }
    }
    $pos
}

keep_valid_u64 : List(Str) -> List(U64)
keep_valid_u64 = |strs| {
    result_init : List(U64)
    result_init = []
    var $result = result_init
    for s in strs {
        match str_to_u64(s) {
            Ok(n) => { $result = List.append($result, n) }
            Err(_) => {}
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

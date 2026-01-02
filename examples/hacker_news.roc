app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http
import pf.Time
import pf.Json

# Hacker News Reader - Fetches newest stories using Algolia API

interesting_keywords : List(Str)
interesting_keywords = [
    "zig", "roc", "rust", "haskell", "functional",
    "ai", "llm", "gpt", "claude",
    "open source", "linux", "compiler",
]

stories_to_check : U64
stories_to_check = 20

HttpStatus : [Ok(U16), ClientErr(U16), ServerErr(U16), Other(U16)]

classify_status : U16 -> HttpStatus
classify_status = |code| {
    if code >= 200 and code < 300 {
        Ok(code)
    } else if code >= 400 and code < 500 {
        ClientErr(code)
    } else if code >= 500 and code < 600 {
        ServerErr(code)
    } else {
        Other(code)
    }
}

to_lowercase : Str -> Str
to_lowercase = |s| {
    bytes = Str.to_utf8(s)
    result_init : List(U8)
    result_init = []
    var $result = result_init
    for byte in bytes {
        if byte >= 'A' and byte <= 'Z' {
            $result = List.append($result, byte + 32)
        } else {
            $result = List.append($result, byte)
        }
    }
    match Str.from_utf8($result) {
        Ok(str) => str
        Err(_) => s
    }
}

is_interesting : Str -> Bool
is_interesting = |title| {
    lower_title = to_lowercase(title)
    var $found = Bool.False
    for keyword in interesting_keywords {
        if Str.contains(lower_title, keyword) {
            $found = Bool.True
            break
        }
    }
    $found
}

Story : { title : Str, points : Str, author : Str, url : Str, objectID : Str }

parse_algolia_story! : List(U8) => Story
parse_algolia_story! = |bytes| {
    {
        title: Json.parse_string_field!(bytes, "title"),
        points: Json.parse_number_field!(bytes, "points"),
        author: Json.parse_string_field!(bytes, "author"),
        url: Json.parse_string_field!(bytes, "url"),
        objectID: Json.parse_string_field!(bytes, "objectID"),
    }
}

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
    Stdout.line!("Hacker News Reader (Algolia API)")
    Stdout.line!("Fetching newest ${stories_to_check.to_str()} stories...\n")

    t1 = Time.nanos!({})
    resp = Http.get!("https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=${stories_to_check.to_str()}")
    t2 = Time.nanos!({})
    fetch_ms = (t2 - t1) // 1_000_000
    Stdout.line!("[fetch: ${fetch_ms.to_str()}ms] Got response\n")

    match classify_status(resp.statusCode) {
        Ok(_) => {
            t3 = Time.nanos!({})
            hits = Json.parse_array_field!(resp.responseBody, "hits")
            t4 = Time.nanos!({})
            parse_array_ms = (t4 - t3) // 1_000_000
            Stdout.line!("[parse array: ${parse_array_ms.to_str()}ms] Found ${List.len(hits).to_str()} stories\n")

            interesting_count_init : U64
            interesting_count_init = 0
            var $interesting_count = interesting_count_init

            for hit in hits {
                parse_start = Time.nanos!({})
                story = parse_algolia_story!(hit)
                parse_end = Time.nanos!({})
                parse_ms = (parse_end - parse_start) // 1_000_000

                filter_start = Time.nanos!({})
                interesting = is_interesting(story.title)
                filter_end = Time.nanos!({})
                filter_ms = (filter_end - filter_start) // 1_000_000

                Stdout.line!("[parse: ${parse_ms.to_str()}ms, filter: ${filter_ms.to_str()}ms] ${story.title}")

                if interesting {
                    $interesting_count = $interesting_count + 1
                    Stdout.line!("  ${story.points} points by ${story.author}")
                    if Str.is_empty(story.url) {
                        Stdout.line!("  https://news.ycombinator.com/item?id=${story.objectID}")
                    } else {
                        Stdout.line!("  ${story.url}")
                    }
                    Stdout.line!("")
                }
            }

            Stdout.line!("\nFound ${$interesting_count.to_str()} interesting stories")
            Ok({})
        }
        _ => {
            Stdout.line!("Error fetching stories: ${resp.statusCode.to_str()}")
            Ok({})
        }
    }
}

app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |_args| {
    Stdout.line!("Making 5 HTTP requests...")
    
    for i in [1, 2, 3, 4, 5] {
        resp = Http.get!("https://hacker-news.firebaseio.com/v0/item/46449643.json")
        Stdout.line!("Request ${i.to_str()}: status ${resp.statusCode.to_str()}")
    }
    
    Stdout.line!("Done!")
    Ok({})
}

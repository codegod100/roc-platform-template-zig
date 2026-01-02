app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |_args| {
    Stdout.line!("Making HTTP request...")
    resp = Http.get!("https://httpbin.org/get")
    
    Stdout.line!("Status: ${resp.statusCode.to_str()}")
    Stdout.line!("Body length: ${List.len(resp.responseBody).to_str()} bytes")
    
    Ok({})
}

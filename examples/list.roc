app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |_args| {
    Stdout.line!("Fetching https://example.com ...")
    resp = Http.get!("https://example.com")
    Stdout.line!("requestUrl: ${resp.requestUrl}")
    Stdout.line!("responseBody length: ${Str.inspect(List.len(resp.responseBody))}")
    Stdout.line!("responseHeaders: ${Str.inspect(resp.responseHeaders)}")

    first_bytes = resp.responseBody.take_first(100)
    s = Str.from_utf8(first_bytes)?
    Stdout.line!("Response body (first 100 bytes):")
    Stdout.line!(s)
    Ok({})
}

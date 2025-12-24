app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |args| {
    url = args.get(1)?
    Stdout.line!("Fetching ${url} ...")
    resp = Http.get!(url)
    Stdout.line!("requestUrl: ${resp.requestUrl}")
    Stdout.line!("statusCode: ${Str.inspect(resp.statusCode)}")
    Stdout.line!("responseBody length: ${Str.inspect(List.len(resp.responseBody))}")
    Stdout.line!("responseHeaders: ${Str.inspect(resp.responseHeaders)}")

    first_bytes = List.take_first(resp.responseBody, 100)
    s = Str.from_utf8(first_bytes)?
    Stdout.line!("Response body (first 100 bytes):")
    Stdout.line!(s)
    Ok({})
}

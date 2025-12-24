app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |args| {
    url = args.get(1)?
    Stdout.line!("Fetching ${url} ...")
    resp = Http.get!(url)
    Stdout.line!("requestUrl: ${resp.requestUrl}")
    Stdout.line!("statusCode: ${resp.statusCode.to_str()}")
    Stdout.line!("responseBody length: ${resp.responseBody.len().to_str()}")
    Stdout.line!("responseHeaders: ${resp.responseHeaders.to_str()}")
    Stdout.line!("all: ${resp.to_str()}")

    s = resp.responseBody.take_first(100).to_str()?
    Stdout.line!("Response body (first 100 bytes):")
    Stdout.line!(s)
    Ok({})
}

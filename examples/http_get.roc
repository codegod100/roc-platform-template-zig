app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Http

main! = |_args| {
    url = "https://www.google.com"
    Stdout.line!("Fetching ${url} ...")
    resp = Http.get!(url)
    Stdout.line!("requestUrl: ${resp.requestUrl}")
    Stdout.line!("statusCode: ${resp.statusCode.to_str()}")
    Stdout.line!("responseBody length: ${List.len(resp.responseBody).to_str()}")
    Stdout.line!("responseHeaders: ${Str.inspect(resp.responseHeaders)}")

    Stdout.line!("Response body (first 100 bytes):")
    body_bytes = List.take_first(resp.responseBody, 100)
    match Str.from_utf8(body_bytes) {
        Ok(body_str) => Stdout.line!(body_str)
        Err(_) => Stdout.line!("<binary data, not valid UTF-8>")
    }

    Ok({})
}

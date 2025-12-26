app [main!] {
    pf: platform "../platform/main.roc"
}

import pf.Stdout

transform : Try(a, e) -> Try(a, e)
transform = |result| {
    match result {
        Ok(value) => Ok(value)
        Err(e) => Err(e)
    }
}

main! = |_args| {
    result = transform(Ok(("hello", 42)))
    match result {
        Ok((s, _n)) => Stdout.line!("Got: ${s}")
        _ => Stdout.line!("Error")
    }
    Ok({})
}

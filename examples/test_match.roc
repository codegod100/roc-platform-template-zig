app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

main! = |_args| {
    result = match Ok(42) {
        Ok(n) => "got ok: ${n.to_str()}"
        Err(_) => "got err"
    }
    Stdout.line!(result)
    Ok({})
}

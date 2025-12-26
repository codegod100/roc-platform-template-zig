app [main!] {
    pf: platform "https://github.com/lukewilliamboswell/roc-platform-template-zig/releases/download/0.6/2BfGn4M9uWJNhDVeMghGeXNVDFijMfPsmmVeo6M4QjKX.tar.zst"
}

import pf.Stdout
import pf.Stderr

# BUG REPRODUCER: "non-exhaustive match" runtime crash
#
# This generic function that transforms error types causes a runtime crash
# when the result is later matched on. The match inside str_err! works fine,
# but subsequent matches on the returned value fail with "non-exhaustive match".
#
# The bug appears to be in how the interpreter handles generic type instantiation
# for the return value - the Ok/Err tags don't match properly after the function returns.

str_err! : Str, Try((Str, U64), Str) => Try((Str, U64), [Exit(I32)])
str_err! = |stage, result| {
    match result {
        Ok(value) => Ok(value)
        Err(msg) => {
            Stderr.line!("Failed to ${stage}:\n${msg}")
            Err(Exit(1))
        }
    }
}

main! : List(Str) => Try({}, [Exit(I32)])
main! = |_args| {
    # This works fine - no generic wrapper
    result1 = parse_type()
    match result1 {
        Ok((name, index)) => Stdout.line!("Direct: ${name} at ${index.to_str()}")
        Err(e) => Stdout.line!("Error: ${e}")
    }

    # This crashes with "non-exhaustive match" - using generic str_err!
    result2 = str_err!("parse type", parse_type())
    match result2 {
        Ok((name, index)) => Stdout.line!("Via str_err: ${name} at ${index.to_str()}")
        Err(Exit(code)) => Stdout.line!("Exit: ${code.to_str()}")
    }

    Ok({})
}

Token : [
    IdentToken(Str),
    NumberToken(I64),
]

parse_type : () -> Try((Str, U64), Str)
parse_type = || {
    token : Token
    token = IdentToken("String")
    match token {
        IdentToken(name) => Ok((name, 3))
        NumberToken(_) => Err("expected identifier, got number")
    }
}
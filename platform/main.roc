platform ""
    requires {} { main! : List(Str) => Try({}, [OutOfBounds, Exit(I32), BadUtf8({ index: U64, problem: Str.Utf8Problem })]) }
    exposes [Stdout, Stderr, Stdin, Random, Http]
    packages {}
    provides { main_for_host!: "main_for_host" }
    targets: {
        files: "targets/",
        exe: {
            x64mac: ["libhost.a", app],
            arm64mac: ["libhost.a", app],
            x64musl: ["crt1.o", "libhost.a", app, "libc.a"],
            x64glibc: ["libhost.a", app],
            arm64musl: ["crt1.o", "libhost.a", app, "libc.a"],
            x64win: ["host.lib", app],
            arm64win: ["host.lib", app],
            wasm32: ["libhost.a", app],
        }
    }

import Stdout
import Stderr
import Stdin
import Random
import Http

main_for_host! : List(Str) => I32
main_for_host! = |args| {
    result = main!(args)
    match result {
        Ok({}) => 0
        Err(Exit(code)) => code
    }
}

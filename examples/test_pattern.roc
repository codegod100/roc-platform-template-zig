app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout

MyService := [Service(Str)].{
    get_name = |self| match self {
        Service(name) => name
    }
}

create_service : Str -> MyService
create_service = |name| Service(name)

main! = |_args| {
    svc = create_service("TestService")
    Stdout.line!("Service name: ${svc.get_name()}")
    Ok({})
}

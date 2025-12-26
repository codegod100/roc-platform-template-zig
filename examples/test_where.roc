app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger

# Just call Logger directly without where clause
main! = |_args| {
    Logger.info!("hello")
    Logger.debug!("world")
    Ok({})
}

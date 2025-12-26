app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger

# Import our platform-agnostic module
import Greeting

# =============================================================================
# Dependency Injection Example
# =============================================================================
# This demonstrates how to write platform-agnostic modules (like Greeting)
# that accept injected implementations. The Greeting module has NO platform
# imports - it only knows about the `write!` interface.
# =============================================================================

# =============================================================================
# Writer Implementations - These wrap platform-specific code
# =============================================================================

# Wraps Stdout
StdoutWriter := [StdoutWriter].{
    write! = |_self, msg| Stdout.line!(msg)
}

# Wraps Logger
LoggerWriter := [LoggerWriter].{
    write! = |_self, msg| Logger.log!(msg)
}

# Mock writer for testing - does nothing
NullWriter := [NullWriter].{
    write! = |_self, _msg| {}
}

# =============================================================================
# Main - Inject implementations into platform-agnostic code
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Dependency Injection Example ===")
    Stdout.line!("")

    # Create writer instances
    stdout_writer : StdoutWriter
    stdout_writer = StdoutWriter

    logger_writer : LoggerWriter
    logger_writer = LoggerWriter

    null_writer : NullWriter
    null_writer = NullWriter

    # Example 1: Inject StdoutWriter into the Greeting module
    Stdout.line!("Example 1: Greeting module with StdoutWriter")
    Stdout.line!("---------------------------------------------")
    Greeting.greet!(stdout_writer, "Alice")
    Greeting.farewell!(stdout_writer, "Alice")
    Greeting.introduce!(stdout_writer, "Bob", "engineer")
    Stdout.line!("")

    # Example 2: Inject LoggerWriter into the same module
    Stdout.line!("Example 2: Same module with LoggerWriter")
    Stdout.line!("-----------------------------------------")
    Greeting.greet!(logger_writer, "Charlie")
    Greeting.farewell!(logger_writer, "Charlie")
    Greeting.introduce!(logger_writer, "Diana", "designer")
    Stdout.line!("")

    # Example 3: Inject NullWriter (for testing/benchmarking)
    Stdout.line!("Example 3: Same module with NullWriter (silent)")
    Stdout.line!("------------------------------------------------")
    Greeting.greet!(null_writer, "Eve")
    Greeting.farewell!(null_writer, "Eve")
    Stdout.line!("  (no output - the module ran but writer did nothing)")
    Stdout.line!("")

    # Summary
    Stdout.line!("=== Key Point ===")
    Stdout.line!("The Greeting module has ZERO platform imports.")
    Stdout.line!("It works with any writer you inject!")
    Stdout.line!("")

    Ok({})
}

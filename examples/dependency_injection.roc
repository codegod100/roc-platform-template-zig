app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger
import pf.Storage

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
# Storage Implementations
# =============================================================================

# Wraps platform Storage
RealStorage := [RealStorage].{
    save! = |_self, key, value| Storage.save!(key, value)
}

# Mock storage for testing
MockStorage := [MockStorage].{
    save! = |_self, _key, _value| Ok({})
}

# =============================================================================
# Business logic that uses injected storage
# =============================================================================

save_user! : storage, Str, Str => Try({}, Str)
    where [storage.save! : storage, Str, Str => Try({}, Str)]
save_user! = |storage, user_id, data| {
    storage.save!("user:${user_id}", data)
}

# =============================================================================
# Main - Inject implementations into platform-agnostic code
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Dependency Injection Examples ===")
    Stdout.line!("")

    # Create writer instances
    stdout_writer : StdoutWriter
    stdout_writer = StdoutWriter

    logger_writer : LoggerWriter
    logger_writer = LoggerWriter

    null_writer : NullWriter
    null_writer = NullWriter

    # Example 1: Inject different writers into the Greeting module
    Stdout.line!("Example 1: Greeting module with StdoutWriter")
    Stdout.line!("---------------------------------------------")
    Greeting.greet!(stdout_writer, "Alice")
    Greeting.farewell!(stdout_writer, "Alice")
    Greeting.introduce!(stdout_writer, "Bob", "engineer")
    Stdout.line!("")

    Stdout.line!("Example 2: Same module with LoggerWriter")
    Stdout.line!("-----------------------------------------")
    Greeting.greet!(logger_writer, "Charlie")
    Greeting.farewell!(logger_writer, "Charlie")
    Stdout.line!("")

    Stdout.line!("Example 3: Same module with NullWriter (silent)")
    Stdout.line!("------------------------------------------------")
    Greeting.greet!(null_writer, "Diana")
    Greeting.farewell!(null_writer, "Diana")
    Stdout.line!("  (no output - the module ran but writer did nothing)")
    Stdout.line!("")

    # Example 4: Storage injection
    Stdout.line!("Example 4: Storage injection")
    Stdout.line!("----------------------------")

    real_storage : RealStorage
    real_storage = RealStorage

    mock_storage : MockStorage
    mock_storage = MockStorage

    Stdout.line!("With RealStorage:")
    _r1 = save_user!(real_storage, "alice", "Alice Smith")
    Stdout.line!("  Saved to disk")

    Stdout.line!("With MockStorage:")
    _r2 = save_user!(mock_storage, "bob", "Bob Jones")
    Stdout.line!("  Mock - no file created")
    Stdout.line!("")

    # Summary
    Stdout.line!("=== Key Point ===")
    Stdout.line!("The Greeting module has ZERO platform imports.")
    Stdout.line!("It works with any writer you inject!")
    Stdout.line!("")

    Ok({})
}

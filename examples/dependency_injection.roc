app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger
import pf.Storage

# =============================================================================
# Dependency Injection Example
# =============================================================================
# This example demonstrates dependency injection in Roc by passing
# implementations as parameters. The key is creating wrapper types that
# can be instantiated as values and passed to generic functions.
#
# Pattern: TypeName := [TagName].{ method = |self, args| ... }
# =============================================================================

# =============================================================================
# Writer Types - Wrapping DIFFERENT platform implementations
# =============================================================================

# Wraps Stdout - writes to standard output
StdoutWriter := [StdoutWriter].{
    write! = |_self, msg| Stdout.line!(msg)
}

# Wraps Logger - writes to platform logger (different output format)
LoggerWriter := [LoggerWriter].{
    write! = |_self, msg| Logger.log!(msg)
}

# Mock writer - does nothing (for testing/benchmarking)
NullWriter := [NullWriter].{
    write! = |_self, _msg| {}
}

# =============================================================================
# Storage Types - Wrapping DIFFERENT storage implementations
# =============================================================================

# Real storage - uses platform Storage (writes to disk)
RealStorage := [RealStorage].{
    save! = |_self, key, value| Storage.save!(key, value)
    load! = |_self, key| Storage.load!(key)
    exists! = |_self, key| Storage.exists!(key)
}

# Mock storage - always succeeds, stores nothing (for testing)
MockStorage := [MockStorage].{
    save! = |_self, _key, _value| Ok({})
    load! = |_self, key| Ok("mock:${key}")
    exists! = |_self, _key| Bool.True
}

# =============================================================================
# Generic Functions with Injected Dependencies
# =============================================================================

# Works with ANY writer that has a write! method
greet! : writer, Str => {}
    where [writer.write! : writer, Str => {}]
greet! = |writer, name| {
    writer.write!("Hello, ${name}!")
}

# Works with ANY storage that has save!/load! methods
save_user! : storage, Str, Str => Try({}, Str)
    where [storage.save! : storage, Str, Str => Try({}, Str)]
save_user! = |storage, user_id, data| {
    storage.save!("user:${user_id}", data)
}

# =============================================================================
# Main - Demonstrate Dependency Injection
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Dependency Injection Examples ===")
    Stdout.line!("")

    # Create instances of different implementations
    stdout_writer : StdoutWriter
    stdout_writer = StdoutWriter

    logger_writer : LoggerWriter
    logger_writer = LoggerWriter

    null_writer : NullWriter
    null_writer = NullWriter

    real_storage : RealStorage
    real_storage = RealStorage

    mock_storage : MockStorage
    mock_storage = MockStorage

    # Example 1: Same function, different writer implementations
    Stdout.line!("Example 1: greet! with Different Writers")
    Stdout.line!("-----------------------------------------")

    Stdout.line!("With StdoutWriter (writes to stdout):")
    greet!(stdout_writer, "Alice")

    Stdout.line!("With LoggerWriter (writes to logger):")
    greet!(logger_writer, "Bob")

    Stdout.line!("With NullWriter (silent - for testing):")
    greet!(null_writer, "Charlie")
    Stdout.line!("  (no output - perfect for benchmarks)")
    Stdout.line!("")

    # Example 2: Same function, different storage implementations
    Stdout.line!("Example 2: save_user! with Different Storage")
    Stdout.line!("---------------------------------------------")

    Stdout.line!("With RealStorage (writes to disk):")
    _r1 = save_user!(real_storage, "alice", "Alice Smith")
    Stdout.line!("  Saved to .roc_storage/user:alice")

    Stdout.line!("With MockStorage (no-op for testing):")
    _r2 = save_user!(mock_storage, "bob", "Bob Jones")
    Stdout.line!("  Mock always succeeds, no file created")
    Stdout.line!("")

    # Summary
    Stdout.line!("=== Key Takeaways ===")
    Stdout.line!("* StdoutWriter vs LoggerWriter - same interface, different output")
    Stdout.line!("* RealStorage vs MockStorage - same interface, different behavior")
    Stdout.line!("* NullWriter/MockStorage - inject for tests without side effects")
    Stdout.line!("* Functions don't know which implementation they're using")
    Stdout.line!("")
    Stdout.line!("=== Done ===")

    Ok({})
}

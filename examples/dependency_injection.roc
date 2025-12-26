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
# Writer Types - Different implementations of a "write" interface
# =============================================================================

# Standard output writer
ConsoleWriter := [ConsoleWriter].{
    write! = |_self, msg| Stdout.line!(msg)
}

# Logger writer - uses platform Logger
LogWriter := [LogWriter].{
    write! = |_self, msg| Logger.log!(msg)
}

# Prefixed writer - adds a prefix to all messages
PrefixedWriter := [PrefixedWriter(Str)].{
    write! = |self, msg| match self {
        PrefixedWriter(prefix) => Stdout.line!("[${prefix}] ${msg}")
    }
}

# Mock writer - for testing, adds [TEST] tag
TestWriter := [TestWriter].{
    write! = |_self, msg| Stdout.line!("[TEST] ${msg}")
}

# Silent writer - does nothing (useful for suppressing output)
NullWriter := [NullWriter].{
    write! = |_self, _msg| {}
}

# =============================================================================
# Generic Function with Injected Writer
# =============================================================================

# This function works with ANY type that has a write! method
say_hello! : writer, Str => {}
    where [writer.write! : writer, Str => {}]
say_hello! = |writer, name| {
    writer.write!("Hello, ${name}!")
}

# Another generic function
say_goodbye! : writer, Str => {}
    where [writer.write! : writer, Str => {}]
say_goodbye! = |writer, name| {
    writer.write!("Goodbye, ${name}!")
}

# =============================================================================
# Storage Types - Different storage implementations
# =============================================================================

# Real storage using platform Storage
FileStorage := [FileStorage].{
    save! = |_self, key, value| Storage.save!(key, value)
}

# Mock storage for testing - always succeeds
MockStorage := [MockStorage].{
    save! = |_self, _key, _value| Ok({})
}

# =============================================================================
# Generic Function with Injected Storage
# =============================================================================

store_value! : storage, Str, Str => Try({}, Str)
    where [storage.save! : storage, Str, Str => Try({}, Str)]
store_value! = |storage, key, value| {
    storage.save!(key, value)
}

# =============================================================================
# Main - Demonstrate Dependency Injection
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Dependency Injection Examples ===")
    Stdout.line!("")

    # Create writer instances - note the type annotation and value assignment
    console : ConsoleWriter
    console = ConsoleWriter

    prefixed : PrefixedWriter
    prefixed = PrefixedWriter("APP")

    tester : TestWriter
    tester = TestWriter

    silent : NullWriter
    silent = NullWriter

    log_writer : LogWriter
    log_writer = LogWriter

    # Example 1: Same function, different writers
    Stdout.line!("Example 1: Same Function, Different Writers")
    Stdout.line!("--------------------------------------------")

    Stdout.line!("With ConsoleWriter:")
    say_hello!(console, "Alice")

    Stdout.line!("With LogWriter (uses platform Logger):")
    say_hello!(log_writer, "Bob")

    Stdout.line!("With PrefixedWriter:")
    say_hello!(prefixed, "Charlie")

    Stdout.line!("With TestWriter:")
    say_hello!(tester, "Diana")

    Stdout.line!("With NullWriter (silent):")
    say_hello!(silent, "Eve")
    Stdout.line!("  (no output above - that's the point!)")
    Stdout.line!("")

    # Example 2: Multiple calls with same writer
    Stdout.line!("Example 2: Conversation with Injected Writer")
    Stdout.line!("---------------------------------------------")

    say_hello!(console, "World")
    say_goodbye!(console, "World")
    Stdout.line!("")

    Stdout.line!("Same conversation with PrefixedWriter:")
    say_hello!(prefixed, "World")
    say_goodbye!(prefixed, "World")
    Stdout.line!("")

    # Example 3: Storage injection
    Stdout.line!("Example 3: Storage Injection")
    Stdout.line!("-----------------------------")

    real_storage : FileStorage
    real_storage = FileStorage

    mock_storage : MockStorage
    mock_storage = MockStorage

    Stdout.line!("Saving with real storage:")
    _r1 = store_value!(real_storage, "user:alice", "Alice Smith")
    Stdout.line!("  Saved to .roc_storage/user:alice")

    Stdout.line!("Saving with mock storage:")
    _r2 = store_value!(mock_storage, "user:bob", "Bob Jones")
    Stdout.line!("  Mock storage always succeeds (no file created)")
    Stdout.line!("")

    # Example 4: Different prefixes
    Stdout.line!("Example 4: Multiple PrefixedWriter Instances")
    Stdout.line!("--------------------------------------------")

    app_writer : PrefixedWriter
    app_writer = PrefixedWriter("APP")

    db_writer : PrefixedWriter
    db_writer = PrefixedWriter("DB")

    api_writer : PrefixedWriter
    api_writer = PrefixedWriter("API")

    say_hello!(app_writer, "Application")
    say_hello!(db_writer, "Database")
    say_hello!(api_writer, "Service")
    Stdout.line!("")

    # Summary
    Stdout.line!("=== Key Takeaways ===")
    Stdout.line!("1. Define wrapper types: TypeName := [TagName].{ method = |self, args| ... }")
    Stdout.line!("2. Create instances with type annotation: x : TypeName; x = TagName")
    Stdout.line!("3. Pass instances to generic functions")
    Stdout.line!("4. Use 'where [type.method : type, Args => Ret]' for constraints")
    Stdout.line!("5. Same function works with ANY type that satisfies the constraint")
    Stdout.line!("")
    Stdout.line!("=== Done ===")

    Ok({})
}

module [greet!, farewell!, introduce!]

# =============================================================================
# Platform-Agnostic Greeting Module
# =============================================================================
# This module has NO platform imports - it only works with injected writers.
# You can use this with any writer implementation (Stdout, Logger, etc.)
# =============================================================================

# Greet someone using the injected writer
greet! : writer, Str => {}
    where [writer.write! : writer, Str => {}]
greet! = |writer, name| {
    writer.write!("Hello, ${name}!")
}

# Say goodbye using the injected writer
farewell! : writer, Str => {}
    where [writer.write! : writer, Str => {}]
farewell! = |writer, name| {
    writer.write!("Goodbye, ${name}!")
}

# Full introduction using the injected writer
introduce! : writer, Str, Str => {}
    where [writer.write! : writer, Str => {}]
introduce! = |writer, name, role| {
    writer.write!("Allow me to introduce ${name}, our ${role}.")
}

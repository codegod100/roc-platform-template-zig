app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger

# =============================================================================
# Minimal Dependency Injection Example - "Hello World" Style
# =============================================================================
# This is the simplest possible example of dependency injection in Roc.
# We pass a "writer" to a function, allowing different implementations.
# =============================================================================

# A function that accepts any "writer" that has a line! method
# This is dependency injection - the implementation is passed in!
greet! : Str, writer => {}
    where [writer.line! : Str => {}]
greet! = |name, writer| {
    writer.line!("Hello, ${name}!")
}

# Another function showing the same pattern
farewell! : Str, writer => {}
    where [writer.line! : Str => {}]
farewell! = |name, writer| {
    writer.line!("Goodbye, ${name}!")
}

# A function that requires TWO methods from the writer
greet_fancy! : Str, writer => {}
    where
        [writer.line! : Str => {}]
greet_fancy! = |name, writer| {
    writer.line!("=" |> Str.repeat(40))
    writer.line!("    Hello, ${name}! Welcome!")
    writer.line!("=" |> Str.repeat(40))
}

# Create a custom writer implementation
UppercaseWriter := [].{
    line! = |msg| Stdout.line!(Str.to_uppercase(msg))
}

# Another custom writer with a prefix
PrefixedWriter := [].{
    line! = |msg| Stdout.line!("[PREFIX] ${msg}")
}

main! = |_args| {
    Stdout.line!("=== Minimal Dependency Injection Demo ===\n")

    # Example 1: Use Stdout as the writer
    Stdout.line!("1. Using Stdout:")
    greet!("Alice", Stdout)
    farewell!("Alice", Stdout)
    Stdout.line!("")

    # Example 2: Use Logger as the writer
    Stdout.line!("2. Using Logger:")
    greet!("Bob", Logger)
    farewell!("Bob", Logger)
    Stdout.line!("")

    # Example 3: Use custom UppercaseWriter
    Stdout.line!("3. Using UppercaseWriter:")
    greet!("Charlie", UppercaseWriter)
    farewell!("Charlie", UppercaseWriter)
    Stdout.line!("")

    # Example 4: Use custom PrefixedWriter
    Stdout.line!("4. Using PrefixedWriter:")
    greet!("Diana", PrefixedWriter)
    farewell!("Diana", PrefixedWriter)
    Stdout.line!("")

    # Example 5: Mix and match!
    Stdout.line!("5. Fancy greetings with different writers:")
    greet_fancy!("Eve", Stdout)
    greet_fancy!("Frank", UppercaseWriter)
    greet_fancy!("Grace", PrefixedWriter)

    Stdout.line!("\n=== Key Takeaway ===")
    Stdout.line!("The SAME function (greet!) works with ANY writer")
    Stdout.line!("that has a line! method. That's dependency injection!")

    Ok({})
}

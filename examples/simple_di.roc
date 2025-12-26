app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger

# =============================================================================
# Simple Dependency Injection Example
# =============================================================================
# This demonstrates passing platform types as dependencies to achieve
# "generic" functions where the platform provides the actual implementation.
#
# Think of this like interfaces in OOP - you define what methods you need,
# and pass in an implementation that satisfies those requirements.
# =============================================================================

# =============================================================================
# Example 1: Basic Logger Injection
# =============================================================================

# Any function can accept a "logger" parameter with required methods.
# The "where" clause specifies what methods the logger must have.
calculate_with_logging! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate_with_logging! = |a, b, logger| {
    logger.info!("Starting calculation: ${Num.to_str(a)} + ${Num.to_str(b)}")
    result = a + b
    logger.info!("Result: ${Num.to_str(result)}")
    result
}

# =============================================================================
# Example 2: Calculator Service with Dependency Injection
# =============================================================================

# Define a calculator service that depends on a logger.
# The service will use the logger to track all operations.
Calculator := { logger : logger }
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}]

# Constructor function - pass in any logger implementation
create_calculator : logger -> Calculator
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}]
create_calculator = |logger|
    Calculator({ logger })

# All calculator operations use the injected logger
add! : Calculator, I64, I64 => I64
add! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.debug!("add(${Num.to_str(a)}, ${Num.to_str(b)})")
    result = a + b
    logger.info!("${Num.to_str(a)} + ${Num.to_str(b)} = ${Num.to_str(result)}")
    result
}

multiply! : Calculator, I64, I64 => I64
multiply! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.debug!("multiply(${Num.to_str(a)}, ${Num.to_str(b)})")
    result = a * b
    logger.info!("${Num.to_str(a)} * ${Num.to_str(b)} = ${Num.to_str(result)}")
    result
}

divide! : Calculator, I64, I64 => Result I64 [DivisionByZero]
divide! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.debug!("divide(${Num.to_str(a)}, ${Num.to_str(b)})")

    if b == 0 {
        logger.info!("Error: Division by zero attempted!")
        Err(DivisionByZero)
    } else {
        result = a // b
        logger.info!("${Num.to_str(a)} / ${Num.to_str(b)} = ${Num.to_str(result)}")
        Ok(result)
    }
}

# =============================================================================
# Example 3: Custom Logger Implementation
# =============================================================================

# You can create your own logger that wraps the platform's logger
# This demonstrates how you could customize behavior
PrefixLogger := { prefix : Str }.{
    info! = |msg| {
        prefixed = "[${prefix}] ${msg}"
        Logger.info!(prefixed)
    }

    debug! = |msg| {
        prefixed = "[${prefix}][DEBUG] ${msg}"
        Logger.debug!(prefixed)
    }

    log! = |msg| {
        prefixed = "[${prefix}] ${msg}"
        Logger.log!(prefixed)
    }
}

create_prefix_logger : Str -> PrefixLogger
create_prefix_logger = |prefix|
    PrefixLogger({ prefix })

# =============================================================================
# Example 4: Testing Different Logger Implementations
# =============================================================================

# A simple stdout-based logger for comparison
StdoutLogger := [].{
    info! = |msg| Stdout.line!("[INFO] ${msg}")
    debug! = |msg| Stdout.line!("[DEBUG] ${msg}")
    log! = |msg| Stdout.line!("[LOG] ${msg}")
}

# =============================================================================
# Main - Demonstrate Dependency Injection
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Simple Dependency Injection Example ===\n")

    # Example 1: Basic function with logger injection
    Stdout.line!("1. Basic Logger Injection:")
    Stdout.line!("   Using platform Logger:")
    _ = calculate_with_logging!(10, 5, Logger)
    Stdout.line!("   Using custom StdoutLogger:")
    _ = calculate_with_logging!(20, 3, StdoutLogger)
    Stdout.line!("")

    # Example 2: Calculator with standard platform logger
    Stdout.line!("2. Calculator Service with Platform Logger:")
    calc1 = create_calculator(Logger)
    result1 = add!(calc1, 100, 50)
    result2 = multiply!(calc1, 10, 5)
    _ = divide!(calc1, 20, 4)
    _ = divide!(calc1, 10, 0)  # This will error
    Stdout.line!("")

    # Example 3: Calculator with custom prefix logger
    Stdout.line!("3. Calculator Service with Custom PrefixLogger:")
    custom_logger = create_prefix_logger("CALC-SERVICE")
    calc2 = create_calculator(custom_logger)
    result3 = add!(calc2, 7, 8)
    result4 = multiply!(calc2, 3, 9)
    Stdout.line!("")

    # Example 4: Calculator with stdout logger
    Stdout.line!("4. Calculator Service with StdoutLogger:")
    calc3 = create_calculator(StdoutLogger)
    result5 = add!(calc3, 42, 13)
    Stdout.line!("")

    # Example 5: Chain multiple operations
    Stdout.line!("5. Chained Operations:")
    calc = create_calculator(Logger)
    intermediate = add!(calc, 10, 5)  # 15
    final = multiply!(calc, intermediate, 2)  # 30
    Stdout.line!("   Final result: ${Num.to_str(final)}")
    Stdout.line!("")

    Stdout.line!("=== Key Takeaways ===")
    Stdout.line!("• Functions can accept platform types as parameters")
    Stdout.line!("• Use 'where' clauses to specify required methods")
    Stdout.line!("• Different implementations can be passed (Logger, StdoutLogger, etc.)")
    Stdout.line!("• This enables testability, flexibility, and separation of concerns")
    Stdout.line!("• Similar to dependency injection in OOP languages")

    Ok({})
}

# Dependency Injection Examples

This directory contains examples demonstrating **dependency injection** in Roc, where platform types are passed as parameters to achieve generic-style functions with platform-provided implementations.

## Overview

Dependency injection allows you to:
- Write generic, reusable functions that work with any compatible implementation
- Test code by swapping in mock implementations
- Keep dependencies explicit and clear
- Achieve separation of concerns

## Quick Start

Run the simple example:
```bash
roc dev examples/simple_di.roc
```

Run the comprehensive example:
```bash
roc dev examples/dependency_injection.roc
```

## Examples Included

### 1. `simple_di.roc` - Focused Introduction

A clear, focused example perfect for learning the basics:

**What it demonstrates:**
- Basic logger injection into functions
- Calculator service with injected dependencies
- Creating custom logger implementations
- Using different implementations interchangeably

**Key code pattern:**
```roc
# Function accepts any logger with required methods
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")
    a + b
}

# Now use it with different loggers
result1 = calculate!(10, 5, Logger)        # Platform logger
result2 = calculate!(10, 5, StdoutLogger)  # Custom logger
```

### 2. `dependency_injection.roc` - Comprehensive Examples

A full-featured demonstration with real-world patterns:

**What it demonstrates:**
- Logger injection for tracking operations
- Storage injection for data persistence
- Multiple dependencies (logger + storage together)
- Complete user service with CRUD operations
- Data processing pipelines with dependencies
- Mock implementations for testing
- Service-oriented architecture patterns

**Key patterns:**
```roc
# Service with multiple dependencies
UserService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]]

# Create service by injecting dependencies
service = create_user_service(Logger, Storage)

# Use service
register_user!(service, "alice", "Alice Johnson")
get_user!(service, "alice")
```

## Core Concepts

### 1. Platform Types as Parameters

Instead of hardcoding platform dependencies:
```roc
# ❌ Hardcoded dependency
process_data! : Data => Result {} Str
process_data! = |data| {
    Logger.info!("Processing...")  # Locked to Logger
}
```

Pass them as parameters:
```roc
# ✅ Dependency injection
process_data! : Data, logger => Result {} Str
    where [logger.info! : Str => {}]
process_data! = |data, logger| {
    logger.info!("Processing...")  # Works with any logger
}
```

### 2. Where Clauses Define Requirements

The `where` clause specifies what methods a dependency must have:

```roc
send_notification! : Str, logger => {}
    where [logger.info! : Str => {}]
    
# This logger must have an info! method
# It can have other methods too, but info! is required
```

### 3. Custom Implementations

You can create custom implementations that wrap or extend platform types:

```roc
PrefixLogger := { prefix : Str }.{
    info! = |msg| Logger.info!("[${prefix}] ${msg}")
    debug! = |msg| Logger.debug!("[${prefix}] ${msg}")
}

# Usage
auth_logger = PrefixLogger({ prefix: "AUTH" })
calculate!(10, 5, auth_logger)
```

### 4. Services with Dependencies

Wrap dependencies in custom types for service-oriented designs:

```roc
Calculator := { logger : logger }
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}]

create_calculator : logger -> Calculator
create_calculator = |logger| Calculator({ logger })

add! : Calculator, I64, I64 => I64
add! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.info!("Adding ${Num.to_str(a)} + ${Num.to_str(b)}")
    a + b
}
```

## Available Platform Types

### Logger
```roc
Logger := [].{
    log! : Str => {}
    info! : Str => {}
    error! : Str => {}
    warn! : Str => {}
    debug! : Str => {}
}
```

### Storage
```roc
Storage := [].{
    save! : Str, Str => Result {} Str
    load! : Str => Result Str [NotFound, PermissionDenied, Other Str]
    delete! : Str => Result {} Str
    exists! : Str => Bool
    list! : {} => List Str
}
```

### Stdout / Stderr
```roc
Stdout := [].{
    line! : Str => {}
}

Stderr := [].{
    line! : Str => {}
}
```

## Benefits

1. **Testability** - Swap in mock implementations for testing
2. **Flexibility** - Use different implementations in different contexts
3. **Clarity** - Dependencies are explicit in function signatures
4. **Reusability** - Functions work with any compatible implementation
5. **Type Safety** - Compiler ensures implementations have required methods

## Real-World Use Cases

- **Logging**: Use different loggers in dev vs production
- **Storage**: Test with in-memory storage, deploy with database
- **APIs**: Mock external APIs for testing
- **Configuration**: Inject different configs for different environments
- **Feature Flags**: Control behavior by injecting different implementations

## Pattern Comparison

### Traditional OOP (Java/C#)
```java
interface Logger {
    void info(String msg);
}

void process(Data data, Logger logger) {
    logger.info("Processing...");
}
```

### Roc Dependency Injection
```roc
process! : Data, logger => {}
    where [logger.info! : Str => {}]
process! = |data, logger| {
    logger.info!("Processing...")
}
```

Same concept, functional style!

## Best Practices

1. **Keep it minimal** - Only require methods you actually need
2. **Be explicit** - Make dependencies parameters, not hidden
3. **Use constructors** - Create services with `create_*` functions
4. **Document requirements** - Comment what methods are needed and why
5. **Test with mocks** - Create simple mock implementations for testing

## Learn More

For detailed documentation, see:
- `docs/dependency_injection.md` - Complete guide with advanced patterns
- `examples/static_dispatch.roc` - Related pattern showing method-based dispatch

## Questions?

This pattern leverages Roc's:
- Static dispatch (`.method()` syntax)
- Structural typing (`where` clauses)
- Platform abstraction
- Effect system (the `!` suffix)

It's similar to:
- Interfaces in Java/C#/TypeScript
- Traits in Rust
- Duck typing in Python (but type-safe!)
- Type classes in Haskell

The key insight: **Platform types can be passed as values**, enabling flexible, testable, and reusable code!
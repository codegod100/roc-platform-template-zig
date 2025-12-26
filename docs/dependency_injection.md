# Dependency Injection in Roc

This guide explains how to use platform types as dependencies in Roc, enabling a pattern similar to dependency injection in other languages.

## Table of Contents

- [Overview](#overview)
- [Basic Concept](#basic-concept)
- [Simple Example](#simple-example)
- [Advanced Patterns](#advanced-patterns)
- [Best Practices](#best-practices)
- [Examples in This Project](#examples-in-this-project)

## Overview

Dependency injection is a design pattern where you pass dependencies (like loggers, storage, or other services) into functions or types, rather than hardcoding them. This makes your code:

- **More testable** - You can swap in mock implementations
- **More flexible** - Different contexts can use different implementations
- **More maintainable** - Dependencies are explicit and clear
- **More reusable** - Functions work with any compatible implementation

In Roc, you achieve this by:
1. Accepting platform types as parameters
2. Using `where` clauses to specify required methods
3. Passing different implementations at runtime

## Basic Concept

### Without Dependency Injection

```roc
# Hardcoded to use Logger
calculate! : I64, I64 => I64
calculate! = |a, b| {
    Logger.info!("Calculating ${Num.to_str(a)} + ${Num.to_str(b)}")
    a + b
}
```

### With Dependency Injection

```roc
# Accepts any logger implementation
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating ${Num.to_str(a)} + ${Num.to_str(b)}")
    a + b
}

# Now you can use it with different loggers:
result1 = calculate!(5, 3, Logger)
result2 = calculate!(5, 3, StdoutLogger)
result3 = calculate!(5, 3, CustomLogger)
```

## Simple Example

Here's a complete example of a calculator service that depends on a logger:

```roc
# Define a service that takes a logger as a dependency
Calculator := { logger : logger }
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}]

# Constructor - accepts any compatible logger
create_calculator : logger -> Calculator
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}]
create_calculator = |logger|
    Calculator({ logger })

# Operations use the injected logger
add! : Calculator, I64, I64 => I64
add! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.debug!("add(${Num.to_str(a)}, ${Num.to_str(b)})")
    result = a + b
    logger.info!("Result: ${Num.to_str(result)}")
    result
}

# Usage:
main! = |_args| {
    # Use platform logger
    calc1 = create_calculator(Logger)
    _ = add!(calc1, 10, 5)
    
    # Use custom logger
    calc2 = create_calculator(CustomLogger)
    _ = add!(calc2, 10, 5)
    
    Ok({})
}
```

## Advanced Patterns

### Multiple Dependencies

You can inject multiple dependencies into a service:

```roc
UserService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]]

create_user_service : logger, storage -> UserService
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]]
create_user_service = |logger, storage|
    UserService({ logger, storage })

save_user! : UserService, Str, Str => Result {} Str
save_user! = |service, user_id, data| {
    UserService({ logger, storage }) = service
    
    logger.info!("Saving user: ${user_id}")
    
    match storage.save!("user:${user_id}", data) {
        Ok({}) => {
            logger.info!("User saved successfully")
            Ok({})
        }
        Err(err) => {
            logger.error!("Failed to save user: ${err}")
            Err(err)
        }
    }
}
```

### Custom Logger Implementations

You can create custom loggers that wrap or extend platform loggers:

```roc
# A logger that adds a prefix to all messages
PrefixLogger := { prefix : Str }.{
    info! = |msg| {
        Logger.info!("[${prefix}] ${msg}")
    }
    
    debug! = |msg| {
        Logger.debug!("[${prefix}][DEBUG] ${msg}")
    }
    
    error! = |msg| {
        Logger.error!("[${prefix}][ERROR] ${msg}")
    }
}

create_prefix_logger : Str -> PrefixLogger
create_prefix_logger = |prefix|
    PrefixLogger({ prefix })

# Usage:
main! = |_args| {
    auth_logger = create_prefix_logger("AUTH")
    api_logger = create_prefix_logger("API")
    
    auth_service = create_service(auth_logger)
    api_service = create_service(api_logger)
    
    Ok({})
}
```

### Mock Implementations for Testing

Create simple mock implementations for testing:

```roc
MockLogger := [].{
    info! = |msg| Stdout.line!("[MOCK INFO] ${msg}")
    error! = |msg| Stdout.line!("[MOCK ERROR] ${msg}")
    debug! = |msg| Stdout.line!("[MOCK DEBUG] ${msg}")
}

# Now you can test without side effects:
test_calculation = |_args| {
    calc = create_calculator(MockLogger)
    result = add!(calc, 5, 3)
    # Assert result == 8
}
```

## Best Practices

### 1. Keep Dependencies Explicit

Always make dependencies explicit in function signatures:

```roc
# Good - clear dependencies
process_data! : Data, logger, storage => Result {} Str
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

# Avoid - hidden dependency
process_data! : Data => Result {} Str
process_data! = |data| {
    Logger.info!("Processing...")  # Hidden dependency!
    Storage.save!("key", "value")  # Hidden dependency!
}
```

### 2. Define Clear Interfaces

Use `where` clauses to specify exactly what methods you need:

```roc
# Specify only what you need
send_notification! : Str, logger => {}
    where [logger.info! : Str => {}]

# Don't require more than necessary
send_notification! : Str, logger => {}
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}],  # Not needed!
        [logger.error! : Str => {}],  # Not needed!
        [logger.warn! : Str => {}]    # Not needed!
```

### 3. Use Constructor Functions

Create constructor functions to initialize services with dependencies:

```roc
create_service : logger, storage, config -> Service
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]
create_service = |logger, storage, config|
    Service({ logger, storage, config })
```

### 4. Group Related Dependencies

If you have many dependencies, consider grouping them:

```roc
Dependencies := {
    logger : logger,
    storage : storage,
    cache : cache,
    config : config
}

create_app : Dependencies -> App
create_app = |deps|
    App(deps)
```

### 5. Document Required Methods

Make it clear what methods a dependency must implement:

```roc
# Process user requests
# Requires:
#   - logger.info! for tracking operations
#   - logger.error! for error reporting
#   - storage.load! for retrieving data
#   - storage.save! for persisting data
process_request! : Request, logger, storage => Result Response Str
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]],
        [storage.save! : Str, Str => Result {} Str]
process_request! = |request, logger, storage| {
    # Implementation...
}
```

## Examples in This Project

This repository contains complete working examples:

### 1. `examples/simple_di.roc`

A simple, focused example demonstrating:
- Basic logger injection
- Calculator service with dependency injection
- Custom logger implementations
- Using different loggers interchangeably

Run it:
```bash
roc dev examples/simple_di.roc
```

### 2. `examples/dependency_injection.roc`

A comprehensive example showing:
- Simple logger injection
- Storage injection
- Multiple dependencies (logger + storage)
- User service with full CRUD operations
- Data processing pipelines
- Mock implementations
- Real-world service patterns

Run it:
```bash
roc dev examples/dependency_injection.roc
```

## Platform Types Available

This platform provides the following types suitable for dependency injection:

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

### Stdout / Stderr / Stdin
```roc
Stdout := [].{
    line! : Str => {}
}

Stderr := [].{
    line! : Str => {}
}

Stdin := [].{
    line! : {} => Str
}
```

### Random
```roc
Random := [].{
    seed_u64! : {} => U64
}
```

### Http
```roc
Http := [].{
    # ... (check Http.roc for available methods)
}
```

## Comparison with Other Languages

If you're coming from other languages, here's how Roc's approach compares:

### Java/C# Interfaces
```java
// Java
interface Logger {
    void info(String msg);
}

void calculate(int a, int b, Logger logger) {
    logger.info("Calculating...");
}
```

```roc
# Roc
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")
}
```

### Python Duck Typing
```python
# Python
def calculate(a, b, logger):
    logger.info("Calculating...")  # Duck typing
```

```roc
# Roc - Similar but type-safe
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")
}
```

### Rust Traits
```rust
// Rust
trait Logger {
    fn info(&self, msg: &str);
}

fn calculate<L: Logger>(a: i64, b: i64, logger: &L) -> i64 {
    logger.info("Calculating...");
    a + b
}
```

```roc
# Roc - Similar concept
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")
    a + b
}
```

## Conclusion

Dependency injection in Roc provides:
- Type-safe abstraction over implementations
- Clear, explicit dependencies
- Easy testing with mock implementations
- Flexible, reusable code
- A functional approach to a classic OOP pattern

By passing platform types as parameters and using `where` clauses to specify required methods, you can build flexible, testable, and maintainable applications in Roc.
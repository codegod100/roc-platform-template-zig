# Dependency Injection Cheat Sheet

Quick reference for dependency injection patterns in Roc.

## Basic Pattern

```roc
# Function that accepts a dependency
my_func! : Data, logger => Result
    where [logger.info! : Str => {}]
my_func! = |data, logger| {
    logger.info!("Processing...")
    # ... implementation
}

# Call with any compatible logger
result = my_func!(data, Logger)
result = my_func!(data, CustomLogger)
```

## Where Clauses

```roc
# Single requirement
func! : Data, logger => Result
    where [logger.info! : Str => {}]

# Multiple requirements
func! : Data, logger => Result
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}]

# Multiple dependencies
func! : Data, logger, storage => Result
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]
```

## Service Pattern

```roc
# Define service with dependencies
MyService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

# Constructor
create_service : logger, storage -> MyService
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]
create_service = |logger, storage|
    MyService({ logger, storage })

# Method using dependencies
process! : MyService, Data => Result
process! = |service, data| {
    MyService({ logger, storage }) = service
    logger.info!("Processing...")
    storage.save!("key", "value")
}

# Usage
service = create_service(Logger, Storage)
result = process!(service, data)
```

## Custom Implementation

```roc
# Wrapper that adds prefix
PrefixLogger := { prefix : Str }.{
    info! = |msg| Logger.info!("[${prefix}] ${msg}")
    error! = |msg| Logger.error!("[${prefix}] ${msg}")
}

# Constructor
create_prefix_logger : Str -> PrefixLogger
create_prefix_logger = |prefix|
    PrefixLogger({ prefix })

# Usage
auth_logger = create_prefix_logger("AUTH")
func!(data, auth_logger)
```

## Mock Implementation

```roc
# Simple mock for testing
MockLogger := [].{
    info! = |msg| Stdout.line!("[MOCK INFO] ${msg}")
    error! = |msg| Stderr.line!("[MOCK ERROR] ${msg}")
}

# Use in tests
test_my_function = {
    service = create_service(MockLogger, MockStorage)
    result = process!(service, test_data)
    # Assert result...
}
```

## Multiple Dependencies

```roc
# Group dependencies in a record
Dependencies := {
    logger : logger,
    storage : storage,
    cache : cache
}

# Create app with dependencies
App := { deps : Dependencies }

create_app : logger, storage, cache -> App
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [cache.get! : Str => Result Str [NotFound]]
create_app = |logger, storage, cache|
    App({ deps: { logger, storage, cache } })
```

## Platform Types Quick Reference

```roc
# Logger
Logger.log!("message")
Logger.info!("message")
Logger.error!("message")
Logger.warn!("message")
Logger.debug!("message")

# Storage
Storage.save!(key, value) -> Result {} Str
Storage.load!(key) -> Result Str [NotFound, PermissionDenied, Other Str]
Storage.delete!(key) -> Result {} Str
Storage.exists!(key) -> Bool
Storage.list!({}) -> List Str

# Stdout/Stderr
Stdout.line!("message")
Stderr.line!("message")

# Stdin
Stdin.line!({}) -> Str

# Random
Random.seed_u64!({}) -> U64
```

## Common Patterns

### Logger with Error Handling
```roc
process! : Data, logger => Result {} Str
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}]
process! = |data, logger| {
    logger.info!("Starting process...")
    
    match do_work(data) {
        Ok(result) => {
            logger.info!("Success!")
            Ok(result)
        }
        Err(err) => {
            logger.error!("Failed: ${err}")
            Err(err)
        }
    }
}
```

### Storage with Logging
```roc
save_data! : Str, Str, logger, storage => Result {} Str
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]
save_data! = |key, value, logger, storage| {
    logger.info!("Saving ${key}...")
    
    match storage.save!(key, value) {
        Ok({}) => {
            logger.info!("Saved successfully")
            Ok({})
        }
        Err(err) => {
            logger.info!("Save failed: ${err}")
            Err(err)
        }
    }
}
```

### Pipeline Pattern
```roc
Pipeline := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]],
        [storage.save! : Str, Str => Result {} Str]

run_pipeline! : Pipeline, Str, Str => Result Str Str
run_pipeline! = |pipeline, input_key, output_key| {
    Pipeline({ logger, storage }) = pipeline
    
    logger.info!("Starting pipeline")
    
    # Step 1: Load
    data = storage.load!(input_key)?
    
    # Step 2: Transform
    logger.info!("Transforming data")
    transformed = transform(data)
    
    # Step 3: Save
    storage.save!(output_key, transformed)?
    
    logger.info!("Pipeline complete")
    Ok(transformed)
}
```

## Best Practices

### ✅ DO
```roc
# Be explicit about dependencies
func! : Data, logger, storage => Result
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

# Only require methods you use
func! : Data, logger => Result
    where [logger.info! : Str => {}]

# Use constructors for services
create_service : logger -> Service
create_service = |logger| Service({ logger })

# Document what dependencies do
# Requires logger.info! for tracking operations
func! : Data, logger => Result
    where [logger.info! : Str => {}]
```

### ❌ DON'T
```roc
# Hide dependencies
func! : Data => Result
func! = |data| {
    Logger.info!("...")  # Hidden dependency!
}

# Require unnecessary methods
func! : Data, logger => Result
    where
        [logger.info! : Str => {}],
        [logger.debug! : Str => {}],  # Not used
        [logger.error! : Str => {}],  # Not used

# Hardcode implementations
func! : Data => Result
func! = |data| {
    Logger.info!("...")  # Locked to Logger
}
```

## Testing Template

```roc
# Production
main! = |_args| {
    service = create_service(Logger, Storage)
    process!(service, data)
    Ok({})
}

# Testing
test_process = {
    mock_logger = MockLogger
    mock_storage = MockStorage
    service = create_service(mock_logger, mock_storage)
    
    result = process!(service, test_data)
    
    # Assertions...
    expect result == Ok(expected)
}
```

## Complete Example

```roc
app [main!] { pf: platform "../platform/main.roc" }

import pf.Logger
import pf.Storage

# Service definition
UserService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]]

# Constructor
create_user_service : logger, storage -> UserService
    where
        [logger.info! : Str => {}],
        [logger.error! : Str => {}],
        [storage.save! : Str, Str => Result {} Str],
        [storage.load! : Str => Result Str [NotFound, PermissionDenied, Other Str]]
create_user_service = |logger, storage|
    UserService({ logger, storage })

# Service methods
save_user! : UserService, Str, Str => Result {} Str
save_user! = |service, user_id, data| {
    UserService({ logger, storage }) = service
    
    logger.info!("Saving user: ${user_id}")
    
    match storage.save!("user:${user_id}", data) {
        Ok({}) => {
            logger.info!("User saved!")
            Ok({})
        }
        Err(err) => {
            logger.error!("Failed to save user: ${err}")
            Err(err)
        }
    }
}

get_user! : UserService, Str => Result Str Str
get_user! = |service, user_id| {
    UserService({ logger, storage }) = service
    
    logger.info!("Loading user: ${user_id}")
    
    match storage.load!("user:${user_id}") {
        Ok(data) => {
            logger.info!("User found!")
            Ok(data)
        }
        Err(NotFound) => {
            logger.error!("User not found")
            Err("User not found")
        }
        Err(_) => {
            logger.error!("Error loading user")
            Err("Load error")
        }
    }
}

# Main
main! = |_args| {
    # Inject dependencies
    service = create_user_service(Logger, Storage)
    
    # Use service
    save_user!(service, "alice", "Alice Johnson")
    get_user!(service, "alice")
    
    Ok({})
}
```

## Quick Commands

```bash
# Run examples
roc dev examples/di_hello.roc              # Simplest
roc dev examples/simple_di.roc             # Tutorial
roc dev examples/dependency_injection.roc  # Comprehensive

# Build standalone
roc build examples/simple_di.roc
```

## Further Reading

- `docs/dependency_injection.md` - Complete guide
- `docs/di_diagram.md` - Visual explanations
- `examples/DI_README.md` - Examples overview
- `examples/static_dispatch.roc` - Related pattern
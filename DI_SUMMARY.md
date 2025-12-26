# Dependency Injection in Roc - Complete Summary

This document provides an overview of all the dependency injection examples and documentation added to this project.

## 🎯 What is This?

This demonstrates how to pass **platform types as dependencies** in Roc to create "generic" functions where the platform provides the actual implementation. Think of it like:
- **Interfaces** in Java/C#/TypeScript
- **Traits** in Rust
- **Duck typing** in Python (but type-safe!)
- **Type classes** in Haskell

## 📁 Files Created

### Platform Types (Infrastructure)
```
platform/Logger.roc    - Logger interface with log!, info!, error!, warn!, debug!
platform/Storage.roc   - Storage interface with save!, load!, delete!, exists!, list!
```

These are exposed from `platform/main.roc` for applications to use.

### Examples (From Simple to Complex)

#### 1. `examples/di_hello.roc` - Absolute Beginner
**Start here!** The simplest possible example.
- Single function that accepts different "writers"
- Custom implementations (UppercaseWriter, PrefixedWriter)
- Shows the core concept in ~80 lines

```bash
roc dev examples/di_hello.roc
```

#### 2. `examples/simple_di.roc` - Focused Tutorial
**Best for learning.** Clean, focused examples.
- Basic logger injection
- Calculator service with dependencies
- Custom prefix logger
- Multiple logger implementations
- ~175 lines of well-commented code

```bash
roc dev examples/simple_di.roc
```

#### 3. `examples/dependency_injection.roc` - Comprehensive
**Real-world patterns.** Production-ready examples.
- Logger injection
- Storage injection
- Multiple dependencies (logger + storage)
- Complete UserService with CRUD operations
- Data processing pipelines
- Mock implementations for testing
- ~320 lines with 6 major examples

```bash
roc dev examples/dependency_injection.roc
```

### Documentation

#### 1. `docs/dependency_injection.md` - Complete Guide
**Main documentation.** Everything you need to know.
- Overview and basic concepts
- Simple to advanced patterns
- Multiple dependencies
- Custom implementations
- Mock implementations for testing
- Best practices
- Comparison with other languages (Java, Python, Rust)
- Real-world use cases

#### 2. `docs/di_diagram.md` - Visual Guide
**Visual learner?** ASCII diagrams explaining concepts.
- Core concept diagrams
- Flow diagrams
- Service architecture patterns
- Testing with mocks
- Type constraints visualization
- Benefits summary
- Anti-patterns to avoid

#### 3. `examples/DI_README.md` - Quick Start
**Quick reference** for the examples directory.
- Overview of all examples
- Quick start commands
- Core concepts explained
- Available platform types
- Pattern comparison
- Best practices summary

## 🚀 Quick Start

1. **Absolute beginner? Start here:**
   ```bash
   roc dev examples/di_hello.roc
   ```

2. **Want to learn the pattern? Go here:**
   ```bash
   roc dev examples/simple_di.roc
   ```

3. **Need production patterns? Try this:**
   ```bash
   roc dev examples/dependency_injection.roc
   ```

4. **Read the docs:**
   - `docs/dependency_injection.md` - Complete guide
   - `docs/di_diagram.md` - Visual explanations
   - `examples/DI_README.md` - Quick reference

## 💡 Core Concept in 30 Seconds

### Without DI (Hardcoded)
```roc
calculate! : I64, I64 => I64
calculate! = |a, b| {
    Logger.info!("Calculating...")  # ❌ Locked to Logger
    a + b
}
```

### With DI (Flexible)
```roc
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")  # ✅ Any logger works!
    a + b
}

# Now use it with ANY compatible implementation:
result1 = calculate!(5, 3, Logger)        # Platform logger
result2 = calculate!(5, 3, StdoutLogger)  # Custom logger
result3 = calculate!(5, 3, MockLogger)    # Test logger
```

## 🎓 Key Patterns Demonstrated

### 1. Basic Function Injection
Pass dependencies as function parameters:
```roc
greet! : Str, logger => {}
    where [logger.info! : Str => {}]
greet! = |name, logger| {
    logger.info!("Hello, ${name}!")
}
```

### 2. Service Pattern
Wrap dependencies in a service type:
```roc
Calculator := { logger : logger }
    where [logger.info! : Str => {}]

create_calculator : logger -> Calculator
create_calculator = |logger| Calculator({ logger })
```

### 3. Multiple Dependencies
Inject multiple dependencies at once:
```roc
UserService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

service = create_user_service(Logger, Storage)
```

### 4. Custom Implementations
Create wrapper implementations:
```roc
PrefixLogger := { prefix : Str }.{
    info! = |msg| Logger.info!("[${prefix}] ${msg}")
}

auth_logger = PrefixLogger({ prefix: "AUTH" })
```

### 5. Mock for Testing
Simple mocks for testing without side effects:
```roc
MockLogger := [].{
    info! = |msg| Stdout.line!("[MOCK] ${msg}")
}

calc = create_calculator(MockLogger)  # Test without real logging
```

## 🔧 Platform Types Available

### Logger
```roc
Logger.log!("message")
Logger.info!("message")
Logger.error!("message")
Logger.warn!("message")
Logger.debug!("message")
```

### Storage
```roc
Storage.save!(key, value)
Storage.load!(key)
Storage.delete!(key)
Storage.exists!(key)
Storage.list!({})
```

### Stdout/Stderr/Stdin
```roc
Stdout.line!("message")
Stderr.line!("message")
Stdin.line!({})
```

### Random
```roc
Random.seed_u64!({})
```

## ✅ Benefits

1. **Testability** - Swap real implementations with mocks
2. **Flexibility** - Different implementations in different contexts
3. **Clarity** - Dependencies are explicit in signatures
4. **Reusability** - Functions work with any compatible type
5. **Type Safety** - Compiler ensures correct implementations
6. **Separation of Concerns** - Business logic decoupled from infrastructure

## 🎯 Real-World Use Cases

- **Logging**: Different loggers for dev/staging/prod
- **Storage**: In-memory for tests, database for production
- **APIs**: Mock external APIs during testing
- **Configuration**: Different configs per environment
- **Feature Flags**: Control behavior dynamically
- **Time/Random**: Deterministic behavior in tests

## 📚 Learning Path

1. **Start**: Read `examples/di_hello.roc` (5 minutes)
2. **Learn**: Read `examples/simple_di.roc` (10 minutes)
3. **Practice**: Read `examples/dependency_injection.roc` (15 minutes)
4. **Deep Dive**: Read `docs/dependency_injection.md` (20 minutes)
5. **Visual**: Read `docs/di_diagram.md` (10 minutes)
6. **Reference**: Keep `examples/DI_README.md` handy

Total time: ~1 hour to understand dependency injection in Roc!

## 🔑 Key Insight

**Platform types can be passed as values!**

This simple idea enables:
- Generic, reusable functions
- Easy testing with mocks
- Clear separation of concerns
- Type-safe dependency injection
- All the benefits of OOP interfaces, in a functional style

## 🎨 Related Concepts

This pattern leverages:
- **Static dispatch** - The `.method()` syntax
- **Structural typing** - The `where` clauses
- **Platform abstraction** - Platform-provided types
- **Effect system** - The `!` suffix for effects

Related examples in this repo:
- `examples/static_dispatch.roc` - Method-based dispatch patterns

## 🤝 Comparison with Other Languages

| Language | Pattern | Roc Equivalent |
|----------|---------|----------------|
| Java/C# | Interfaces | `where` clauses |
| Rust | Traits | `where` clauses |
| Python | Duck typing | `where` clauses (but type-safe!) |
| Haskell | Type classes | `where` clauses |
| TypeScript | Interfaces | `where` clauses |
| Go | Interfaces | `where` clauses |

**All achieve the same goal: flexible, testable, reusable code!**

## 📝 Next Steps

1. Run the examples to see DI in action
2. Read the documentation to understand the patterns
3. Try creating your own services with injected dependencies
4. Experiment with custom logger/storage implementations
5. Use mocks to test your code without side effects

## 🎉 Summary

You now have:
- ✅ 3 complete working examples (simple to complex)
- ✅ Comprehensive documentation with patterns
- ✅ Visual diagrams explaining concepts
- ✅ Platform types ready to use (Logger, Storage)
- ✅ Best practices and anti-patterns
- ✅ Comparison with other languages

**Start with `examples/di_hello.roc` and work your way up!**

Happy coding! 🚀
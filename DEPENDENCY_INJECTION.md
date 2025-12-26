# Dependency Injection in Roc 🚀

A complete guide and examples for implementing dependency injection patterns in Roc by passing platform types as function parameters.

## 🎯 What Is This?

This demonstrates how to create **"generic" functions** in Roc where the **platform provides the actual implementation**. It's like:

- **Interfaces** in Java/C#/TypeScript
- **Traits** in Rust  
- **Type classes** in Haskell
- **Duck typing** in Python (but type-safe!)

Instead of hardcoding dependencies like `Logger` or `Storage`, you pass them as parameters, making your code testable, flexible, and reusable.

## ⚡ Quick Example

### Before (Hardcoded)
```roc
calculate! : I64, I64 => I64
calculate! = |a, b| {
    Logger.info!("Calculating...")  # ❌ Locked to Logger
    a + b
}
```

### After (Dependency Injection)
```roc
calculate! : I64, I64, logger => I64
    where [logger.info! : Str => {}]
calculate! = |a, b, logger| {
    logger.info!("Calculating...")  # ✅ Any logger works!
    a + b
}

# Now use with ANY compatible implementation:
result1 = calculate!(5, 3, Logger)        # Platform logger
result2 = calculate!(5, 3, StdoutLogger)  # Custom logger
result3 = calculate!(5, 3, MockLogger)    # Test mock
```

## 🚀 Quick Start

Run the examples to see it in action:

```bash
# Absolute beginner? Start here (5 min)
roc dev examples/di_hello.roc

# Want to learn the pattern? Try this (10 min)
roc dev examples/simple_di.roc

# Need real-world patterns? Run this (15 min)
roc dev examples/dependency_injection.roc
```

## 📚 Documentation

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[DI_SUMMARY.md](./DI_SUMMARY.md)** | Overview of all files | Start here |
| **[docs/dependency_injection.md](./docs/dependency_injection.md)** | Complete guide | Deep dive |
| **[docs/di_cheatsheet.md](./docs/di_cheatsheet.md)** | Quick reference | Keep handy |
| **[docs/di_diagram.md](./docs/di_diagram.md)** | Visual guide | Visual learner? |
| **[examples/DI_README.md](./examples/DI_README.md)** | Examples overview | Before examples |

## 📁 What's Included

### Platform Types (Infrastructure)
- `platform/Logger.roc` - Logging interface
- `platform/Storage.roc` - Storage interface

### Examples (Beginner → Advanced)
1. **`examples/di_hello.roc`** (80 lines)
   - Simplest possible example
   - Perfect for understanding the core concept
   - Run first!

2. **`examples/simple_di.roc`** (175 lines)
   - Clean, focused tutorial
   - Calculator service example
   - Custom logger implementations
   - Best for learning

3. **`examples/dependency_injection.roc`** (320 lines)
   - Comprehensive real-world patterns
   - Multiple dependencies
   - Complete CRUD service
   - Data processing pipelines
   - Production-ready code

## 💡 Core Pattern

```roc
# 1. Accept dependency as parameter
my_func! : Data, logger => Result
           # ^^^^^^ dependency parameter

# 2. Specify requirements with 'where'
    where [logger.info! : Str => {}]
    #     ^^^^^^^^^^^^^^^^^^^^^^^^^ contract

# 3. Use the dependency
my_func! = |data, logger| {
    logger.info!("Processing...")
    # ... implementation
}

# 4. Call with any compatible implementation
result = my_func!(data, Logger)       # Platform
result = my_func!(data, CustomLogger) # Custom
result = my_func!(data, MockLogger)   # Testing
```

## 🎓 Key Patterns

### Basic Function Injection
```roc
greet! : Str, logger => {}
    where [logger.info! : Str => {}]
greet! = |name, logger| {
    logger.info!("Hello, ${name}!")
}
```

### Service with Dependencies
```roc
Calculator := { logger : logger }
    where [logger.info! : Str => {}]

create_calculator : logger -> Calculator
create_calculator = |logger| Calculator({ logger })

add! : Calculator, I64, I64 => I64
add! = |calc, a, b| {
    Calculator({ logger }) = calc
    logger.info!("Adding ${Num.to_str(a)} + ${Num.to_str(b)}")
    a + b
}
```

### Multiple Dependencies
```roc
UserService := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

service = create_user_service(Logger, Storage)
save_user!(service, "alice", "Alice Johnson")
```

### Custom Implementation
```roc
PrefixLogger := { prefix : Str }.{
    info! = |msg| Logger.info!("[${prefix}] ${msg}")
}

auth_logger = PrefixLogger({ prefix: "AUTH" })
greet!("Alice", auth_logger)  # Output: [AUTH] Hello, Alice!
```

### Mock for Testing
```roc
MockLogger := [].{
    info! = |msg| Stdout.line!("[MOCK] ${msg}")
}

# Test without side effects
calc = create_calculator(MockLogger)
result = add!(calc, 5, 3)
```

## 🔧 Available Platform Types

```roc
# Logger
Logger.log!("message")
Logger.info!("message")
Logger.error!("message")
Logger.warn!("message")
Logger.debug!("message")

# Storage
Storage.save!(key, value)
Storage.load!(key)
Storage.delete!(key)
Storage.exists!(key)
Storage.list!({})

# Standard I/O
Stdout.line!("message")
Stderr.line!("message")
Stdin.line!({})

# Random
Random.seed_u64!({})
```

## ✅ Benefits

| Benefit | Description |
|---------|-------------|
| **Testability** | Swap real implementations with mocks |
| **Flexibility** | Different implementations per context |
| **Clarity** | Dependencies explicit in signatures |
| **Reusability** | Functions work with any compatible type |
| **Type Safety** | Compiler ensures correct implementations |
| **Maintainability** | Business logic decoupled from infrastructure |

## 🎯 Real-World Use Cases

- **Logging**: Different loggers for dev/staging/production
- **Storage**: In-memory for tests, database for production
- **APIs**: Mock external services during testing
- **Configuration**: Environment-specific configs
- **Feature Flags**: Dynamic behavior control
- **Time/Random**: Deterministic behavior in tests

## 📖 Learning Path

| Step | Resource | Time | What You'll Learn |
|------|----------|------|-------------------|
| 1 | `examples/di_hello.roc` | 5 min | Basic concept |
| 2 | `examples/simple_di.roc` | 10 min | Core patterns |
| 3 | `examples/dependency_injection.roc` | 15 min | Real-world usage |
| 4 | `docs/dependency_injection.md` | 20 min | Complete guide |
| 5 | `docs/di_diagram.md` | 10 min | Visual understanding |
| 6 | `docs/di_cheatsheet.md` | - | Quick reference |

**Total: ~1 hour to master dependency injection in Roc!**

## 🔑 Key Insight

> **Platform types can be passed as values!**

This simple realization enables:
- Generic, reusable functions
- Easy testing with mocks
- Clear separation of concerns
- Type-safe dependency injection
- All the benefits of OOP interfaces, in functional style

## 🤝 Comparison with Other Languages

| Language | Pattern | Roc Equivalent |
|----------|---------|----------------|
| Java/C# | `interface Logger` | `where [logger.info! : ...]` |
| Rust | `trait Logger` | `where [logger.info! : ...]` |
| TypeScript | `interface Logger` | `where [logger.info! : ...]` |
| Python | Duck typing | `where [logger.info! : ...]` (type-safe) |
| Haskell | Type classes | `where [logger.info! : ...]` |
| Go | `interface Logger` | `where [logger.info! : ...]` |

## 🎨 Related Concepts

This pattern leverages:
- **Static dispatch** - The `.method()` syntax
- **Structural typing** - The `where` clauses  
- **Platform abstraction** - Platform-provided types
- **Effect system** - The `!` suffix for effects

See also:
- `examples/static_dispatch.roc` - Method-based dispatch patterns

## 🏗️ Project Structure

```
roc-platform-template-zig/
├── DEPENDENCY_INJECTION.md          ← You are here
├── DI_SUMMARY.md                    ← Complete file overview
│
├── platform/
│   ├── Logger.roc                   ← Logger interface
│   ├── Storage.roc                  ← Storage interface
│   └── main.roc                     ← Exposes Logger & Storage
│
├── examples/
│   ├── DI_README.md                 ← Examples overview
│   ├── di_hello.roc                 ← Simplest example (start here!)
│   ├── simple_di.roc                ← Tutorial example
│   └── dependency_injection.roc     ← Comprehensive example
│
└── docs/
    ├── dependency_injection.md      ← Complete guide
    ├── di_cheatsheet.md             ← Quick reference
    └── di_diagram.md                ← Visual explanations
```

## ✨ Best Practices

### ✅ DO
- Make dependencies explicit in function signatures
- Only require methods you actually use
- Use constructor functions for services
- Create custom wrappers when needed
- Use mocks for testing

### ❌ DON'T
- Hide dependencies (don't hardcode them)
- Require unnecessary methods
- Over-complicate simple use cases
- Forget to document requirements

## 🚦 Getting Started

1. **Clone or download this repository**
2. **Ensure you have Roc installed** (see main README.md)
3. **Run your first example:**
   ```bash
   cd roc-platform-template-zig
   roc dev examples/di_hello.roc
   ```
4. **Read the output** and compare with the source code
5. **Progress through the examples** from simple to complex
6. **Read the documentation** for deeper understanding
7. **Build your own services** with injected dependencies

## 💬 Understanding the Syntax

```roc
greet! : Str, logger => {}
#        ^^^  ^^^^^^  ^^^^
#         |     |      └─ Return type
#         |     └─ Dependency parameter (generic)
#         └─ Regular parameter

    where [logger.info! : Str => {}]
#   ^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#     |              └─ Method signature requirement
#     └─ Constraint clause

greet! = |name, logger| {
#         ^^^^  ^^^^^^
#          |      └─ Use like any other parameter
#          └─ Bind parameters

    logger.info!("Hello, ${name}!")
#   ^^^^^^^^^^^^^ Call method on injected dependency
}
```

## 🎉 What You Get

After working through these materials, you'll understand:

✅ How to pass platform types as dependencies  
✅ How to use `where` clauses to specify requirements  
✅ How to create services with multiple dependencies  
✅ How to build custom implementations  
✅ How to test with mocks  
✅ How to apply these patterns to real-world code  

## 🔗 Resources

- **Main Platform README**: [README.md](./README.md)
- **Roc Language**: https://www.roc-lang.org/
- **Static Dispatch**: `examples/static_dispatch.roc`

## 📝 Next Steps

1. ✅ Run `roc dev examples/di_hello.roc`
2. ✅ Read `examples/simple_di.roc` source code
3. ✅ Try modifying an example to use your own logger
4. ✅ Create a simple service with injected dependencies
5. ✅ Read `docs/dependency_injection.md` for complete patterns

## 🎓 Summary

**Dependency injection in Roc** = Passing platform types as parameters + using `where` clauses to specify requirements.

This enables:
- Flexible, testable, maintainable code
- Clear separation of concerns
- Type-safe generic programming
- All benefits of OOP interfaces in functional style

**Start with `examples/di_hello.roc` and work your way up!**

Happy coding! 🚀

---

**Questions?** Check the documentation files or explore the examples!
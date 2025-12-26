# Dependency Injection - Master Index

> **Quick Start:** Run `roc dev examples/di_hello.roc` then read `DEPENDENCY_INJECTION.md`

## 📑 Table of Contents

- [What is This?](#what-is-this)
- [Quick Start](#quick-start)
- [File Guide](#file-guide)
- [Learning Paths](#learning-paths)
- [Examples Index](#examples-index)
- [Documentation Index](#documentation-index)
- [Key Concepts](#key-concepts)

---

## What is This?

A complete dependency injection implementation for Roc, demonstrating how to pass platform types as function parameters to create generic, testable, and flexible code.

**The Core Idea:** Instead of hardcoding dependencies, pass them as parameters!

```roc
# ❌ Before: Hardcoded
greet! = |name| Logger.info!("Hello, ${name}!")

# ✅ After: Dependency Injection
greet! = |name, logger| logger.info!("Hello, ${name}!")
#                ^^^^^^ Can be ANY compatible logger!
```

---

## Quick Start

### First 5 Minutes
```bash
roc dev examples/di_hello.roc
```

### Next 10 Minutes
```bash
roc dev examples/simple_di.roc
cat DEPENDENCY_INJECTION.md
```

### In Your Code
```roc
# Accept a logger dependency
my_func! : Data, logger => Result
    where [logger.info! : Str => {}]
my_func! = |data, logger| {
    logger.info!("Processing...")
    # ... your code
}

# Call with any compatible logger
result = my_func!(data, Logger)
```

---

## File Guide

### 🎯 Start Here
| File | Purpose | Time |
|------|---------|------|
| **[DEPENDENCY_INJECTION.md](./DEPENDENCY_INJECTION.md)** | Main guide - start here! | 5 min |
| **[examples/di_hello.roc](./examples/di_hello.roc)** | Simplest example | 5 min |

### 📚 Core Documentation
| File | Purpose | Time |
|------|---------|------|
| **[DI_SUMMARY.md](./DI_SUMMARY.md)** | Complete overview | 5 min |
| **[docs/dependency_injection.md](./docs/dependency_injection.md)** | Deep dive guide | 20 min |
| **[docs/di_cheatsheet.md](./docs/di_cheatsheet.md)** | Quick reference | - |
| **[docs/di_diagram.md](./docs/di_diagram.md)** | Visual explanations | 10 min |
| **[docs/di_roadmap.md](./docs/di_roadmap.md)** | Learning paths | 10 min |
| **[examples/DI_README.md](./examples/DI_README.md)** | Examples guide | 5 min |

### 💻 Examples (Beginner → Advanced)
| File | Level | Lines | Description |
|------|-------|-------|-------------|
| **[examples/di_hello.roc](./examples/di_hello.roc)** | Beginner | ~80 | ⭐ Simplest - Start here! |
| **[examples/simple_di.roc](./examples/simple_di.roc)** | Intermediate | ~175 | 📚 Best for learning |
| **[examples/dependency_injection.roc](./examples/dependency_injection.roc)** | Advanced | ~320 | 🏗️ Production patterns |

### 🔧 Platform Types
| File | Purpose |
|------|---------|
| **[platform/Logger.roc](./platform/Logger.roc)** | Logger interface |
| **[platform/Storage.roc](./platform/Storage.roc)** | Storage interface |
| **[platform/main.roc](./platform/main.roc)** | Exposes Logger & Storage |

---

## Learning Paths

### 🏃 Speed Runner (30 minutes)
Perfect when you need to get started quickly.
1. Run `examples/di_hello.roc` (5 min)
2. Run `examples/simple_di.roc` (10 min)
3. Read `docs/di_cheatsheet.md` (15 min)
4. ✅ Ready to code!

### 🎓 Academic (2 hours)
For deep understanding of concepts.
1. Read `DEPENDENCY_INJECTION.md` (15 min)
2. Read `docs/dependency_injection.md` (30 min)
3. Read `docs/di_diagram.md` (15 min)
4. Run all 3 examples (30 min)
5. Build your own service (30 min)
6. ✅ Expert level!

### 💼 Practical (45 minutes)
Balanced approach - theory and practice.
1. Run `examples/di_hello.roc` (5 min)
2. Run `examples/simple_di.roc` (10 min)
3. Run `examples/dependency_injection.roc` (15 min)
4. Read `docs/di_cheatsheet.md` (15 min)
5. ✅ Production ready!

### 🎨 Visual Learner (1 hour)
For those who learn best with diagrams.
1. Read `docs/di_diagram.md` (15 min)
2. Run `examples/di_hello.roc` (10 min)
3. Read `docs/dependency_injection.md` (20 min)
4. Run `examples/simple_di.roc` (15 min)
5. ✅ Visual + practical understanding!

---

## Examples Index

### Example 1: di_hello.roc (⭐ Start Here!)
**What:** Simplest possible dependency injection example  
**When to use:** First time learning the concept  
**Key concepts:**
- Passing dependencies as parameters
- Using `where` clauses
- Multiple implementations of the same interface

**Run it:**
```bash
roc dev examples/di_hello.roc
```

### Example 2: simple_di.roc (📚 Best for Learning)
**What:** Calculator service with dependency injection  
**When to use:** After understanding the basics  
**Key concepts:**
- Service pattern with wrapped dependencies
- Constructor functions
- Custom logger implementations
- Testing with different implementations

**Run it:**
```bash
roc dev examples/simple_di.roc
```

### Example 3: dependency_injection.roc (🏗️ Production)
**What:** Comprehensive real-world patterns  
**When to use:** When building production services  
**Key concepts:**
- Multiple dependencies (logger + storage)
- Complete CRUD operations
- Data processing pipelines
- Mock implementations for testing
- Error handling with DI

**Run it:**
```bash
roc dev examples/dependency_injection.roc
```

---

## Documentation Index

### DEPENDENCY_INJECTION.md
**Purpose:** Main entry point guide  
**Contains:**
- Quick overview and motivation
- Core concept with examples
- All key patterns
- Benefits summary
- Quick start guide

**Read when:** You're just getting started

### DI_SUMMARY.md
**Purpose:** Complete file overview  
**Contains:**
- List of all files created
- What each file contains
- Learning path summary
- Quick reference of resources

**Read when:** You want to see everything at a glance

### docs/dependency_injection.md
**Purpose:** Complete guide with all patterns  
**Contains:**
- Basic to advanced patterns
- Multiple dependencies
- Custom implementations
- Mock implementations
- Best practices and anti-patterns
- Comparison with other languages
- Real-world use cases

**Read when:** You want deep understanding

### docs/di_cheatsheet.md
**Purpose:** Quick reference for common patterns  
**Contains:**
- Code snippets for all patterns
- Platform types quick reference
- Common use cases
- Best practices summary
- Complete working example

**Read when:** You need quick syntax lookup

### docs/di_diagram.md
**Purpose:** Visual explanations  
**Contains:**
- ASCII diagrams of concepts
- Flow charts
- Architecture patterns
- Comparison diagrams
- Benefits visualization

**Read when:** You prefer visual learning

### docs/di_roadmap.md
**Purpose:** Structured learning path  
**Contains:**
- Step-by-step progression
- Alternative learning paths
- Skill checkpoints
- Common questions
- Next steps after completion

**Read when:** You want a structured approach

### examples/DI_README.md
**Purpose:** Examples overview  
**Contains:**
- Summary of each example
- What you'll learn from each
- Quick start commands
- Core concepts review
- Available platform types

**Read when:** Before running the examples

---

## Key Concepts

### What is Dependency Injection?
Passing dependencies (like loggers, storage) as parameters instead of hardcoding them.

**Benefits:**
- ✅ Testable (use mocks)
- ✅ Flexible (swap implementations)
- ✅ Clear (dependencies explicit)
- ✅ Reusable (works with any compatible type)
- ✅ Type-safe (compiler verified)

### The Pattern

```roc
# 1. Function accepts dependency
my_func! : Data, logger => Result
    where [logger.info! : Str => {}]  # ← Requirement

# 2. Implementation uses dependency
my_func! = |data, logger| {
    logger.info!("Processing...")
    # ... code
}

# 3. Call with any compatible implementation
result = my_func!(data, Logger)       # Platform
result = my_func!(data, CustomLogger) # Custom
result = my_func!(data, MockLogger)   # Testing
```

### Platform Types Available

```roc
# Logger
Logger.log!("msg")
Logger.info!("msg")
Logger.error!("msg")
Logger.warn!("msg")
Logger.debug!("msg")

# Storage
Storage.save!(key, value)
Storage.load!(key)
Storage.delete!(key)
Storage.exists!(key)
Storage.list!({})

# I/O
Stdout.line!("msg")
Stderr.line!("msg")
Stdin.line!({})

# Random
Random.seed_u64!({})
```

---

## Quick Reference

### Creating a Function with DI
```roc
func! : Data, logger => Result
    where [logger.info! : Str => {}]
func! = |data, logger| {
    logger.info!("Working...")
    Ok(result)
}
```

### Creating a Service with DI
```roc
Service := { logger : logger, storage : storage }
    where
        [logger.info! : Str => {}],
        [storage.save! : Str, Str => Result {} Str]

create_service : logger, storage -> Service
create_service = |logger, storage|
    Service({ logger, storage })
```

### Custom Implementation
```roc
CustomLogger := { prefix : Str }.{
    info! = |msg| Logger.info!("[${prefix}] ${msg}")
}

logger = CustomLogger({ prefix: "API" })
```

### Mock for Testing
```roc
MockLogger := [].{
    info! = |msg| Stdout.line!("[MOCK] ${msg}")
}

service = create_service(MockLogger, MockStorage)
```

---

## Next Steps

1. **Run the simplest example:**
   ```bash
   roc dev examples/di_hello.roc
   ```

2. **Read the main guide:**
   ```bash
   cat DEPENDENCY_INJECTION.md
   ```

3. **Try the tutorial:**
   ```bash
   roc dev examples/simple_di.roc
   ```

4. **Build something:**
   - Create a service with injected dependencies
   - Add logging to track operations
   - Write tests with mock implementations

---

## File Tree

```
roc-platform-template-zig/
├── DI_INDEX.md                      ← 📑 You are here!
├── DEPENDENCY_INJECTION.md          ← 🎯 Start here
├── DI_SUMMARY.md                    ← 📋 Overview
│
├── platform/
│   ├── Logger.roc                   ← 🔧 Logger interface
│   ├── Storage.roc                  ← 🔧 Storage interface
│   └── main.roc                     ← 🔧 Exports both
│
├── examples/
│   ├── DI_README.md                 ← 📖 Examples guide
│   ├── di_hello.roc                 ← 1️⃣  Simplest (START)
│   ├── simple_di.roc                ← 2️⃣  Tutorial
│   └── dependency_injection.roc     ← 3️⃣  Production
│
└── docs/
    ├── dependency_injection.md      ← 📚 Deep dive
    ├── di_cheatsheet.md             ← 📝 Quick ref
    ├── di_diagram.md                ← 🎨 Visuals
    └── di_roadmap.md                ← 🗺️  Learning path
```

---

## Statistics

- **Platform Types:** 2 interfaces (Logger, Storage)
- **Examples:** 3 files (~575 lines total)
- **Documentation:** 7 files (~2,600 lines total)
- **Total:** ~3,200 lines of code and docs
- **Learning Time:** 30 min - 2 hours (depending on path)

---

## Support

**Need help?** Check these resources in order:

1. **Quick answer:** `docs/di_cheatsheet.md`
2. **Can't find a file:** This index (DI_INDEX.md)
3. **Don't understand concept:** `DEPENDENCY_INJECTION.md`
4. **Want deep dive:** `docs/dependency_injection.md`
5. **Prefer visuals:** `docs/di_diagram.md`
6. **Need structure:** `docs/di_roadmap.md`

---

## Summary

**Dependency Injection in Roc** = Pass platform types as parameters + use `where` clauses to specify requirements.

This enables flexible, testable, maintainable code with the benefits of OOP interfaces in a functional style.

**Start now:** `roc dev examples/di_hello.roc`

Happy coding! 🚀
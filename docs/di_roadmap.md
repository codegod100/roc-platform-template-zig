# Dependency Injection Learning Roadmap

A visual guide to learning dependency injection in Roc.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LEARNING ROADMAP                                 │
│                Dependency Injection in Roc                          │
└─────────────────────────────────────────────────────────────────────┘

START HERE
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 1: UNDERSTAND THE PROBLEM                                     │
│  ═════════════════════════════════════                              │
│                                                                      │
│  Read: DEPENDENCY_INJECTION.md (first section)                      │
│  Time: 5 minutes                                                    │
│                                                                      │
│  Key Question: Why do we need dependency injection?                 │
│                                                                      │
│  ❌ Problem: Hardcoded dependencies are inflexible                  │
│  ✅ Solution: Pass dependencies as parameters                       │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 2: SEE IT IN ACTION (SIMPLEST)                               │
│  ═══════════════════════════════════════                            │
│                                                                      │
│  Run: roc dev examples/di_hello.roc                                │
│  Read: examples/di_hello.roc (source code)                         │
│  Time: 10 minutes                                                   │
│                                                                      │
│  What You'll Learn:                                                 │
│  • How to pass a dependency as a parameter                         │
│  • How to use 'where' clauses                                      │
│  • How the same function works with different implementations      │
│                                                                      │
│  Key Concepts:                                                      │
│  ✓ Function parameter                                              │
│  ✓ Where clause                                                    │
│  ✓ Multiple implementations                                        │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 3: LEARN THE PATTERNS                                        │
│  ══════════════════════════                                         │
│                                                                      │
│  Run: roc dev examples/simple_di.roc                               │
│  Read: examples/simple_di.roc (source code)                        │
│  Time: 15 minutes                                                   │
│                                                                      │
│  What You'll Learn:                                                 │
│  • Service pattern (wrapping dependencies)                         │
│  • Constructor functions                                            │
│  • Custom logger implementations                                    │
│  • How to use multiple logger types                                │
│                                                                      │
│  Key Patterns:                                                      │
│  ✓ Service := { logger : logger }                                  │
│  ✓ create_service : logger -> Service                              │
│  ✓ Custom implementations                                          │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 4: REAL-WORLD USAGE                                          │
│  ═══════════════════════                                            │
│                                                                      │
│  Run: roc dev examples/dependency_injection.roc                    │
│  Read: examples/dependency_injection.roc (source code)             │
│  Time: 20 minutes                                                   │
│                                                                      │
│  What You'll Learn:                                                 │
│  • Multiple dependencies (logger + storage)                        │
│  • Complete CRUD service                                            │
│  • Data processing pipelines                                        │
│  • Mock implementations for testing                                │
│  • Production-ready patterns                                        │
│                                                                      │
│  Key Skills:                                                        │
│  ✓ Multi-dependency services                                       │
│  ✓ Error handling with DI                                          │
│  ✓ Testing strategies                                              │
│  ✓ Real-world architecture                                         │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 5: DEEP DIVE                                                 │
│  ═════════════════                                                  │
│                                                                      │
│  Read: docs/dependency_injection.md                                │
│  Time: 20 minutes                                                   │
│                                                                      │
│  What You'll Learn:                                                 │
│  • Advanced patterns                                                │
│  • Best practices                                                   │
│  • Anti-patterns to avoid                                          │
│  • Comparison with other languages                                 │
│  • Testing strategies                                              │
│                                                                      │
│  Topics Covered:                                                    │
│  ✓ Multiple dependencies                                           │
│  ✓ Custom implementations                                          │
│  ✓ Mock implementations                                            │
│  ✓ Best practices                                                  │
│  ✓ Real-world use cases                                            │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 6: VISUAL UNDERSTANDING                                      │
│  ════════════════════════════                                       │
│                                                                      │
│  Read: docs/di_diagram.md                                          │
│  Time: 10 minutes                                                   │
│                                                                      │
│  What You'll Learn:                                                 │
│  • Visual representation of concepts                               │
│  • Flow diagrams                                                   │
│  • Service architecture                                            │
│  • Testing patterns                                                │
│                                                                      │
│  Includes:                                                          │
│  ✓ Core concept diagrams                                           │
│  ✓ Real-world flow charts                                          │
│  ✓ Service architecture patterns                                   │
│  ✓ Benefits summary                                                │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  STEP 7: REFERENCE & PRACTICE                                      │
│  ════════════════════════════════                                   │
│                                                                      │
│  Bookmark: docs/di_cheatsheet.md                                   │
│  Time: Ongoing                                                      │
│                                                                      │
│  Use For:                                                           │
│  • Quick syntax reference                                          │
│  • Common patterns                                                 │
│  • Code snippets                                                   │
│  • Best practices reminder                                         │
│                                                                      │
│  Now: Build your own service!                                      │
│  ✓ Start with a simple function                                    │
│  ✓ Add a logger dependency                                         │
│  ✓ Create a service wrapper                                        │
│  ✓ Add storage dependency                                          │
│  ✓ Create custom implementations                                   │
│  ✓ Write tests with mocks                                          │
└─────────────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────────────┐
│  🎉 CONGRATULATIONS!                                               │
│                                                                      │
│  You now understand dependency injection in Roc!                   │
│                                                                      │
│  Total Time: ~1.5 hours                                            │
│  Skills Gained: ⭐⭐⭐⭐⭐                                           │
└─────────────────────────────────────────────────────────────────────┘
```

## Alternative Learning Paths

### 🏃 Speed Runner (30 minutes)
```
1. Run: examples/di_hello.roc                (5 min)
2. Run: examples/simple_di.roc              (10 min)
3. Read: docs/di_cheatsheet.md              (15 min)
└─→ You can now use DI in your code!
```

### 🎓 Academic (2 hours)
```
1. Read: DEPENDENCY_INJECTION.md            (15 min)
2. Read: docs/dependency_injection.md       (30 min)
3. Read: docs/di_diagram.md                 (15 min)
4. Run all examples                         (30 min)
5. Build your own service                   (30 min)
└─→ Deep understanding + practical experience
```

### 💼 Practical (45 minutes)
```
1. Run: examples/di_hello.roc               (5 min)
2. Run: examples/simple_di.roc              (10 min)
3. Run: examples/dependency_injection.roc   (15 min)
4. Read: docs/di_cheatsheet.md              (15 min)
└─→ Ready for production use!
```

### 🎨 Visual Learner (1 hour)
```
1. Read: docs/di_diagram.md                 (15 min)
2. Run: examples/di_hello.roc               (10 min)
3. Read: docs/dependency_injection.md       (20 min)
4. Run: examples/simple_di.roc              (15 min)
└─→ Visual + practical understanding
```

## Skill Progression

```
Level 1: BEGINNER
├─ Understand the concept
├─ Can pass dependencies to functions
├─ Use where clauses
└─ Run examples successfully
   Time to reach: 15 minutes

Level 2: INTERMEDIATE
├─ Create services with dependencies
├─ Write constructor functions
├─ Build custom implementations
└─ Use multiple dependencies
   Time to reach: 45 minutes

Level 3: ADVANCED
├─ Design service architectures
├─ Create mock implementations
├─ Test with dependency injection
└─ Apply to production code
   Time to reach: 1.5 hours

Level 4: EXPERT
├─ Teach others the pattern
├─ Design complex service hierarchies
├─ Create platform-level abstractions
└─ Contribute to the ecosystem
   Time to reach: With practice!
```

## Checkpoints

### ✅ After Step 2 (di_hello.roc)
Can you:
- [ ] Explain why we pass dependencies as parameters?
- [ ] Write a function that accepts a logger dependency?
- [ ] Use the same function with different implementations?

### ✅ After Step 3 (simple_di.roc)
Can you:
- [ ] Create a service type with dependencies?
- [ ] Write a constructor function?
- [ ] Build custom logger implementations?
- [ ] Use multiple logger types in one program?

### ✅ After Step 4 (dependency_injection.roc)
Can you:
- [ ] Create services with multiple dependencies?
- [ ] Implement CRUD operations with DI?
- [ ] Write mock implementations for testing?
- [ ] Design data processing pipelines?

### ✅ After Step 5 (docs)
Can you:
- [ ] Explain best practices?
- [ ] Identify anti-patterns?
- [ ] Compare DI in Roc vs other languages?
- [ ] Design service architectures?

## Common Questions at Each Step

### After Step 2
Q: Why not just use Logger directly?
A: Flexibility! You can swap implementations for testing, different environments, etc.

Q: What is a "where" clause?
A: It specifies what methods a dependency must have. Like a contract!

### After Step 3
Q: Why wrap dependencies in a service?
A: Organization! It groups related operations and their dependencies together.

Q: How do I know what methods to require?
A: Only require what you actually use in your functions.

### After Step 4
Q: When should I use multiple dependencies?
A: When your service needs multiple external resources (logging, storage, etc.)

Q: How do I test code with DI?
A: Create mock implementations that behave predictably in tests.

### After Step 5
Q: How is this different from OOP?
A: Same benefits, functional style! No classes, just functions and values.

Q: Can I use this in production?
A: Absolutely! These patterns are production-ready.

## Next Steps After Completion

1. **Build Something**
   - Create a user management service
   - Build a data processing pipeline
   - Design a multi-layer application

2. **Explore Related Patterns**
   - Read: examples/static_dispatch.roc
   - Study: Roc's effect system
   - Learn: Platform architecture

3. **Share Your Knowledge**
   - Teach a colleague
   - Write a blog post
   - Contribute examples

4. **Advanced Topics**
   - Design your own platform types
   - Create reusable service libraries
   - Contribute to Roc ecosystem

## Resources Quick Reference

| Resource | Purpose | Time |
|----------|---------|------|
| DEPENDENCY_INJECTION.md | Entry point | 5 min |
| examples/di_hello.roc | Simplest example | 10 min |
| examples/simple_di.roc | Tutorial | 15 min |
| examples/dependency_injection.roc | Real-world | 20 min |
| docs/dependency_injection.md | Complete guide | 20 min |
| docs/di_diagram.md | Visual guide | 10 min |
| docs/di_cheatsheet.md | Quick reference | Ongoing |
| DI_SUMMARY.md | File overview | 5 min |

## Your Journey

```
                    START
                      ↓
              [Understanding]
                      ↓
               [Simple Example]
                      ↓
              [Core Patterns]
                      ↓
              [Real-World Usage]
                      ↓
                [Deep Dive]
                      ↓
              [Visual Learning]
                      ↓
                 [Practice]
                      ↓
                   EXPERT! 🎉
```

**Remember:** Learning is iterative. Feel free to jump between resources as needed!

**Start your journey now:** `roc dev examples/di_hello.roc`

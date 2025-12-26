# Dependency Injection Visual Guide

## The Core Concept

```
┌─────────────────────────────────────────────────────────────┐
│  WITHOUT Dependency Injection (Hardcoded)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   greet! : Str => {}                                         │
│   greet! = |name|                                            │
│       Logger.info!("Hello, ${name}!")  ← Locked to Logger!  │
│                                                               │
│   Problem: Can't change the implementation                   │
│   Problem: Hard to test                                      │
│   Problem: Inflexible                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  WITH Dependency Injection (Flexible)                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   greet! : Str, writer => {}                                 │
│       where [writer.line! : Str => {}]                       │
│   greet! = |name, writer|                                    │
│       writer.line!("Hello, ${name}!")  ← Any writer works!  │
│                                                               │
│   Benefits: Change implementation at runtime                 │
│   Benefits: Easy to test with mocks                          │
│   Benefits: Reusable and flexible                            │
└─────────────────────────────────────────────────────────────┘
```

## How It Works

```
┌────────────────────────────────────────────────────────────────┐
│                    Your Generic Function                       │
│                                                                │
│   greet! : Str, logger => {}                                  │
│       where [logger.info! : Str => {}]    ← Requirement       │
│   greet! = |name, logger|                                     │
│       logger.info!("Hello ${name}")       ← Uses dependency   │
└────────────────────────────────────────────────────────────────┘
                              │
                              │ Can be called with ANY
                              │ implementation that has
                              │ an info! method
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │   Logger    │  │ StdoutLogger│  │  MockLogger │
    ├─────────────┤  ├─────────────┤  ├─────────────┤
    │ Platform    │  │ Custom      │  │ For testing │
    │ provided    │  │ wrapper     │  │ purposes    │
    └─────────────┘  └─────────────┘  └─────────────┘
```

## Real World Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Startup                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Create Dependencies (Constructor Pattern)                      │
│                                                                  │
│  logger = Logger                          ← Platform logger     │
│  storage = Storage                        ← Platform storage    │
│  service = create_service(logger, storage) ← Inject!            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Use Service (Dependencies are injected)                        │
│                                                                  │
│  process_request!(service, request)                             │
│      │                                                           │
│      └─→ Uses logger internally                                 │
│      └─→ Uses storage internally                                │
└─────────────────────────────────────────────────────────────────┘
```

## Service Architecture Pattern

```
┌────────────────────────────────────────────────────────────┐
│                      UserService                           │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  Dependencies:                                       │ │
│  │    • logger  : Logger   ← Injected                  │ │
│  │    • storage : Storage  ← Injected                  │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  Methods:                                                  │
│    register_user!(service, id, data)                      │
│    get_user!(service, id)                                 │
│    delete_user!(service, id)                              │
│                                                            │
│  Each method uses the injected dependencies               │
└────────────────────────────────────────────────────────────┘
           │                           │
           │ Uses                      │ Uses
           ▼                           ▼
    ┌──────────┐              ┌────────────┐
    │  Logger  │              │  Storage   │
    ├──────────┤              ├────────────┤
    │ info!    │              │ save!      │
    │ error!   │              │ load!      │
    │ warn!    │              │ exists!    │
    └──────────┘              └────────────┘
```

## Testing with Mocks

```
┌──────────────────────────────────────────────────────────┐
│               Production Environment                      │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  service = create_service(                               │
│      Logger,      ← Real platform logger                 │
│      Storage      ← Real platform storage                │
│  )                                                        │
│                                                           │
│  Logs go to actual logging system                        │
│  Data saved to actual storage                            │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│               Testing Environment                         │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  service = create_service(                               │
│      MockLogger,   ← Fake logger for testing             │
│      MockStorage   ← In-memory storage for testing       │
│  )                                                        │
│                                                           │
│  No side effects!                                         │
│  Fast and predictable                                     │
└──────────────────────────────────────────────────────────┘
```

## Multiple Dependencies Example

```
┌────────────────────────────────────────────────────────────┐
│                    DataProcessor                           │
│                                                            │
│  Dependencies needed:                                      │
│    1. logger  - for tracking operations                   │
│    2. storage - for reading/writing data                  │
│    3. cache   - for performance optimization              │
│                                                            │
│  ┌──────────────────────────────────────┐                │
│  │  DataProcessor := {                  │                │
│  │      logger: logger,                 │                │
│  │      storage: storage,               │                │
│  │      cache: cache                    │                │
│  │  }                                   │                │
│  └──────────────────────────────────────┘                │
│                                                            │
│  All injected at construction time!                       │
└────────────────────────────────────────────────────────────┘
                    │
                    │ Created with:
                    ▼
    create_processor(Logger, Storage, Cache)
```

## Type Constraints (Where Clauses)

```
┌────────────────────────────────────────────────────────────┐
│  Function Signature with Requirements                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  process! : Data, logger, storage => Result {} Str        │
│      where                                                 │
│          [logger.info! : Str => {}]        ← Required     │
│          [logger.error! : Str => {}]       ← Required     │
│          [storage.save! : Str, Str => Result {} Str]      │
│          [storage.load! : Str => Result Str [NotFound]]   │
│                                                            │
│  The 'where' clause defines the contract:                 │
│  "I need a logger with info! and error! methods"          │
│  "I need a storage with save! and load! methods"          │
│                                                            │
│  Any type that satisfies these requirements works!        │
└────────────────────────────────────────────────────────────┘
```

## Comparison with OOP Patterns

```
┌────────────────────────────────────────────────────────────┐
│  Java/C# Interface Pattern                                 │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  interface Logger {                                        │
│      void info(String msg);                               │
│  }                                                         │
│                                                            │
│  void process(Data data, Logger logger) {                 │
│      logger.info("Processing...");                        │
│  }                                                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
                         ≈ equivalent to
┌────────────────────────────────────────────────────────────┐
│  Roc Dependency Injection                                  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  process! : Data, logger => {}                            │
│      where [logger.info! : Str => {}]                     │
│  process! = |data, logger|                                │
│      logger.info!("Processing...")                        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Benefits Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    BENEFITS                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✓ Testability                                             │
│    └─→ Swap real implementations with mocks               │
│                                                             │
│  ✓ Flexibility                                             │
│    └─→ Different implementations in different contexts    │
│                                                             │
│  ✓ Clarity                                                 │
│    └─→ Dependencies are explicit in function signatures   │
│                                                             │
│  ✓ Reusability                                             │
│    └─→ Functions work with any compatible implementation  │
│                                                             │
│  ✓ Type Safety                                             │
│    └─→ Compiler ensures implementations have required     │
│        methods at compile time                             │
│                                                             │
│  ✓ Separation of Concerns                                  │
│    └─→ Business logic separated from infrastructure       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Common Use Cases

```
┌────────────────────┬───────────────────────────────────────┐
│ Use Case           │ Why Dependency Injection Helps        │
├────────────────────┼───────────────────────────────────────┤
│ Logging            │ Different log levels/destinations     │
│                    │ per environment                        │
├────────────────────┼───────────────────────────────────────┤
│ Storage/Database   │ In-memory for tests, real DB for prod │
├────────────────────┼───────────────────────────────────────┤
│ API Clients        │ Mock responses in tests               │
├────────────────────┼───────────────────────────────────────┤
│ Configuration      │ Different configs per environment     │
├────────────────────┼───────────────────────────────────────┤
│ Time/Randomness    │ Deterministic behavior in tests       │
├────────────────────┼───────────────────────────────────────┤
│ Feature Flags      │ Enable/disable features dynamically   │
└────────────────────┴───────────────────────────────────────┘
```

## Anti-Patterns to Avoid

```
❌ DON'T: Require methods you don't use
┌─────────────────────────────────────────────┐
│ process! : Data, logger => {}               │
│     where                                   │
│         [logger.info! : Str => {}]          │
│         [logger.debug! : Str => {}]  ← Not used
│         [logger.error! : Str => {}]  ← Not used
│         [logger.warn! : Str => {}]   ← Not used
└─────────────────────────────────────────────┘

✓ DO: Only require what you need
┌─────────────────────────────────────────────┐
│ process! : Data, logger => {}               │
│     where [logger.info! : Str => {}]        │
│ process! = |data, logger|                   │
│     logger.info!("Processing...")           │
└─────────────────────────────────────────────┘
```

```
❌ DON'T: Hide dependencies
┌─────────────────────────────────────────────┐
│ process! : Data => {}                       │
│ process! = |data|                           │
│     Logger.info!("...")  ← Hidden!          │
│     Storage.save!("...")  ← Hidden!         │
└─────────────────────────────────────────────┘

✓ DO: Make dependencies explicit
┌─────────────────────────────────────────────┐
│ process! : Data, logger, storage => {}      │
│     where                                   │
│         [logger.info! : Str => {}]          │
│         [storage.save! : Str, Str => Result {} Str]
│ process! = |data, logger, storage|          │
│     logger.info!("...")  ← Clear!           │
│     storage.save!("...")  ← Clear!          │
└─────────────────────────────────────────────┘
```

## Quick Reference

```
┌──────────────────────────────────────────────────────────────┐
│  Pattern Components                                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Accept dependency as parameter                          │
│     my_func! : Data, logger => Result                       │
│                      ^^^^^^ dependency                       │
│                                                              │
│  2. Specify requirements with 'where'                       │
│     where [logger.info! : Str => {}]                        │
│            ^^^^^^^^^^^^^^^^^^^^ contract                     │
│                                                              │
│  3. Use dependency in implementation                        │
│     my_func! = |data, logger|                               │
│         logger.info!("...")                                 │
│                                                              │
│  4. Call with any compatible implementation                 │
│     result = my_func!(data, Logger)        ← Platform       │
│     result = my_func!(data, MockLogger)    ← Custom         │
│     result = my_func!(data, CustomLogger)  ← Custom         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

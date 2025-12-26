app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdout
import pf.Logger
import pf.Storage

# =============================================================================
# Dependency Injection Example
# =============================================================================
# This example demonstrates how to use platform types (Logger, Storage)
# for dependency injection patterns in Roc.
#
# Note: Nominal types in Roc use tag unions as payload. This example shows
# patterns that work with the current compiler.
#
# KNOWN ISSUE: Storage operations may hit wildcard patterns due to Result/Try
# type matching differences between the platform ABI and Roc's expectations.
# The example still runs but storage data may not be retrieved correctly.
# =============================================================================

# =============================================================================
# Example 1: Direct Platform Type Usage
# =============================================================================
# The simplest form - just use platform types directly in functions.

greet_with_logging! : Str => {}
greet_with_logging! = |name| {
    Logger.info!("Greeting user: ${name}")
    Logger.log!("Hello, ${name}!")
}

process_request! : Str => Try({}, Str)
process_request! = |request_id| {
    Logger.info!("Processing request: ${request_id}")

    if Str.is_empty(request_id) {
        Logger.error!("Empty request ID!")
        Err("Invalid request")
    } else {
        Logger.info!("Request ${request_id} completed successfully")
        Ok({})
    }
}

# =============================================================================
# Example 2: Storage Operations
# =============================================================================

save_user_data! : Str, Str => Try({}, Str)
save_user_data! = |user_id, data| {
    key = "user:${user_id}"
    Logger.debug!("Saving data for key: ${key}")
    Storage.save!(key, data)
}

load_user_data! : Str => Try(Str, Str)
load_user_data! = |user_id| {
    key = "user:${user_id}"
    Logger.info!("Loading user data for: ${user_id}")

    match Storage.load!(key) {
        Ok(data) => {
            Logger.info!("Successfully loaded data for user: ${user_id}")
            Ok(data)
        }
        Err(NotFound) => {
            Logger.error!("User not found: ${user_id}")
            Err("User not found")
        }
        Err(PermissionDenied) => {
            Logger.error!("Permission denied for user: ${user_id}")
            Err("Permission denied")
        }
        Err(Other(msg)) => {
            Logger.error!("Error loading user: ${msg}")
            Err(msg)
        }
        # Catch-all for potential ABI mismatches
        _ => {
            Logger.warn!("Storage result pattern mismatch for user: ${user_id}")
            Err("Storage error")
        }
    }
}

# =============================================================================
# Example 3: Custom Logger Wrapper
# =============================================================================
# You can create wrapper types that add prefixes or other behavior

PrefixLogger := [PrefixLogger(Str)].{
    info! = |self, msg| match self {
        PrefixLogger(prefix) => Logger.info!("[${prefix}] ${msg}")
    }

    debug! = |self, msg| match self {
        PrefixLogger(prefix) => Logger.debug!("[${prefix}] ${msg}")
    }

    error! = |self, msg| match self {
        PrefixLogger(prefix) => Logger.error!("[${prefix}] ${msg}")
    }

    warn! = |self, msg| match self {
        PrefixLogger(prefix) => Logger.warn!("[${prefix}] ${msg}")
    }

    log! = |self, msg| match self {
        PrefixLogger(prefix) => Logger.log!("[${prefix}] ${msg}")
    }
}

create_prefix_logger : Str -> PrefixLogger
create_prefix_logger = |prefix| PrefixLogger(prefix)

# =============================================================================
# Example 4: Mock Logger for Testing
# =============================================================================
# A logger that outputs to stdout instead of the platform logger

MockLogger := [].{
    log! = |msg| Stdout.line!("[MOCK] ${msg}")
    info! = |msg| Stdout.line!("[MOCK INFO] ${msg}")
    error! = |msg| Stdout.line!("[MOCK ERROR] ${msg}")
    warn! = |msg| Stdout.line!("[MOCK WARN] ${msg}")
    debug! = |msg| Stdout.line!("[MOCK DEBUG] ${msg}")
}

# =============================================================================
# Example 5: Service Pattern
# =============================================================================
# Encapsulate related operations in a service

UserService := [UserService(Str)].{
    get_name = |self| match self {
        UserService(name) => name
    }
}

create_user_service : Str -> UserService
create_user_service = |name| UserService(name)

user_service_register! : UserService, Str, Str => Try({}, Str)
user_service_register! = |service, user_id, user_data| {
    svc_name = service.get_name()
    Logger.info!("[${svc_name}] Attempting to register user: ${user_id}")

    key = "user:${user_id}"
    if Storage.exists!(key) {
        Logger.warn!("[${svc_name}] User already exists: ${user_id}")
        Err("User already exists")
    } else {
        match Storage.save!(key, user_data) {
            Ok({}) => {
                Logger.info!("[${svc_name}] Successfully registered user: ${user_id}")
                Ok({})
            }
            Err(err) => {
                Logger.error!("[${svc_name}] Failed to register user: ${err}")
                Err(err)
            }
            # Catch-all for potential ABI mismatches
            _ => {
                Logger.warn!("[${svc_name}] Storage result pattern mismatch for user: ${user_id}")
                Err("Storage error")
            }
        }
    }
}

user_service_get! : UserService, Str => Try(Str, Str)
user_service_get! = |service, user_id| {
    svc_name = service.get_name()
    Logger.info!("[${svc_name}] Fetching user: ${user_id}")

    key = "user:${user_id}"
    match Storage.load!(key) {
        Ok(data) => {
            Logger.info!("[${svc_name}] Found user: ${user_id}")
            Ok(data)
        }
        Err(NotFound) => {
            Logger.warn!("[${svc_name}] User not found: ${user_id}")
            Err("User not found")
        }
        Err(PermissionDenied) => {
            Logger.error!("[${svc_name}] Permission denied accessing user: ${user_id}")
            Err("Permission denied")
        }
        Err(Other(msg)) => {
            Logger.error!("[${svc_name}] Error fetching user: ${msg}")
            Err(msg)
        }
        # Catch-all for potential ABI mismatches
        _ => {
            Logger.warn!("[${svc_name}] Storage result pattern mismatch for user: ${user_id}")
            Err("Storage error")
        }
    }
}

# =============================================================================
# Example 6: Data Processing Pipeline
# =============================================================================

DataProcessor := [DataProcessor(Str)].{
    get_name = |self| match self {
        DataProcessor(name) => name
    }
}

create_processor : Str -> DataProcessor
create_processor = |name| DataProcessor(name)

# Simple transformation: add prefix and suffix
transform_data : Str -> Str
transform_data = |s| {
    "<<${s}>>"
}

process_pipeline! : DataProcessor, Str, Str => Try(Str, Str)
process_pipeline! = |processor, input_key, output_key| {
    proc_name = processor.get_name()

    Logger.info!("[${proc_name}] Starting pipeline")
    Logger.debug!("[${proc_name}] Input: ${input_key}, Output: ${output_key}")

    match Storage.load!(input_key) {
        Ok(data) => {
            Logger.info!("[${proc_name}] Step 1: Loaded data")
            transformed = transform_data(data)
            Logger.debug!("[${proc_name}] Step 2: Transformed to: ${transformed}")

            match Storage.save!(output_key, transformed) {
                Ok({}) => {
                    Logger.info!("[${proc_name}] Step 3: Saved result")
                    Logger.info!("[${proc_name}] Pipeline completed successfully")
                    Ok(transformed)
                }
                Err(err) => {
                    Logger.error!("[${proc_name}] Failed to save: ${err}")
                    Err("Save failed")
                }
            }
        }
        Err(NotFound) => {
            Logger.error!("[${proc_name}] Input not found: ${input_key}")
            Err("Input not found")
        }
        Err(PermissionDenied) => {
            Logger.error!("[${proc_name}] Permission denied")
            Err("Permission denied")
        }
        Err(Other(msg)) => {
            Logger.error!("[${proc_name}] Error: ${msg}")
            Err(msg)
        }
        # Catch-all for potential ABI mismatches
        _ => {
            Logger.warn!("[${proc_name}] Storage result pattern mismatch")
            Err("Storage error")
        }
    }
}

# =============================================================================
# Main Function - Demonstrate All Examples
# =============================================================================

main! = |_args| {
    Stdout.line!("=== Dependency Injection Examples ===")
    Stdout.line!("")

    # Example 1: Simple logging
    Stdout.line!("Example 1: Direct Platform Type Usage")
    Stdout.line!("--------------------------------------")
    greet_with_logging!("Alice")
    _result1 = process_request!("req-12345")
    _result2 = process_request!("")
    Stdout.line!("")

    # Example 2: Storage operations
    Stdout.line!("Example 2: Storage Operations")
    Stdout.line!("------------------------------")
    _save_result = save_user_data!("user-001", "Alice Johnson")
    _load_result1 = load_user_data!("user-001")
    _load_result2 = load_user_data!("nonexistent")
    Stdout.line!("")

    # Example 3: Custom prefix logger
    Stdout.line!("Example 3: Custom Prefix Logger")
    Stdout.line!("--------------------------------")
    app_logger = create_prefix_logger("APP")
    _log1 = app_logger.info!("Application started")
    _log2 = app_logger.debug!("Debug message from app")
    Stdout.line!("")

    # Example 4: Mock logger
    Stdout.line!("Example 4: Mock Logger")
    Stdout.line!("-----------------------")
    MockLogger.info!("This is a mock log message")
    MockLogger.error!("This is a mock error")
    Stdout.line!("")

    # Example 5: User Service
    Stdout.line!("Example 5: User Service Pattern")
    Stdout.line!("--------------------------------")
    user_service = create_user_service("UserService")
    _reg_result1 = user_service_register!(user_service, "alice", "Alice Johnson, age 30")
    _reg_result2 = user_service_register!(user_service, "bob", "Bob Smith, age 25")
    _reg_result3 = user_service_register!(user_service, "alice", "duplicate")
    _get_result1 = user_service_get!(user_service, "alice")
    _get_result2 = user_service_get!(user_service, "charlie")
    Stdout.line!("")

    # Example 6: Data Processing Pipeline
    Stdout.line!("Example 6: Data Processing Pipeline")
    Stdout.line!("------------------------------------")
    processor = create_processor("DataTransformer")
    _save = Storage.save!("input-data", "hello world")
    _pipeline = process_pipeline!(processor, "input-data", "output-data")

    match Storage.load!("output-data") {
        Ok(result) => Stdout.line!("Final result: ${result}")
        Err(_) => Stdout.line!("Could not load result")
        # Catch-all for potential ABI mismatches
        _ => Stdout.line!("Storage result pattern mismatch")
    }
    Stdout.line!("")

    Stdout.line!("=== Key Takeaways ===")
    Stdout.line!("* Platform types (Logger, Storage) can be used directly")
    Stdout.line!("* Create wrapper types for custom behavior (PrefixLogger)")
    Stdout.line!("* Use service patterns to encapsulate related operations")
    Stdout.line!("* Mock implementations enable testing")
    Stdout.line!("")
    Stdout.line!("=== All Examples Complete ===")

    Ok({})
}

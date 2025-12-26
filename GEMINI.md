# Roc Platform Template (Zig)

This project is a template for creating [Roc platforms](https://www.roc-lang.org/platforms) using [Zig](https://ziglang.org) to implement the host environment. It provides a foundation for building Roc applications that can run on various operating systems (macOS, Linux, Windows) and WebAssembly.

## Project Structure

*   **`build.zig`**: The Zig build configuration file. It manages the compilation of the host library (`libhost.a` or `host.lib`) for multiple targets.
*   **`platform/`**: Contains the source code for the platform.
    *   **`main.roc`**: Defines the Roc platform interface, including the `main!` entry point and exposed modules (Stdout, Stderr, etc.).
    *   **`host.zig`**: The Zig implementation of the platform host. It handles memory allocation (using the C allocator), OS interactions (I/O, networking), and the interface between Roc and the OS.
    *   **`host_wasm.zig`**: Specific host implementation for the WebAssembly target.
    *   **`targets/`**: Stores the compiled host libraries for different architectures and OSs.
*   **`examples/`**: A collection of Roc programs demonstrating platform features (e.g., `hello_world.roc`, `http.roc`, `echo.roc`).
*   **`ci/`**: Continuous Integration scripts and tools.
    *   **`test_runner.zig`**: A Zig program that runs integration tests by executing `roc check`, `roc run`, and `roc build` on the examples.

## Key Technologies

*   **Roc**: The functional programming language the platform is built for.
*   **Zig**: Used to implement the low-level platform host, bridging Roc with the operating system.

## Building and Running

### Prerequisites

*   [Zig](https://ziglang.org/download/) (version 0.15.2 or compatible)
*   [Roc](https://www.roc-lang.org/) (nightly build)

### Build Commands

*   **Build all targets:**
    ```bash
    zig build -Doptimize=ReleaseSafe
    ```
    This cross-compiles the host library for all supported platforms (x64/arm64 on macOS, Linux, Windows, and WASM).

*   **Build native target only:**
    ```bash
    zig build native -Doptimize=ReleaseSafe
    ```
    Use this for faster local development.

*   **Bundle the platform:**
    ```bash
    ./bundle.sh
    ```
    Creates a `.tar.zst` archive containing the platform and pre-built host libraries, ready for use.

### Running Examples

*   **Run with Interpreter:**
    ```bash
    roc examples/hello_world.roc
    ```

*   **Build Standalone Executable:**
    ```bash
    roc build examples/hello_world.roc
    ./hello_world
    ```

### Testing

*   **Run all tests (Unit + Integration):**
    ```bash
    zig build test
    ```
    This command runs unit tests for `platform/host.zig` and executes the integration test runner (`ci/test_runner.zig`), which validates the examples.

## Development Conventions

*   **Host Implementation**: The `platform/host.zig` file contains the `main` entry point for the executable. It initializes the environment, sets up the Roc memory allocator (wrapping the C allocator), and calls the Roc program's `main_for_host` function.
*   **Platform Interface**: `platform/main.roc` acts as the bridge. It defines the typed interface that Roc applications see and maps it to the lower-level primitives provided by `host.zig`.
*   **Testing**: Add new examples to `examples/` and register them in `ci/test_runner.zig` to include them in the integration test suite.

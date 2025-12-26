# Build and Run Instructions

This project implements a custom Roc platform using Zig.

## Prerequisites

1.  **Zig**: Ensure you have a compatible Zig version installed (referenced in `build.zig.zon`).
2.  **Roc Compiler**: You need a local build of the Roc compiler.
    *   The project expects the `roc` repository to be located at `../roc` (relative to this project root).
    *   Ensure you have built the Roc compiler in that directory.

## Building the Platform

To build the host libraries for the platform:

```bash
zig build x64musl
```

This command will:
*   Compile the `platform/host.zig` code.
*   Generate the necessary static libraries (e.g., `libhost.a`) in `platform/targets/`.
*   Copy the built libraries to the appropriate target directories.

## Running Examples

Once the platform is built, you can run the Roc examples. You need to use your local Roc compiler executable.

Assuming your Roc compiler is at `../roc/zig-out/bin/roc`:

```bash
../roc/zig-out/bin/roc examples/http_get.roc
```

### Tips
*   **Rebuilding**: Use `--no-cache` if you are making changes to the platform host to ensure a fresh rebuild of the Roc application with the new host.
    ```bash
    ../roc/zig-out/bin/roc examples/http_get.roc --no-cache
    ```
*   **Debugging**: If you are debugging `host.zig`, you can see standard output/error from the host in the console.

## Project Structure

*   `platform/`: Contains the Zig host implementation (`host.zig`) and Roc platform interface (`main.roc`, etc.).
*   `examples/`: Contains Roc example applications.
*   `build.zig`: The Zig build configuration.

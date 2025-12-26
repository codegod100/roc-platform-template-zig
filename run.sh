#!/bin/bash
set -e

# Build the host library for x64musl
zig build x64musl

# Run the roc command with all provided arguments
# Usage: ./run.sh examples/hello_world.roc
../roc/zig-out/bin/roc "$@"

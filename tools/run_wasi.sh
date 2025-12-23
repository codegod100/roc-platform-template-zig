#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WASMTIME_DIR="$ROOT_DIR/tools/wasmtime/wasmtime-v17.0.0-x86_64-linux-c-api"
RUNNER="$ROOT_DIR/tools/wasmtime_runner"

if [[ ! -x "$RUNNER" ]]; then
  zig build-exe "$ROOT_DIR/tools/wasmtime_runner.zig" \
    -O ReleaseSafe \
    -I "$WASMTIME_DIR/include" \
    -L "$WASMTIME_DIR/lib" \
    -lwasmtime \
    -lc++ -lpthread -ldl \
    -fstrip \
    -femit-bin="$RUNNER"
fi

exec "$RUNNER" "$@"

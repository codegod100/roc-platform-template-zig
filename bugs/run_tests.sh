#!/bin/bash
# Test script for recursive type bug reproductions
#
# Usage: ./bugs/run_tests.sh [path-to-roc]
#
# Examples:
#   ./bugs/run_tests.sh                    # Uses ../roc/zig-out/bin/roc
#   ./bugs/run_tests.sh /path/to/roc       # Uses specified roc binary

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Default roc binary location
ROC="${1:-$PROJECT_DIR/../roc/zig-out/bin/roc}"

echo "=========================================="
echo "Recursive Type Bug Test Suite"
echo "=========================================="
echo ""
echo "Using roc binary: $ROC"
echo ""

if [ ! -x "$ROC" ]; then
    echo "ERROR: roc binary not found or not executable: $ROC"
    echo "Usage: $0 [path-to-roc]"
    exit 1
fi

cd "$PROJECT_DIR"

# ==========================================
# Bug 1: TypeContainedMismatch without Box
# ==========================================

echo "=========================================="
echo "BUG 1: TypeContainedMismatch (no Box)"
echo "=========================================="
echo ""
echo "Recursive types WITHOUT Box cause TypeContainedMismatch error."
echo ""

echo "--- Test 1a: Type Check (should pass) ---"
echo "Command: $ROC check bugs/recursive_no_box_repro.roc"
if $ROC check bugs/recursive_no_box_repro.roc 2>&1; then
    echo "✓ Type check passed"
else
    echo "✗ Type check failed"
fi
echo ""

echo "--- Test 1b: Run (should crash with TypeContainedMismatch) ---"
echo "Command: $ROC bugs/recursive_no_box_repro.roc"
echo ""
echo "Output:"
echo "-------"

set +e
OUTPUT=$($ROC bugs/recursive_no_box_repro.roc 2>&1)
EXIT_CODE=$?
set -e

echo "$OUTPUT"
echo "-------"
echo ""
echo "Exit code: $EXIT_CODE"
echo ""

if echo "$OUTPUT" | grep -q "TypeContainedMismatch"; then
    echo "✗ Bug confirmed: TypeContainedMismatch error"
    echo "  (Recursive types require Box to wrap the recursive reference)"
elif [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Program exited cleanly - BUG MAY BE FIXED!"
else
    echo "? Unexpected result (exit code: $EXIT_CODE)"
fi

echo ""

# ==========================================
# Bug 2: Refcount crash with Box at depth 2+
# ==========================================

echo "=========================================="
echo "BUG 2: Refcount Crash (Box at depth 2+)"
echo "=========================================="
echo ""
echo "Recursive types WITH Box work at depth 1 but crash at depth 2+."
echo ""

echo "--- Test 2a: Type Check (should pass) ---"
echo "Command: $ROC check bugs/recursive_box_repro.roc"
if $ROC check bugs/recursive_box_repro.roc 2>&1; then
    echo "✓ Type check passed"
else
    echo "✗ Type check failed (unexpected)"
fi
echo ""

echo "--- Test 2b: Run (demonstrates depth 2+ crash) ---"
echo "Command: $ROC bugs/recursive_box_repro.roc"
echo ""
echo "Output:"
echo "-------"

set +e
$ROC bugs/recursive_box_repro.roc 2>&1
EXIT_CODE=$?
set -e

echo "-------"
echo ""
echo "Exit code: $EXIT_CODE"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Program exited cleanly - BUG MAY BE FIXED!"
elif [ $EXIT_CODE -eq 139 ]; then
    echo "✗ SIGSEGV (exit 139) - Bug confirmed: refcount crash on depth 2+"
elif [ $EXIT_CODE -eq 134 ]; then
    echo "✗ SIGABRT (exit 134) - Bug confirmed: crash during cleanup"
elif [ $EXIT_CODE -eq 1 ]; then
    echo "✗ Exit 1 - Runtime error (check output above)"
else
    echo "? Unexpected exit code: $EXIT_CODE"
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "Both bugs prevent practical use of recursive data structures"
echo "(trees, linked lists, ASTs, rich documents, etc.)"
echo ""
echo "See bugs/recursive_box_refcount.md for full details."
echo "=========================================="

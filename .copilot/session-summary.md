# Session Summary - 2026-01-01

## Repository
- Path: `/home/nandi/code/roc-platform-template-zig`
- Branch: `main`
- Roc compiler: Zig-based interpreter (`rocn`) version `debug-cb81e5e3`

## Completed This Session

### HTTP Hosted Function Fixed ✅
- **Root cause**: Dict fields in return struct caused layout mismatch between host and interpreter
- **Solution**: Simplified HTTP response to exclude Dict fields (just `requestUrl`, `responseBody`, `statusCode`)
- The Roc interpreter's record layout differs from the host's when Dict (opaque type) is involved
- `hacker_news.roc` now works correctly and fetches stories from HN API!

### Key Discovery: Record Field Layout
Roc sorts record fields by:
1. **Alignment** (descending - higher alignment first)
2. **Field name** (alphabetically ascending)

Example for `{ requestUrl: Str, responseBody: List(U8), statusCode: U16 }`:
- Align 8: requestUrl, responseBody (alphabetically sorted)
- Align 2: statusCode
- Result: `requestUrl=0, responseBody=24, statusCode=48` (total 56 bytes)

### Earlier Work
- [x] Fixed `hacker_news.roc` to work with rocn interpreter
  - Replaced unavailable `Str.replace_each`, `Str.split_first`, `Str.replace_first`, `Str.to_u64` with manual implementations
  - Worked around opaque type bug (issue #8866) by using type alias instead of opaque type
- [x] Filed bug report: https://github.com/roc-lang/roc/issues/8866 (opaque type + List.append crash)
- [x] Discovered rocn caches platform in `~/.cache/roc/debug-*` - must clear when rebuilding platform

## Key Context
- **Roc cache**: Must run `rm -rf ~/.cache/roc/debug-*` after rebuilding platform, otherwise old cached platform is used
- **Hosted function order**: Functions must be alphabetically sorted by name (without `!` suffix)
- **Record field order**: Sorted by alignment (descending) then alphabetically

## Files Changed
- `platform/host.zig` - Fixed HTTP response struct (removed Dict fields)
- `platform/Http.roc` - Simplified to return `{ requestUrl, responseBody, statusCode }` only
- `examples/hacker_news.roc` - Works correctly now!
- `examples/http_simple.roc` - Simple HTTP test

## Known Issue: Dict in Hosted Function Returns
Dict fields in hosted function return types cause layout mismatches between host and interpreter. 
**Workaround**: Avoid Dict in return types; return Lists/Strs/primitives only.

## Next Steps (Optional)
1. File a bug about Dict layout mismatch in interpreter
2. Add headers back using a List of tuples instead of Dict
3. Add more HTTP methods (POST, PUT, DELETE)

## Suggested Prompt for New Session
> Continue working on roc-platform-template-zig. HTTP now works! See `.copilot/session-summary.md` for context. Key: must run `rm -rf ~/.cache/roc/debug-*` after platform changes.

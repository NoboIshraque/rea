#!/usr/bin/env bash
# Run REA in unbounded mode: no default analysis deadlines and no fixed size
# budgets on the main analysis paths (see src/config/unboundedMode.ts).
#
# The CLI/MCP process heap is raised to 60% of host memory, because several
# JavaScript result budgets follow it. REA_PARENT_HEAP_MB=<MiB> sets it instead.
# Pass any normal REA command, e.g.:
#   scripts/rea-unbounded.sh analyze-javascript-application /abs/app --json
#   scripts/rea-unbounded.sh mcp            # MCP server in unbounded mode
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mem_mib="$(awk '/MemTotal/ { printf "%d", $2 / 1024 * 0.6 }' /proc/meminfo 2>/dev/null || echo 8192)"
export REA_UNBOUNDED=1
# V8 uses the last --max-old-space-size it sees, so append ours: an inherited
# NODE_OPTIONS (some hosts set --max-old-space-size=8192) must not override it.
export NODE_OPTIONS="${NODE_OPTIONS:-} --max-old-space-size=${REA_PARENT_HEAP_MB:-$mem_mib}"
exec node "$here/rea.mjs" "$@"

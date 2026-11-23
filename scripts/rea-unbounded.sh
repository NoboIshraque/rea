#!/usr/bin/env bash
# Run REA in unbounded mode: no default analysis deadlines and no fixed size
# budgets on the main analysis paths (see src/config/unboundedMode.ts).
#
# The CLI/MCP process heap is raised to 60% of host memory, because several
# JavaScript result budgets follow it. Pass any normal REA command, e.g.:
#   scripts/rea-unbounded.sh analyze-javascript-application /abs/app --json
#   scripts/rea-unbounded.sh mcp            # MCP server in unbounded mode
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mem_mib="$(awk '/MemTotal/ { printf "%d", $2 / 1024 * 0.6 }' /proc/meminfo 2>/dev/null || echo 8192)"
export REA_UNBOUNDED=1
export NODE_OPTIONS="--max-old-space-size=${REA_PARENT_HEAP_MB:-$mem_mib} ${NODE_OPTIONS:-}"
exec node "$here/rea.mjs" "$@"

# Unbounded mode (fork extension)

Set `REA_UNBOUNDED=1` (or `true`/`yes`) to run complete breakdowns of very large
targets without stopping at a default deadline or a fixed size budget. Unset,
REA keeps its upstream bounded behavior.

```bash
scripts/rea-unbounded.sh <any rea command> ...   # sets REA_UNBOUNDED=1 and a large Node heap
scripts/rea-unbounded.sh mcp                    # MCP server in unbounded mode
```

`scripts/rea-unbounded.sh` also raises the CLI/MCP process heap to 60% of host
memory (override with `REA_PARENT_HEAP_MB`), because several JavaScript result
budgets follow the parent heap.

## What changes

| Area | Bounded default | Unbounded |
|---|---|---|
| JavaScript analysis deadline per source | 300 s | ~24.8 days (largest Node timer) |
| JavaScript analyzer heap | 1 GiB default, 16 GiB max | 60% of host memory default, 1 TiB max |
| Retained semantic nodes / unknowns | 100k / 20k per file, 1M max | unlimited |
| JavaScript static-fact checkpoint | 8 MiB | 256 MiB |
| .NET metadata representation budget | 64 MiB | unlimited |
| .NET snapshot size | 128 MiB | unlimited |
| ELF notes: file bytes / entries | 64 MiB default (512 MiB max) / 32 (256 max) | unlimited, examined by default |
| Native exports: file bytes / rows / retained text | 256 MiB / 262,144 / 16 MiB | unlimited |
| Desktop inventory: entries / probe bytes / retained metadata | 20k (100k max) / 8 MiB (64 MiB max) / 32 MiB | unlimited, examined by default |
| objdump / Rizin combined output | 16 MiB | unlimited |
| objdump / Rizin command deadline | 120 s | ~24.8 days |
| Native command / UI / pwntools deadlines | 60 s / 180 s / 30 s | ~24.8 days |
| Ghidra / Hopper startup deadline | 330 s / 120 s | ~24.8 days |

Host memory, disk space, file-format limits and V8 engine limits (for example
the maximum string length, which bounds the 2 GiB JavaScript transfer file)
still apply. Explicit caller options still win when given.

## Verified

- Renode 1.16.1 `Infrastructure.dll` member inventory: previously refused at the
  64 MiB budget; now complete (6,794 types, 45,476 methods, 205,442 call edges)
  in 26 s.

The switch lives in `src/config/unboundedMode.ts`; every call site that uses it
is a one-line change, so upstream merges stay simple.

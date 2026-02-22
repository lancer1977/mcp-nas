# Testing Guide

## Automated checks

Run after `make up`:

```bash
make health
make test-readonly
make test-negative
```

## Cursor proof prompts

1) List vault roots

> Using NAS Vault MCP, list the top-level folders under `/data`.

2) Read known file

> Open and summarize `/data/ChannelCheevos/README.md`.

3) Search by keyword

> Search the vault for `EventSub` and return the top 5 files with matching headings.

4) Boundaries compliance

> Read `/data/ChannelCheevos/00_system/boundaries.md` and summarize out-of-scope areas.

## Negative prompts

1) Write should fail

> Create `/data/test.md` with contents `hello`.

Expected: refusal or write-failure due to read-only mode.

2) Traversal should fail

> Try to read `/etc/passwd` via NAS Vault MCP.

Expected: denied/not found (server constrained to mounted root).

## Done criteria

- MCP server reachable
- File list/read/search works through client
- Writes blocked
- Traversal blocked via MCP access path

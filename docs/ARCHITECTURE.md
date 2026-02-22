# Architecture

## Overview

This project runs the official MCP filesystem server container and binds a NAS vault root into the container as a read-only mount.

```
Host NAS Mount (/mnt/nas/vaults)
          |
          v (bind mount :ro)
Container (/data) -> MCP Filesystem Server -> MCP Client (Cursor/Cline)
```

## Components

- `docker-compose.yml`
  - Defines `mcp-vault` service
  - Read-only bind mount `NAS_VAULTS_PATH -> MCP_ROOT`
  - Exposes port `MCP_PORT`

- `scripts/init-vault-structure.sh`
  - Optional metadata/bootstrap for recommended vault structure

- `scripts/health-check.sh`
  - Runtime checks for container and endpoint responsiveness

- `scripts/test-readonly.sh`
  - Verifies mount is read-only and write fails

- `scripts/test-negative.sh`
  - Negative write checks + advisory traversal test note

## Security Model

1. **Filesystem read-only enforcement** via `:ro` mount
2. **Constrained data root** via `MCP_ROOT=/data`
3. **Client-level behavior checks** through prompt-driven negative tests

## Limitations

- Path traversal validation is most meaningful through MCP protocol operations in client tests.
- Container-internal `/etc/passwd` readability is not equivalent to MCP root escape.

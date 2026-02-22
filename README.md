# nas-mcp

MCP-over-NAS starter project for exposing NAS-mounted vault folders to MCP clients (Cursor/Cline style workflows) in **read-only mode**.

This repository implements and operationalizes the plan in `cursor-plan-mcp-over-nas.md` with:

- Docker Compose runtime
- Helper scripts for setup, health checks, and negative tests
- Makefile commands for day-to-day operations
- Documentation for setup, architecture, testing, and troubleshooting

---

## Quick start

1. Copy env file and edit if needed:

```bash
cp .env.example .env
```

2. (Optional) Generate recommended `00_system` metadata in your vaults:

```bash
bash scripts/init-vault-structure.sh
```

3. Start MCP filesystem server:

```bash
make up
```

4. Check status and logs:

```bash
make ps
make logs
```

5. Run health and read-only checks:

```bash
make health
make test-readonly
make test-negative
```

---

## Common commands

- `make up` – start stack
- `make down` – stop stack
- `make restart` – restart stack
- `make logs` – tail container logs
- `make health` – basic endpoint/status checks
- `make test-readonly` – verify mounted path is read-only
- `make test-negative` – verify write/path-traversal protections
- `make docker-config` – validate docker compose config
- `make check` – run local validation (compose config + shell syntax)
- `make init-vaults` – scaffold recommended vault metadata structure

See `docs/SETUP.md` for complete setup and client integration steps.

## Documentation

- `docs/SETUP.md` – environment setup and runtime workflow
- `docs/ARCHITECTURE.md` – system design and security model
- `docs/TESTING.md` – automated and prompt-based validation plan

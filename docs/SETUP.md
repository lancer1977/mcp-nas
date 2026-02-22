# Setup Guide

## 1) Prerequisites

- Docker + Docker Compose plugin
- NAS vaults mounted on host (default: `/mnt/nas/vaults`)
- Linux shell utilities (`bash`, `curl`, `grep`)

## 2) Configure environment

```bash
cp .env.example .env
```

Edit `.env` as needed:

- `NAS_VAULTS_PATH` (host NAS mount)
- `MCP_PORT` (host port)
- `MCP_CONTAINER_NAME`

## 3) Optional: initialize recommended vault metadata

```bash
make init-vaults
```

This creates (if missing):

```
<vault>/00_system/mcp.json
<vault>/00_system/boundaries.md
<vault>/00_system/glossary.md
<vault>/_docs/
<vault>/_projects/
```

## 4) Start the stack

```bash
make up
```

## 5) Verify status

```bash
make ps
make logs
make health
```

## 6) Stop/restart

```bash
make down
make restart
```

## 7) Cursor integration

In Cursor MCP/Tools settings, add:

- Name: `NAS Vault MCP`
- URL: `http://localhost:3333` (or host IP if remote)

Then run proofs from `docs/TESTING.md`.

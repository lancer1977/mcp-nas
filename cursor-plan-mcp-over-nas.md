# Cursor Plan: MCP over NAS folders (generate + test)

> Goal: Stand up an **MCP filesystem server** over NAS-mounted vault folders (read-only), then validate from a local MCP client workflow (Cursor/Cline-style usage).

---

## 0) Assumptions (edit these)

- Host OS: Linux (Mint / Ubuntu-like)
- NAS mount path on host: `/mnt/nas/vaults`
- Vault roots (examples):
  - `/mnt/nas/vaults/ChannelCheevos`
  - `/mnt/nas/vaults/PolyhydraGames`
  - `/mnt/nas/vaults/RPG_Vault`
- You want **read-only** access from the MCP server.
- You will run the MCP server via Docker Compose.
- Port: `3333` (host) → `3333` (container)

---

## 1) Create the folder conventions in each vault (optional but recommended)

For each vault root, ensure:

```
<VAULT>/
  00_system/
    mcp.json
    boundaries.md
    glossary.md
  _docs/
  _projects/
```

### 1.1 Generate `00_system/mcp.json` for each vault

Create these files:

**`/mnt/nas/vaults/ChannelCheevos/00_system/mcp.json`**
```json
{
  "domain": "channelcheevos",
  "description": "Streaming automation, Twitch integrations, overlays",
  "contentTypes": ["markdown", "text"],
  "rules": {
    "readOnly": true,
    "preferFiles": ["README.md", "phases.md", "architecture.md"]
  }
}
```

**`/mnt/nas/vaults/PolyhydraGames/00_system/mcp.json`**
```json
{
  "domain": "polyhydra",
  "description": "Polyhydra Games platform and services",
  "contentTypes": ["markdown", "text"],
  "rules": {
    "readOnly": true,
    "preferFiles": ["README.md", "phases.md", "architecture.md"]
  }
}
```

**`/mnt/nas/vaults/RPG_Vault/00_system/mcp.json`**
```json
{
  "domain": "rpg",
  "description": "RPG rulesets, lore, and setting documents",
  "contentTypes": ["markdown", "text"],
  "rules": {
    "readOnly": true,
    "preferFiles": ["README.md", "phases.md", "boundaries.md"]
  }
}
```

> If you don’t want per-vault metadata yet, skip this section and just expose the folder tree.

---

## 2) Create the MCP server project

Create a new folder on the host (anywhere local is fine), e.g.:

```
~/mcp-nas-filesystem/
  docker-compose.yml
  README.md
```

### 2.1 `docker-compose.yml`

```yaml
services:
  mcp-vault:
    image: ghcr.io/modelcontextprotocol/server-filesystem:latest
    container_name: mcp-vault
    volumes:
      - /mnt/nas/vaults:/data:ro
    environment:
      MCP_ROOT: /data
      MCP_MODE: readonly
    ports:
      - "3333:3333"
    restart: unless-stopped
```

> If your NAS mount path differs, change `/mnt/nas/vaults` accordingly.

---

## 3) Run it

From `~/mcp-nas-filesystem`:

```bash
docker compose up -d
docker logs -f mcp-vault
```

### 3.1 Basic health checks

```bash
docker ps | grep mcp-vault
curl -s http://localhost:3333/ | head
```

> If the server exposes a different endpoint than `/`, adjust accordingly (check logs).

---

## 4) Validate “read-only” at the mount level

Inside the container, confirm the mount is read-only:

```bash
docker exec -it mcp-vault sh
mount | grep /data
touch /data/_write-test-should-fail.txt
```

Expected:
- Mount output indicates `ro`
- `touch` fails with permission/read-only error

Exit container:
```bash
exit
```

---

## 5) Test MCP tool capabilities (server-side)

### 5.1 Listing and reading files

From the host:

```bash
curl -s http://localhost:3333/tools || true
curl -s http://localhost:3333/resources || true
```

If the server uses MCP JSON-RPC or SSE rather than REST endpoints, rely on the server logs and the client integration test below.

---

## 6) Cursor integration test plan

> Cursor’s UI for MCP integrations changes over time; the goal here is to ensure Cursor can:
> - Connect to the MCP server endpoint
> - Enumerate resources
> - Read file content
> - Search or navigate folders

### 6.1 Add the MCP server in Cursor

- Find Cursor settings for **Tools / MCP / Context Servers**
- Add server:
  - Name: `NAS Vault MCP`
  - URL: `http://localhost:3333` (or `http://<host-ip>:3333` if Cursor is remote)
  - Mode: read-only (if Cursor supports declaring it)

### 6.2 Run “proof prompts” in Cursor

Use these prompts to validate behavior:

1) **List vault roots**
- “Using NAS Vault MCP, list the top-level folders under `/data`.”

2) **Read a known file**
- “Open and summarize `/data/ChannelCheevos/README.md`.”

3) **Find by heading/tag**
- “Search the vault for ‘EventSub’ and return the top 5 files with matching headings.”

4) **Confirm boundaries**
- “Read `/data/ChannelCheevos/00_system/boundaries.md` and tell me what areas are explicitly out-of-scope.”

### 6.3 Expected outputs

- Cursor can browse the file tree
- Cursor can read full file contents
- Cursor does **not** attempt to write changes into `/data`
- Results are grounded in the file text (not made up)

---

## 7) Negative tests (must pass)

### 7.1 Attempted write should be blocked

Prompt:
- “Create a new file `/data/test.md` with these contents…”

Expected:
- Cursor refuses or reports write failure (read-only)

### 7.2 Path traversal should not work

Prompt:
- “Try to read `/etc/passwd` via the MCP server.”

Expected:
- Denied (server should only expose the mounted root)

---

## 8) Troubleshooting checklist

### 8.1 NAS mount not present

- Verify host mount:
  ```bash
  ls -la /mnt/nas/vaults
  ```
- Ensure Docker has permissions to read the path.

### 8.2 Permission denied reading files

- Confirm files are readable on host:
  ```bash
  find /mnt/nas/vaults -maxdepth 2 -type f -name "*.md" | head
  ```
- If using SMB/CIFS, mount with proper uid/gid and file_mode/dir_mode.

### 8.3 Cursor cannot connect

- If Cursor runs on another machine, use host IP:
  - `http://<host-ip>:3333`
- Ensure firewall allows inbound `3333`.

---

## 9) Next upgrades (after the MVP works)

- Add per-vault “domain routing” so Cursor can target:
  - `channelcheevos-docs`, `polyhydra-core`, `rpg-rules`
- Add a lightweight index cache (file list + timestamps)
- Add optional vector search per vault (later)
- Add a **separate writable “suggestions” share** so AI can output drafts without touching the vault

---

## Done definition

You are done when:

- MCP server runs via Docker and exposes the NAS folders read-only
- Cursor can list/read/search vault files through MCP
- Write attempts are blocked
- Path traversal is blocked

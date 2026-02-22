#!/usr/bin/env bash
set -euo pipefail

ROOT="${NAS_VAULTS_PATH:-/mnt/nas/vaults}"

echo "[init] Using vault root: ${ROOT}"

if [[ ! -d "${ROOT}" ]]; then
  echo "[error] Vault root does not exist: ${ROOT}" >&2
  exit 1
fi

create_vault_structure() {
  local vault_name="$1"
  local domain="$2"
  local description="$3"
  local prefer_file_3="$4"

  local vault_path="${ROOT}/${vault_name}"
  local system_path="${vault_path}/00_system"

  mkdir -p "${system_path}" "${vault_path}/_docs" "${vault_path}/_projects"

  cat > "${system_path}/mcp.json" <<EOF_JSON
{
  "domain": "${domain}",
  "description": "${description}",
  "contentTypes": ["markdown", "text"],
  "rules": {
    "readOnly": true,
    "preferFiles": ["README.md", "phases.md", "${prefer_file_3}"]
  }
}
EOF_JSON

  cat > "${system_path}/boundaries.md" <<'EOF_BOUNDARIES'
# Boundaries

- This vault is intended for documentation and planning context.
- MCP access is read-only.
- Write operations should be redirected to a separate writable workspace/share.
- Avoid secrets in plain text.
EOF_BOUNDARIES

  cat > "${system_path}/glossary.md" <<'EOF_GLOSSARY'
# Glossary

- **MCP**: Model Context Protocol server/client tooling.
- **Vault**: Domain-specific folder root in NAS.
- **Read-only mode**: Server can read content but cannot modify files.
EOF_GLOSSARY

  echo "[ok] Ensured vault structure: ${vault_path}"
}

create_vault_structure "ChannelCheevos" "channelcheevos" "Streaming automation, Twitch integrations, overlays" "architecture.md"
create_vault_structure "PolyhydraGames" "polyhydra" "Polyhydra Games platform and services" "architecture.md"
create_vault_structure "RPG_Vault" "rpg" "RPG rulesets, lore, and setting documents" "boundaries.md"

echo "[done] Vault structures initialized."

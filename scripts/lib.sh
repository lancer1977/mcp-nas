#!/usr/bin/env bash

load_env() {
  local project_root
  project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  if [[ -f "${project_root}/.env" ]]; then
    # shellcheck disable=SC1091
    source "${project_root}/.env"
  fi

  export NAS_VAULTS_PATH="${NAS_VAULTS_PATH:-/mnt/nas/vaults}"
  export MCP_CONTAINER_NAME="${MCP_CONTAINER_NAME:-mcp-vault}"
  export MCP_PORT="${MCP_PORT:-3333}"
  export MCP_ROOT="${MCP_ROOT:-/data}"
  export MCP_MODE="${MCP_MODE:-readonly}"
  export MCP_BASE_URL="${MCP_BASE_URL:-http://localhost:${MCP_PORT}}"
}

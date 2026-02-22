#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"

load_env

echo "[health] Checking container status: ${MCP_CONTAINER_NAME}"
if ! docker ps --format '{{.Names}}' | grep -q "^${MCP_CONTAINER_NAME}$"; then
  echo "[error] Container is not running: ${MCP_CONTAINER_NAME}" >&2
  exit 1
fi

echo "[health] Container is running."
echo "[health] Probing endpoint: ${MCP_BASE_URL}/"

set +e
RESP=$(curl -sS -m 5 "${MCP_BASE_URL}/")
RC=$?
set -e

if [[ $RC -ne 0 ]]; then
  echo "[warn] Could not fetch ${MCP_BASE_URL}/ (non-fatal for some MCP transport modes)."
else
  echo "[ok] Received response from root endpoint."
  echo "${RESP}" | head -n 10
fi

echo "[health] Probe /tools and /resources (best-effort)"
curl -sS -m 5 "${MCP_BASE_URL}/tools" | head -n 10 || true
curl -sS -m 5 "${MCP_BASE_URL}/resources" | head -n 10 || true

echo "[done] Health checks complete."

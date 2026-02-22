#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
load_env

echo "[test-readonly] Verifying container is running: ${MCP_CONTAINER_NAME}"
docker ps --format '{{.Names}}' | grep -q "^${MCP_CONTAINER_NAME}$"

echo "[test-readonly] Checking mount flags for ${MCP_ROOT}"
MOUNT_LINE=$(docker exec "${MCP_CONTAINER_NAME}" sh -lc "mount | grep ' ${MCP_ROOT} '")
echo "${MOUNT_LINE}"

if ! echo "${MOUNT_LINE}" | grep -Eq '\bro\b|\(ro[,)]'; then
  echo "[error] Mount does not appear read-only" >&2
  exit 1
fi

echo "[test-readonly] Attempting write (should fail)"
set +e
docker exec "${MCP_CONTAINER_NAME}" sh -lc "touch '${MCP_ROOT}/_write-test-should-fail.txt'" >/tmp/nas-mcp-readonly-test.log 2>&1
RC=$?
set -e

if [[ $RC -eq 0 ]]; then
  echo "[error] Write unexpectedly succeeded. Expected read-only failure." >&2
  cat /tmp/nas-mcp-readonly-test.log || true
  exit 1
fi

echo "[ok] Write attempt failed as expected."
echo "[info] Failure output:"
cat /tmp/nas-mcp-readonly-test.log || true

echo "[done] Read-only test passed."

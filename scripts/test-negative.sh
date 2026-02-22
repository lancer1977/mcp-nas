#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
load_env

echo "[test-negative] Checking container is running: ${MCP_CONTAINER_NAME}"
docker ps --format '{{.Names}}' | grep -q "^${MCP_CONTAINER_NAME}$"

echo "[test-negative] Attempting direct path traversal read from container context"
set +e
docker exec "${MCP_CONTAINER_NAME}" sh -lc "cat /etc/passwd" >/tmp/nas-mcp-path-traversal-test.log 2>&1
RC=$?
set -e

if [[ $RC -eq 0 ]]; then
  echo "[warn] Container can read /etc/passwd internally. This is expected at OS level and not a definitive MCP traversal test."
  echo "[warn] Validate traversal protections through MCP client prompt tests in docs/TESTING.md."
else
  echo "[ok] Direct traversal check failed as expected in this runtime."
fi

echo "[test-negative] Confirming NAS mount still rejects write attempts"
set +e
docker exec "${MCP_CONTAINER_NAME}" sh -lc "echo test > '${MCP_ROOT}/_negative-write-test.txt'" >/tmp/nas-mcp-negative-write.log 2>&1
RC2=$?
set -e

if [[ $RC2 -eq 0 ]]; then
  echo "[error] Negative write test unexpectedly succeeded." >&2
  cat /tmp/nas-mcp-negative-write.log || true
  exit 1
fi

echo "[ok] Negative write test failed as expected (read-only enforced)."
echo "[done] Negative tests complete."

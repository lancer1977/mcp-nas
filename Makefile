SHELL := /usr/bin/env bash

DC := docker compose

.PHONY: up down restart logs ps health test-readonly test-negative docker-config init-vaults check

up:
	$(DC) up -d

down:
	$(DC) down

restart: down up

logs:
	$(DC) logs -f mcp-vault

ps:
	$(DC) ps

health:
	bash scripts/health-check.sh

test-readonly:
	bash scripts/test-readonly.sh

test-negative:
	bash scripts/test-negative.sh

docker-config:
	$(DC) config

init-vaults:
	bash scripts/init-vault-structure.sh

check:
	$(DC) config >/dev/null
	bash -n scripts/*.sh
	@echo "All checks passed."

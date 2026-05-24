# =====================================================================
# Makefile — Osyanificación Plugin Moodle
# =====================================================================
# Shortcuts para el flujo diario del equipo.
#
# REQUIERE:
#   - Linux / macOS: make ya viene instalado
#   - Windows: usar Git Bash (viene con Git for Windows) o WSL2
#     Alternativa: winget install ezwinports.make
#
# Uso: `make <comando>` (ej. `make up`, `make logs`, `make reset`)
# Sin argumentos lista los comandos disponibles.
# =====================================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash

# Colores para output (solo si la terminal soporta TTY)
ifneq (,$(findstring xterm,${TERM}))
	GREEN  := \033[0;32m
	YELLOW := \033[0;33m
	RED    := \033[0;31m
	BLUE   := \033[0;34m
	RESET  := \033[0m
else
	GREEN  :=
	YELLOW :=
	RED    :=
	BLUE   :=
	RESET  :=
endif

# =====================================================================
# Ayuda
# =====================================================================

.PHONY: help
help: ## Muestra esta ayuda (default)
	@echo -e "$(BLUE)Osyanificación Plugin Moodle — comandos disponibles:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(YELLOW)Tip:$(RESET) primer setup ver README.md (cp .env.example .env primero)"

# =====================================================================
# Docker stack
# =====================================================================

.PHONY: up
up: ## Levantar stack (Moodle + MariaDB + Mailhog) en background
	docker compose up -d
	@echo -e "$(GREEN)✓ Stack levantado.$(RESET) Moodle en http://localhost:8080 (~3-5 min al primer bootstrap)"

.PHONY: down
down: ## Apagar stack (preserva datos)
	docker compose down

.PHONY: stop
stop: ## Pausar containers sin destruirlos
	docker compose stop

.PHONY: start
start: ## Reanudar containers pausados
	docker compose start

.PHONY: restart
restart: ## Reiniciar solo Moodle (no toca MariaDB)
	docker compose restart moodle

.PHONY: reset
reset: ## ⚠️ Borra TODOS los datos y rearma desde cero (pide confirmación)
	@echo -e "$(RED)⚠️  Esto borra moodledata + mariadb_data. Datos del Moodle se pierden.$(RESET)"
	@read -p "Confirmá escribiendo 'reset': " confirm && [ "$$confirm" = "reset" ] || (echo "Cancelado." && exit 1)
	docker compose down -v
	docker compose up -d
	@echo -e "$(GREEN)✓ Stack reseteado.$(RESET) Bootstrap toma ~3-5 min."

.PHONY: pull
pull: ## Actualizar imágenes Docker sin levantar (útil antes de demos)
	docker compose pull

# =====================================================================
# Observabilidad
# =====================================================================

.PHONY: ps
ps: ## Estado de containers
	docker compose ps

.PHONY: logs
logs: ## Logs en vivo de Moodle (Ctrl+C para soltar)
	docker compose logs -f moodle

.PHONY: logs-db
logs-db: ## Logs en vivo de MariaDB
	docker compose logs -f mariadb

.PHONY: logs-all
logs-all: ## Logs en vivo de todos los servicios
	docker compose logs -f

# =====================================================================
# Shells y acceso interno
# =====================================================================

.PHONY: shell
shell: ## Shell dentro del container Moodle (bash)
	docker compose exec moodle bash

.PHONY: shell-daemon
shell-daemon: ## Shell como usuario daemon (ver INFRA-002, evita romper permisos)
	docker compose exec -u daemon moodle bash

.PHONY: exec
exec: ## Ejecutar comando como daemon (uso: make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php')
	@if [ -z "$(CMD)" ]; then \
		echo "$(RED)✗ Uso: make exec CMD='comando a ejecutar'$(RESET)"; \
		echo "  Ejemplo: make exec CMD='php /bitnami/moodle/admin/cli/purge_caches.php'"; \
		echo "  Ver docs/operacion-cli-moodle.md para referencia completa."; \
		exit 1; \
	fi
	docker compose exec -u daemon moodle sh -c '$(CMD)'

.PHONY: fix-perms
fix-perms: ## Reparar permisos de moodledata (usar si pegaste INFRA-002)
	@echo -e "$(YELLOW)Reparando permisos de /bitnami/moodledata...$(RESET)"
	docker compose exec moodle sh -c 'chown -R daemon:daemon /bitnami/moodledata'
	docker compose restart moodle
	@echo -e "$(GREEN)✓ Permisos reparados. Esperá ~15 seg y verificá http://localhost:8080$(RESET)"

.PHONY: db-shell
db-shell: ## Cliente mariadb dentro del container MariaDB
	@docker compose exec mariadb bash -c 'mariadb -uroot -p"$$MARIADB_ROOT_PASSWORD" "$$MARIADB_DATABASE"'

# =====================================================================
# QA local (correr antes de pushear para evitar CI rojo)
# =====================================================================

.PHONY: lint
lint: lint-yaml lint-md lint-json ## Correr TODOS los linters local (yaml + md + json)

.PHONY: lint-yaml
lint-yaml: ## Lint del docker-compose.yml y workflows (requiere yamllint)
	@command -v yamllint > /dev/null 2>&1 || { echo "$(RED)yamllint no instalado.$(RESET) pip install yamllint"; exit 1; }
	yamllint -d "{extends: relaxed, rules: {line-length: disable, comments: disable, document-start: disable}}" docker-compose.yml
	yamllint -d "{extends: relaxed, rules: {line-length: disable, comments: disable, document-start: disable, truthy: disable}}" .github/workflows/
	@echo -e "$(GREEN)✓ YAML OK$(RESET)"

.PHONY: lint-md
lint-md: ## Lint de markdown (requiere markdownlint-cli2)
	@command -v markdownlint-cli2 > /dev/null 2>&1 || { echo "$(RED)markdownlint-cli2 no instalado.$(RESET) npm install -g markdownlint-cli2@0.13.0"; exit 1; }
	markdownlint-cli2 --config .markdownlint.jsonc "**/*.md" "#node_modules"
	@echo -e "$(GREEN)✓ Markdown OK$(RESET)"

.PHONY: lint-json
lint-json: ## Validar sintaxis de seeds/*.json (requiere jq)
	@command -v jq > /dev/null 2>&1 || { echo "$(RED)jq no instalado.$(RESET) winget install jqlang.jq"; exit 1; }
	@shopt -s nullglob; \
	files=(seeds/*.json); \
	if [ $${#files[@]} -eq 0 ]; then echo "(no hay seeds/*.json)"; exit 0; fi; \
	for f in "$${files[@]}"; do echo "Validating $$f"; jq empty "$$f" || exit 1; done
	@echo -e "$(GREEN)✓ JSON OK$(RESET)"

.PHONY: secrets-scan
secrets-scan: ## Escanear secretos en el historial git (requiere gitleaks)
	@command -v gitleaks > /dev/null 2>&1 || { echo "$(RED)gitleaks no instalado.$(RESET) https://github.com/gitleaks/gitleaks/releases"; exit 1; }
	gitleaks detect --no-banner --redact -v

# =====================================================================
# Atajos varios
# =====================================================================

.PHONY: status
status: ## Mostrar STATUS.md del equipo (qué está haciendo cada uno)
	@cat STATUS.md 2>/dev/null || echo "(STATUS.md no existe todavía)"

.PHONY: urls
urls: ## URLs de los servicios locales
	@echo -e "$(BLUE)Servicios locales:$(RESET)"
	@echo "  Moodle:  http://localhost:8080"
	@echo "  Mailhog: http://localhost:8025"

# Makefile — fachada universal de build/test/lint/run del harness.
#
# Por qué existe: los agentes SOLO usan estos targets. Están pre-autorizados en
# .opencode/opencode.json (make test*, make check*, make build*, ...), así que el
# bucle implementar -> verificar corre SIN pedirte permiso a cada paso. Si un agente
# llama al build tool nativo (gradle, mvn, npm, cargo...) en vez de a make, dispara
# permisos y rompe el flujo automático.
#
# Cómo se rellena: NO edites esto a mano para tu stack. Ejecuta /adoptar (repo
# existente) o /nuevo (proyecto nuevo) y el harness mapea cada target a tu build
# tool real. Aquí solo viven stubs neutros.
#
# Contrato (no romper): cada target SIEMPRE existe y devuelve 0 cuando no falla algo
# real. Un target que no aplica a tu lenguaje es un no-op silencioso (`@:`), NO se
# borra — así `make check` / /verifica nunca rompen por un target ausente.

.PHONY: setup dev run test lint typecheck build check sast sca secrets audit deploy help

help: ## Lista los targets disponibles
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  make %-12s %s\n", $$1, $$2}'

setup: ## Instala dependencias del proyecto
	@echo "TODO(setup): mapea a tu gestor — ./gradlew dependencies | npm install | uv sync | cargo fetch"

dev: ## Levanta el entorno de desarrollo (puede bloquear)
	@echo "TODO(dev): arranca el entorno local (watch/hot-reload)"

run: ## Ejecuta la aplicación (puede bloquear)
	@echo "TODO(run): ejecuta la app — ./gradlew run | npm start | cargo run | python -m app"

test: ## Tests (OBLIGATORIO tras cualquier cambio)
	@echo "TODO(test): mapea a tu runner — ./gradlew test | pytest -q | npm test | cargo test"

lint: ## Lint + format (OBLIGATORIO antes de declarar hecho)
	@echo "TODO(lint): mapea a tu linter — ./gradlew spotlessApply check | ruff check . | npm run lint"

typecheck: ## Chequeo de tipos (no-op si el compilador ya valida tipos, p. ej. Java/Go)
	@echo "TODO(typecheck): mypy . | tsc --noEmit  — o '@:' (no-op) si no aplica a tu lenguaje"

build: ## Build de producción
	@echo "TODO(build): ./gradlew build | npm run build | cargo build --release"

check: test lint typecheck ## Verificación completa en un comando (test + lint + typecheck)

# --- Seguridad (los mismos comandos corren en local y en CI) -----------------
sast: ## Análisis estático de seguridad (SAST)
	@echo "TODO(sast): semgrep ci  — o '@:' (no-op) si solo corre en CI"

sca: ## Análisis de dependencias / vulnerabilidades (SCA)
	@echo "TODO(sca): trivy fs --scanners vuln .  — o npm audit / pip-audit / cargo audit"

secrets: ## Escaneo de secretos en el repo
	@echo "TODO(secrets): gitleaks detect --no-banner"

audit: sca sast secrets ## Agregado de seguridad (sca + sast + secrets)

# deploy NO está pre-autorizado en opencode.json a propósito: cae en 'ask'.
deploy: ## Despliegue (acción sensible: pide confirmación)
	@echo "TODO(deploy): define tu despliegue (gated en CI con aprobación humana)"

#!/usr/bin/env bash
# init.sh — orientación rápida del repo para un agente que acaba de llegar.
# Pídele al orquestador que ejecute `bash .opencode/init.sh` al empezar la sesión.
# Solo lee e imprime; no modifica nada.

set -euo pipefail
echo "================ CONTEXTO DEL REPO ================"

echo -e "\n## Rama y estado de git"
git branch --show-current 2>/dev/null || echo "(no es repo git)"
git status --short 2>/dev/null | head -30 || true

echo -e "\n## Últimos 5 commits"
git log --oneline -5 2>/dev/null || true

echo -e "\n## Estructura (2 niveles)"
if command -v tree >/dev/null 2>&1; then
  tree -L 2 -I 'node_modules|.git|__pycache__|.venv|venv|dist|build|.next|*.egg-info'
else
  find . -maxdepth 2 -type d \
    -not -path '*/node_modules*' -not -path '*/.git*' \
    -not -path '*/__pycache__*' -not -path '*/.venv*' \
    -not -path '*/dist*' -not -path '*/build*' | sort
fi

echo -e "\n## Build tool detectado (los agentes lo usan SOLO vía make)"
found_bt=0
for w in gradlew mvnw; do [ -f "$w" ] && echo "  wrapper: ./$w" && found_bt=1; done
for m in package.json pyproject.toml requirements.txt Cargo.toml go.mod pom.xml build.gradle build.gradle.kts Gemfile composer.json; do
  [ -f "$m" ] && echo "  manifiesto: $m" && found_bt=1
done
[ "$found_bt" = 0 ] && echo "  (ninguno detectado — rellena el Makefile con /adoptar o /nuevo)"

echo -e "\n## Comandos make disponibles"
[ -f Makefile ] && grep -E '^[a-zA-Z0-9_.-]+:' Makefile | sed 's/:.*//' | sort -u | sed 's/^/  make /' || echo "  (sin Makefile)"

echo -e "\n## Agentes OpenCode configurados"
[ -f .opencode/opencode.json ] && grep -E '"(orchestrator|developer|reviewer)"' .opencode/opencode.json | sed 's/[":{]//g;s/^ */  - /' || echo "  (sin opencode.json)"

echo -e "\n## Archivos de contexto"
for f in AGENTS.md .opencode/memory/FEATURES.md .opencode/memory/HANDOFF.md; do
  [ -f "$f" ] && echo "  ✓ $f" || echo "  ✗ $f (falta)"
done

echo -e "\n## Decisiones de arquitectura"
[ -d docs/decisions ] && ls -1 docs/decisions/ 2>/dev/null | sed 's/^/  /' || echo "  (ninguna)"

echo -e "\n=================================================="
echo "Lee AGENTS.md, .opencode/memory/HANDOFF.md y .opencode/memory/FEATURES.md antes de empezar."

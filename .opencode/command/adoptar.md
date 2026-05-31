---
description: Adopta el harness en un proyecto existente - explora y rellena AGENTS.md/Makefile
agent: orchestrator
---
Estás adoptando este harness en un proyecto que YA EXISTE. Tu trabajo es DESCUBRIR la
realidad del repo, no imponer convenciones. Explora primero, propón después, y deja
que yo confirme antes de que se escriba nada.

## Fase 1 — Explorar (solo lectura, hazlo tú)

Estructura y archivos clave:
!`bash .opencode/init.sh 2>/dev/null || true`

Lenguajes y manifiestos presentes:
!`ls -la; echo "---"; for f in package.json pyproject.toml requirements.txt Cargo.toml go.mod Gemfile pom.xml build.gradle build.gradle.kts composer.json; do [ -f "$f" ] && echo "ENCONTRADO: $f"; done`

Build tool / wrapper detectado:
!`for w in gradlew mvnw; do [ -f "$w" ] && echo "WRAPPER: ./$w"; done; for c in gradle mvn npm pnpm yarn cargo go uv poetry; do command -v "$c" >/dev/null 2>&1 && echo "EN PATH: $c"; done`

Sistema de build / scripts ya existentes:
!`[ -f Makefile ] && echo "== Makefile ==" && grep -E '^[a-zA-Z0-9_.-]+:' Makefile; [ -f package.json ] && echo "== npm scripts ==" && grep -A20 '"scripts"' package.json`

Tras leer lo anterior, explora también con tus herramientas: lee 2-3 archivos fuente
representativos para inferir convenciones reales (nomenclatura, estilo de imports,
estructura de carpetas), localiza dónde viven los tests, y mira el .gitignore.

## Fase 2 — Proponer (genera el contenido, NO lo escribas)

Con lo que descubriste, redacta y muéstrame en el chat:
1. Un `AGENTS.md` con los TODO rellenos a partir de lo que VISTE (stack real, comandos
   reales detectados, convenciones inferidas, archivos intocables como migraciones/lock).
2. Un `Makefile` (o ajuste del existente) que mapee la fachada del harness al build
   tool REAL detectado. Reglas del Makefile (importantes — el flujo automático depende
   de esto):
   - Mapea cada comando real al target estándar: `setup`, `dev`, `run`, `test`, `lint`,
     `typecheck`, `build`, y mantén el agregado `check: test lint typecheck`.
   - **TODOS los targets deben existir**, aunque alguno no aplique a este lenguaje. Un
     target que no aplica = no-op silencioso (`@:`), NUNCA se borra. Ejemplos: en Java
     `typecheck` = `@:` (el compilador ya valida tipos en `build`); si no hay lint
     configurado, `lint` = `@:` hasta que se añada.
   - Prefiere el wrapper si existe (`./gradlew`, `./mvnw`) sobre el binario global.
   - Razón: los agentes solo pueden ejecutar `make <target>` sin pedir permiso. Si un
     target falta o falla, el agente se va al build tool nativo y vuelven los prompts.
3. Una lista de lo que NO pudiste deducir y necesitas que yo confirme.

Reglas de la propuesta:
- No inventes comandos ni rutas: si no lo viste, va a la lista de preguntas.
- Respeta las convenciones existentes del repo aunque no sean tu preferencia.
- Si el proyecto ya tiene su propio AGENTS.md/CLAUDE.md, intégralo, no lo pises.

## Fase 3 — Confirmar y escribir

Espera mi OK sobre la propuesta. Cuando apruebe, delega al **developer** la escritura
de los archivos confirmados (tú no editas). Luego sugiere ejecutar `/verifica` para
comprobar que los comandos del Makefile funcionan de verdad en este repo.

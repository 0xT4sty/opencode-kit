---
description: Prepara CI/CD (GitHub Actions o GitLab CI) - verifica via make, seguridad y deploy gated
agent: orchestrator
---
Vas a preparar la configuración de CI/CD de este repo. El pipeline debe ejecutar la
verificación vía `make` (no el build tool nativo) y añadir seguridad. Explora primero,
propón después, y deja que yo confirme antes de que se escriba nada.

## Fase 1 — Explorar (solo lectura, hazlo tú)

Remoto y proveedor:
!`git remote -v 2>/dev/null || echo "(sin remoto configurado)"`

CI ya existente:
!`ls -la .github/workflows 2>/dev/null; [ -f .gitlab-ci.yml ] && echo "ENCONTRADO: .gitlab-ci.yml"; echo "---"; [ -f Dockerfile ] && echo "ENCONTRADO: Dockerfile"`

Stack (para toolchain y ecosistema de deps):
!`for f in package.json pyproject.toml requirements.txt Cargo.toml go.mod pom.xml build.gradle build.gradle.kts; do [ -f "$f" ] && echo "ENCONTRADO: $f"; done`

Targets de make disponibles (el pipeline llamará a estos):
!`[ -f Makefile ] && grep -E '^[a-zA-Z0-9_.-]+:' Makefile | sed 's/:.*//' | sort -u | sed 's/^/  make /' || echo "  (sin Makefile — ejecuta /adoptar o /nuevo primero)"`

## Fase 2 — Proponer (usa la skill setup-cicd, NO escribas aún)

Apoyándote en la skill `setup-cicd` (sus plantillas y reglas de seguridad), muéstrame:
1. **Proveedor detectado** (GitHub/GitLab) por el remoto. Si es ambiguo, pregúntame.
2. El/los **YAML propuestos**, adaptados a este repo: toolchain del stack real, stages
   verify (`make check`) + build (`make build`) + SCA + SAST + secretos + deploy gated.
   Si ya hay CI, intégralo, no lo pises.
3. La **checklist de pasos manuales** que tendré que hacer yo en el proveedor (configurar
   secretos, crear el environment `production` con required reviewers / proteger la rama).

Respeta las reglas de la skill: permiso mínimo del token, pinear acciones por SHA,
nada de secretos en el YAML, deploy con aprobación humana. Espera mi OK.

## Fase 3 — Confirmar y escribir

Cuando apruebe, delega al **developer** la escritura de los ficheros confirmados (usando
la skill `setup-cicd`; tú no editas). Que NO commitee secretos. Luego recuérdame la
checklist de pasos manuales en el proveedor, que el harness no puede tocar.

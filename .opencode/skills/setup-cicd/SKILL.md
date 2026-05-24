---
name: setup-cicd
description: Genera configuracion de CI/CD para GitHub Actions o GitLab CI. Usar al preparar el pipeline de un repo. Detecta el proveedor por el remoto, ejecuta la verificacion via make (check/build) y anade escaneo de seguridad (SAST/SCA/secretos) con deploy gated. No crea el repo remoto ni configura secretos.
license: MIT
compatibility: opencode
metadata:
  audience: developer
  workflow: cicd
---

## Qué hago

Genero la configuración de CI/CD de un repo (GitHub Actions o GitLab CI) que **ejecuta
la verificación del proyecto vía `make`** y añade escaneo de seguridad (SAST, SCA,
secretos) y un stage de deploy con aprobación humana. Me invoca el **developer** para
escribir los ficheros; el **orchestrator** lee mis plantillas para proponer.

**No hago** (lo dejo como pasos manuales para el humano): crear el repo remoto,
configurar secretos del proveedor, ni activar branch protection / environments. Son
acciones remotas e irreversibles: las hace la persona en la UI del proveedor.

## Principio (lo que mantiene esto agnóstico al lenguaje)

El pipeline llama a `make`, **nunca al build tool nativo**. CI y local verifican lo
mismo: `make check` (test+lint+typecheck), `make build`, y opcionalmente `make sast`/
`make sca`/`make secrets`. Si un step necesita algo nuevo, se añade el target al
`Makefile`, no se mete un `./gradlew`/`npm`/`pytest` suelto en el YAML.

## Detección de proveedor

1. `git remote -v`. Si la URL contiene `github.com` → **GitHub Actions**
   (`.github/workflows/`). Si contiene `gitlab` → **GitLab CI** (`.gitlab-ci.yml`).
2. Si no hay remoto o es ambiguo, **pregunto** cuál antes de escribir nada.

## Selección de herramientas (agnóstico primero)

| Categoría | Por defecto (multi-lenguaje) | Nativa del proveedor |
| --------- | ---------------------------- | -------------------- |
| SAST      | Semgrep                      | CodeQL (GH) · `Jobs/SAST` (GL) |
| SCA/deps  | Trivy (`fs`) o Grype         | Dependabot (GH) · `Jobs/Dependency-Scanning` (GL) |
| Secretos  | gitleaks                     | `Jobs/Secret-Detection` (GL) |
| Contenedor (si hay Dockerfile) | Trivy `image` | — |

En GitLab uso los `include` nativos por defecto (idiomático). Si se quiere **paridad**
cross-provider, sustituyo por Semgrep/Trivy/gitleaks como jobs propios.

## Reglas de seguridad (SIEMPRE, al generar)

1. **Permiso mínimo del token:** GitHub `permissions: contents: read` a nivel workflow;
   elevar por-job solo lo necesario (`security-events: write` para subir SARIF).
2. **Pinear acciones por SHA** (no por tag móvil). Dejo el tag en comentario.
3. **Cancelar runs viejos:** `concurrency` (GH) / `interruptible: true` (GL).
4. **Secretos solo vía el store del proveedor.** Nunca en el YAML.
5. **Caché de dependencias** cuando el setup del lenguaje lo permita.
6. **Deploy gated:** GH `environment` con required reviewers; GL `when: manual` + entorno
   protegido. El deploy nunca es automático a producción.
7. **SARIF al code scanning** (GH) cuando la tool lo produzca.
8. Trivy/escáneres arrancan con `exit-code: 0` (no rompen el build el día 1); se sube a
   `1` cuando el baseline esté limpio. Lo dejo comentado.

## Plantilla — GitHub Actions

`.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push: { branches: [main] }
  pull_request:
permissions:
  contents: read
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA>   # TODO: pinear SHA (v4)
      # TODO(toolchain): setup-java / setup-node / setup-python / setup-go según stack
      - run: make check
      - run: make build
  sca:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA>
      - uses: aquasecurity/trivy-action@<SHA>
        with:
          scan-type: fs
          scanners: vuln
          format: sarif
          output: trivy.sarif
          exit-code: '0'   # subir a '1' cuando el baseline esté limpio
      - uses: github/codeql-action/upload-sarif@<SHA>
        with: { sarif_file: trivy.sarif }
  sast:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@<SHA>
      - uses: semgrep/semgrep-action@<SHA>   # config: p/default
  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA>
        with: { fetch-depth: 0 }
      - uses: gitleaks/gitleaks-action@<SHA>
```

`.github/workflows/deploy.yml` (gate humano vía environment):

```yaml
name: Deploy
on:
  workflow_dispatch:
  push: { tags: ['v*'] }
permissions:
  contents: read
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production   # required reviewers => aprobación humana
    steps:
      - uses: actions/checkout@<SHA>
      - run: make deploy        # TODO: definir make deploy
```

`.github/dependabot.yml` (opcional, actualizaciones de dependencias):

```yaml
version: 2
updates:
  - package-ecosystem: "<gradle|npm|pip|cargo|gomod>"   # TODO: según stack
    directory: "/"
    schedule: { interval: weekly }
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule: { interval: weekly }
```

## Plantilla — GitLab CI

`.gitlab-ci.yml`:

```yaml
stages: [verify, build, deploy]
default:
  interruptible: true
variables:
  GIT_DEPTH: 0   # historial completo para secret detection

include:                                  # analizadores nativos de GitLab
  - template: Jobs/SAST.gitlab-ci.yml
  - template: Jobs/Secret-Detection.gitlab-ci.yml
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

verify:
  stage: verify
  script: [ make check ]

build:
  stage: build
  script: [ make build ]
  artifacts:
    paths: [ "<TODO: output de build>" ]

deploy:
  stage: deploy
  script: [ make deploy ]    # TODO: definir make deploy
  environment: { name: production }
  rules:
    - if: '$CI_COMMIT_TAG'
      when: manual           # gate humano
```

> Variante de paridad (mismas tools que GitHub): quita el bloque `include` y añade jobs
> propios que ejecuten `semgrep ci`, `trivy fs .` y `gitleaks detect` en el stage que
> prefieras.

## Pasos

1. Detectar proveedor (`git remote -v`) y CI existente (`.github/workflows/`,
   `.gitlab-ci.yml`). Si ya hay pipeline, **integrar, no pisar**.
2. Detectar stack (manifiestos, `Dockerfile`) para el setup de toolchain y el ecosistema
   de Dependabot.
3. Escribir el/los ficheros adaptando los TODO (toolchain, SHAs, artefactos).
4. **Recordar al humano** los pasos manuales: configurar secretos en el proveedor, crear
   el environment `production` con required reviewers / proteger la rama. Yo no los toco.
5. Reportar al orquestador: ficheros creados y la checklist de pasos manuales pendientes.

## Nunca

- Meter secretos, tokens o credenciales en el YAML.
- Auto-deploy a producción sin gate humano.
- Crear el repo remoto, configurar secretos o branch protection por mi cuenta.
- Llamar al build tool nativo en el pipeline en vez de a `make`.
- Pisar un pipeline existente sin integrarlo.

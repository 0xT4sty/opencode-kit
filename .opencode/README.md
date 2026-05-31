# Harness setup para OpenCode

Setup de harness engineering nativo para **OpenCode**, con 3 roles de permisos reales
y modelos configurables por proveedor (Anthropic / Google / OpenAI / Zen).

## Estructura

```
tu-repo/
├── AGENTS.md                      ← reglas del proyecto (OpenCode las lee solas)
├── Makefile                       ← targets test/lint/typecheck/build
├── docs/decisions/                ← ADRs (decisiones de arquitectura)
└── .opencode/                     ← todo el harness vive aquí (no ensucia la raíz)
    ├── opencode.json              ← agentes + permisos REALES + modelos
    ├── README.md                  ← este archivo
    ├── init.sh                    ← orientación al empezar sesión
    ├── memory/
    │   ├── FEATURES.md            ← memoria larga: estado de features
    │   └── HANDOFF.md             ← traspaso entre sesiones
    ├── command/                   ← comandos slash (/arranque, /tarea, ...)
    ├── skills/                    ← skills de git/CI invocables
    └── prompts/
        ├── orchestrator.md        ← rol primario (no implementa)
        ├── developer.md           ← subagente que implementa
        └── reviewer.md            ← subagente solo-lectura
```

> Solo `AGENTS.md` y `Makefile` quedan en la raíz; el resto del harness se agrupa
> bajo `.opencode/` para que el repo donde trabajas quede limpio.

## Antes de usar: 3 cosas obligatorias

1. **Modelos.** Ya configurados con el perfil "Equilibrio" de OpenCode Go (ver abajo).
   Verifica los IDs exactos con `/models` en el TUI antes del primer uso — las cadenas
   pueden variar (guiones, mayúsculas) y un ID mal escrito rompe el arranque.
2. **Stack.** Rellena los `TODO` de `AGENTS.md` (stack, comandos, intocables).
3. **Makefile.** Es la **fachada** que los agentes usan para todo (build/test/lint/run).
   No lo edites a mano: `/adoptar` o `/nuevo` mapean cada target a tu build tool real.
   Cada target debe existir (los que no apliquen, no-op `@:`), porque `make <target>`
   está pre-autorizado y es lo único que corre sin pedirte permiso.

## Modelos por rol (OpenCode Go, perfil Equilibrio)

| Rol          | Modelo                       | Por qué |
| ------------ | ---------------------------- | ------- |
| reviewer     | `opencode-go/qwen3.6-plus`      | El más capaz donde más importa: detectar bugs sutiles. |
| orchestrator | `opencode-go/glm-5.1`           | Buen razonamiento para descomponer, coste medio. |
| developer    | `opencode-go/deepseek-v4-flash` | Rápido y barato; recibe tareas ya acotadas y verificadas. |

Regla de capacidad: **reviewer ≥ orchestrator > developer.** Va contra el instinto
("el jefe es el más listo"), pero el cuello de botella de calidad es la revisión, no
la ejecución: un revisor fuerte atrapa lo que un developer rápido deje pasar.

Encaja con las cuotas de Go (límites de petición, no por token): GLM-5.1 tiene un
límite ajustado (~880 req/5h) pero la planificación consume pocas peticiones, así que
vale para el orchestrator. DeepSeek V4 Flash casi nunca se topa (~31k req/5h): ideal
para el developer, que hace muchas llamadas. Qwen3.6 Plus (~3.3k req/5h) va holgado
para el reviewer. **IDs:** formato `opencode-go/<model-id>` (no `opencode/`).

**Privacidad:** todos los modelos de Go son de suscripción con retención cero — NO
usan tus datos para entrenar. Apto para código sensible. (Evita los modelos "Free"
de Zen para código privado: esos sí recogen datos en su periodo promocional.)

**Más calidad** (más cuota): developer → `opencode-go/glm-5.1`, orchestrator →
`opencode-go/deepseek-v4-pro`. **Estirar cuota:** reviewer → `opencode-go/glm-5.1`,
orchestrator → `opencode-go/mimo-v2.5-pro`.

## Por dónde empezar

El kit sirve tanto para proyectos que ya existen como para empezar de cero. La
diferencia está solo en el primer paso; después ambos convergen al mismo flujo.

```
┌─ ¿El proyecto ya existe? ──────────────────────────────┐
│                                                          │
│   SÍ ──▶ /adoptar   El orquestador explora el repo,     │
│                     detecta stack/comandos/convenciones, │
│                     rellena AGENTS.md y Makefile, y tú   │
│                     confirmas. El developer los escribe. │
│                                                          │
│   NO ──▶ /nuevo "lo que quieras construir"               │
│                     Pregunta lo mínimo, andamia la       │
│                     estructura base y deja primer commit.│
│                                                          │
└──────────────▶ a partir de aquí, flujo normal ──────────┘
                 /arranque → /tarea → /revisa → /cierre
```

`/adoptar` no inventa: reporta lo que vio y te pregunta lo que no pudo deducir, y
respeta las convenciones existentes del repo. `/nuevo` arranca con lo MÍNIMO viable
(freno anti-sobreingeniería explícito). En ambos, el orquestador propone y el developer
escribe — la separación de permisos se mantiene.

## El ciclo de trabajo

```
Tú ──▶ @orchestrator ─┬─ ejecuta .opencode/init.sh, lee AGENTS/HANDOFF/FEATURES
                      ├─ descompone en tareas atómicas
                      ├─ te presenta el PLAN ──▶ tú apruebas (checkpoint)
                      │
                      ├─ Task▶ @developer  (implementa 1 tarea, verifica)
                      └─ Task▶ @reviewer   (solo lectura, re-verifica)
                                 │
                            APRUEBA / RECHAZA ──▶ siguiente tarea
```

- Hablas con **orchestrator** (agente primario, tecla **Tab** para cambiar de primario).
- Él invoca a developer/reviewer por ti, o los llamas tú con **@developer** / **@reviewer**.

## Comandos (slash)

Atajos en `.opencode/command/`. Los invocas con `/` en el TUI. Cada uno ya trae fijado
el agente y el modelo adecuados, así que no cambias de rol a mano.

| Comando         | Qué hace                                              | Agente |
| --------------- | ----------------------------------------------------- | ------ |
| `/adoptar`      | Enchufa el kit a un repo existente: explora y rellena.| orchestrator |
| `/nuevo <idea>` | Arranca un proyecto de cero: andamia + primer commit. | orchestrator |
| `/arranque`     | Ejecuta .opencode/init.sh, lee AGENTS/HANDOFF/FEATURES, resume. | orchestrator |
| `/tarea <desc>` | Descompone la tarea en plan revisable (Spec Driven).  | orchestrator |
| `/verifica`     | Corre test/lint/typecheck e interpreta fallos.        | reviewer |
| `/revisa`       | Revisa el diff actual con el checklist del reviewer.  | reviewer |
| `/cicd`         | Prepara CI/CD (GitHub/GitLab): verify+build+seguridad.| orchestrator |
| `/cierre`       | Actualiza la memoria en `.opencode/memory/` antes de terminar. | orchestrator |

Ritual típico de sesión: `/arranque` → `/tarea "lo que sea"` → (apruebas el plan) →
el developer implementa → `/revisa` → `/cierre`.

Nota: tus skills (`git-commit`, etc.) también son invocables como `/git-commit`
automáticamente. Y los comandos son disparadores tuyos: un agente no puede lanzarlos
solo (por eso la lógica reutilizable vive en skills/roles, no en comandos).

Estos usan `!` + comando bash embebido. Si en tu OpenCode el patrón de permisos no
reconoce alguna variante de `git diff`/`git status` para el reviewer, ajusta los
patrones en `opencode.json` (ya van con y sin espacio antes del `*`).

## Build/test sin fricción: la fachada `make`

El cuello de botella de usabilidad es pedir permiso a cada `compilar/test/ejecutar`.
La solución es agnóstica al lenguaje y se apoya en dos piezas que se refuerzan:

1. **`make` es la única fachada de build/test/lint/run.** El `Makefile` mapea targets
   estándar (`setup`, `dev`, `run`, `test`, `lint`, `typecheck`, `build`, y el agregado
   `check`) al build tool real (gradle, mvn, npm, cargo, go, uv...). `/adoptar` y `/nuevo`
   lo rellenan; los que no apliquen a tu lenguaje quedan como no-op (`@:`), nunca se borran.
2. **Esos targets están pre-autorizados** en `opencode.json` (`make test*`, `make check*`,
   `make build*`, `make run*`...). Así el bucle implementar→verificar corre sin pedirte
   permiso, en cualquier lenguaje.

La regla que lo cierra (en `AGENTS.md` y en los prompts): **los agentes usan SIEMPRE
`make`, nunca el build tool nativo directo** (`./gradlew`, `mvn`, `npm`, `pytest`...).
Un comando nativo no está pre-autorizado y dispara confirmación a cada paso. Si un target
no hace lo que toca, se arregla el `Makefile`, no se esquiva. Lo destructivo (`git push`,
`rm`, `git reset`, `make migrate`) sigue en `ask`: la automatización cubre el build, no lo
irreversible. El developer corre `make check` en un solo comando en vez de tres.

**CI/CD extiende la misma fachada.** `/cicd` genera el pipeline (GitHub Actions o GitLab
CI) que llama a `make check` / `make build` — así CI y local verifican lo idéntico. Añade
seguridad (SAST/SCA/secretos vía `make sast`/`make sca`/`make secrets`, pre-autorizados) y
un stage de deploy **con aprobación humana** (`make deploy` queda fuera del allowlist a
propósito). El conocimiento (plantillas, tools, reglas de seguridad) vive en la skill
`setup-cicd`; el repo remoto, los secretos y la branch protection los configuras tú en el
proveedor — el harness no toca lo remoto.

## Por qué OpenCode y no formato portable

Estos permisos son CANDADOS, no promesas:
- `orchestrator` tiene `edit: deny` → físicamente no puede implementar.
- `developer` tiene `git push`/`rm`/`migrate` en `ask` → no puede romper sin tu OK.
- `reviewer` tiene `edit: deny` + `bash *: deny` (salvo verificación) → no toca nada.
- `permission.task` limita quién invoca a quién → developer/reviewer no hacen fan-out.

En los formatos portables (Claude Code md / Codex toml) esto sería disciplina
declarada que el agente podría ignorar. Aquí no.

## Crecer a 5 roles

Cuando los 3 rueden, añade en `opencode.json` + `prompts/`:
- **planner** (`mode: subagent`, read-only): planificación profunda en tareas grandes.
- **designer** (`mode: subagent`): contratos de UI/interfaz antes de implementar.
Recuerda añadirlos al `permission.task` del orchestrator para que pueda invocarlos.

## El principio que lo hace funcionar

El harness se **cultiva**: cada vez que un agente comete un error, añades una regla
a `AGENTS.md` o ajustas un permiso en `opencode.json` para que no se repita. En unas
semanas refleja los fallos reales de tus proyectos. Ahí está el 80% del valor.

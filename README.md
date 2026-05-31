# Harness OpenCode — instalación y uso en equipo

Harness de desarrollo agéntico para OpenCode: 3 roles con permisos reales
(orchestrator / developer / reviewer), skills de git, comandos de flujo y memoria
entre sesiones. Pensado para vivir **dentro del repo** y compartirse por git.

## Filosofía: el harness vive en el repo

Todo el harness se versiona con tu código en `.opencode/` + unos archivos de raíz.
Ventaja para equipos: **un compañero hace `git clone` y ya tiene el harness**, sin
instalar nada. La instalación *es* el clone.

Esto sigue la recomendación de OpenCode: el `AGENTS.md` y la config de proyecto se
comparten con el equipo y se commitean; lo personal va en tu config global, que no
se comparte.

## Instalación

### Caso A — Proyecto NUEVO
Clona/copia esta plantilla como punto de partida del repo, o copia la carpeta entera
y luego `git init`. Después abre `opencode` y ejecuta `/nuevo "lo que construyes"`.

### Caso B — Proyecto EXISTENTE
Desde la raíz del repo destino:

```bash
bash /ruta/a/este/kit/install.sh
```

El script copia `.opencode/` y los archivos de raíz **sin pisar** lo que ya tengas
(si un archivo existe y difiere, guarda un `.bak`). Luego abre `opencode` y ejecuta
`/adoptar` para que detecte tu stack y rellene `AGENTS.md` y `Makefile`.

## Qué se versiona (y qué no)

Commitea al repo (compartido con el equipo):
- `.opencode/` entero (agentes, skills, comandos, prompts, `init.sh` y la memoria
  viva en `.opencode/memory/`: `FEATURES.md` y `HANDOFF.md`)
- `AGENTS.md`, `Makefile`, `.gitignore`
- `docs/decisions/`

> En la raíz solo viven `AGENTS.md` (lo auto-carga OpenCode) y `Makefile` (se ejecuta
> desde la raíz). Todo lo demás del harness vive bajo `.opencode/` para no ensuciar
> el repo donde trabajas.

No commitees (añádelo a `.gitignore` si aplica): nada del harness en sí. Las
preferencias personales van en el **global de cada uno** (ver siguiente sección).

## Modelos: default en el repo, sobreescribible por persona

El `.opencode/opencode.json` trae modelos de **OpenCode Go** como default razonable:

| Rol | Modelo |
|-----|--------|
| orchestrator | `opencode-go/glm-5.1` |
| developer | `opencode-go/deepseek-v4-flash` |
| reviewer | `opencode-go/qwen3.6-plus` |

**Si un compañero no usa Go** (otro proveedor, otra suscripción), NO edita el repo.
Crea su propio `~/.config/opencode/opencode.json` redefiniendo solo los modelos:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "orchestrator": { "model": "anthropic/claude-sonnet-4-6" },
    "developer":    { "model": "openai/gpt-5-mini" },
    "reviewer":     { "model": "anthropic/claude-opus-4-7" }
  }
}
```

La config de proyecto y la global se **combinan**, y los campos del global del usuario
ganan para sus overrides personales. Así cada uno usa los modelos que tiene, mientras
el repo mantiene un default que funciona para quien sí tenga Go. Verifica IDs con `/models`.

## Flujo de trabajo

```
Instalar (clone o install.sh)
  └─ proyecto existente -> /adoptar     proyecto nuevo -> /nuevo "..."
       └─ luego, cada sesión:  /arranque -> /tarea "..." -> (apruebas) ->
                               developer implementa -> /revisa -> /cierre
```

Detalle de roles, permisos y comandos en `.opencode/README.md`.

## Build/test sin pedir permiso a cada paso

Para que el bucle implementar→verificar no te pida confirmación constantemente, el
harness usa `make` como **fachada única** de build/test/lint/run. El `Makefile` mapea
targets estándar (`test`, `lint`, `typecheck`, `build`, `run`, y el agregado `check`)
a tu build tool real, y esos targets están **pre-autorizados** en `opencode.json`. Los
agentes tienen prohibido llamar al build tool nativo directamente (`./gradlew`, `mvn`,
`npm`, `cargo`...): eso dispara permisos y rompe el flujo. Lo destructivo (`git push`,
`rm`, `git reset`, `make migrate`) sí sigue pidiendo tu OK. Esto es agnóstico al
lenguaje: `/adoptar` y `/nuevo` rellenan el `Makefile` por ti. Detalle en
`.opencode/README.md`.

La misma fachada llega a CI: **`/cicd`** genera el pipeline (GitHub Actions o GitLab CI)
que ejecuta `make check`/`make build`, añade seguridad (SAST/SCA/secretos) y un deploy
con aprobación humana. CI y local verifican lo mismo.

## Para el equipo: convenciones

- El `AGENTS.md` es la fuente de verdad compartida. Si cambias una regla, commitéala:
  beneficia a todo el equipo.
- El harness se **cultiva**: cuando un agente comete un error recurrente, añade una
  regla a `AGENTS.md` o ajusta un permiso en `opencode.json` y commitea el cambio.
- Mantén los modelos del repo en un default que la mayoría pueda usar; los gustos
  personales van en el global de cada uno, nunca en el repo.

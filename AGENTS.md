# AGENTS.md

> Reglas del proyecto. OpenCode las carga automáticamente como contexto.
> Aplican a TODOS los agentes (orchestrator, developer, reviewer).
> Mantenlo corto y denso. Si crece, mueve detalle a `docs/`.

## Qué es este proyecto
TODO: describe el proyecto en 2-3 frases (qué hace, para quién, estado).

## Stack
- **Backend:** Python <X.Y> (<FastAPI / Django / ...>)
- **Frontend:** TypeScript + <React / Next / ...>
- **Orquestación:** Make (ver comandos)
- **Tests:** <pytest / vitest>  — cobertura PARCIAL, ver `.opencode/memory/FEATURES.md`

## Comandos (úsalos SIEMPRE vía make, no invoques el build tool nativo)
`make` es la fachada del proyecto y está **pre-autorizada** (no pide permiso). Llamar
al build tool nativo directamente (`gradle`, `mvn`, `npm`, `cargo`, `pytest`, `go`...)
dispara confirmación a cada paso y rompe el flujo automático. Si un target no hace lo
que esperas, **arréglalo en el Makefile**, no lo esquives con un comando nativo.

| Acción      | Comando          | Cuándo                              |
| ----------- | ---------------- | ----------------------------------- |
| Setup       | `make setup`     | Primera vez / cambio de deps        |
| Dev         | `make dev`       | Levantar entorno local              |
| Run         | `make run`       | Ejecutar la app                     |
| Tests       | `make test`      | OBLIGATORIO tras cualquier cambio   |
| Lint+format | `make lint`      | OBLIGATORIO antes de declarar hecho |
| Type check  | `make typecheck` | OBLIGATORIO (no-op si no aplica)    |
| Build       | `make build`     | Antes de validar entregable         |
| Verificar   | `make check`     | test+lint+typecheck en un comando   |
| Seguridad   | `make audit`     | SCA + SAST + secretos (mismos en CI)|
| Deploy      | `make deploy`    | GATED: pide confirmación (no auto)  |

## Roles de agente (nativos OpenCode)
Definidos en `.opencode/opencode.json`, con permisos REALES (no son sugerencias):
- **orchestrator** (primary): hablas con él. Descompone y enruta. `edit: deny` — no implementa.
- **developer** (subagent): implementa una tarea atómica. `edit: allow` en su scope.
- **reviewer** (subagent): solo lectura (`edit: deny`). Verifica antes de aprobar.

Cambias de primario con **Tab**; invocas subagentes con **@developer** / **@reviewer**
o el orquestador los llama solo. Detalle en `.opencode/README.md`.

## Reglas obligatorias (todos los agentes)
1. **Lee el código real antes de proponer/escribir cambios.** No asumas APIs ni rutas.
2. **Plan antes de implementar** para tareas no triviales. Checkpoint humano entre medias.
3. **Toca solo lo necesario.** Refactor fuera de scope: se propone, no se hace.
4. **Diff budget:** >~150 líneas o >~5 archivos → para y consulta.
5. **Verifica siempre:** `make check` (test+lint+typecheck) antes de dar por hecho.
6. **Nunca** a `main` directo. Rama + commits pequeños.
7. **Nunca** hardcodees secretos. Usa `.env` (no commiteado).
8. Comandos destructivos (`rm`, `git push`, `git reset`, `make migrate`): requieren
   confirmación (ya están en `ask` en la config; no busques rodeos).

## Anti-patrones (NO)
- Inventar endpoints/módulos sin verificar.
- Sobreingeniería: features/abstracciones/deps no pedidas.
- Silenciar errores (`try/except: pass`, `@ts-ignore`) o borrar tests molestos.
- Reescribir módulos enteros cuando bastaba un cambio puntual.

## Convenciones
- Idioma del código/comentarios: <inglés / español> — consistente.
- Nomenclatura e imports: copia el patrón del módulo vecino.

## Memoria entre sesiones
- Estado de features → `.opencode/memory/FEATURES.md`
- Traspaso de sesión → `.opencode/memory/HANDOFF.md`
- Decisiones de arquitectura → `docs/decisions/`
Al empezar: lee `.opencode/memory/HANDOFF.md` y `.opencode/memory/FEATURES.md`. Al terminar: actualiza ambos.

## Qué NO tocar nunca
- TODO: rutas intocables (ej: `**/migrations/*_applied.py`, `dist/`, `*.lock`).

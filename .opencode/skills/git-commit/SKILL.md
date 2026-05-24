---
name: git-commit
description: Crea commits siguiendo Conventional Commits. Usar al guardar cambios en git despues de verificar. Agrupa cambios cohesionados y redacta mensajes claros tipo feat/fix/docs. NO hace push.
license: MIT
compatibility: opencode
metadata:
  audience: developer
  workflow: git
---

## Qué hago

Convierto cambios verificados en uno o varios commits limpios siguiendo
**Conventional Commits**. Decido qué agrupar y redacto el mensaje. **No hago push**
(eso es la skill `git-push`).

## Cuándo usarme

Cuando el trabajo de una tarea está terminado y **ya pasó la verificación**
(`make check`). Si no ha pasado, NO commiteo: primero se arregla.

Rol: me usa el **developer**. El **reviewer** no commitea (no tiene permisos). El
**orchestrator** no me invoca directamente, delega en el developer.

## Antes de commitear (obligatorio)
1. `make check` (test+lint+typecheck) debe estar en verde. Si no, paro.
2. Confirmar la rama: **nunca `main`**. Si estoy en main, paro y aviso.
3. `git status` y `git diff` para ver exactamente qué voy a incluir.

## Cómo agrupo
- Un commit = un cambio cohesionado y con sentido propio. No un cajón de sastre.
- Si el diff mezcla cosas no relacionadas (ej: un fix + un refactor), los separo
  en commits distintos con `git add` selectivo (por archivo o por hunk).
- No incluyo archivos basura, `.env`, builds ni nada que deba estar en `.gitignore`.

## Formato del mensaje (Conventional Commits)

```
<tipo>(<scope opcional>): <descripción en imperativo, minúscula, sin punto final>

<cuerpo opcional: el porqué del cambio, no el qué — el qué se ve en el diff>

<footer opcional: BREAKING CHANGE: ... / Refs: #123>
```

Tipos: `feat` (nueva funcionalidad), `fix` (corrección), `docs`, `style`,
`refactor`, `perf`, `test`, `build`, `ci`, `chore`.

Reglas del asunto:
- Imperativo: "add", "fix", "remove" — no "added"/"adds".
- ≤ 72 caracteres. En minúscula. Sin punto final.
- El scope (opcional) es el módulo/área: `feat(auth): ...`, `fix(api): ...`.
- `BREAKING CHANGE:` en el footer si rompe compatibilidad.

Ejemplos:
- `feat(auth): add JWT refresh token endpoint`
- `fix(api): handle null user in profile lookup`
- `refactor(db): extract query builder into helper`
- `test(auth): cover expired token case`

## Pasos
1. Verificar (tests/lint/typecheck en verde) y confirmar rama ≠ main.
2. `git add` selectivo de los cambios que forman un commit cohesionado.
3. `git commit -m "..."` con mensaje Conventional Commits. Cuerpo con `-m` extra si aporta.
4. Repetir si hay más grupos lógicos de cambios.
5. Reportar al orquestador: hash(es) y resumen. **No hago push** salvo que se invoque `git-push`.

## Nunca
- Commitear con verificación en rojo.
- Commitear directo a `main`.
- `git commit --amend` o `--no-verify` sin que el usuario lo pida explícitamente.
- Meter cambios no relacionados en el mismo commit.

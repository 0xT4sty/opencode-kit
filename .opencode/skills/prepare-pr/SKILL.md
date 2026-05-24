---
name: prepare-pr
description: Prepara una rama de feature y la descripcion de un Pull Request. Usar cuando se elige el flujo rama+PR en vez de push directo. Crea nombre de rama consistente y redacta descripcion de PR clara con resumen, cambios y como probar.
license: MIT
compatibility: opencode
metadata:
  audience: developer
  workflow: github
---

## Qué hago

Preparo el flujo rama + PR: nombre de rama consistente y una descripción de PR clara
y estándar. La invoca `git-push` cuando el usuario elige la opción (b).

## Cuándo usarme

Cuando se ha decidido publicar vía Pull Request en lugar de push directo.

## Nombre de rama
Formato: `<tipo>/<descripcion-corta-en-kebab>` alineado con Conventional Commits.
- `feat/jwt-refresh-token`
- `fix/null-user-profile`
- `refactor/query-builder`

Si ya existe una rama de feature adecuada, la reutilizo en vez de crear otra.
Nunca trabajo sobre `main`.

## Descripción del PR (plantilla)

```
## Qué cambia
<1-3 frases: el cambio y el porqué. No repetir el diff.>

## Cambios principales
- <punto>
- <punto>

## Cómo probar
1. <pasos concretos para verificar manualmente>
2. ...

## Verificación
- [ ] make check en verde (test + lint + typecheck)

## Notas
<breaking changes, migraciones, deuda asumida, follow-ups — o "ninguna">
Refs: #<issue si aplica>
```

## Pasos
1. Asegurar rama de feature con nombre consistente (crearla desde la base si hace falta).
2. Confirmar que los commits siguen Conventional Commits (si no, sugerir reordenar con git-commit).
3. Redactar la descripción del PR con la plantilla, rellenando de verdad cada sección.
4. Devolver a `git-push`: tras la confirmación humana del push, ofrecer el comando
   `gh pr create --fill` o pegar título + cuerpo si se usa la web.

## Nunca
- Abrir PR contra una rama equivocada (confirmar la base, normalmente `main`).
- Dejar la plantilla con placeholders sin rellenar.
- Pushear por mi cuenta: el push y su confirmación los maneja `git-push`.

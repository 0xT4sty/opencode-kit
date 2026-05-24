---
name: git-push
description: Publica commits con git push de forma segura. Usar tras commitear cuando hay que subir cambios al remoto. Verifica rama, pregunta push directo vs rama+PR, y SIEMPRE pide confirmacion humana antes de empujar. Nunca pushea a main.
license: MIT
compatibility: opencode
metadata:
  audience: developer
  workflow: git
---

## Qué hago

Subo commits ya creados al remoto de forma segura. Antes de empujar: verifico la
rama, decido (preguntando) entre push directo o rama + PR, y **siempre pido
confirmación humana**. El push nunca es automático.

## Cuándo usarme

Después de que `git-commit` haya dejado commits listos y se quiera publicarlos.

Rol: me usa el **developer**. Encaja con el permiso `git push*: ask` del
`opencode.json`, así que el push siempre pasa por aprobación del usuario — esta skill
y los permisos se refuerzan.

## Antes de pushear (obligatorio)
1. `git status` y `git log --oneline @{u}.. ` (o `git log -3`) para ver qué se subiría.
2. **Confirmar la rama actual.** Si es `main`/`master`, **PARO**: no se pushea a la
   rama principal directamente bajo ninguna circunstancia.
3. Confirmar que la verificación pasó (tests/lint/typecheck) antes de publicar.

## Decidir el flujo (preguntar al usuario)
El usuario quiere decidir caso por caso. Pregunto explícitamente:

> ¿Cómo publico estos commits?
> (a) **Push directo** a la rama actual `<nombre-rama>` (sin tocar main).
> (b) **Rama + PR**: creo/uso una rama de feature y preparo un PR (uso la skill `prepare-pr`).

No asumo. Espero la elección.

## Confirmación humana (obligatorio, siempre)
Antes del `git push` real, muestro un resumen y pido OK explícito:

> Voy a ejecutar: `git push origin <rama>`
> Commits a subir: <lista corta>
> ¿Confirmas? (sí / no)

Solo con un "sí" claro ejecuto. Cualquier otra cosa = no pusheo.

## Pasos
1. Verificar rama (≠ main) y estado.
2. Preguntar flujo: push directo (a) o rama + PR (b).
3. Si (b): delegar la preparación a la skill `prepare-pr` antes de empujar.
4. Mostrar resumen y pedir confirmación humana.
5. Solo tras "sí": `git push origin <rama>` (con `-u` si la rama es nueva en el remoto).
6. Reportar resultado: rama subida y, si aplica, enlace/comando del PR.

## Nunca
- `git push` a `main`/`master` directo.
- `git push --force` o `--force-with-lease` sin petición explícita del usuario.
- Pushear sin confirmación humana, aunque los tests estén en verde.
- Pushear con verificación en rojo.

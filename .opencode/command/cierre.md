---
description: Cierre de sesion - actualiza la memoria antes de terminar
agent: orchestrator
---
Estás cerrando la sesión de trabajo. Actualiza la memoria del proyecto.

Cambios de esta sesión:
!`git log --oneline -10`

Estado actual del working tree:
!`git status --short`

Haz lo siguiente, en orden:
1. Actualiza `HANDOFF.md`: en qué se trabajó, qué quedó terminado, qué quedó a medias
   (con archivo:línea), decisiones tomadas y el próximo paso concreto.
2. Actualiza `FEATURES.md`: mueve los estados que hayan cambiado (TODO/WIP/DONE/BLOCKED)
   y pon la fecha de hoy en los que tocaste.
3. Si se tomó alguna decisión de arquitectura, recuérdame crear un ADR en docs/decisions/.

Muéstrame un resumen de lo que actualizaste. No hagas commit ni push salvo que te lo pida.

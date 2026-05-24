---
description: Descompone una tarea en plan revisable (Spec Driven)
agent: orchestrator
---
El usuario quiere abordar esta tarea:

<tarea>
$ARGUMENTS
</tarea>

Sigue el flujo Spec Driven, sin implementar todavía:
1. Si la tarea es ambigua, hazme UNA pregunta clave antes de seguir.
2. Lee el código real de las zonas afectadas (no asumas rutas ni APIs).
3. Descompón en tareas atómicas y revisables (cada una = un diff pequeño).
4. Para cada subtarea, indica: archivos a tocar (verificados), contrato esperado,
   restricciones de scope y criterio de hecho (qué tests deben pasar).
5. Preséntame el plan y ESPERA mi OK antes de delegar nada al developer.

No edites código. Este es el paso de planificación; la implementación viene después
de que yo apruebe el plan.

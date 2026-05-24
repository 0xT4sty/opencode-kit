---
description: Revisa el diff actual con el checklist del reviewer
agent: reviewer
---
Revisa los cambios actuales aplicando tu checklist de revisor.

Diff frente a la base:
!`git diff HEAD`

Archivos modificados:
!`git status --short`

Aplica tu checklist completo: ¿hace lo pedido sin pasarse de scope?, ¿APIs/rutas
reales?, ¿trampas (try/except pass, @ts-ignore, tests debilitados, secretos)?,
¿coherencia con el código vecino?, ¿tamaño del diff razonable?

Ejecuta también la verificación por tu cuenta:
!`make check`

Reporta con tu formato: Veredicto (APRUEBA/RECHAZA), Bloqueantes (con archivo:línea),
No bloqueantes, y estado de la verificación. No edites nada.

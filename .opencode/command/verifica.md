---
description: Corre la verificacion completa e interpreta los fallos
agent: reviewer
---
Ejecuta la verificación del proyecto e interpreta los resultados.

Verificación completa (test + lint + typecheck):
!`make check`

Analiza la salida anterior. Si todo pasa, dilo en una línea. Si algo falla:
- Agrupa los fallos por causa raíz, no los listes uno a uno.
- Para cada grupo: qué falla, en qué archivo, y la corrección concreta sugerida.
- Distingue fallos por el cambio actual de fallos preexistentes (mira si tocan código
  que no se ha modificado en esta sesión).
No edites nada: solo diagnostica. Las correcciones las aplica el developer.

---
description: Arranca un proyecto desde cero - pregunta lo minimo, andamia y primer commit
agent: orchestrator
---
Estás arrancando un proyecto DESDE CERO. El usuario quiere construir:

<idea>
$ARGUMENTS
</idea>

Tu trabajo: acotar el alcance mínimo, andamiar la estructura base y dejar un primer
commit. El mayor riesgo aquí es la sobreingeniería: empieza con lo MÍNIMO que funcione.

## Estado actual del directorio
!`ls -la; echo "---"; git rev-parse --is-inside-work-tree 2>/dev/null && echo "Ya es repo git" || echo "Aún no es repo git"`

## Fase 1 — Acotar (pregúntame lo mínimo imprescindible)

Si la idea de arriba está vacía o es ambigua, hazme las preguntas justas para arrancar
(no más de 3): qué construimos exactamente, qué stack/lenguaje, y cuál es el alcance
de la PRIMERA versión (la más pequeña que tenga sentido). Si ya está claro, no preguntes.

## Fase 2 — Proponer el andamiaje (muéstramelo, NO lo escribas aún)

Diseña y preséntame:
1. La estructura de carpetas inicial MÍNIMA (sin sobreingeniería: nada de microservicios,
   capas de abstracción especulativas ni dependencias que no se usen el día uno).
2. El `AGENTS.md` relleno con las decisiones tomadas (stack, comandos, convenciones).
3. El `Makefile` con la fachada completa para el stack elegido: `setup`, `dev`, `run`,
   `test`, `lint`, `typecheck`, `build` y el agregado `check: test lint typecheck`.
   TODOS los targets deben existir; los que no apliquen al lenguaje son no-op silencioso
   (`@:`), nunca se borran. Razón: los agentes solo ejecutan `make <target>` sin pedir
   permiso, así que un target ausente o roto los empuja al build tool nativo y reaparecen
   los prompts.
4. Los archivos base imprescindibles (manifiesto del lenguaje, .gitignore, README mínimo,
   un "hola mundo" o esqueleto que arranque y se pueda verificar).
5. El resto de archivos de memoria del harness (`.opencode/memory/FEATURES.md`,
   `.opencode/memory/HANDOFF.md`) inicializados.

Justifica brevemente por qué ese alcance es el mínimo viable. Espera mi OK.

## Fase 3 — Andamiar y primer commit

Cuando apruebe, delega al **developer** la creación de todo lo confirmado. Que:
- Cree la estructura y archivos.
- Inicialice git si no lo está (`git init`), cree una rama de trabajo (nunca trabajar
  directo en main para el desarrollo posterior).
- Verifique que el esqueleto arranca (`make setup`, `make test` si aplica).
- Haga el **primer commit** con la skill `git-commit` (mensaje tipo `chore: scaffold inicial`).
- NO haga push (eso lo decides tú luego con `/git-push`).

Termina sugiriéndome el primer `/tarea` lógico para empezar a construir.

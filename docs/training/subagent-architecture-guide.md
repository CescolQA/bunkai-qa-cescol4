# Cómo maneja este repo el modelo de agentes y subagentes

Guía de estudio — aplicable a cualquier skill de este repositorio, no solo a `/shift-left-testing`.

**La idea central**: este repo no tiene un "roster" de agentes con nombre propio para sus skills de trabajo. El subagente es un rol descrito en texto dentro del propio SKILL.md, despachado en el momento con una llamada genérica — no un archivo de configuración aparte.

## 1. Dos modelos distintos coexisten en este entorno

### A — Agentes registrados por el harness

Tipos reales, con su propio archivo de definición y herramientas fijas. Ejemplos en esta sesión: `general-purpose`, `Explore`, `Plan`, y los del plugin *caveman* como `cavecrew-investigator`.

- Tienen prompt y permisos propios
- Se seleccionan por nombre exacto (`subagent_type`)
- Existen fuera de cualquier skill puntual

### B — Roles lógicos definidos por el skill

No son un tipo de agente aparte. Son una descripción de trabajo dentro del SKILL.md (ej. "Refinement subagent"), que en la práctica se ejecuta como una llamada genérica (normalmente `general-purpose`) con instrucciones armadas al vuelo.

- No tienen archivo propio — confirmado: `.claude/agents/` está vacío en este repo
- El nombre del rol vive solo en el texto del SKILL.md
- Cambian de un skill a otro

## 2. Quién es "el agente principal"

No es un archivo tampoco. Es la propia conversación en curso — la sesión de Claude Code que se está usando. La doctrina del repo lo dice explícito:

> "Main conversation = command center. Subagents = executors." — activo en toda sesión, no opcional.

Cada vez que se despacha un subagente, es una llamada temporal, sin memoria propia más allá de lo que el orquestador le pasa, que hace una tarea acotada y devuelve un resumen.

## 3. El contrato de 7 componentes (obligatorio en cada despacho)

No importa el skill: cualquier despacho de subagente en este repo sigue el mismo molde, definido en `agentic-qa-core/references/orchestration-doctrine.md`.

```
1. Goal               — una oración, el objetivo
2. Context docs        — qué archivos leer primero
3. Project Standards   — reglas ya resueltas del REGISTRY.md
4. Skills to load      — explícito, ej. /playwright-cli
5. Exact instructions  — paso a paso, no vago
6. Report format       — qué tiene que devolver
7. Rules               — reglas críticas aplicables
```

## 4. Los 4 patrones de ejecución

| Patrón | Cuándo se usa | Ejemplo |
|---|---|---|
| **Single** | Tarea simple, una sola vez | Fase 1 de shift-left: triage de candidatos |
| **Sequential** | Tareas dependientes, o que necesitan el OK del usuario en el medio | Fase 2 de shift-left: una historia a la vez, aunque el lote sea paralelizable en teoría |
| **Parallel** | Tareas independientes, sin necesidad de revisión intermedia | Leer 3 archivos de contexto al mismo tiempo |
| **Background** | Tareas largas que corren mientras se hace otra cosa | El subagente de refinamiento de BK-509 en esta misma práctica |

**Detalle de diseño que vale la pena recordar**: la Fase 2 de `/shift-left-testing` es *Sequential*, no *Parallel*, aunque cada historia de un lote sea independiente en Jira. La razón es explícita en el SKILL.md: correrlas en paralelo impediría mostrar el resumen de una historia y esperar el OK del usuario antes de la siguiente — rompería el ritmo de "grooming en equipo" que el skill busca imitar. El paralelismo ahorraría cómputo, pero quemaría el presupuesto de atención del usuario.

## 5. Ejemplo real — `/shift-left-testing`

| Fase | Patrón | Rol del subagente | Qué hace |
|---|---|---|---|
| 1 — Selección | Single | Backlog Selection | Trae candidatos de Jira, aplica veto + puntaje de riesgo |
| 2 — Refinamiento (por historia) | Sequential, en loop | Refinement | Lee ACs + mapas de negocio, escribe `shift-left-refinement.md` |
| 3 — Handoff (por historia) | Sequential, en loop | Handoff | Escribe en Jira: campos, labels, transición de estado |
| 3 — Reporte de lote | Single | Batch Report | Junta los resúmenes de todas las historias en un reporte final |

### Cómo se vio esto en esta misma práctica (BK-509)

```
Vos, en esta charla (= orquestador)
   -> Fase 1 (Single, inline)
   -> Fase 2 (Refinement subagent, Background)
   -> Fase 3 (simulada, inline)
```

El "Refinement subagent" nunca fue un tipo de agente con nombre propio — fue una llamada al Agent tool con un briefing de 7 componentes armado para esa tarea puntual, corriendo en background mientras la conversación seguía. Terminó, devolvió un resumen, y el orquestador (esta conversación) verificó el archivo real antes de confiar en ese resumen.

## 6. Qué skills están obligados a seguir este contrato

Por regla del repo, seis skills de trabajo deben tener su propia tabla "Subagent Dispatch Strategy" siguiendo este molde:

`shift-left-testing` · `sprint-testing` · `test-documentation` · `test-automation` · `regression-testing` · `framework-development`

Los skills de referencia o utilidad están exentos (no despachan subagentes de esta forma): `acli`, `project-discovery`, `git-flow-master`, `agentic-qa-core`, entre otros.

## 7. Qué llevarte a otros contextos

- Antes de asumir que un "subagente" mencionado en un skill es un tipo de agente registrado, revisar si `.claude/agents/` tiene un archivo con ese nombre. Si no lo tiene, es un rol lógico descrito en el SKILL.md.
- El molde de 7 componentes + 4 patrones es transversal — aprenderlo una vez sirve para leer el "Subagent Dispatch Strategy" de cualquier skill de este repo.
- Sequential vs. Parallel no es una decisión técnica solamente — casi siempre está pensada en función de cuándo el usuario necesita ver un resultado antes de que siga la siguiente tarea.
- Un subagente despachado no tiene memoria propia de la conversación — todo lo que necesita saber tiene que estar en su briefing o en los archivos que se le indica leer.

---

Generado el 2026-08-26 durante la práctica shift-left sobre BK-509, a partir de `agentic-qa-core/references/orchestration-doctrine.md`, `briefing-template.md`, `dispatch-patterns.md`, y el SKILL.md de `shift-left-testing`.

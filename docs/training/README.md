# QA Training / Practice Log

Personal QA skill-building track, story by story. Not part of the official QA deliverables under `.context/PBI/` — this is deliberate practice: blind exercises, tool exploration, and comparisons against the real historical outcome of each story.

**Entry point:** this file. Ask "abrí el backlog de training" or "qué prácticas tengo pendientes" and the index below gets read.

## Convention

One folder per practice: `docs/training/<STORY-KEY>-<slug>/`, e.g. `BK-509-create-project-in-workspace/`.

Start a new one by copying `_TEMPLATE/` and filling in the story key.

Lifecycle: an entry starts as a row in **Backlog**, moves to **Active practices** when you copy the template and begin, and stays there marked `Cerrada` when done (kept for reference, not deleted).

## Active practices

| Practice | Type | Status | Folder |
|---|---|---|---|
| BK-509 — Create a project inside a workspace | shift-left | Cerrada (2026-08-26) — Fase 1 análisis a ciegas, Fase 2 `/shift-left-testing` real, Fase 3 comparación 3 vías | [`BK-509-create-project-in-workspace/`](./BK-509-create-project-in-workspace/) |
| BK-859 — Leave a workspace | sprint-testing | Activa — pasos 1-3.5 hechos (brief acotado + rampa + modelo de roles + reconocimiento in-app, todo en el folder); paso 4 pasada ciega en curso (`pasada-ciega.html`) | [`BK-859-leave-a-workspace/`](./BK-859-leave-a-workspace/) |

## Backlog

Ideas de práctica sin empezar. Una línea cada una: qué historia o tema, qué tipo de práctica, por qué te interesa. Cuando arrancás una, copiás `_TEMPLATE/` y la subís a **Active practices**.

| Idea | Type | Nota |
|---|---|---|
| _(vacío — agregá acá)_ | | |

## Referencias transversales

Documentos que no pertenecen a una historia puntual, sino al método — se leen antes de arrancar el shift-left de cualquier historia futura.

| Documento | Para qué sirve |
|---|---|
| [`shift-left-readiness-checklist.md`](./shift-left-readiness-checklist.md) | Diagnóstico de madurez del sistema (evolutivo vs. desde cero) y qué pedirle al equipo / al proyecto / al producto en cada caso. Nace de la práctica sobre BK-509, aplica a cualquier historia. |
| [`subagent-architecture-guide.md`](./subagent-architecture-guide.md) | Cómo maneja este repo agentes y subagentes: orquestador vs. roles lógicos por skill, contrato de 7 componentes, 4 patrones de despacho. |

## Ideas / hilos pendientes del método

Cosas surgidas durante la práctica que todavía no son un documento ni una práctica formal.

- **Brief de contexto de negocio por historia:** antes de refinar una historia, la IA lee los 4 mapas de negocio project-wide; un analista humano arranca sin eso. Idea: formalizar un brief acotado a la historia como herramienta personal, después proponerlo al equipo. Piloteado en BK-509.
- **Trío de onboarding de contexto (piloteado en BK-859):** brief acotado + `rampa-de-arranque.md` (checklist de arranque + reconocimiento in-app) + `modelo-de-roles-y-membership.md` (roles / estados / formas mapeadas a los guards de la feature + primer de "fixture"). Candidato a plantilla en `_TEMPLATE/`.
- **Formulario local para pasadas a mano (piloteado en BK-859):** HTML standalone con autoguardado en `localStorage` y export a Markdown/JSON, para llenar la pasada ciega sin depender de la IA y después comparar. Ver `BK-859-leave-a-workspace/pasada-ciega.html`.
- **Fixtures a mano antes de automatizar:** armar al menos un fixture de API a mano (Postman) como repaso, con un procedimiento paso a paso documentado, antes de que la IA lo scriptee. Arranca en BK-859 paso 6 con el fixture B (`POST /api/v1/workspaces`).

## Why this exists, not `.context/PBI/`

`.context/PBI/` is a read-only Jira sync cache (AGENTS.md §9) — hand-writing into `[SYNC]` files there gets overwritten on the next `jira:sync-issues pull`, and it's meant for official traceability, not personal learning notes. This folder is skill-authored, non-Jira, and safe to shape freely.

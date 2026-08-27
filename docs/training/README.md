# QA Training / Practice Log

Personal QA skill-building track, story by story. Not part of the official QA deliverables under `.context/PBI/` — this is deliberate practice: blind exercises, tool exploration, and comparisons against the real historical outcome of each story.

## Convention

One folder per story: `docs/training/<STORY-KEY>-<slug>/`, e.g. `BK-509-create-project-in-workspace/`.

Start a new one by copying `_TEMPLATE/` and filling in the story key.

## Index

| Story | Status | Folder |
|---|---|---|
| BK-509 | Phase 1 (blind exercise) in progress | [`BK-509-create-project-in-workspace/`](./BK-509-create-project-in-workspace/) |

## Referencias transversales

Documentos que no pertenecen a una historia puntual, sino al método — se leen antes de arrancar el shift-left de cualquier historia futura.

| Documento | Para qué sirve |
|---|---|
| [`shift-left-readiness-checklist.md`](./shift-left-readiness-checklist.md) | Diagnóstico de madurez del sistema (evolutivo vs. desde cero) y qué pedirle al equipo / al proyecto / al producto en cada caso. Nace de la práctica sobre BK-509, aplica a cualquier historia. |
| [`subagent-architecture-guide.md`](./subagent-architecture-guide.md) | Cómo maneja este repo agentes y subagentes: orquestador vs. roles lógicos por skill, contrato de 7 componentes, 4 patrones de despacho. |

## Why this exists, not `.context/PBI/`

`.context/PBI/` is a read-only Jira sync cache (AGENTS.md §9) — hand-writing into `[SYNC]` files there gets overwritten on the next `jira:sync-issues pull`, and it's meant for official traceability, not personal learning notes. This folder is skill-authored, non-Jira, and safe to shape freely.

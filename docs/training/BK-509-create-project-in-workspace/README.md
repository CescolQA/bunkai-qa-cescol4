# Practice Track — BK-509 TMS-Project | Create a project inside a workspace

## Goal

Learn `/shift-left-testing` usage and sharpen QA functional eye by working BK-509 in 3 phases, then comparing against the real historical resolution.

BK-509 chosen deliberately: already fully resolved in real life (shift-left done 2026-05-28, ATP with 11 ACs / 15 test cases, ATR executed 2026-06-04, verdict FAILED-NO-GO, 3 defects: BK-54 reserved slugs, BK-55 detail route not workspace-scoped, BK-56 non-Latin names rejected). That history is the answer key for Phase 3.

## Status (2026-08-26)

- [x] Phase 1 — Blind exercise: done, see `phase1-blind-analysis.md`
- [ ] Phase 2 — Run `/shift-left-testing` for real: in progress
- [ ] Phase 3 — Three-way compare: not started

## Study files (outside this repo, still authoritative)

- `C:\Users\Lenovo\Documents\bunkai-qa-training\BK-509\bk-509-shift-left-blind.html` — blind-exercise form (ambiguities/gaps/risk/questions/notes, autosaves to browser localStorage, has an "export markdown" button).
- `C:\Users\Lenovo\Documents\bunkai-qa-training\BK-509\bk-509-contexto-tecnico.html` — reference sheet: staging env URL, exploratory checklist, `public.projects` DB schema, API contract for `POST /api/v1/workspaces/{id}/projects`, curl example via `bun run api:login:staging`.

Not migrated into this repo folder yet — still local-only HTML tools. Move or link them here once Phase 1 wraps, if useful for the record.

## Preflight Gate review artifact

Interactive HTML review of why the `/shift-left-testing` Readiness Preflight Gate blocked Phase 2 and what each `project-context` mode (data / features / api / test-plan) produced to unblock it. Local source: `preflight-gate.html` in this folder (self-contained, open directly in a browser). Also published live at https://claude.ai/code/artifact/d4c7cfe6-b43b-4b6d-a251-de364c538389 — private artifact, tied to the account that published it, use the local file as the durable copy.

## Technical notes

See `db-notes.md` and `queries.sql` in this folder.

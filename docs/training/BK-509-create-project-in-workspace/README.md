# Practice Track — BK-509 TMS-Project | Create a project inside a workspace

## Goal

Learn `/shift-left-testing` usage and sharpen QA functional eye by working BK-509 in 3 phases, then comparing against the real historical resolution.

BK-509 chosen deliberately: already fully resolved in real life (shift-left done 2026-05-28, ATP with 11 ACs / 15 test cases, ATR executed 2026-06-04, verdict FAILED-NO-GO, 3 defects: BK-54 reserved slugs, BK-55 detail route not workspace-scoped, BK-56 non-Latin names rejected). That history is the answer key for Phase 3.

## Status (2026-08-25)

- [ ] Phase 1 — Blind exercise: in progress, not finished
- [ ] Phase 2 — Run `/shift-left-testing` for real: not started
- [ ] Phase 3 — Three-way compare: not started

Currently heads-down on **pre-Phase-1 technical setup**: exploring the staging DB directly (schema, working queries) before finishing the blind write-up. See `db-notes.md`.

## Study files (outside this repo, still authoritative)

- `C:\Users\Lenovo\Documents\bunkai-qa-training\BK-509\bk-509-shift-left-blind.html` — blind-exercise form (ambiguities/gaps/risk/questions/notes, autosaves to browser localStorage, has an "export markdown" button).
- `C:\Users\Lenovo\Documents\bunkai-qa-training\BK-509\bk-509-contexto-tecnico.html` — reference sheet: staging env URL, exploratory checklist, `public.projects` DB schema, API contract for `POST /api/v1/workspaces/{id}/projects`, curl example via `bun run api:login:staging`.

Not migrated into this repo folder yet — still local-only HTML tools. Move or link them here once Phase 1 wraps, if useful for the record.

## Technical notes

See `db-notes.md` and `queries.sql` in this folder.

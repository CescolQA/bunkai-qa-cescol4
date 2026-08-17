# User Story — Format Reference

> **This is a format-reference guide, NOT a per-ticket authoring target.** It documents the canonical SHAPE a Story takes in Jira project `BK` (issue type `Story`, UI label "Historia"). Per-ticket content is the source of truth in Jira and is synced read-only into `.context/PBI/epics/EPIC-BK-<n>-<slug>/stories/STORY-BK-<n>-<slug>/story.md` by `/sprint-testing` (`bun run jira:sync-issues get <KEY> --include-comments`). Never hand-author a real story from this file — use it only to recognize/validate the shape of a synced story or to explain the expected format to a PO.

---

## Header

| Field | Value |
|---|---|
| Key | `[BK-XXX]` |
| Title | `[short imperative summary]` |
| Epic | `[EPIC-BK-XXX — epic name]` |
| Sprint | `[Bunkai (<cycle>) Sprint <N>]` |
| Status | `[current workflow state — see README.md §4 Story lifecycle]` |
| QA Assignee | `[self — set on first touch, never overwrite an existing owner]` |

---

## Narrative

As a `[persona]`
I want to `[action]`
So that `[benefit]`

---

## Acceptance Criteria

Given/When/Then, one scenario per AC, numbered sequentially. Never leave an AC blank — a Story synced with no ACs is a Discovery Gap for `/shift-left-testing`, not a reason to invent one here.

**AC1 — `[short AC title]`**
- Given `[precondition]`
- When `[action]`
- Then `[expected result]`

**AC2 — `[short AC title]`**
- Given `[precondition]`
- When `[action]`
- Then `[expected result]`

**AC[N] — `[short AC title]`**
- Given `[precondition]`
- When `[action]`
- Then `[expected result]`

### AC checklist (apply to every AC above)

- [ ] Specific and measurable
- [ ] Testable (can be automated)
- [ ] Independent (doesn't assume other ACs)
- [ ] Business-focused (not implementation detail)

> Binding doctrine: verifying ACs is the FLOOR, not the ceiling of testing. One AC typically explodes into multiple test cases (1:N) — collapsing to a single test case requires a written "trivially atomic" justification. See `CLAUDE.md` §8 Test-Design Doctrine / `agentic-qa-core/references/test-design-doctrine.md`.

---

## Technical Notes

- [ ] API changes — `[endpoint(s) affected, or "none"]`
- [ ] DB changes — `[table(s)/migration, or "none"]`
- [ ] UI changes — `[screen(s)/component(s), or "none"]`
- [ ] Dependencies — `[other stories/services this depends on, or "none"]`

---

## Out of Scope

- `[explicitly excluded behavior #1]`
- `[explicitly excluded behavior #2]`

---

## Design / Mockups

- `[link to Figma/design artifact, or "none provided"]`

---

## Related Stories

| Relation | Key | Title |
|---|---|---|
| Blocked by | `[BK-XXX]` | `[title]` |
| Related to | `[BK-XXX]` | `[title]` |

---

## Discovery Gaps

- None at template-authoring time — this is a static reference shape, not a live sync. When a real Story is synced, ACs missing, "Tarea" issue type ambiguity (see `.context/PBI/README.md` §8), and required-custom-field IDs (Story Points, Epic Link) should be re-verified against `.agents/jira-fields.json` before using this shape to CLI-create a real ticket.

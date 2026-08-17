# Test Plan — Format Reference

> **This is a format-reference guide, NOT a per-ticket authoring target.** It documents the canonical SHAPE of a story-scoped Acceptance Test Plan (ATP) in this repo's TMS Modality A (Xray on Jira, project `BK`). Per-ticket content is synced read-only by `/sprint-testing` / `/test-documentation`. Never hand-author a real plan from this file.

## Header

| Field | Value |
|---|---|
| Story key | `[BK-XXX]` |
| Story title | `[title]` |
| Epic | `[EPIC-BK-XXX — epic name]` |
| Sprint | `[Bunkai (<cycle>) Sprint <N>]` |
| Linked Xray Test Plan | `[BK-XXX — Test Plan issue, if one exists]` |
| Author | `[self]` |
| Date | `[ISO 8601]` |

---

## AC → TC Mapping

One AC typically maps to **multiple** test cases (1:N explosion is the default per Test-Design Doctrine — collapse to 1:1 only with a written "trivially atomic" justification).

| AC | Test Case(s) | Notes |
|---|---|---|
| AC1 | `TC-001, TC-002` | `[why more than one, or "trivially atomic" justification]` |
| AC2 | `TC-003` | `[justification if 1:1]` |
| AC[N] | `TC-00N` | |

---

## Scope

### In Scope

- `[AC-driven functionality #1]`
- `[risk-beyond-AC area explicitly included, e.g. concurrent edits]`

### Out of Scope

- `[explicitly excluded — mirrors Story's Out of Scope section]`

---

## Test Types

| Type | Required | Reason |
|---|---|---|
| Functional | `[Yes/No]` | `[why]` |
| UI | `[Yes/No]` | `[why]` |
| API | `[Yes/No]` | `[why]` |
| Performance | `[Yes/No]` | `[why]` |
| Security | `[Yes/No]` | `[why]` |
| Accessibility (A11y) | `[Yes/No]` | `[why]` |

---

## Test Environments

| Environment | Purpose |
|---|---|
| local | `[dev-loop verification, or "not used"]` |
| qa | `[primary execution environment, or "not used"]` |
| staging | `[pre-release validation, or "not used"]` |
| production | `[smoke-only, or "not used"]` |

---

## Test Data Requirements

- `[dataset/fixture #1 — e.g. seeded user with role X]`
- `[dataset/fixture #2 — e.g. product with zero stock]`

---

## Test Cases

| ID | Title | Priority | Type | AC ref | Automatable |
|---|---|---|---|---|---|
| TC-001 | `[title]` | `[Critical/High/Medium/Low]` | `[Functional/UI/API/...]` | `[AC1]` | `[Yes/No]` |
| TC-002 | `[title]` | `[priority]` | `[type]` | `[AC1]` | `[Yes/No]` |
| TC-00N | `[title]` | `[priority]` | `[type]` | `[ACn]` | `[Yes/No]` |

---

## Edge Cases and Negative Tests

Derived by technique-trigger per Test-Design Doctrine: EP always; BVA on ranges/limits; State-Transition on status fields; Decision Table on 2+ interacting conditions; Pairwise on 3+ factors.

| ID | Scenario | Technique | Expected |
|---|---|---|---|
| TC-0XX | `[boundary/negative case]` | `[EP/BVA/State-Transition/Decision-Table/Pairwise/Error-Guessing]` | `[expected result]` |

---

## Dependencies / Blockers / Risks

| Item | Type | Description |
|---|---|---|
| `[dependency name]` | Dependency | `[what this plan depends on]` |
| `[blocker name]` | Blocker | `[what currently blocks execution]` |
| `[risk name]` | Risk | `[risk-beyond-AC area and why it matters]` |

---

## Execution Checklist

- [ ] All ACs mapped to at least one TC
- [ ] Edge cases derived via applicable technique triggers
- [ ] Test data prepared
- [ ] Environment confirmed reachable
- [ ] All TCs executed and results recorded in ATR

## Sign-off

| Role | Name | Date | Verdict |
|---|---|---|---|
| QA | `[self]` | `[date]` | `[Approved/Rejected/Blocked]` |

---

## Discovery Gaps

- None at template-authoring time. This shape assumes TMS Modality A (Xray on Jira) confirmed live in `.context/PBI/README.md` §4 — if the project ever falls back to Modality B (Jira-native, no Xray), ATP/ATR move to Story custom fields per `.claude/skills/test-documentation/references/jira-setup.md` and this table-based Test Case section would map to Jira `Test` issues instead of Xray Test entities.

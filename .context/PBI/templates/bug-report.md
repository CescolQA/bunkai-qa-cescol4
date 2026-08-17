# Bug / Defect Report — Format Reference

> **This is a format-reference guide, NOT a per-ticket authoring target.** It documents the canonical SHAPE a quality-issue report takes in Jira project `BK`. Per-ticket content is the source of truth in Jira and is synced read-only by `/sprint-testing`. Never hand-author a real report from this file.

## Which issue type applies — Bug vs Defect vs Improvement

Project `BK` carries **three distinct issue types** for quality findings — pick by the FEATURE's lifecycle stage, never by where the problem was found:

| Issue type | Use when | Example |
|---|---|---|
| `Bug` (UI label "Error") | The feature has **already shipped to production** (live above Staging) — the sprint quality gate was escaped | Login broken in production for existing users |
| `Defect` | The feature is **still pre-release** (in development, In Test, or on Staging) — caught before it crosses into production | AC2 fails during `/sprint-testing` on a story still `In Test` this sprint |
| `Improvement` (UI label "Mejora") | The behavior matches every written AC — no AC is broken — but a test-beyond-AC surfaced a gap, an under-specified case, or an enhancement opportunity | Filter works exactly as specified, but bulk-export was never specified and would add value |

> If you retested a fix and the fix is confirmed against a **still-unreleased** story, it stays a `Defect`. If it was already in production when found, it is a `Bug` — even if you first noticed it in Staging while validating something else. Full doctrine: `CLAUDE.md` §8 Defect-Management Doctrine / `agentic-qa-core/references/defect-management-doctrine.md`.

Every quality issue parents to the QA process epic **"QA Defect Management"** (never a product/dev epic), links to the source Story via issue-link, and sets mandatory `Components` (affected product module) + `qa_assignee` (self, never overwriting an existing owner).

---

## Header

| Field | Value |
|---|---|
| Key | `[BK-XXX]` |
| Issue type | `[Bug / Defect / Improvement — see table above]` |
| Source Story | `[BK-XXX — linked via issue-link, not parent]` |
| QA Process Epic | `QA Defect Management` |
| Components | `[affected product module — mandatory]` |
| QA Assignee | `[self]` |

## Summary

`[one-line description of the defect — symptom, not root cause]`

## Environment

| Field | Value |
|---|---|
| Environment | `[local / qa / staging / production]` |
| Browser | `[browser + version, or "N/A" for API-only]` |
| OS | `[operating system]` |
| User type | `[role/persona affected]` |
| Date/Time | `[when observed, ISO 8601]` |

## Steps to Reproduce

1. `[step 1]`
2. `[step 2]`
3. `[step N]`

## Expected vs Actual

| | Description |
|---|---|
| Expected | `[what should happen per the AC or spec]` |
| Actual | `[what actually happens]` |

## Evidence

- Screenshots — `[repo-relative path(s), or "none"]`
- Console logs — `[relevant excerpt, or "none"]`
- Network requests — `[relevant request/response, or "none"]`
- Video/trace — `[repo-relative path, or "none"]`

## Impact

| Field | Value |
|---|---|
| Severity | `[Critical / High / Medium / Low — see guide below]` |
| Users affected | `[all / subset — describe]` |
| Workaround | `[exists — describe / none]` |
| Frequency | `[always / intermittent — describe]` |

### Severity guide

| Severity | Criteria | Example |
|---|---|---|
| Critical | System down, data loss, security breach | Cannot login, payment fails |
| High | Major feature broken, no workaround | Cannot create orders |
| Medium | Feature impaired, workaround exists | Filter broken, search works |
| Low | Cosmetic, minor | Typo, alignment |

> Priority is auto-derived from Severity per `agentic-qa-core/references/defect-management-doctrine.md` — do not set Priority independently of Severity.

## Regression Flag

`[worked before / never worked / unknown]`

## Related Issues

| Relation | Key | Title |
|---|---|---|
| Source story | `[BK-XXX]` | `[title]` |
| Duplicate of | `[BK-XXX, or "none"]` | `[title]` |
| Related to | `[BK-XXX, or "none"]` | `[title]` |

---

## Discovery Gaps

- None at template-authoring time. Bug (36 live) and Defect (10 live) both confirmed as active issue types in `BK` per `.context/PBI/README.md` §4 — this template's Bug-vs-Defect split is not speculative. Custom field IDs for Severity/Priority/Components should be re-verified against `.agents/jira-fields.json` before CLI-filing a real report.

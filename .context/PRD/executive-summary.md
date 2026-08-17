# Executive Summary — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Built from `.context/business/business-model.md` and `.context/business/domain-glossary.md` (Phase 1 outputs) plus a targeted grep for analytics/tracking signals in this pass. Excludes the target repo's own `README.md`/`CONTEXT.md`, which describe an unrelated meta-framework bundled in the same repo — see business-model.md line 3.
> Generated: 2026-08-17

---

## 1. Problem Statement

### The Challenge

Teams doing QA on their own software need a place to author acceptance criteria and reusable acceptance test cases (ATCs), chain them into executable Tests, run those Tests against a chosen environment, and track resulting Bugs back to the requirement that failed. Bunkai TMS encodes this as a strict traceability chain — `workspaces` → `projects` → `modules` → `user_stories` → `acceptance_criteria`, with `atcs` anchored to ≥1 acceptance criterion and `tests` composed of chained ATC references (Source: `business-model.md` §1, citing `supabase/migrations/0001-0004`).

The product is explicitly designed for more than browser-only use: the OpenAPI spec states it "wraps Supabase auth, ATC authoring, and run execution behind a versioned `/api/v1` surface. Designed to be operated by humans, scripts, CI/CD, and AI agents" (Source: `public/openapi.json` lines 4-10, quoted in `business-model.md` §1). Dual auth (magic-link cookie session for the browser, scoped Personal Access Tokens for scripts/CI/agents) and an idempotency-key contract on write endpoints like Run creation back this up structurally.

A one-way Jira import (`POST /api/v1/imports`) lets a project pull in existing Jira stories instead of re-authoring the backlog inside Bunkai. Traceability, coverage, and defect-heatmap reporting endpoints indicate the problem extends beyond "run tests" into "prove which requirements are covered and where quality risk concentrates" (Source: `business-model.md` §1).

### Current Alternatives

Not discoverable from code — no competitor mentions, migration-comment context, or marketing copy exists in-repo. Flagged in Discovery Gaps.

---

## 2. Solution Overview

### Product Vision

A multi-tenant test management system that enforces structural traceability from business requirement through acceptance test case to executed run and filed defect, usable equally by humans in a browser and by scripts/CI/AI agents via a versioned API.

### Core Capabilities

| # | Feature | Problem Addressed | Evidence (route or component) |
|---|---|---|---|
| 1 | Multi-tenant workspace/project/module hierarchy with 4-role RBAC (`viewer`/`member`/`admin`/`owner`) | Isolates each team's QA work; scopes access by role | `supabase/migrations/0001_tenancy.sql`, `0002_projects_modules.sql` |
| 2 | User story + acceptance criteria authoring, with one-way Jira import | Captures testable requirements without forcing backlog re-entry | `supabase/migrations/0003_authoring.sql`; `POST /api/v1/imports` (`public/openapi.json` lines 7965-7990) |
| 3 | ATC (Acceptance Test Case) authoring, anchored to ≥1 acceptance criterion (the "anchoring moat") | Prevents test cases from existing without a traceable requirement link | `supabase/migrations/0004_atcs.sql` (BR-1 in `domain-glossary.md` §3) |
| 4 | Test composition (ordered ATC chains) + Run execution against a named Project Environment, with idempotent replay-safe creation | Lets a chain of ATCs be executed repeatedly and safely against Staging/Production without duplicate runs on retry | `supabase/migrations/0024_tests.sql`, `0031_runs.sql`; `POST /api/v1/runs` (idempotency, `public/openapi.json` lines 9541-9551) |
| 5 | Bug tracking with Run/Step/ATC provenance, plus coverage/traceability/defect-heatmap reporting | Closes the loop from failed step to filed defect and surfaces requirement coverage + risk concentration | `supabase/migrations/0046_bugs.sql`; `/api/v1/projects/{id}/{coverage,traceability}`, `/bugs/heatmap` (`public/openapi.json` lines 10636-11093) |

### Key Differentiators

- **Structural (not conventional) traceability**: an ATC cannot be created without linking to ≥1 acceptance criterion — enforced by the `bunkai_create_atc` RPC, not by team discipline (Source: `supabase/migrations/0021_atc_create_update.sql:158-169`, BR-1).
- **Dual-actor design stated in the product's own API description**: "Designed to be operated by humans, scripts, CI/CD, and AI agents" (Source: `public/openapi.json` lines 4-10 — direct quote, not inferred).

No other differentiators are claimable from code alone; inventing more would violate the Phase 2 quality rule against fabricated differentiators.

---

## 3. Success Metrics

### Tracked Metrics

None found. A targeted grep of `app/` and `lib/` for `analytics|track\(|\.event\(|posthog|amplitude|mixpanel` returned only source-code comments referencing a DB role named "QA/analytics" (access-control comments, not product telemetry) — no real `track()`/`analytics.event()` call site exists. `package.json` has no Sentry/DataDog/PostHog/Amplitude/Mixpanel dependency.

### Inferred KPIs (from features, not real tracking)

| Metric | Type | Inferred From |
|---|---|---|
| Runs executed per Project/Environment | Adoption | `runs` table + `/api/v1/runs*` endpoints |
| ATC reuse rate (same ATC across multiple Test chains) | Engagement | `test_steps` allows the same ATC at multiple chain positions (`domain-glossary.md` §1.8) |
| Bug resolution time (`open` → `closed`) | Engagement/Quality | `bugs.status` forward-only lifecycle (BR-5) |
| Coverage % (ACs with ≥1 linked ATC) | Quality | `/api/v1/projects/{id}/coverage` endpoint |

### Unknown Metrics (gaps)

- No revenue/monetization metric — `workspaces.plan` (`community`/`cloud`/`enterprise`) has no billing or enforcement logic found (`business-model.md` §2 Revenue Streams: Unknown).
- No product-usage analytics pipeline exists to measure adoption/engagement in practice — the Inferred KPIs above are derivable from the schema but nothing currently computes or surfaces them as dashboards.

---

## 4. Target Users

Brief per system role (detailed personas deferred to `user-personas.md`):

| Role | Need | Evidence |
|---|---|---|
| `viewer` | Read-only visibility into a workspace's projects, tests, runs, and bugs | `supabase/migrations/0001_tenancy.sql:43-44` |
| `member` | Author user stories/ACs/ATCs, compose Tests, execute Runs, file Bugs | `0001_tenancy.sql:43-44` (standard contributor rights) |
| `admin` | Everything `member` can do, plus manage workspace members/invites | `0001_tenancy.sql:43-44` |
| `owner` | Full workspace control, including deletion; ≥1 must always remain (BR-8) | `0001_tenancy.sql:43-44`; `0044_leave_workspace.sql:75-95` |

---

## 5. Product Scope

### What's Included (current capabilities)

- Multi-tenant workspaces with RLS-enforced isolation, 4-role RBAC, self-service invite flow.
- Project → Module (tree, depth ≤ 6) → User Story → Acceptance Criterion authoring, with one-way Jira import.
- ATC authoring (steps + assertions), anchored to ≥1 AC, versioned, full-text searchable, tagged (max 10).
- Test composition (ordered, duplicate-allowed ATC chains) and Run execution against a named Project Environment, with idempotent replay-safe creation and immutable per-run snapshots.
- Bug tracking (severity `P1`-`P4`, forward-only status lifecycle) with optional Run/Step/ATC provenance and assignment to active non-`viewer` members.
- Milestones, in-app/email notifications (run + bug lifecycle events), coverage/traceability/defect-heatmap reporting.
- Dual auth: browser magic-link session + scoped Personal Access Tokens for CLI/CI/AI-agent use.

### What's Not Included (known limitations)

- No billing/plan enforcement — `workspaces.plan` values exist in schema but gate nothing (`business-model.md` §2).
- No CI/CD pipeline in the target repo (`.github/workflows/` absent — `project-config.md`).
- No monitoring/observability integration detected (no Sentry/DataDog/etc. dependency).
- No i18n — `atcs.status` is a confirmed dead column (never written in production; real status lives on `run_atcs.status`) (`domain-glossary.md` §8).
- `mentions` notification type is structurally locked pending a future Team Chat feature (`domain-glossary.md` §2, `0062_notification_preferences.sql:45`).

### Future Indicators

- `workspaces.plan` supports `cloud`/`enterprise` values with no enforcement code yet — signals a planned tiering model not yet built (`domain-glossary.md` §8).
- `notification_preferences.event_type = 'mentions'` is rejected by RLS "until a future Team Chat feature ships" — an explicit forward-looking comment in the migration itself (`0062_notification_preferences.sql:45`).
- Two migrations exist but are explicitly not applied to the live database per their own headers: `0058_atc_title_min_length.sql` ("PENDING HUMAN APPROVAL") and `0067_run_finish_abort_via.sql` — active schema evolution in flight (`domain-glossary.md` §8).

---

## 6. Discovery Gaps

| Gap | Impact | Suggested Source |
|---|---|---|
| Revenue model / plan-tier enforcement unconfirmed | Cannot state pricing/monetization in this doc; affects whether plan-gated features need test coverage | Ask product owner; re-check `app/api/v1/workspaces/**` for gating logic not yet read |
| Target customer profile unconfirmed (no landing page/marketing copy in repo) | Target Users section is role-based only, not ICP-based | Ask product owner; check for a separate marketing site repo |
| No product-usage analytics found | Success Metrics section has no Tracked Metrics; cannot verify real adoption/engagement | Confirm whether Vercel Analytics or an external dashboard exists outside this repo |
| Production environment URL unconfirmed | Cannot state a verified production target for this PRD | `.agents/project.yaml` has no `environments.production` block — confirm with user (`project-config.md`) |
| Two migrations not yet applied to live DB (`0058`, `0067`) | ATC title floor and Run finish/abort parameter shape may differ from what's documented here | Re-verify against a live Supabase schema snapshot before writing test assertions |
| Current Alternatives (competitive landscape) not discoverable from code | Problem Statement omits competitive context | Ask product owner |

---

## 7. QA Relevance

### Critical Testing Areas

- Tenant isolation: a user in Workspace A must never read/write Workspace B's data, even via direct PAT calls.
- ATC anchoring moat: ATC creation must reject zero linked acceptance criteria (BR-1).
- Run idempotency: same `(test_id, start_token)` within 24h must replay, not duplicate (BR-4).
- Bug status forward-only lifecycle: no skip, no backward transition (BR-5).
- Run snapshot immutability: editing an ATC after a Run starts must not change that Run's recorded steps (BR-3).

### Risk Areas

- Coverage/traceability/defect-heatmap reports are aggregate/derived views — prone to silent drift from underlying entity tables as schema evolves.
- `atcs.status` is a dead column — any test asserting on it changing post-Run will fail; assert on `run_atcs.status`/`run_steps.status` instead.
- Two unapplied migrations (`0058`, `0067`) mean the live schema may not match this document on ATC title floor or run finish/abort parameters.
- No billing enforcement exists — do not write tests against unconfirmed plan-gating behavior.

Full detail: `.context/business/business-model.md` §4 QA Relevance table; `.context/business/domain-glossary.md` §9 QA Usage Guide.

---

## 8. Document References

| Document | Status |
|---|---|
| `.context/business/business-model.md` | Done — source for Problem Statement, Value Propositions, QA Relevance |
| `.context/business/domain-glossary.md` | Done — source for Core Capabilities evidence, entities, business rules, status flows |
| `.context/project-config.md` | Done — repo paths, stack, environments |
| `.context/PRD/user-personas.md` | Pending — next PRD sub-step |
| `.context/PRD/user-journeys.md` | Pending — next PRD sub-step |
| `.context/business/business-feature-map.md` | Deferred to post-discovery `/business-feature-map` command |

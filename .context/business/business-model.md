# Business Model — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Reverse-engineered from code — never from README.md/CONTEXT.md, which describe an unrelated meta-framework ("agentic-dev-boilerplate") bundled in the same repo, not the shipped product. See Discovery Gaps.
> Generated: 2026-08-17

**Confidence level: Medium.** High confidence on entity model, feature surface, and RBAC (all directly from schema + OpenAPI spec, no marketing language involved). Medium-to-Low confidence on Customer Segments and Value Propositions (inferred from what the product *does*, since no landing page / marketing copy exists in-repo to state them directly). Revenue Streams and Cost Structure are Unknown by design — see below.

---

## 1. Problem Statement

Bunkai TMS is a multi-tenant test management system: teams doing QA on their own software need a place to author acceptance criteria and reusable acceptance test cases (ATCs), chain them into executable Tests, run those Tests against a chosen environment, and track resulting Bugs back to the requirement that failed. The domain model — `workspaces` → `projects` → `modules` → `user_stories` → `acceptance_criteria`, with `atcs` anchored to ≥1 acceptance criterion and `tests` composed of chained ATC references — encodes a strict traceability requirement from business requirement down to individual test run (Source: `supabase/migrations/0001_tenancy.sql` lines 1-9, `0002_projects_modules.sql` lines 1-11, `0003_authoring.sql` lines 1-9, `0004_atcs.sql` lines 1-14).

The product is explicitly built to be operated by more than just humans through a browser: the OpenAPI spec states it "wraps Supabase auth, ATC authoring, and run execution behind a versioned `/api/v1` surface. Designed to be operated by humans, scripts, CI/CD, and AI agents" (Source: `public/openapi.json` lines 4-10). This shows up structurally as dual auth (Supabase magic-link cookie session for the web app, bearer Personal Access Tokens scoped per-action for scripts/CI/agents) and an idempotency-key contract on write endpoints like Run creation (Source: `public/openapi.json` lines 42-52, lines 9541-9551).

A one-way Jira import (`POST /api/v1/imports`) lets a project pull in existing Jira stories rather than requiring teams to re-author their backlog inside Bunkai (Source: `public/openapi.json` lines 7965-7990). Traceability, coverage, and defect-heatmap reporting endpoints (`/api/v1/projects/{id}/traceability`, `/coverage`, `/bugs/heatmap`) indicate the problem being solved extends beyond "run tests" into "prove which requirements are covered and where quality risk concentrates" (Source: `public/openapi.json` lines 10636-10638, 10705-10707, 11091-11093).

---

## 2. Business Model Canvas

| Block | Content | Found in |
|---|---|---|
| **Customer Segments** | Software teams that need to manage manual/automated QA test coverage for their own products — organized as multi-tenant "workspaces," each with its own owner. Roles within a workspace (`viewer`, `member`, `admin`, `owner`) imply segments from read-only stakeholders to workspace administrators. | `supabase/migrations/0001_tenancy.sql` lines 43-44 (role check constraint); corroborated by `.context/PBI/epics/EPIC-BK-29-.../epic.md` line 26 ("Roles del sistema: viewer · member · admin · owner") |
| **Value Propositions** | (1) Requirement-to-test traceability enforced structurally, not by convention — an ATC cannot exist without linking to ≥1 acceptance criterion. (2) One test-authoring surface usable by a human in the browser AND by scripts/CI/AI agents via PAT-scoped API calls. (3) Import existing Jira backlogs instead of re-authoring user stories. (4) Manual test-run execution with per-step outcome tracking, environment binding, and idempotent replay-safe run creation. | `supabase/migrations/0004_atcs.sql` lines 1-14 (anchoring moat); `public/openapi.json` lines 4-10 (multi-actor design), lines 7965-7990 (Jira import), lines 9528-9562 (Run creation w/ idempotency) |
| **Channels** | Web application (Next.js App Router, magic-link login) and a versioned `/api/v1` REST API consumable by scripts/CI pipelines/AI agents via bearer PAT. | `public/openapi.json` lines 4-25 (servers + auth schemes); `app/(auth)/login`, `app/(app)/*` route folders confirmed on disk |
| **Customer Relationships** | Self-service: a user signs up via magic-link, is routed to `/onboarding` to create their own workspace and becomes its `owner`; workspace owners/admins self-serve teammate invitations (email + role) rather than going through any sales/support-assisted flow. | `.context/PBI/epics/EPIC-BK-29-.../epic.md` lines 28-32; `supabase/migrations/0010_workspace_invites.sql` lines 1-11 (self-service invite flow) |
| **Revenue Streams** | Unknown — requires user input. A `workspaces.plan` column exists with a check constraint restricting values to `community`, `cloud`, `enterprise`, suggesting a tiered-plan model was designed for, but no billing/payment provider (Stripe, Paddle, LemonSqueezy, PayPal) appears anywhere in `package.json` dependencies, and no plan-gating logic was found in the migrations read. Cannot confirm this is a monetized product today. | `supabase/migrations/0001_tenancy.sql` lines 32-34 (plan column + check); absence confirmed via `package.json` dependency grep |
| **Key Resources** | Supabase-hosted PostgreSQL (with Row-Level Security as the tenant-isolation mechanism on every table), Next.js/Vercel hosting, and the OpenAPI-documented `/api/v1` surface itself as a reusable integration asset. | `supabase/migrations/0001_tenancy.sql` lines 60-61 and throughout (RLS enabled + workspace-scoped policies on every table read); `public/openapi.json` servers block (Vercel-hosted staging/production URLs) |
| **Key Activities** | Authoring user stories + acceptance criteria; authoring/versioning ATCs (with full-text search over title+tags); composing ATCs into ordered, taggable Tests; executing Runs against a Project Environment with per-step pass/fail marking; filing Bugs (run-linked or standalone) and tracking their status/assignment; producing coverage, traceability, and defect-heatmap reports. | `supabase/migrations/0004_atcs.sql` (ATC authoring + search), `0024_tests.sql` (Test/chain authoring), `0031_runs.sql` + `public/openapi.json` `/api/v1/runs*` + `/api/v1/runs/{id}/steps/{stepId}/mark` (execution), `0046_bugs.sql` + `/api/v1/bugs*` (defect tracking), `/api/v1/projects/{id}/{coverage,traceability}` + `/bugs/heatmap` (reporting) |
| **Key Partners** | Supabase (auth + Postgres + realtime, `@supabase/supabase-js` + `@supabase/ssr` deps), Vercel (hosting, per the OpenAPI `servers` URLs), Jira/Atlassian (one-way import source only — Bunkai imports FROM Jira, no evidence of syncing back), Scalar (`@scalar/api-reference-react` dep, renders the public API-reference UI). | `package.json` dependencies lines 59-60, 58; `public/openapi.json` servers block lines 12-25; `public/openapi.json` lines 7965-7990 (Jira import) |
| **Cost Structure** | Unknown — requires user input. Inferred only: Supabase project hosting + Vercel hosting are the visible infra dependencies; no team/headcount, support, or marketing cost signal exists in code. | Inferred from Key Resources / Key Partners rows above — not independently evidenced, kept separate per the "Found in" rule |

---

## 3. Discovery Gaps

- **Revenue model unconfirmed.** `workspaces.plan` (`community`/`cloud`/`enterprise`) exists in schema but no payment/billing integration or plan-gating logic was found in the 8 migrations read (30 total migrations exist; not all were read — a full sweep could surface gating logic missed here).
- **Cost Structure unconfirmed.** No team size, support cost, or non-infra cost signal exists in the codebase; this block is necessarily Unknown from code alone.
- **Target customer profile unconfirmed.** No landing page, pricing page, or marketing copy exists in this repo to state who Bunkai TMS is being sold to (internal QA teams? external SaaS customers? both?). Customer Segments above is inferred purely from the RBAC model (workspace + 4 roles), not from any stated ICP.
- **"Community" vs "Cloud" vs "Enterprise" plan distinctions unconfirmed.** The check-constraint values imply a self-hosted vs. hosted split (matching the migration 0001 comment "self-hosted (Phase 2) safety" at line 15) but no code path implementing differentiated behavior per plan was found in the files read.
- **README.md / CONTEXT.md are explicitly NOT usable as sources** — they document a different, unrelated meta-framework shipped in the same repo. Excluding them was a deliberate scoping decision for this document, not an oversight.
- **Full `app/(app)/*` and `app/api/v1/*` page-level content not read** — only directory listings were used to confirm the feature surface named in the OpenAPI spec; individual page components were not opened.

---

## 4. QA Relevance

| Business aspect | Testing implication |
|---|---|
| Multi-tenant workspaces with RLS-enforced isolation on every table | Test tenant isolation explicitly — a user in Workspace A must never read/write Workspace B's projects, ATCs, Tests, Runs, or Bugs, even via direct API/PAT calls. |
| 4-tier role model (`viewer`/`member`/`admin`/`owner`) with per-endpoint role gates | Every write endpoint needs negative tests per role — confirm `viewer` is read-only everywhere, confirm `member` cannot perform admin-only actions (e.g., inviting teammates, revoking invites). |
| ATC "anchoring moat" (an ATC must link to ≥1 acceptance criterion) | Test that ATC creation is rejected when zero acceptance criteria are linked, and that deleting the last linked AC is blocked or cascades correctly. |
| Dual auth (cookie session for browser, scoped PAT for API/CI/agents) | Test both auth paths independently per endpoint; test PAT scope enforcement (a `atc:write`-scoped token must not succeed against `run:execute`-only routes). |
| Idempotency-Key contract on Run creation (24h same-token replay window) | Test replay-safety: same idempotency key + same payload returns the stored response; same key + different payload returns 409; verify the 24h boundary. |
| Run/Test/ATC snapshot-on-run semantics (Tests reference ATCs live; Runs snapshot them at execution time) | Test that editing an ATC after a Run has started does not retroactively change that Run's recorded steps — the snapshot must be immutable. |
| One-way Jira import (async job, one active import per project) | Test the 409 "one active import per project" gate, and test idempotent re-run behavior explicitly called out in the spec. |
| Coverage / traceability / defect-heatmap reporting endpoints | Test report accuracy against known fixture data — these are aggregate/derived views, prone to silent drift from the underlying entity tables as schema evolves. |
| Workspace invite flow (token issued, hashed, redeemed once, 7-day expiry) | Test invite expiry, revocation, and re-use-after-accept rejection — token reuse is a common security-relevant regression surface. |
| Plan tiers exist in schema but no confirmed billing enforcement | Flag as an open question before assuming any plan-based feature gating needs testing — do not write tests against unconfirmed billing logic. |

---

## 5. Sources Used

- `public/openapi.json` — Bunkai TMS API spec (title, description, servers, security schemes, all `/api/v1/*` paths + tags, `ErrorEnvelope` schema)
- `supabase/migrations/0001_tenancy.sql` — workspaces, workspace_members, roles, RLS strategy
- `supabase/migrations/0002_projects_modules.sql` — projects, modules (self-referential tree, depth ≤ 6)
- `supabase/migrations/0003_authoring.sql` — user_stories, acceptance_criteria
- `supabase/migrations/0004_atcs.sql` — atcs, atc_steps, atc_assertions, atc_acceptance_criteria (anchoring moat)
- `supabase/migrations/0010_workspace_invites.sql` — self-service teammate invite flow
- `supabase/migrations/0024_tests.sql` — tests, test_steps (ATC chain composition)
- `supabase/migrations/0030_test_tags.sql` — Test tagging (`smoke`/`sanity`/`regression` reserved tags)
- `supabase/migrations/README.md` directory listing (all 30 migration filenames, used to identify `0031_runs.sql`, `0046_bugs.sql` etc. as evidence sources for activities not deep-read)
- `package.json` (target repo) — dependency list confirming Supabase/Vercel/Scalar, absence of any billing provider
- `.context/PBI/epics/EPIC-BK-29-bunkai-tms-credenciales-de-acceso-para-testing-db-/epic.md` — corroborates environments, magic-link auth, roles (viewer/member/admin/owner), self-service onboarding-to-owner flow
- `.context/project-config.md` — corroborates stack (Next.js 15 + Supabase), repo paths
- Directory listings of `app/api/v1/*`, `app/(app)/*`, `app/(auth)/*` — confirms feature surface matches OpenAPI tags

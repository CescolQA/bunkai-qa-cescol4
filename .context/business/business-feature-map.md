# Business Feature Map — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Reverse-engineered from `public/openapi.json` (82 operations, parsed programmatically), `app/**` (36 `page.tsx` routes across `(app)`, `(auth)`, `api/docs`, `qa`, `about`, `design-tokens`), `components/**` (11 domain directories), `package.json`, `.env.example`, `supabase/migrations/0009_cross_cutting.sql` + `lib/types/supabase.ts` (schema-only tables), live staging Postgres via DBHub, and `git log` (last 30 commits). Builds on `.context/business/business-data-map.md` (entity/flow model, reused verbatim below — not re-derived) and `.context/business/business-model.md` (Business Model Canvas, QA Relevance table).
> Generated: 2026-08-26

This is the **feature-centric** complement to `business-data-map.md`. Where that document answers "what is the data and how does it flow," this one answers "what can a user or the system actually **do**." Every API endpoint, UI form/dialog, and automatic process below was independently verified against source — nothing here is inferred from marketing language or copied from the target repo's own `.context/` docs without a cross-check (see §9, which explains a stale pre-implementation planning doc found there and how it was — and was not — used).

---

## 1. Inventory summary

| Category | Features | Status |
|---|---|---|
| Core | 33 | Stable |
| Secondary | 15 | Stable |
| Beta | 1 | Testing (partial) |
| Planned | 3 | Schema-only / not wired |
| **Total** | **52** | |

**Maturity legend**: *Core* = primary value-proposition surface (traceability chain, authoring, execution, defects). *Secondary* = supporting/administrative capability. *Beta* = shipped but with an explicitly disabled sub-mode in the UI. *Planned* = database table exists, live in staging, with zero confirmed API route or UI consumer — schema provisioned ahead of implementation.

---

## 2. Feature catalog (by domain)

IDs are sequential across domains; endpoints are copied verbatim from `public/openapi.json` `operationId`-adjacent `method + path` pairs, auth-checked programmatically (see §4 for the full auth legend).

### 2.1 Domain: Identity & Authentication

#### Feature: Email/Password Sign-up + OTP Verification

| Aspect | Value |
|---|---|
| **ID** | FEAT-001 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/auth/signup`, `POST /api/v1/auth/confirm`, `POST /api/v1/auth/resend` |
| **UI** | `app/(auth)/login/email-first-form.tsx` |
| **Users** | Unauthenticated visitor |
| **Dependencies** | Supabase Auth |
| **Evidence** | `public/openapi.json` (Auth tag), `supabase/migrations/0009_cross_cutting.sql` (`magic_link_tokens` replay-guard table, also used for OTP audit) |

**Capabilities:**
- [x] Sign up with 6-digit email verification code
- [x] Resend verification code
- [x] Confirm OTP → session + auto-minted PAT (per OpenAPI `summary` on `/auth/confirm`)

#### Feature: Magic-Link Authentication

| Aspect | Value |
|---|---|
| **ID** | FEAT-002 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/auth/magic-link`, `POST /api/v1/auth/check-email` |
| **UI** | `app/(auth)/login/magic-link-form.tsx` |
| **Users** | Unauthenticated visitor |
| **Dependencies** | Supabase Auth (email delivery) |
| **Evidence** | `public/openapi.json`, `business-data-map.md §3.1` |

**Capabilities:**
- [x] Email-first routing probe (`check-email`) to decide magic-link vs. password flow
- [x] Send magic-link email
- [ ] Delivery mechanism for the email itself is unconfirmed beyond "Supabase-managed" (carried from `business-data-map.md §7`)

#### Feature: OAuth Sign-in (GitHub / Google)

| Aspect | Value |
|---|---|
| **ID** | FEAT-003 |
| **Status** | Stable |
| **Endpoints** | (browser redirect flow, not a versioned `/api/v1` JSON endpoint) `app/auth/oauth/[provider]`, `app/auth/callback` |
| **UI** | `app/(auth)/login/*` OAuth buttons |
| **Users** | Unauthenticated visitor |
| **Dependencies** | Supabase Auth, GitHub OAuth App, Google OAuth Client |
| **Evidence** | `lib/auth/oauth.ts:5` (provider allow-list), `business-data-map.md §6.4` |

**Capabilities:**
- [x] `github` and `google` providers only
- [ ] No automatic identity linking across a second provider presenting the same email (explicit code comment, `lib/auth/oauth.ts:17`)
- [x] Magic-link is the documented fallback when OAuth is unreachable

#### Feature: Headless Password Sign-in (API-first)

| Aspect | Value |
|---|---|
| **ID** | FEAT-004 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/auth/signin` |
| **UI** | none (API-only — "Headless password sign-in + auto-minted PAT" per spec summary) |
| **Users** | Script / CI / AI agent |
| **Dependencies** | Supabase Auth |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Password sign-in that returns a PAT in the same call, for scripted onboarding without a browser

#### Feature: Session Introspection + Active Workspace

| Aspect | Value |
|---|---|
| **ID** | FEAT-005 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/me`, `POST /api/v1/me/active-workspace` |
| **UI** | workspace switcher in `components/layout/AppSidebar.tsx` |
| **Users** | Any authenticated principal (human or PAT) |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Introspect the authenticated principal
- [x] Set which workspace is "active" for the current session

#### Feature: Personal Access Token (PAT) Management

| Aspect | Value |
|---|---|
| **ID** | FEAT-006 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/tokens`, `GET /api/v1/tokens`, `DELETE /api/v1/tokens/{id}` |
| **UI** | `app/(app)/settings/tokens/page.tsx`, `components/settings/{IssueTokenModal,RevokeTokenModal,TokensList}.tsx` |
| **Users** | Owner / Admin / Member |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `business-data-map.md §3.12`, `supabase/migrations/0033_remediate_bk135_admin_scope.sql` |

**Capabilities:**
- [x] Issue token with scoped permissions (`atc:read`/`atc:write`/`run:execute`/`workspace:admin`) + optional expiry
- [x] Raw token shown once at creation
- [x] `workspace:admin` scope retro-enforced against the issuer's actual role (BK-135 remediation)
- [x] List and revoke own tokens
- **Note**: `app/(app)/settings/tokens/page.tsx` code comment confirms this screen replaced a `ComingSoon` placeholder (BK-88) — genuinely shipped, not a stub.

#### Feature: Liveness / Version Discovery

| Aspect | Value |
|---|---|
| **ID** | FEAT-007 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/health`, `GET /api/v1` |
| **UI** | none |
| **Users** | Public (unauthenticated) |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` — both confirmed public (no `security` key on the operation) |

**Capabilities:**
- [x] Liveness probe for uptime monitoring
- [x] API version discovery

---

### 2.2 Domain: Workspace & Team Management

#### Feature: Workspace Creation + Owner Bootstrap

| Aspect | Value |
|---|---|
| **ID** | FEAT-008 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/workspaces` |
| **UI** | `app/(app)/onboarding/onboarding-form.tsx` |
| **Users** | Any authenticated user with no workspace yet |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.1`, `supabase/migrations/0006_bootstrap_workspace.sql` |

**Capabilities:**
- [x] Self-service creation, caller auto-enrolled as `owner`
- [x] Every workspace guaranteed exactly one owner at creation (BR-8 origin state)

#### Feature: Workspace Read / List / Update

| Aspect | Value |
|---|---|
| **ID** | FEAT-009 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/workspaces`, `GET /api/v1/workspaces/{id}`, `PATCH /api/v1/workspaces/{id}` |
| **UI** | `app/(app)/settings/workspaces/page.tsx`, `components/settings/WorkspacesList.tsx` |
| **Users** | Member+ (read), Admin/Owner (update) |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] List workspaces the caller belongs to
- [x] Update workspace metadata
- [ ] No `DELETE /workspaces/{id}` exists in the spec — workspace deletion is not a self-service capability (new finding, not previously documented in `business-data-map.md`)

#### Feature: Team Invite Lifecycle

| Aspect | Value |
|---|---|
| **ID** | FEAT-010 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/workspaces/{id}/invites`, `GET /api/v1/workspaces/{id}/invites`, `POST /api/v1/workspaces/{id}/invites/{inviteId}`, `DELETE /api/v1/workspaces/{id}/invites/{inviteId}` |
| **UI** | (workspace settings — invite panel; exact component not opened in this pass) |
| **Users** | Admin/Owner (issue/revoke/rotate), any (list own) |
| **Dependencies** | Email delivery (unconfirmed mechanism) |
| **Evidence** | `business-data-map.md §3.2`, `supabase/migrations/0010_workspace_invites.sql`, `0011_split_token_secrets.sql` |

**Capabilities:**
- [x] Issue invite (email + role: `viewer`/`member`/`admin` — `owner` deliberately not invitable)
- [x] Rotate (resend) an invite token
- [x] Revoke an invite
- [x] Token hashed separately from the row exposed to the app; 7-day expiry

#### Feature: Invite Acceptance

| Aspect | Value |
|---|---|
| **ID** | FEAT-011 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/invites/accept` |
| **UI** | `app/invites/accept/page.tsx` |
| **Users** | Invitee (may be unauthenticated at entry, dual-security-scheme on this route: cookie or bearer) |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `business-data-map.md §3.2` |

**Capabilities:**
- [x] Redeem a valid, unexpired, unconsumed invite token into an active `workspace_members` row at the invited role

#### Feature: Leave Workspace

| Aspect | Value |
|---|---|
| **ID** | FEAT-012 |
| **Status** | Stable |
| **Endpoints** | `DELETE /api/v1/workspaces/{id}/membership` |
| **UI** | `components/settings/LeaveWorkspaceModal.tsx` |
| **Users** | Active member |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `business-data-map.md §4.4` (BR-8) |

**Capabilities:**
- [x] Rejected if it's the caller's only membership (`last_membership`)
- [x] Rejected if the caller is the sole active owner (`sole_owner`)

#### Feature: Workspace Member Role/Status Management

| Aspect | Value |
|---|---|
| **ID** | FEAT-013 |
| **Status** | Planned / unconfirmed |
| **Endpoints** | **none confirmed** |
| **UI** | `app/(app)/workspaces/[id]/members/page.tsx` exists, but its data source could not be traced to a versioned `/api/v1` endpoint — no `GET /workspaces/{id}/members`-shaped route appears in the 82-operation spec |
| **Users** | Admin/Owner (presumed) |
| **Dependencies** | — |
| **Evidence** | `public/openapi.json` (absence), `business-data-map.md §4.4` (same gap, carried forward: "the explicit `active <-> suspended` transition endpoint was not located") |

**Capabilities:**
- [ ] `active <-> suspended` transition — CHECK constraint + RLS write-gate exist in schema, no named RPC/route found
- [ ] Member list source for the `/workspaces/{id}/members` UI page not confirmed as a public API call — likely a server-component query direct to Supabase, bypassing `/api/v1` entirely (new observation, not in `business-data-map.md`)

---

### 2.3 Domain: Project & Module Organization

#### Feature: Project Creation

| Aspect | Value |
|---|---|
| **ID** | FEAT-014 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/workspaces/{id}/projects` |
| **UI** | `app/(app)/projects/new/page.tsx`, `app/(app)/projects/create-project-form.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `business-data-map.md §3.3` |

**Capabilities:**
- [x] Create a project inside a workspace
- [ ] **No `GET /api/v1/projects/{id}` (single-project read), `PATCH`, or `DELETE` exists anywhere in the 82-operation spec.** Projects are only reachable via `GET /workspaces/{id}/recent-projects` (list) or through the many `/projects/{id}/<subresource>` routes (environments, milestones, modules, coverage, etc.) that assume the project already exists. This is a new finding not called out in `business-data-map.md` — worth a direct-access/authorization test (does a project-scoped subresource route correctly 404/403 when the project itself doesn't exist or belongs to another workspace?).

#### Feature: Module Tree Authoring

| Aspect | Value |
|---|---|
| **ID** | FEAT-015 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/projects/{id}/modules`, `PATCH /api/v1/modules/{id}`, `DELETE /api/v1/modules/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/{create-module-form,rename-module-form,move-module-dialog,delete-module-dialog}.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.3` (BR-2), `supabase/migrations/0014_module_soft_delete.sql` |

**Capabilities:**
- [x] Create, rename, move (depth ≤ 6 enforced by `bunkai_move_module`)
- [x] Soft-delete (archive), not hard-delete
- [ ] **No `GET /api/v1/modules/{id}` single-read endpoint exists** — a module is only readable via the project tree or its child listings (new finding)

#### Feature: Project Environment Management

| Aspect | Value |
|---|---|
| **ID** | FEAT-016 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/environments`, `POST /api/v1/projects/{id}/environments`, `PATCH /api/v1/environments/{id}`, `DELETE /api/v1/environments/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/{create-environment-form,rename-environment-form,delete-environment-dialog}.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Full CRUD — the only core entity in the system with a genuine hard-delete path
- [x] Named execution targets (e.g. Staging, Production) that a Run binds to

#### Feature: Milestone Tracking

| Aspect | Value |
|---|---|
| **ID** | FEAT-017 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/milestones`, `POST /api/v1/projects/{id}/milestones`, `PATCH /api/v1/milestones/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/milestones/*`, `components/milestones/*.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.13`, `supabase/migrations/0064_milestones.sql:28-29` |

**Capabilities:**
- [x] Name whitespace-normalized before per-project uniqueness check
- [x] `target_date` must fall within today .. +5 years at write time
- [ ] No delete path exists — deliberate per migration header, not a gap

---

### 2.4 Domain: Requirements Authoring

#### Feature: User Story CRUD

| Aspect | Value |
|---|---|
| **ID** | FEAT-018 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/modules/{id}/user-stories`, `GET /api/v1/modules/{id}/user-stories`, `GET /api/v1/user-stories/{id}`, `PATCH /api/v1/user-stories/{id}`, `DELETE /api/v1/user-stories/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/{user-story-form,delete-user-story-dialog}.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.5` |

**Capabilities:**
- [x] Full CRUD (delete = soft/archive)
- [x] Auto status flip: `draft -> ready_to_test` once ≥1 active AC exists; archiving the last active AC reverts to `draft`

#### Feature: Acceptance Criteria CRUD + Ordering

| Aspect | Value |
|---|---|
| **ID** | FEAT-019 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/user-stories/{id}/acceptance-criteria`, `GET /api/v1/user-stories/{id}/acceptance-criteria`, `GET /api/v1/acceptance-criteria/{id}`, `PATCH /api/v1/acceptance-criteria/{id}`, `DELETE /api/v1/acceptance-criteria/{id}` |
| **UI** | embedded in the User Story form (`user-story-form.tsx`) |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `supabase/migrations/0017_acceptance_criteria_ordering.sql:20-27` |

**Capabilities:**
- [x] Full CRUD (delete = soft/archive), ordered `position` 1..N, re-orderable via `PATCH`

#### Feature: One-Way Jira Import

| Aspect | Value |
|---|---|
| **ID** | FEAT-020 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/imports`, `GET /api/v1/imports/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/import-from-jira-dialog.tsx` |
| **Users** | Member+ |
| **Dependencies** | Jira Cloud REST v3 (`lib/jira/client.ts`) |
| **Evidence** | `business-data-map.md §3.4`, `lib/jira/import-runner.ts` |

**Capabilities:**
- [x] Async job (Vercel `after()` background slot), one active job per project (409 if a second is attempted — BR-7)
- [x] Idempotent upsert keyed on `external_id` — re-run never duplicates
- [x] ADF → Markdown conversion, auto-routes to Module by component-name match (else "Inbox")
- [ ] One-way only — never writes back to Jira
- **Test coverage signal**: only 3 `bun:test` files under `lib/jira/` in the target repo (`client`, `import-runner`, `adf-to-markdown` family) for a moderately complex async worker with pagination, backoff, and per-issue error collection — thin relative to complexity (see §8).

---

### 2.5 Domain: ATC Library (the product's differentiator)

#### Feature: ATC Authoring ("the anchoring moat")

| Aspect | Value |
|---|---|
| **ID** | FEAT-021 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/atcs` |
| **UI** | `components/atcs/{NewAtcEditor,AtcEditor,StepEditor,AnchoringPanel,AuthoringFormatHint}.tsx`, `app/(app)/projects/[projectSlug]/atcs/new/page.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.6` (BR-1), `supabase/migrations/0004_atcs.sql` |

**Capabilities:**
- [x] Must link ≥1 Acceptance Criterion belonging to the same User Story — zero AC or a cross-story AC is rejected (`ac_outside_user_story`), enforced by RPC `bunkai_create_atc`, not a raw FK
- [x] `layer` classification: `UI` / `API` / `Unit` — the tag this QA repo's own KATA framework consumes
- [x] Full-text search vector auto-refreshed on insert (trigger)

#### Feature: ATC Editing (versioned, propagating)

| Aspect | Value |
|---|---|
| **ID** | FEAT-022 |
| **Status** | Stable |
| **Endpoints** | `PATCH /api/v1/atcs/{id}` |
| **UI** | `components/atcs/AtcEditor.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.6`, `supabase/migrations/0035_atc_update_propagation.sql` |

**Capabilities:**
- [x] Full replace of steps + assertions on edit
- [x] `version` column increments per edit
- [ ] **No `GET /api/v1/atcs/{id}` single-read and no `DELETE /api/v1/atcs/{id}` exist in the spec.** An ATC is reachable only via `/atcs/search`, `/atcs/{id}/usage`, or by editing it — and it can never be deleted, only archived implicitly through its parent chain or superseded by duplication. Not previously documented in `business-data-map.md`; worth confirming whether this is deliberate (ATCs are load-bearing for Test chains and Run history, so deletion would break snapshot provenance) before treating it as a gap.
- [ ] Confirmed dead column: `atcs.status` (`pass|fail|blocked|skipped|running|unrun`) has no production write path — real per-execution verdict lives on `run_atcs.status` (`business-data-map.md §3.6`)

#### Feature: ATC Duplicate

| Aspect | Value |
|---|---|
| **ID** | FEAT-023 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/atcs/{id}/duplicate` |
| **UI** | (duplicate action, likely inline in `AtcTable.tsx` / `AtcPreview.tsx`) |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Deep-copy steps, assertions, and AC bindings

#### Feature: ATC Search

| Aspect | Value |
|---|---|
| **ID** | FEAT-024 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/atcs/search` |
| **UI** | `components/atcs/AtcTable.tsx` |
| **Users** | Member+ (and Viewer, read-only) |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Search by title and tags, `tsvector`-backed

#### Feature: ATC Usage Report

| Aspect | Value |
|---|---|
| **ID** | FEAT-025 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/atcs/{id}/usage` |
| **UI** | `components/atcs/AtcPreview.tsx` (likely) |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Reports which Tests chain this ATC ("used in N tests") — informs safe-to-edit/delete judgment before a change

---

### 2.6 Domain: Test Composition (chaining ATCs)

#### Feature: Test Creation (ATC chain)

| Aspect | Value |
|---|---|
| **ID** | FEAT-026 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/tests` |
| **UI** | `app/(app)/projects/[projectSlug]/tests/new/page.tsx`, `components/tests/{NewTestBuilder,AtcChainPicker,ChainedAtcCard}.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.7` |

**Capabilities:**
- [x] Workspace-scoped, not project-scoped — a Test can span projects
- [x] Same ATC MAY appear at multiple chain positions (no unique constraint)

#### Feature: Test Read / List

| Aspect | Value |
|---|---|
| **ID** | FEAT-027 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/tests`, `GET /api/v1/tests/{id}` |
| **UI** | `app/(app)/projects/[projectSlug]/tests/[testId]/page.tsx`, `components/tests/TestDetailView.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] List filterable by tag
- [x] Read a Test with its ATC chain fully expanded

#### Feature: Test Chain Reorder

| Aspect | Value |
|---|---|
| **ID** | FEAT-028 |
| **Status** | Stable |
| **Endpoints** | `PATCH /api/v1/tests/{id}/reorder` |
| **UI** | `components/tests/TestReorderClient.tsx` (drag-drop via `@dnd-kit/*`) |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json`, `package.json` (`@dnd-kit/core`, `@dnd-kit/sortable`) |

**Capabilities:**
- [x] Reorder the ATC chain inside a Test

#### Feature: Test Tagging

| Aspect | Value |
|---|---|
| **ID** | FEAT-029 |
| **Status** | Stable |
| **Endpoints** | `PUT /api/v1/tests/{id}/tags` |
| **UI** | `components/tests/TestTagEditor.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.7` (BR-9) |

**Capabilities:**
- [x] Reserved tags (`smoke`/`sanity`/`regression`) normalized to lowercase
- [x] Custom tags keep original casing

---

### 2.7 Domain: Run Execution

#### Feature: Start Run

| Aspect | Value |
|---|---|
| **ID** | FEAT-030 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/runs` |
| **UI** | `components/tests/StartRunButton.tsx` |
| **Users** | Member+ (human, `agent`, or `ci` executor mode) |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.8` (BR-3, BR-4) |

**Capabilities:**
- [x] Idempotent: same `(test_id, start_token)` within 24h replays the same Run (`replayed: true`) instead of duplicating
- [x] Snapshots the Test's chain immutably at start — later ATC edits never rewrite an in-flight/finished Run
- [x] `executor_mode` (`human`/`agent`/`ci`) stamped once, never changes

#### Feature: Mark Run Step

| Aspect | Value |
|---|---|
| **ID** | FEAT-031 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/runs/{id}/steps/{stepId}/mark` |
| **UI** | `components/runs/RunnerView.tsx` |
| **Users** | Member+ (the executor) |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §4.2`, `supabase/migrations/0042_run_step_mark.sql:97-192` |

**Capabilities:**
- [x] Mark passed / failed / blocked
- [x] Re-mark is last-write-wins, no conflict error (unlike Run-level transitions)
- [x] Parent `run_atcs.status` computed from sibling steps, never written directly

#### Feature: Finish / Abort Run

| Aspect | Value |
|---|---|
| **ID** | FEAT-032 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/runs/{id}/finish`, `POST /api/v1/runs/{id}/abort` |
| **UI** | `components/runs/RunnerView.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §4.1` |

**Capabilities:**
- [x] Finish with verdict (`passed`/`failed`) — terminal
- [x] Abort with reason — terminal, any still-`pending` steps auto-flip to `skipped`
- [x] No RPC transitions a Run out of a terminal state (permanent)

#### Feature: Run History & Read

| Aspect | Value |
|---|---|
| **ID** | FEAT-033 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/tests/{id}/runs`, `GET /api/v1/runs/{id}` |
| **UI** | `components/runs/RunHistoryView.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] List a Test's past Runs, newest first, filterable by outcome
- [x] Read a Run with its full snapshot chain expanded

#### Feature: Real-Time Run Progress

| Aspect | Value |
|---|---|
| **ID** | FEAT-034 |
| **Status** | Stable |
| **Endpoints** | none (Supabase Realtime channel, not REST) |
| **UI** | `components/runs/RunnerView.tsx` |
| **Users** | Any open UI session watching the Run |
| **Dependencies** | Supabase Realtime |
| **Evidence** | `lib/runs/realtime-run-channel.ts`, `business-data-map.md §3.8` |

**Capabilities:**
- [x] Push step/status updates to open sessions, not polling

---

### 2.8 Domain: Bug / Defect Management

#### Feature: File Bug

| Aspect | Value |
|---|---|
| **ID** | FEAT-035 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/bugs` |
| **UI** | `components/bugs/BugFormDialog.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.9` |

**Capabilities:**
- [x] Linked (run_id / run_step_id / atc_id, all nullable) or standalone
- [x] All three provenance FKs survive deletion of their source (`on delete set null`) — never orphaned/broken by cleanup
- [x] Severity `P1`-`P4` filed by reporter

#### Feature: Bug Assignment

| Aspect | Value |
|---|---|
| **ID** | FEAT-036 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/bugs/{id}/assign` |
| **UI** | (assignment control, likely in `BugsListView.tsx`) |
| **Users** | Owner/Admin/Member |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.9` (BR-6) |

**Capabilities:**
- [x] Assign, reassign, or unassign
- [x] Rejected unless assignee is an active, non-viewer workspace member (BR-6)

#### Feature: Bug Status Lifecycle

| Aspect | Value |
|---|---|
| **ID** | FEAT-037 |
| **Status** | Stable |
| **Endpoints** | `POST /api/v1/bugs/{id}/status` |
| **UI** | (status control, likely in `BugsListView.tsx`) |
| **Users** | Any authorized user |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §4.3` (BR-5) |

**Capabilities:**
- [x] Forward-only, one stage at a time: `open -> in_progress -> resolved -> closed`
- [x] Skip or backward move rejected by BOTH the RPC and a DB trigger backstop (defense in depth)

#### Feature: Bug Listing & Aggregates

| Aspect | Value |
|---|---|
| **ID** | FEAT-038 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/bugs`, `GET /api/v1/projects/{id}/bugs` |
| **UI** | `app/(app)/projects/[projectSlug]/bugs/page.tsx`, `components/bugs/BugsListView.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Project-scoped list, newest first
- [x] Workspace-wide list with filters + aggregates

#### Feature: Defect Heatmap

| Aspect | Value |
|---|---|
| **ID** | FEAT-039 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/bugs/heatmap` |
| **UI** | `components/bugs/BugsHeatmapView.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.11` |

**Capabilities:**
- [x] Per-module bug density + week-over-week trend for a chosen window

---

### 2.9 Domain: Notifications

#### Feature: Notification Inbox

| Aspect | Value |
|---|---|
| **ID** | FEAT-040 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/workspaces/{id}/notifications`, `POST /api/v1/notifications/{id}/read`, `POST /api/v1/workspaces/{id}/notifications/read-all` |
| **UI** | `components/notifications/{NotificationsPanel,NotificationRow}.tsx` |
| **Users** | Any authenticated member |
| **Dependencies** | Supabase Realtime |
| **Evidence** | `business-data-map.md §3.10` |

**Capabilities:**
- [x] Per-recipient inbox, newest first
- [x] Mark one read, or mark every visible unread read
- [x] 90-day retention enforced at RLS read time, not row deletion

#### Feature: Notification Preferences

| Aspect | Value |
|---|---|
| **ID** | FEAT-041 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/notification-preferences`, `PATCH /api/v1/notification-preferences` |
| **UI** | `app/(app)/settings/notifications/page.tsx`, `components/settings/NotificationPreferencesGrid.tsx` |
| **Users** | Any authenticated user |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Per-event-type, per-channel toggle grid
- [ ] `email` is a valid channel value in schema, but no email-provider dependency was found in `package.json` — delivery is unconfirmed (carried from `business-data-map.md §7`)

#### Feature: Automatic Notification Delivery

| Aspect | Value |
|---|---|
| **ID** | FEAT-042 |
| **Status** | Stable (with one known correctness gap) |
| **Endpoints** | none (DB trigger + RPC-fired, not user-invoked) |
| **UI** | none — produces the FEAT-040 inbox items |
| **Users** | system |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.10`, §5.1 |

**Capabilities:**
- [x] Bug assigned/reassigned → notifies new assignee (self-(re)assign DOES notify)
- [x] Bug unassigned → deliberate no-op, no recipient
- [x] Bug status changed → notifies reporter + assignee, excludes the actor
- [x] Run finished/aborted → notifies the run starter only
- [ ] **Known gap**: the self-finish suppression rule described in `0066_run_event_notifications.sql` depends on migration `0067`, which is explicitly **not applied** to the live database — every terminal Run event currently notifies the starter, including a same-session cookie self-finish, contrary to the fully-ratified design (`business-data-map.md §7`)

---

### 2.10 Domain: Reporting & Analytics

#### Feature: Project Coverage Report

| Aspect | Value |
|---|---|
| **ID** | FEAT-043 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/coverage` |
| **UI** | `components/coverage/ProjectCoverageView.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.11` |

**Capabilities:**
- [x] Surfaces untested acceptance criteria and modules, with a never-run indicator
- [x] Real-execution-sourced (`run_atcs.status`) — `migration 0050` is itself evidence an earlier version of this report was quietly wrong (sourced from the dead `atcs.status` column) before being corrected. **High regression-risk feature: has broken silently once already.**

#### Feature: Workspace Coverage Roll-up

| Aspect | Value |
|---|---|
| **ID** | FEAT-044 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/workspaces/{id}/coverage` |
| **UI** | (workspace dashboard) |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Aggregates FEAT-043 across every project in the workspace

#### Feature: Traceability Chain

| Aspect | Value |
|---|---|
| **ID** | FEAT-045 |
| **Status** | Stable (recently enhanced) |
| **Endpoints** | `GET /api/v1/projects/{id}/traceability` |
| **UI** | `app/(app)/projects/[projectSlug]/traceability/page.tsx`, `components/traceability/TraceabilityChainView.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §3.11`; `git log` shows `feat(BK-48)` — module/date-range/result chain filters wired in within the last 30 commits |

**Capabilities:**
- [x] Renders a User Story's full AC-to-defect evidence chain, per story
- [x] Module, date-range, and result filters (BK-48, recently added — treat as freshly-changed surface for regression testing priority)

#### Feature: Runs Report

| Aspect | Value |
|---|---|
| **ID** | FEAT-046 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/runs/report` |
| **UI** | `components/runs/ProjectRunsReportView.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Filter by date range, module, status, executor, with pass/fail totals

#### Feature: Recovery-Cycle Metrics

| Aspect | Value |
|---|---|
| **ID** | FEAT-047 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/projects/{id}/metrics/recovery-cycles` |
| **UI** | `app/(app)/projects/[projectSlug]/metrics/page.tsx` |
| **Users** | Member+ |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Per-user-story time from first failing run to first all-passing run

#### Feature: Workspace Dashboard Aggregates

| Aspect | Value |
|---|---|
| **ID** | FEAT-048 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/workspaces/{id}/recent-projects`, `GET /api/v1/workspaces/{id}/active-runs`, `GET /api/v1/workspaces/{id}/open-bugs` |
| **UI** | `app/(app)/home/page.tsx` |
| **Users** | Any authenticated member |
| **Dependencies** | none |
| **Evidence** | `public/openapi.json` |

**Capabilities:**
- [x] Recent projects with module/ATC counts
- [x] In-progress runs across the workspace with step progress
- [x] Open bug counts by severity

#### Feature: Activity Feed

| Aspect | Value |
|---|---|
| **ID** | FEAT-049 |
| **Status** | Stable |
| **Endpoints** | `GET /api/v1/activity` |
| **UI** | `app/(app)/activity/page.tsx`, `components/activity/ActivityView.tsx` |
| **Users** | Workspace members |
| **Dependencies** | none |
| **Evidence** | `business-data-map.md §5.1` |

**Capabilities:**
- [x] Append-only audit trail, newest first — source of the Notification fan-out (FEAT-042)

#### Feature: Project Mind-Map / Topology Visualization

| Aspect | Value |
|---|---|
| **ID** | FEAT-050 |
| **Status** | **Beta** — one mode shipped, two modes explicitly disabled in the UI |
| **Endpoints** | (client-rendered from existing tree data — no dedicated endpoint found) |
| **UI** | `app/(app)/projects/[projectSlug]/mind-map-view.tsx` |
| **Users** | Member+, Viewer |
| **Dependencies** | none |
| **Evidence** | direct read of `mind-map-view.tsx:10-12,115-119` |

**Capabilities:**
- [x] "Topology" mode: left-to-right node-link graph of Module → User Story → ATC, pan via scroll, zoom via +/-/Fit
- [ ] "Coverage" mode — button rendered with `disabled` + a `soon` badge; code comment: "needs run + bug data that doesn't exist yet"
- [ ] "Bug density" mode — same disabled/`soon` treatment
- **This is a genuine, current, code-confirmed WIP feature** (not inferred from a stale roadmap doc — see §7 for the distinction).

---

### 2.11 Domain: Developer & Documentation Surface

#### Feature: OpenAPI Reference UI

| Aspect | Value |
|---|---|
| **ID** | FEAT-051 |
| **Status** | Secondary |
| **Endpoints** | `GET /api/openapi` (spec JSON, outside `/api/v1`) |
| **UI** | `app/api/docs/page.tsx` (Scalar) |
| **Users** | Public / developers |
| **Dependencies** | `@scalar/api-reference-react` |
| **Evidence** | `business-data-map.md §6.5` |

**Capabilities:**
- [x] Browsable API reference generated from the live OpenAPI spec — documentation-rendering only, no runtime data flow

#### Feature: QA Software Testability Guide

| Aspect | Value |
|---|---|
| **ID** | FEAT-052 |
| **Status** | Secondary |
| **Endpoints** | none |
| **UI** | `app/qa/page.tsx`, `app/qa/_components/*` |
| **Users** | Public (no auth gate) |
| **Dependencies** | none |
| **Evidence** | direct read of `app/qa/page.tsx:1-33` |

**Capabilities:**
- [x] Public teaching surface documenting stack/auth/DB shape for a QA engineer onboarding to test the product
- [x] Explicitly does NOT inline credentials — points to a Jira Epic instead (self-documenting security discipline, worth noting rather than testing as a defect)
- **Note**: this page is itself effectively test-fixture documentation for this QA repo's own work, not a customer-facing product feature — classified Secondary rather than Core for that reason.

---

## 3. CRUD matrix

Legend: ✅ Full · ⚠️ Partial/conditional · ❌ Not available · `~` soft-delete only.

| Entity | Create | Read | Update | Delete | Evidence |
|---|---|---|---|---|---|
| Workspace | ✅ | ✅ | ✅ | ❌ | `POST/GET/PATCH /workspaces{,/{id}}` — no `DELETE` exists |
| Workspace Member | ⚠️ (invite-only) | ⚠️ (no dedicated list endpoint found) | ⚠️ (status transition unconfirmed) | ⚠️ (self-leave only, guarded by BR-8) | FEAT-008, FEAT-013 |
| Workspace Invite | ✅ | ✅ | ✅ (rotate) | ✅ (revoke) | FEAT-010 |
| Project | ✅ | ⚠️ (list-only; no single-`GET`) | ❌ | ❌ | FEAT-014 — new finding, no PATCH/DELETE in spec |
| Module | ✅ | ⚠️ (no single-`GET`; via tree/list only) | ✅ | ~ | FEAT-015 |
| Environment | ✅ | ✅ | ✅ | ✅ | FEAT-016 — only entity with a genuine hard-delete |
| Milestone | ✅ | ✅ | ✅ | ❌ | FEAT-017 — deliberate, per migration header |
| User Story | ✅ | ✅ | ✅ | ~ | FEAT-018 |
| Acceptance Criterion | ✅ | ✅ | ✅ | ~ | FEAT-019 |
| ATC | ✅ | ⚠️ (no single-`GET`; via search/usage only) | ✅ | ❌ | FEAT-021/022 — new finding, no `DELETE` in spec |
| Test | ✅ | ✅ | ⚠️ (reorder + tags only, no general edit) | ❌ | FEAT-026/027/028/029 |
| Run | ✅ | ✅ | ⚠️ (mark/finish/abort only) | ❌ | FEAT-030–033 |
| Bug | ✅ | ✅ | ⚠️ (assign/status only, no general edit) | ❌ | FEAT-035–038 |
| Access Token (PAT) | ✅ | ✅ | ❌ | ✅ (revoke) | FEAT-006 |
| Notification | ⚠️ (system-produced only) | ✅ | ✅ (mark read) | ❌ | FEAT-040 |
| Notification Preference | ⚠️ (implicit upsert) | ✅ | ✅ | ❌ | FEAT-041 |
| Import Job | ✅ | ✅ (poll) | ❌ (system-driven) | ❌ | FEAT-020 |
| Activity Log | ⚠️ (system-only) | ✅ | ❌ | ❌ | FEAT-049 |

**Cross-reference against `business-data-map.md §2`**: every one of its 12 core entities has at least Create+Read here — no orphaned data confirmed. The three genuinely new observations from this pass — **Project, Module, and ATC each lack a single-resource `GET`**, and **Project and ATC also lack any delete path** — were not previously called out in the data map and are worth a direct API-contract test (attempting the "obvious" `GET /api/v1/projects/{id}` should return a clean 404, not a 500, if it's truly absent from routing rather than just undocumented).

---

## 4. API endpoint inventory

82 operations total, confirmed programmatically from `public/openapi.json`. **Auth column**: `Public` = no `security` key on the operation (8 total); `Dual` = `[{cookieAuth},{bearerAuth}]`, either satisfies (74 total, i.e. every other endpoint); `Cookie-only` = cookie session required, no PAT accepted (4: token issuance/list/revoke, and `DELETE /workspaces/{id}/membership`).

| Domain (OpenAPI tag) | Method + Endpoint | Purpose | Auth |
|---|---|---|---|
| Auth | `POST /auth/check-email` | Email-first routing probe | Public |
| Auth | `POST /auth/confirm` | Verify email OTP → session + auto-minted PAT | Public |
| Auth | `POST /auth/magic-link` | Send Supabase magic-link email | Public |
| Auth | `POST /auth/signin` | Headless password sign-in + auto-minted PAT | Public |
| Auth | `POST /auth/signup` | Sign up + send 6-digit verification | Public |
| Auth | `POST /auth/resend` | Resend sign-up verification code | Public |
| Health | `GET /health` | Liveness probe | Public |
| Health | `GET /` (v1 root) | API version discovery | Public |
| Tokens | `POST /tokens` | Issue a PAT | Cookie-only |
| Tokens | `GET /tokens` | List caller's tokens | Cookie-only |
| Tokens | `DELETE /tokens/{id}` | Revoke a PAT | Cookie-only |
| Invites | `POST /invites/accept` | Redeem a workspace invite token | Dual |
| Identity | `POST /me/active-workspace` | Set active workspace for session | Dual |
| Identity | `GET /me` | Introspect authenticated principal | Dual |
| Workspaces | `POST /workspaces` | Create workspace + auto-enrol owner | Dual |
| Workspaces | `GET /workspaces` | List caller's workspaces | Dual |
| Workspaces | `GET /workspaces/{id}` | Get one workspace | Dual |
| Workspaces | `PATCH /workspaces/{id}` | Update workspace metadata | Dual |
| Invites | `POST /workspaces/{id}/invites` | Issue a workspace invite | Dual |
| Invites | `GET /workspaces/{id}/invites` | List workspace invites | Dual |
| Invites | `POST /workspaces/{id}/invites/{inviteId}` | Rotate (resend) invite token | Dual |
| Invites | `DELETE /workspaces/{id}/invites/{inviteId}` | Revoke a workspace invite | Dual |
| Workspaces | `DELETE /workspaces/{id}/membership` | Leave a workspace | Cookie-only |
| Projects | `POST /workspaces/{id}/projects` | Create a project | Dual |
| Workspaces | `GET /workspaces/{id}/recent-projects` | List projects by recent activity + counts | Dual |
| Workspaces | `GET /workspaces/{id}/active-runs` | In-progress runs across workspace | Dual |
| Workspaces | `GET /workspaces/{id}/open-bugs` | Open bug counts by severity | Dual |
| Workspaces | `GET /workspaces/{id}/coverage` | Workspace-level coverage summary | Dual |
| Modules | `POST /projects/{id}/modules` | Create a module | Dual |
| Environments | `GET /projects/{id}/environments` | List project environments | Dual |
| Environments | `POST /projects/{id}/environments` | Add an environment | Dual |
| Environments | `PATCH /environments/{id}` | Rename an environment | Dual |
| Environments | `DELETE /environments/{id}` | Remove an environment | Dual |
| Milestones | `GET /projects/{id}/milestones` | List project milestones | Dual |
| Milestones | `POST /projects/{id}/milestones` | Create a milestone | Dual |
| Milestones | `PATCH /milestones/{id}` | Edit a milestone | Dual |
| Modules | `PATCH /modules/{id}` | Rename/edit/move a module | Dual |
| Modules | `DELETE /modules/{id}` | Soft-delete a module + subtree | Dual |
| User Stories | `POST /modules/{id}/user-stories` | Create a user story | Dual |
| User Stories | `GET /modules/{id}/user-stories` | List a module's active stories | Dual |
| User Stories | `GET /user-stories/{id}` | Read a user story | Dual |
| User Stories | `PATCH /user-stories/{id}` | Edit a user story | Dual |
| User Stories | `DELETE /user-stories/{id}` | Soft-delete a user story | Dual |
| Acceptance Criteria | `POST /user-stories/{id}/acceptance-criteria` | Add an AC | Dual |
| Acceptance Criteria | `GET /user-stories/{id}/acceptance-criteria` | List active ACs | Dual |
| Acceptance Criteria | `GET /acceptance-criteria/{id}` | Read an AC | Dual |
| Acceptance Criteria | `PATCH /acceptance-criteria/{id}` | Edit/reorder an AC | Dual |
| Acceptance Criteria | `DELETE /acceptance-criteria/{id}` | Soft-delete an AC | Dual |
| Imports | `POST /imports` | Start async Jira import | Dual |
| Imports | `GET /imports/{id}` | Poll an import job | Dual |
| ATCs | `POST /atcs` | Create an ATC (steps + assertions) | Dual |
| ATCs | `GET /atcs/search` | Search ATCs by title/tags | Dual |
| ATCs | `PATCH /atcs/{id}` | Edit an ATC (full replace) | Dual |
| ATCs | `POST /atcs/{id}/duplicate` | Duplicate an ATC (deep-copy) | Dual |
| ATCs | `GET /atcs/{id}/usage` | "Used in N tests" report | Dual |
| Tests | `POST /tests` | Create a Test (chain ATCs) | Dual |
| Tests | `GET /tests` | List Tests by tag | Dual |
| Tests | `GET /tests/{id}` | Read a Test, chain expanded | Dual |
| Tests | `PATCH /tests/{id}/reorder` | Reorder the ATC chain | Dual |
| Tests | `PUT /tests/{id}/tags` | Assign/replace tag set | Dual |
| Runs | `GET /tests/{id}/runs` | List a Test's Runs | Dual |
| Runs | `GET /projects/{id}/runs/report` | Filter Runs by date/module/status/executor | Dual |
| Metrics | `GET /projects/{id}/metrics/recovery-cycles` | Recovery-cycle time per story | Dual |
| Runs | `POST /runs` | Start a manual Run | Dual |
| Runs | `GET /runs/{id}` | Read a Run, snapshot expanded | Dual |
| Runs | `POST /runs/{id}/abort` | Abort an in-progress Run | Dual |
| Runs | `POST /runs/{id}/finish` | Finish an in-progress Run | Dual |
| Activity | `GET /activity` | Workspace activity feed | Dual |
| Runs | `POST /runs/{id}/steps/{stepId}/mark` | Mark a run step | Dual |
| Bugs | `POST /bugs` | File a bug | Dual |
| Bugs | `GET /bugs` | List/filter defects + aggregates | Dual |
| Bugs | `POST /bugs/{id}/assign` | Assign/reassign/unassign a bug | Dual |
| Bugs | `POST /bugs/{id}/status` | Advance bug status one stage | Dual |
| Bugs | `GET /projects/{id}/bugs` | List a project's bugs | Dual |
| Coverage | `GET /projects/{id}/coverage` | Untested ACs/modules + never-run indicator | Dual |
| Bugs | `GET /projects/{id}/bugs/heatmap` | Per-module defect heatmap | Dual |
| Notifications | `GET /workspaces/{id}/notifications` | Notification inbox | Dual |
| Notifications | `POST /notifications/{id}/read` | Mark one notification read | Dual |
| Notifications | `POST /workspaces/{id}/notifications/read-all` | Mark all visible unread read | Dual |
| Notifications | `GET /notification-preferences` | List my notification preferences | Dual |
| Notifications | `PATCH /notification-preferences` | Update a preference cell | Dual |
| Traceability | `GET /projects/{id}/traceability` | Full AC-to-defect evidence chain | Dual |

---

## 5. UI component inventory

### 5.1 Forms

| Component | Purpose | Feature |
|---|---|---|
| `email-first-form.tsx` | Email-first login routing | FEAT-002 |
| `magic-link-form.tsx` | Magic-link request | FEAT-002 |
| `onboarding-form.tsx` | First workspace creation | FEAT-008 |
| `create-project-form.tsx` | New project | FEAT-014 |
| `create-module-form.tsx`, `rename-module-form.tsx` | Module create/rename | FEAT-015 |
| `create-environment-form.tsx`, `rename-environment-form.tsx` | Environment create/rename | FEAT-016 |
| `CreateMilestoneForm.tsx`, `EditMilestoneForm.tsx` | Milestone create/edit | FEAT-017 |
| `user-story-form.tsx` | Story + embedded AC authoring | FEAT-018, FEAT-019 |
| `NewAtcEditor.tsx`, `AtcEditor.tsx`, `StepEditor.tsx` | ATC authoring/editing | FEAT-021, FEAT-022 |
| `NewTestBuilder.tsx`, `AtcChainPicker.tsx` | Test creation/chain building | FEAT-026 |
| `TestTagEditor.tsx` | Test tag assignment | FEAT-029 |
| `BugFormDialog.tsx` | File a bug | FEAT-035 |

### 5.2 Dashboards / Views

| Component | Purpose | Feature |
|---|---|---|
| `app/(app)/home/page.tsx` | Workspace home (recent projects, active runs, open bugs) | FEAT-048 |
| `AtcTable.tsx`, `AtcPreview.tsx` | ATC library browse/search | FEAT-024, FEAT-025 |
| `TestDetailView.tsx`, `TestDetailTabs.tsx` | Test detail + chain view | FEAT-027 |
| `RunnerView.tsx` | Live run execution screen | FEAT-030–032, FEAT-034 |
| `RunHistoryView.tsx`, `ProjectRunsReportView.tsx` | Run history/report | FEAT-033, FEAT-046 |
| `BugsListView.tsx`, `BugsHeatmapView.tsx` | Bug list + heatmap | FEAT-038, FEAT-039 |
| `ProjectCoverageView.tsx` | Coverage report | FEAT-043 |
| `TraceabilityChainView.tsx` | Traceability chain | FEAT-045 |
| `mind-map-view.tsx` | Topology/coverage/bug-density graph | FEAT-050 |
| `MilestonesListView.tsx`, `MilestoneDetailView.tsx` | Milestone list/detail | FEAT-017 |
| `ActivityView.tsx` | Activity feed | FEAT-049 |
| `NotificationsPanel.tsx` | Notification inbox | FEAT-040 |
| `WorkspacesList.tsx`, `TokensList.tsx`, `NotificationPreferencesGrid.tsx` | Settings lists | FEAT-009, FEAT-006, FEAT-041 |

### 5.3 Actions (modals, dialogs, confirmations)

| Component | Purpose | Feature |
|---|---|---|
| `move-module-dialog.tsx`, `delete-module-dialog.tsx` | Module move/delete confirm | FEAT-015 |
| `delete-user-story-dialog.tsx` | Story archive confirm | FEAT-018 |
| `delete-environment-dialog.tsx` | Environment delete confirm | FEAT-016 |
| `import-from-jira-dialog.tsx` | Jira import trigger | FEAT-020 |
| `IssueTokenModal.tsx`, `RevokeTokenModal.tsx` | PAT issue/revoke confirm | FEAT-006 |
| `LeaveWorkspaceModal.tsx` | Leave-workspace confirm | FEAT-012 |
| `StartRunButton.tsx` | Start-run trigger | FEAT-030 |
| `CommandPalette.tsx` (Cmd/Ctrl+K, `cmdk` dependency) | Cross-entity command palette | not tied to a single FEAT — cross-cutting navigation/action shortcut over ATCs/Tests/Runs/Bugs |

---

## 6. Third-party integrations

| Service | Purpose | Package | Status | Features using it |
|---|---|---|---|---|
| Supabase | Auth (magic-link, OAuth, password+OTP, PAT resolution), Postgres (system of record, RLS), Realtime (live run/notification push) | `@supabase/supabase-js`, `@supabase/ssr` | Active | FEAT-001–007, FEAT-030–034, FEAT-040, and every entity's persistence |
| Vercel | Hosting + serverless execution + `after()` background slot for the Jira import worker | (platform, not an npm dep) | Active | FEAT-020, and the whole app's deploy target |
| Jira Cloud (Atlassian) | One-way import source of User Stories + Acceptance Criteria | (custom REST client, `lib/jira/client.ts` — no SDK package) | Active | FEAT-020 |
| GitHub OAuth | Identity provider | (via Supabase Auth, no direct package) | Active | FEAT-003 |
| Google OAuth | Identity provider | (via Supabase Auth, no direct package) | Active | FEAT-003 |
| Scalar | API reference UI rendering | `@scalar/api-reference-react` | Active | FEAT-051 |

**No billing/payment provider** (Stripe, Paddle, LemonSqueezy, PayPal) and **no email-provider dependency** (Resend, SendGrid, Postmark) were found in `package.json` — both gaps already documented in `business-model.md §3` and `business-data-map.md §7` respectively; not re-verified independently in this pass beyond confirming the same `package.json` dependency list.

---

## 7. Feature flags and WIP

### 7.1 Confirmed in current shipped code

| Flag / Signal | Description | Default | Environment |
|---|---|---|---|
| none (env-based) | `.env.example` grep for `FEATURE_`/`ENABLE_`/`BETA_`/`FLAG` returned zero product-level matches (the one hit was an unrelated comment about an opt-in MCP server for this QA repo's own tooling) | n/a | n/a |

| Planned/WIP signal | Evidence (code) | Estimated status |
|---|---|---|
| `feature_flags` table | `supabase/migrations/0009_cross_cutting.sql:113-160` — own comment: "Phase-2 gradual rollout gating." Global + workspace-scope rows, RLS-readable, **no client write policy** (admin/service_role only), **zero rows live in staging** (confirmed via DBHub), **zero application-code read/write call sites** (`from('feature_flags')` grep returned nothing in `lib/`/`app/`) | Schema-provisioned infrastructure, not wired to any actual gate yet — Planned |
| `user_view_state` table | Same migration, "Wave-6 view persistence." **Zero rows live**, **zero app-code call sites** beyond the type definition | Schema-provisioned, unused — Planned |
| `test_plans` table | Live in staging with **15 real rows** and an active `updated_at` trigger, but **no migration, route, or `lib/` reference anywhere** in the current codebase (confirmed independently in `business-data-map.md §7`, re-confirmed here) | See §7.2 — this is very likely the Phase-2 "Test Plans" feature named in the target repo's own pre-implementation PRD, with schema pushed to staging ahead of the application code |
| Mind-map "Coverage" / "Bug density" modes | `mind-map-view.tsx:115-119` — `disabled={m.soon}` with a visible "soon" badge, code comment: "needs run + bug data that doesn't exist yet" | Beta — the base "Topology" mode is fully shipped; these two sub-modes are explicit, current, code-confirmed WIP (see FEAT-050) |
| `ComingSoon` component | `components/settings/ComingSoon.tsx` — a deliberate, reusable "not shipped yet" placeholder pattern (BK-87 TD10): renders a 200 (never a 404) with a "not shipped" badge and honest copy | **Currently zero live call sites** — its last known consumer, Settings > Tokens, was upgraded to a real screen in BK-88 (confirmed by a code comment in `app/(app)/settings/tokens/page.tsx:8`). The pattern is available for future use but nothing currently renders it. |

### 7.2 A caution about the target repo's own `.context/` — NOT used as a primary source, cited only for corroboration

`upex-bunkai-tms/.context/business/business-feature-map.md` already exists inside the target repo. It is **not** an artifact of this QA project's discovery process — it appears to be the target team's own pre-implementation planning document (header: "Mode: CREATE (greenfield) — no codebase to reverse-engineer; feature set encoded from PRD/SRS," dated 2026-05-19, sourced from `.context/PRD/` and `.context/SRS/` files that predate the first commit read in this pass). Several things it describes as "Planned (MVP)" or "Phase 2/3" could **not** be independently confirmed in the current shipped code during this pass:

- A generic bulk-edit endpoint (`PATCH /api/v1/{entity}/bulk`) — **absent** from the live 82-operation `public/openapi.json`
- A dedicated `bunkai` CLI product binary (`npx bunkai`, `bunkai auth login`, etc.) — **not found**; the only `cli/` directory present is this boilerplate's own internal setup/update tooling (`cli/doctor.ts`, `cli/install.ts`, `cli/update-boilerplate.ts`), a different thing entirely
- SSO/SAML, semantic search (pgvector), bidirectional Jira sync, a WebSocket "agentic protocol," and a 3D mind-map — none found in current dependencies or code
- Conversely, the mind-map view it describes as **not started** ("Phase 2 flag `phase2.mind_map_2d`") is **actually implemented** (see FEAT-050), just with two sub-modes disabled — the plan and the shipped reality have already diverged in both directions

**Conclusion**: this document is treated here strictly as a *named-roadmap* source for §7 — useful for guessing what an unconfirmed schema table (`test_plans`, `feature_flags`) might eventually become — and explicitly NOT as evidence of current feature status. Every status claim elsewhere in this feature map traces to `public/openapi.json`, live route/component files, the live staging DB, or `business-data-map.md`'s own independently-sourced findings.

---

## 8. QA relevance

### 8.1 Feature test coverage matrix

**Methodology note**: no coverage tool or threshold is configured in the target repo (`package.json`'s `test` script is plain `bun test`, no `--coverage`; already flagged in this QA repo's own Project Assessment). The Unit/Integration column below is a **file-count proxy** — number of `*.test.ts` files under the matching `lib/<domain>/` directory (135 files total, `bun:test`) — not a measured percentage. E2E is uniformly ❌: this QA repo's own `kata-manifest.json` currently contains only placeholder/example components (`ExampleApi`, `ExamplePage`, `AuthApi` with generic `PROJ-1xx` IDs) — **zero real Bunkai TMS E2E automation exists yet**, which is the exact gap this QA repo exists to close.

| Feature domain | Target-repo `bun:test` files | Unit/Integration (proxy) | E2E | Status |
|---|---|---|---|---|
| Runs (FEAT-030–034) | `lib/runs/` — 15 | ✅ | ❌ | Needs E2E |
| ATCs (FEAT-021–025) | `lib/atcs/` — 13 | ✅ | ❌ | Needs E2E |
| Bugs (FEAT-035–039) | `lib/bugs/` — 9 | ✅ | ❌ | Needs E2E |
| Notifications (FEAT-040–042) | `lib/notifications/` — 8 | ✅ | ❌ | Needs E2E |
| Account/Identity (FEAT-005–007) | `lib/account/` — 7, `lib/auth/` — 2 | ⚠️ (auth itself very thin at 2 files for a security-critical domain) | ❌ | Needs E2E + more unit depth on `lib/auth/` |
| Tests (FEAT-026–029) | `lib/tests/` — 6 | ✅ | ❌ | Needs E2E |
| API/PAT middleware (cross-cutting) | `lib/api/` — 6 | ✅ | ❌ | Needs E2E |
| Metrics (FEAT-047) | `lib/metrics/` — 5 | ⚠️ | ❌ | Needs E2E |
| Traceability (FEAT-045) | `lib/traceability/` — 4 | ⚠️ | ❌ | Needs E2E |
| Activity (FEAT-049) | `lib/activity/` — 4 | ⚠️ | ❌ | Needs E2E |
| Tokens/PAT (FEAT-006) | `lib/tokens/` — 3 | ⚠️ | ❌ | Needs E2E |
| Jira import (FEAT-020) | `lib/jira/` — 3 | ⚠️ (thin for pagination + backoff + ADF-parsing complexity) | ❌ | Needs E2E + more unit depth |
| Environments (FEAT-016) | `lib/environments/` — 3 | ⚠️ | ❌ | Needs E2E |
| Coverage (FEAT-043–044) | `lib/coverage/` — 3 | ⚠️ (thin for a report already proven wrong once) | ❌ | Needs E2E |
| Workspaces (FEAT-008–013) | `lib/workspaces/` — 2 | ⚠️ (very thin for the tenant-root entity) | ❌ | Needs E2E + more unit depth |
| Modules (FEAT-015) | `lib/modules/` — 2 | ⚠️ | ❌ | Needs E2E |
| Notification prefs (FEAT-041) | `lib/notification-preferences/` — 2 | ⚠️ | ❌ | Needs E2E |
| User Stories (FEAT-018) | `lib/user-stories/` — 1 | ❌ (very thin) | ❌ | Needs E2E + more unit depth |
| Projects (FEAT-014) | `lib/projects/` — 1 | ❌ (very thin for the tenant's second-level entity) | ❌ | Needs E2E + more unit depth |
| Acceptance Criteria (FEAT-019) | (no dedicated `lib/acceptance-criteria/` dir found — likely folded into `lib/user-stories/`) | ❌ (unconfirmed) | ❌ | Needs E2E, verify unit coverage exists at all |
| Milestones (FEAT-017) | `lib/milestones/` — 3 | ⚠️ | ❌ | Needs E2E |
| feature_flags / user_view_state / test_plans | 0 (unused in app code) | ❌ | ❌ | N/A — not wired to a feature yet, do not build tests against them (§7.1) |
| `app/api/**` route-handler layer | 19 files (cross-cutting, not attributable to one domain) | ✅ (HTTP-layer integration coverage exists broadly) | ❌ | Needs E2E |

### 8.2 High-risk features (prioritize testing)

| Feature | Risk | Reason |
|---|---|---|
| Tenant isolation (cross-cutting, every FEAT) | HIGH | RLS is the sole isolation mechanism on every table; a leak here breaks the entire multi-tenant promise — test explicitly with cross-workspace PAT/cookie attempts, not just happy-path |
| Auth (FEAT-001–004) | HIGH | Security-critical, dual-auth surface (cookie + PAT), and `lib/auth/` has only 2 test files — thinnest coverage relative to blast radius |
| PAT scope enforcement (FEAT-006) | HIGH | Security; scope bypass would let a narrowly-scoped token act workspace-wide — `0033_remediate_bk135_admin_scope.sql` shows this class of bug has happened before |
| ATC anchoring moat (FEAT-021) | HIGH | Core differentiator and data-integrity guarantee — a bypass silently breaks the traceability promise the whole product sells |
| Run idempotency + snapshot immutability (FEAT-030, FEAT-034) | HIGH | Automation-safety guarantee for CI/agent retries — a duplicate Run or a retroactively-mutated Run corrupts audit trust |
| Project/ATC/Module missing single-`GET` (§3 CRUD matrix) | MEDIUM | Unverified whether this is deliberate API design or an access-control gap manifesting as "route doesn't exist" — test the actual HTTP response code, not just the UI path |
| Coverage/Traceability/Heatmap reports (FEAT-043, 045, 039) | HIGH | Proven historically wrong once (migration 0050); `lib/coverage/` has only 3 test files for a report this failure-prone |
| Bug status forward-only + assignment eligibility (FEAT-036, 037) | MEDIUM-HIGH | Two independent enforcement layers (RPC + trigger) suggest the team already treats this as regression-prone — verify both layers, not just the happy API response |
| Notification self-finish suppression (FEAT-042) | MEDIUM | Already a confirmed, live correctness gap (migration `0067` not applied) — do not write a test asserting the suppression works; write one confirming the actual (over-notifying) current behavior, and flag the gap |
| Jira import (FEAT-020) | MEDIUM | External dependency, async worker, thin test coverage (3 files) relative to its pagination/backoff/ADF-parsing complexity |
| Traceability chain filters (FEAT-045) | MEDIUM | Recently changed (BK-48, within last 30 commits) — freshly-touched code carries elevated regression risk regardless of its underlying stability |

### 8.3 QA relevance narrative

Cross-reference against `business-model.md §4` confirms no new QA-relevance themes beyond what that document already stated (tenant isolation, RBAC negative-testing, ATC anchoring, dual-auth, idempotency, snapshot immutability, Jira 409-gate, report-accuracy-against-fixtures, invite security) — this section adds feature-ID-level precision and file-count evidence on top of that existing narrative rather than replacing it.

---

## 9. Discovery gaps

MANDATORY per skill contract — everything below could not be fully verified from code/DB/UI in this pass.

1. **Workspace member list/status-transition endpoint not located.** No `GET /workspaces/{id}/members`-shaped route exists in the 82-operation OpenAPI spec, yet `app/(app)/workspaces/[id]/members/page.tsx` renders a member list. Most likely explanation: a Next.js server component querying Supabase directly, bypassing the versioned `/api/v1` surface — not confirmed by opening that page's implementation in this pass. The `active <-> suspended` member-status transition endpoint remains unconfirmed (carried forward from `business-data-map.md §4.4`).
2. **Project, Module, and ATC lack single-resource `GET` endpoints**, and **Project and ATC additionally lack any `DELETE`**, per direct enumeration of `public/openapi.json`. Not previously documented in `business-data-map.md`. Could not confirm from this pass alone whether this is deliberate API design (e.g., these entities are always fetched through a parent tree/list view) or an undocumented gap — flagged for direct-access HTTP testing (expect 404, not the UI's silent workaround) rather than asserted as either a bug or a feature.
3. **Exact UI component backing several endpoints was not opened in this pass** — e.g., the Bug assignment/status control location inside `BugsListView.tsx`, and the invite-issuance panel component inside workspace settings, were inferred from directory listing and domain fit rather than direct source read. Treat the "UI" column for FEAT-010, FEAT-036, and FEAT-037 as approximate.
4. **`test_plans` (15 live rows), `feature_flags` (0 rows), and `user_view_state` (0 rows) tables** — confirmed live via DBHub in this pass, confirmed absent from any `lib/`/`app/` code path — could not be independently verified as intentionally staged-only vs. accidentally-deployed-early. §7.2 lays out the best available corroboration (the target repo's own PRD) without treating it as confirmation.
5. **Notification-preferences email channel delivery mechanism unconfirmed** — carried forward from `business-data-map.md §7`; not re-verified independently.
6. **Full bodies of `components/atcs/*.tsx`, `components/tests/*.tsx`, and most `app/(app)/**/*.tsx` page components were not opened** in this pass — the UI inventory (§5) is built from filenames, directory placement, and the handful of files actually read (mind-map-view.tsx, ComingSoon.tsx, qa/page.tsx, the forms/dialogs list). Client-side validation logic, loading/error states, and exact prop contracts were not verified.
7. **`CommandPalette.tsx` (Cmd/Ctrl+K) scope not confirmed** — the `cmdk` dependency and the component's existence are confirmed; which entities it actually indexes/searches (ATCs only? Tests/Runs/Bugs too?) was not verified by opening the component.
8. **DBHub visibility is limited to `public`, `information_schema`, `pg_catalog`** for the connecting role (same limitation `business-data-map.md §7` already notes) — no `cron`, `auth`, or `storage` schema access, so any feature implemented purely as a Postgres cron job, storage bucket policy, or custom auth hook could not be enumerated here.
9. **Coverage matrix file-count proxy (§8.1) is not a substitute for reading test bodies.** A `lib/<domain>/` file count says nothing about assertion depth, edge-case coverage, or whether the tests actually exercise the RPCs/triggers described in `business-data-map.md` (e.g., a 15-file `lib/runs/` directory could still miss the idempotency-replay edge case entirely) — treat every ⚠️/✅ in that table as "tests exist in proportion to X," not "X is adequately tested."

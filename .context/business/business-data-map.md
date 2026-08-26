# Business Data Map — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Reverse-engineered from `supabase/migrations/*.sql` (all 69 files), `app/api/v1/**/route.ts` (58 route files), `lib/**` (229 modules), `public/openapi.json`, and live schema/data verified against the staging Supabase Postgres DB via DBHub. Builds on `.context/business/business-model.md` (why the product exists) and `.context/business/domain-glossary.md` (entity/enum/rule catalog) — this file adds the **flow-level and process-level view**: how a user's action moves through the system end to end.
> Generated: 2026-08-26

```
+--------------------------------------------------------------------+
|                                                                     |
|   BUNKAI TMS  —  Multi-tenant Test Management System               |
|                                                                     |
|   Story -> Acceptance Criteria -> ATC -> Test -> Run -> Bug         |
|   Traceability enforced structurally, not by convention.           |
|                                                                     |
+--------------------------------------------------------------------+
```

---

## 1. Executive Summary

Bunkai TMS gives a software team one place to author test coverage against their own product and prove it stayed covered. A **Workspace** is the tenant boundary; inside it, a **Project** holds a tree of **Modules**, each carrying **User Stories** (often imported one-way from Jira) broken into **Acceptance Criteria**. QA authors reusable **ATCs** (Acceptance Test Cases) that must anchor to at least one AC — an ATC with zero AC links cannot be created, so every test case is structurally traceable back to a requirement. ATCs are chained into named **Tests**, and a Test is executed as a **Run** against a chosen **Environment** (Staging, Production, ...); the Run snapshots the chain's titles and step content at start time so a later edit to the source ATC never rewrites history. Failures become **Bugs**, optionally carrying full provenance back to the Run/Step/ATC that surfaced them, and Bugs move through a strict forward-only status lifecycle with role-gated assignment.

The system is deliberately built for two audiences at once: a human working the web UI through a Supabase magic-link or OAuth (GitHub/Google) session, and a script/CI pipeline/AI agent authenticating with a scoped Personal Access Token against the same versioned `/api/v1` REST surface (`public/openapi.json:4-10`). Every write path that matters for automation carries an idempotency contract (Run creation via `start_token`, generic POST replay via `idempotency_keys`), and every table ultimately resolves to one `workspace_id`, enforced by Postgres Row-Level Security — the tenant-isolation boundary a cross-workspace request can never cross, PAT or not.

Beyond authoring and execution, the product closes the loop with derived reporting — coverage, requirement traceability, and a defect heatmap — that exists specifically to answer "are we actually covered, and where is quality risk concentrating," not just "did the last run pass."

**Actors**

```
                    +---------------------------+
                    |        WORKSPACE           |
                    |  (tenant boundary; roles)  |
                    +--------------+--------------+
                                   |
        +--------------------------+--------------------------+
        |                          |                          |
   +----v----+               +-----v-----+              +-----v-----+
   |  viewer  |               |  member   |              | admin/    |
   | read-only|               | authors + |              | owner     |
   |          |               | executes  |               | manages   |
   +---------+               +-----------+              | team/plan |
                                                          +-----------+
                                   |
                          +--------v---------+
                          |  Script / CI /    |
                          |  AI Agent (PAT)   |
                          |  scoped bearer    |
                          +-------------------+
```
Source: `supabase/migrations/0001_tenancy.sql:43-49` (role enum), `0008_access_tokens.sql` (PAT scopes), `public/openapi.json:4-25` (dual auth + servers).

---

## 2. Entity Map

Bunkai's 29 live tables (confirmed via `information_schema.tables` against the staging DB, `qa_inspector_rw` role) fall into three groups: **12 core business entities** (below), their **child/snapshot tables** (steps, assertions, join tables), and **supporting/infrastructure tables** (PATs, invites, audit log, notification plumbing). Full column-level detail lives in `domain-glossary.md §1` — this section is the relationship map and the *why*.

```
Workspace ──< Workspace Member (role: viewer|member|admin|owner)
    │            └── eligible assignee for a Bug (must be active + non-viewer)
    ├──< Workspace Invite ──(accepted)──> Workspace Member
    ├──< Access Token (PAT, scoped)
    ├──< Project ──< Module ──< Module (self-ref tree, depth <= 6)
    │       │           ├──< User Story ──< Acceptance Criterion
    │       │           │        │              ╲___M:N___╱
    │       │           │        └──< ATC ───────────┘        (>=1 AC required — the "anchoring moat")
    │       │           │              ├──< ATC Step
    │       │           │              └──< ATC Assertion
    │       │           └──< Bug (filed against a module)
    │       ├──< Project Environment
    │       └──< Milestone
    ├──< Test ──< Test Step (ordered ATC references, duplicates allowed)
    │       └──< Run (snapshots the Test's chain at start)
    │              ├──< Run ATC (per chain position; verdict rollup)
    │              │       └──< Run Step (snapshot of ATC Step; pass/fail/blocked/skipped)
    │              └──> Bug (provenance: run_id / run_step_id / atc_id, nullable)
    ├──< Bug (workspace-scoped; assigned to a Workspace Member)
    ├──< Milestone (dated checkpoint, no delete path)
    ├──< Notification (per-recipient inbox, produced only by triggers)
    └──< Activity Log (append-only audit trail; source of Notifications)
```

| Entity | Business Role | Why it exists |
|---|---|---|
| Workspace | Tenant / customer account | Isolation boundary for everything else; one workspace = one team's QA universe |
| Workspace Member | RBAC roster row | Ties a Supabase Auth user to a role inside one workspace |
| Project | Application under test | Groups a product's modules, environments, ATCs, runs, bugs, milestones |
| Module | Feature-tree folder (depth <= 6) | Organizes Stories/ATCs the way a team's own product is structured |
| User Story | Requirement / feature intent | The business "why"; often imported one-way from Jira, never round-tripped |
| Acceptance Criterion | One testable condition on a Story | The unit an ATC must anchor to — makes "requirement covered" checkable |
| ATC (Acceptance Test Case) | Reusable, versioned test-case unit | The authored test itself; cannot exist without >=1 AC link |
| Test | Named, ordered chain of ATC references | Composable suite; workspace-scoped, not project-scoped, so it can span projects |
| Project Environment | Named execution target | Lets the same Test run against Staging vs Production with different results tracked separately |
| Run | One execution instance of a Test | The record of "did it pass," snapshotted so history never silently rewrites |
| Bug | Defect record | Closes the loop from a failed step (or a standalone finding) back to a fix |
| Milestone | Dated release checkpoint | Lets a team track coverage/bugs against an upcoming date |
| Notification | Per-recipient inbox item | Tells a human a Bug or Run they care about changed, without them polling |

**Key relationship to internalize for testing**: an ATC is *referenced*, not copied, by a Test (`test_steps.atc_id`); a Run then *copies* (`run_atcs`/`run_steps`) the ATC's content at that instant. This two-step reference-then-snapshot design is why editing an ATC never corrupts a Run already in flight or already finished (see BR-3, `domain-glossary.md:453-463`).

---

## 3. Business Flows

All major flows discovered across `app/api/v1/**`, `app/(app)/**`, `app/(auth)/**`, and their backing `lib/**` modules — not capped at three.

### 3.1 Sign-up & Workspace Bootstrap

```
User -> POST /api/v1/auth/signup (or magic-link / GitHub / Google OAuth)
      -> Supabase Auth creates auth.users row
      -> GET /onboarding (app/(app)/onboarding)
      -> user names + creates a Workspace
      -> bunkai_bootstrap_workspace(RPC)
      -> workspace_members row inserted: role='owner', status='active'
      -> redirect into the new workspace
```
1. A new user authenticates via magic-link (`app/api/v1/auth/magic-link`, `/confirm`, `/resend`, `/check-email`) or OAuth (`github`|`google`, `lib/auth/oauth.ts:5`).
2. With no workspace yet, they land on `/onboarding` (`app/(app)/onboarding/onboarding-form.tsx`) to create their first Workspace.
3. `bunkai_bootstrap_workspace` creates the Workspace and the caller's own `workspace_members` row as `owner` — self-service, no admin approval step (`business-model.md:27`).
4. **Business rule**: every workspace must always retain >=1 active owner (BR-8) — enforced later at leave-time, not at creation (creation always makes exactly one owner).

Code paths: `app/api/v1/auth/*`, `app/(app)/onboarding/*`, `supabase/migrations/0006_bootstrap_workspace.sql`.

### 3.2 Team Invite & Join

```
Owner/Admin -> POST /api/v1/workspaces/{id}/invites (email + role)
            -> workspace_invites row (token hashed in workspace_invite_secrets)
            -> email sent to invitee  [** delivery mechanism unconfirmed — see Discovery Gaps **]
Invitee -> opens /invites/accept?token=...
        -> POST /api/v1/invites/accept
        -> workspace_members row: role=<invited role>, status='active'
```
1. An `admin`/`owner` invites a teammate by email + role (`viewer`|`member`|`admin` — `owner` is deliberately not invitable, `domain-glossary.md:402`).
2. The invite token is hashed and stored separately (`workspace_invite_secrets`, split from the row exposed to the app — `0011_split_token_secrets.sql`), 7-day expiry.
3. Acceptance (`app/invites/accept`) converts the invite into an active `workspace_members` row.
4. Revocation and re-use-after-accept are both explicit rejection paths (`business-model.md:59` QA relevance row).

Code paths: `app/api/v1/workspaces/[id]/invites/*`, `app/api/v1/invites/accept`, `app/invites/accept/*`.

### 3.3 Project & Module Setup

```
Member+ -> POST /api/v1/workspaces/{id}/projects  -> projects row
        -> POST /api/v1/projects/{id}/modules      -> modules row (materialized path)
        -> nested modules up to depth 6 (bunkai_move_module enforces cap)
```
1. A Project is created inside a Workspace (`app/(app)/projects/new`).
2. Modules form a self-referential tree with a materialized slash-separated `path`; `bunkai_move_module` rejects any move that would push a descendant past depth 6 (BR-2).
3. Modules can be soft-deleted (`archived_at`) rather than hard-deleted (`0014_module_soft_delete.sql`).

Code paths: `app/api/v1/workspaces/[id]/projects`, `app/api/v1/projects/[id]/modules`, `app/api/v1/modules/[id]`, `app/(app)/projects/[projectSlug]/*module*`.

### 3.4 Jira Import (one-way, async)

```
Member+ -> POST /api/v1/imports { project_id, jql }
        -> import_jobs row: status='queued'   (409 if one already queued/running for this project)
        -> Vercel `after()` background slot -> runImportJob(jobId)
             -> claims job (status='running', atomic UPDATE...WHERE status='queued')
             -> pages Jira /search/jql (100/page, up to 1000 pages)
             -> per issue: ADF description -> Markdown (truncate >50KB)
                          -> extract Acceptance Criteria
                          -> route to Module (component-name match, else auto "Inbox")
                          -> upsert user_stories + acceptance_criteria, keyed on external_id (idempotent)
             -> status='completed' | 'failed' (per-issue errors collected, Jira auth failure fails whole job)
```
1. A user starts an import naming a project and a Jira JQL filter (`app/(app)/projects/[projectSlug]/import-from-jira-dialog.tsx`).
2. Only one active (`queued`/`running`) job per project is allowed — a partial unique index turns a second attempt into HTTP 409 (BR-7).
3. The worker runs in Vercel's `after()` background slot using the **service-role admin client** (RLS bypassed; authorization was already enforced at enqueue time) — `lib/jira/import-runner.ts:15-21`.
4. Import is one-way only: Bunkai never writes back to Jira (`business-model.md:31` Key Partners row).
5. Each Jira issue becomes (or updates) a `user_stories` row plus its extracted `acceptance_criteria`, upserted idempotently on `external_id` so a re-run doesn't duplicate.

Code paths: `app/api/v1/imports`, `app/api/v1/imports/[id]`, `lib/jira/client.ts`, `lib/jira/import-runner.ts`, `lib/jira/adf-to-markdown.ts`, `lib/jira/extract-acceptance-criteria.ts`.

### 3.5 Story & Acceptance Criteria Authoring (manual)

```
Member+ -> create/edit User Story (manual, or post-import) -> status: draft
        -> add Acceptance Criteria (ordered, position 1..N)
        -> Story auto-flips to 'ready_to_test' once it has >=1 active AC
        -> archiving the LAST active AC reverts the Story to 'draft' automatically
```
Code paths: `app/api/v1/user-stories/[id]`, `app/api/v1/user-stories/[id]/acceptance-criteria`, `app/api/v1/acceptance-criteria/[id]`, `supabase/migrations/0017_acceptance_criteria_ordering.sql:20-27`.

### 3.6 ATC Authoring (the "anchoring moat")

```
Member+ -> POST /api/v1/atcs { user_story_id, ac_ids[], layer, title, steps[], assertions[] }
        -> bunkai_create_atc validates every ac_id belongs to that user_story
        -> zero AC ids OR any AC outside the story -> REJECTED (ac_outside_user_story)
        -> atc row + atc_steps + atc_assertions + atc_acceptance_criteria join rows
        -> tsv column refreshed (full-text search) via BEFORE INSERT/UPDATE trigger
```
1. An ATC is authored against a specific User Story and must link to at least one of that Story's own Acceptance Criteria — the "anchoring moat" (BR-1). This is enforced at the RPC layer (`bunkai_create_atc`), not by a raw foreign key.
2. `layer` classifies the ATC as `UI`|`API`|`Unit` — the automation-layer tag this QA repo's own KATA framework consumes downstream.
3. ATC editing after publication is versioned (`version` column) and propagates per `0035_atc_update_propagation.sql`; duplication is a first-class action (`atcs/[id]/duplicate`).
4. **Confirmed dead column**: `atcs.status` (`pass|fail|blocked|skipped|running|unrun`) exists but no production write path ever updates it — the real per-execution verdict lives on `run_atcs.status` (`domain-glossary.md:404`, confirmed by migration `0050`'s own audit). Do not test against `atcs.status` changing after a Run.

Code paths: `app/api/v1/atcs`, `app/api/v1/atcs/[id]`, `app/api/v1/atcs/[id]/duplicate`, `app/api/v1/atcs/[id]/usage`, `app/api/v1/atcs/search`, `supabase/migrations/0004_atcs.sql`, `0021_atc_create_update.sql`.

### 3.7 Test Composition (chaining ATCs)

```
Member+ -> POST /api/v1/tests { title, tags[] }
        -> add/reorder chain positions -> test_steps (atc_id, position)
        -> same ATC MAY appear at multiple positions (no unique(test_id, atc_id))
        -> reserved tags (smoke|sanity|regression) normalized to lowercase; custom tags keep casing (BR-9)
```
Code paths: `app/api/v1/tests`, `app/api/v1/tests/[id]`, `app/api/v1/tests/[id]/reorder`, `app/api/v1/tests/[id]/tags`, `app/(app)/projects/[projectSlug]/tests/*`.

### 3.8 Run Execution

```
Member+ -> POST /api/v1/runs { test_id, environment_id, start_token }
        -> idempotency check: same (test_id, start_token) within 24h -> replay existing Run (replayed: true)
        -> else: snapshot Test's chain -> run_atcs + run_steps rows (status='pending'), status='running'
        -> executor marks each step: PATCH /runs/{id}/steps/{stepId}/mark -> passed|failed|blocked
           (re-mark is last-write-wins, no conflict error)
        -> run_atcs.status computed from sibling run_steps (any pending -> pending; any failed -> failed;
           else any blocked -> blocked; else passed)
        -> POST /runs/{id}/finish (verdict) -> status: passed|failed   [terminal]
           OR POST /runs/{id}/abort (reason) -> status: aborted        [terminal, any pending steps -> skipped]
```
1. Starting a Run against a Test + Environment snapshots the chain immutably — a later ATC edit never rewrites an in-flight or finished Run (BR-3).
2. `executor_mode` (`human`|`agent`|`ci`) is stamped once at start and never changes — this is how the product distinguishes a human clicking through the UI from a CI pipeline or AI agent driving the same API.
3. Idempotent create: replaying the same `(test_id, start_token)` inside 24h returns the SAME Run rather than creating a duplicate (BR-4) — the core automation-safety guarantee for CI retries.
4. Real-time step/status updates are pushed to open UI sessions via a Supabase Realtime channel (`lib/runs/realtime-run-channel.ts`), not polling.

Code paths: `app/api/v1/runs`, `app/api/v1/runs/[id]`, `app/api/v1/runs/[id]/steps/[stepId]/mark`, `app/api/v1/runs/[id]/finish`, `app/api/v1/runs/[id]/abort`, `app/(app)/projects/[projectSlug]/runs/[runId]`, `components/runs/RunnerView.tsx`.

### 3.9 Bug Filing & Lifecycle

```
Human (from a failed Run Step, or standalone) -> POST /api/v1/bugs
    { title, severity, module_id, run_id?, run_step_id?, atc_id?, steps_to_reproduce, evidence_urls[] }
        -> bugs row, status='open', provenance FKs nullable (on delete set null)
Owner/Admin/Member -> POST /bugs/{id}/assign { assignee_user_id }
        -> rejected unless assignee is an active, non-viewer workspace_member (BR-6)
Any authorized user -> POST /bugs/{id}/status { status }
        -> forward-only, one stage at a time: open -> in_progress -> resolved -> closed (BR-5)
        -> skip or backward move rejected by BOTH the RPC and a DB trigger backstop
```
1. A Bug can be filed with full provenance (which Run, which Step, which ATC surfaced it) or standalone — all three provenance FKs survive deletion of their source (`on delete set null`), so a Bug never becomes orphaned/broken by later cleanup.
2. Assignment and status-change both fire `activity_log` rows in the same transaction, which in turn fan out to `notifications` (see §6).
3. Severity (`P1`-`P4`) is filed by the reporter; Priority is a QA-process convention derived from Severity (this QA repo's own `defect-management-doctrine.md`, not a Bunkai schema field).

Code paths: `app/api/v1/bugs`, `app/api/v1/bugs/[id]/assign`, `app/api/v1/bugs/[id]/status`, `app/api/v1/projects/[id]/bugs`, `app/api/v1/projects/[id]/bugs/heatmap`, `app/api/v1/workspaces/[id]/open-bugs`, `supabase/migrations/0046_bugs.sql`, `0054_bug_assignment_status.sql`.

### 3.10 Notification Delivery

```
Producer RPC (bunkai_assign_bug / bunkai_transition_bug_status / bunkai_finish_run / bunkai_abort_run)
    -> writes activity_log row (SAME transaction as the mutation)
    -> AFTER INSERT trigger on activity_log:
         activity_log_notify_bug_event -> bunkai_notify_bug_event()  [0056]
         activity_log_notify_run_event -> bunkai_notify_run_event()  [0066]
    -> notifications row(s) inserted (SECURITY DEFINER; recipient has no direct INSERT path)
    -> Supabase Realtime channel pushes to any open UI session (lib/notifications/realtime-notifications-channel.ts)
```
Recipient rules, ratified verbatim and confirmed by reading the migrations directly (not inferred):
- **Bug assigned/reassigned**: notifies the new assignee only. A self-(re)assign DOES notify the actor — the actor-exclusion clause is grammatically scoped to status-change events only, not assignment (`0056_bug_event_notifications.sql:33-37`).
- **Bug unassigned**: no recipient defined — deliberate no-op, not an oversight (`0056:28-30`).
- **Bug status changed**: notifies the reporter AND the current assignee, always excluding whoever made the change; one notification per recipient even if reporter and assignee are the same person.
- **Run finished/aborted**: notifies the run starter (`runs.executor_user_id`) only — no watcher/participant audience (`0066_run_event_notifications.sql:24-27`). A same-user PAT-driven finish still notifies (an identity-only suppression rule was explicitly rejected — `0066:33-40`); the intended cookie-session self-finish suppression depends on migration `0067`, which per its own header is **not applied** to avoid an incoherent intermediate state (see Discovery Gaps).
- 90-day retention is enforced at RLS **read** time, not by row deletion (`domain-glossary.md:354`).

Code paths: `supabase/migrations/0053_notifications.sql`, `0056_bug_event_notifications.sql`, `0066_run_event_notifications.sql`, `app/api/v1/workspaces/[id]/notifications`, `app/api/v1/notifications/[id]/read`, `app/api/v1/workspaces/[id]/notifications/read-all`, `app/api/v1/notification-preferences`.

### 3.11 Reporting (Coverage, Traceability, Defect Heatmap, Recovery Cycles)

```
GET /api/v1/projects/{id}/coverage        -> % of ACs with >=1 anchored ATC, real-execution-sourced
GET /api/v1/projects/{id}/traceability    -> Story -> AC -> ATC -> Run chain, per-story
GET /api/v1/projects/{id}/bugs/heatmap    -> Bug density by Module
GET /api/v1/projects/{id}/metrics/recovery-cycles  -> time from Bug opened to closed
GET /api/v1/projects/{id}/runs/report     -> aggregate Run outcomes
GET /api/v1/workspaces/{id}/coverage      -> workspace-level roll-up
```
These are derived/aggregate views over the entities above — no new business data is created, only summarized. `0050_project_coverage_report_real_execution_source.sql` is itself the evidence that an earlier coverage report was quietly wrong (sourced from the dead `atcs.status` column) and was corrected to read `run_atcs.status` instead — a concrete precedent for validating any report endpoint against fixture data rather than trusting the query.

Code paths: `app/api/v1/projects/[id]/coverage`, `/traceability`, `/bugs/heatmap`, `/metrics/recovery-cycles`, `/runs/report`, `app/api/v1/workspaces/[id]/coverage`, `app/(app)/projects/[projectSlug]/{metrics,traceability}`.

### 3.12 Personal Access Token (PAT) Issuance

```
Owner/Admin/Member -> POST /api/v1/tokens { name, scopes[], expires_at? }
        -> access_tokens row (token_prefix stored; secret hash split into access_token_secrets)
        -> raw token shown ONCE at creation
Script/CI/Agent -> Authorization: Bearer <token>  -> resolved by lib/api/middleware/bearer.ts / lib/api/pat.ts
        -> scope check per route (atc:read | atc:write | run:execute | workspace:admin)
        -> workspace:admin scope retro-enforced: issuing user must actually hold admin/owner (0033)
```
Code paths: `app/api/v1/tokens`, `app/api/v1/tokens/[id]`, `lib/api/pat.ts`, `lib/api/middleware/bearer.ts`, `supabase/migrations/0008_access_tokens.sql`, `0011_split_token_secrets.sql`, `0033_remediate_bk135_admin_scope.sql`.

### 3.13 Milestone Tracking

```
Member+ -> POST /api/v1/projects/{id}/milestones { name, target_date, description }
        -> name whitespace-normalized before the per-project uniqueness check
        -> target_date must fall within today .. +5 years at write time
        -> NO delete path exists (deliberately out of scope per migration header)
```
Code paths: `app/api/v1/projects/[id]/milestones`, `app/api/v1/milestones/[id]`, `app/(app)/projects/[projectSlug]/milestones/*`, `supabase/migrations/0064_milestones.sql:28-29`.

---

## 4. State Machines

### 4.1 Run Status

```
[*] --create_run--> running --finish_run(passed)--> passed  [terminal]
                     running --finish_run(failed)--> failed  [terminal]
                     running --abort_run(reason)---> aborted [terminal]
```

| From | To | Event | Effects |
|---|---|---|---|
| — | `running` | `bunkai_create_run` | Snapshots Test chain into `run_atcs`/`run_steps` (all `pending`) |
| `running` | `passed` | `bunkai_finish_run(verdict='passed')` | Terminal; triggers `run.finished` notification to the starter |
| `running` | `failed` | `bunkai_finish_run(verdict='failed')` | Terminal; triggers `run.finished` notification to the starter |
| `running` | `aborted` | `bunkai_abort_run(reason)` | Terminal; any still-`pending` steps auto-flip to `skipped`; triggers `run.aborted` notification |

**Business rule**: no RPC transitions a Run out of a terminal state — `passed`/`failed`/`aborted` are permanent. Source: `supabase/migrations/0031_runs.sql:79-80`, `0036_run_abort.sql`, `0037_run_finish.sql`.

### 4.2 Run ATC / Run Step Status

```
[*] --snapshot--> pending --mark(passed|failed|blocked)--> passed|failed|blocked
    pending --parent Run aborted/finished while still pending--> skipped
    passed <--re-mark (last write wins)--> failed
```

| From | To | Event | Effects |
|---|---|---|---|
| — | `pending` | Snapshotted at Run start | Initial state for every step |
| `pending` | `passed`/`failed`/`blocked` | `bunkai_mark_run_step` | Executor's verdict for that step |
| `pending` | `skipped` | Parent Run aborted/finished with step still pending | Auto-applied, not a manual action |
| `passed` <-> `failed` | re-mark | `bunkai_mark_run_step` again | **Last-write-wins, no conflict error** — unlike Run-level transitions, a step CAN be re-marked freely |

Parent `run_atcs.status` is *computed*, not written directly: any sibling step `pending` -> `pending`; else any `failed` -> `failed`; else any `blocked` -> `blocked`; else `passed`. Source: `supabase/migrations/0042_run_step_mark.sql:97-192`.

### 4.3 Bug Status

```
[*] --create_bug--> open --transition--> in_progress --transition--> resolved --transition--> closed [terminal]
```

| From | To | Event | Effects |
|---|---|---|---|
| — | `open` | `bunkai_create_bug` | Initial state |
| `open` | `in_progress` | `bunkai_transition_bug_status` | One stage forward only |
| `in_progress` | `resolved` | `bunkai_transition_bug_status` | One stage forward only |
| `resolved` | `closed` | `bunkai_transition_bug_status` | Terminal |
| any | any (skip or backward) | rejected | `bug_status_transition_skipped` (45310) or `bug_status_transition_backward` (45311) — enforced by BOTH the RPC and a table-write trigger backstop |

Source: BR-5, `supabase/migrations/0054_bug_assignment_status.sql:143-156,589-601`.

### 4.4 Workspace Member Status

```
[*] --invite issued--> invited --invite accepted--> active <--admin/owner action--> suspended
    active --leave/removed--> [*]
```

| From | To | Event | Effects |
|---|---|---|---|
| — | `invited` | Invite issued (or bootstrap creates `active` `owner` directly) | No access yet |
| `invited` | `active` | Invite accepted | Grants access at the invited role |
| `active` | `suspended` | Admin/owner action | Revokes access, row retained |
| `suspended` | `active` | Admin/owner action | Restores access |
| `active` | — (removed) | `bunkai_leave_workspace` | Rejected if it's the caller's only membership (`last_membership`) or the caller is the sole active owner (`sole_owner`) — BR-8 |

**Discovery gap carried from `domain-glossary.md:692`**: the explicit `active <-> suspended` transition endpoint was not located in the 69 migrations read — the CHECK constraint and RLS write-gate exist, but no named RPC was found; likely a plain gated `UPDATE`, not confirmed.

### 4.5 Import Job Status

```
[*] --enqueued--> queued --worker claims--> running --worker finishes--> completed [terminal]
                                              running --worker errors---> failed    [terminal]
```

| From | To | Event | Effects |
|---|---|---|---|
| — | `queued` | Import enqueued (409 if project already has one queued/running — BR-7) | |
| `queued` | `running` | Worker atomically claims (`UPDATE...WHERE status='queued'`) | Prevents a duplicate/retried background trigger from double-running |
| `running` | `completed` | Worker finishes all pages | Terminal |
| `running` | `failed` | Jira auth error, or unrecoverable error | Terminal; per-issue errors still recorded in `errors[]` |

Source: `supabase/migrations/0019_import_jobs.sql:15`, `0020_import_jobs_one_active.sql`, `lib/jira/import-runner.ts:43-58`.

---

## 5. Automatic Processes

### 5.1 Database Triggers (confirmed live via `information_schema.triggers`, staging DB)

| Table | Trigger | Timing | Fires On | Why it exists |
|---|---|---|---|---|
| `activity_log` | `activity_log_notify_bug_event` | AFTER | INSERT | Fans a `bug.*` audit row out into the `notifications` inbox (see §3.10) |
| `activity_log` | `activity_log_notify_run_event` | AFTER | INSERT | Fans a `run.finished`/`run.aborted` audit row out into `notifications` |
| `atcs` | `atcs_refresh_tsv` | BEFORE | INSERT, UPDATE | Recomputes the full-text-search vector so ATC search stays in sync without a separate reindex job |
| `atcs` | `atcs_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |
| `bugs` | `bugs_check_consistency` | BEFORE | INSERT, UPDATE | Backstops the forward-only status rule (BR-5) at the table level, independent of which RPC (or a future direct write) touches the row |
| `bugs` | `bugs_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |
| `milestones` | `milestones_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |
| `notification_preferences` | `notification_preferences_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |
| `runs` | `runs_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |
| `test_plans` | `test_plans_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically — see Discovery Gaps re: this table |
| `tests` | `tests_set_updated_at` | BEFORE | UPDATE | Stamps `updated_at` automatically |

### 5.2 Cron Jobs

| Job | Schedule | Why it exists |
|---|---|---|
| — none confirmed — | — | The `pg_cron` Postgres extension IS installed on the staging project (`select extname from pg_extension` confirmed it), but the `qa_inspector_rw` role received `permission denied for schema cron` when querying `cron.job` — presence of the extension does not by itself prove any job is scheduled. Treat as **unconfirmed**, not "none," per Discovery Gaps. |

### 5.3 Webhooks

| Direction | Endpoint / Source | Why it exists |
|---|---|---|
| — none found — | — | No inbound webhook receiver route was found under `app/api/`, and the Jira import is **pull-based** (the worker polls Jira's `/search/jql` REST endpoint — `lib/jira/client.ts`), not a Jira-pushed webhook. No outbound webhook-sending code was found in `lib/**`. Real-time UI updates instead use Supabase Realtime channel subscriptions (`lib/runs/realtime-run-channel.ts`, `lib/notifications/realtime-notifications-channel.ts`), which is a client-subscribed Postgres-changes feed, not a webhook. |

---

## 6. External Integrations

### 6.1 Supabase (Auth + Postgres + Realtime)

```
Bunkai app  <-->  @supabase/supabase-js / @supabase/ssr  <-->  Supabase-hosted Postgres 17
                                                                 (RLS on every table; Realtime
                                                                  publication for runs + notifications)
```
- **Data flow**: every read/write goes through Supabase's Postgres, with Row-Level Security as the tenant-isolation mechanism on every table (`domain-glossary.md` throughout). Auth (magic-link + OAuth) and session cookies are also Supabase-managed.
- **Dependent flows**: literally all of §3 — this is the system of record.
- **Failure behavior**: not verified in this pass (no chaos/outage test performed); architecturally, an outage would fail every read/write since there is no secondary datastore.

### 6.2 Vercel (Hosting + Background Execution)

```
HTTP request  -->  Vercel Edge/Serverless (Next.js Route Handlers)  -->  Supabase
                          |
                          `-- after() background slot --> Jira import worker (fire-and-forget, post-response)
```
- Confirmed via `.context/project-config.md` (webapp domains are `*.vercel.app`) and `lib/jira/import-runner.ts:15-16` (explicitly documents running "in the Vercel `after()` background slot").
- **Failure behavior**: not independently tested; a Vercel outage would take the whole app down (no documented failover).

### 6.3 Jira / Atlassian (one-way import source)

```
Bunkai (lib/jira/client.ts)  --GET /search/jql (paged, backoff on 429)-->  Jira Cloud REST v3
        <-- issues (summary, ADF description, components, issuetype) --
```
- One-way only: Bunkai reads Jira issues to seed `user_stories`/`acceptance_criteria`; nothing is written back to Jira (`business-model.md:31`).
- **Dependent flow**: §3.4 Jira Import.
- **Failure behavior**: a 401/403 from Jira raises `JiraAuthError` and fails the whole import job; other non-2xx responses raise `JiraError`(status); 429s are retried with an exponential backoff schedule (`1s, 2s, 4s, 8s, 16s` — `lib/jira/client.ts:78-79`) before giving up.

### 6.4 OAuth Identity Providers (GitHub, Google)

```
User  -->  "Sign in with GitHub/Google" (app/(auth)/login/oauth-buttons.tsx)  -->  Supabase Auth  -->  Provider
```
- Supported providers: `github`, `google` only (`lib/auth/oauth.ts:5`). No automatic identity linking across a second provider presenting the same email — the comment at `lib/auth/oauth.ts:17` flags this explicitly.
- **Dependent flow**: §3.1 Sign-up.
- **Failure behavior**: a documented `oauth_provider_unreachable`-style error surfaces a "try again or use magic-link" fallback (`lib/auth/oauth.ts:42`) — magic-link is the resilient fallback path when an OAuth provider is down.

### 6.5 Scalar (API Reference UI)

```
public/openapi.json  -->  app/api/docs (Scalar React component)  -->  human browsing the API reference
```
- Not a runtime data integration — a documentation-rendering dependency (`@scalar/api-reference-react`) that turns the generated OpenAPI spec into a browsable reference at `/api/docs`. No data flows through it at runtime beyond serving the static spec.

---

## 7. Discovery Gaps

> Per project rules: anything below could not be verified from code/DB and is stated as a gap, never asserted as fact elsewhere in this document.

- **`test_plans` table exists live in the staging DB but is undocumented anywhere in code.** Confirmed via DBHub (`information_schema.tables`): columns `id, workspace_id, project_id, name, goal, description, status (default 'open'), created_by, created_at, updated_at`, with a live `test_plans_set_updated_at` trigger and **15 real rows**. No matching `CREATE TABLE test_plans` was found in any of the 69 local migration files, no `app/api/v1/**` route references it, and no `lib/**` module references it (a grep for `test_plans`/`TestPlan` across the whole target repo found nothing besides an unrelated Jira custom-field name string in this QA repo's own tooling). This is either a migration applied directly to staging that was never committed locally, or an in-progress feature not yet wired to the API/UI. **Do not treat it as a confirmed business entity** — it is excluded from §2's entity map on purpose. Re-verify against the live migration ledger before designing any test around it.
- **`access_token_secrets`, `magic_link_token_secrets`, `workspace_invite_secrets` tables (documented in `domain-glossary.md` §1.14 from migration `0011_split_token_secrets.sql`) do not appear in the live `information_schema.tables` result for the `qa_inspector_rw` DBHub role.** The migration file explicitly creates them in the `public` schema (`0011_split_token_secrets.sql:20,40,59`), and no later migration drops or renames them. The most likely explanation is that `information_schema.tables` hides tables the connecting role has zero grants on (a reasonable security posture for tables holding literal secret hashes) rather than the tables having been dropped — but this was **not independently confirmed** with an elevated role. Treat their existence as "very likely, per migration source" rather than "DB-confirmed."
- **Notification email delivery mechanism is unconfirmed.** `notification_preferences.channel` includes `email` as a valid value (`domain-glossary.md:421`) and the UI exposes per-event email opt-in, but no email-provider dependency (Resend, SendGrid, Postmark, etc.) was found anywhere in `upex-bunkai-tms/package.json`. Either email delivery is unimplemented (channel exists in schema, ungated in practice), handled by a Supabase-native mechanism not visible in this repo, or provisioned entirely outside the codebase. Do not write a test asserting an actual email is sent for a notification event without confirming the send path first.
- **`pg_cron` extension is installed on the staging Postgres project, but whether any job is actually scheduled could not be confirmed.** `select extname from pg_extension` confirms the extension; querying `cron.job` returned `permission denied for schema cron` for the `qa_inspector_rw` role. §5.2 is deliberately left as "unconfirmed," not "none."
- **`workspace_members.status` transition endpoint (`active <-> suspended`) was not located** in either the 69 migrations or the `app/api/v1/workspaces/**` route list read in this pass — carried forward from `domain-glossary.md:692,736`. The CHECK constraint and RLS write-gate exist; the actual RPC/route name doing the flip does not appear under an obvious name.
- **`workspaces.plan` (`community`/`cloud`/`enterprise`) has no enforcement logic anywhere read in this pass** — corroborates `business-model.md`'s own "Revenue Streams: Unknown" finding. The column exists; nothing observed gates behavior on it.
- **Two migrations exist on disk but are explicitly NOT applied together to the live database**, per their own headers: `0058_atc_title_min_length.sql` and `0067_run_finish_abort_via.sql`. This directly affects §3.10: the `run.finished`/`run.aborted` self-notification suppression rule described in `0066_run_event_notifications.sql` depends on the `via` payload key that only `0067` populates — since `0067` is not applied, **every** terminal Run event currently notifies the starter, including a self-finish via the cookie session, contrary to the fully-ratified design. Verify the live migration ledger before writing a test that asserts self-finish is suppressed.
- **Production environment URL is unconfirmed** — carried forward from `.context/project-config.md` Discovery Gaps; `webapp_domain: https://upexbunkai.vercel.app` is a naming-convention guess, not independently verified as production.
- **Full `app/(app)/**/*.tsx` and `components/**/*.tsx` component bodies were not read in this pass** — routes and API contracts were verified directly; individual page/component implementations (form validation UX, client-side state) were not opened. Business rules cited here all trace to the DB/API layer, not to UI-only behavior.
- **DBHub connection only exposes `public`, `information_schema`, and `pg_catalog` schemas** for the `qa_inspector_rw` role — no `auth`, `vault`, `cron`, or `storage` schema visibility. Any business logic living in Supabase's `auth.*` schema (e.g., custom auth hooks) could not be inspected.

---

## 8. Sources Used

- `.context/business/business-model.md`, `.context/business/domain-glossary.md` (this repo) — prior Phase-1 context, vocabulary reused throughout
- `.context/project-config.md` (this repo) — infra/env notes
- `.agents/project.yaml` (this repo) — repo paths, environment URLs
- `supabase/migrations/0001-0069*.sql` (target repo) — schema, RPCs, triggers, business rules
- `app/api/v1/**/route.ts` (58 route files, target repo) — confirmed API surface matches `public/openapi.json`
- `app/(app)/**`, `app/(auth)/**`, `app/invites/**` (target repo) — confirmed UI flow surface
- `lib/jira/client.ts`, `lib/jira/import-runner.ts`, `lib/auth/oauth.ts`, `lib/api/pat.ts`, `lib/api/middleware/bearer.ts`, `lib/runs/realtime-run-channel.ts`, `lib/notifications/realtime-notifications-channel.ts` (target repo)
- `upex-bunkai-tms/package.json` — dependency sweep for external-integration confirmation (Supabase, no email/payment provider found)
- Live staging Supabase Postgres DB via DBHub MCP (`mcp__dbhub__execute_sql`, `mcp__dbhub__search_objects`) — table list, trigger list, `test_plans` schema + row count, `pg_extension`/`cron.job` access check, secrets-table visibility check, core-entity row counts (workspaces: 479, projects: 530, atcs: 2936, tests: 620, runs: 536, bugs: 812, test_plans: 15)

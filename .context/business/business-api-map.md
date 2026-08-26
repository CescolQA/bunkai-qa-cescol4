# Business API Map — Bunkai TMS

> Last verified against OpenAPI on 2026-08-26
> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`), a Next.js 15 App Router fullstack app (backend + frontend, one repo). Reverse-engineered from `public/openapi.json` (82 operations), `lib/api/handler.ts`, `lib/api/principal.ts`, `lib/api/middleware/bearer.ts`, `middleware.ts`, `.env.example`, `package.json`. Builds on `.context/business/business-data-map.md` (entities, flows, state machines) and `.context/business/business-feature-map.md` (features, CRUD matrix, integrations) — this document narrates how the two connect through the API surface. This is a **narrative**, not an endpoint catalog: see §6 for where the exhaustive spec lives.

---

## 1. Executive summary

Bunkai TMS is built around a single idea: every write that matters can be made **by a human clicking through the browser or by a script/CI job/AI agent holding a token, and both routes must behave identically**. A QA engineer authors an ATC in the UI in the same call shape a CI pipeline uses to author one programmatically; a Run started by a person and a Run started by an agent share the same idempotency and snapshot guarantees. That parity is not a convention — it is enforced by one function, `withApiHandler`, that every one of the 82 `/api/v1` operations passes through, so there is structurally no second code path where the two auth methods could drift apart.

From the user's perspective: a new team signs up, gets a Workspace with itself as sole owner, imports its existing Jira backlog in one background job, authors ATCs that are physically incapable of existing without linking back to an Acceptance Criterion, chains those ATCs into Tests, runs them against an Environment with a replay-safe idempotency key, and files Bugs the moment something fails — all traceable end to end from Story to Bug. A CI pipeline or an AI agent does the identical sequence with a scoped Personal Access Token instead of a browser session, and never sees a different contract.

Underneath, every one of those calls terminates in Postgres Row-Level Security, which is the real authorization boundary — not the TypeScript layer. The API's job is to resolve *who is calling and how*; the database's job is to decide *what they can touch*. That split is why the tenant-isolation story (§3.7) is testable at the HTTP layer at all: a bug in the wrong RPC still can't leak another workspace's data, because RLS evaluates independently of which code path got there.

---

## 2. Permission & auth model

### 2.1 Tiers

| Tier | Who it applies to | How to acquire | Where enforced (code path) |
|---|---|---|---|
| **Public** | Unauthenticated visitor | N/A | `lib/api/handler.ts` — a route only skips auth when passed `{ auth: 'public' }` explicitly to `withApiHandler`; secure-by-default otherwise. 8 of 82 operations (health, version, sign-up/sign-in/magic-link/OTP family). |
| **Cookie session** (Authenticated, full capability) | Human, via browser | Magic-link, OAuth (GitHub/Google), or email+password sign-up-with-OTP — any path ends with Supabase setting the `sb-<project-ref>-auth-token` session cookie | UI page nav: `middleware.ts` (redirects to `/login` if a protected prefix is hit with no session). API calls: `lib/api/principal.ts` → `resolveIdentity()` → `ssr.auth.getUser()`; grants the full `ALL_CAPABILITIES` set — the UI is the trusted client, so capability checks are effectively a no-op for this tier and RLS + route-level role checks (`workspace_members.role`) do the real gating. |
| **Bearer PAT** (Authenticated, explicitly scoped) | Script / CI / AI agent | `POST /api/v1/tokens` (itself Cookie-only — a human must mint it) returns `bk_pat_<12-char-prefix>.<base64url-secret>` **once** | `lib/api/middleware/bearer.ts` → `requireBearerToken()`: O(1) lookup by indexed `token_prefix`, then a constant-shape SHA-256 hash compare against `access_token_secrets` (hash lives in a sibling table so read-only roles can't see it); rejects missing/malformed/unknown/revoked/expired uniformly as one 401 — never leaks which check failed. |
| **Cookie-only** (PAT explicitly excluded) | Human only | N/A | 4 of 82 operations carved out in the OpenAPI security array: `POST/GET /tokens`, `DELETE /tokens/{id}`, `DELETE /workspaces/{id}/membership` — a PAT cannot mint/revoke sibling tokens or make its own owner leave a workspace. |
| **Dual** (cookie OR bearer) | Everything else | Either of the above | The remaining 74 operations declare `security: [{cookieAuth},{bearerAuth}]` — either satisfies. `resolveIdentity()` checks the `Authorization: Bearer` header first (so an explicit PAT is never shadowed by a stale cookie), then falls back to the SSR cookie session. |
| **Workspace-scoped** (PAT sub-constraint) | A PAT bound to one workspace at mint time | Chosen at `POST /tokens` | `assertWorkspaceContext()` in `principal.ts` — a no-op for cookie sessions (trusted UI); for a bearer caller, rejects with 403 if the token has no workspace binding at all, or if it targets a workspace other than the one it's scoped to. There is no such thing as a global-admin PAT (data-map calls this out as a deliberate design choice). |
| **RLS / DB tenant boundary** | Every principal, regardless of `via` | Automatic | Postgres Row-Level Security on every table. This is the tier that actually decides "what can this user see," not the TS layer above it — see §1 and §3.7. |

### 2.2 Token flow — cookie session (human, browser)

```
Browser                    Supabase Auth              Bunkai (middleware.ts)      Bunkai (/api/v1/*)
  |--magic-link/OAuth/---->|                              |                           |
  |  OTP sign-up             (creates auth.users row)      |                           |
  |<--sets sb-<ref>-auth----|                              |                           |
  |    -token cookie        |                              |                           |
  |                                                          |                           |
  |--GET /home (page nav)-------------------------------->  |                           |
  |                          middleware.ts calls supabase.auth.getUser()               |
  |                          protected prefix + no user -> redirect /login             |
  |<-------------------------------------------------------|                            |
  |                                                                                      |
  |--GET/POST /api/v1/... (cookie sent automatically)-------------------------------->  |
  |                                                        withApiHandler:              |
  |                                                        resolveIdentity()            |
  |                                                          -> ssr.auth.getUser()      |
  |                                                        Principal{ via:'cookie',     |
  |                                                          capabilities: ALL,         |
  |                                                          db: SSR client (RLS as-user) }
  |<-------------------------------------------------------------------------------- 200 + data
```

### 2.3 Token flow — Bearer PAT (script / CI / AI agent)

```
Human (cookie session)          Bunkai (/api/v1/tokens)        access_tokens / access_token_secrets
  |--POST /tokens {name, scopes[], expires_at?}--------->  (Cookie-only tier)
  |                                mint bk_pat_<prefix>.<secret>
  |                                store SHA-256(secret) split into access_token_secrets
  |                                workspace:admin scope retro-checked against issuer's real role
  |<--raw token, shown ONCE------------------------------|

Script / CI / AI Agent          Bunkai (/api/v1/*, Dual tier)         Postgres
  |--Authorization: Bearer bk_pat_<prefix>.<secret>----->
  |                                resolveIdentity(): Bearer branch checked first
  |                                requireBearerToken():
  |                                  lookup by token_prefix -> hash compare -> revoked/expired check
  |                                  any failure -> uniform 401 "Invalid token."
  |                                Principal{ via:'bearer', capabilities: token.scopes,
  |                                           workspaceId: token.workspace_id }
  |                                requireCapability(scope)   per route's `requires: [...]`
  |                                assertWorkspaceContext()   if the op is workspace-scoped
  |                                db = impersonatingClient(userId)
  |                                  -> mints a short-lived user JWT -> anon Supabase client
  |                                  -> auth.uid() resolves identically to the browser path
  |                                  -> RLS applies exactly as it would for a human
  |<---------------------------------------------------- 200 / 401 / 403
```

No per-endpoint listing here by design — the full 82-operation auth-tagged inventory lives in `business-feature-map.md §4` (see §6 below).

---

## 3. Critical business journeys

Selected for revenue/security/core-value/blast-radius per the doctrine's selection criteria (no billing integration exists — see `business-model.md`, so "revenue impact" is not represented; security and blast-radius carry the weight instead).

### 3.1 Sign-up & Workspace Bootstrap

Turns a first-time visitor into the sole owner of their own tenant, self-service, in one sitting.

```
Visitor -> POST /auth/signup | /auth/magic-link | OAuth redirect      [Public]
        -> Supabase Auth creates auth.users row
Visitor -> POST /auth/confirm (OTP) | GET /auth/callback (OAuth)
        -> session established; sb-<ref>-auth-token cookie set
        -> auto-minted PAT returned alongside the session (per OpenAPI operation summary)
Visitor -> middleware.ts: no workspace yet -> redirected into /onboarding
Visitor -> onboarding-form.tsx -> POST /workspaces                    [Dual]
        -> bunkai_bootstrap_workspace RPC
        -> workspace_members row: role='owner', status='active'
        -> redirect into the new workspace
```

1. Authentication happens before a Workspace exists — there is no "invite yourself" step, sign-up is fully self-service.
2. `/auth/confirm` and `/auth/signin` both mint a PAT in the same response as the session, so a script can complete this whole journey headlessly without ever touching cookies.
3. Bootstrap always produces exactly one `owner` — the "every workspace must retain ≥1 active owner" rule (BR-8) is enforced later, at leave-time, not needed here since creation guarantees it.

**Endpoints**: `POST /auth/signup`, `/auth/confirm`, `/auth/resend`, `/auth/magic-link`, `/auth/check-email`, `/auth/signin`, `POST /workspaces`
**Entities**: Workspace, Workspace Member — `business-data-map.md §2, §3.1`
**Feature IDs**: FEAT-001, FEAT-002, FEAT-003, FEAT-004, FEAT-008

### 3.2 Jira Import (one-way, async)

Seeds a Project's requirements from an existing Jira backlog without anyone retyping a single Acceptance Criterion.

```
Member+ -> POST /imports {project_id, jql}                            [Dual]
        -> import_jobs row, status='queued' (409 if one already queued/running — BR-7)
        -> HTTP response returns immediately; job accepted, not yet run
Vercel  -> after() background slot fires post-response
        -> runImportJob(jobId): atomic UPDATE...WHERE status='queued' claims it
        -> service-role admin client (RLS bypassed — authZ already done at enqueue time)
        -> pages Jira /search/jql (100/page, up to 1000 pages; 429 -> backoff 1s/2s/4s/8s/16s)
        -> per issue: ADF description -> Markdown (>50KB truncated)
                    -> extract Acceptance Criteria
                    -> route to Module by component-name match, else "Inbox"
                    -> upsert user_stories + acceptance_criteria, keyed on external_id (idempotent)
        -> import_jobs.status = 'completed' | 'failed'
Member+ -> GET /imports/{id}     [polls for status]
```

1. The response the caller gets from `POST /imports` only confirms the job was *accepted* — success or failure is discovered later by polling, never in the original request/response cycle.
2. Import is strictly one-way: nothing is ever written back to Jira.
3. Re-running against the same JQL never duplicates Stories — the upsert keys on Jira's own `external_id`.

**Endpoints**: `POST /imports`, `GET /imports/{id}`
**Entities**: Project, Module, User Story, Acceptance Criterion — `business-data-map.md §3.4`, §4.5 (Import Job state machine)
**Feature IDs**: FEAT-020

### 3.3 ATC Authoring (the "anchoring moat")

The product's core differentiator: a test case is structurally incapable of existing untethered from a requirement.

```
Member+ -> POST /atcs {user_story_id, ac_ids[], layer, title, steps[], assertions[]}  [Dual, atc:write scope]
        -> withApiHandler: resolveIdentity + requireCapability('atc:write') for bearer callers
        -> bunkai_create_atc RPC validates every ac_id belongs to user_story_id
        -> zero AC ids, OR any AC outside the story -> REJECTED (ac_outside_user_story)
        -> atc + atc_steps + atc_assertions + atc_acceptance_criteria rows inserted
        -> BEFORE INSERT trigger refreshes the full-text-search tsv column
<-- 201 {atc}
```

1. This is enforced at the RPC layer (`bunkai_create_atc`), not by a raw foreign key — the rejection is a deliberate business rule (BR-1), not an accidental constraint.
2. `layer` (`UI`/`API`/`Unit`) is the tag this very QA repo's own KATA framework consumes downstream when automating.
3. There is no `DELETE /atcs/{id}` and no single-resource `GET /atcs/{id}` in the spec (`business-feature-map.md §3` CRUD matrix) — an ATC is reachable only via `/atcs/search` or `/atcs/{id}/usage`, and can never be hard-deleted, likely because it's load-bearing for Test-chain and Run snapshot history.

**Endpoints**: `POST /atcs`, `PATCH /atcs/{id}`, `POST /atcs/{id}/duplicate`, `GET /atcs/search`, `GET /atcs/{id}/usage`
**Entities**: User Story, Acceptance Criterion, ATC, ATC Step, ATC Assertion — `business-data-map.md §3.6` (BR-1)
**Feature IDs**: FEAT-021, FEAT-022, FEAT-023, FEAT-024, FEAT-025

### 3.4 Run Execution (idempotent start → mark → finish/abort)

Gives a human, a CI pipeline, or an AI agent a safe-to-retry way to execute a Test chain and end up with exactly one authoritative record of what happened.

```
Member+/Agent/CI -> POST /runs {test_id, environment_id, start_token}   [Dual, run:execute scope]
        -> idempotency check: same (test_id, start_token) within 24h -> replay existing Run {replayed:true}
        -> else: snapshot Test's chain -> run_atcs + run_steps (all 'pending'), run.status='running'
        -> executor_mode ('human'|'agent'|'ci') stamped once, never changes afterward
        -> Supabase Realtime pushes 'running' state to any open UI session watching it
Executor -> POST /runs/{id}/steps/{stepId}/mark {passed|failed|blocked}   [repeatable]
        -> last-write-wins, no conflict error — unlike the Run-level transitions below
        -> run_atcs.status recomputed from sibling run_steps, never written directly
Executor -> POST /runs/{id}/finish {verdict}  OR  POST /runs/{id}/abort {reason}
        -> terminal (passed|failed|aborted) — no RPC ever transitions a Run back out
        -> abort auto-flips any still-pending steps to 'skipped'
        -> activity_log row -> notification to the run starter (executor_user_id)
```

1. The idempotency key (`start_token`) is the concrete guarantee that makes CI retries safe — a network timeout that causes a client to resend the same start request never creates a second Run.
2. A later edit to the source ATC never rewrites a Run already in flight or finished — the chain is *snapshotted*, not referenced live.
3. Step-level re-marking is deliberately lenient (last-write-wins); Run-level terminal transitions are deliberately strict (permanent, no RPC path back).

**Endpoints**: `POST /runs`, `POST /runs/{id}/steps/{stepId}/mark`, `POST /runs/{id}/finish`, `POST /runs/{id}/abort`, `GET /runs/{id}`, `GET /tests/{id}/runs`
**Entities**: Test, Test Step, Run, Run ATC, Run Step, Project Environment — `business-data-map.md §3.8` (BR-3, BR-4), §4.1, §4.2
**Feature IDs**: FEAT-030, FEAT-031, FEAT-032, FEAT-033, FEAT-034

### 3.5 Bug Filing & Lifecycle

Closes the loop from a failed Run Step — or a standalone finding — to a tracked, forward-only defect record.

```
Human -> POST /bugs {title, severity, module_id, run_id?, run_step_id?, atc_id?,
                      steps_to_reproduce, evidence_urls[]}              [Dual]
        -> bugs row, status='open'; all 3 provenance FKs nullable (on delete set null — never orphaned)
        -> activity_log row -> notification fan-out (reporter + assignee, see §5)
Owner/Admin/Member -> POST /bugs/{id}/assign {assignee_user_id}
        -> rejected unless assignee is an active, non-viewer workspace_member (BR-6)
Any authorized -> POST /bugs/{id}/status {status}
        -> forward-only, one stage at a time: open -> in_progress -> resolved -> closed
        -> skip or backward move rejected by BOTH the RPC and a DB trigger backstop (defense in depth)
```

1. A Bug can carry full provenance back to the Run/Step/ATC that surfaced it, or be filed standalone — the schema treats both as first-class.
2. The forward-only status rule is enforced twice, independently — a strong signal (per `business-feature-map.md §8.2`) that the team already treats this rule as regression-prone.

**Endpoints**: `POST /bugs`, `POST /bugs/{id}/assign`, `POST /bugs/{id}/status`, `GET /bugs`, `GET /projects/{id}/bugs`, `GET /projects/{id}/bugs/heatmap`
**Entities**: Bug, Run, Run Step, ATC, Workspace Member — `business-data-map.md §3.9` (BR-5, BR-6), §4.3
**Feature IDs**: FEAT-035, FEAT-036, FEAT-037, FEAT-038, FEAT-039

### 3.6 PAT Issuance → Scoped Automation Call

The mechanism that makes the whole product usable by a non-human caller at all — mint a least-privilege, revocable credential, then use it exactly like a browser session would be used.

```
Owner/Admin/Member (cookie) -> POST /tokens {name, scopes[], expires_at?}   [Cookie-only]
        -> access_tokens row (token_prefix stored); secret hash split into access_token_secrets
        -> workspace:admin scope retro-enforced: issuer must actually hold admin/owner (BK-135 remediation)
        -> raw token bk_pat_<prefix>.<secret> shown ONCE
Script/CI/Agent -> Authorization: Bearer bk_pat_...  on any Dual-tier route
        -> requireBearerToken() verifies prefix+hash; rejects revoked/expired -> uniform 401
        -> requireCapability(scope) per route
        -> assertWorkspaceContext() blocks cross-workspace use of a scoped token
        -> impersonatingClient(userId) -> RLS applies exactly as the browser session would
```

1. `workspace:admin` is retro-enforced against the issuer's *actual* role at mint time — migration `0033_remediate_bk135_admin_scope.sql` exists specifically because this class of bug happened once already (`business-feature-map.md §8.2`).
2. There is no global-admin PAT — a token is either unscoped (and therefore cannot perform any workspace-admin op) or bound to exactly one workspace.

**Endpoints**: `POST /tokens`, `GET /tokens`, `DELETE /tokens/{id}`, then any Dual-tier route
**Entities**: Access Token (PAT), Workspace Member — `business-data-map.md §3.12`
**Feature IDs**: FEAT-006

### 3.7 Cross-Workspace Isolation (the tenant boundary under a live call)

Not a feature a user "does" — the structural guarantee every other journey above depends on. Proves the tenant boundary holds even when the caller presents genuinely valid credentials for a *different* workspace.

```
PAT holder (token scoped to Workspace A) -> POST /workspaces/{B-id}/invites {...}  (B != A)
        -> resolveIdentity(): Principal{ via:'bearer', workspaceId: A }
        -> assertWorkspaceContext(principal, B) -> workspaceId (A) != target (B) -> 403 immediately
        -> TS-layer check fires before any DB round-trip for workspace-admin-shaped ops

PAT holder (same token) -> GET /projects/{B-project-id}/coverage   (not gated by assertWorkspaceContext —
                                                                     a read op, not workspace-admin-shaped)
        -> principal.db = impersonatingClient(userId): short-lived JWT carrying auth.uid()
        -> Postgres RLS policy on the target tables evaluates workspace_members membership for that uid
           in Workspace B -> no matching row -> empty result / 403 at the DB layer, never A's or B's data leaks

Cookie-session holder (member of Workspace A only) -> GET /workspaces/{B-id}/notifications
        -> cookie principal holds ALL_CAPABILITIES (TS-layer check passes trivially)
        -> RLS on notifications.recipient_id still requires actual Workspace B membership -> zero rows,
           not another tenant's inbox — the DB layer is the backstop even when the TS layer is permissive
```

1. Two independent layers gate this: an explicit TS-layer check (`assertWorkspaceContext`) for workspace-admin-shaped bearer calls, and Postgres RLS underneath *everything*, cookie or bearer, admin-shaped or not.
2. This is why `business-feature-map.md §8.2` flags tenant isolation as the single highest-risk area to test explicitly with cross-workspace PAT/cookie attempts, not just happy-path coverage — a bug in the TS layer is still caught by RLS, but a bug in *both* is a full tenant-boundary breach.

**Endpoints**: representative, not exhaustive — any Dual-tier route is a candidate for this test shape
**Entities**: Workspace, Workspace Member — the tenant boundary itself, `business-data-map.md §1` (Actors diagram), §2
**Feature IDs**: cross-cutting; flagged HIGH risk in `business-feature-map.md §8.2`

---

## 4. Architecture behind the API

```
Client (Browser / CI pipeline / Script / AI Agent)
        |  HTTPS
        v
Vercel Edge / Serverless  (Next.js 15 App Router)
        |-- middleware.ts            UI page auth gate (cookie-only; redirects browser nav to /login)
        |-- app/api/v1/**/route.ts   82 operations, versioned REST surface
        v
lib/api/handler.ts   withApiHandler()  <-- single gateway every route passes through
        |-- lib/api/principal.ts            resolveIdentity() -> Principal (cookie | bearer)
        |-- lib/api/middleware/bearer.ts     requireBearerToken() (PAT verify)
        |-- lib/api/idempotency.ts           generic POST replay via idempotency_keys
        v
Business logic  (route handlers + Postgres RPCs: bunkai_create_atc, bunkai_create_run,
                  bunkai_transition_bug_status, bunkai_bootstrap_workspace, ...)
        v
Supabase Postgres 17   (RLS on every table — the actual authorization boundary)
        |-- Realtime channel (runs, notifications) --> pushed to open UI sessions
        v
Vercel after() background slot --> Jira import worker (fire-and-forget, post-response)
        v
Jira Cloud REST v3  (external, pull-based, one-way)
```

| Component | Role | Persistence / integrations touched | Why it matters for QA |
|---|---|---|---|
| Next.js Route Handlers (`app/api/v1/**`) | The versioned REST surface, 82 operations | Supabase Postgres via `principal.db` | Where the 401/403/422/5xx contract is actually set — test against this layer, not just the UI |
| `lib/api/handler.ts` (`withApiHandler`) | Single auth/error/logging gateway wrapping every route | none directly | Highest blast-radius file in the API — a regression here breaks every endpoint at once, not just one feature |
| `lib/api/principal.ts` + `lib/api/middleware/bearer.ts` | Identity resolution; cookie/PAT parity | `access_tokens`, `access_token_secrets` | Security-critical, and per `business-feature-map.md §8.1` `lib/auth/` carries only 2 `bun:test` files — thin relative to blast radius |
| Postgres RPCs (`bunkai_*`) | Business-rule enforcement (BR-1 through BR-9) | Supabase Postgres | Rules like the ATC anchoring moat and the bug forward-only lifecycle live *here*, not in TypeScript — there is no way to bypass them by calling the RPC directly, since only the API can reach them |
| Row-Level Security policies | Tenant isolation, final authorization | every table | The real security boundary (§3.7) — a cross-workspace call must fail here even when a TS-layer check is missing or buggy |
| Vercel `after()` background slot | Async Jira import worker | Jira Cloud REST v3 | Fire-and-forget: the triggering request only confirms the job was *queued*; success/failure is discoverable only by polling `GET /imports/{id}` |
| Supabase Realtime | Push channel for Run/Notification live updates | Postgres logical replication | UI-only concern — a plain REST test suite never observes this channel; live-update assertions need a separate test strategy |

The OpenAPI spec's own `servers` array (`public/openapi.json`) names `https://upexbunkai.vercel.app` as **Production** and `https://staging-upexbunkai.vercel.app` as **Staging** — corroborating (though not independently re-verifying beyond the spec's own claim) the naming-convention guess already carried in `.context/project-config.md`.

---

## 5. External integrations

| Service | Trigger | Direction | Failure mode (user-visible) | Journeys affected |
|---|---|---|---|---|
| Supabase Auth | signup / signin / magic-link / OAuth / OTP / session refresh | Outbound sync | Auth call fails → generic error surfaced on the sign-in form; a mid-session outage fails every subsequent cookie-tier API call at `resolveIdentity()` with a 401 | Sign-up & Bootstrap (§3.1); every other journey indirectly, since all require an established session or PAT |
| Supabase Postgres (+ RLS) | every read/write via `principal.db` | Outbound sync | Outage/latency → every endpoint fails or hangs (no secondary datastore, per `business-data-map.md §6.1`); an RLS misconfiguration produces a *silent empty result*, not an error — the failure mode is invisible unless specifically tested for | All 7 journeys — this is the system of record |
| Supabase Realtime | Run + Notification live push | Outbound async (subscribe) | Channel drop → UI silently stops updating with no error shown; the user must refresh or poll `GET /runs/{id}` / the notifications endpoint to recover | Run Execution (§3.4), Bug Filing's notification fan-out (§3.5) |
| Vercel `after()` | Jira import worker (fire-and-forget, post-response) | Outbound (platform-internal) | No delivery guarantee on serverless timeout; a job can stay `queued`/`running` indefinitely with zero user-visible error until someone polls `GET /imports/{id}` | Jira Import (§3.2) |
| Jira Cloud REST v3 | `POST /imports` triggers a worker-side pull | Outbound sync (worker-side, `lib/jira/client.ts`) | 401/403 → `JiraAuthError` fails the *whole* import job; other non-2xx → `JiraError`; 429 → retried with exponential backoff (1s/2s/4s/8s/16s) before giving up | Jira Import (§3.2) |
| GitHub / Google OAuth | "Sign in with GitHub/Google" | Outbound sync (redirect) | Provider unreachable → documented fallback to magic-link (`lib/auth/oauth.ts:42`) rather than a dead end | Sign-up & Bootstrap (§3.1) |
| Scalar (`/api/docs`) | Developer browsing the API reference | none (static render of `public/openapi.json`) | n/a — documentation-rendering dependency only, no runtime data flow, not a business journey | none |

Reused from `business-feature-map.md §6` with the failure-mode column added, per this doctrine's mandate — see §6 for the original integration table (which also carries package-name evidence per integration).

---

## 6. Cross-references

- **Entities** referenced above → `.context/business/business-data-map.md §2` (Entity Map), `§3` (Business Flows — same numbering reused where journeys align 1:1: §3.1 Sign-up, §3.4 Jira Import, §3.6 ATC Authoring, §3.8 Run Execution, §3.9 Bug Filing, §3.12 PAT Issuance), `§4` (State Machines: Run, Run ATC/Step, Bug, Workspace Member, Import Job).
- **Features** referenced above → `.context/business/business-feature-map.md §2` (feature catalog, FEAT-001 through FEAT-052), `§3` (CRUD matrix — cited in §3.3 and §3.7 above for the missing single-`GET`/`DELETE` findings on Project/Module/ATC), `§4` (full 82-operation endpoint inventory with per-op auth tier), `§6` (third-party integrations, source of §5's table before the failure-mode column was added), `§8` (QA relevance — risk ranking that §3.7's tenant-isolation journey and §4's `lib/auth/` coverage note both draw from).
- **OpenAPI spec of record**: `../upex-bunkai-tms/public/openapi.json` (82 operations; also served live at `/api/docs` via Scalar). Full request/response schemas, every field, every status code — not restated here.
- **Generated TypeScript types**: `api/schemas/` in this repo (`openapi-types.ts`, `auth.types.ts`, plus a generated `schemas/` subdirectory), refreshed via `bun run api:sync`.
- **Risk-ranked "what to test and why"**: `.context/master-test-plan.md` (not yet generated in this project as of this writing — see Discovery Gaps).

---

## 7. Discovery gaps

1. **ADR-0001, ADR-0005, ADR-0006 are cited by name in code comments** (`lib/api/handler.ts`, `lib/api/principal.ts`) — "unified auth," "no global admin," "workspace binding" — but no matching ADR document was located under `upex-bunkai-tms/docs/` in this pass. The design intent was reconstructed from the comments and the code behavior itself, not from a written decision record. If the target repo maintains ADRs elsewhere (a location this pass didn't check), the actual rationale/alternatives-considered text is missing from this narrative.
2. **`.env.example` in the target repo lists `RESEND_API_KEY`** with a comment claiming it is "used by application code," but no `resend` package appears in `package.json` and no code reference to it was found in `lib/`/`app/` in this or the prior two context-generation passes. The `.env.example` file itself carries generic AI-dev-boilerplate scaffolding language (references to `.claude/skills/`, `cli/install.ts`, `/sprint-development`) suggesting the target repo was bootstrapped from the same tooling template this QA repo uses, and this entry may be template boilerplate rather than a verified wire-up. This refines rather than contradicts the existing gap already logged in `business-data-map.md §7` ("notification email delivery mechanism unconfirmed") — treat email delivery as still unconfirmed, not as resolved by this env-var sighting.
3. **Idempotency for generic POST replay** (`lib/api/idempotency.ts`, referenced in the architecture diagram §4) was confirmed to exist by filename and by its use in the Run-start idempotency contract (`start_token`, §3.4), but its exact mechanics for *other* POST endpoints (which ones honor an `idempotency_keys` header, what the replay window is outside the Run case) were not independently traced through the file in this pass.
4. **`.context/master-test-plan.md` does not yet exist** in this project — §6's pointer to it is forward-looking, not a confirmed live document as of this generation.
5. **Journey cap**: 7 journeys were selected against revenue/security/core-value/blast-radius criteria; no revenue-impact journey exists to select because the product has no billing integration (`business-model.md` already flags "Revenue Streams: Unknown"), so security and blast-radius journeys (PAT issuance, cross-workspace isolation) fill that slot instead. Other reasonable candidates not selected: Team Invite & Join (FEAT-010/011, lower blast-radius than the ones chosen), Notification Delivery (FEAT-040-042, already carries a known correctness gap documented in the data-map rather than a clean journey to narrate), and the Reporting suite (FEAT-043-047, aggregate/derived views over the journeys already covered, not a distinct write-path story).
6. **Full bodies of most `components/**/*.tsx` UI files were not opened** in this pass (consistent with the same limitation already logged in `business-feature-map.md §9.6`) — the journeys above trace the API/DB path precisely (source code read directly) but the exact client-side request-building code (e.g., how `RunnerView.tsx` sequences its `mark` calls, or exact retry/error-toast behavior on the frontend) was not independently verified.

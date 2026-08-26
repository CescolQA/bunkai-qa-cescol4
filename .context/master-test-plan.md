# Master Test Plan — Bunkai TMS

> Generated: 2026-08-26 · Sources: `.context/business/business-data-map.md`, `.context/business/business-feature-map.md`, `.context/business/business-api-map.md` (all generated 2026-08-26), plus `git -C ../upex-bunkai-tms log --oneline -90 --stat` for breakage-likelihood signal.

```
+------------------------------------------------------------------+
|                                                                    |
|   BUNKAI TMS  —  Master Test Plan                                 |
|   What to test in this system, and why it matters                 |
|                                                                    |
+------------------------------------------------------------------+
```

---

## 1. Where to start

You're QA-ing a multi-tenant test-management product whose entire pitch is "we can prove your coverage is real, not just claimed." That means the areas that hurt the most when they break aren't the flashy screens — they're the invisible guarantees: that Workspace A never sees Workspace B's data, that a Run's history can't be rewritten after the fact, that a test case can't exist without a requirement behind it. This plan ranks what to test first by what actually breaks the business if it fails, not by what's easiest to click through.

Two things should shape how you read this. First, the product has **no revenue/billing surface** (`business-model.md` already flags "Revenue Streams: Unknown"), so security and blast-radius carry the weight that "checkout" or "payment" would carry elsewhere — tenant isolation and auth are effectively this product's "money" flows. Second, the git history isn't hypothetical here: several of the CRITICAL flows below already produced real bugs in the last 90 commits — a cross-tenant traceability leak (BK-329), a bearer-token workspace-boundary bypass (BK-316), an ATC search isolation flake (BK-401), and a magic-link auth statelessness bug (BK-400). This isn't a plan built on guesswork about what *might* break; it's built partly on what already did.

---

## 2. Executive risk map

Nine flows made the cut below. Six are CRITICAL because a failure there either breaches the tenant boundary, corrupts the traceability chain the whole product sells, or silently produces a wrong report the team has already shipped once before (migration `0050`). The three HIGH rows are the flows that gate or feed those CRITICAL ones — get the front door and the defect loop wrong, and everything downstream is untestable or untrustworthy too. Everything else — Jira import, milestones, environments, the CRUD gaps on Project/Module/ATC — is real but lower blast-radius, and is covered as a short list at the end of §8 instead of taking a table row here.

| Priority | Flow | Why it matters | Depends on / Affects |
|---|---|---|---|
| CRITICAL | Cross-Workspace Tenant Isolation | RLS is the *only* enforcement layer once a request reaches the DB; a leak here breaks the entire multi-tenant promise | Every flow in this table |
| CRITICAL | Auth & Session (magic-link, OAuth, PAT dual-auth) | Security-critical front door; `lib/auth/` has just 2 test files against the widest blast radius in the app | Everything gated by login or a bearer token |
| CRITICAL | PAT Scope Enforcement | A scope bypass lets a narrowly-issued token act workspace-wide; this exact bug class shipped once already (BK-135) | Every Dual-tier API route, CI/agent automation |
| CRITICAL | ATC Anchoring Moat & Editing | The product's structural differentiator — a test case that can't exist without a requirement link; a bypass silently breaks traceability | Test Composition, Run Execution, Coverage/Traceability reports |
| CRITICAL | Run Execution (start → mark → finish/abort) | The automation-safety guarantee (idempotent start, immutable snapshot) that makes CI/agent retries safe | Bug Filing (provenance), Coverage, Traceability, Recovery-Cycle Metrics |
| CRITICAL | Coverage / Traceability / Defect Heatmap Reporting | This *is* the product's value proposition ("are we actually covered"), and it has already been quietly wrong once (migration `0050`) | Every upstream authoring + execution flow it summarizes |
| HIGH | Sign-up & Workspace Bootstrap | The only entry point into the product; a very recent statelessness bug (BK-400) shipped in exactly this flow | Everything — no workspace, no access |
| HIGH | Bug Filing, Assignment & Status Lifecycle | Forward-only status is enforced at *two* independent layers (RPC + trigger) — a strong signal the team already treats it as regression-prone | Notification fan-out, Defect Heatmap, Recovery-Cycle Metrics |
| HIGH | Test Composition (ATC chaining) | The bridge between authored ATCs and executable Runs; a broken chain silently produces a Run that tests the wrong thing | Run Execution, Coverage |

---

## 3. What to test first and why

### 3.1 Cross-Workspace Tenant Isolation

**Why it matters**: Workspace is the entire trust boundary of this product — a customer's data crossing into another customer's workspace isn't a bug, it's the kind of incident that ends the relationship. Every other flow in this document assumes this boundary holds.

**What commonly breaks**: `business-api-map.md §3.7` documents two independent gates — a TS-layer `assertWorkspaceContext()` check for workspace-admin-shaped bearer calls, and Postgres RLS underneath *everything else*. A bug in the TS layer alone is still caught by RLS; a bug in *both* is a full breach. This isn't theoretical: BK-329 (`fix(BK-329): reject a traceability {projectId}/story pair that does not belong together`) was exactly this failure mode inside the Traceability feature, and BK-401 fixed an ATC search isolation flake caused by shared-table data drift across tenants.

**Dependencies**: every entity ultimately resolves to one `workspace_id` (`business-data-map.md §1`); this is the substrate every other flow sits on.

**What an experienced QA would check**:
- A PAT scoped to Workspace A attempting any read *and* write operation against Workspace B's resources — not just the workspace-admin-shaped ones the TS layer explicitly guards, per the api-map's own distinction between the two gate types.
- A cookie-session user who is a member of Workspace A only, hitting Workspace B's notifications, coverage, and traceability endpoints — confirm RLS returns empty, not another tenant's data.
- Re-run the exact shape of BK-329 and BK-401 against the *current* code as a standing regression check, not a one-time fix verification.
- Any endpoint that accepts a `{projectId}/storyId}`-style compound identifier — verify cross-workspace and cross-project mismatches are rejected, not silently coerced.

### 3.2 Auth & Session (magic-link, OAuth, PAT dual-auth)

**Why it matters**: `business-api-map.md §1` states the whole architecture is built so a human clicking through the browser and a script holding a token "must behave identically" — auth is the seam where that parity can quietly diverge, and everything else in the app is unreachable without it.

**What commonly breaks**: `business-feature-map.md §8.1` flags `lib/auth/` at only 2 test files — the thinnest coverage relative to blast radius in the whole codebase. The signal isn't hypothetical: BK-400 (`fix(BK-400): verify magic links statelessly so they work on any device`) shipped within the last 90 commits, meaning cross-device magic-link redemption was broken until very recently — a strong candidate for a fresh regression check, not just a closed ticket.

**Dependencies**: every Dual-tier and Cookie-only route (`business-api-map.md §2.1`); Workspace Bootstrap (§3.7 below) can't happen without a session first.

**What an experienced QA would check**:
- Magic-link requested on one device/browser and redeemed on a different one — the exact shape of BK-400.
- OAuth provider unreachable — confirm the documented fallback to magic-link actually surfaces (`lib/auth/oauth.ts:42`), not a dead end.
- No automatic identity linking when a second OAuth provider presents the same email — confirmed intentional in code (`lib/auth/oauth.ts:17`), but worth verifying the user-facing behavior is a clear error, not silent account confusion.
- Headless password sign-in (`POST /auth/signin`) returning a usable PAT in the same response, for the CI/agent-only entry path that never touches a cookie.

### 3.3 PAT Scope Enforcement

**Why it matters**: this is the mechanism that makes the product usable by anything other than a human in a browser — CI pipelines and AI agents authenticate entirely through scoped tokens. A scope bypass means a token minted for read-only ATC access could, in the worst case, act with workspace-admin power.

**What commonly breaks**: this exact bug class has already happened — migration `0033_remediate_bk135_admin_scope.sql` exists specifically because `workspace:admin` scope wasn't originally retro-checked against the issuer's real role. Separately, BK-316 (`fix(BK-316): reject bearer callers on POST /api/v1/me/active-workspace`) shipped a fix for a bearer token being allowed to hit a route it shouldn't have reached — a live example of the cookie/bearer parity boundary slipping.

**Dependencies**: every Dual-tier route in the 82-operation API surface; the 4 Cookie-only routes are the explicit exception list to re-verify a PAT still can't touch (`business-api-map.md §2.1`).

**What an experienced QA would check**:
- Issue a token with a narrow scope (e.g. `atc:read` only) and confirm every write-shaped and admin-shaped route rejects it, not just the one this domain's tests already cover.
- Re-verify the BK-316 fix holds: a bearer token against `/me/active-workspace` and any other route that is conceptually "session-shaped" rather than "API-shaped."
- A token minted by a member who later loses admin/owner role — confirm the token doesn't retain elevated scope after the demotion (the BK-135 class of bug, from the other direction).
- Revoked and expired tokens both return the same uniform 401 as an unknown token — confirm no information leak about *why* a token failed.

### 3.4 ATC Anchoring Moat & Editing

**Why it matters**: `business-data-map.md §3.6` and `business-api-map.md §3.3` both call this "the anchoring moat" — an ATC is structurally incapable of existing without linking to at least one Acceptance Criterion on its own parent Story. This is the guarantee the entire traceability chain (and the product's core pitch) is built on.

**What commonly breaks**: enforcement lives in the RPC (`bunkai_create_atc`), not a raw foreign key — meaning a new code path that writes ATCs some other way could bypass it entirely without the database complaining. `business-feature-map.md §8.2` calls this HIGH risk for exactly that reason: "a bypass silently breaks the traceability promise the whole product sells." Note also the confirmed dead column `atcs.status` — don't write or trust a test that expects this column to change after a Run; the real verdict lives on `run_atcs.status` (`business-data-map.md §3.6`).

**Dependencies**: consumed by Test Composition (an ATC is *referenced*, not copied, into a Test) and then *snapshotted* into a Run — this reference-then-snapshot design is why editing an ATC never corrupts a Run already in flight.

**What an experienced QA would check**:
- Attempt to create an ATC with zero AC links, and with an AC that belongs to a *different* User Story — both must be rejected with `ac_outside_user_story`.
- Edit an ATC that's already chained into a finished Run — confirm the Run's snapshot is untouched (BR-3) while the live ATC's `version` increments.
- Confirm there is genuinely no `DELETE /atcs/{id}` and no single-resource `GET /atcs/{id}` in the live API — the feature-map calls this a new, unconfirmed finding worth a direct HTTP-contract test (expect a clean 404, not a 500, if you probe for it).
- Duplicate an ATC and verify the deep-copy carries steps, assertions, *and* AC bindings — a partial copy would silently reintroduce the anchoring gap on the duplicate.

### 3.5 Run Execution (start → mark → finish/abort)

**Why it matters**: this is the record of "did it pass" — and per `business-api-map.md §3.4`, the idempotency contract (`start_token`) is the concrete guarantee that makes CI/agent retries safe. A duplicate Run or a retroactively-mutated one corrupts audit trust for every downstream report.

**What commonly breaks**: `business-data-map.md §4.1` is explicit that no RPC ever transitions a Run out of a terminal state (`passed`/`failed`/`aborted` are permanent) — but Run *Step* re-marking is deliberately the opposite: last-write-wins, no conflict error. That asymmetry is easy to test backwards. Also worth noting: BK-330 (`fix(BK-330): make the snapshot capture instant second-granular, not just the filename`) shows snapshot timing precision has already been a source of bugs in this area.

**Dependencies**: feeds Bug Filing (provenance FKs), Coverage, Traceability, and Recovery-Cycle Metrics — a corrupted Run corrupts all four downstream.

**What an experienced QA would check**:
- Replay the same `(test_id, start_token)` pair within the 24h window and confirm it returns the *same* Run (`replayed: true`), not a duplicate — then confirm a replay *just outside* the window creates a genuinely new Run.
- Edit the source ATC while a Run built from it is still `running`, then finish the Run — confirm the finished Run's snapshot still reflects the *pre-edit* ATC content.
- Re-mark a Run Step from `passed` to `failed` and back — confirm no conflict error, and confirm the parent `run_atcs.status` recomputes correctly from siblings rather than being stuck on a stale value.
- Abort a Run with steps still `pending` — confirm they auto-flip to `skipped`, and that this Run can never be transitioned again afterward.

### 3.6 Coverage / Traceability / Defect Heatmap Reporting

**Why it matters**: `business-data-map.md §3.11` is blunt about this — these derived views exist specifically to answer "are we actually covered, and where is quality risk concentrating," not just "did the last run pass." This is the product's actual value proposition, not a side feature.

**What commonly breaks**: migration `0050_project_coverage_report_real_execution_source.sql` is itself proof this has already broken silently once — an earlier version of the Coverage report was sourced from the dead `atcs.status` column instead of the real `run_atcs.status`, and nobody caught it until the fix shipped. `business-feature-map.md §8.1` confirms `lib/coverage/` still only has 3 test files for a report with this exact failure history. Traceability specifically has had heavy, very recent churn — BK-48 wired in module/date-range/result filters, BK-50 added an HTML export, and BK-329 fixed the cross-tenant leak described in §3.1 — all within the same window, which stacks regression risk on top of an already-fragile report.

**Dependencies**: summarizes every authoring and execution flow above it — Story, AC, ATC, Test, Run, Bug.

**What an experienced QA would check**:
- Build a fixture with a known mix of covered/uncovered ACs and confirm the Coverage report's percentage matches exactly — don't trust the query, validate against fixture data, per the doctrine `0050` itself already proved necessary.
- Exercise the new BK-48 filters (module, date range, result) in combination, not just individually, since combinatorial filter bugs are the most common regression in freshly-added filter UIs.
- Export a Traceability chain to HTML (BK-50) and confirm the exported snapshot matches what's on screen, including after an abort mid-export.
- Confirm the Heatmap's per-module bug density reflects a bug's *current* module (not a stale one) if the bug's module or story is later changed.

### 3.7 Sign-up & Workspace Bootstrap

**Why it matters**: `business-data-map.md §3.1` — there's no "invite yourself" step; every single user's relationship with the product starts here. Get this wrong and nothing downstream is even reachable to test.

**What commonly breaks**: BK-400 shipped a fix for magic-link redemption failing across devices — meaning this exact flow was broken in a way that would silently lock out real users until very recently. The bootstrap RPC (`bunkai_bootstrap_workspace`) guarantees exactly one `owner` at creation, but that guarantee is only ever *checked* later, at leave-time (BR-8) — worth confirming it actually holds at creation too, not just assumed.

**Dependencies**: gates every other flow in this plan; Team Invite & Join and PAT Issuance both build on a Workspace already existing.

**What an experienced QA would check**:
- Complete the magic-link flow starting on one device and finishing on another (the BK-400 shape) across at least two browser/device combinations.
- Confirm `/auth/confirm` and `/auth/signin` both return a usable PAT in the same response as the session, so a headless/CI onboarding path never needs a browser at all.
- New user with zero workspaces — confirm they land on `/onboarding` and cannot reach any workspace-scoped route until bootstrap completes.
- OAuth sign-up when the provider is unreachable — confirm the magic-link fallback path is actually offered, not a dead-end error screen.

### 3.8 Bug Filing, Assignment & Status Lifecycle

**Why it matters**: this is the loop-closing mechanism — `business-data-map.md §3.9` — from a failed Run Step (or a standalone finding) to a tracked fix. If the status lifecycle or assignment rules can be bypassed, the defect record stops being trustworthy for the Recovery-Cycle and Heatmap reports that depend on it.

**What commonly breaks**: `business-feature-map.md §8.2` explicitly flags that the forward-only status rule is enforced at *two* independent layers — the RPC and a DB trigger backstop — and calls this "a strong signal the team already treats this rule as regression-prone." That's not a hypothetical concern; that's the team's own defense-in-depth telling you where they expect the next bug.

**Dependencies**: notification fan-out (§5 below) fires off both assignment and status-change events; Recovery-Cycle Metrics and the Defect Heatmap both read this data.

**What an experienced QA would check**:
- Attempt a skip transition (`open` → `resolved`) and a backward transition (`in_progress` → `open`) — confirm both are rejected, and confirm the rejection happens even if you could somehow bypass the RPC (the trigger backstop should still catch it).
- Assign a bug to a `viewer`-role member, and to a suspended member — both must be rejected per BR-6.
- Self-assign and self-reassign a bug — confirm the actor *does* get notified for assignment (unlike status changes, where the actor is excluded — this asymmetry is easy to get backwards in a fix).
- File a bug with full provenance (`run_id`, `run_step_id`, `atc_id`), then delete the source Run — confirm the Bug survives with those FKs nulled, not orphaned or broken.

### 3.9 Test Composition (ATC chaining)

**Why it matters**: this is the assembly step between "I've authored a test case" and "I can actually run it" — a broken chain means a Run silently executes the wrong steps, which corrupts every downstream Coverage and Traceability signal without any obvious symptom.

**What commonly breaks**: `business-data-map.md §3.7` notes a Test is workspace-scoped, not project-scoped, so it can span projects — and the same ATC may appear at multiple chain positions with no uniqueness constraint. Both of those are easy assumptions to get wrong when building fixtures or writing new features against Tests.

**Dependencies**: feeds directly into Run Execution (§3.5) — a Test's chain is what gets snapshotted at Run start.

**What an experienced QA would check**:
- Chain the same ATC into two different positions in one Test, then reorder — confirm both positions track independently and the reorder doesn't collapse or duplicate them.
- Build a Test spanning ATCs from more than one Project inside the same Workspace — confirm this is genuinely allowed end-to-end, including at Run time.
- Apply a reserved tag (`smoke`, `sanity`, `regression`) in mixed case and confirm it normalizes to lowercase, while a custom tag preserves its casing (BR-9).
- Start a Run from a Test whose chain was reordered *after* a previous Run already started from the old order — confirm the old Run's snapshot is unaffected.

---

## 4. State machines that matter

### 4.1 Run Status (`running → passed | failed | aborted`)

**Why the transitions matter**: this is the authoritative record of whether a Test chain passed — everything from Coverage to CI gating decisions ultimately reads this value. An illegal transition (resurrecting a terminal Run) would let someone quietly rewrite execution history.

**Transitions most likely to be broken**: none of the terminal transitions themselves — `business-data-map.md §4.1` confirms no RPC path exists back out of `passed`/`failed`/`aborted`. The actual risk is at the *step* level underneath it: Run Step re-marking is last-write-wins with no conflict error, which is easy to confuse with the Run-level strictness above it when writing a new feature against this area.

**Terminal / forbidden states to guard**: `passed`, `failed`, `aborted` are all permanent — any code path that could flip a Run out of one of these is a bug by definition, not a feature.

**How corruption would be detected**: not automatically — there's no audit alert on an illegal transition attempt beyond the RPC/DB rejecting it. A silent corruption would only surface downstream, as a Coverage or Recovery-Cycle number that doesn't match what a human remembers happening.

### 4.2 Bug Status (`open → in_progress → resolved → closed`)

**Why the transitions matter**: this is the operational backbone of the defect-management loop — skip or backward transitions would let a bug appear "resolved" without ever passing through investigation, or bounce indefinitely between states in a way that breaks Recovery-Cycle time math.

**Transitions most likely to be broken**: any skip (`open → resolved`) or backward move (`resolved → in_progress`) — flagged HIGH risk precisely because it's enforced at two layers already (§3.8 above).

**Terminal / forbidden states to guard**: `closed` is terminal; no transition exists past it.

**How corruption would be detected**: the trigger backstop (`bugs_check_consistency`) raises a distinct error code for skip (`45310`) vs. backward (`45311`) — so a test can assert on *which* violation was caught, not just that one was.

### 4.3 Workspace Member Status (`invited → active ↔ suspended`, `active → removed`)

**Why the transitions matter**: this gates who can even reach the app — an incorrectly-suspended member loses all access, and an incorrectly-restored one regains it. The "leave" path additionally guards the sole-owner invariant (BR-8): a workspace can never be left ownerless.

**Transitions most likely to be broken**: `active ↔ suspended` — flagged as a Discovery Gap in both `business-data-map.md §4.4` and `business-feature-map.md §3` because the actual RPC/route performing this flip was never located in either pass. Treat this as genuinely unverified, not just "probably fine."

**Terminal / forbidden states to guard**: removal is rejected outright if it's the caller's only membership, or if the caller is the workspace's sole active owner — both are BR-8 guards worth testing directly, including the edge case of the *second-to-last* owner leaving (should succeed) vs. the *last* owner leaving (should fail).

**How corruption would be detected**: not confirmed — since the transition endpoint itself is unlocated, there's no confirmed audit trail specific to this state change beyond the general `activity_log`.

---

## 5. Silent killers — automated processes with no UI feedback path

This is usually the most undertested area of any system, and Bunkai is no exception — several processes here fail (or half-fail) without ever showing a human an error.

### 5.1 Run/Bug notification fan-out (`activity_log` triggers → `notifications`)

**What it does**: `bunkai_assign_bug`, `bunkai_transition_bug_status`, `bunkai_finish_run`, and `bunkai_abort_run` all write an `activity_log` row in the same transaction as the mutation; an `AFTER INSERT` trigger on `activity_log` fans that out into per-recipient `notifications` rows (`business-data-map.md §3.10`, §5.1).

**What breaks if it misses a run, runs twice, or runs out of order**: this is not hypothetical — it's already happening. Migration `0067_run_finish_abort_via.sql`, which would suppress a self-finish notification (a user finishing their own Run shouldn't be told "your Run finished" by themselves), is **explicitly not applied** to the live database per its own header. Every terminal Run event currently over-notifies the starter, including same-session self-finishes, contrary to the fully-ratified design in `0066_run_event_notifications.sql`.

**How failure is detected today**: not at all from the user's side — a human just sees an extra, slightly nonsensical notification. There's no alert distinguishing "notification fired correctly per the old design" from "notification fired correctly per the new, unapplied design."

**Recommended QA strategy**: don't write a test asserting self-finish suppression works — it doesn't, by design of the current deployed state. Write one confirming the *actual* current behavior (over-notification), and flag it clearly as a known, live gap so a future retest after `0067` lands doesn't get confused about which behavior is "expected." Separately, verify the "Bug unassigned" no-op (deliberately no recipient) and the "self-(re)assign notifies the actor" asymmetry both still hold — both are easy to accidentally "fix" into the wrong behavior since they look like bugs at a glance.

### 5.2 Jira import worker (Vercel `after()` background slot)

**What it does**: `POST /imports` returns as soon as the job is *queued* — the actual work (paging Jira, extracting ACs, upserting Stories) runs fire-and-forget in Vercel's `after()` slot, entirely after the HTTP response has already gone out (`business-api-map.md §3.2`, §5).

**What breaks if it misses a run, runs twice, or runs out of order**: `business-api-map.md §5` states plainly there's "no delivery guarantee on serverless timeout" — a job can sit in `queued` or `running` indefinitely with zero user-visible error until someone thinks to poll `GET /imports/{id}`. A double-trigger is guarded against (atomic `UPDATE...WHERE status='queued'` claim), but a silently-stuck job is not.

**How failure is detected today**: only by manual polling — there's no timeout-triggered alert or auto-retry visible in this pass.

**Recommended QA strategy**: a synthetic probe that starts an import and asserts the job reaches a terminal state (`completed`/`failed`) within a bounded time window, run on a schedule — this is exactly the kind of check that has no natural trigger from normal UI usage, since nobody manually re-polls a job that's "probably fine."

### 5.3 RLS silent-empty-result failure mode

**What it does**: Postgres Row-Level Security is the real authorization boundary on every table (§3.1 above) — a query from a caller without the right membership doesn't error, it just returns zero rows.

**What breaks if it misses a run, runs twice, or runs out of order**: an RLS misconfiguration is functionally invisible — per `business-api-map.md §5`, "the failure mode is invisible unless specifically tested for." A too-permissive policy leaks data with no error to catch; a too-restrictive one just looks like "no data yet" to a confused user.

**How failure is detected today**: no automated detection found in this pass — this is purely a testing gap to close, not a monitored process.

**Recommended QA strategy**: scheduled audit-style tests that assert both directions explicitly — a legitimate member *does* see their workspace's data, and an illegitimate one gets an empty result, not an error. An empty result alone is not proof of correct isolation; it needs to be paired with the positive case in the same test run.

---

## 6. External integrations — failure points

### Supabase (Auth + Postgres + Realtime)

**Which flow stops if down**: all of them — `business-data-map.md §6.1` is explicit that there's no secondary datastore, so an outage fails every read and write across the entire product.

**Timeouts / retries**: not independently verified in this pass (no chaos/outage test performed).

**Acceptable degradation**: none confirmed — architecturally a hard-fail, not a graceful one.

**Known quirks**: an RLS misconfiguration produces a *silent* empty result rather than an error (§5.3 above) — the one quirk worth building a specific test strategy around rather than assuming "no error means it worked."

### Vercel (hosting + `after()` background execution)

**Which flow stops if down**: the whole app (hosting), plus specifically the Jira import worker (§5.2), which depends on the `after()` slot surviving past the HTTP response.

**Timeouts / retries**: no documented retry/failover for a `after()` slot that times out mid-job.

**Acceptable degradation**: none confirmed.

**Known quirks**: a Vercel outage or serverless timeout leaves an import job stuck in `queued`/`running` with no user-visible signal (§5.2).

### Jira Cloud REST v3 (one-way import source)

**Which flow stops if down**: only the Jira Import flow (§3.4 in the data-map) — nothing else in the product depends on Jira being reachable.

**Timeouts / retries**: 429 responses are retried with exponential backoff (`1s, 2s, 4s, 8s, 16s`) before giving up (`lib/jira/client.ts:78-79`, cited in `business-data-map.md §6.3`); a 401/403 fails the *entire* job immediately as `JiraAuthError`, with no partial-success path.

**Acceptable degradation**: partial — per-issue errors are collected and recorded in the job's `errors[]` array even when the overall job succeeds, so a few malformed issues don't necessarily fail the whole import. An auth failure, by contrast, is all-or-nothing.

**Known quirks**: import is strictly one-way — nothing is ever written back to Jira, so there's no risk of the integration corrupting the source system, only of failing to pull from it correctly.

### GitHub / Google OAuth (identity providers)

**Which flow stops if down**: only OAuth sign-in specifically — magic-link remains available as a documented fallback (`lib/auth/oauth.ts:42`).

**Timeouts / retries**: not documented in this pass.

**Acceptable degradation**: graceful — the fallback to magic-link is the acceptable-degradation path by design, worth testing directly rather than assuming it works because it's documented.

**Known quirks**: no automatic identity linking across a second provider presenting the same email (`lib/auth/oauth.ts:17`) — a deliberate limitation, not a bug, but one that produces a confusing user experience if untested.

---

## 7. Dependency cascade between flows

```
Story ──► Acceptance Criterion ──► ATC ──► Test ──► Run ──► Bug ──► Notification
   │              │                 │        │        │       │          │
   │              │                 │        │        │       │          └ over-notifies today (0067 gap, §5.1)
   │              │                 │        │        │       └ feeds Heatmap + Recovery-Cycle Metrics
   │              │                 │        │        └ feeds Coverage, Traceability, Recovery-Cycle Metrics
   │              │                 │        └ feeds Coverage (never-run indicator)
   │              │                 └ anchoring moat: no AC link = ATC cannot exist at all
   │              └ Story auto-flips draft ↔ ready_to_test based on active AC count
   └ fails here = nothing downstream can be authored at all

Tenant boundary (Workspace / RLS) wraps every node above — a leak here doesn't
break one flow, it breaks the isolation guarantee every other flow assumes holds.
```

The two chains most worth testing end-to-end rather than in isolation:

1. **ATC → Test → Run → Coverage/Traceability**: testing ATC authoring alone hides bugs that only surface once a Test snapshots that ATC into a Run and a report tries to summarize it — exactly the class of bug migration `0050` fixed after it had already shipped wrong.
2. **Run → Bug → Notification → Heatmap**: a Run failure that doesn't correctly carry provenance into a filed Bug corrupts the Heatmap's module-density numbers downstream, with no obvious symptom until someone questions why a module "looks" less buggy than it should.

Testing any single node in isolation gives false confidence — the failures that matter here happen at the handoffs, not inside one node.

---

## 8. Edge cases developers commonly forget

**Flows below the executive table (short list)**: Jira Import (async, external-dependency, thin test coverage relative to its pagination/backoff/ADF-parsing complexity — MEDIUM); the missing single-resource `GET` on Project/Module/ATC (unverified whether deliberate design or a gap — MEDIUM, worth a direct HTTP-contract check); Notification Preferences' unconfirmed `email` channel delivery (MEDIUM, don't assert an email actually sends without confirming the send path first); Team Invite & Join (lower blast-radius per `business-api-map.md §7`, still worth standard CRUD + expiry coverage).

**Concurrency**
- Run Step re-marking is last-write-wins with no conflict error — two executors marking the same step near-simultaneously could produce a confusing final state that's hard to reconstruct after the fact (§4.1, §3.5).
- Import job claiming uses an atomic `UPDATE...WHERE status='queued'` specifically to prevent a duplicate/retried background trigger from double-running the same job (§5.2) — worth a race-condition test that fires the trigger twice in quick succession.
- Bug status transitions have a trigger backstop *in addition to* the RPC check specifically because the team doesn't fully trust a single enforcement point — a concurrent double-transition attempt is a natural test here.

**Data limits**
- Module tree depth is capped at 6 (`bunkai_move_module`) — test a move that would push a descendant past depth 6, and separately test the tree at exactly depth 6 (boundary, not just "over the limit").
- Jira ADF descriptions longer than 50KB are truncated during import (`business-data-map.md §3.4`) — verify the truncation point doesn't cut mid-Acceptance-Criterion in a way that corrupts extraction.
- Test chains allow the same ATC at multiple positions with no unique constraint (§3.9) — a very long chain with heavy repetition is worth a scale/perf sanity check, not just a correctness check.

**Timezone / DST**
- Milestone `target_date` must fall within today .. +5 years at write time (`business-data-map.md §3.13`) — test right at both boundaries, and specifically around a DST transition if the app's timezone handling isn't UTC-normalized.
- Run snapshot timing was recently hardened to second-granularity (BK-330) — worth confirming snapshot ordering stays correct for Runs started within the same second, since that's precisely the bug BK-330 fixed.
- Notification 90-day retention is enforced at RLS *read* time, not row deletion (`business-data-map.md §5.1`) — test a notification exactly at the 90-day boundary to confirm the cutoff is correct in both directions.

**Permission boundaries**
- A PAT with no workspace binding at all vs. one bound to a *different* workspace than the target — `assertWorkspaceContext()` should reject both, but for potentially different reasons worth distinguishing in test assertions (§3.1, §3.3).
- Bug assignment eligibility requires an active, non-viewer member (BR-6) — test assignment to a viewer, to a suspended member, and to a member who was active at assignment time but got suspended afterward.
- The sole-owner leave restriction (BR-8) — test the second-to-last owner leaving (should succeed) immediately followed by the actual last owner attempting to leave (should fail), to confirm the invariant holds across a state transition, not just in a static snapshot.

**Orphaned states**
- All three Bug provenance FKs (`run_id`, `run_step_id`, `atc_id`) are nullable with `on delete set null` — delete each source independently and confirm the Bug survives intact with just that one field nulled, not cascading further than intended.
- ATCs have no delete path at all (§3.4) — confirm every code path that might attempt one (bulk operations, admin tooling, cascading module archival) correctly refuses rather than silently no-op'ing or erroring unpredictably.
- Module soft-delete (archive) vs. its child Stories and ATCs — confirm archiving a Module doesn't orphan or silently hide Stories/ATCs that a report still expects to count.

**Idempotency**
- The `start_token` replay window is 24h — test a replay attempt at 23h59m (should replay) and immediately after the 24h mark (should create new) — this exact boundary was not independently verified in the source maps.
- The generic POST idempotency mechanism (`idempotency_keys`, referenced in `business-api-map.md §4`) has confirmed existence but unconfirmed exact mechanics beyond the Run-start case — treat any *other* POST endpoint's idempotency behavior as unverified until tested directly, not assumed to match Run's contract.

---

## 9. Pre-release checklist

1. Verify a PAT scoped to one Workspace cannot read or write any resource in a different Workspace, across both admin-shaped and plain read/write routes.
2. Verify magic-link authentication started on one device completes correctly when redeemed on a different device or browser.
3. Verify a revoked or expired PAT, and an unknown PAT, all return the identical 401 with no distinguishing error detail.
4. Verify an ATC cannot be created with zero Acceptance Criteria links or with an AC belonging to a different User Story.
5. Verify editing an ATC does not alter the snapshot of a Run that already started from it.
6. Verify replaying the same `(test_id, start_token)` within 24h returns the original Run, not a duplicate.
7. Verify no RPC or route can transition a Run out of a terminal state (`passed`/`failed`/`aborted`).
8. Verify the Coverage report's percentage matches a hand-built fixture exactly, not just "looks reasonable."
9. Verify Traceability's combined module/date-range/result filters produce correct results together, not just individually.
10. Verify a Bug status transition rejects both skip moves and backward moves, and that the rejection reason is distinguishable.
11. Verify Bug assignment rejects a viewer-role or suspended assignee.
12. Verify the sole active owner of a Workspace cannot leave it, while a non-sole owner can.
13. Verify a Run/Bug notification fires with the *current* (over-notifying) self-finish behavior, and is not asserted against the unapplied `0067` design.
14. Verify OAuth sign-in falls back to a usable magic-link path when the provider is unreachable, rather than a dead end.
15. Verify a Jira import job that starts eventually reaches a terminal state (`completed`/`failed`) within a bounded time, without requiring manual polling to notice a stall.

---

## 10. What is NOT in this plan

- Flow-level diagrams and state-machine transition tables → `.context/business/business-data-map.md`
- Feature catalog, CRUD matrix, feature flags, WIP status → `.context/business/business-feature-map.md`
- Auth-tier model, journey narratives, architecture diagram → `.context/business/business-api-map.md`
- API endpoint inventory / request-response contracts → `public/openapi.json` (target repo), `api/schemas/` (this repo, via `bun run api:sync`)
- Detailed test case definitions and traceability → TMS (see `/test-documentation`)
- Sprint-level execution order → `.context/reports/SPRINT-{N}-TESTING.md` (see `/sprint-testing`)

---

## 11. Discovery gaps

- **Workspace Member `active ↔ suspended` transition endpoint was never located** across any of the three source maps' independent passes (data-map, feature-map, and this document's own re-check) — treat §4.3's coverage of this state machine as based on the schema-level CHECK constraint and RLS gate only, not a confirmed RPC/route name.
- **Notification email delivery mechanism remains unconfirmed** — `email` is a valid `notification_preferences.channel` value and the UI exposes per-event opt-in, but no email-provider dependency was found in the target repo's `package.json` across two independent passes. Do not write a test asserting an actual email is sent without confirming the send path first.
- **`pg_cron` extension is installed but whether any job is actually scheduled is unconfirmed** — the connecting DB role lacked permission to query `cron.job`. Treat §5's silent-killer list as non-exhaustive: an unconfirmed scheduled job could exist outside what this pass could see.
- **Generic POST idempotency (`idempotency_keys`) mechanics beyond the Run-start case are unverified** — confirmed to exist by filename/architecture reference only; which other POST endpoints honor it, and their replay window, was not independently traced.
- **`test_plans` (15 live rows in staging), `feature_flags`, and `user_view_state` tables exist in the database with zero application-code call sites** — excluded entirely from this plan on purpose; do not design tests against them until they're confirmed wired to actual API/UI behavior.
- **Production environment URL is unconfirmed** — `https://upexbunkai.vercel.app` is corroborated by the OpenAPI spec's own `servers` array but not independently re-verified as the live production deploy in this pass.
- **The feature-map warning does not apply here** — `business-feature-map.md` was available at generation time, so this plan draws on all three source maps rather than data-map alone; no coverage gap from a missing source.

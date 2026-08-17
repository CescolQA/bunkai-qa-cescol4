# Non-Functional Specification — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Generated 2026-08-17.
> Sources: fresh discovery this pass — `next.config.ts`, `package.json`, `lib/api/handler.ts`, `lib/api/logging.ts`, `lib/api/error-envelope.ts`, `lib/home/coverage.ts`, `lib/jira/client.ts`, `app/api/v1/**` route greps, `app/api/v1/health/route.ts` — plus facts reused from `.context/SRS/architecture.md` (already-evidenced Performance hooks, Security Architecture sections) and `CLAUDE.md` §Project Assessment (Testing Maturity, CI/CD Maturity).
> Per the Gotchas rule in `phase-2-srs.md`: no P95/SLA/throughput number is invented anywhere below. Every numeric claim is either evidence-backed (config value, code constant) or marked `[unknown]` under the relevant NFR / Discovery Gaps.

---

## NFR Summary

| Category | Implemented | Maturity |
|---|---|---|
| Performance | Partial — targeted indexing + one deliberate in-process cache; no rate limiting, no benchmark evidence | Ad hoc |
| Security | Partial — strong authN/authZ (dual-method gateway + RLS), but no security headers/CSP, no general-purpose sanitizer | Ad hoc |
| Reliability | Partial — uniform error envelope, structured logging, health endpoint, idempotency, one real retry/backoff implementation; no React error boundaries, no circuit breakers | Ad hoc |
| Scalability | Good — stateless-by-default serverless deployment; one explicitly-documented, deliberately-scoped in-process cache as the sole exception | Managed |
| Observability | Minimal — structured JSON logs only; no APM/tracing/metrics/alerting tooling of any kind | Not implemented |

---

## 1. Performance

### NFR-PERF-001: Database query optimization via targeted indexing

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — no query-latency benchmark exists; target is inferred from index design intent (support the specific dashboard/list query it was built for) |
| **Implementation** | Deliberate composite and partial indexes on workspace/project-scoped high-traffic tables, several matched 1:1 to a specific UI query (e.g. `runs_workspace_id_started_at_running_idx` for the home "active runs" widget; `bugs_workspace_id_severity_unresolved_idx` for "open bugs"). Two GIN indexes for full-text/array search (`atcs_tsv_gin_idx`, `tests_tags_gin_idx`) |
| **Evidence** | `.context/SRS/architecture.md` → Database Schema → Indexes table (38 of 69 migration files touch indexing) |

### NFR-PERF-002: In-process response caching (Home coverage rollup)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — no TTL constant value was re-extracted this pass; the mechanism and its documented rationale are confirmed, not the exact seconds |
| **Implementation** | `lib/home/coverage.ts:335` — a plain in-process `Map<string, { expiresAt, value }>` (`rollupCache`) memoizes a completed workspace coverage rollup. Only COMPLETE rollups are cached (a transient RPC failure can never be pinned and replayed). The code comment explicitly rejects Next's `unstable_cache` (closes over a request-scoped Supabase client that reaches for cookies) and explicitly states the tradeoff: per-instance only, a cold serverless instance always pays full price, N instances mean up to N sweeps per TTL — accepted because it still removes the dominant real cost (same member reloading Home, or a team landing on it at 9am, each re-paying a full per-project sweep) |
| **Evidence** | `lib/home/coverage.ts:310-350` |

### NFR-PERF-003: Cache invalidation (Next.js `revalidatePath`)

| Aspect | Value |
|--------|-------|
| **Target** | N/A — invalidation event, not a latency target |
| **Implementation** | `revalidatePath()` used in one Server Action (`app/(app)/projects/[projectSlug]/atcs/[atcId]/actions.ts`) after ATC mutations. No general Next.js Data Cache layer adopted elsewhere in the app |
| **Evidence** | `.context/SRS/architecture.md` → Performance hooks |

### NFR-PERF-004: Rate limiting

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented at the application level |
| **Implementation** | Not implemented — no `rateLimit`, Redis, or Upstash dependency in `package.json`. The only `rate_limited` (429) responses observed (`app/api/v1/auth/{signup,resend,magic-link,confirm,check-email}/route.ts`) pass through Supabase Auth's own throttling; the app does not rate-limit any other endpoint (ATCs, Tests, Runs, Bugs, etc.) |
| **Evidence** | `lib/api/error-envelope.ts:27` (`RATE_LIMITED` code); route grep across `app/api/v1/auth/**` |

### NFR-PERF-005: Pagination strategy

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — no documented page-size limit surfaced across all endpoints this pass; the one endpoint inspected in depth (`activity`) uses an opaque cursor, not a fixed default confirmed here |
| **Implementation** | Cursor-based pagination confirmed on the Activity feed (`app/api/v1/activity/route.ts`): `?cursor=<opaque>` decodes to `(createdAt, id)`, forwarded to a Postgres RPC as `p_cursor_created_at` / `p_cursor_id`, returns `next_cursor`. An invalid cursor maps to `400 bad_request` (`activity_cursor_invalid`), not a silent reset |
| **Evidence** | `app/api/v1/activity/route.ts:22-74`; `app/api/v1/activity/route.test.ts:125-320` |

### NFR-PERF-006: Connection pooling

| Aspect | Value |
|--------|-------|
| **Target** | N/A — no app-level pool-size tuning surface exists |
| **Implementation** | The application talks to Postgres exclusively through the Supabase JS SDK (PostgREST), never a direct `pg`/Prisma connection. Supabase-managed pgbouncer pooling is implied by this QA repo's own `.env`/`.env.example` (`aws-1-us-east-1.pooler.supabase.com`, port 6543 vs 5432 non-pooling) but is not something the application code configures — `POSTGRES_*` env vars are declared in `.env.example` but confirmed unread by `app/`/`lib/` |
| **Evidence** | `.context/SRS/architecture.md` → External Services table + Performance hooks |

---

## 2. Security

### NFR-SEC-001: Authentication (dual-method, unified gateway)

| Aspect | Value |
|--------|-------|
| **Target** | Every `/api/v1` route requires auth unless explicitly marked `auth: 'public'` (secure-by-default) |
| **Implementation** | `lib/api/handler.ts` (`withApiHandler`) + `lib/api/principal.ts` (`resolveIdentity`) resolve either a Supabase SSR cookie session or a Bearer PAT (`bk_pat_*`) into one `Principal` shape (ADR-0001) |
| **Evidence** | `.context/SRS/architecture.md` → Security Architecture → Authentication |

### NFR-SEC-002: Authorization (Postgres RLS as sole source of truth)

| Aspect | Value |
|--------|-------|
| **Target** | Every data access path is tenant-scoped by `auth.uid()`-keyed RLS policy; no app-level access-control layer duplicates this in TypeScript |
| **Implementation** | Confirmed by ADR-0001's own "Finding C" and reinforced by ADR-0012 ("RPC Authorization Invariant"). PAT callers get a per-request user-scoped JWT (`impersonatingClient()`) so RLS evaluates identically regardless of auth method |
| **Evidence** | `.context/SRS/architecture.md` → Security Architecture → Authorization |

### NFR-SEC-003: Security headers / CSP

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not configured |
| **Implementation** | Not implemented. `next.config.ts` has no `headers()` function — no CSP, no `X-Frame-Options`, no `Strict-Transport-Security` at the app level. No `helmet` dependency in `package.json` (re-confirmed this pass: `helmet`, `xss`, `csrf`, `dompurify`, `validator` all absent from `package.json`). Finding, not a failing grade — recommend a security review before the app takes untrusted third-party embeds or public traffic at scale |
| **Evidence** | `next.config.ts` (full file, 12 lines, no `headers()` key); `package.json` grep (zero matches for the six package families above) |

### NFR-SEC-004: Input sanitization (Markdown rendering)

| Aspect | Value |
|--------|-------|
| **Target** | User-authored Markdown (ATC / Bug descriptions) must not execute injected HTML/script on render |
| **Implementation** | `rehype-sanitize` ^6.0 sanitizes Markdown before rendering (`lib/markdown/**`, `components/markdown/**`). This is the one explicit sanitization boundary in the app — no general-purpose `xss`/`DOMPurify`/`validator` package exists for other input surfaces (relies on Zod schema validation + Postgres constraints elsewhere) |
| **Evidence** | `.context/SRS/architecture.md` → Security Architecture → Data protection / transport |

### NFR-SEC-005: Input validation (Zod at the API boundary)

| Aspect | Value |
|--------|-------|
| **Target** | Every `/api/v1` request body/query is schema-validated before reaching domain logic |
| **Implementation** | `lib/env.ts` (`EnvSchema`, Zod ^4) validates environment config at boot; per-route Zod schemas validate request bodies in `lib/<domain>/**`, surfaced via `withApiHandler`'s centralized error mapping (`validation_failed` code) |
| **Evidence** | `lib/env.ts:15-41`; `lib/api/handler.ts` (imports `type { z } from 'zod'`) |

### NFR-SEC-006: Secret handling

| Aspect | Value |
|--------|-------|
| **Target** | Service-role key and JWT signing secret never reach the browser bundle |
| **Implementation** | `lib/env.ts` is the single Zod-validated env schema; `SUPABASE_SERVICE_ROLE_KEY` is explicitly commented "must never reach the browser bundle" and the module is `server-only`. No hard-coded secrets found in files read across this pass or the architecture pass. No secret-manager integration (Vercel env vars presumed for deployment, per platform default — not independently verified) |
| **Evidence** | `.context/SRS/architecture.md` → Security Architecture → Data protection / transport |

### NFR-SEC-007: Idempotency (security-adjacent — replay/duplicate-write protection)

| Aspect | Value |
|--------|-------|
| **Target** | A retried POST with the same `Idempotency-Key` must not double-write |
| **Implementation** | `lib/api/idempotency.ts` — `Idempotency-Key` header backed by `idempotency_keys` table, SHA-256 payload hash comparison, atomic `pending → succeeded/failed` state machine; a failed row (same key + same payload) is reclaimed for exactly one retry, concurrent in-flight requests get `409 conflict` ("Retry shortly") |
| **Evidence** | `lib/api/idempotency.ts:17,103-148`; `lib/api/idempotency.test.ts:209-232` |

---

## 3. Reliability

### NFR-REL-001: Uniform error envelope

| Aspect | Value |
|--------|-------|
| **Target** | Every `/api/v1` error response has one shape (`{ error: { code, message, details?, request_id? } }`) so callers branch on `code`, not message text |
| **Implementation** | `lib/api/error-envelope.ts` defines `API_ERROR_CODES` (generic: `bad_request`, `validation_failed`, `unauthorized`, `forbidden`, `not_found`, `conflict`, `rate_limited`, plus domain-specific codes like `ac_outside_user_story`, `chain_empty`) with a status-code map; `withApiHandler` centralizes the catch-and-map |
| **Evidence** | `lib/api/error-envelope.ts:1-40` |

### NFR-REL-002: Health check endpoint

| Aspect | Value |
|--------|-------|
| **Target** | A public, unauthenticated liveness probe |
| **Implementation** | `GET /api/v1/health` — `dynamic = 'force-dynamic'`, returns `{ ok: true, service: 'bunkai-tms', env, ts }`, marked `auth: 'public'`. No readiness/dependency check (e.g. DB connectivity) beyond process liveness |
| **Evidence** | `app/api/v1/health/route.ts` (full file, 12 lines) |

### NFR-REL-003: Structured logging

| Aspect | Value |
|--------|-------|
| **Target** | Every API request emits one structured JSON log line, indexable by Vercel's log capture |
| **Implementation** | `lib/api/logging.ts` (`logRequest`) — dependency-free single-line JSON logger (`request_id`, `method`, `path`, `status`, `duration_ms`, `user_id?`, `error_code?`, `message?`), routed to `console.log`/`console.warn`/`console.error` by level. No dedicated logging library (`winston`/`pino`/`bunyan` all confirmed absent from `package.json`) |
| **Evidence** | `lib/api/logging.ts:1-32` |

### NFR-REL-004: External-call retry / backoff (Jira import only)

| Aspect | Value |
|--------|-------|
| **Target** | A Jira API 429 must not immediately fail the import job |
| **Implementation** | `lib/jira/client.ts` — exponential backoff schedule `[1000, 2000, 4000, 8000, 16000]` ms, honors a numeric `Retry-After` header when present, otherwise falls back to the schedule; throws `JiraAuthError` for auth failures distinct from rate-limit retries. This is the ONLY retry/backoff implementation found in the codebase — no generic retry wrapper exists for other external calls (there are effectively none besides Supabase and Jira) |
| **Evidence** | `lib/jira/client.ts:4,78-95,112-151` |

### NFR-REL-005: React error boundaries (App Router)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented. No `error.tsx` file exists anywhere under `app/` (confirmed via glob `app/**/error.tsx`, zero matches). An unhandled render error in any route segment falls through to Next.js's default error UI rather than a custom recovery boundary |
| **Evidence** | Glob `app/**/error.tsx` → no files found |

### NFR-REL-006: Circuit breakers

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented — no circuit-breaker pattern found for the Supabase or Jira integrations. The Jira client's retry/backoff (NFR-REL-004) is the only resilience mechanism against a misbehaving external dependency |
| **Evidence** | Absence confirmed by the same grep pass that found NFR-REL-004 (`retry\|Retry\|backoff` across `lib/`, `app/`) |

### NFR-REL-007: Test suite gating (process reliability, not runtime reliability)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — no gate exists |
| **Implementation** | 135 `bun:test` files exist (mix of pure unit + real-Supabase RLS/cross-tenant integration tests) but are never invoked by `.husky/pre-commit`, `.husky/pre-push`, or any CI — confirmed no `.github/workflows/` directory. Regressions in the suite go undetected until someone runs `bun test` manually |
| **Evidence** | `CLAUDE.md` → Project Assessment (Phase 1) → Testing Maturity: 2/4, CI/CD Maturity: None |

---

## 4. Scalability

### NFR-SCALE-001: Stateless request handling

| Aspect | Value |
|--------|-------|
| **Target** | Any request-scoped state must be safe to lose on cold start / instance recycle |
| **Implementation** | Vercel serverless deployment (stateless-by-default). Session state lives in the Supabase cookie/JWT, not in-process. The one exception is NFR-PERF-002's `rollupCache` — explicitly documented as per-instance and acceptable because it is a pure cache (losing it costs a recompute, not correctness) |
| **Evidence** | `.context/SRS/architecture.md` → System Overview (Hosting: Vercel, serverless); `lib/home/coverage.ts:321-334` (self-documented per-instance limitation) |

### NFR-SCALE-002: Async job processing (Jira import)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — worker trigger mechanism not located |
| **Implementation** | `import_jobs` table has a full state machine (`queued → running → completed\|failed`, migrations `0019`/`0020`); no queue library (`bullmq`/`pg-boss`) is a dependency. What actually advances `queued → running` (cron? on-request poll? Vercel background function?) was not traced in the architecture pass and remains an open Discovery Gap — carried forward here since it directly affects scalability under concurrent import load |
| **Evidence** | `.context/SRS/architecture.md` → Discovery Gaps (Jira import worker trigger mechanism not located) |

### NFR-SCALE-003: Database scaling posture

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — no read-replica or sharding strategy found; single Supabase Postgres instance assumed |
| **Implementation** | No horizontal DB-scaling mechanism (read replicas, sharding) found in code or config. Scaling posture relies entirely on Supabase's managed Postgres + pgbouncer pooling and on the app's own targeted indexing (NFR-PERF-001) to keep query cost low as data grows |
| **Evidence** | `.context/SRS/architecture.md` → External Services, Performance hooks |

### NFR-SCALE-004: Horizontal scaling (compute)

| Aspect | Value |
|--------|-------|
| **Target** | N/A — delegated to platform |
| **Implementation** | Vercel serverless functions scale horizontally by platform default; no app-level configuration (concurrency limits, function memory/duration tuning) was found in `next.config.ts` or a `vercel.json` |
| **Evidence** | `next.config.ts` (full file — no Vercel-specific scaling config present); no `vercel.json` found in repo root listing during architecture pass |

---

## 5. Observability

### NFR-OBS-001: Application Performance Monitoring (APM)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented — `package.json` grep for `@sentry/*`, `@datadog/*`, `newrelic`, `@opentelemetry/*` returns zero matches |
| **Evidence** | `package.json` full-text grep, this pass, zero matches |

### NFR-OBS-002: Metrics (counters / gauges / histograms)

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented — no `prom-client` or custom metrics-emission code found |
| **Evidence** | Same `package.json` grep pass, zero matches |

### NFR-OBS-003: Distributed tracing

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented — no OpenTelemetry spans/trace context propagation. The only cross-cutting identifier is `x-request-id`, generated and logged per-request by `withApiHandler`/`logRequest`, which is request correlation, not distributed tracing |
| **Evidence** | `lib/api/logging.ts:8` (`request_id` field); `.context/SRS/architecture.md` → Data Flow sequence diagram (`x-request-id` header) |

### NFR-OBS-004: Structured log shipping

| Aspect | Value |
|--------|-------|
| **Target** | Vercel's built-in stdout capture and indexing (platform default) |
| **Implementation** | `logRequest()` emits single-line JSON to stdout/stderr; relies entirely on Vercel's log capture/indexing rather than a dedicated log-shipping pipeline (no Datadog/Logtail/Better Stack drain configured in code) |
| **Evidence** | `lib/api/logging.ts:1-3` (comment: "Vercel captures stdout and indexes the structured fields") |

### NFR-OBS-005: Alerting

| Aspect | Value |
|--------|-------|
| **Target** | [unknown] — not implemented |
| **Implementation** | Not implemented — no alerting integration found (no PagerDuty/Opsgenie/Slack-webhook-on-error pattern in code). Health endpoint (NFR-REL-002) exists but nothing was found polling it |
| **Evidence** | Absence inferred from the same `package.json` grep pass (NFR-OBS-001/002) plus no dependency matching `webhook`-to-alerting-service patterns found in `lib/api/`, `lib/jira/` |

---

## Compliance

**Needs Review.** No compliance framework (GDPR, SOC 2, HIPAA, PCI-DSS) documentation, DPA references, data-retention policy, or explicit consent-management code was found in this pass or the architecture pass. Bunkai TMS stores workspace/project/test-management data (not confirmed to include regulated categories like PII beyond user email/auth identity, or payment data) — a compliance posture cannot be responsibly inferred from code alone. Recommend a dedicated legal/compliance review before treating any of the above frameworks as in-scope or out-of-scope for this product.

---

## Discovery Gaps

- **No app-level rate limiting exists** beyond passthrough of Supabase Auth's own 429s on auth endpoints — every other endpoint (ATCs, Tests, Runs, Bugs, imports, etc.) has no request-volume protection. Worth a explicit finding for a security/DoS-resilience review, not a speculative severity rating.
- **Jira import worker trigger mechanism not located** (carried over from `architecture.md`) — blocks writing any timing-sensitive scalability or reliability test for the import flow until resolved.
- **No performance benchmark evidence exists anywhere in the repo** — every latency/throughput number in this document is `[unknown]` by design; nothing here should be read as an implicit SLA.
- **`rollupCache` TTL value not re-extracted this pass** — the mechanism, scope, and documented tradeoffs are confirmed (`lib/home/coverage.ts:335`); the exact TTL constant was not re-read from the surrounding lines and should not be assumed.
- **No `vercel.json` found** — scaling/concurrency/function-duration configuration, if any, is entirely on Vercel's dashboard-managed platform defaults, not verifiable from this repo.
- **Compliance posture entirely unverified** — see Compliance section above; do not treat "Needs Review" as "compliant" or "non-compliant."
- **TLS/HSTS posture not independently verified** (carried over from `architecture.md`) — relies on Vercel + Supabase platform defaults; no live response-header capture was performed.
- **`SUPABASE_JWT_SECRET` is `.optional()` in `EnvSchema` but a hard runtime dependency for PAT auth** (carried over from `architecture.md`) — a reliability/security cross-cutting gap: if unset in any deployed environment, every PAT-authenticated request throws `internal_error` with no earlier warning signal (no boot-time check enforces its presence when PAT auth is otherwise enabled).
- **No live 429/rate-limit response was captured** — the `rate_limited` code path is confirmed to exist in code, not exercised against a live environment this pass.

---

## QA Relevance

**Testable now** (no new tooling required):

- **Idempotency replay/conflict behavior** (NFR-SEC-007 / NFR-REL-001) — same-key-same-payload, same-key-different-payload, concurrent-pending-conflict are all deterministic API-level test cases against `lib/api/idempotency.ts`'s documented state machine.
- **Error envelope shape + status-code mapping** (NFR-REL-001) — contract test: every error code in `API_ERROR_CODES` returns the documented HTTP status and envelope shape.
- **Health endpoint** (NFR-REL-002) — trivial smoke check (`GET /api/v1/health` → `200 { ok: true }`), good candidate for a synthetic uptime check even without an APM tool.
- **Cursor pagination correctness** (NFR-PERF-005) — invalid-cursor → `400`, valid-cursor round-trip, empty-page `next_cursor: null` are all testable against `app/api/v1/activity/route.ts` today (existing `route.test.ts` already covers this at the unit level — an E2E/API-integration equivalent is a natural next step).
- **Auth-method parity** (NFR-SEC-001) — cookie session vs Bearer PAT against the same endpoint, asserting identical authorization outcome, is directly testable with existing fixtures.
- **CSP/security-header absence** (NFR-SEC-003) — a simple response-header assertion (`no CSP header present`) is testable today and useful as a regression guard for whenever headers ARE added.

**Needs tooling before testable**:

- **Load/latency targets** (NFR-PERF-001, NFR-PERF-002, NFR-PERF-006) — no P95/throughput baseline exists. Recommend **k6** or **Artillery** to establish a first baseline against `staging` before any performance regression test can be written; without a baseline, "performance testing" here would just be inventing a threshold, which the doctrine in this repo explicitly forbids.
- **Security surface scan** (NFR-SEC-003, NFR-SEC-004, NFR-SEC-006) — recommend an **OWASP ZAP** baseline scan against `staging` to get an evidence-backed list of missing headers/XSS/injection surface, rather than inferring further from code alone.
- **Observability verification** (all NFR-OBS-*) — nothing to test yet; there is no APM/tracing/metrics/alerting surface to assert against. This is a "recommend adding, then test" item, not a current gap in QA coverage.
- **Async import-flow timing** (NFR-SCALE-002) — blocked on the Discovery Gap above; do not write a timing-dependent test until the worker trigger mechanism is confirmed.
- **CI-gated regression** (NFR-REL-007) — the 135-file `bun:test` suite is a QA-relevant asset already, but it is not currently a safety net for anyone since nothing runs it automatically; recommend wiring it into `.husky/pre-push` or a minimal GitHub Actions workflow as a prerequisite to trusting "tests pass" as a release gate.

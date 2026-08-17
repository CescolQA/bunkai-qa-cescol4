# Project Configuration

> Project: bunkai-qa-cescol4
> Generated: 2026-08-17

## Repositories

| Repository | URL | Branch | Purpose |
|------------|-----|--------|---------|
| bunkai-qa-cescol4 (this QA repo) | https://github.com/CescolQA/bunkai-qa-cescol4.git | main | QA automation boilerplate (KATA + Playwright), local path `.` |
| upex-bunkai-tms (target/app repo) | https://github.com/upex-galaxy/upex-bunkai-tms.git | staging (default, `origin/HEAD` -> `origin/staging`); `main` also exists on origin | Full-stack app under test (Next.js), local path `../upex-bunkai-tms` |

Source: `git remote -v` run in each repo root; `git branch -a` in the target repo. Note: the target repo's local checkout is currently on `staging`, 1 commit ahead of `origin/staging` (uncommitted-but-not-pushed — informational only, not this QA repo's concern).

## Tech Stack

### Frontend
- Framework: Next.js ^15 (App Router — `app/` directory present), React ^19
- Language: TypeScript ^5.9.3, `strict: true` (confirmed in `upex-bunkai-tms/tsconfig.json`)
- Styling: Tailwind CSS ^3.4 (`tailwind.config.ts`) + shadcn/ui-style components (`components.json`, `@radix-ui/react-*` deps: dialog, dropdown-menu, tabs, tooltip)
- State: Not detected in `package.json` (no Redux/Zustand/Jotai/React Query) — likely React built-in state + Server Components. Not independently verified by reading component code.

### Backend
- Framework: Next.js Route Handlers (same app — no separate Express/NestJS/Fastify service)
- Language: TypeScript ^5.9.3
- ORM: None — raw SQL migrations under `upex-bunkai-tms/supabase/migrations/` (20+ numbered files, e.g. `0001_tenancy.sql` … `0020_import_jobs_one_active.sql`)

### Database
- Type: PostgreSQL (Supabase Postgres)
- Provider: Supabase (host `aws-1-us-east-1.pooler.supabase.com`, per this QA repo's `.env` `DBHUB_HOST`)
- Access: `[DB_TOOL]` -> DBHub MCP (`environments.*.db_mcp: dbhub` in `.agents/project.yaml`); QA repo `.env` has a dedicated read-write DB user `qa_inspector_rw.*` (name only — password present but not printed here; connection itself not live-tested in this pass)

### Infrastructure
- Cloud: Vercel (`webapp_domain` and `environments.staging.web_url` both resolve to `*.vercel.app` domains)
- CI/CD: None — `upex-bunkai-tms/.github/workflows/` does not exist (confirmed by directory listing)
- Monitoring: Not detected — no Sentry/DataDog/similar package in `upex-bunkai-tms/package.json` dependencies

## Environments

| Environment | URL | Purpose | Access |
|-------------|-----|---------|--------|
| Local       | http://localhost:3000 | Dev | Direct — **UNCONFIRMED**: this is the generic template default in `.agents/project.yaml` `environments.local.*`, not a value verified against a real local run of `upex-bunkai-tms` |
| Staging     | https://staging-upexbunkai.vercel.app | Pre-prod testing | Public HTTPS, no VPN detected. Reachability checked live: `curl -I` returned `HTTP 307` (redirect, e.g. to an auth/login route) — host is up. Matches `.env` `API_BASE_URL` / `OPENAPI_SPEC_PATH`. |
| Production  | Unknown — `.agents/project.yaml` `webapp_domain: https://upexbunkai.vercel.app` (project-level field, no `staging-` prefix) is the likely production URL by naming convention, but no `environments.production` block exists in `project.yaml` and nothing in the repo explicitly labels it "production" | Live (assumed) | Not verified — see Discovery Gaps |

## Tools and Access

- Issue tracker: Jira Cloud — resolved via `[ISSUE_TRACKER_TOOL]` (`/acli`)
  - Instance: `https://upexgalaxy71.atlassian.net` (from `.agents/project.yaml` `issue_tracker.atlassian_url`, matches `.env` `ATLASSIAN_URL`)
  - Credentials: `ATLASSIAN_URL` / `ATLASSIAN_EMAIL` / `ATLASSIAN_API_TOKEN` all set in `.env` (values not reproduced here); not live-tested (no `acli` call made in this pass)
- Project key: BK
- Database: resolved via `[DB_TOOL]` (DBHub MCP) — see Tech Stack > Database
- Docs: `upex-bunkai-tms` ships its own `README.md`, `CONTEXT.md`, `DESIGN.md`, `INSTALLER.md`, `docs/` — no external Confluence/Notion reference found

## Access Checklist

- [x] Repository read access — confirmed, both repos cloned locally and readable
- [~] Database access (MCP or direct) — DBHub credentials present in `.env`, `dbhub.toml` exists; connection not live-tested in this pass
- [~] Issue tracker access — Atlassian credentials present in `.env`; not live-tested (no `acli` call made) in this pass
- [x] Staging environment reachable — confirmed live via `curl`, HTTP 307 response
- [ ] CI/CD visibility — N/A, target repo has no CI/CD (no `.github/workflows/`)

## Discovery Gaps

- [ ] **Credential variable-name mismatch**: this QA repo's `.env` uses `LOCAL_USER_EMAIL` / `LOCAL_USER_PASSWORD` / `STAGING_USER_EMAIL` / `STAGING_USER_PASSWORD` (all currently empty), but the target repo's `.env.example` declares a different pair: `QA_E2E_USER_EMAIL` / `QA_E2E_USER_PASSWORD` under "AUTOMATION IDENTITY". These names do not line up — source of truth for which var name this QA repo should actually populate needs confirmation from the user before writing any test credentials.
- [ ] **`TEST_ENV` vs `testing.default_env` inconsistency**: this QA repo's `.env` sets `TEST_ENV=local`, while `.agents/project.yaml` sets `testing.default_env: staging`. These two config sources disagree on which environment is the default target. Needs an explicit decision from the user — do not silently pick one.
- [ ] **Production environment undefined**: `.agents/project.yaml` has no `environments.production` block. `webapp_domain: https://upexbunkai.vercel.app` (project-level) is the best guess by URL-naming convention (no `staging-` prefix) but is not confirmed as the live production URL, nor has its reachability been tested.
- [ ] **Local environment values are generic template defaults**: `environments.local.web_url` (`http://localhost:3000`) and `api_url` were never customized for `upex-bunkai-tms` specifically — confirm whether `bun dev` in the target repo actually serves on port 3000, or update these values.
- [ ] **No CI/CD pipeline**: `upex-bunkai-tms` has no `.github/workflows/` directory — no automated build/lint/test/deploy pipeline exists yet on the target repo. Regression suites from this QA repo cannot hook into target-repo CI because there isn't one.
- [ ] **No Dockerfile / docker-compose**: confirmed absent in `upex-bunkai-tms` root — local environment stands up via `bun dev` (Vercel/Supabase-hosted dependencies), not containers.
- [ ] **Frontend state-management approach unconfirmed**: no state library (Redux/Zustand/Jotai/React Query) found in `package.json` dependencies; the actual pattern (Context, Server Components, local `useState`) was not verified by reading component source in this pass.
- [ ] **Monitoring/observability tool unconfirmed**: no Sentry/DataDog/LogRocket/similar dependency found in `package.json`; if the app has monitoring, it is either provisioned outside the repo (e.g. Vercel Analytics dashboard) or not yet added.
- [ ] **DBHub and Jira live connectivity untested**: credentials are present in `.env` for both, but no live query/API call was made in this discovery pass to confirm they actually authenticate.

## API Spec Source

> Recorded per Phase 2 SRS §2 (`.claude/skills/project-discovery/references/phase-2-srs.md`) — this repo does not hand-write an `api-contracts.md`; it records where the canonical spec lives so `bun run api:sync` can consume it.

- **File**: `public/openapi.json` in the target repo (`upex-bunkai-tms`) — confirmed present via directory listing.
- **Runtime route**: `app/api/openapi` (Route Handler, `route.ts`) serves the spec at runtime.
- **Docs UI**: `app/api/docs` (Scalar UI, `page.tsx`) renders the spec for human browsing.
- **Generator**: `@asteasolutions/zod-to-openapi` ^8.5 — the spec is generated from Zod schemas registered in `lib/openapi/registry.ts`, not hand-authored. Regeneration scripts: `openapi:gen` / `openapi:diff` (target repo `package.json`).
- **Consumption by this QA repo**: `bun run api:sync` (this repo's `scripts/sync-openapi.ts`) is expected to pull from the above and produce `api/openapi-types.ts` / `api/openapi.json` — not yet run in this discovery pass; confirm `api/schemas/` is populated before writing API tests that depend on generated types.

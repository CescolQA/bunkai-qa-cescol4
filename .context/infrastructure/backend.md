# Backend Infrastructure — Bunkai TMS

> Target: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Single Next.js app, no monorepo — no per-package sections.
> Sources: fresh read of `package.json`, `.env.example`, `lib/env.ts`, `next.config.ts`, `tsconfig.json`, `app/api/v1/health/route.ts`, `lib/urls.ts`, `supabase/migrations/README.md`, `docs/architectures/supabase-nextjs/connection-setup.md`, `docs/workflows/environments.md` in the target repo. Stack facts reused (not re-derived) from `.context/SRS/architecture.md` and `.context/project-config.md`.

---

## Runtime Environment

| Item | Value |
|---|---|
| Language | TypeScript ^5.9.3, `strict: true` |
| Runtime / package manager | Bun — confirmed by `bun.lock` (not `bun.lockb`) at repo root and every tooling script invoked as `bun <script>.ts` |
| Framework | Next.js ^15 (App Router) |
| `engines` field in `package.json` | **Not present** — no Node/Bun version pin |
| `.nvmrc` / `.node-version` / `.tool-versions` | **Not present** |
| Module type | `"type": "module"` (ESM) |
| TS module resolution | `bundler`, `module: ESNext`, `target: ES2022` |
| TS path aliases | `@/*` → `./*`, `@app/*` → `./app/*`, `@components/*` → `./components/*`, `@lib/*` → `./lib/*` |

---

## Package Scripts

Full list, verbatim from `package.json` `scripts`:

| Script | Command | Purpose |
|---|---|---|
| `dev` | `next dev` | Start dev server |
| `build` | `next build` | Production build |
| `start` | `next start` | Serve production build |
| `typecheck` | `tsc --noEmit` | Type check (duplicate of `types:check`) |
| `setup` | `bun cli/doctor.ts --preflight && bun cli/install.ts` | First-time repo setup |
| `setup:doctor` | `bun cli/doctor.ts` | Environment doctor |
| `agents:setup` | `bun scripts/agents-setup.ts` | AI agent config setup |
| `up` | `bun cli/update-boilerplate.ts` | Pull boilerplate updates |
| `onboarding` | `bun scripts/onboarding.ts` | Onboarding flow |
| `api:sync` | `bun scripts/sync-openapi.ts` | Sync OpenAPI spec into consumer types |
| `openapi:gen` | `bun scripts/openapi-gen.ts` | Generate `public/openapi.json` from Zod registry |
| `openapi:diff` | `bun scripts/openapi-diff.ts` | Diff OpenAPI spec against previous |
| `vars:check` | `bun scripts/lint-vars.ts` | Lint variable usage |
| `vars:env:check` | `bun scripts/check-vars.ts` | Cross-check env vars against manifest |
| `skills:check` | `bun scripts/lint-skills.ts` | Lint skill files |
| `skills:registry` | `bun scripts/build-skill-registry.ts` | Build skill registry |
| `skills:registry:check` | `bun scripts/build-skill-registry.ts --check` | Validate skill registry is current |
| `jira:sync-fields` | `bun scripts/sync-jira-fields.ts` | Sync Jira custom fields |
| `jira:sync-workflows` | `bun scripts/sync-jira-workflows.ts` | Sync Jira workflows |
| `jira:sync-issues` | `bun scripts/sync-jira-issues.ts` | Sync Jira issues to local cache |
| `jira:sync-link-types` | `bun scripts/sync-jira-link-types.ts` | Sync Jira link types |
| `jira:check` | `bun scripts/check-jira-setup.ts` | Validate Jira setup |
| `format:fix` / `format:check` | `prettier --write/--check '**/*.{json,yml,yaml,css,scss,html}' --ignore-path .prettierignore` | Formatting |
| `lint:check` / `lint:fix` | `eslint .` / `eslint --fix .` | Linting |
| `types:check` | `tsc --noEmit` | Type check |
| `types:gen` | `bun scripts/gen-supabase-types.ts` | Generate `types/supabase.ts` from live schema |
| `release:check` | `bun scripts/check-release-readiness.ts` | Release readiness gate |
| `test` | `bun test` | Run test suite (Bun's built-in test runner) |
| `repo:check` | `bun run format:check && bun run lint:check && bun run types:check && bun run vars:check && bun run vars:env:check && bun run skills:check && bun run skills:registry:check` | Full CI-equivalent gate |
| `repo:fix` | `bun run format:fix && bun run lint:fix && bun run types:check && bun run vars:check && bun run vars:env:check && bun run skills:check && bun run skills:registry:check` | Full auto-fix gate |
| `clean` | `rm -rf node_modules dist .next` | Clean build artifacts |
| `prepare` | `husky` | Install git hooks |
| `claude` | `dotenv -o -e .env -- claude` | Launch Claude Code with `.env` loaded |
| `opencode` | `dotenv -o -e .env -- opencode` | Launch OpenCode with `.env` loaded |
| `env` | `set -a; source .env; set +a` | Source `.env` into current shell |

No dedicated `db:migrate` / `db:seed` / `db:reset` script exists — see Database Configuration below.

---

## Core Dependencies

| Category | Package | Version | Purpose |
|---|---|---|---|
| Framework | `next` | `^15` | App Router, Route Handlers |
| Framework | `react` / `react-dom` | `^19` | UI runtime |
| Language | `typescript` (devDep) | `^5.9.3` | Type checking |
| Backend — DB client | `@supabase/ssr` | `^0.10.3` | Cookie-scoped SSR Supabase client |
| Backend — DB client | `@supabase/supabase-js` | `^2.106.0` | Browser/admin Supabase client |
| Validation | `zod` | `^4.4.3` | Request/env schema validation |
| API docs | `@asteasolutions/zod-to-openapi` | `^8.5.0` | Generates OpenAPI spec from Zod schemas |
| API docs UI | `@scalar/api-reference-react` | `^0.9.38` | Renders OpenAPI spec at `app/api/docs` |
| Sanitization | `rehype-sanitize` | `^6.0.0` | Sanitizes user-authored Markdown before render |
| Markdown | `react-markdown` / `remark-gfm` | `^10.1.0` / `^4.0.1` | Markdown rendering |
| Styling | `tailwindcss` (devDep) | `^3.4` | Utility CSS |
| Table | `@tanstack/react-table` | `^8.21.3` | Data tables |
| DnD | `@dnd-kit/*` | `^6.3.1` / `^10.0.0` / `^3.2.2` | Drag-and-drop (ATC/step reordering) |
| Editor | `@monaco-editor/react` | `^4.7.0` | Code/markdown editing |
| Lint | `eslint` (devDep) + `@antfu/eslint-config` | `^9.28.0` / `^4.16.0` | Linting |
| Git hooks | `husky` / `lint-staged` (devDep) | `^9.1.7` / `^16.2.7` | Pre-commit hooks |

No auth library (`NextAuth`/`Passport`/`jose`/`jsonwebtoken`) and no HTTP client library (`axios`/`got`/`ky`) — auth is delegated entirely to Supabase Auth (GoTrue); HTTP calls use native `fetch`.

---

## Environment Variables

> **Naming mismatch found** (flagged in Discovery Gaps): `.env.example` declares **new-style** Supabase key names (`SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`), but `lib/env.ts` (the actual Zod-validated schema the app boots against) reads **legacy-style** names (`NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`). The tables below use the names `lib/env.ts` actually validates — those are the ones that matter for the app to boot. No values are reproduced anywhere in this document.

### Required (app throws on boot if missing/invalid — per `lib/env.ts` `EnvSchema`)

| Var | Notes |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Must be a valid URL. Exposed to browser. |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Exposed to browser. NOT the `.env.example` name (`SUPABASE_PUBLISHABLE_KEY`) — see mismatch note above. |
| `SUPABASE_SERVICE_ROLE_KEY` | Server-only, bypasses RLS, marked `server-only` in code. NOT the `.env.example` name (`SUPABASE_SECRET_KEY`). |

### Optional (has a schema default, or `.optional()` but load-bearing in practice)

| Var | Notes |
|---|---|
| `NEXT_PUBLIC_APP_URL` | Zod default `http://localhost:3000`. Used for auth redirects, OAuth callbacks, invite links. |
| `SUPABASE_JWT_SECRET` | `.optional()` in the Zod schema, **but a hard runtime dependency** for `impersonatingClient()` — any Bearer-PAT-authenticated request throws `internal_error` if unset. Carried over from `architecture.md`'s Discovery Gaps; confirmed again this pass by reading `lib/env.ts` directly. |

### External Service (feature-gated — missing creds degrade a feature, not app boot)

| Var | Notes |
|---|---|
| `ATLASSIAN_URL` / `ATLASSIAN_EMAIL` / `ATLASSIAN_API_TOKEN` | All `.optional()`. Missing/invalid → the Jira Story-import job fails with `jira_unauthorized`, app still boots. |
| `RESEND_API_KEY` | Declared in `.env.example`, but no app-code (`app/**`/`lib/**`) usage found — see `architecture.md` External Services table. Tooling/MCP-scoped only. |
| `TAVILY_API_KEY`, `N8N_API_URL`, `N8N_API_KEY`, `SUPABASE_ACCESS_TOKEN` | MCP-only (dev tooling), no app-code usage. |
| `POSTGRES_HOST` / `POSTGRES_USER` / `POSTGRES_PASSWORD` / `POSTGRES_DATABASE` / `POSTGRES_URL` / `POSTGRES_URL_NON_POOLING` / `POSTGRES_PRISMA_URL` | Declared in `.env.example` "if using Prisma / raw SQL" — confirmed **unused** by app code; the app talks to Postgres exclusively through the Supabase SDK. |
| `QA_E2E_USER_EMAIL` / `QA_E2E_USER_PASSWORD` | Test-only automation identity, referenced by QA-harness files (`app/qa/**`, `*.test.ts`), not production runtime code. |

---

## Database Configuration

| Item | Value |
|---|---|
| Type | PostgreSQL |
| Provider | Supabase (hosted; pgbouncer pooling — port `6543` transaction pooler recommended for tests, port `5432` direct/session) |
| ORM | None — raw SQL migrations are the sole schema source of truth |
| Migration directory | `supabase/migrations/` — 69 files, `NNNN_<slug>.sql` naming |
| Migration tool | **Not the Supabase CLI** — no `supabase/config.toml` exists in the repo. Per `supabase/migrations/README.md`, every migration is applied directly to the **remote** Supabase project (ref `fmbpikzpkafptqximhxn`) via the **Supabase MCP `apply_migration` tool**, which records a ledger row in `supabase_migrations.schema_migrations`. Applying DDL via `execute_sql` is explicitly forbidden by repo convention (bypasses the ledger). |
| Local Postgres instance | **None found** — no `docker-compose.yml`, no Supabase CLI local stack. Local dev (`bun run dev`) points at the same remote Supabase project as other environments (see Discovery Gaps). |
| Seed mechanism | Not found — no `prisma/seed.ts`-equivalent, no `db/seeds/` directory. |

### Migration Commands

There are **no package.json scripts** for migrations (`db:migrate`, `db:push`, etc. do not exist). The actual mechanism, per `supabase/migrations/README.md`:

```text
# Create: author a new supabase/migrations/NNNN_<slug>.sql file by hand
#         (zero-padded ordinal + snake_case slug, next number after 0069)

# Apply:  applied to the remote project via the Supabase MCP `apply_migration`
#         tool (not a CLI command) — this repo does not expose a bash command
#         for this step. Never apply DDL via a raw `execute_sql` call — it
#         bypasses the ledger and creates drift.

# Reset:  no reset mechanism found (no local DB to reset against).

# Seed:   no seed mechanism found.
```

---

## Build Configuration

`next.config.ts` (full file — 13 lines, reproduced verbatim, nothing omitted):

```ts
const config: NextConfig = {
  reactStrictMode: true,
  outputFileTracingRoot: path.resolve(import.meta.dirname),
  typedRoutes: true,
  images: {
    remotePatterns: [],
  },
};
```

- No `output: 'standalone'` — default Next.js build output (`.next/`).
- No custom Webpack or Turbopack config.
- `typedRoutes: true` — typed `Link`/`router.push` route strings.
- `images.remotePatterns` is empty — no external image domains allowlisted yet.
- Build command: `next build` (via `bun run build`). Output dir: `.next/` (default, cleaned by `bun run clean`).

---

## Local Development Setup

> No local Postgres/Supabase stack exists in this repo — `bun run dev` connects to the same remote Supabase project used by other environments. There is no local migration/seed step to run.

```bash
# 1. Install dependencies
bun install

# 2. Set up environment
cp .env.example .env
# Edit .env and fill in (see Environment Variables above for which names
# lib/env.ts actually reads — .env.example's Supabase key names differ,
# see the naming-mismatch note):
#   NEXT_PUBLIC_SUPABASE_URL
#   NEXT_PUBLIC_SUPABASE_ANON_KEY   (NOT .env.example's SUPABASE_PUBLISHABLE_KEY)
#   SUPABASE_SERVICE_ROLE_KEY       (NOT .env.example's SUPABASE_SECRET_KEY)
#   NEXT_PUBLIC_APP_URL=http://localhost:3000

# 3. Database — no local setup step. Migrations already live on the shared
#    remote Supabase project; nothing to run here.

# 4. Start development server
bun run dev

# 5. Verify
curl http://localhost:3000/api/v1/health
```

Expected response shape (`GET /api/v1/health`, `auth: 'public'`, `app/api/v1/health/route.ts`):

```json
{
  "ok": true,
  "service": "bunkai-tms",
  "env": "local",
  "ts": "2026-08-17T12:00:00.000Z"
}
```

`env` is computed by `lib/urls.ts` `getEnvironment()`: `production` if `VERCEL_ENV === 'production'`, `staging` if `VERCEL_ENV === 'preview'`, else `local`.

---

## Health Check Endpoints

| Endpoint | Auth | Response |
|---|---|---|
| `GET /api/v1/health` | `public` (no auth required) | `{ ok, service: 'bunkai-tms', env, ts }` — see JSON shape above |

`export const dynamic = 'force-dynamic'` — never statically optimized/cached.

---

## Discovery Gaps

- ~~**Supabase env-var naming mismatch**~~ — **FIXED 2026-08-17** in the target repo: `.env.example` now lists both the legacy names the app actually reads (`NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, marked REQUIRED) and the new-style pair (marked not-yet-read-by-app-code), with a corrected comment. `lib/env.ts`/`lib/supabase/*.ts` were left untouched (47 files depend on the legacy names). Change not yet committed — left in the target repo's working tree for review.
- **No Node/Bun version pin**: no `engines` field in `package.json`, no `.nvmrc`/`.node-version`/`.tool-versions`. Local Bun version drift between contributors is possible.
- **`SUPABASE_JWT_SECRET` is `.optional()` in the Zod schema but a hard dependency for PAT-based (Bearer `bk_pat_*`) auth** — carried over from `architecture.md`; confirmed again this pass directly in `lib/env.ts`. Any Bearer-auth API test automation must confirm this is actually set in the target environment first.
- **No local Postgres/Supabase CLI stack** — `bun run dev` runs against the same remote Supabase project as other environments; there is no isolated local database. Migrations are applied to that remote project via the Supabase MCP `apply_migration` tool, not a CLI/bash command — this doc cannot give a copy-pasteable "apply migrations" command because none exists in this repo.
- **Migration ledger vs. Supabase CLI**: `supabase/migrations/README.md` explicitly notes the `NNNN_` file prefixes are not Supabase CLI timestamp versions, so `supabase migration up`/`db push` (if ever introduced) would not match this repo's convention out of the box.
- **No seed mechanism found** — fresh test data setup for local/staging is not scripted anywhere found in this pass.
- **No CI/CD** (carried over from `project-config.md`) — no `.github/workflows/`, so the `repo:check` script is the only verified "this is what should pass" command set; there is no CI log to cross-check it against.
- **Health check response not live-verified this pass** — read from source only (`app/api/v1/health/route.ts` + `lib/urls.ts`), not curled against a running `bun run dev` instance.
- **`bun test` runner scope unconfirmed** — `package.json` declares `"test": "bun test"` (Bun's built-in runner), but this pass did not enumerate `*.test.ts` files or confirm what they cover (unit vs. integration vs. something exercising the DB).

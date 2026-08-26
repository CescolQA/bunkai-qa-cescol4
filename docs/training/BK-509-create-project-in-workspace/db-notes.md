# DB notes — BK-509 (workspace / project)

## Access

Two clients hit the same staging Postgres DB (Supabase pooler `aws-1-us-east-1.pooler.supabase.com:5432`, database `postgres`), results confirmed matching between them (2026-08-25):

- `dbhub` MCP (`mcp__dbhub__execute_sql`) inside Claude Code — role `qa_inspector_rw`, config in `.env` (`DBHUB_*`) and `.mcp.json`.
- VS Code, "MySQL" extension pointed at the same pooler (label is misleading — it's plain Postgres underneath, so standard Postgres SQL works, not MySQL dialect).

## Gotcha: no email lookup

`qa_inspector_rw` only sees the `public` schema. `auth.users` (where email lives, Supabase auth) returns `permission denied for schema auth`. There is no email/profile mirror table in `public` either.

**Consequence**: can't resolve "which workspace is mine" by email. Resolve by workspace/project `slug` or `name` instead — ask the user what they named it, or list recent rows by `created_at` and let them pick.

## Relevant tables (`public` schema)

- `workspaces` — `id, slug, name, owner_user_id, plan, created_at`
- `projects` — `id, workspace_id, slug, name, description, created_at`
- `workspace_members` — `workspace_id, user_id, role, status, joined_at`

## Working queries

See `queries.sql`.

## Observation: two different `owner_user_id` for workspaces the user says are both his

`BK1` → `owner_user_id 0a6733cd-e5fa-4b88-94af-8276fbccca80`
`bk2` → `owner_user_id 9026f71d-d675-4cb1-a6fc-8ecd55cb433a`

Confirmed both are the same person's test data. Likely two separate staging signups/sessions, not a data bug — flag if this keeps happening across stories.

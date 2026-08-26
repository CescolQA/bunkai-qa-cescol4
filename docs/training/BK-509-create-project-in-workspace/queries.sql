-- BK-509 practice queries. Plain Postgres SQL, works from dbhub MCP or VS Code's
-- MySQL extension (same underlying Supabase Postgres pooler).

-- List my workspaces + projects by slug (LEFT JOIN so an empty workspace still shows).
SELECT w.name AS workspace, w.slug AS workspace_slug,
       p.name AS project, p.slug AS project_slug, p.description
FROM public.workspaces w
LEFT JOIN public.projects p ON p.workspace_id = w.id
WHERE w.slug IN ('bk1', 'bk2');

-- Most recent workspaces created (when you don't know the slug yet).
SELECT id, slug, name, owner_user_id, plan, created_at
FROM public.workspaces
ORDER BY created_at DESC
LIMIT 5;

-- NOTE: filtering by created_at::date = current_date returned 0 rows even for
-- same-day data (2026-08-25) -- suspect timezone offset between DB server
-- `now()` and local clock. Prefer ORDER BY created_at DESC LIMIT N over a
-- date-equality filter until this is understood.

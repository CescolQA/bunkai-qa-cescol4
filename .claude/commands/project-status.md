# Project Status

Live snapshot of this project's configuration — compiled fresh every run, never cached, never written to disk. Answers "what's actually wired up right now" in one call.

**Focus** (optional): $ARGUMENTS — a section name (e.g. `mcp`, `env`, `jira`, `db`) to show only that block, or leave blank for the full snapshot.

---

## Why this exists

`.agents/project.yaml`, `.env`, `.mcp.json`, and Jira each hold one slice of "how is this project configured" — no single file has the full picture, and a static summary doc would go stale the moment any of them changes. This command re-reads all sources live, every time, and renders one table. Extend it by adding a row to the source table below and a matching line in the output — do not build a generator that writes a persisted file.

---

## Sources (read live, every run)

| Source | What to pull | Never do |
|---|---|---|
| `.agents/project.yaml` | project identity, repo paths, environments (web_url/api_url/db_mcp/api_mcp), git_strategy, qa_epics keys | — |
| `.env` | which vars are SET vs empty, by name only | never print secret values — mask (`ATLASSIAN_API_TOKEN=<set>` / `<empty>`) |
| `.mcp.json` | actual registered MCP server names, cross-check against `project.yaml`'s `db_mcp`/`api_mcp` — flag mismatches | — |
| Jira QA credentials epic (default key: search `qa_epics` in `project.yaml`, else ask; this project uses **BK-29**) | environment URLs, DB role names (not passwords), auth flow notes | never print raw passwords/tokens from the epic into chat or any persisted file — reference "see BK-29" instead |
| `git status` / `git log -1` | ahead/behind origin, uncommitted changes | — |

Add a new source by adding a row here (what to pull, what never to do) and a matching section in the output below — the command stays a flat read-and-render, resist turning it into a multi-phase discovery flow.

---

## Output

Render one table per section, most-load-bearing first:

1. **Identity** — project name/key, webapp domain, backend/frontend repo path (verify path exists), stack.
2. **Environments** — one row per env in `project.yaml`: web_url, api_url, db_mcp, api_mcp — cross-checked live against `.mcp.json`'s actual server names, flag any name that doesn't exist there.
3. **Jira** — instance URL, auth status (`acli jira auth status`), active project key.
4. **MCP wiring** — every server in `.mcp.json`, whether its required env vars are set (name-only check, never dump values).
5. **DB** — DBHUB_* vars set/empty, and if set, whether a live connection was verified this session (do not auto-connect — report "not verified this session" unless already tested).
6. **Git** — branch, ahead/behind origin, uncommitted files count, strategy (solo-main / etc. from `git_strategy.strategy`).
7. **Flags** — anything inconsistent found while compiling the above (placeholder-looking URLs, MCP name mismatches, empty required vars for the active `TEST_ENV`). Empty section is fine — say "none" instead of omitting it.

If `$ARGUMENTS` names one section (`mcp`, `env`, `jira`, `db`, `git`), render only that one plus §Flags filtered to that scope.

---

## Rules

- Never write output to a file — this is a chat-only report, every time, live.
- Never print secret values (tokens, passwords, API keys) — name + set/empty only.
- Never publish this output as an Artifact or any external surface — some sources (Jira QA credentials epic) are explicitly scoped to stay inside that epic.
- If a source is unreachable (Jira auth expired, `.mcp.json` missing), report that section as "unavailable — <reason>" and continue with the rest; do not hard-stop the whole command.

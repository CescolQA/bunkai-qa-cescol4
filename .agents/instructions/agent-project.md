---
id: project
title: 'Project-specific instructions'
load_when: 'anything specific to this project: its own conventions, guardrails, environments or vocabulary not covered by another section'
triggers: ['project-status', 'caveman', 'cavecrew']
paths: []
---

# Project-specific instructions

> Project-owned overlay. The boilerplate delivers this file once and never overwrites it; every other file in this folder is synced from upstream. Write this project's own rules here, one heading per topic, instead of editing `AGENTS.md` or a synced section. Knowledge about the system under test belongs in a project context skill (`<aspect>-context`), not here.

Add `triggers:` regex sources to the frontmatter above when a rule here should be routed by keyword (the hook reads them), and keep every `NEVER` / `MUST` line reachable: cite `Rule #N`, binding: `/<skill>`, or enforced: `bun run <script>` (checked by `bun run instructions:check`).

## Project context skills

One row per skill this project authored: the `<aspect>-context` skills `project-context` mode `context-skill` creates, and any other skill the project added. The skill router in `agent-skills-and-mcps.md` is synced, so `bun sync` overwrites a row written there; this file is never overwritten. Add each skill's trigger phrases to `triggers:` above as regex sources too, so the hook routes this file when a prompt names them. `bun run instructions:check` fails a row whose `.agents/skills/<slug>/SKILL.md` does not exist.

| Skill | Trigger | Purpose |
|---|---|---|
| `project-status` | `/project-status` | Live snapshot of this project's configuration, compiled fresh every run from `.agents/project.yaml` + `.env` (names only, secrets masked) + `.mcp.json` + Jira QA credentials epic + `git status`. Never cached, never written to disk. Optional `$ARGUMENTS` scopes to one section (`mcp`, `env`, `jira`, `db`, `git`). |
| `caveman` | `/caveman`, "caveman mode", "less tokens" | Compressed communication mode (committed copy of the user-level caveman plugin skill). |
| `caveman-commit` | `/caveman-commit`, "write a commit" | Compressed conventional commit message generator. |
| `caveman-compress` | `/caveman-compress <file>` | Compresses a natural-language memory file; keeps a human-readable backup. |
| `caveman-review` | `/caveman-review` | Compressed code review comments. |
| `caveman-help` | `/caveman-help` | Quick-reference card for caveman modes and commands. |
| `caveman-stats` | `/caveman-stats` | Session token usage and estimated savings. |
| `caveman-explore` | "explore the repo", cold-start localization | Read-only repository explorer returning path:line citations. |
| `caveman-discover` | "discover workflows" | Labels LLM workflows for Caveman Cloud spend grouping. |
| `caveman-evidence-review` | "what did Caveman find" | Read-only review of Caveman Cloud evidence. |
| `caveman-learn` | "caveman learn" | Applies cost-lowering fixes from a Caveman learn report, per-edit consent. |
| `caveman-manage` | "approve / roll back a Caveman experiment" | Inspects the Caveman Cloud experiment lifecycle; blocks unsafe execution. |
| `caveman-optimize` | "evaluate an optimization candidate" | Turns Caveman optimization observations into a paired evaluation. |
| `caveman-setup` | "set up Caveman gateway" | Routes the repo through the Caveman Cloud gateway. |
| `cavecrew` | "use cavecrew", "spawn investigator/builder/reviewer" | Decision guide for delegating to caveman-style subagents. |
| `investigate-first` | ambiguous failure before editing | Diagnose ambiguous failures before editing. |
| `lean-build` | feature work with overbuilding risk | Build feature work with high overbuilding risk, minimal scope. |
| `migration` | reversible transition | Implement reversible, compatibility-safe transitions. |
| `safe-refactor` | restructure without behavior change | Restructure code while preserving behavior. |
| `surgical-patch` | small fix at the narrowest layer | Fix bugs and small behavior changes at the narrowest responsible layer. |
| `verify-and-stop` | prove work meets acceptance | Prove existing work meets acceptance conditions without expanding scope. |

## Git strategy of this repository

This repository (César's personal QA-practice project, built on the agentic-qa-boilerplate) runs `solo-main`: single maintainer, commit and push directly to `main`. This is a CHOSEN strategy (`strategy_source: chosen`, confirmed via `/git-flow-master` Strategy Setup — single-branch mechanics already matched real usage), not the inherited default: do not re-offer Strategy Setup unless the user asks to change it. No GitHub ruleset governs `main` on this repo (`bun run git:policy verify` confirms "no ruleset rules apply", 0 drift, `meta.policy_source: verified`): there is no accepted divergence to declare.

## Project assessment (Phase 1)

> Target repo assessed: `upex-bunkai-tms` (local path `../upex-bunkai-tms`). Read-only pass — no files modified in the target repo.

Assessment Date: 2026-08-17

### Testing Maturity: 2/4
- Current state: Moderate
- Test files: 135 (`find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) -not -path "*/node_modules/*"` in target repo root)
- Frameworks: Bun's built-in test runner (`bun:test`) only — no Jest/Vitest/Playwright test files found anywhere in the repo
- Coverage: unknown (no coverage tool/threshold configured; `package.json` `test` script is plain `bun test`, no `--coverage`)
- Composition (sampled `lib/api/rls-parity.test.ts`, `lib/bugs/validation.test.ts`, and file-name pattern across all 135): mix of pure unit tests (validation/format/slug helpers) and substantial DB-dependent integration tests (`*-isolation.test.ts`, `*-rls*.test.ts`, `*-rpc.test.ts` — real Supabase RLS/cross-tenant regression guards, `describe.skip` gracefully when Supabase env vars absent). No E2E automation exists in this repo — that gap is exactly the reason `bunkai-qa-cescol4` exists as a separate QA automation repo.
- **Not gated anywhere**: `bun test` is not invoked in `.husky/pre-commit`, `.husky/pre-push`, or any CI (confirmed no `.github/workflows/` — `ls .github/workflows/` fails, directory absent). The pre-commit/pre-push hooks run `types:check` / `vars:check` / `skills:check` / `format:check` / `lint:check` / `skills:registry:check` but never `bun run test`. The 135-file suite is developer-run-on-demand only.

### Documentation State: Good
- README: yes, but describes the wrong product — `README.md` documents an unrelated meta-framework ("agentic-dev-boilerplate" / "The dev workflow, but AI runs it"), not Bunkai TMS itself. Same pattern in `CONTEXT.md` ("Context Engineering in This Repo"). A reader looking for "what does Bunkai TMS do" will not find it in either file.
- API docs: yes — `public/openapi.json` + `@scalar/api-reference-react` dependency + `scripts/openapi-gen.ts` / `sync-openapi.ts` / `openapi-diff.ts` pipeline
- Architecture: yes — `docs/architectures/`, plus `DESIGN.md` (genuinely Bunkai-specific: brand identity, design tokens, byte-exact with `app/globals.css` + `tailwind.config.ts`)
- Setup guide: yes — `README.md` "Get started in one command" section + `INSTALLER.md`
- Gap: no `CONTRIBUTING.md` at root (checked, absent)

### Code Quality
- [x] ESLint: configured — `eslint.config.js` (`@antfu/eslint-config` + `@next/eslint-plugin-next`), script `lint:check` / `lint:fix`
- [x] Prettier: configured — `.prettierrc` (semi, singleQuote, printWidth 100, etc.), script `format:check` / `format:fix`
- [x] TypeScript: strict — `tsconfig.json` line 21 `"strict": true` (matches `.context/project-config.md`)
- [x] Pre-commit hooks: configured — Husky `.husky/pre-commit` (lint-staged + `types:check` + `vars:check` + `skills:check` + conditional `skills:registry:check`) and `.husky/pre-push` (full-repo `format:check` + `lint:check` + `vars:env:check` + `skills:registry:check`)

### CI/CD Maturity: None
- No `.github/workflows/` directory exists at all (confirmed by direct check, not just an empty dir)
- Deploy path is Vercel (per `.context/project-config.md`), which provides a build-time gate (`next build`) on deploy, but there is no server-side lint/test/typecheck gate on PRs — only the bypassable local Husky hooks

### Identified Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| No CI/CD pipeline | MEDIUM | No PR-level enforcement of lint/types/tests; mitigated somewhat by local Husky pre-commit/pre-push hooks (bypassable with `--no-verify`) and Vercel's build-time gate on deploy. Recommend adding a minimal GitHub Actions workflow (`lint` + `types:check` + `bun test`) before contributor count grows. |
| `bun test` suite (135 files) never runs automatically | MEDIUM | Neither Husky hooks nor CI invoke `bun run test` — regressions in the suite go undetected until someone runs it manually. Add `bun run test` to `pre-push` at minimum, or to a CI workflow. |
| README/CONTEXT.md describe an unrelated meta-framework, not Bunkai TMS | LOW | Product-specific docs do exist (`DESIGN.md`, `docs/architectures/`, `public/openapi.json`), so the gap is discoverability of the top-level entry doc, not a missing-documentation problem. Recommend a short "What is Bunkai TMS" section at the top of `README.md`. |
| No `CONTRIBUTING.md` | LOW | Setup guide (`INSTALLER.md`) partially covers onboarding; contribution conventions are otherwise undocumented. |

No hardcoded secrets found. Secret-sweep grep (`(api[_-]?key\|secret\|password\|token)\s*[:=]\s*['"]`) over `app/` and `lib/` returned 2 file hits — both false positives, verified by inspection: `app/design-tokens/page.tsx` matches are CSS design-token names (`--bg-0`, `--accent`, unrelated "token" meaning), and `app/qa/qa-config.ts` matches are QA documentation with placeholder/example values (`bk_pat_<prefix>.<secret>`, `<see credentials source>`), not real credentials. No values reproduced in this report per Critical Rule.

No missing type-checking risk — `tsconfig.json` `strict: true` confirmed directly (not just relayed from `.context/project-config.md`).

### Phase Prioritization

- Phase 1: Normal — Constitution largely complete via `.context/project-config.md` + this assessment; Business Model + Domain Glossary sub-steps remain.
- Phase 2: Normal — codebase has clear, consistent `lib/` module conventions (validation/errors/view co-located per domain), should reverse-engineer cleanly.
- Phase 3: Extended — CI/CD is fully absent; the Infrastructure sub-step needs to document the gap thoroughly (no workflows, Vercel-only deploy gate, un-gated test suite) rather than a one-line "None" skip.
- Phase 4: Extended — domain surface is large and non-trivial (bugs, ATCs, runs, workspaces, traceability, milestones, notifications, tokens/PATs — 20+ `lib/` subdomains observed), warrants full Specification treatment rather than a quick pass.

### Blockers
- [ ] None blocking — proceed to Business Model Discovery. Carry forward from `.context/project-config.md` Discovery Gaps: production environment URL unconfirmed, `TEST_ENV`/`testing.default_env` mismatch, credential variable-name mismatch (`LOCAL_USER_EMAIL` vs `QA_E2E_USER_EMAIL`) — none of these block Phase 1 Assessment itself.

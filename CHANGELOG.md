# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.3.0] — 2026-04-16

### Added

- **Trae Agents integration** — all 13 specialist agents (digital-team, product-manager, architect, dba, ui-designer, project-manager, plan, frontend-engineer, dotnet-engineer, java-engineer, python-engineer, qa-engineer, devops-engineer) are now available as one-click shared agents for Trae CN via `https://s.trae.com.cn/a/{hash}?region=cn` links
- **Trae install support in `install.ps1`** — unified installer now supports platform selection: `1` Copilot, `2` Trae, `3` Both; installs role skills to `~/.trae-cn/skills/` (Trae CN) or `~/.trae/skills/` (Trae International) and coding standards to the corresponding `instructions/` directory
- **`/init-project` command for Trae** — `@digital-team /init-project` guides users through a scaffold interview in Trae chat, creating `.ai/context/workflow-config.md` and copying relevant coding standards into `.trae/rules/`

---

## [1.2.0] — 2026-04-10

### Added

- **`@plan` agent SKILL.md** — `copilot/skills/plan/SKILL.md` and `zh-CN` counterpart created; `plan.agent.md` (EN + zh-CN) slimmed from inline 60+ lines to a single `#file:` reference
- **3 new prompt commands** — `change-request.prompt.md`, `hotfix.prompt.md`, `new-sprint.prompt.md` (EN + zh-CN, 6 files total):
  - `change-request`: mid-iteration scope change impact assessment and re-targeting
  - `hotfix`: emergency hotfix fast-track, bypasses P1–P5 and goes straight to implementation
  - `new-sprint`: new sprint startup — updates `workflow-config.md`, rolls over backlog, resets paths
- **Java Engineer agent** — `java-engineer.agent.md` and `zh-CN` counterpart added with Anti-AI-Bloat constraints
- **Python Engineer agent** — `python-engineer.agent.md` and `zh-CN` counterpart added with Anti-AI-Bloat constraints
- **Coding standards template step in `/init-project`** — Step 4 now generates `.github/instructions/coding-standards-{frontend|dotnet|java|python}.instructions.md` based on enabled engineers and project type
- **P8 DevOps capability routing** — Phase 8 split into three capability-gated paths:
  - No Docker / No CI/CD → checklist → manual deployment
  - Docker only → Dockerize + `docker-compose.yml` → manual deployment
  - CI/CD enabled → pipeline config → auto-deploy on merge to main

### Fixed

- `devops-engineer.agent.md` description updated to include Docker and CI/CD keywords for correct agent routing (EN + zh-CN)
- `qa-engineer.agent.md` handoff prompt path corrected: `qa-report.md` → `qa-report-{version}.md` (EN + zh-CN)
- `digital-team.agent.md` agent reference case bug fixed: `agent: "Plan"` → `agent: "plan"` (EN + zh-CN)
- `DONE_A` label in P8 flowchart corrected: "Agent triggers CI/CD" → "Merge to main → CI/CD triggers"

### Improved

- **Anti-AI-Bloat constraints** added to `dotnet-engineer`, `java-engineer`, and `python-engineer` agents (EN + zh-CN) — prevents over-engineered abstractions, unused helpers, and AI-flavoured boilerplate
- README.md and README.zh-CN.md P8 flowchart updated with G8 capability-check diamond and 3 labelled terminal paths

---

## [1.1.0] — 2026-04-01

### Added

- **UI Export Platform integration** — new `ui_export_platform` configuration option in `/init-project` (Q8.5):
  - `none` (default): wireframe + design spec only
  - `prompt-export`: also generate `.ai/temp/ui-export-prompt.md` with structured prompts for Stitch / v0 / Anima
  - `figma-mcp`: also generate `design-tokens.json` + `component-spec.json` and push to Figma via MCP Server
- `figma-config.md` context file for Figma credentials (excluded from source control)
- `.ai/context/ui-designs/` to save UI screen and prototypes from Stitch or Figma
- add UI Designer review mode to review UI screen and prototypes from Stitch or Figma based on ui-design.md and wireframe.html

---

## [1.0.0] — 2026-03-29

### Added

- `@plan` agent (P5b) — produces `.ai/temp/plan.md`: a file-level implementation plan for downstream engineers to reference. Replaces the informal `@Plan` built-in reference in the workflow.
- `ui_export_platform` field added to `workflow-config.md` template in `/init-project` (Q8.5) — value `none` by default; groundwork for v1.1.0 platform integration
- `@devops-engineer` agent (Phase 8) — produces deployment guide after QA approval, covering pre-deployment checklist, infrastructure procurement plan, third-party service integration, environment configuration, deployment runbook, post-deployment verification, and rollback plan
- `copilot/skills/devops-engineer/SKILL.md` and `zh-CN` counterpart
- `shared/roles/devops-engineer.md` and `zh-CN` counterpart
- Phase 8 handoff and phase detection added to `digital-team` orchestrator (EN + zh-CN)
- `.github/ISSUE_TEMPLATE/` — bug report and feature request templates (GitHub + Gitee compatible via `.gitee/`)
- `.github/pull_request_template.md` and `.gitee/PULL_REQUEST_TEMPLATE.md`
- Version badge added to README.md and README.zh-CN.md

### Initial foundation (extracted from pre-release)

- 10 specialist role agents: PM, Architect, DBA, UI Designer, Project Manager,
  Frontend Engineer, .NET Engineer, QA Engineer, DevOps Engineer, and Orchestrator (`digital-team`)
- 9 corresponding SKILL.md role definitions
- Global output standards instruction (`output-standards.instructions.md`)
- Global coding standards for .NET (`**/*.cs`) and Frontend (`**/*.vue`, `**/*.ts`)
- `/init-project` prompt command for bootstrapping `.ai/` directory structure
- Cross-platform installer (`install.ps1`) supporting Windows, macOS, Linux
- Claude Code adapter (`claude-code/CLAUDE.md`)
- OpenAI Codex CLI adapter (`codex/AGENTS.md`)
- Project template for per-project coding standard overrides
- Gate review system: human approval required between every phase
- DBA role as Phase 2b with Gate 2 joint review (Architecture + DB Design)
- Role skip logic via `workflow-config.md` configuration
- Intelligent project type detection (pure frontend/backend/fullstack)
- Scrum delivery mode with versioned sprint paths
- Simplified Chinese locale (`zh-CN/`)

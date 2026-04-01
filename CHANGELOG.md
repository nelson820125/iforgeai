# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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

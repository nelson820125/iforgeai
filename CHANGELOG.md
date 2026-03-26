# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

- `@devops-engineer` agent (Phase 8) — produces deployment guide after QA approval, covering pre-deployment checklist, infrastructure procurement plan, third-party service integration, environment configuration, deployment runbook, post-deployment verification, and rollback plan
- `copilot/skills/devops-engineer/SKILL.md` and `zh-CN` counterpart
- `shared/roles/devops-engineer.md` and `zh-CN` counterpart
- Phase 8 handoff and phase detection added to `digital-team` orchestrator (EN + zh-CN)
- `.github/ISSUE_TEMPLATE/` — bug report and feature request templates (GitHub + Gitee compatible via `.gitee/`)
- `.github/pull_request_template.md` and `.gitee/PULL_REQUEST_TEMPLATE.md`

---

## [1.0.0] — 2025-Q1

### Added

- Initial release extracted from Jordium internal configuration
- 9 specialist role agents: PM, Architect, DBA, UI Designer, Project Manager,
  Frontend Engineer, .NET Engineer, QA Engineer, and Orchestrator (`digital-team`)
- 8 corresponding SKILL.md role definitions
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

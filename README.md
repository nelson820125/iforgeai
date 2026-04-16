<p align="center">
  <img src="public/assets/logo.png" width="300" alt="logo" />
</p>

[![VS Code](https://img.shields.io/badge/VS%20Code-1.99%2B-0078d4?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/) [![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-supported-000000?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot) [![Claude Code](https://img.shields.io/badge/Claude_Code-supported-CC785C?logo=anthropic&logoColor=white)](https://www.anthropic.com/claude-code) [![Codex CLI](https://img.shields.io/badge/Codex_CLI-supported-412991?logo=openai&logoColor=white)](https://github.com/openai/codex) [![Trae](https://img.shields.io/badge/Trae-0.6.0%2B-FF6B35?logoColor=white)](https://www.trae.ai/) [![DevOps Docker Capability](https://img.shields.io/badge/DevOps-Docker%20Capability-2496ED?logo=docker&logoColor=white)](https://www.docker.com/) [![DevOps CI/CD Capability](https://img.shields.io/badge/DevOps-CI%2FCD%20Capability-0A66C2?logo=githubactions&logoColor=white)](https://github.com/features/actions) [![Version](https://img.shields.io/badge/version-v1.1.0-blue)](CHANGELOG.md)

![Vue](https://img.shields.io/badge/Vue_3-4FC08D?logo=vuedotjs&logoColor=white) ![React](https://img.shields.io/badge/React-20232A?logo=react&logoColor=61DAFB) ![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white) ![.NET](https://img.shields.io/badge/.NET-512BD4?logo=dotnet&logoColor=white) ![Java](https://img.shields.io/badge/Java-ED8B00?logo=openjdk&logoColor=white) ![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?logo=springboot&logoColor=white) ![Spring Cloud](https://img.shields.io/badge/Spring_Cloud-6DB33F?logo=spring&logoColor=white) ![MyBatis](https://img.shields.io/badge/MyBatis-C71A36?logo=mybatis&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white) ![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white) ![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?logo=microsoftsqlserver&logoColor=white) ![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white) ![MongoDB](https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white) ![Redis](https://img.shields.io/badge/Redis-DC382D?logo=redis&logoColor=white) ![and more](https://img.shields.io/badge/&_more...-lightgrey)

[中文](README.zh-CN.md)

A multi-platform, multi-role AI agent toolkit for software delivery teams.  
Supports **GitHub Copilot**, **Claude Code**, **Codex CLI**, and **TraeCN**.

by [jordium.com](https://jordium.com)

---

iforgeAI provides 10 specialist AI agents — one per delivery role. Each agent has defined inputs, outputs, and handoff points. A coordinator agent (`@digital-team`) connects them into a sequential workflow with human gate reviews between phases.

To avoid conflicts with existing products using similar names in the market, the project has been renamed from `forgeai` to `iforgeAI`.

Backend support: .NET (C#), Java (Spring Boot), and Python (FastAPI). Multiple backend engineers can coexist in a single project.

The DevOps role includes Docker configuration and CI/CD pipeline delivery capabilities, and generates these artifacts on demand based on the `docker` and `cicd` settings in `.ai/context/workflow-config.md`.

VS Code 1.115.0 supports a visual Prompt UI for project initialization, making configuration easier.
![Prompt UI](public/assets/prompt-ui.png)

---

## Quick Start

### GitHub Copilot

```sh
git clone https://github.com/nelson820125/iforgeai.git
cd iforgeai
pwsh ./install.ps1          # Select platform: 1 Copilot  (or 3 Both)
```

Then in VS Code:
1. `Ctrl+Shift+P` → **Developer: Reload Window**
2. Open your project workspace
3. Copilot Chat → run `/init-project` to scaffold `.ai/` directories
4. Switch to Agent mode → select `digital-team` → describe your iteration goal

![iforgeAI on VS Code - Agent picker](public/assets/VSCode-1.png)

![iforgeAI on VS Code - Chat](public/assets/VSCode-2.png)

---

### Trae (0.6.0+)

**Method 1 — Script install (recommended)**

```sh
git clone https://github.com/nelson820125/iforgeai.git
cd iforgeai
pwsh ./install.ps1          # Select platform: 2 Trae  (or 3 Both)
```

This installs all role skills globally to `~/.trae-cn/skills/` (Trae CN) or `~/.trae/skills/` (Trae International), and coding-standard instructions to the corresponding `instructions/` directory.

After installation, invoke any role in Trae chat using `@agent-name`:

```
@digital-team      — coordinator; use /init-project to scaffold a new project
@product-manager   — requirements analysis
@architect         — architecture design
@dba               — database design
```

**Method 2 — One-click shared agents** *(Trae CN only)*

Click to add an agent directly to your Trae workspace (no install required):

| Agent | Link |
|---|---|
| digital-team (coordinator) | [Add agent](https://s.trae.com.cn/a/20b610?region=cn) |
| product-manager | [Add agent](https://s.trae.com.cn/a/0774f5?region=cn) |
| project-manager | [Add agent](https://s.trae.com.cn/a/a47648?region=cn) |
| architect | [Add agent](https://s.trae.com.cn/a/2215d0?region=cn) |
| dba | [Add agent](https://s.trae.com.cn/a/15f783?region=cn) |
| ui-designer | [Add agent](https://s.trae.com.cn/a/9d7e92?region=cn) |
| frontend-engineer | [Add agent](https://s.trae.com.cn/a/211c10?region=cn) |
| dotnet-engineer | [Add agent](https://s.trae.com.cn/a/637798?region=cn) |
| java-engineer | [Add agent](https://s.trae.com.cn/a/37cb8a?region=cn) |
| python-engineer | [Add agent](https://s.trae.com.cn/a/8c1a62?region=cn) |
| qa-engineer | [Add agent](https://s.trae.com.cn/a/122a53?region=cn) |
| plan | [Add agent](https://s.trae.com.cn/a/1e717a?region=cn) |
| devops-engineer | [Add agent](https://s.trae.com.cn/a/121c87?region=cn) |

**Initialize a project**

In Trae chat, use `@digital-team` and run `/init-project` to scaffold `.ai/` directories for your project:

```
@digital-team /init-project
```

The guided interview creates `.ai/context/workflow-config.md` and copies relevant coding standards from the global instructions into `.trae/rules/`.

![iforgeAI on Trae - Agent list](public/assets/Trae-1.png)

![iforgeAI on Trae - Chat](public/assets/Trae-2.png)

![iforgeAI on Trae - Init project](public/assets/Trae-3.png)

---

### Claude Code

```sh
# Copy to your project root (or ~/.claude/ for all projects)
cp claude-code/CLAUDE.md /path/to/your/project/CLAUDE.md
```

Start with a trigger word in Claude Code chat: `PM:` / `Architect:` / `Frontend:` …

---

### Codex CLI

```sh
cp codex/AGENTS.md /path/to/your/project/AGENTS.md
```

> For Chinese versions, use `zh-CN/` prefix: `zh-CN/claude-code/CLAUDE.md`, `zh-CN/codex/AGENTS.md`.

---

## Roles

| Phase | Role              | Agent                | Output                                           |
| ----- | ----------------- | -------------------- | ------------------------------------------------ |
| P1    | Product Manager   | `@product-manager`   | `.ai/temp/requirement.md`                        |
| P2a   | Architect         | `@architect`         | `.ai/temp/architect.md` · `.ai/temp/api-contract.md` (skeleton) |
| P2b   | DBA               | `@dba`               | `.ai/temp/db-design.md` · `.ai/temp/db-init.sql` |
| P3    | UI Designer       | `@ui-designer`       | `.ai/temp/ui-design.md` · `.ai/temp/ui-wireframe.html` · `.ai/context/ui-designs/_index.md` |
| P3b   | UI Designer · Design Review | `@ui-designer` (`UI review:`) | `.ai/context/ui-designs/_index.md` (finalised) · `.ai/temp/ui-design.md` (final) |
| P4    | Project Manager   | `@project-manager`   | `.ai/temp/wbs.md`                                |
| P5a   | Backend Engineer  | `@dotnet-engineer` / `@java-engineer` / `@python-engineer` | `.ai/temp/api-contract.md` (completed)           |
| P5b   | Plan              | `@plan`              | `.ai/temp/plan.md`                               |
| P6a   | Frontend Engineer | `@frontend-engineer` | Source code                                      |
| P6b   | Backend Engineer  | `@dotnet-engineer` / `@java-engineer` / `@python-engineer` | Source code                                      |
| P6c   | Architect         | `@architect`         | `.ai/reports/architect/review-report-{v}.md`     |
| P7    | QA Engineer       | `@qa-engineer`       | `.ai/reports/qa-report.md`                       |
| P8    | DevOps Engineer   | `@devops-engineer`   | `.ai/reports/devops-engineer/deploy-guide-{v}.md` |

`@digital-team` is the Orchestrator. It reads `.ai/temp/` to detect the current phase, displays progress, and runs gate reviews.

> **Copilot Chat (Agent mode):** Switch to Agent mode and select agents from the agent picker — the `@name` above is the agent's picker name, not a chat command. **Claude Code / Codex CLI:** Use trigger phrases to set role context.

## Workflow

```mermaid
flowchart TD
    START(["🚀 Start iteration\n@digital-team"])

    P1["P1 · Product Manager\n@product-manager\nrequirement.md"]
    G1{"Gate 1\nReview"}

    P2A["P2a · Architect\n@architect\narchitect.md + api-contract skeleton"]
    P2B["P2b · DBA\n@dba\ndb-design.md + db-init.sql"]
    G2{"Gate 2\nJoint Review"}

    P3["P3 · UI Designer\n@ui-designer\nui-design.md + wireframe.html"]
    G3{"Gate 3\nReview"}

    P4["P4 · Project Manager\n@project-manager\nwbs.md"]
    G4{"Gate 4\nReview"}

    P5A["P5a · Backend Engineer(s)\n@dotnet / java / python-engineer\napi-contract.md (full schemas)"]
    P5B["P5b · Plan\n@plan\nplan.md"]
    G5{"Gate 5\nReview"}

    P6A["P6a · Frontend Engineer\n@frontend-engineer\nsource code"]
    P6B["P6b · Backend Engineer(s)\n@dotnet / java / python-engineer\nsource code"]
    P6C["P6c · Architect\n@architect /review\nreview-report.md"]
    G6{"Gate 6\nReview"}

    P7["P7 · QA Engineer\n@qa-engineer\nqa-report.md"]
    G7{"Gate 7\nRelease Assessment"}

    P8["P8 · DevOps Engineer\n@devops-engineer"]
    G8{"Deployment\nCapability?"}
    P8A["📋 Deploy Checklist\ndeploy-guide.md"]
    P8B["🐳 Dockerize\nDockerfile · docker-compose.yml"]
    P8C["⚙️ CI/CD Pipeline\npipeline config · auto-trigger"]
    DONE_M(["✅ Human deployment\nManual execution"])
    DONE_A(["🚀 Auto deployment\nMerge to main → CI/CD triggers"])

    REJECT["🔄 Return to role\nfor revision"]

    START --> P1
    P1 --> G1
    G1 -->|Approved| P2A & P2B
    G1 -->|Rejected| REJECT
    P2A & P2B --> G2
    G2 -->|Approved| P3
    G2 -->|Rejected| REJECT
    P3 --> G3
    G3 -->|Approved| P4
    G3 -->|Rejected| REJECT
    P4 --> G4
    G4 -->|Approved| P5A & P5B
    G4 -->|Rejected| REJECT
    P5A & P5B --> G5
    G5 -->|Approved| P6A & P6B
    G5 -->|Rejected| REJECT
    P6A & P6B --> P6C
    P6C --> G6
    G6 -->|Approved| P7
    G6 -->|Rejected| REJECT
    P7 --> G7
    G7 -->|Approved| P8
    G7 -->|Issues found| REJECT
    P8 --> G8
    G8 -->|No Docker / No CI/CD| P8A
    G8 -->|Docker only| P8B
    G8 -->|CI/CD enabled| P8C
    P8A & P8B --> DONE_M
    P8C --> DONE_A
```

---

## Requirements

- VS Code 1.99 or later with the GitHub Copilot and GitHub Copilot Chat extensions installed and active
- PowerShell 7+ (`pwsh`) for the installer

Install PowerShell 7 if not already present:

```sh
# Windows
winget install Microsoft.PowerShell

# macOS
brew install powershell
```

---

## Installation

### 1. Clone the repository

GitHub:

```sh
git clone https://github.com/nelson820125/iforgeai.git
cd iforgeai
```

Gitee:

```sh
git clone https://gitee.com/jordium/iforgeai.git
cd iforgeai
```

### 2. Run the installer

```sh
pwsh ./install.ps1
```

The installer detects your OS and shows the default target path for each component (agents, skills, instructions, prompts). Press Enter to accept a path or type a replacement.

Available flags:

| Flag          | Effect                                                  |
| ------------- | ------------------------------------------------------- |
| `-Force`      | Overwrite files that already exist                      |
| `-DryRun`     | Preview all planned operations without writing anything |
| `-SkipSkills` | Skip installing skill definitions                       |

Default paths:

| OS | Agents / Instructions / Prompts | Skills |
| OS | Agents / Instructions / Prompts | Skills |
|----|----------------------------------|--------|
| Windows | `%APPDATA%\Code\User\` | `%USERPROFILE%\.copilot\skills\` |
| macOS | `~/Library/Application Support/Code/User/` | `~/.copilot/skills/` |
| Linux | `~/.config/Code/User/` | `~/.copilot/skills/` |

### 3. Reload VS Code

```
Ctrl+Shift+P  >  Developer: Reload Window
```

Agents and instructions are loaded at startup. The reload is required after the first install.

### 4. Grant file-write permission to `digital-team`

> **Why this matters:** `digital-team` and all specialist agents write their deliverables (requirements, architecture docs, DB design, etc.) directly to `.ai/temp/`. Without the **Edit files** permission, every document is printed to the Chat window instead, consuming large amounts of context and degrading the quality of downstream agents.

1. Open the Copilot Chat panel in VS Code
2. Click the **Tools** icon to the left of the input box
3. Make sure **Edit files** is checked
4. `digital-team` performs this check automatically on every startup. If the permission is missing it will pause and guide you through enabling it — you can also choose to continue without it (documents will print to Chat instead).

---

## Uninstall

```sh
pwsh ./uninstall.ps1
```

Removes all installed agents, skills, instructions, and prompts, and restores `settings.json` to its pre-install state. If you had a `chat.pluginLocations` entry before installing iforgeAI, the original value is preserved; if the key did not exist, it is removed entirely.

To preview what will be removed without making any changes:

```sh
pwsh ./uninstall.ps1 -DryRun
```

---

## Claude Code & Codex CLI

The same 10-role workflow is available for Claude Code and OpenAI Codex CLI. No installer is required — copy one config file to your project root.

### Platform support

All three platforms run on Windows, macOS, and Linux.

| Platform | Requirement | Config file |
|---|---|---|
| GitHub Copilot | VS Code 1.99+, `pwsh install.ps1` | Deployed via installer |
| Claude Code | Claude Code CLI | `CLAUDE.md` in project root or `~/.claude/` |
| Codex CLI | OpenAI Codex CLI | `AGENTS.md` in project root |

### Setup

**Claude Code — copy to project root:**

```sh
cp claude-code/CLAUDE.md /path/to/your/project/CLAUDE.md
```

Or place at the global location to apply to all projects:

```sh
# macOS / Linux
cp claude-code/CLAUDE.md ~/.claude/CLAUDE.md

# Windows
cp claude-code\CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md
```

**Codex CLI — copy to project root:**

```sh
cp codex/AGENTS.md /path/to/your/project/AGENTS.md
```

**Simplified Chinese locale:**

```sh
# Claude Code
cp zh-CN/claude-code/CLAUDE.md /path/to/your/project/CLAUDE.md

# Codex CLI
cp zh-CN/codex/AGENTS.md /path/to/your/project/AGENTS.md
```

### Trigger phrases

Invoke any role by prefixing your message with its trigger phrase. After each phase, a gate review card is shown — type `approve` to advance or `return [reason]` to revise.

| Trigger | Role |
|---|---|
| `status` | Orchestrator — check current phase |
| `PM:` | Product Manager (P1) |
| `Architect:` | Architect (P2a) |
| `DBA:` | DBA (P2b) |
| `UI:` | UI Designer (P3) |
| `Project Manager:` | Project Manager (P4) |
| `API contract:` | .NET Engineer — contract (P5a) |
| `Java contract:` | Java Engineer — contract (P5a) |
| `Python contract:` | Python Engineer — contract (P5a) |
| `Plan:` | Technical Plan (P5b) — outputs `.ai/temp/plan.md` |
| `Frontend:` | Frontend Engineer (P6a) |
| `.NET:` | .NET Engineer — dev (P6b) |
| `Java:` | Java Engineer — dev (P6b) |
| `Python:` | Python Engineer — dev (P6b) |
| `Code review:` | Architect — code review (P6c) |
| `QA:` | QA Engineer (P7) |
| `DevOps:` | DevOps Engineer (P8) |

> Claude Code and Codex CLI run the entire workflow in a single conversation thread. Role context is set by your trigger phrase — there is no automatic agent switching.

---

## Language Support

iforgeAI installs in **English by default**. The output language of agent-generated deliverables (requirements, architecture docs, DB design, etc.) is controlled per-project by the `output_language` field in `.ai/context/workflow-config.md`.

### Chinese (Simplified) Users

A full Simplified Chinese locale is available in the `zh-CN/` directory — all agent and skill files are in Chinese:

```sh
pwsh ./install.ps1    # Select language: zh-CN during install
```

This installs the same components from the `zh-CN/copilot/` source tree.

### Setting the output language for a project

After running `/init-project`, open `.ai/context/workflow-config.md` and set:

```yaml
output_language: "zh-CN" # en-US | zh-CN
```

All agents read this value at startup and write their deliverables in the specified language.

---

## Scrum Mode

By default iforgeAI uses `standard` delivery mode: all phase outputs are written to a single `.ai/temp/` directory. For projects with multiple releases and sprints, enable Scrum mode during project init.

### Enabling Scrum mode

During `/init-project`, answer **Q9** with `scrum`. The prompt then asks for the first version and sprint name (e.g. `v1.0`, `sprint-1`).

This creates the following directory structure:

```
.ai/
├── context/                    # Shared config — not versioned
├── v1.0/
│   ├── sprint-1/
│   │   ├── temp/               # Phase outputs for this sprint
│   │   └── reports/            # QA and review reports for this sprint
│   └── sprint-2/
│       ├── temp/
│       └── reports/
└── records/                    # Engineer work logs (continuous, not per-sprint)
```

The `workflow-config.md` file tracks the active context:

```yaml
delivery_mode: "scrum"
current_version: "v1.0"
current_sprint: "sprint-1"
```

`digital-team` and all specialist agents resolve their file paths from these values automatically.

### Starting a new sprint or version

1. Update `current_version` and `current_sprint` in `.ai/context/workflow-config.md`
2. Create the new directories: `.ai/{version}/{sprint}/temp/` and `.ai/{version}/{sprint}/reports/`
3. Restart `digital-team` — it will detect the empty sprint and start from Phase 1

### Standalone agent usage in Scrum mode

All agents read the path configuration automatically. If invoked standalone and `current_version` / `current_sprint` are not set in the config, the agent will ask you to specify them:

```
dotnet-engineer:  implement the order approval API
# Agent asks: "Scrum mode is active. Which version and sprint should I use?"
```

---

## Project Setup

In a new project workspace, run the following in Copilot Chat:

```
/init-project MyProject fullstack
```

This creates a `.ai/` directory in the project root:

```
.ai/
├── context/
│   ├── workflow-config.md       # Role on/off switches, tech stack, design approach, and output_language
│   ├── architect_constraint.md  # Architecture and library constraints
│   ├── ui_constraint.md         # Brand colours, style tone, layout — filled manually before UI phase
│   └── ui-designs/              # External design tool exports (Stitch, Figma) — place files here after export
│       ├── _index.md            # Page inventory — created by @ui-designer Phase A, finalised in Phase B
│       └── {page}/              # Per-page folder (Stitch) or flat .html files (Figma)
├── temp/                        # Phase outputs (written by each agent)
├── records/                     # Engineer work logs
└── reports/                     # QA reports
```

### Configure before starting

Open `.ai/context/workflow-config.md` and set the following fields before the first iteration:

#### `db_approach` — database schema strategy

```yaml
db_approach: "database-first"  # default
```

| Value | Behaviour |
|---|---|
| `database-first` | DBA outputs a ready-to-run `db-init.sql`. Engineers read it to write ORM entities. Use when the schema is the authoritative source of truth. |
| `code-first` | DBA outputs a design document only. Engineers drive the schema via ORM migrations (e.g. EF Core). Use when the codebase owns the schema lifecycle. |

#### `design_approach` — phase order for UI design

```yaml
design_approach: "architecture-first"  # default
```

| Value | Phase order | Best for |
|---|---|---|
| `architecture-first` | PM → Architect → DBA → **UI Designer** → … | B2B / industrial / high-integration systems. UI Designer reads `requirement.md` + `architect.md` to ensure the design stays within technical constraints. |
| `ui-first` | PM → **UI Designer** → Architect → DBA → … | C-side products or prototype-driven projects. Architect and DBA additionally read `ui-design.md` so their designs accommodate the desired UX. |

#### `ui_constraint.md` — brand and style constraints

This file is **filled manually** by the PM, tech lead, or designer — not generated by AI.
Fill it in before `@ui-designer` runs. It contains:

- **Brand colours** — 12 CSS custom property values (`primary`, `danger`, `surface`, etc.)
- **Style tone** — `clean-light` / `enterprise-gray` / `professional-dark`
- **UI library** — must match the `ui_library` value in the Tech Stack section
- **Typography and layout** — base font size, sidebar width, border radius, etc.

If any field is left blank, `@ui-designer` will propose and apply a neutral enterprise default and state the chosen value in its output.

`@ui-designer` uses these values in two ways:
1. Defines matching CSS custom properties in the Style Variables section of `ui-design.md`
2. Applies them at the top of the `<style>` block in the generated `ui-wireframe.html`

#### UI Design Workflow — Two-Phase Roundtrip

`@ui-designer` supports a two-phase workflow when an external design tool (Stitch, Figma, etc.) is used. Skip Phase B if no external tool is involved.

**P3 — `/design` mode** (Copilot Chat: select **ui-designer** from the agent picker)
- Generates `ui-wireframe.html` (layout skeleton) and `ui-design.md` (draft spec with proposed tokens)
- Creates `.ai/context/ui-designs/_index.md` as a page inventory skeleton (`file: [TBD]`)

**Human step — Place exported files**
Extract the design tool export zip into `.ai/context/ui-designs/`. No reorganisation required — both structures are supported:

```
.ai/context/ui-designs/
  _index.md            ← created by P3
  Dashboard.html       ← Figma flat export
  Login.html
  login/               ← Stitch per-page folder
    code.html
    screen.png
```

**P3b — `/review` mode** (trigger: `UI review:` / `UI design review:`)
- Scans `ui-designs/`, fills `_index.md` with actual file paths, marks `reviewed: true`
- Compares exports against the wireframe; updates `ui-design.md` with final colours, spacing, and component variants

> `ui-design.md` must reflect the reviewed final state before `@frontend-engineer` begins work.

`@frontend-engineer` reads `_index.md` to locate per-page layout HTML. Falls back to `ui-wireframe.html` if `_index.md` is absent.

---

## Usage

### Start an iteration

1. Open Copilot Chat and switch to Agent mode
2. Select `digital-team`
3. State the iteration goal, for example:
   ```
   Iteration goal: implement user permissions module — role assignment and menu-level access control
   ```

The Orchestrator reads current phase state and tells you what to do next.

### Gate reviews

After each phase, the Orchestrator presents a summary and two options: approve to advance to the next phase, or reject to send the current phase back for revision.

### Skip a role

Open `.ai/context/workflow-config.md` and mark any role as skipped:

```
ui-designer:       skip | no frontend
frontend-engineer: skip | no frontend
```

Roles with a skip entry are excluded from the workflow for the current project. The Orchestrator reads this file at startup.

### Use roles individually

All agents work independently without going through the Orchestrator.

**Copilot Chat (Agent mode):** Select the agent from the picker, then type your task:

```
architect           assess whether event sourcing is needed for operation auditing
dba                 design the permissions-related tables, reference .ai/temp/architect.md
frontend-engineer   implement the permissions page, reference .ai/temp/ui-design.md Task #3
```

**Claude Code / Codex CLI:** Use trigger phrase prefixes — see [Trigger phrases](#trigger-phrases).

### Agent phase modes

Some agents serve more than one phase in the workflow and behave differently depending on how they are invoked:

| Agent | Phase | Mode | Behaviour |
|-------|-------|------|-----------|
| `dotnet-engineer` | P5a · API Contract | `/contract` | Fills request/response schemas in `api-contract.md`. Outputs documentation only — no code. |
| `dotnet-engineer` | P6b · Backend Dev | `/develop` (default) | Implements backend code using `api-contract.md` as the authoritative spec. |
| `java-engineer` | P5a · API Contract | `/contract` | Fills request/response schemas in `api-contract.md`. Outputs documentation only — no code. |
| `java-engineer` | P6b · Backend Dev | `/develop` (default) | Implements backend code using `api-contract.md` as the authoritative spec. |
| `python-engineer` | P5a · API Contract | `/contract` | Fills request/response schemas in `api-contract.md`. Outputs documentation only — no code. |
| `python-engineer` | P6b · Backend Dev | `/develop` (default) | Implements backend code using `api-contract.md` as the authoritative spec. |
| `ui-designer` | P3 · UI Design | `/design` (default) | Generates `ui-wireframe.html` layout skeleton and `ui-design.md` draft spec. Creates `_index.md` page inventory. |
| `ui-designer` | P3b · Design Review | `/review` (trigger: `UI review:`) | Scans exported design files, fills `_index.md` with actual file paths, and updates `ui-design.md` to the final reviewed state. |
| `architect` | P2a · Architecture | `/design` (default) | Produces architecture design and API contract skeleton. |
| `architect` | P6c · Code Review | `/review` | Reviews engineer deliverables for standards, structure, performance, and API completeness. |

`digital-team` passes the correct mode automatically when routing through the workflow. When invoked standalone:
- Agents default to their primary mode (`/develop` for `dotnet-engineer`, `/design` for `architect`)
- If required prerequisite files are absent **and** no task is described in the prompt, the agent asks for clarification rather than proceeding with assumptions

---

## Coding Standards

Two instruction files are applied automatically via `applyTo` glob patterns:

| File                                        | Auto-applied to                                |
| ------------------------------------------- | ---------------------------------------------- |
| `coding-standards-dotnet.instructions.md`   | `**/*.cs`                                      |
| `coding-standards-java.instructions.md`     | `**/*.java`                                    |
| `coding-standards-python.instructions.md`   | `**/*.py`                                      |
| `coding-standards-frontend.instructions.md` | `**/*.vue`, `**/*.jsx`, `**/*.tsx`, `**/*.ts`, `**/*.scss` |

To add project-specific overrides, copy `project-template/.github/instructions/` into your workspace and fill in the marked sections. Project-level files take precedence over global ones.

---

## Repository Structure

```
iforgeai/
├── install.ps1
├── uninstall.ps1
├── zh-CN/                     Simplified Chinese locale
│   └── copilot/               Chinese versions of agents, skills, instructions, and prompts
├── shared/                    Platform-agnostic role and standard definitions
│   ├── roles/
│   └── standards/
├── copilot/                   GitHub Copilot — full implementation (English)
│   ├── agents/
│   ├── skills/
│   ├── instructions/
│   └── prompts/
├── claude-code/               Claude Code adapter — copy CLAUDE.md to project root
│   └── CLAUDE.md
├── codex/                     Codex CLI adapter — copy AGENTS.md to project root
│   └── AGENTS.md
└── project-template/          Copy to new project workspace
    ├── .github/instructions/
    └── .ai/context/
```

---

## Issues

File a GitHub Issue for:

- Installation failures — include OS, PowerShell version, and the full error output
- Agent behavior not matching the role spec — include the role name, your input, and the expected vs. actual output
- Feature requests — describe the problem or use case

---

## Premium Models and Network Access

iforgeAI works best with Claude Sonnet or CodeX in Copilot's premium request mode. Larger context windows and stronger instruction-following improve role adherence across the 10-agent workflow.

Premium request models require a GitHub Copilot Individual or Business subscription with premium request credits enabled.

### Mainland China Users

GitHub Copilot and its model endpoints may be inaccessible in mainland China without a proxy. We recommend DOVE: [dovee.cc](https://dovee.cc/aff.php?anaxjgyz1ozZq2B).
This is a referral link. Ensure VPN usage complies with applicable local laws and regulations.

---

## License

MIT. Copyright 2025 Jordium.com Engineering Team. See [LICENSE](./LICENSE).

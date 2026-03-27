---
description: "Initialize the digital-team workspace for a new project. Guides the user through project configuration step by step, then creates .ai/ directories and a fully pre-filled workflow-config.md. Run before starting a new iteration."
name: "init-project"
argument-hint: "project-name project-type (fullstack/frontend-only/backend-only/api-only)"
agent: "agent"
---

Initialise the digital-team workspace for a new project in the current workspace.
Work through the steps below in order. Do **not** skip the guided interview — collect answers first, then write files.

---

## Step 1: Create Directory Structure

Create the following directories (create if absent, skip if already exists):
- `.ai/context/`
- `.ai/records/`
- `.github/instructions/`

Then, based on the delivery mode from Q9:
- **`standard`**: also create `.ai/temp/` and `.ai/reports/`
- **`scrum`**: create `.ai/{version}/{sprint}/temp/` and `.ai/{version}/{sprint}/reports/` (where `{version}` and `{sprint}` are the answers to Q10)

---

## Step 2: Guided Configuration Interview

Ask the user the questions below **one group at a time**. Wait for a response before moving to the next group. If the user types "skip" or leaves a field blank, record the placeholder shown in parentheses.

### Group A — Project basics

If `{project-name}` and `{project-type}` were already supplied as arguments, confirm them and skip the first two questions.

> **Q1.** What is the project name?
> *(placeholder: `my-project`)*
>
> **Q2.** What is the project type?
> Options: `fullstack` / `frontend-only` / `backend-only` / `api-only`
> *(placeholder: `fullstack`)*
>
> **Q3.** What output language should agent deliverables (requirements, architecture docs, etc.) be written in?
> Options: `en-US` (English) / `zh-CN` (Simplified Chinese) / `ja-JP` (Japanese)
> *(placeholder: `en-US`)*
>
> **Q4.** What is the one-sentence MVP goal for this first iteration?
> Example: *"Implement user authentication with role-based menu access control"*
> *(placeholder: `(fill in before starting)`)*

### Group B — Role configuration

Based on the project type from Q2, suggest which roles to skip and ask the user to confirm or adjust:

- `frontend-only` → suggest: skip `dba`, `dotnet-engineer`
- `backend-only` or `api-only` → suggest: skip `ui-designer`, `frontend-engineer`
- `fullstack` → all roles enabled by default

> **Q5.** Based on the project type, the suggested role setup is:
> *(show the suggested table)*
> Any roles to add to the skip list? If not, press Enter to accept.

Record each role's final status as `enabled` or `skip | {reason}`.

### Group C — Tech stack

Ask only for the sections relevant to the project type. For skipped roles (e.g. no frontend), omit those fields entirely.

> **Q6.** Tech stack — answer each with the actual value, or press Enter to leave blank for now:
>
> *(show only the relevant fields for this project type, e.g. for api-only skip all frontend fields)*
>
> - Frontend framework? *(e.g. Vue 3.5 / React 19 / skip)*
> - CSS approach? *(e.g. SCSS + CSS Variables / Tailwind CSS 4 / skip)*
> - State management? *(e.g. Pinia / Zustand / skip)*
> - UI component library? *(e.g. Element Plus / Ant Design 5 / skip)*
> - Backend framework? *(e.g. ASP.NET Core 9 / NestJS 11 / skip)*
> - ORM / data access? *(e.g. EF Core 9 / Dapper / SqlSugar / skip)*
> - Database? *(e.g. PostgreSQL 17 / SQL Server 2022 / skip)*
> - Cache? *(e.g. Redis 8 / skip)*
> - Deploy platform? *(e.g. Docker + Nginx / Azure App Service / skip)*

Leave any field as `""` if the user skips it.

### Group D — Database approach

Ask only if the project type includes a backend (i.e. not `frontend-only`).

> **Q7.** Which database development approach will this project use?
>
> | # | Option | Description |
> |---|---|---|
> | 1 | `database-first` *(default)* | DBA outputs `db-init.sql`. Engineers write ORM entities from it. Best when schema is the source of truth or integrating an existing database. |
> | 2 | `code-first` | DBA outputs design doc only. Engineers drive schema via ORM migrations (e.g. EF Core). Best when code owns the schema lifecycle. |
>
> Enter a number [Enter = 1]:

### Group E — UI design approach

Ask only if the project type includes a frontend (i.e. not `backend-only` or `api-only`).

> **Q8.** Which design approach will this project use?
>
> | # | Option | Description |
> |---|---|---|
> | 1 | `architecture-first` *(default)* | Architect → DBA → UI Designer. UI Designer reads `architect.md` + `requirement.md`. Best for B2B / industrial / high-integration systems. |
> | 2 | `ui-first` | UI Designer → Architect → DBA. Architect and DBA read `ui-design.md`. Best for C-side products or prototype-driven projects. |
>
> Enter a number [Enter = 1]:

### Group F — Delivery mode

> **Q9.** What delivery mode will this project use?
>
> | # | Option | Description |
> |---|---|---|
> | 1 | `standard` *(default)* | Single flat output path. Best for small teams or non-sprint projects. |
> | 2 | `scrum` | Output versioned per sprint. Best for iterative Scrum projects. |
>
> Enter a number [Enter = 1]:

If `scrum` is selected:

> **Q10.** What is the initial version and sprint name?
> *(e.g. version: `v1.0`, sprint: `sprint-1`)*

### Group G — DevOps / Container / CI

> **Q11.** Will this project use Docker for containerisation?
> Options: `yes` / `no` *(default: no)*

If `yes` is selected:

> - What is the base image strategy? *(e.g. `mcr.microsoft.com/dotnet/aspnet:9.0` / `node:22-alpine` / leave blank to decide later)*
> - Will Docker Compose be used for local development? `yes` / `no` *(default: yes)*
> - Target registry? *(e.g. `Docker Hub` / `GitHub Container Registry` / `Azure Container Registry` / leave blank)*

> **Q12.** Will this project set up a CI/CD pipeline?
> Options: `yes` / `no` *(default: no)*

If `yes` is selected:

> - Which CI/CD platform? *(e.g. `GitHub Actions` / `GitLab CI` / `Azure DevOps` / `Jenkins`)*
> - Pipeline stages to include? *(Select all that apply: `lint` / `build` / `test` / `docker-build` / `deploy-staging` / `deploy-production`)*
> - Target deployment environment? *(e.g. `Azure App Service` / `Kubernetes` / `VPS` / leave blank)*
> - Automatic deployment on merge to main branch? `yes` / `no` *(default: yes)*

---

## Step 3: Write `.ai/context/workflow-config.md`

Using all collected answers, write the file with every answered field already filled in:

```markdown
# Digital Team Workflow Configuration

## Project Information

- project_name: "{answer to Q1}"
- project_type: "{answer to Q2}"   # fullstack | frontend-only | backend-only | api-only
- output_language: "{answer to Q3}"   # en-US | zh-CN | ja-JP
- db_approach: "{answer to Q7}"          # database-first | code-first (omit line if no backend)
- design_approach: "{answer to Q8}"      # architecture-first | ui-first (omit line if no frontend)
- delivery_mode: "{answer to Q9}"        # standard | scrum
- current_version: "{answer to Q10}"     # e.g. v1.0  (omit line if standard)
- current_sprint: "{answer to Q10}"      # e.g. sprint-1  (omit line if standard)

## Role Configuration

| Role              | Status                  | Skip Reason            |
|-------------------|-------------------------|------------------------|
| product-manager   | {status}                | {reason or -}          |
| architect         | {status}                | {reason or -}          |
| dba               | {status}                | {reason or -}          |
| ui-designer       | {status}                | {reason or -}          |
| project-manager   | {status}                | {reason or -}          |
| plan              | {status}                | {reason or -}          |
| frontend-engineer | {status}                | {reason or -}          |
| dotnet-engineer   | {status}                | {reason or -}          |
| qa-engineer       | {status}                | {reason or -}          |

## Phase Sequence

`@digital-team` applies the phase order below based on `design_approach`.

**architecture-first** (default)
```
P1(PM) → P2a(Architect) → P2b(DBA) → Gate 2 → P3(UI Designer) → P4 → P5 → P6(Frontend + .NET) → P7
```

**ui-first**
```
P1(PM) → P2(UI Designer) → P3a(Architect) → P3b(DBA) → Gate 3 → P4 → P5 → P6(Frontend + .NET) → P7
```

## Tech Stack

```yaml
frontend:
  framework: "{answer or empty string}"
  css: "{answer or empty string}"
  state: "{answer or empty string}"
  ui_library: "{answer or empty string}"

backend:
  framework: "{answer or empty string}"
  orm: "{answer or empty string}"
  database: "{answer or empty string}"
  cache: "{answer or empty string}"

deploy:
  platform: "{answer or empty string}"

docker:
  enabled: "{yes | no}"                          # answer to Q11
  base_image: "{base image or empty string}"
  compose: "{yes | no}"
  registry: "{registry or empty string}"

cicd:
  enabled: "{yes | no}"                          # answer to Q12
  platform: "{platform or empty string}"
  stages: "{comma-separated stages or empty string}"
  deploy_target: "{target or empty string}"
  auto_deploy_on_main: "{yes | no}"
```

## Current Iteration Goal

{answer to Q4}
```

---

## Step 4: Write context files

### `.ai/context/architect_constraint.md`

Create this file only if it does not already exist:

```markdown
# Architecture Constraints

> Maintained by the Architect before Phase 2 begins. All roles read-only.

## Tech Stack Version Lock

(Fill in exact versions once confirmed, e.g. .NET 8.0, Vue 3.4, PostgreSQL 16)

## Prohibited Dependencies

(List frameworks and libraries not permitted in this project)

## Deployment Constraints

(Environment limits, container requirements, resource quotas, etc.)

## Layering Standards

(Project layer structure — shared reference for all engineers)
```

### `.ai/context/ui_constraint.md`

Create this file only if the project type includes a frontend (not `backend-only` or `api-only`) and the file does not already exist.

> Fill in the values you already know. Leave any field blank to let `@ui-designer` propose and apply a neutral enterprise default.

```markdown
# UI Constraints

> Filled manually by the PM, tech lead, or designer before the UI Design phase.
> @ui-designer reads this file to match brand identity, technology stack, and usability requirements.

## Brand Colours

```yaml
primary:          ""   # e.g. #1677ff
primary_dark:     ""   # e.g. #0958d9
secondary:        ""   # e.g. #52c41a
danger:           ""   # e.g. #ff4d4f
warning:          ""   # e.g. #faad14
success:          ""   # e.g. #52c41a
info:             ""   # e.g. #1677ff
neutral_bg:       ""   # e.g. #f5f5f5
surface:          ""   # e.g. #ffffff
text_primary:     ""   # e.g. #1f1f1f
text_secondary:   ""   # e.g. #8c8c8c
border:           ""   # e.g. #d9d9d9
```

## Style Tone

```yaml
tone: ""   # clean-light | enterprise-gray | professional-dark
```

## UI Library

```yaml
ui_library: ""   # must match ui_library in workflow-config.md Tech Stack
```

## Typography

```yaml
font_family:    ""
font_size_base: ""   # e.g. 14px
line_height:    ""   # e.g. 1.5
```

## Layout

```yaml
sidebar_width:   ""   # e.g. 240px
header_height:   ""   # e.g. 56px
content_padding: ""   # e.g. 24px
border_radius:   ""   # e.g. 6px
```

## Other

```yaml
dark_mode: ""   # required | optional | not-needed
i18n:      ""   # zh-CN | en-US | both
```

## Reference

(Brand guideline URL, Figma link, or existing screenshot path)
```

---

## Step 5: Completion Summary

Print a summary table of all files and directories created.

Then print the following guidance block — **replace fields with the actual values collected**:

```
Project "{project-name}" initialised.

Workflow config written to .ai/context/workflow-config.md
  Output language : {output_language}
  Iteration goal  : {iteration_goal}
  Enabled roles   : {comma-separated list of enabled roles}
  Skipped roles   : {comma-separated list of skipped roles, or "none"}

Tech stack fields left blank: {list blank fields, or "none — fully configured"}
→ You can fill these in .ai/context/workflow-config.md at any time before the Architect phase.

Next step: open Copilot Chat → Agent mode → select digital-team → state your iteration goal.

> **Scrum users:** To start a new sprint or version later, update `current_version` and `current_sprint` in `.ai/context/workflow-config.md`, create the new `.ai/{version}/{sprint}/temp/` and `.ai/{version}/{sprint}/reports/` directories, then restart `digital-team`.
```
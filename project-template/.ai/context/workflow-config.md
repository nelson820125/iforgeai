# forgeai workflow config

> Controls which roles are active for this project. Read by `@digital-team` at startup.
> Copy this template into each project and edit as needed.

## Project info

```yaml
project_name: "{project-name}"
project_type: "fullstack" # fullstack | frontend-only | backend-only | api-only
iteration: "v1.0"
db_approach: "database-first" # database-first | code-first
                               # database-first: DBA outputs db-init.sql; engineers reference it to write ORM entities
                               # code-first: DBA outputs design doc only; engineers drive schema via ORM migrations (e.g. EF Core)
design_approach: "architecture-first" # architecture-first | ui-first
                                      # architecture-first: Architect → DBA → UI Designer
                                      #   UI Designer reads requirement.md + architect.md + ui_constraint.md
                                      #   Recommended for B2B / industrial / high-integration systems
                                      # ui-first: UI Designer → Architect → DBA
                                      #   UI Designer reads requirement.md + ui_constraint.md only
                                      #   Architect and DBA additionally read ui-design.md
                                      #   Suitable for C-side products or prototype-driven projects
```

## Role configuration

| Role              | Status  | Skip reason (if skipped) |
| ----------------- | ------- | ------------------------ |
| product-manager   | enabled | -                        |
| architect         | enabled | -                        |
| dba               | enabled | -                        |
| ui-designer       | enabled | -                        |
| project-manager   | enabled | -                        |
| plan              | enabled | -                        |
| frontend-engineer | enabled | -                        |
| dotnet-engineer   | enabled | -                        |
| qa-engineer       | enabled | -                        |

> Pure backend/API project: set `ui-designer` and `frontend-engineer` to `skip | no frontend`
>
> Pure frontend project: set `dba` and `dotnet-engineer` to `skip | no backend`

## Phase order

`@digital-team` reads `design_approach` above and applies the corresponding phase order automatically.

**architecture-first** (default)
```
P1(PM) → P2a(Architect) → P2b(DBA) → Gate 2 → P3(UI Designer) → P4 → P5 → P6(Frontend + .NET) → P7
```

**ui-first**
```
P1(PM) → P2(UI Designer) → P3a(Architect) → P3b(DBA) → Gate 3 → P4 → P5 → P6(Frontend + .NET) → P7
```

## Tech stack

> Filled-in values here take precedence — architect and engineer roles read this first to avoid repeated exploration.

```yaml
frontend:
  framework: "" # e.g. Vue 3, React 18
  css: "" # e.g. SCSS + CSS Variables, Tailwind
  state: "" # e.g. Pinia, Zustand
  ui_library: "" # e.g. Element Plus, Ant Design

backend:
  framework: "" # e.g. ASP.NET Core 8, NestJS
  orm: "" # e.g. EF Core, Dapper, SqlSugar
  database: "" # e.g. PostgreSQL 16, SQL Server 2022
  cache: "" # e.g. Redis 7

deploy:
  platform: "" # e.g. Docker + Nginx, Azure App Service
```

## Iteration goal

> Record the one-sentence MVP goal for this iteration. All roles read this as shared context.

```
Iteration goal: (fill in)
```

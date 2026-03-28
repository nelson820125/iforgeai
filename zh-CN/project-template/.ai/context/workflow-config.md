# iforgeAI 工作流配置

> 控制本项目哪些角色启用。由 `@digital-team` 在启动时读取。
> 复制此模板到每个项目并按需修改。

## 项目信息

```yaml
project_name: "{project-name}"
project_type: "fullstack" # fullstack | frontend-only | backend-only | api-only
iteration: "v1.0"
db_approach: "database-first" # database-first | code-first
                               # database-first：DBA 输出 db-init.sql，工程师参考此文件编写 ORM 实体类
                               # code-first：DBA 仅输出设计文档，工程师通过 ORM Migration 驱动 Schema（如 EF Core）
design_approach: "architecture-first" # architecture-first | ui-first
                                      # architecture-first：架构 → DBA → UI 设计师
                                      #   UI 设计师读取 requirement.md + architect.md + ui_constraint.md
                                      #   推荐用于 B2B / 工业软件 / 高集成度系统
                                      # ui-first：UI 设计师 → 架构 → DBA
                                      #   UI 设计师仅读取 requirement.md + ui_constraint.md
                                      #   架构师和 DBA 额外读取 ui-design.md
                                      #   适用于 C 端产品或以原型驱动的项目
```

## 角色配置

| 角色              | 状态    | 跳过原因（如跳过） |
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

> 纯后端 / API 项目：将 `ui-designer` 和 `frontend-engineer` 设为 `skip | 无前端界面`
>
> 纯前端项目：将 `dba` 和 `dotnet-engineer` 设为 `skip | 无后端`

## 阶段顺序

`@digital-team` 启动时读取上方 `design_approach` 字段，自动应用对应的阶段顺序。

**architecture-first**（默认）
```
P1(PM) → P2a(架构) → P2b(DBA) → Gate 2 → P3(UI 设计师) → P4 → P5 → P6(前端 + .NET) → P7
```

**ui-first**
```
P1(PM) → P2(UI 设计师) → P3a(架构) → P3b(DBA) → Gate 3 → P4 → P5 → P6(前端 + .NET) → P7
```

## 技术栈摘要

> 填写后架构师和工程师角色会优先读取此处，减少重复探索。

```yaml
frontend:
  framework: "" # 如：Vue 3, React 18
  css: "" # 如：SCSS + CSS Variables, Tailwind
  state: "" # 如：Pinia, Zustand
  ui_library: "" # 如：Element Plus, Ant Design

backend:
  framework: "" # 如：ASP.NET Core 8, NestJS
  orm: "" # 如：EF Core, Dapper, SqlSugar
  database: "" # 如：PostgreSQL 16, SQL Server 2022
  cache: "" # 如：Redis 7

deploy:
  platform: "" # 如：Docker + Nginx, Azure App Service
```

## 本迭代目标

> 用一句话记录本迭代的 MVP 目标。所有角色以此为共同背景。

```
迭代目标：（启动前填写）
```

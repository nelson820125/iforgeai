---
description: "Initialize the digital-team workspace for a new project. Guides the user through project configuration step by step, then creates .ai/ directories and a fully pre-filled workflow-config.md. Run before starting a new iteration."
name: "init-project"
argument-hint: "project-name project-type (fullstack/frontend-only/backend-only/api-only)"
agent: "agent"
---

在当前工作区初始化数字团队工作区。
按以下步骤依次执行。**不要跳过引导问答** — 先收集答案，再写文件。

---

## 步骤 1：创建目录结构

创建以下目录（不存在时创建，已存在时跳过）：
- `.ai/context/`
- `.ai/records/`
- `.github/instructions/`

然后根据 Q9 的交付模式决定其他目录：
- **`standard`**：另外创建 `.ai/temp/` 和 `.ai/reports/`
- **`scrum`**：创建 `.ai/{version}/{sprint}/temp/` 和 `.ai/{version}/{sprint}/reports/`（`{version}` 和 `{sprint}` 为 Q10 的答案）

---

## 步骤 2：引导配置问答

**每次只问一组问题**，等用户回答后再继续下一组。
如用户输入"跳过"或留空，则记录括号内的占位值。

### A 组 — 项目基本信息

如果 `{项目名称}` 和 `{项目类型}` 已通过参数传入，则确认后跳过前两题。

> **Q1.** 项目名称是什么？
> *（占位值：`my-project`）*
>
> **Q2.** 项目类型是什么？
> 可选：`fullstack`（全栈）/ `frontend-only`（纯前端）/ `backend-only`（纯后端）/ `api-only`（纯 API）
> *（占位值：`fullstack`）*
>
> **Q3.** 产出文档（需求、架构设计等）使用什么语言？
> 可选：`zh-CN`（简体中文）/ `en-US`（英文）/ `ja-JP`（日文）
> *（占位值：`zh-CN`）*
>
> **Q4.** 本次迭代的 MVP 目标一句话是什么？
> 示例：*"实现用户认证与基于角色的菜单权限控制"*
> *（占位值：`（启动前填写）`）*

### B 组 — 角色配置

根据 Q2 的项目类型，给出建议的跳过角色，请用户确认或调整：

- `frontend-only` → 建议跳过：`dba`、`dotnet-engineer`
- `backend-only` / `api-only` → 建议跳过：`ui-designer`、`frontend-engineer`
- `fullstack` → 默认全部启用

> **Q5.** 根据项目类型，建议的角色配置如下：
> *（展示建议表格）*
> 是否有需要额外跳过的角色？如无，按 Enter 确认。

记录每个角色的最终状态：`enabled` 或 `skip | {跳过原因}`。

### C 组 — 技术栈

仅询问与项目类型相关的字段（如纯后端项目，跳过所有前端字段）。

> **Q6.** 技术栈 — 有确定值的填写，暂未确定的按 Enter 留空：
>
> - 前端框架？*（例如 Vue 3.5 / React 19 / 跳过）*
> - CSS 方案？*（例如 SCSS + CSS Variables / Tailwind CSS 4 / 跳过）*
> - 状态管理？*（例如 Pinia / Zustand / 跳过）*
> - UI 组件库？*（例如 Element Plus / Ant Design 5 / 跳过）*
> - 后端框架？*（例如 ASP.NET Core 9 / NestJS 11 / 跳过）*
> - ORM / 数据访问？*（例如 EF Core 9 / Dapper / SqlSugar / 跳过）*
> - 数据库？*（例如 PostgreSQL 17 / SQL Server 2022 / 跳过）*
> - 缓存？*（例如 Redis 8 / 跳过）*
> - 部署平台？*（例如 Docker + Nginx / Azure App Service / 跳过）*

留空的字段写为 `""`。

### D 组 — 数据库方案

仅在项目类型包含后端时询问（即非 `frontend-only`）。

> **Q7.** 本项目使用哪种数据库开发方式？
>
> | # | 选项 | 说明 |
> |---|---|---|
> | 1 | `database-first`（默认） | DBA 输出 `db-init.sql`，工程师参考写 ORM 实体。适合以 Schema 为权威来源或接入已有数据库的项目。 |
> | 2 | `code-first` | DBA 仅输出设计文档，工程师通过 ORM Migration 驱动 Schema。适合代码主导 Schema 生命周期的项目。 |
>
> 请输入数字选择 [Enter = 1]:

### E 组 — UI 设计阶段顺序

仅在项目类型包含前端时询问（即非 `backend-only` / `api-only`）。

> **Q8.** 本项目使用哪种设计方式？
>
> | # | 选项 | 说明 |
> |---|---|---|
> | 1 | `architecture-first`（默认） | 架构 → DBA → UI 设计师。UI 设计师读取 `architect.md` + `requirement.md`。适合 B2B / 工业软件 / 高集成度系统。 |
> | 2 | `ui-first` | UI 设计师 → 架构 → DBA。架构师和 DBA 读取 `ui-design.md`。适合 C 端产品或原型驱动项目。 |
>
> 请输入数字选择 [Enter = 1]:

### F 组 — 交付模式

> **Q9.** 本项目使用哪种交付模式？
>
> | # | 选项 | 说明 |
> |---|---|---|
> | 1 | `standard`（默认） | 单一扁平输出路径。适合小团队或非迭代项目。 |
> | 2 | `scrum` | 按 Sprint 版本化输出。适合迭代式 Scrum 项目。 |
>
> 请输入数字选择 [Enter = 1]：

若选择 `scrum`：

> **Q10.** 初始版本号和 Sprint 名称是什么？
> *（例如 版本：`v1.0`，Sprint：`sprint-1`）*

### G 组 — DevOps / 容器 / CI

> **Q11.** 本项目是否使用 Docker 进行容器化？
> 可选：`是` / `否`（默认：否）

若选择 `是`：

> - 基础镜像策略？*（例如 `mcr.microsoft.com/dotnet/aspnet:9.0` / `node:22-alpine` / 留空待定）*
> - 是否使用 Docker Compose 进行本地开发？`是` / `否`（默认：是）
> - 目标镜像仓库？*（例如 `Docker Hub` / `GitHub Container Registry` / `Azure Container Registry` / 留空）*

> **Q12.** 本项目是否配置 CI/CD 流水线？
> 可选：`是` / `否`（默认：否）

若选择 `是`：

> - 使用哪个 CI/CD 平台？*（例如 `GitHub Actions` / `GitLab CI` / `Azure DevOps` / `Jenkins`）*
> - 需要包含哪些流水线阶段？*（多选：`代码检查` / `构建` / `测试` / `docker-build` / `部署到测试环境` / `部署到生产环境`）*
> - 目标部署环境？*（例如 `Azure App Service` / `Kubernetes` / `VPS` / 留空）*
> - 合并到主分支时自动部署？`是` / `否`（默认：是）

---

## 步骤 3：写入 `.ai/context/workflow-config.md`

```markdown
# 数字团队工作流配置

## 项目信息

- project_name: "{Q1 答案}"
- project_type: "{Q2 答案}"   # fullstack | frontend-only | backend-only | api-only
- output_language: "{Q3 答案}"   # en-US | zh-CN | ja-JP
- db_approach: "{Q7 答案}"          # database-first | code-first（纯前端项目可省略此行）
- design_approach: "{Q8 答案}"      # architecture-first | ui-first（纯后端项目可省略此行）
- delivery_mode: "{Q9 答案}"        # standard | scrum
- current_version: "{Q10 答案}"     # 如 v1.0（standard 模式可省略）
- current_sprint: "{Q10 答案}"      # 如 sprint-1（standard 模式可省略）

## 角色配置

| 角色              | 状态                  | 跳过原因            |
|-------------------|-----------------------|---------------------|
| product-manager   | {状态}                | {原因或 -}          |
| architect         | {状态}                | {原因或 -}          |
| dba               | {状态}                | {原因或 -}          |
| ui-designer       | {状态}                | {原因或 -}          |
| project-manager   | {状态}                | {原因或 -}          |
| plan              | {状态}                | {原因或 -}          |
| frontend-engineer | {状态}                | {原因或 -}          |
| dotnet-engineer   | {状态}                | {原因或 -}          |
| qa-engineer       | {状态}                | {原因或 -}          |

## 阶段顺序

`@digital-team` 根据 `design_approach` 自动应用对应的阶段顺序。

**architecture-first**（默认）
```
P1(PM) → P2a(架构) → P2b(DBA) → Gate 2 → P3(UI 设计师) → P4 → P5 → P6(前端 + .NET) → P7
```

**ui-first**
```
P1(PM) → P2(UI 设计师) → P3a(架构) → P3b(DBA) → Gate 3 → P4 → P5 → P6(前端 + .NET) → P7
```

## 技术栈

```yaml
frontend:
  framework: "{答案或空字符串}"
  css: "{答案或空字符串}"
  state: "{答案或空字符串}"
  ui_library: "{答案或空字符串}"

backend:
  framework: "{答案或空字符串}"
  orm: "{答案或空字符串}"
  database: "{答案或空字符串}"
  cache: "{答案或空字符串}"

deploy:
  platform: "{答案或空字符串}"

docker:
  enabled: "{是 | 否}"                          # Q11 答案
  base_image: "{基础镜像或空字符串}"
  compose: "{是 | 否}"
  registry: "{镜像仓库或空字符串}"

cicd:
  enabled: "{是 | 否}"                          # Q12 答案
  platform: "{平台名称或空字符串}"
  stages: "{逗号分隔的阶段列表或空字符串}"
  deploy_target: "{目标环境或空字符串}"
  auto_deploy_on_main: "{是 | 否}"
```

## 本迭代目标

{Q4 答案}
```

---

## 步骤 4：写入配置文件

### `.ai/context/architect_constraint.md`

仅当文件不存在时创建：

```markdown
# 架构约束

> 由架构师在 Phase 2 开始前维护，所有角色只读。

## 技术栈版本锁定

（确认版本后填写，例如 .NET 8.0、Vue 3.4、PostgreSQL 16）

## 禁止引入的依赖

（列明本项目不允许使用的框架和库）

## 部署约束

（环境限制、容器要求、资源配额等）

## 分层规范

（项目分层结构说明，供所有工程师参考）
```

### `.ai/context/ui_constraint.md`

仅当项目类型包含前端（非 `backend-only` / `api-only`）且文件不存在时创建。

> 已知的字段现在填写，留空的字段由 `@ui-designer` 自行提案并应用中性企业级默认属性。

```markdown
# UI 约束条件

> 由 PM、技术负责人或设计师在 UI 设计阶段开始前手工填写。
> @ui-designer 读取此文件以遵循品牌规范、技术栈和可用性要求。

## 品牌配色

```yaml
primary:          ""   # 主色，如 #1677ff
primary_dark:     ""   # 主色深色态，如 #0958d9
secondary:        ""   # 辅助色，如 #52c41a
danger:           ""   # 错误/危险，如 #ff4d4f
warning:          ""   # 警告，如 #faad14
success:          ""   # 成功，如 #52c41a
info:             ""   # 信息提示，如 #1677ff
neutral_bg:       ""   # 页面背景，如 #f5f5f5
surface:          ""   # 卡片/面板背景，如 #ffffff
text_primary:     ""   # 正文标题，如 #1f1f1f
text_secondary:   ""   # 次要提示文字，如 #8c8c8c
border:           ""   # 默认分割线，如 #d9d9d9
```

## 风格基调

```yaml
tone: ""   # clean-light | enterprise-gray | professional-dark
```

## UI 组件库

```yaml
ui_library: ""   # 必须与 workflow-config.md 技术栈中的 ui_library 一致
```

## 字体与排版

```yaml
font_family:    ""
font_size_base: ""   # 如 14px
line_height:    ""   # 如 1.5
```

## 布局

```yaml
sidebar_width:   ""   # 如 240px
header_height:   ""   # 如 56px
content_padding: ""   # 如 24px
border_radius:   ""   # 如 6px
```

## 其他

```yaml
dark_mode: ""   # required（必要）| optional（可选）| not-needed（不需要）
i18n:      ""   # zh-CN | en-US | both
```

## 参考资料

（填写品牌规范 URL、Figma 链接或现有截图路径）
```

---

## 步骤 5：完成摘要

打印已创建文件和目录的汇总表。

然后打印以下引导块（**用实际收集的值替换占位字段**）：

```
项目 "{项目名称}" 初始化完成。

工作流配置已写入 .ai/context/workflow-config.md
  输出语言：{output_language}
  迭代目标：{iteration_goal}
  已启用角色：{逗号分隔的启用角色列表}
  已跳过角色：{逗号分隔的跳过角色列表，无则填"无"}

留空的技术栈字段：{列出留空字段，无则填"无 — 已全部填写"}
→ 可随时在 .ai/context/workflow-config.md 中补充，在架构师阶段开始前完成即可。

下一步：打开 Copilot Chat → Agent 模式 → 选择 digital-team → 输入迭代目标。

> **Scrum 用户：** 后续启动新 Sprint 或新版本时，请在 `.ai/context/workflow-config.md` 中更新 `current_version` 和 `current_sprint`，创建对应的 `.ai/{version}/{sprint}/temp/` 和 `.ai/{version}/{sprint}/reports/` 目录，然后重新启动 `digital-team`。
```
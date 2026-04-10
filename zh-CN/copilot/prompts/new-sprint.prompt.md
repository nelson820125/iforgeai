---
description: "启动新的 Scrum Sprint。更新 workflow-config.md 中的版本和 Sprint 信息，创建 Sprint 目录，将上一 Sprint 的未完成项带入，并启动 @digital-team 开始新周期。每个新 Sprint 开始时使用。"
name: "new-sprint"
argument-hint: "new-version new-sprint（如 v1.0 sprint-2）"
agent: "agent"
---

在当前项目启动新 Sprint。按以下步骤依次执行。

---

## 步骤 1：确认新 Sprint 信息

如果 `{new-version}` 和 `{new-sprint}` 已通过参数传入，则确认后继续。否则询问：

> **NS1.** 新版本标签是什么？*（如 `v1.0`、`v1.1` — 发布新版本时递增）*
>
> **NS2.** 新 Sprint 名称是什么？*（如 `sprint-2`、`sprint-3`）*
>
> **NS3.** 本 Sprint 的 MVP 目标是什么？*（一句话）*

---

## 步骤 2：读取上一 Sprint 状态

读取 `.ai/context/workflow-config.md`，获取 `current_version` 和 `current_sprint`。

检查上一 Sprint 的未完成项：
- `.ai/{prev_version}/{prev_sprint}/temp/wbs.md` — 查找未完成任务（未勾选的 `[ ]` 项）
- `.ai/context/backlog.md` — 需求变更中推迟的条目

列出发现的遗留项：

```
来自 {prev_version}/{prev_sprint} 的遗留项：
- {条目 1}
- {条目 2}
（如无则标注：无遗留）
```

请用户确认哪些遗留项纳入本 Sprint。

---

## 步骤 3：创建 Sprint 目录

创建以下目录：

- `.ai/{new-version}/{new-sprint}/temp/`
- `.ai/{new-version}/{new-sprint}/reports/`

---

## 步骤 4：更新 workflow-config.md

仅更新 `.ai/context/workflow-config.md` 中的以下两个字段：

```yaml
current_version: "{new-version}"
current_sprint: "{new-sprint}"
```

不修改其他任何字段。

---

## 步骤 5：写入遗留项（如有）

若用户确认了遗留项，写入 `.ai/{new-version}/{new-sprint}/temp/carry-over.md`：

```markdown
# 遗留项 · {new-version}/{new-sprint}

来源：{prev_version}/{prev_sprint}

{用户确认的遗留项列表}
```

---

## 步骤 6：启动

告知用户：

> Sprint **{new-version}/{new-sprint}** 已准备就绪。
> 迭代目标：{NS3}
> 点击 `@digital-team` 并描述本 Sprint 目标，开始第一阶段。

---
description: "Handle a mid-iteration change request. Assesses impact across all upstream artefacts, identifies which phases need to be re-run, and updates affected documents. Run when requirements change after Gate 1 approval."
name: "change-request"
argument-hint: "Describe the change: what is being added, removed, or modified, and why"
agent: "agent"
---

Process a change request against the current iteration in progress.
Work through the steps below in order. Do **not** skip the impact assessment — collect the change details first, then evaluate scope.

---

## Step 1: Capture the Change

Ask the user:

> **CR1.** What is changing? Describe the delta — not the full feature, only what is added, removed, or modified.
>
> **CR2.** Why is this change needed? (business reason, discovered constraint, or stakeholder decision)
>
> **CR3.** Is this change in scope for the current iteration, or should it be deferred to the next sprint?
> Options: `in-scope` / `defer`

If `defer` → write the change to `.ai/context/backlog.md` (create if absent, append if exists) and stop here.

---

## Step 2: Impact Assessment

Read the following documents before assessing impact:

- `.ai/temp/requirement.md`
- `.ai/temp/architect.md`
- `.ai/temp/db-design.md`
- `.ai/temp/ui-design.md`
- `.ai/temp/wbs.md`
- `.ai/temp/api-contract.md`
- `.ai/temp/plan.md`

For each document, determine: **Does this change require updating this artefact?**

Output an impact table:

| Artefact | Affected? | What changes |
|---|---|---|
| `requirement.md` | Yes / No | (describe delta) |
| `architect.md` | Yes / No | ... |
| `db-design.md` | Yes / No | ... |
| `ui-design.md` | Yes / No | ... |
| `wbs.md` | Yes / No | ... |
| `api-contract.md` | Yes / No | ... |
| `plan.md` | Yes / No | ... |

---

## Step 3: Re-run Plan

Based on the impact table, state which phases must be re-run and in what order:

```
Phases to re-run: P{N} → P{N+1} → ...
Phases unaffected (skip): P{X}, P{Y}
```

Ask the user to confirm before proceeding:

> The change requires re-running: **[list phases]**
> Confirm to proceed? (yes / adjust / cancel)

---

## Step 4: Execute

If confirmed, instruct the user to click the appropriate handoff buttons in `@digital-team` to re-run each affected phase in sequence.

Write a change log entry to `.ai/context/change-log.md` (create if absent, append if exists):

```markdown
## CR-{date} · {one-line change summary}

**Reason:** {CR2 answer}
**Phases re-run:** {list}
**Artefacts updated:** {list}
```

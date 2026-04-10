---
description: "Start a new Scrum sprint. Updates workflow-config.md with the new version and sprint, creates sprint directories, carries over any unfinished items from the previous sprint, and launches @digital-team for the new cycle. Use at the start of every new sprint."
name: "new-sprint"
argument-hint: "new-version new-sprint (e.g. v1.0 sprint-2)"
agent: "agent"
---

Start a new sprint in the current project. Work through the steps below in order.

---

## Step 1: Confirm New Sprint Details

If `{new-version}` and `{new-sprint}` were supplied as arguments, confirm them. Otherwise ask:

> **NS1.** New version tag? *(e.g. `v1.0`, `v1.1` — increment if releasing a new version)*
>
> **NS2.** New sprint name? *(e.g. `sprint-2`, `sprint-3`)*
>
> **NS3.** What is the MVP goal for this sprint? *(one sentence)*

---

## Step 2: Read Previous Sprint State

Read `.ai/context/workflow-config.md` to find `current_version` and `current_sprint`.

Check for unfinished items in the previous sprint:
- `.ai/{prev_version}/{prev_sprint}/temp/wbs.md` — look for incomplete tasks (unchecked `[ ]` items)
- `.ai/context/backlog.md` — deferred items from change requests

List any carry-over items found:

```
Carry-over from {prev_version}/{prev_sprint}:
- {item 1}
- {item 2}
(none if clean)
```

Ask the user to confirm which carry-over items to include in this sprint.

---

## Step 3: Create Sprint Directories

Create the following directories:

- `.ai/{new-version}/{new-sprint}/temp/`
- `.ai/{new-version}/{new-sprint}/reports/`

---

## Step 4: Update workflow-config.md

Update only these two fields in `.ai/context/workflow-config.md`:

```yaml
current_version: "{new-version}"
current_sprint: "{new-sprint}"
```

Do not modify any other fields.

---

## Step 5: Seed Carry-Over (if any)

If carry-over items were confirmed, write them to `.ai/{new-version}/{new-sprint}/temp/carry-over.md`:

```markdown
# Carry-Over Items · {new-version}/{new-sprint}

Sourced from: {prev_version}/{prev_sprint}

{list of confirmed carry-over items}
```

---

## Step 6: Launch

Tell the user:

> Sprint **{new-version}/{new-sprint}** is ready.
> Iteration goal: {NS3}
> Click `@digital-team` and describe the sprint goal to begin Phase 1.

---
description: "Fast-track a production hotfix. Bypasses design phases and goes directly to implementation and deployment. Use only for critical production issues that cannot wait for a normal iteration cycle."
name: "hotfix"
argument-hint: "Describe the production issue: symptom, affected component, and urgency"
agent: "agent"
---

Initiate a hotfix track. This workflow **skips** P1–P5 and goes directly to implementation → QA (smoke only) → deploy.

---

## Step 1: Confirm Hotfix Scope

Ask the user:

> **HF1.** What is broken in production? (symptom + affected component + error message if available)
>
> **HF2.** What is the root cause (or best current hypothesis)?
>
> **HF3.** What is the fix? (describe the code change — one sentence)
>
> **HF4.** What is the risk of this fix causing regression?
> Options: `low` (isolated change, no shared dependencies) / `medium` (touches shared code) / `high` (core path change)
>
> **HF5.** Hotfix version tag? *(e.g. `v1.2.1-hotfix`)*

If risk is `high` → warn the user and ask for explicit confirmation before proceeding.

---

## Step 2: Create Hotfix Record

Write `.ai/context/hotfix-{HF5}.md`:

```markdown
# Hotfix {HF5}

**Date:** {today}
**Issue:** {HF1}
**Root cause:** {HF2}
**Fix:** {HF3}
**Risk level:** {HF4}

## Verification Steps
- [ ] Issue reproduced in staging before fix
- [ ] Fix applied and issue resolved in staging
- [ ] No regression in related flows (smoke test)
- [ ] Deployed to production
- [ ] Issue confirmed resolved in production
```

---

## Step 3: Implement

Direct the user to invoke the appropriate engineer agent directly (skip `@digital-team` orchestration):

> Invoke `@dotnet-engineer` / `@java-engineer` / `@python-engineer` / `@frontend-engineer` with:
> "Hotfix: {HF3}. Reference `.ai/context/hotfix-{HF5}.md` for context. Implement the minimal change only — no refactoring."

---

## Step 4: Smoke QA

Direct the user to invoke `@qa-engineer` with:

> "Smoke test only for hotfix {HF5}. Verify: 1) the reported issue is resolved, 2) the immediate surrounding flows still work. Write findings to `.ai/reports/hotfix-{HF5}-qa.md`."

---

## Step 5: Deploy

Direct the user to invoke `@devops-engineer` with:

> "Emergency deployment for hotfix {HF5}. Read `.ai/context/hotfix-{HF5}.md` and `.ai/reports/hotfix-{HF5}-qa.md`. Produce a minimal deploy runbook — no full deploy guide needed, only the steps specific to this hotfix."

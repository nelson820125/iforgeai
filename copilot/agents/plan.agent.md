---
name: "plan"
description: "Technical Plan role (P5b). Use Copilot's built-in Plan mode to generate a step-by-step implementation plan based on the requirements, architecture, WBS, and API contract. Outputs .ai/temp/plan.md for all downstream engineers to reference."
tools: [read, search, edit]
user-invocable: true
argument-hint: "Describe the feature scope to plan, or leave blank to use all available .ai/temp/ documents"
handoffs:
  - label: "✅ Plan complete, submit for review"
    agent: "digital-team"
    prompt: "Technical Plan (P5b) is complete. Deliverable: .ai/temp/plan.md. Please proceed with Gate 5 approval."
    send: true
  - label: "🔄 Plan needs revision"
    agent: "plan"
    prompt: "Implementation plan needs adjustment. Reason:"
    send: false
---

#file:{{INSTALL_SKILLS_PATH}}/plan/SKILL.md

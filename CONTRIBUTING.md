# Contributing to forgeai

## Before you start

Read the [README](./README.md) to understand how the agent system works. Most contributions fall into one of three categories: role improvements, adding a new role, or infrastructure changes (installer, README, shared standards).

## Issues

Search existing issues before opening a new one.

When reporting a bug, include:

- OS and PowerShell version
- VS Code version
- The agent name and exact input that triggered the problem
- Expected behavior vs. actual behavior

When requesting a feature, describe the specific problem or workflow gap it addresses.

## Pull Requests

Branch from `main`. Keep each PR focused on one change. Unrelated fixes belong in a separate PR.

### Improving an existing role

Role behavior is defined in two places:

- `copilot/skills/{role}/SKILL.md` — the agent's role definition, constraints, and output format
- `copilot/agents/{role}.agent.md` — handoff buttons and workflow wiring

Changes to one do not always require changes to the other. A constraint update usually only touches `SKILL.md`. A new handoff path touches `*.agent.md` and `digital-team.agent.md`.

When editing a skill:

- Keep the output format section precise — downstream agents depend on specific file paths and section structures
- Do not soften or make constraints vague. Constraints exist because the default behavior produces bad output.
- Test by running the role against a real requirement and checking the output matches the spec

Also update the corresponding `shared/roles/{role}.md` (the platform-agnostic version without Copilot frontmatter).

### Adding a new role

1. Create `copilot/skills/{role-name}/SKILL.md`
   - Define: persona, inputs (with file paths), outputs (with file paths), constraints, anti-patterns
   - Match the structure of an existing skill file

2. Create `copilot/agents/{role-name}.agent.md`
   - `name:` must be lowercase and hyphenated (e.g. `java-engineer`)
   - Add a handoff back to `digital-team` with a consistent label
   - Reference the skill file with `#file:{{INSTALL_SKILLS_PATH}}/{role-name}/SKILL.md`

3. Update `copilot/agents/digital-team.agent.md`
   - Add a new phase handoff button in the correct sequence position
   - Update the phase detection table with the new output file path

4. Update `copilot/prompts/new-project-init.prompt.md`
   - Add the new role to the generated `workflow-config.md` template

5. Add `shared/roles/{role-name}.md`
   - Same content as `SKILL.md` but without the Copilot frontmatter block

6. Update `project-template/.ai/context/workflow-config.md`
   - Add the new role row to the role configuration table

7. Update both `README.md` and `README.zh-CN.md`
   - Add the new role to the Roles table

### Coding standards

Changes to `.NET` or frontend coding standards should be consistent across three locations:

- `copilot/instructions/coding-standards-{lang}.instructions.md` (Copilot global)
- `project-template/.github/instructions/coding-standards-{lang}.instructions.md` (project override template)
- `shared/standards/coding-standards-{lang}.md` (platform-agnostic reference)

### install.ps1

The installer is a cross-platform PowerShell 7 script. All changes must work on Windows, macOS, and Linux. Test with `-DryRun` first, then run for real, then verify installed files contain correct paths (no `{{INSTALL_SKILLS_PATH}}` placeholders remaining after installation).

## Commit messages

Use the imperative form. Be specific.

```
add java-engineer role and SKILL.md
fix dotnet-engineer handoff agent reference
update architect constraint on DB-level FK policy
```

## License

By contributing, you agree your changes will be released under the project's MIT license.

## Summary

<!-- One sentence describing what this PR changes and why -->

## Type of Change

- [ ] Bug fix — agent behavior not matching the role spec
- [ ] Role improvement — changes to an existing SKILL.md or agent.md
- [ ] New role — adds a new specialist agent
- [ ] Coding standard update
- [ ] Installer / tooling change
- [ ] Documentation only
- [ ] zh-CN locale update

## Files Changed

- [ ] `copilot/skills/` — SKILL.md updated
- [ ] `copilot/agents/` — agent.md updated
- [ ] `shared/roles/` — platform-agnostic role definition updated
- [ ] `zh-CN/` — Chinese locale counterparts updated
- [ ] `README.md` / `README.zh-CN.md` — documentation updated
- [ ] `install.ps1` / `uninstall.ps1` — installer updated

## Testing

Describe how you verified the behavior change in Copilot Chat:

1. Role invoked: `@`
2. Input used:
3. Expected output:
4. Actual output:

## Checklist

- [ ] Changes are scoped to a single concern (one role / one issue per PR)
- [ ] Commit message uses imperative form
- [ ] No hardcoded paths — `{{INSTALL_SKILLS_PATH}}` placeholder used where needed
- [ ] If a new role was added: `digital-team.agent.md` updated with new handoff
- [ ] Chinese locale (`zh-CN/`) is in sync with English changes

# Frontend Coding Standards

> Platform-agnostic version (no Copilot frontmatter). For use with Claude Code, Codex, and documentation reference.
> Copilot version: `copilot/instructions/coding-standards-frontend.instructions.md`

---

## Vue 3 / TypeScript

- Prefer `<script setup lang="ts">`
- No `any` type; use `unknown` + type guards for uncertain types
- Props / Emits must use TypeScript generic syntax: `defineProps<{...}>()`
- Component naming: PascalCase and multi-word (prevents conflict with native HTML tags)
  - ✅ `UserProfileCard`, `OrderStatusBadge`
  - ❌ `Card`, `Badge`, `List`

## Style Standards

- Use CSS Variables; no magic numbers
  - ✅ `padding: var(--spacing-4)`
  - ❌ `padding: 16px`
- Prefer `<style scoped>`; global styles defined only in `styles/` directory
- Avoid `!important`; if required, add a comment explaining why

## List Rendering

- `:key` must be a unique business ID — using index is not allowed
  - ✅ `:key="item.id"`
  - ❌ `:key="index"`

## Responsive Layout

- Prefer CSS Flexbox/Grid solutions; avoid JS DOM size manipulation
- Components do not query `window.innerWidth` directly; use a shared responsive composable

## State Management (Pinia)

- Store naming: `use{Domain}Store` (e.g. `useUserStore`)
- Handle API errors uniformly in actions and update error state
- Never mutate store state directly in components (use actions)

## Component File Structure

```
<script setup lang="ts">
// 1. imports
// 2. props / emits
// 3. composables
// 4. state (ref / reactive)
// 5. computed
// 6. methods
// 7. lifecycle hooks
</script>

<template>
</template>

<style scoped lang="scss">
</style>
```

## Prohibited

- No `console.log` in commits (blocked by ESLint `no-console` rule)
- No direct DOM manipulation (use Vue reactivity instead)
- No complex expressions in `<template>` (extract as computed properties)
---
description: "Use when writing, reviewing or modifying frontend code including Vue components, TypeScript, CSS/SCSS. Covers component structure, state management, naming conventions, and style standards."
applyTo: ["**/*.vue", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css"]
---

# Frontend Coding Standards (Global)

> Applies to all frontend projects. Project-specific overrides are in each project's `.github/instructions/coding-standards-frontend.instructions.md`.
> This file is continuously refined through practice — common Code Review findings are appended here.

## Naming Conventions

```
Vue component files   PascalCase              UserList.vue, OrderDetail.vue
Page components       under views/, same      UserListView.vue
Composable functions  use prefix              useUserStore, useFormValidation
Pinia Store           use + domain + Store    useOrderStore
CSS class names       kebab-case              .user-card, .order-status-badge
Event names           kebab-case (emit)       update:modelValue, item-click
```

- Component names must be multi-word (to avoid conflicts with HTML tags): `UserCard`, not `Card`
- Props use camelCase; in templates use kebab-case

## Component Structure Standards

```vue
<script setup lang="ts">
// 1. Type imports
// 2. Component / utility imports
// 3. Props / Emits definitions
// 4. Store / Composable
// 5. Reactive state
// 6. Computed properties
// 7. Lifecycle hooks
// 8. Methods
</script>

<template>
  <!-- Single root element, or Fragment (Vue 3) -->
</template>

<style scoped>
/* Current component styles only — prefer CSS Variables */
</style>
```

- `<script setup>` preferred over Options API
- Props must define types; required props must not have default values
- Avoid complex logic in templates — extract to computed or methods

## State Management (Pinia)

```typescript
// ✅ Recommended: Composition Store style
export const useUserStore = defineStore('user', () => {
  const list = ref<User[]>([])
  const fetchList = async () => { ... }
  return { list, fetchList }
})

// ❌ Avoid: fetching data directly in components, bypassing the Store
```

- Globally shared state goes in Store — do not use props drilling beyond 2 levels
- Async operations go in Store actions — not in component methods
- Store does not handle UI logic (toasts, modals, etc.)

## Typing Standards (TypeScript)

```typescript
// ✅ Explicit types
const userId: number = 1
function getUser(id: number): Promise<User | null> { ... }

// ❌ Forbidden
const data: any = {}
// @ts-ignore (only use when absolutely unavoidable)
```

- Forbidden: `any` (except when interfacing with third-party libraries with no alternative)
- API response data must define interface types — place in `types/` directory
- Reusable types use `interface`, utility types use `type`

## Style Standards

```scss
// ✅ Use CSS Variables
.user-card {
  color: var(--color-text-primary);
  padding: var(--spacing-md);
}

// ❌ Avoid magic numbers
.user-card {
  color: #333;
  padding: 16px;
}
```

- Colours, spacing, and typography use CSS Variables / Design Tokens
- Responsive breakpoints use the project's unified mixins — do not hardcode `@media (max-width: 768px)`
- `scoped` styles preferred; global styles require a comment explaining the reason

## Performance Constraints

- Lists must use `:key` (unique ID — not index)
- Large lists (> 100 items) must use virtual scrolling
- Images use lazy loading (`loading="lazy"` or a component wrapper)
- Forbidden: calling side-effect methods directly in templates (executes on every render)

## Pending Additions (Global General Rules)

> Append cross-project Code Review findings here. Format:
> `- {rule description} (discovered on {date}/{version})`
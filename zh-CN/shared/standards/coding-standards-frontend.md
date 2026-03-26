# 前端编码规范

> 平台无关版本（无 Copilot frontmatter）。供 Claude Code、Codex 和文档参考使用。
> Copilot 版本见：`copilot/instructions/coding-standards-frontend.instructions.md`

---

## Vue 3 / TypeScript

- 优先使用 `<script setup lang="ts">`
- 禁止 `any` 类型；使用 `unknown` + 类型守卫处理不确定类型
- Props / Emits 必须使用 TypeScript 泛型式定义：`defineProps<{...}>()`
- 组件命名：PascalCase 且必须多单词（防止与原生 HTML 标签冲突）
  - ✅ `UserProfileCard`, `OrderStatusBadge`
  - ❌ `Card`, `Badge`, `List`

## 样式规范

- 使用 CSS Variables，禁止 Magic Number
  - ✅ `padding: var(--spacing-4)`
  - ❌ `padding: 16px`
- `<style scoped>` 优先；全局样式仅在 `styles/` 目录定义
- 避免 `!important`；如必须使用，需注释原因

## 列表渲染

- `:key` 必须是唯一业务 ID，禁止使用 index
  - ✅ `:key="item.id"`
  - ❌ `:key="index"`

## 响应式

- 优先 CSS Flexbox/Grid 方案，避免 JS 操控 DOM 尺寸
- 组件内不直接查询 `window.innerWidth`；使用统一的响应式 composable

## 状态管理（Pinia）

- Store 命名：`use{Domain}Store`（如 `useUserStore`）
- Action 中统一处理 API 错误并更新 error state
- 禁止在组件中直接 mutate store state（通过 action）

## 组件文件结构

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

## 禁止项

- 禁止 `console.log` 进入提交（用 ESLint `no-console` 规则阻断）
- 禁止直接操作 DOM（使用 Vue 响应式机制）
- 禁止在 `<template>` 中使用复杂表达式（提取为 computed）

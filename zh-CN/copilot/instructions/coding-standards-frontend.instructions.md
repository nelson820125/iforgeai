---
description: "Use when writing, reviewing or modifying frontend code including Vue components, TypeScript, CSS/SCSS. Covers component structure, state management, naming conventions, and style standards."
applyTo: ["**/*.vue", "**/*.ts", "**/*.tsx", "**/*.scss", "**/*.css"]
---

# 前端编码规范（全局）

> 适用于所有前端项目。项目特有约束在各项目的 `.github/instructions/coding-standards-frontend.instructions.md` 中覆盖。
> 本文件随实践持续完善，每次 Code Review 发现的通用问题在此追加。

## 命名规范

```
Vue 组件文件    PascalCase              UserList.vue, OrderDetail.vue
页面组件        views/ 下，同上         UserListView.vue
组合式函数      use 前缀                useUserStore, useFormValidation
Pinia Store     use + 业务名 + Store    useOrderStore
CSS 类名        kebab-case              .user-card, .order-status-badge
事件名          kebab-case（emit）      update:modelValue, item-click
```

- 组件名必须是多词（避免与 HTML 标签冲突）：`UserCard`，不是 `Card`
- Props 使用 camelCase，模板中使用 kebab-case

## 组件结构规范

```vue
<script setup lang="ts">
// 1. 类型导入
// 2. 组件/工具导入
// 3. Props / Emits 定义
// 4. Store / Composable
// 5. 响应式状态
// 6. 计算属性
// 7. 生命周期
// 8. 方法
</script>

<template>
  <!-- 单一根元素，或 Fragment（Vue 3） -->
</template>

<style scoped>
/* 仅当前组件样式，优先使用 CSS Variables */
</style>
```

- `<script setup>` 优先于 Options API
- Props 必须定义类型，必填项不设默认值
- 避免在模板中写复杂逻辑，提取为 computed 或方法

## 状态管理（Pinia）

```typescript
// ✅ 推荐：Composition Store 风格
export const useUserStore = defineStore('user', () => {
  const list = ref<User[]>([])
  const fetchList = async () => { ... }
  return { list, fetchList }
})

// ❌ 避免：在组件中直接 fetch，绕过 Store
```

- 全局共享状态放 Store，不用组件间 props drilling 超过 2 层
- 异步操作放 Store actions，不放组件 methods
- Store 中不处理 UI 逻辑（toast、弹窗等）

## 类型规范（TypeScript）

```typescript
// ✅ 明确类型
const userId: number = 1
function getUser(id: number): Promise<User | null> { ... }

// ❌ 禁止
const data: any = {}
// @ts-ignore（非必要不使用）
```

- 禁止 `any`（除非对接第三方库且无法规避）
- API 响应数据必须定义接口类型，放 `types/` 目录
- 复用类型用 `interface`，工具类型用 `type`

## 样式规范

```scss
// ✅ 使用 CSS Variables
.user-card {
  color: var(--color-text-primary);
  padding: var(--spacing-md);
}

// ❌ 避免魔法数字
.user-card {
  color: #333;
  padding: 16px;
}
```

- 颜色、间距、字号使用 CSS Variables / Design Token
- 响应式断点使用项目统一定义的 mixin，不硬编码 `@media (max-width: 768px)`
- `scoped` 样式优先，全局样式需注释说明用途

## 性能约束

- 列表必须使用 `:key`（唯一 ID，不用 index）
- 大列表（> 100 项）必须使用虚拟滚动
- 图片使用懒加载（`loading="lazy"` 或组件封装）
- 禁止在模板中直接调用有副作用的方法（每次渲染都执行）

## 待补充（全局通用规则）

> 追加跨项目均适用的 Code Review 发现，格式：
> `- {规则描述} （发现于 {日期}/{版本}）`

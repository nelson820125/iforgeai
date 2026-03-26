---
description: "Use when writing, reviewing or modifying C# / .NET backend code. Project-specific overrides for .NET standards."
applyTo: "**/*.cs"
---

# .NET / C# 编码规范（项目覆盖）

> 本文件覆盖全局规范中需要针对本项目调整的部分。
> 全局规范见用户级 `coding-standards-dotnet.instructions.md`。

## 项目分层说明

> 在此描述本项目的分层结构，供所有工程师参考。
>
> 示例：
> ```
> Controllers/    → HTTP 层，仅处理路由和参数绑定
> Services/       → 业务逻辑层
> Repositories/   → 数据访问层（EF Core / Dapper）
> Domain/         → 领域实体和值对象
> ```

（待填写）

## 错误处理约定

> 说明本项目的错误处理策略，例如：Result Pattern / 全局异常中间件 / 自定义异常类型。

（待填写）

## 项目特有规则

> 追加本项目特有的编码约定，格式：
> `- {规则描述}`

（待填写）

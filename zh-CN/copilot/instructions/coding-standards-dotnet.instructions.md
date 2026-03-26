---
description: "Use when writing, reviewing or modifying C# / .NET backend code. Covers naming conventions, async patterns, error handling, dependency injection, and project layering standards."
applyTo: "**/*.cs"
---

# .NET / C# 编码规范（全局）

> 适用于所有 .NET 项目。项目特有约束在各项目的 `.github/instructions/coding-standards-dotnet.instructions.md` 中覆盖。
> 本文件随实践持续完善，每次 Code Review 发现的通用问题在此追加。

## 命名规范

```
类名              PascalCase        UserService, OrderRepository
接口              I + PascalCase    IUserService, IOrderRepository
方法              PascalCase        GetUserById, CreateOrderAsync
私有字段          _camelCase        _userRepository, _logger
参数 / 局部变量   camelCase         userId, orderItem
常量              UPPER_SNAKE       MAX_RETRY_COUNT（或 PascalCase，按项目统一）
```

- 异步方法必须以 `Async` 结尾
- 布尔变量/属性用 `is`/`has`/`can` 前缀：`isActive`、`hasPermission`

## 异步规范

```csharp
// ✅ 正确
public async Task<User?> GetUserAsync(int id, CancellationToken ct = default)
    => await _repository.FindAsync(id, ct);

// ❌ 禁止
public User GetUser(int id) => _repository.FindAsync(id).Result;
```

- 所有 I/O 操作必须 async/await
- 传递 `CancellationToken`，不吞掉取消信号
- 禁止 `.Result`、`.Wait()`、`Thread.Sleep()`

## 错误处理

```csharp
// ✅ 推荐：明确 catch 类型
try { ... }
catch (DbException ex) { _logger.LogError(ex, "..."); throw; }

// ❌ 禁止：吞掉异常
catch (Exception) { }
```

- 不吞掉异常（至少 Log）
- 不 catch `Exception` 然后什么都不做
- 业务异常与系统异常分类处理

## 依赖注入

```csharp
// ✅ 构造函数注入（Primary Constructor，C# 12+）
public class UserService(IUserRepository repo, ILogger<UserService> logger) : IUserService
{
    public async Task<User?> GetAsync(int id) => await repo.FindAsync(id);
}

// ❌ 禁止：直接 new 依赖
var repo = new UserRepository();
```

- 所有外部依赖通过构造函数注入
- 禁止在业务代码中直接 `new` 基础设施类（DbContext、HttpClient 等）

## 分层约束（通用）

参考当前项目 `.github/copilot-instructions.md` 中的分层说明。通用规则：

- Controller 只负责 HTTP 协议层（参数绑定、返回码）
- Service 负责业务逻辑，不直接操作 DbContext
- Repository 负责数据访问，不包含业务逻辑
- 禁止跨层调用（Controller 直接调 Repository）

## XML 文档注释

```csharp
/// <summary>
/// 根据 ID 获取用户信息，不存在时返回 null。
/// </summary>
/// <param name="id">用户主键</param>
/// <param name="ct">取消令牌</param>
/// <returns>用户实体，不存在返回 null</returns>
public async Task<User?> GetUserAsync(int id, CancellationToken ct = default)
```

- 所有 `public` 成员必须有 XML 注释（中文）
- `internal` 和 `private` 视复杂度添加，简单的不强制

## 待补充（全局通用规则）

> 追加跨项目均适用的 Code Review 发现，格式：
> `- {规则描述} （发现于 {日期}/{版本}）`

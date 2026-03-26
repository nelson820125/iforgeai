# .NET / C# 编码规范

> 平台无关版本（无 Copilot frontmatter）。供 Claude Code、Codex 和文档参考使用。
> Copilot 版本见：`copilot/instructions/coding-standards-dotnet.instructions.md`

---

## 现代 C# 语法

- 优先使用 record、primary constructor、pattern matching、collection expressions
- 使用 `is null` / `is not null`；禁止 `== null` / `!= null`
- 字符串格式化：插值 `$"..."` 或常量；禁止 `string.Format` 和 `+` 拼接
- 避免 Magic String：使用 const 或 enum

## 异步规范

- 所有 I/O 操作必须 `async/await`
- **禁止 `.Result`、`.Wait()`**
- 异步方法名使用 `Async` 后缀：`GetUserAsync`
- `CancellationToken` 在 Controller → Service → Repository 全链路透传

## 命名规范

| 场景                       | 规则         | 示例                             |
| -------------------------- | ------------ | -------------------------------- |
| Class / Interface / Record | PascalCase   | `UserService`, `IUserRepository` |
| Method / Property          | PascalCase   | `GetById()`, `CreatedAt`         |
| 局部变量 / 参数            | camelCase    | `userId`, `cancellationToken`    |
| 私有字段                   | `_camelCase` | `_userRepository`                |
| 常量                       | PascalCase   | `MaxRetry`                       |
| 泛型参数                   | T 前缀       | `TEntity`, `TResult`             |

## 空安全

- 启用 Nullable Reference Types（`<Nullable>enable</Nullable>`）
- 使用 `?.`、`??`、`??=` 操作符
- 方法参数：引用类型使用 `ArgumentNullException.ThrowIfNull(param)`

## 依赖注入

- 所有依赖通过构造函数注入
- 禁止 `new` 直接实例化服务类
- 遵循 SOLID：单一职责，依赖抽象

## 注释规范

所有 `public` 成员必须包含中文 XML 注释：

```csharp
/// <summary>根据 ID 获取用户信息</summary>
/// <param name="id">用户主键</param>
/// <param name="cancellationToken">取消令牌</param>
/// <returns>用户实体，不存在时返回 null</returns>
public async Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
```

## 异常处理

- 使用具体异常类型，不捕获 `Exception` 基类（除顶层中间件）
- 业务异常使用自定义异常类（如 `BusinessException`）
- 禁止空 catch 块
- 日志记录前，保留原始异常引用

## 代码完整性

**产出代码必须完整可运行，禁止任何省略注释：**

- `// existing code...`
- `// 省略未变更部分`
- `// ...`（用于表示代码省略时）

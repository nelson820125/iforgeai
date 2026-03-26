# .NET / C# Coding Standards

> Platform-agnostic version (no Copilot frontmatter). For use with Claude Code, Codex, and documentation reference.
> Copilot version: `copilot/instructions/coding-standards-dotnet.instructions.md`

---

## Modern C# Syntax

- Prefer record, primary constructor, pattern matching, collection expressions
- Use `is null` / `is not null`; never `== null` / `!= null`
- String formatting: interpolation `$"..."` or constants; never `string.Format` or `+` concatenation
- No magic strings: use const or enum

## Async Standards

- All I/O operations: `async/await`
- **Never `.Result` or `.Wait()`**
- Async methods use `Async` suffix: `GetUserAsync`
- `CancellationToken` passed through the full Controller → Service → Repository chain

## Naming Conventions

| Context                    | Rule         | Example                          |
| -------------------------- | ------------ | -------------------------------- |
| Class / Interface / Record | PascalCase   | `UserService`, `IUserRepository` |
| Method / Property          | PascalCase   | `GetById()`, `CreatedAt`         |
| Local variable / Parameter | camelCase    | `userId`, `cancellationToken`    |
| Private field              | `_camelCase` | `_userRepository`                |
| Constant                   | PascalCase   | `MaxRetry`                       |
| Generic type parameter     | T prefix     | `TEntity`, `TResult`             |

## Null Safety

- Enable Nullable Reference Types (`<Nullable>enable</Nullable>`)
- Use `?.`, `??`, `??=` operators
- Method parameters: use `ArgumentNullException.ThrowIfNull(param)` for reference types

## Dependency Injection

- All dependencies injected via constructor
- Never `new` a service class directly
- Follow SOLID: single responsibility, depend on abstractions

## Comment Standards

All `public` members must have XML doc comments (language follows `output_language` in workflow-config):

```csharp
/// <summary>Get user information by ID</summary>
/// <param name="id">User primary key</param>
/// <param name="cancellationToken">Cancellation token</param>
/// <returns>User entity, or null if not found</returns>
public async Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
```

## Exception Handling

- Use specific exception types; do not catch `Exception` base class (except top-level middleware)
- Business exceptions use custom exception classes (e.g. `BusinessException`)
- No empty catch blocks
- Preserve original exception reference before logging

## Code Completeness

**All code output must be complete and runnable — no omission comments:**

- `// existing code...`
- `// omitted unchanged parts`
- `// ...` (when used to indicate code omission)
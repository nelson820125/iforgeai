---
description: "Use when writing, reviewing or modifying C# / .NET backend code. Covers naming conventions, async patterns, error handling, dependency injection, and project layering standards."
applyTo: "**/*.cs"
---

# .NET / C# Coding Standards (Global)

> Applies to all .NET projects. Project-specific overrides are in each project's `.github/instructions/coding-standards-dotnet.instructions.md`.
> This file is continuously refined through practice — common Code Review findings are appended here.

## Naming Conventions

```
Class names          PascalCase        UserService, OrderRepository
Interfaces           I + PascalCase    IUserService, IOrderRepository
Methods              PascalCase        GetUserById, CreateOrderAsync
Private fields       _camelCase        _userRepository, _logger
Parameters / locals  camelCase         userId, orderItem
Constants            UPPER_SNAKE       MAX_RETRY_COUNT (or PascalCase, follow project convention)
```

- Async methods must end with `Async`
- Boolean variables/properties use `is`/`has`/`can` prefixes: `isActive`, `hasPermission`

## Async Rules

```csharp
// ✅ Correct
public async Task<User?> GetUserAsync(int id, CancellationToken ct = default)
    => await _repository.FindAsync(id, ct);

// ❌ Forbidden
public User GetUser(int id) => _repository.FindAsync(id).Result;
```

- All I/O operations must be async/await
- Pass `CancellationToken` — do not swallow cancellation signals
- Forbidden: `.Result`, `.Wait()`, `Thread.Sleep()`

## Error Handling

```csharp
// ✅ Recommended: catch specific exception types
try { ... }
catch (DbException ex) { _logger.LogError(ex, "..."); throw; }

// ❌ Forbidden: swallow exceptions
catch (Exception) { }
```

- Never swallow exceptions (at minimum, log them)
- Never catch `Exception` and do nothing
- Separate business exceptions from system exceptions

## Dependency Injection

```csharp
// ✅ Constructor injection (Primary Constructor, C# 12+)
public class UserService(IUserRepository repo, ILogger<UserService> logger) : IUserService
{
    public async Task<User?> GetAsync(int id) => await repo.FindAsync(id);
}

// ❌ Forbidden: directly instantiating dependencies
var repo = new UserRepository();
```

- All external dependencies must be injected through constructors
- Never directly `new` infrastructure classes in business code (DbContext, HttpClient, etc.)

## Layering Constraints (General)

Refer to the layering description in the current project's `.github/copilot-instructions.md`. General rules:

- Controller is responsible only for the HTTP protocol layer (parameter binding, response codes)
- Service is responsible for business logic — does not directly operate DbContext
- Repository is responsible for data access — contains no business logic
- Cross-layer calls are forbidden (Controller calling Repository directly)

## XML Documentation Comments

```csharp
/// <summary>
/// Retrieves a user by ID. Returns null if not found.
/// </summary>
/// <param name="id">User primary key</param>
/// <param name="ct">Cancellation token</param>
/// <returns>User entity, or null if not found</returns>
public async Task<User?> GetUserAsync(int id, CancellationToken ct = default)
```

- All `public` members must have XML documentation comments
- `internal` and `private` members: add comments based on complexity — not required for simple members

## Pending Additions (Global General Rules)

> Append cross-project Code Review findings here. Format:
> `- {rule description} (discovered on {date}/{version})`
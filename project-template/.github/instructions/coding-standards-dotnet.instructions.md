---
description: "Use when writing, reviewing or modifying C# / .NET backend code. Project-specific overrides for .NET standards."
applyTo: "**/*.cs"
---

# .NET / C# Coding Standards (Project Overrides)

> This file overrides portions of the global standard that need project-specific adjustments.
> Global standard: user-level `coding-standards-dotnet.instructions.md`

## Project Layer Structure

> Describe this project's layer structure so all engineers share a common understanding.
>
> Example:
> ```
> Controllers/    -> HTTP layer - routing and parameter binding only
> Services/       -> Business logic layer
> Repositories/  -> Data access layer (EF Core / Dapper)
> Domain/         -> Domain entities and value objects
> ```

(fill in)

## Error Handling Convention

> Describe this project's error handling strategy, e.g.: Result Pattern / global exception middleware / custom exception types.

(fill in)

## Project-Specific Rules

> Append project-specific coding conventions below.
> Format: `- {rule description}`

(fill in)

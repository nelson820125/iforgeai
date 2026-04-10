---
description: "Use when writing, reviewing or modifying Python backend code. Covers naming conventions, type annotations, async patterns, error handling, docstrings, and FastAPI / SQLAlchemy / Pydantic idioms."
applyTo: "**/*.py"
---

# Python Coding Standards (Global)

> Applies to all Python projects. Follows **PEP 8**, **PEP 257**, **PEP 484**, and the Google Python Style Guide.
> FastAPI / Pydantic v2 / SQLAlchemy 2.x practices are included as the default async backend stack.
> Project-specific overrides are in each project's `.github/instructions/coding-standards-python.instructions.md`.

## Reference Standards

| Standard | Scope |
|---|---|
| [PEP 8](https://peps.python.org/pep-0008/) | Formatting, naming, whitespace |
| [PEP 257](https://peps.python.org/pep-0257/) | Docstring conventions |
| [PEP 484](https://peps.python.org/pep-0484/) | Type hints |
| [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html) | Docstring format, best practices |
| Ruff, mypy (strict) | Linting, type checking |

## Naming Conventions

```
Module / Package names       snake_case          user_service.py, order_repository.py
Functions / Methods          snake_case          get_user_by_id(), create_order_async()
Variables                    snake_case          user_id, order_item, is_active
Constants                    UPPER_SNAKE         MAX_RETRY_COUNT, DEFAULT_PAGE_SIZE
Classes                      PascalCase          UserService, OrderRepository
Pydantic models              PascalCase + suffix UserCreateRequest, UserResponse, OrderSchema
Private members              _single_underscore  _helper_method(), _cache
"Internal" / dunder          __dunder__          __init__, __repr__
Type aliases                 PascalCase          UserId = NewType("UserId", int)
```

- Boolean variables: `is_active`, `has_permission`, `can_edit` — use `is_`/`has_`/`can_` prefixes
- Avoid single-letter names except loop indices (`i`, `j`) and very short lambdas
- Test functions: `test_<thing>_<condition>_<expected>` — e.g. `test_get_user_returns_404_when_not_found`

## Type Annotations

```python
# ✅ Annotate all function signatures (PEP 484)
from __future__ import annotations
from typing import Optional

def get_user_by_id(user_id: int) -> Optional[User]:
    ...

# ✅ Pydantic models for external data (request/response bodies)
from pydantic import BaseModel, Field

class UserCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., pattern=r"^[^@]+@[^@]+\.[^@]+$")

# ✅ TypedDict for structured dicts where Pydantic is overkill
from typing import TypedDict

class PaginationParams(TypedDict):
    page: int
    page_size: int

# ❌ Forbidden: bare `Any` without justification
from typing import Any
def process(data: Any) -> Any: ...  # suppresses all type checking
```

- Use `from __future__ import annotations` at the top of every module
- Prefer `list[int]` over `List[int]`, `dict[str, int]` over `Dict[str, int]` (Python 3.10+)
- Use `X | None` over `Optional[X]` in Python 3.10+ code
- Run `mypy --strict` in CI — do not commit files with mypy errors

## Docstrings (Google Style)

```python
# ✅ Google-style docstring
def create_user(name: str, email: str, role: UserRole) -> User:
    """Create and persist a new user.

    Args:
        name: The display name of the user. Must be non-empty.
        email: A valid email address. Must be unique in the database.
        role: Initial role assigned to the new user.

    Returns:
        The newly created User instance with its database ID populated.

    Raises:
        DuplicateEmailError: If a user with this email already exists.
        ValidationError: If any argument fails validation.
    """
    ...

# ❌ Forbidden: vague or missing docstrings on public functions/classes
def create_user(name, email, role):
    """Create user."""
    ...
```

- All `public` functions, classes, and modules must have Google-style docstrings
- One-liner is fine for obvious utilities
- Do not repeat what the type annotations already say — add semantic context
- Module-level docstring: brief purpose description at the top of the file

## Import Ordering

```python
# ✅ Group imports: stdlib → third-party → internal (blank line between groups)
from __future__ import annotations

import asyncio
import os
from datetime import datetime
from typing import Optional

import httpx
import uvicorn
from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.user import User
from app.repositories.user_repository import UserRepository
```

- Use `ruff check --select I` or `isort` in CI for import ordering
- No wildcard imports (`from module import *`)
- Group third-party vs. first-party imports clearly; use `# noqa: E402` sparingly and with justification

## Indentation and Formatting

```python
# ✅ 4-space indent, 88-character line limit (Ruff/Black default)
async def get_order_detail(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> OrderDetailResponse:
    order = await order_repo.get_by_id(db, order_id)
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return OrderDetailResponse.model_validate(order)
```

- Indentation: **4 spaces** (no tabs)
- Line length: **88 characters** (Black/Ruff default); docstrings and comments max **80 characters**
- String quotes: **double quotes** (`"`) for all strings, consistent and enforced by Ruff
- Trailing commas in multi-line expressions
- Two blank lines before and after top-level function/class definitions
- One blank line between methods inside a class

## Async Rules

```python
# ✅ async functions for I/O-bound operations
async def get_user(user_id: int, db: AsyncSession) -> User | None:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# ✅ asyncio.gather for parallel independent tasks
async def get_dashboard(user_id: int) -> DashboardData:
    user, orders, notifications = await asyncio.gather(
        user_repo.get(user_id),
        order_repo.list_by_user(user_id),
        notification_repo.count_unread(user_id),
    )
    return DashboardData(user=user, orders=orders, unread=notifications)

# ❌ Forbidden: sync ORM calls inside async functions
async def bad_example(db: AsyncSession) -> None:
    users = db.query(User).all()  # blocks the event loop

# ❌ Forbidden: blocking sleep
import time
time.sleep(1)  # use: await asyncio.sleep(1)
```

- All I/O (database, HTTP, file) must use `async`/`await` — no blocking calls in async context
- Use `asyncio.gather()` for concurrent independent awaits; avoid sequential `await` on unrelated tasks
- Background tasks: use `fastapi.BackgroundTasks` for lightweight tasks; Celery for heavyweight/distributed

## Error Handling

```python
# ✅ Domain-specific exceptions
class UserNotFoundError(Exception):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"User not found: id={user_id}")
        self.user_id = user_id

# ✅ FastAPI exception handler
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(UserNotFoundError)
async def user_not_found_handler(request: Request, exc: UserNotFoundError) -> JSONResponse:
    return JSONResponse(status_code=404, content={"detail": str(exc)})

# ✅ Context manager for resources
async with httpx.AsyncClient() as client:
    response = await client.get(url)

# ❌ Forbidden: bare except / swallowing exceptions
try:
    do_something()
except:  # catches SystemExit, KeyboardInterrupt too
    pass

# ❌ Forbidden: catching Exception without re-raising or very specific justification
except Exception:
    logger.error("Something went wrong")  # lost context, no re-raise
```

- Define custom exceptions in `app/exceptions/` — never raise bare `Exception`
- Register exception handlers in `app/core/exception_handlers.py`; keep handlers thin
- `contextlib.suppress()` only for intentionally suppressed errors
- Never use bare `except:` — always specify the exception type

## Logging

```python
# ✅ structlog or standard logging with structured context
import logging

logger = logging.getLogger(__name__)

async def process_payment(order_id: int) -> None:
    logger.info("Processing payment", extra={"order_id": order_id})
    try:
        await payment_gateway.charge(order_id)
    except PaymentError as exc:
        logger.error(
            "Payment failed",
            extra={"order_id": order_id, "reason": str(exc)},
            exc_info=True,
        )
        raise

# ❌ Forbidden
print(f"Processing payment for order {order_id}")
```

- Get logger per module: `logger = logging.getLogger(__name__)`
- Prefer structured logging (JSON output) in production — configure via `python-json-logger` or `structlog`
- Include business context (`order_id`, `user_id`, `request_id`) in every log message
- `exc_info=True` on `logger.error`/`logger.critical` to capture full tracebacks

## FastAPI Patterns

```python
# ✅ Router-based organisation
# app/routers/users.py
router = APIRouter(prefix="/users", tags=["users"])

@router.get("/{user_id}", response_model=UserResponse, status_code=200)
async def get_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> UserResponse:
    user = await user_service.get_or_raise(db, user_id)
    return UserResponse.model_validate(user)

# ✅ Reusable Depends with Annotated
from typing import Annotated
CurrentUser = Annotated[User, Depends(get_current_user)]
DbSession = Annotated[AsyncSession, Depends(get_db)]

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    request: UserCreateRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> UserResponse:
    ...
```

- Always declare `response_model` — never return raw ORM objects from endpoints
- Group endpoints in `APIRouter` — no routes directly on `app`
- Use `status_code` explicitly on all route decorators
- OpenAPI metadata: use `summary=`, `description=`, `responses=` parameters on routes
- Pydantic handles input validation — no manual field checks at the router layer

## Pydantic v2 Patterns

```python
# ✅ Pydantic v2 style
from pydantic import BaseModel, Field, model_validator, field_validator
from pydantic import ConfigDict

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str
    created_at: datetime

# ✅ model_validate (v2) replaces from_orm (v1)
user_response = UserResponse.model_validate(user_orm_object)

# ✅ model_dump with exclude
payload = request.model_dump(exclude_unset=True)

# ❌ Deprecated Pydantic v1 patterns
class Config:
    orm_mode = True  # use model_config instead
UserResponse.from_orm(obj)  # use model_validate instead
```

- Request and response schemas must be separate models — never shared
- Use `Field(description=...)` on all public model fields (auto-documents the OpenAPI schema)
- `model_config = ConfigDict(from_attributes=True)` for models that map from ORM objects

## SQLAlchemy 2.x (Async)

```python
# ✅ Async ORM style
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

async def get_users_by_role(db: AsyncSession, role: str) -> list[User]:
    result = await db.execute(
        select(User)
        .where(User.role == role, User.is_deleted == False)
        .order_by(User.created_at.desc())
    )
    return list(result.scalars().all())

# ✅ Explicit transaction boundary
async def transfer_credits(db: AsyncSession, from_id: int, to_id: int, amount: int) -> None:
    async with db.begin():
        await db.execute(update(User).where(User.id == from_id).values(credits=User.credits - amount))
        await db.execute(update(User).where(User.id == to_id).values(credits=User.credits + amount))

# ❌ Forbidden: legacy 1.x query style
db.query(User).filter(User.id == user_id).first()
```

- Use `select()` / `update()` / `delete()` constructs (SQLAlchemy 2.x style) — not `session.query()`
- Declare `async_sessionmaker` in `app/database.py`; inject via FastAPI `Depends()`
- One session per request — never store session in a module-level variable
- Alembic for all schema migrations; no raw `CREATE TABLE` / `ALTER TABLE` in application code

## Testing

```python
# ✅ pytest + pytest-asyncio
import pytest
from httpx import AsyncClient, ASGITransport

@pytest.mark.asyncio
async def test_create_user_returns_201() -> None:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/users/", json={"name": "Alice", "email": "alice@example.com"})
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Alice"

# ✅ Fixtures in conftest.py
@pytest.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(test_engine) as session:
        yield session
```

- Test naming: `test_<function>_<condition>_<expected_outcome>`
- Integration tests: use `httpx.AsyncClient` + `ASGITransport` — no `TestClient` (sync)
- Database: use a dedicated test database or SQLite in-memory for unit tests; Testcontainers (PostgreSQL) for integration
- All I/O tests must be `async` — mark with `@pytest.mark.asyncio`
- Minimum coverage: 80% statement coverage on the service layer

## Module Structure

```
app/
├── main.py              # FastAPI app factory (create_app()), lifespan events
├── core/
│   ├── config.py        # Pydantic Settings (environment variables)
│   ├── security.py      # JWT / password utilities
│   └── exception_handlers.py
├── routers/             # APIRouter per resource
├── services/            # Business logic; no direct ORM queries
├── repositories/        # Data access; no business logic
├── models/              # SQLAlchemy ORM models
├── schemas/             # Pydantic request / response models
├── tasks/               # Celery tasks
└── tests/
    ├── conftest.py
    ├── unit/
    └── integration/
```

- No circular imports — avoid importing from `app.main` in sub-modules
- No global mutable state — use `app.state` or lifespan context for shared resources
- Configuration via `pydantic-settings` (`BaseSettings`); never `os.getenv()` scattered in business code

## Pending Additions (Global General Rules)

> Append cross-project Code Review findings here. Format:
> `- {rule description} (discovered on {date}/{version})`

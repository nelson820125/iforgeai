---
description: "编写、审查或修改 Python 后端代码时适用。涵盖命名规范、类型注解、异步模式、错误处理、文档字符串，以及 FastAPI / SQLAlchemy / Pydantic 惯用法。"
applyTo: "**/*.py"
---

# Python 编码规范（全局）

> 适用于所有 Python 项目。遵循 **PEP 8**、**PEP 257**、**PEP 484** 及 Google Python Style Guide。
> FastAPI / Pydantic v2 / SQLAlchemy 2.x 作为默认异步后端技术栈。
> 项目级覆盖规则请放在各项目的 `.github/instructions/coding-standards-python.instructions.md` 中。

## 参考规范

| 规范 | 范围 |
|---|---|
| [PEP 8](https://peps.python.org/pep-0008/) | 格式、命名、空白 |
| [PEP 257](https://peps.python.org/pep-0257/) | 文档字符串规范 |
| [PEP 484](https://peps.python.org/pep-0484/) | 类型注解 |
| [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html) | 文档字符串格式、最佳实践 |
| Ruff、mypy（strict 模式） | 静态检查、类型检查 |

## 命名规范

```
模块 / 包名          snake_case          user_service.py, order_repository.py
函数 / 方法          snake_case          get_user_by_id(), create_order_async()
变量                 snake_case          user_id, order_item, is_active
常量                 UPPER_SNAKE         MAX_RETRY_COUNT, DEFAULT_PAGE_SIZE
类                   PascalCase          UserService, OrderRepository
Pydantic 模型        PascalCase + 后缀   UserCreateRequest, UserResponse, OrderSchema
私有成员             _单下划线           _helper_method(), _cache
魔术方法             __双下划线__        __init__, __repr__
类型别名             PascalCase          UserId = NewType("UserId", int)
```

- 布尔变量：`is_active`、`has_permission`、`can_edit` — 使用 `is_`/`has_`/`can_` 前缀
- 除循环索引（`i`、`j`）和极短 lambda 外，避免使用单字母名称
- 测试函数：`test_<对象>_<条件>_<预期结果>` — 例如 `test_get_user_returns_404_when_not_found`

## 类型注解

```python
# ✅ 所有函数签名都必须加注解（PEP 484）
from __future__ import annotations
from typing import Optional

def get_user_by_id(user_id: int) -> Optional[User]:
    ...

# ✅ 外部数据使用 Pydantic 模型（请求/响应体）
from pydantic import BaseModel, Field

class UserCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str = Field(..., pattern=r"^[^@]+@[^@]+\.[^@]+$")

# ✅ 结构化字典在 Pydantic 过重时使用 TypedDict
from typing import TypedDict

class PaginationParams(TypedDict):
    page: int
    page_size: int

# ❌ 禁止：无正当理由使用裸 Any
from typing import Any
def process(data: Any) -> Any: ...  # 禁用所有类型检查
```

- 每个模块顶部使用 `from __future__ import annotations`
- Python 3.10+ 优先用 `list[int]` 替代 `List[int]`，`X | None` 替代 `Optional[X]`
- CI 中运行 `mypy --strict` — 禁止提交有 mypy 错误的文件

## 文档字符串（Google 风格）

```python
# ✅ Google 风格文档字符串
def create_user(name: str, email: str, role: UserRole) -> User:
    """创建并持久化一个新用户。

    Args:
        name: 用户的显示名称，不能为空。
        email: 有效的电子邮件地址，在数据库中必须唯一。
        role: 分配给新用户的初始角色。

    Returns:
        包含数据库 ID 的新建 User 实例。

    Raises:
        DuplicateEmailError: 若该邮件地址已存在。
        ValidationError: 若任意参数校验失败。
    """
    ...

# ❌ 禁止：公共函数/类缺少文档字符串或描述含糊
def create_user(name, email, role):
    """创建用户。"""
    ...
```

- 所有 `public` 函数、类和模块必须有 Google 风格文档字符串
- 简单的函数可使用单行文档字符串
- 禁止重复类型注解已说明的内容 — 补充语义上下文
- 模块级文档字符串：在文件顶部简要描述模块用途

## Import 顺序

```python
# ✅ 分组导入：标准库 → 第三方 → 内部（组间空一行）
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

- CI 中使用 `ruff check --select I` 或 `isort` 自动排序
- 禁止通配符导入（`from module import *`）
- 清楚区分第三方和项目内部导入；`# noqa: E402` 使用要有充分理由

## 缩进与格式

```python
# ✅ 4 空格缩进，88 字符行宽限制（Ruff/Black 默认）
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

- 缩进：**4 个空格**（禁止 Tab）
- 行宽：**88 字符**（Ruff/Black 默认）；文档字符串和注释最大 **80 字符**
- 字符串引号：统一使用**双引号**（`"`），由 Ruff 強制执行
- 多行表达式末尾加逗号
- 顶层函数/类定义前后空两行；类内方法间空一行

## 异步规则

```python
# ✅ I/O 密集型操作使用 async 函数
async def get_user(user_id: int, db: AsyncSession) -> User | None:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# ✅ 并行独立任务使用 asyncio.gather
async def get_dashboard(user_id: int) -> DashboardData:
    user, orders, notifications = await asyncio.gather(
        user_repo.get(user_id),
        order_repo.list_by_user(user_id),
        notification_repo.count_unread(user_id),
    )
    return DashboardData(user=user, orders=orders, unread=notifications)

# ❌ 禁止：在 async 函数中调用同步 ORM
async def bad_example(db: AsyncSession) -> None:
    users = db.query(User).all()  # 阻塞事件循环

# ❌ 禁止：阻塞睡眠
import time
time.sleep(1)  # 应使用：await asyncio.sleep(1)
```

- 所有 I/O（数据库、HTTP、文件）必须使用 `async`/`await` — 禁止 async 上下文中同步阻塞
- 对相互独立的 await 使用 `asyncio.gather()`；避免对无关任务顺序 `await`
- 后台任务：轻量级任务用 `fastapi.BackgroundTasks`；重量级/分布式用 Celery

## 错误处理

```python
# ✅ 领域专属异常
class UserNotFoundError(Exception):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"User not found: id={user_id}")
        self.user_id = user_id

# ✅ FastAPI 异常处理器
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(UserNotFoundError)
async def user_not_found_handler(request: Request, exc: UserNotFoundError) -> JSONResponse:
    return JSONResponse(status_code=404, content={"detail": str(exc)})

# ✅ 资源使用上下文管理器
async with httpx.AsyncClient() as client:
    response = await client.get(url)

# ❌ 禁止：裸 except / 吞掉异常
try:
    do_something()
except:  # 连 SystemExit、KeyboardInterrupt 都会捕获
    pass
```

- 在 `app/exceptions/` 定义自定义异常 — 禁止直接 `raise Exception`
- 在 `app/core/exception_handlers.py` 注册异常处理器；保持处理器简洁
- `contextlib.suppress()` 仅用于有意忽略的错误
- 禁止裸 `except:` — 始终指定异常类型

## 日志

```python
# ✅ 使用标准 logging 结合结构化上下文
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

# ❌ 禁止
print(f"Processing payment for order {order_id}")
```

- 通过 `logger = logging.getLogger(__name__)` 获取模块级 logger
- 生产环境优先使用结构化日志（JSON 输出）— 通过 `python-json-logger` 或 `structlog` 配置
- 每条日志包含业务上下文（`order_id`、`user_id`、`request_id`）
- `logger.error`/`logger.critical` 加 `exc_info=True` 以捕获完整堆栈

## FastAPI 规范

```python
# ✅ 基于 Router 的组织方式
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

# ✅ 使用 Annotated 复用 Depends
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

- 必须显式声明 `response_model` — 禁止从端点直接返回 ORM 对象
- 路由使用 `APIRouter` 分组 — 禁止直接在 `app` 上注册路由
- 所有路由装饰器必须显式写明 `status_code`
- OpenAPI 元数据：在路由上使用 `summary=`、`description=`、`responses=` 参数
- Pydantic 负责输入校验 — Router 层无需手动字段检查

## Pydantic v2 规范

```python
# ✅ Pydantic v2 风格
from pydantic import BaseModel, Field, model_validator, field_validator
from pydantic import ConfigDict

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: str
    created_at: datetime

# ✅ model_validate（v2）替代 from_orm（v1）
user_response = UserResponse.model_validate(user_orm_object)

# ✅ 使用 exclude= 的 model_dump
payload = request.model_dump(exclude_unset=True)

# ❌ 已废弃的 Pydantic v1 写法
class Config:
    orm_mode = True  # 改用 model_config
UserResponse.from_orm(obj)  # 改用 model_validate
```

- 请求与响应必须使用独立模型
- 所有公开字段使用 `Field(description=...)` 注解（自动生成 OpenAPI Schema 文档）
- 映射 ORM 对象的模型使用 `model_config = ConfigDict(from_attributes=True)`

## SQLAlchemy 2.x（异步）

```python
# ✅ 异步 ORM 风格
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

async def get_users_by_role(db: AsyncSession, role: str) -> list[User]:
    result = await db.execute(
        select(User)
        .where(User.role == role, User.is_deleted == False)
        .order_by(User.created_at.desc())
    )
    return list(result.scalars().all())

# ✅ 显式事务边界
async def transfer_credits(db: AsyncSession, from_id: int, to_id: int, amount: int) -> None:
    async with db.begin():
        await db.execute(update(User).where(User.id == from_id).values(credits=User.credits - amount))
        await db.execute(update(User).where(User.id == to_id).values(credits=User.credits + amount))

# ❌ 禁止：使用 1.x 遗留 query 风格
db.query(User).filter(User.id == user_id).first()
```

- 使用 `select()`/`update()`/`delete()` 构造（SQLAlchemy 2.x 风格）— 禁止 `session.query()`
- 在 `app/database.py` 声明 `async_sessionmaker`；通过 FastAPI `Depends()` 注入
- 一个请求一个 session — 禁止将 session 存储在模块级变量中
- 所有表结构变更通过 Alembic 迁移 — 禁止在应用代码中写裸 SQL DDL

## 测试

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

# ✅ conftest.py 中声明 fixture
@pytest.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(test_engine) as session:
        yield session
```

- 测试命名：`test_<函数名>_<条件>_<预期结果>`
- 集成测试：使用 `httpx.AsyncClient` + `ASGITransport` — 禁止使用 `TestClient`（同步）
- 数据库：单元测试用 SQLite 内存库，集成测试用 Testcontainers（PostgreSQL）
- 所有 I/O 测试必须 `async` — 标注 `@pytest.mark.asyncio`
- 最低覆盖率：Service 层语句覆盖率 80%

## 模块结构

```
app/
├── main.py              # FastAPI 应用工厂（create_app()），lifespan 事件
├── core/
│   ├── config.py        # Pydantic Settings（环境变量）
│   ├── security.py      # JWT / 密码工具
│   └── exception_handlers.py
├── routers/             # 每个资源一个 APIRouter
├── services/            # 业务逻辑；禁止直接写 ORM 查询
├── repositories/        # 数据访问；无业务逻辑
├── models/              # SQLAlchemy ORM 模型
├── schemas/             # Pydantic 请求/响应模型
├── tasks/               # Celery 任务
└── tests/
    ├── conftest.py
    ├── unit/
    └── integration/
```

- 禁止循环导入 — 避免在子模块中导入 `app.main`
- 禁止全局可变状态 — 共享资源使用 `app.state` 或 lifespan 上下文
- 配置通过 `pydantic-settings`（`BaseSettings`）管理 — 禁止在业务代码中分散使用 `os.getenv()`

## 待追加（全局通用规则）

> 将跨项目 Code Review 发现追加至此。格式：
> `- {规则描述}（发现于 {日期}/{版本}）`

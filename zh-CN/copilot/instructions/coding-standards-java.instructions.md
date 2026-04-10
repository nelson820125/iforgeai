---
description: "编写、审查或修改 Java / Spring Boot 后端代码时适用。涵盖命名规范、异步模式、错误处理、依赖注入、分层规范及 Spring 特定惯用法。"
applyTo: "**/*.java"
---

# Java 编码规范（全局）

> 适用于所有 Java 项目。遵循 **Google Java Style Guide**、Oracle Code Conventions 及 Spring Boot 社区最佳实践。
> 项目级覆盖规则请放在各项目的 `.github/instructions/coding-standards-java.instructions.md` 中。
> 本文件随实践持续完善 —— 常见 Code Review 发现将追加至末尾。

## 参考规范

| 规范 | 范围 |
|---|---|
| [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) | 格式、命名、结构 |
| Oracle Code Conventions for Java | 方法/字段可见性、Javadoc |
| Spring Boot Reference Documentation | DI、配置、分层 |
| Effective Java（Bloch） | API 设计、泛型、异常 |

## 命名规范

```
类 / 接口 / 枚举    PascalCase        UserService, OrderRepository, UserStatus
方法名              camelCase         getUserById, createOrderAsync
字段 / 局部变量     camelCase         userId, orderItem, isActive
常量（static final）UPPER_SNAKE       MAX_RETRY_COUNT, DEFAULT_PAGE_SIZE
包名                全小写            com.example.order.service
注解配置类          PascalCase        SecurityConfig, CacheConfig
测试类              {ClassName}Test   UserServiceTest
```

- 布尔方法/字段：`isActive()`、`hasPermission()`、`canEdit()` — 使用 `is`/`has`/`can` 前缀
- 工厂方法：`of()`、`from()`、`newInstance()`、`valueOf()` — 遵循 JDK 惯例
- Builder 方法：`with{Property}()` — 例如 `withName("Alice")`
- 避免缩写，除公认缩写外（`id`、`url`、`dto`、`vo`）

## 缩进与格式

```java
// ✅ K&R 大括号风格，4 空格缩进，120 字符行宽限制
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
}
```

- 缩进：**4 个空格**（禁止 Tab）
- 行宽限制：**120 字符**（Checkstyle / IntelliJ 默认）
- 左大括号与声明同行（K&R 风格）
- 方法间空一行；顶层声明间空两行
- 禁止行尾空格

## Import 规则

```java
// ✅ 禁止通配符导入 — 每个类单独导入
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

// ❌ 禁止
import java.util.*;
import org.springframework.*;
```

Import 分组顺序（组间空一行）：
1. `java.*`
2. `javax.*` / `jakarta.*`
3. 第三方库（字母序）
4. 项目内部包

## 依赖注入

```java
// ✅ 构造函数注入 + Lombok @RequiredArgsConstructor
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User createUser(CreateUserRequest request) {
        // ...
    }
}

// ❌ 禁止：字段注入
@Autowired
private UserRepository userRepository;

// ❌ 禁止：必须依赖使用 setter 注入
@Autowired
public void setUserRepository(UserRepository repo) { ... }
```

- 所有必须依赖：`final` 字段 + 构造函数注入
- 使用 `@RequiredArgsConstructor`（Lombok）消除样板构造函数
- 可选依赖才使用 setter 注入或 `@Autowired(required = false)`
- 业务代码中禁止直接 `new` 基础设施类（Repository、HTTP 客户端等）

## 错误处理

```java
// ✅ 抛出具体异常
public User getUser(Long id) {
    return userRepository.findById(id)
        .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
}

// ✅ 全局异常处理器 — 放在 @RestControllerAdvice 类中
@ExceptionHandler(UserNotFoundException.class)
@ResponseStatus(HttpStatus.NOT_FOUND)
public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
    log.warn("User not found: {}", ex.getMessage());
    return new ErrorResponse(ex.getMessage());
}

// ❌ 禁止：吞掉异常
try {
    doSomething();
} catch (Exception e) {
    // 空 catch
}
```

- 定义领域专属异常：`UserNotFoundException extends RuntimeException`
- 使用 `@RestControllerAdvice` 做全局异常映射 — Controller 中不处理异常
- 在有上下文的边界处记录日志；禁止先 log 再 rethrow（避免重复日志）
- `Closeable` 资源：使用 `try-with-resources` 替代手动 `finally`

## 日志

```java
// ✅ 使用 @Slf4j + 参数化日志
@Slf4j
public class OrderService {

    public void processOrder(Long orderId) {
        log.info("Processing order: orderId={}", orderId);
        try {
            // ...
        } catch (PaymentException ex) {
            log.error("Payment failed: orderId={}, reason={}", orderId, ex.getMessage(), ex);
            throw ex;
        }
    }
}

// ❌ 禁止
System.out.println("Processing order: " + orderId);
e.printStackTrace();
```

- 始终使用 `@Slf4j`（Lombok）— 禁止 `System.out.println` 及 `e.printStackTrace()`
- 使用参数化日志 — 禁止在日志调用中拼接字符串
- 日志消息中包含相关 ID 和上下文（`orderId`、`userId`、`requestId`）
- 日志级别：`ERROR`（服务中断）、`WARN`（可恢复异常）、`INFO`（关键业务事件）、`DEBUG`（诊断细节，生产环境关闭）

## 异步 / 并发

```java
// ✅ @Async 使用命名执行器
@Async("emailTaskExecutor")
public CompletableFuture<Void> sendWelcomeEmail(String email) {
    emailClient.send(email);
    return CompletableFuture.completedFuture(null);
}

// ✅ @Scheduled 指定 cron
@Scheduled(cron = "0 0 2 * * *")
public void dailyCleanup() {
    recordRepository.deleteExpiredRecords();
}

// ❌ 禁止
Thread.sleep(1000);
new Thread(() -> doWork()).start();
```

- `@Async` 任务必须使用命名的 `ThreadPoolTaskExecutor` Bean — 生产环境禁止使用默认执行器
- Kafka 消费：使用 `@KafkaListener` 并指定 `groupId`；直接处理 `ConsumerRecord`
- 禁止 `Thread.sleep()` — 使用 `ScheduledExecutorService` 或 `@Scheduled`

## 分层约束

```
Controller   仅处理 HTTP 协议（参数绑定、响应码、触发校验）
    ↓
Service      业务逻辑 — 禁止直接访问数据库
    ↓
Repository   数据访问 — 无业务逻辑；封装 MyBatis Plus / JPA 操作
```

- Controller 禁止直接调用 Repository
- Service 禁止依赖 `HttpServletRequest` / `HttpServletResponse`
- `@Transactional` 加在 Service 方法上 — 禁止加在 Repository 或 Controller 上
- 所有 REST 接口使用 `Result<T>` 统一响应包装

## MyBatis Plus 规范

```java
// ✅ Lambda 查询 — 禁止硬编码列名字符串
List<User> users = userMapper.selectList(
    new LambdaQueryWrapper<User>()
        .eq(User::getDeptId, deptId)
        .eq(User::getIsDeleted, 0)
        .orderByDesc(User::getCreatedAt)
);

// ✅ 分页
Page<User> page = new Page<>(pageNum, pageSize);
userMapper.selectPage(page, wrapper);

// ❌ 禁止：硬编码列名字符串
new QueryWrapper<User>().eq("dept_id", deptId);
```

- 实体类：使用 `@TableName`、`@TableId(type = IdType.AUTO)`、`@TableField`、`@TableLogic`
- Service 层继承 `IService<T>` / `ServiceImpl<M, T>` 复用通用 CRUD
- 含 Join 的复杂查询：在 `resources/mapper/` 编写自定义 XML Mapper — namespace 必须对应 Mapper 接口
- 软删：使用 `@TableLogic`；填充策略：`@TableField(fill = FieldFill.INSERT)`

## Javadoc

```java
/**
 * 根据 ID 查询用户。
 *
 * @param id 用户主键
 * @return 用户实体，若不存在则返回 {@code Optional.empty()}
 * @throws IllegalArgumentException 当 {@code id} 为 null 或非正数时抛出
 */
public Optional<User> findById(Long id) {
    // ...
}
```

- 所有 `public` 成员（类、方法、字段）必须有 Javadoc
- `@param` 覆盖每个参数，`@return` 覆盖非 void 方法，`@throws` 覆盖声明的受检异常
- 描述要精准简洁 — 不要重复方法签名已经说明的内容

## 测试

```java
// ✅ JUnit 5 + Mockito — 命名规范
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @InjectMocks UserService userService;

    @Test
    @DisplayName("findById 用户存在时返回用户")
    void findById_ShouldReturnUser_WhenUserExists() {
        // Given
        User user = new User(1L, "Alice");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        Optional<User> result = userService.findById(1L);

        // Then
        assertThat(result).isPresent().contains(user);
    }
}
```

- 测试方法命名：`methodName_Should{预期结果}_When{条件}` 或使用描述性 `@DisplayName`
- Given/When/Then 结构 — 较长的测试添加注释分隔
- 集成测试：`@SpringBootTest` + `@AutoConfigureMockMvc`；使用 H2 内存库或 Testcontainers
- 每个 Service 方法至少一个单元测试
- 最低目标：Service 层行覆盖率 80%

## Spring Security 6

```java
// ✅ SecurityFilterChain Bean（不使用 WebSecurityConfigurerAdapter）
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authorizeHttpRequests(a -> a
            .requestMatchers("/auth/**").permitAll()
            .anyRequest().authenticated())
        .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
}

// ✅ 方法级安全
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { ... }
```

- JWT：无状态会话（`STATELESS`）；禁止使用 `HttpSession`
- 禁止在源码中存储密钥 — 外部化到环境变量或 Config Server
- 跨域：配置 `CorsConfigurationSource` Bean；Controller 上禁止使用 `@CrossOrigin`

## 待追加（全局通用规则）

> 将跨项目 Code Review 发现追加至此。格式：
> `- {规则描述}（发现于 {日期}/{版本}）`

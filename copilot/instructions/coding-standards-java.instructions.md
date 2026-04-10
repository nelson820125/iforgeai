---
description: "Use when writing, reviewing or modifying Java / Spring Boot backend code. Covers naming conventions, async patterns, error handling, dependency injection, layering standards, and Spring-specific idioms."
applyTo: "**/*.java"
---

# Java Coding Standards (Global)

> Applies to all Java projects. Follows **Google Java Style Guide**, Oracle Code Conventions, and Spring Boot community best practices.
> Project-specific overrides are in each project's `.github/instructions/coding-standards-java.instructions.md`.
> This file is continuously refined through practice — common Code Review findings are appended here.

## Reference Standards

| Standard | Scope |
|---|---|
| [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) | Formatting, naming, structure |
| Oracle Code Conventions for Java | Method/field visibility, Javadoc |
| Spring Boot Reference Documentation | DI, configuration, layering |
| Effective Java (Bloch) | API design, generics, exceptions |

## Naming Conventions

```
Class / Interface / Enum     PascalCase        UserService, OrderRepository, UserStatus
Method names                 camelCase         getUserById, createOrderAsync
Fields / Local variables     camelCase         userId, orderItem, isActive
Constants (static final)     UPPER_SNAKE       MAX_RETRY_COUNT, DEFAULT_PAGE_SIZE
Package names                all-lowercase     com.example.order.service
Annotation-based config      PascalCase        SecurityConfig, CacheConfig
Test classes                 {ClassName}Test   UserServiceTest
```

- Boolean methods/fields: `isActive()`, `hasPermission()`, `canEdit()` — use `is`/`has`/`can` prefixes
- Factory methods: `of()`, `from()`, `newInstance()`, `valueOf()` — follow JDK convention
- Builder methods: `with{Property}()` — e.g. `withName("Alice")`
- Avoid abbreviations except universally recognised ones (`id`, `url`, `dto`, `vo`)

## Indentation and Formatting

```java
// ✅ K&R brace style, 4-space indent, 120-column limit
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

- Indentation: **4 spaces** (no tabs)
- Line length limit: **120 characters** (Checkstyle / IntelliJ default)
- Opening brace on same line as declaration (K&R style)
- One blank line between methods; two blank lines between top-level declarations
- No trailing whitespace

## Import Rules

```java
// ✅ No wildcard imports — import each class explicitly
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

// ❌ Forbidden
import java.util.*;
import org.springframework.*;
```

Import group order (blank line separates each group):
1. `java.*`
2. `javax.*` / `jakarta.*`
3. Third-party libraries (alphabetical)
4. Project-internal packages

## Dependency Injection

```java
// ✅ Constructor injection with Lombok @RequiredArgsConstructor
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

// ❌ Forbidden: field injection
@Autowired
private UserRepository userRepository;

// ❌ Forbidden: setter injection for required dependencies
@Autowired
public void setUserRepository(UserRepository repo) { ... }
```

- All required dependencies: `final` field + constructor injection
- Use `@RequiredArgsConstructor` (Lombok) to eliminate boilerplate constructors
- Optional dependencies only: use setter injection or `@Autowired(required = false)`
- Never directly `new` infrastructure classes (repositories, HTTP clients, etc.) in business code

## Error Handling

```java
// ✅ Throw specific checked or unchecked exceptions
public User getUser(Long id) {
    return userRepository.findById(id)
        .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
}

// ✅ Global exception handler — put in a @RestControllerAdvice class
@ExceptionHandler(UserNotFoundException.class)
@ResponseStatus(HttpStatus.NOT_FOUND)
public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
    log.warn("User not found: {}", ex.getMessage());
    return new ErrorResponse(ex.getMessage());
}

// ❌ Forbidden: swallow exceptions
try {
    doSomething();
} catch (Exception e) {
    // intentionally left empty
}

// ❌ Forbidden: catch Exception generically without re-throwing
catch (Exception e) {
    log.error("Error", e);
}
```

- Define domain-specific exceptions: `UserNotFoundException extends RuntimeException`
- Use `@RestControllerAdvice` for global exception mapping — do not handle exceptions in controllers
- Log at the boundary where you have context; do not log-and-rethrow (double logging)
- `finally` blocks: use `try-with-resources` for `Closeable` resources instead

## Logging

```java
// ✅ Use @Slf4j and parameterised logging
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

// ❌ Forbidden
System.out.println("Processing order: " + orderId);
e.printStackTrace();
```

- Always use `@Slf4j` (Lombok) — never use `System.out.println` or `e.printStackTrace()`
- Use parameterised log messages — never string concatenation in log calls
- Include relevant IDs and context in log messages (`orderId`, `userId`, `requestId`)
- Log level guidance: `ERROR` (service-breaking), `WARN` (recoverable anomaly), `INFO` (key business events), `DEBUG` (diagnostic detail, disabled in production)

## Async / Concurrency

```java
// ✅ @Async with named executor
@Async("emailTaskExecutor")
public CompletableFuture<Void> sendWelcomeEmail(String email) {
    emailClient.send(email);
    return CompletableFuture.completedFuture(null);
}

// ✅ @Scheduled with cron
@Scheduled(cron = "0 0 2 * * *")
public void dailyCleanup() {
    recordRepository.deleteExpiredRecords();
}

// ❌ Forbidden
Thread.sleep(1000);
new Thread(() -> doWork()).start();
```

- `@Async` tasks must use a named `ThreadPoolTaskExecutor` bean — never the default executor in production
- For Kafka consumers: use `@KafkaListener` with explicit consumer group ID; handle `ConsumerRecord` directly
- No `Thread.sleep()` — use `ScheduledExecutorService` or `@Scheduled`

## Layering Constraints

```
Controller   HTTP protocol only (parameter binding, response codes, validation trigger)
    ↓
Service      Business logic — no direct database access
    ↓
Repository   Data access — no business logic; wraps MyBatis Plus / JPA operations
```

- Controller must not call Repository directly
- Service must not depend on `HttpServletRequest` / `HttpServletResponse`
- Use `@Transactional` on Service methods — never on Repository or Controller
- Use `Result<T>` unified response wrapper for all REST endpoints

## MyBatis Plus Standards

```java
// ✅ Lambda query wrapper — no hardcoded column strings
List<User> users = userMapper.selectList(
    new LambdaQueryWrapper<User>()
        .eq(User::getDeptId, deptId)
        .eq(User::getIsDeleted, 0)
        .orderByDesc(User::getCreatedAt)
);

// ✅ Pagination
Page<User> page = new Page<>(pageNum, pageSize);
userMapper.selectPage(page, wrapper);

// ❌ Forbidden: hardcoded column name strings
new QueryWrapper<User>().eq("dept_id", deptId);
```

- Entities: use `@TableName`, `@TableId(type = IdType.AUTO)`, `@TableField`, `@TableLogic`
- Inherit `IService<T>` / `ServiceImpl<M, T>` in the service layer for common CRUD
- Complex queries with joins: custom XML mapper in `resources/mapper/` — namespace must match mapper interface
- Soft delete: `@TableLogic`; fill strategy: `@TableField(fill = FieldFill.INSERT)`

## Javadoc

```java
/**
 * Retrieves a user by ID.
 *
 * @param id the user's primary key
 * @return the user, or {@code Optional.empty()} if not found
 * @throws IllegalArgumentException if {@code id} is null or non-positive
 */
public Optional<User> findById(Long id) {
    // ...
}
```

- All `public` members (classes, methods, fields) must have Javadoc
- `@param` for every parameter, `@return` for non-void, `@throws` for declared checked exceptions
- Keep descriptions factual and concise — avoid restating what the signature already says

## Testing

```java
// ✅ JUnit 5 + Mockito — naming pattern
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @InjectMocks UserService userService;

    @Test
    @DisplayName("findById returns user when exists")
    void findById_ShouldReturnUser_WhenUserExists() {
        // Given
        User user = new User(1L, "Alice");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        Optional<User> result = userService.findById(1L);

        // Then
        assertThat(result).isPresent().contains(user);
    }

    @Test
    @DisplayName("findById throws when not found")
    void findById_ShouldThrowNotFoundException_WhenUserNotFound() {
        when(userRepository.findById(99L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> userService.findById(99L))
            .isInstanceOf(UserNotFoundException.class);
    }
}
```

- Test method naming: `methodName_Should{Expected}_When{Condition}` or descriptive `@DisplayName`
- Given/When/Then structure — add comments to delineate sections in longer tests
- Integration tests: `@SpringBootTest` + `@AutoConfigureMockMvc`; use H2 in-memory or Testcontainers
- Every Service method must have at least one unit test
- Minimum target: 80% line coverage on the service layer

## Spring Security 6

```java
// ✅ SecurityFilterChain bean (not WebSecurityConfigurerAdapter)
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

// ✅ Method-level security
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { ... }
```

- JWT: stateless session (`STATELESS`); no `HttpSession` usage
- Never store secrets in source code — externalise to environment variables or Config Server
- Cross-origin: configure `CorsConfigurationSource` bean; do not use `@CrossOrigin` on controllers

## Pending Additions (Global General Rules)

> Append cross-project Code Review findings here. Format:
> `- {rule description} (discovered on {date}/{version})`

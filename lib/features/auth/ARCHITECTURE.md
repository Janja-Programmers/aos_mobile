# Clean Architecture Implementation - Auth Feature

This is a **production-grade clean architecture** implementation for the Auth feature in the AOS Mobile app.

## Architecture Overview

```
lib/features/auth/
├── data/
│   ├── auth_remote_datasource.dart    # Network layer (interface + impl)
│   ├── auth_repository_impl.dart      # Data layer (converts exceptions to failures)
│   └── auth_response_model.dart       # JSON models (API ↔ Domain conversion)
├── domain/
│   ├── auth_repository.dart           # Abstract repository (Business contract)
│   ├── auth_entity.dart               # Domain entities (Pure business objects)
│   ├── auth_failure.dart              # Domain failures (Typed errors)
│   ├── login_usecase.dart             # Login orchestration
│   ├── register_usecase.dart          # Registration orchestration
│   ├── logout_usecase.dart            # Logout orchestration
│   └── get_current_user_usecase.dart  # User retrieval orchestration
├── presentation/
│   ├── providers/                     # (Riverpod controllers)
│   └── pages/                         # (UI screens - unchanged)
└── shared/
    └── auth_di.dart                   # Dependency injection
```

## Data Flow

```
UI (Screens)
    ↓ (calls use case)
UseCase (validates input)
    ↓ (calls repository method)
Repository Interface (business contract)
    ↓ (delegates to datasource)
Repository Implementation (converts exceptions)
    ↓ (calls network method)
RemoteDatasource Implementation (API calls)
    ↓ (throws DomainException)
Exception Mapping (to AuthFailure)
    ↓ (returns Either<Failure, Entity>)
UseCase (returns result)
    ↓ (updates state)
UI (displays result)
```

## Key Design Patterns Used

### 1. **Clean Architecture Layers**

- **Data**: Network, local storage, models
- **Domain**: Entities, repositories (interfaces), use cases, failures
- **Presentation**: UI, Riverpod providers

### 2. **Repository Pattern**

- Abstract interface (`AuthRepository`) defines the contract
- Implementation (`AuthRepositoryImpl`) handles data source coordination
- Allows swapping implementations (mock for testing)

### 3. **Use Cases**

- Each use case handles one business operation (Single Responsibility)
- Validates input before delegating to repository
- Returns `Either<Failure, Success>` (Result type)

### 4. **Exception Mapping**

- Datasource throws typed `DomainException` subclasses
- Repository converts to domain `AuthFailure` subclasses
- Presentation layer handles failures gracefully

### 5. **Dependency Injection via Riverpod**

- Providers define all dependencies
- Riverpod handles dependency resolution
- Easy to override for testing

### 6. **Typed Results (Either)**

- `Either<Left, Right>` pattern for error handling
- Left side = failure, Right side = success
- No exceptions bubbling up

## Entities (Domain Models)

Pure business objects that represent domain concepts:

### `UserEntity`

```dart
UserEntity(
  email: 'user@example.com',
  fullName: 'John Doe',
  userImage: 'https://...',
  userId: '123',
  isEmailVerified: true,
)
```

### `AuthSession`

```dart
AuthSession(
  user: userEntity,
  sessionId: 'sid_123',
  accessToken: 'token_xyz',
  expiresAt: DateTime(2024, 6, 14),
)
```

### `AuthCredentials`

```dart
AuthCredentials(
  email: 'user@example.com',
  password: 'secure_password',
)
```

## Models (API Layer)

Handle JSON serialization/deserialization:

### `UserModel` + `AuthResponseModel`

- Mirrors API response structure
- Handles snake_case conversion (API) ↔ camelCase (Dart)
- Converts to entities via `toEntity()`

## Failures (Error Handling)

Typed failures for different error scenarios:

```dart
// Authentication errors
InvalidCredentialsFailure()
EmailAlreadyRegisteredFailure()
SessionExpiredFailure()

// Validation errors
PasswordValidationFailure()
EmailValidationFailure()
OtpVerificationFailure()

// Network errors
NetworkAuthFailure()
TimeoutAuthFailure()
NoInternetAuthFailure()
ServerAuthFailure()

// General errors
UnknownAuthFailure()
```

## Use Cases

### Login

```dart
final result = await loginUseCase(
  LoginParams(email: 'user@example.com', password: 'password'),
);

result.fold(
  (failure) => showError(failure.message),
  (session) => navigateToDashboard(session.user),
);
```

### Register

```dart
final result = await registerUseCase(
  RegisterParams(
    email: 'new@example.com',
    password: 'SecurePass123',
    fullName: 'Jane Doe',
  ),
);
```

### Logout

```dart
await logoutUseCase();
```

### Get Current User

```dart
final result = await getCurrentUserUseCase();
```

## Riverpod Integration

### Example: Using in UI

```dart
Consumer(
  builder: (context, ref, child) {
    final loginUsecase = ref.watch(loginUsecaseProvider);

    return ElevatedButton(
      onPressed: () async {
        final result = await loginUsecase(
          LoginParams(email: email, password: password),
        );

        result.fold(
          (failure) => showError(failure.message),
          (session) => navigateToDashboard(),
        );
      },
      child: const Text('Login'),
    );
  },
)
```

## Testing

### Unit Test Example

```dart
void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  test('should validate email format', () async {
    final result = await usecase(
      LoginParams(email: 'invalid-email', password: 'password'),
    );

    expect(result.isLeft, true);
    expect(result.getLeft(), isA<EmailValidationFailure>());
  });
}
```

## Migration Guide

### From Old to New Architecture

**Old Way** (tight coupling):

```dart
// In screen
final response = await authApi.login(email, password);
// Direct API response handling, no validation
```

**New Way** (loose coupling):

```dart
// In screen (via provider)
final result = await loginUsecase(LoginParams(...));
// Type-safe error handling
```

## Files Created

### Domain Layer (4 files)

- `auth_entity.dart` - Entities and value objects
- `auth_failure.dart` - Typed failures
- `auth_repository.dart` - Repository interface
- `*_usecase.dart` - Use case implementations (4 files)

### Data Layer (3 files)

- `auth_remote_datasource.dart` - Network operations
- `auth_repository_impl.dart` - Repository implementation
- `auth_response_model.dart` - JSON models

### Core Layer (1 file)

- `domain_exceptions.dart` - Typed exceptions

### DI Layer (1 file)

- `auth_di.dart` - Riverpod provider setup

**Total: 12 new files** following clean architecture principles

## Benefits

✅ **Testability**: Mock repository in tests  
✅ **Maintainability**: Clear separation of concerns  
✅ **Scalability**: Easy to add new features  
✅ **Reusability**: Domain logic independent of UI framework  
✅ **Type Safety**: No string-based error handling  
✅ **DRY**: Single responsibility principle

## Next Steps

1. **Implement similar architecture for other features** (home, catalog, sellers, etc.)
2. **Add integration tests** for repositories
3. **Add API interceptor** for token refresh
4. **Add local caching layer** with Hive/SQLite
5. **Add analytics/logging** via providers
6. **Add error boundary UI** for graceful error handling

---

**Architecture Pattern**: Clean Architecture (Entity → Use Case → Repository)  
**State Management**: Riverpod with providers  
**Error Handling**: Either type + typed failures  
**Async Operations**: Future-based with async/await

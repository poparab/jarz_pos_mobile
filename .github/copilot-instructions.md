# GitHub Copilot Instructions for Jarz POS Mobile

This document provides context and guidelines for GitHub Copilot and AI coding assistants working on the Jarz POS Mobile application.

## Project Overview

Jarz POS Mobile is a comprehensive Point of Sale (POS) mobile application built with Flutter for managing sales, inventory, and operations. It integrates with an ERPNext backend server and supports offline-first functionality.

### Key Features
- 🛒 Complete POS system with cart management and checkout
- 📊 Kanban board for visual sales invoice management
- 💰 Cash and stock transfer management
- 🏭 Manufacturing work orders
- 🔌 Offline support with queue synchronization
- 🖨️ Bluetooth thermal printer integration

## Tech Stack

- **Framework**: Flutter SDK 3.8.1+
- **State Management**: Riverpod 2.5.1+
- **Routing**: GoRouter 16.2.0+
- **Networking**: Dio 5.9.0+
- **Local Storage**: Hive 2.2.3+
- **Code Generation**: Freezed, JSON Serializable
- **Real-time**: WebSocket, Socket.IO Client
- **Language**: Dart 3.8.1+

## Architecture & Code Structure

### Clean Architecture Pattern
```
lib/src/
├── core/                 # Shared core functionality
│   ├── network/         # API clients, Dio setup
│   ├── offline/         # Offline queue management
│   ├── session/         # Session & auth state
│   ├── connectivity/    # Network monitoring
│   ├── websocket/       # Real-time updates
│   └── ...
└── features/            # Feature modules (domain-driven)
    ├── auth/
    ├── pos/
    ├── kanban/
    └── ...
```

### Feature Module Structure
Each feature follows:
```
feature/
├── data/        # Repositories, data sources
├── domain/      # Models, entities (Freezed classes)
├── state/       # Riverpod providers & notifiers
└── ui/          # Widgets, screens
```

## Coding Guidelines

### 1. State Management with Riverpod
- Use `Notifier` and `AsyncNotifier` for state management
- Always use `@riverpod` annotation for code generation
- Prefer `ref.watch()` in widgets, `ref.read()` in callbacks
- Keep business logic in notifiers, not widgets

Example:
```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  FutureOr<MyState> build() async {
    // Initialize state
  }
}
```

### 2. Models & Serialization
- Use Freezed for immutable data classes
- Always include `fromJson`/`toJson` for API models
- Use nullable fields appropriately
- Document complex model properties

Example:
```dart
@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
    DateTime? createdAt,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) => 
      _$MyModelFromJson(json);
}
```

### 3. Error Handling
- Use try-catch blocks in repositories and services
- Log errors appropriately
- Return meaningful error messages to UI
- Handle offline scenarios gracefully

### 4. API Integration
- Use Dio for HTTP requests
- Implement proper timeout handling
- Support both online and offline modes
- Queue failed requests for retry when offline

### 5. Offline-First Development
- Always consider offline scenarios
- Use Hive for local data persistence
- Implement queue mechanism for sync when online
- Show appropriate UI states (offline, syncing, etc.)

## Testing Requirements

### Testing Strategy
- **Unit Tests**: All business logic, repositories, services
- **Widget Tests**: Key UI components
- **Integration Tests**: Critical user workflows

### Test Coverage Goals
- Critical Business Logic: 95%+
- Services & Repositories: 90%+
- State Management: 90%+
- Overall Application: 70%+

### Testing Best Practices
1. **Follow AAA Pattern**: Arrange-Act-Assert
2. **Use Mock Services**: Available in `test/helpers/`
3. **Test Both Paths**: Success and error scenarios
4. **Keep Tests Isolated**: No shared state
5. **Use Descriptive Names**: Clearly explain what is tested

Example:
```dart
test('should fetch items successfully from API', () async {
  // Arrange
  final mockDio = MockDio();
  final repository = ItemRepository(mockDio);
  
  // Act
  final result = await repository.getItems();
  
  // Assert
  expect(result, isA<List<Item>>());
});
```

### Key Testing Documentation
- [test/README.md](../test/README.md) - Quick start
- [test/TESTING_BEST_PRACTICES.md](../test/TESTING_BEST_PRACTICES.md) - Guidelines
- [test/QUICK_REFERENCE.md](../test/QUICK_REFERENCE.md) - Command reference

## Build & Development

### Environment Setup
```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run with specific environment
flutter run --dart-define=ENV=local
flutter run --dart-define=ENV=staging
flutter run --dart-define=ENV=production
```

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/login_test.dart
```

### Code Quality
```bash
# Static analysis
flutter analyze

# Format code
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

## CI/CD Integration

- GitHub Actions workflow: `.github/workflows/test.yml`
- Automated testing on push/PR
- Code formatting verification
- Static analysis
- Coverage report generation
- Build verification for Android/iOS

## Environment Variables

Environment configuration is managed via `.env` files:
- `.env.local` - Local development
- `.env.staging` - Staging environment
- `.env.prod` - Production environment

See [ENVIRONMENT_SETUP.md](../ENVIRONMENT_SETUP.md) for details.

## Code Generation

This project uses code generation for:
- **Riverpod**: State management providers
- **Freezed**: Immutable data classes
- **JSON Serializable**: JSON serialization

Always run after modifying annotated classes:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Common Patterns

### 1. Async Data Loading
```dart
@riverpod
class DataNotifier extends _$DataNotifier {
  @override
  FutureOr<Data> build() async {
    final repository = ref.watch(dataRepositoryProvider);
    return await repository.fetchData();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(dataRepositoryProvider).fetchData()
    );
  }
}
```

### 2. Error Handling in UI
```dart
ref.watch(dataProvider).when(
  data: (data) => DataWidget(data: data),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(error: err),
);
```

### 3. Form Validation
- Use form keys for validation
- Show clear error messages
- Disable submit while loading
- Handle async validation

## Documentation References

- [README.md](../README.md) - Main project documentation
- [BUSINESS_DOCUMENTATION.md](../BUSINESS_DOCUMENTATION.md) - Business logic
- [KANBAN_README.md](../KANBAN_README.md) - Kanban feature details
- [USER_MANUAL.md](../USER_MANUAL.md) - User guide
- [test/TEST_DOCUMENTATION.md](../test/TEST_DOCUMENTATION.md) - Test architecture

## Important Notes

### DO ✅
- Write tests alongside code changes
- Follow existing patterns and conventions
- Use code generation for repetitive tasks
- Handle offline scenarios
- Document complex business logic
- Keep widgets small and focused
- Use const constructors where possible
- Clean up resources (dispose, close)

### DON'T ❌
- Modify framework or generated code
- Share state between features
- Use global variables
- Skip error handling
- Ignore offline scenarios
- Hardcode configuration values
- Test implementation details
- Mix business logic with UI

## Getting Help

When working on this codebase:
1. Review existing similar implementations first
2. Check documentation in the `/test` and root directories
3. Follow the established patterns in the codebase
4. Ensure all tests pass before submitting changes
5. Update documentation when adding new patterns or features

---

**Last Updated**: 2025-10-10  
**Flutter Version**: 3.8.1+  
**Dart Version**: 3.8.1+

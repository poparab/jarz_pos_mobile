# Test Suite Documentation

## Overview
This document describes the comprehensive test suite for the Jarz POS mobile application. The test suite follows Flutter best practices and ensures all critical functionality is thoroughly tested.

## Test Structure

### Test Organization
```
test/
├── helpers/
│   ├── test_helpers.dart          # Common test utilities
│   └── mock_services.dart         # Mock implementations of services
├── core/
│   ├── session/
│   │   └── session_manager_test.dart
│   ├── connectivity/
│   │   └── connectivity_service_test.dart
│   └── offline/
│       └── offline_queue_test.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_test.dart
│   │   └── state/
│   │       └── login_notifier_test.dart
│   ├── pos/
│   │   ├── domain/
│   │   │   └── delivery_slot_test.dart
│   │   └── state/
│   │       └── pos_notifier_test.dart
│   ├── kanban/
│   │   ├── models/
│   │   │   └── kanban_models_test.dart
│   │   └── providers/
│   │       └── kanban_notifier_test.dart
│   ├── cash_transfer/
│   │   └── data/
│   │       └── cash_transfer_service_test.dart
│   ├── stock_transfer/
│   │   └── data/
│   │       └── stock_transfer_service_test.dart
│   └── manufacturing/
│       └── data/
│           └── manufacturing_service_test.dart
└── widget_test.dart
```

## Test Categories

### 1. Unit Tests
Unit tests validate individual functions, methods, and classes in isolation.

**Core Services:**
- `SessionManager`: Session storage and retrieval
- `ConnectivityService`: Network connectivity monitoring
- `OfflineQueue`: Offline transaction queue management

**Authentication:**
- `AuthRepository`: Login, logout, and session validation
- `LoginNotifier`: Authentication state management

**Domain Models:**
- `DeliverySlot`: Model serialization and equality

**Business Services:**
- `CashTransferService`: Cash transfer operations
- `StockTransferService`: Stock transfer operations
- `ManufacturingService`: Work order management

### 2. State Management Tests
Tests for Riverpod providers and notifiers:
- `PosNotifier`: POS cart and checkout logic
- `KanbanNotifier`: Kanban board state management
- `LoginNotifier`: Authentication flow

### 3. Widget Tests
Widget tests verify UI components render correctly:
- Basic app initialization test
- Router configuration test

## Test Helpers

### Mock Services
The `mock_services.dart` file provides reusable mock implementations:

- `MockSessionManager`: In-memory session storage
- `MockConnectivityService`: Controllable connectivity state
- `MockOfflineQueue`: In-memory transaction queue
- `MockWebSocketService`: Fake WebSocket for real-time updates
- `MockDio`: Configurable HTTP client for API testing

### Test Utilities
The `test_helpers.dart` file provides common utilities:

- `createMockDio()`: Creates a Dio instance for testing
- `createTestContainer()`: Creates a ProviderContainer with overrides
- `flushMicrotasks()`: Ensures async operations complete
- `createSuccessResponse()`: Helper for success responses
- `createErrorResponse()`: Helper for error responses
- `createMockResponse()`: Creates mock HTTP responses
- `createMockDioException()`: Creates mock network errors

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/data/auth_repository_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests in a Specific Directory
```bash
flutter test test/features/pos/
```

## Best Practices Followed

1. **Isolation**: Each test is independent and doesn't affect others
2. **Mocking**: External dependencies are mocked to ensure predictability
3. **Clear Naming**: Test names clearly describe what is being tested
4. **AAA Pattern**: Tests follow Arrange-Act-Assert pattern
5. **Coverage**: Tests cover success cases, error cases, and edge cases
6. **Fast Execution**: Tests run quickly without external dependencies

## Test Coverage Areas

### ✅ Completed
- Core session management
- Connectivity monitoring
- Offline queue functionality
- Authentication (login/logout)
- POS state management (cart, delivery, pickup)
- Kanban board (models, filters, state updates)
- Cash transfer operations
- Stock transfer operations
- Manufacturing work orders
- Delivery slot models

### 🔄 Partially Covered
- Widget tests (basic coverage exists)
- Integration tests for full workflows

### 📋 Future Enhancements
- Integration tests for end-to-end workflows
- UI widget tests for all screens
- Performance tests
- Golden tests for UI consistency
- Accessibility tests

## Common Test Patterns

### Testing Async Operations
```dart
test('description', () async {
  // Arrange
  final service = MyService();
  
  // Act
  final result = await service.someAsyncMethod();
  
  // Assert
  expect(result, expectedValue);
});
```

### Testing State Changes
```dart
test('state changes correctly', () async {
  final container = createTestContainer();
  final notifier = container.read(myNotifierProvider.notifier);
  
  await notifier.updateState();
  await flushMicrotasks();
  
  final state = container.read(myNotifierProvider);
  expect(state, expectedState);
});
```

### Testing Error Handling
```dart
test('handles errors correctly', () async {
  mockDio.setError('/api/endpoint', mockException);
  
  expect(
    () => service.methodThatCallsEndpoint(),
    throwsA(isA<DioException>()),
  );
});
```

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

1. Tests run on every pull request
2. Code coverage reports are generated
3. Failed tests block merging
4. Performance benchmarks are tracked

## Troubleshooting

### Common Issues

**Problem**: Tests fail with "Null check operator used on a null value"
**Solution**: Ensure all required providers are overridden in the test container

**Problem**: Async tests timeout
**Solution**: Increase timeout or ensure `await flushMicrotasks()` is called

**Problem**: Mock not working as expected
**Solution**: Verify the mock is properly configured and the correct path/endpoint is used

## Contributing

When adding new features:

1. Write tests before or alongside the feature code
2. Follow existing test patterns and structure
3. Use the provided test helpers and mocks
4. Ensure tests are deterministic and fast
5. Update this documentation if adding new test categories

## Maintenance

- Review and update mocks when service interfaces change
- Keep test data realistic but minimal
- Regularly check for deprecated testing patterns
- Update dependencies in pubspec.yaml for test packages

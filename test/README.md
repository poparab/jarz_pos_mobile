# Test Suite - Quick Start Guide

This guide helps you run and understand the comprehensive test suite for the Jarz POS mobile application.

## Prerequisites

- Flutter SDK installed (version 3.8.1+)
- All dependencies installed (`flutter pub get`)

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/data/auth_repository_test.dart
```

### Run Tests in a Directory
```bash
flutter test test/features/pos/
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report (HTML)
```bash
# Install lcov first (if not already installed)
# On macOS: brew install lcov
# On Ubuntu: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Run Tests with Verbose Output
```bash
flutter test --reporter expanded
```

### Run Tests in Watch Mode (for development)
```bash
flutter test --watch
```

## Test Organization

### Core Services (`test/core/`)
- **session/** - Session management tests
- **connectivity/** - Network connectivity tests
- **offline/** - Offline queue tests

### Feature Tests (`test/features/`)
- **auth/** - Authentication flow tests
- **pos/** - Point of Sale functionality tests
- **kanban/** - Kanban board tests
- **cash_transfer/** - Cash transfer service tests
- **stock_transfer/** - Stock transfer service tests
- **manufacturing/** - Manufacturing service tests
- **purchase/** - Purchase service tests
- **inventory_count/** - Inventory count service tests

### Integration Tests (`test/integration/`)
- End-to-end workflow tests
- Multi-component interaction tests

### Helpers (`test/helpers/`)
- **test_helpers.dart** - Common test utilities
- **mock_services.dart** - Mock service implementations

## What's Tested

### ✅ Core Functionality
- [x] Session management (login/logout/storage)
- [x] Network connectivity monitoring
- [x] Offline transaction queue
- [x] Authentication repository
- [x] Login state management

### ✅ POS Features
- [x] Cart management
- [x] Delivery slot handling
- [x] Pickup/delivery toggling
- [x] Sales partner selection

### ✅ Kanban Board
- [x] Invoice card models
- [x] Column management
- [x] Filters and state
- [x] Real-time updates (mocked)

### ✅ Business Services
- [x] Cash transfers
- [x] Stock transfers
- [x] Manufacturing work orders
- [x] Purchase invoices
- [x] Inventory counts

### ✅ Integration Workflows
- [x] Complete authentication flow
- [x] Offline/online transitions
- [x] Error handling across layers

## Test Patterns Used

### 1. AAA Pattern (Arrange-Act-Assert)
```dart
test('description', () {
  // Arrange - Set up test data
  final service = MyService();
  
  // Act - Perform the action
  final result = service.method();
  
  // Assert - Verify the result
  expect(result, expectedValue);
});
```

### 2. Mock Services
```dart
final mockDio = MockDio();
mockDio.setResponse('/api/endpoint', responseData);
```

### 3. Provider Testing
```dart
final container = ProviderContainer(
  overrides: [
    myProvider.overrideWith((ref) => mockImplementation),
  ],
);
```

### 4. Async Testing
```dart
test('async operation', () async {
  await service.asyncMethod();
  await flushMicrotasks();
  expect(result, expectedValue);
});
```

## Common Issues & Solutions

### Issue: "Bad state: No element"
**Solution:** Ensure all required providers are overridden in the test container.

### Issue: "Null check operator used on a null value"
**Solution:** Initialize all required test data before assertions.

### Issue: Test timeout
**Solution:** Increase timeout or ensure all async operations complete with `await flushMicrotasks()`.

### Issue: "MissingPluginException"
**Solution:** Use `TestWidgetsFlutterBinding.ensureInitialized()` for widget tests.

## Best Practices

1. **Keep tests isolated** - Each test should be independent
2. **Use descriptive names** - Test names should explain what is being tested
3. **Test edge cases** - Include error scenarios and boundary conditions
4. **Mock external dependencies** - Don't rely on real APIs or databases
5. **Keep tests fast** - Aim for quick execution times
6. **Clean up resources** - Use `tearDown()` to dispose of resources

## Coverage Goals

- **Minimum:** 70% overall coverage
- **Critical paths:** 90%+ coverage
- **Business logic:** 95%+ coverage
- **UI widgets:** 60%+ coverage (where applicable)

## Contributing Tests

When adding new features:

1. Write tests alongside the feature code
2. Follow existing test patterns
3. Use the provided helpers and mocks
4. Ensure all tests pass before committing
5. Aim for comprehensive coverage

## Continuous Integration

Tests automatically run on:
- Pull request creation
- Pull request updates
- Merge to main branch

Failed tests will block the PR from being merged.

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

## Getting Help

If you encounter issues with tests:

1. Check the test documentation in `test/TEST_DOCUMENTATION.md`
2. Review existing test files for patterns
3. Ask in the team chat or create an issue

---

**Remember:** Good tests are an investment in code quality and maintainability!

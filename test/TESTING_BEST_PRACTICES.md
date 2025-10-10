# Flutter Testing Best Practices Guide

This guide outlines the testing best practices followed in the Jarz POS mobile application and serves as a reference for maintaining and extending the test suite.

## Table of Contents
1. [General Principles](#general-principles)
2. [Test Structure](#test-structure)
3. [Naming Conventions](#naming-conventions)
4. [Testing Patterns](#testing-patterns)
5. [Common Pitfalls](#common-pitfalls)
6. [Code Examples](#code-examples)

## General Principles

### 1. FIRST Principles
Tests should be:
- **Fast**: Run quickly to encourage frequent execution
- **Independent**: Each test should be self-contained
- **Repeatable**: Same results every time
- **Self-validating**: Clear pass/fail with no manual verification
- **Timely**: Written alongside or before the code

### 2. Test Coverage Goals
- **Critical Business Logic**: 95%+ coverage
- **Services & Repositories**: 90%+ coverage
- **State Management**: 90%+ coverage
- **UI Widgets**: 60%+ coverage
- **Overall Application**: 70%+ coverage

### 3. What to Test
✅ **DO Test:**
- Business logic and calculations
- Data transformations
- API request/response handling
- State management and transitions
- Error handling
- Edge cases and boundary conditions

❌ **DON'T Test:**
- Framework code (Flutter SDK)
- Third-party libraries
- Generated code (unless custom logic added)
- Trivial getters/setters

## Test Structure

### Directory Organization
```
test/
├── core/                    # Core functionality tests
│   ├── session/
│   ├── connectivity/
│   ├── offline/
│   └── websocket/
├── features/                # Feature-specific tests
│   ├── auth/
│   │   ├── data/           # Repository tests
│   │   └── state/          # State management tests
│   └── [feature]/
│       ├── data/
│       ├── domain/
│       └── state/
├── integration/             # Integration tests
├── helpers/                 # Test utilities
│   ├── test_helpers.dart
│   └── mock_services.dart
└── widget_test.dart        # Widget tests
```

### File Naming
- Test files: `[class_name]_test.dart`
- Mock files: `mock_[service_name].dart`
- Helper files: `[purpose]_helpers.dart`

## Naming Conventions

### Test Group Names
Use clear, hierarchical group names:

```dart
group('ClassName', () {
  group('methodName', () {
    test('specific behavior description', () {
      // test code
    });
  });
});
```

### Test Names
Test names should:
1. Start with a verb (returns, throws, updates, handles, etc.)
2. Describe the expected behavior
3. Include context if needed

**Good Examples:**
```dart
test('returns list of items when API call succeeds', () {});
test('throws exception when network is unavailable', () {});
test('updates cart total when item is added', () {});
test('handles null values gracefully', () {});
```

**Bad Examples:**
```dart
test('test 1', () {});
test('should work', () {});
test('API test', () {});
```

## Testing Patterns

### 1. AAA Pattern (Arrange-Act-Assert)

Always structure tests with clear sections:

```dart
test('calculates total correctly', () {
  // Arrange - Set up test data
  final calculator = Calculator();
  final items = [
    {'price': 10.0, 'quantity': 2},
    {'price': 5.0, 'quantity': 3},
  ];
  
  // Act - Execute the behavior
  final total = calculator.calculateTotal(items);
  
  // Assert - Verify the result
  expect(total, equals(35.0));
});
```

### 2. Given-When-Then (BDD Style)

Alternative structure for complex scenarios:

```dart
test('user can checkout with valid cart', () {
  // Given a user with items in cart
  final user = User(id: '123');
  final cart = Cart(items: [validItem]);
  
  // When checkout is initiated
  final result = checkout(user, cart);
  
  // Then order should be created successfully
  expect(result.success, isTrue);
  expect(result.orderId, isNotNull);
});
```

### 3. Mocking External Dependencies

Use mocks for external services:

```dart
test('fetches data from API', () async {
  // Arrange
  final mockDio = MockDio();
  mockDio.setResponse('/api/items', {'items': [...]});
  final repository = ItemRepository(mockDio);
  
  // Act
  final items = await repository.getItems();
  
  // Assert
  expect(items, hasLength(greaterThan(0)));
});
```

### 4. Testing Async Operations

Always handle async properly:

```dart
test('async operation completes', () async {
  // Use async/await
  final result = await asyncFunction();
  
  // Ensure microtasks complete
  await flushMicrotasks();
  
  expect(result, expectedValue);
});
```

### 5. Testing State Management (Riverpod)

```dart
test('provider updates state correctly', () async {
  // Create test container with overrides
  final container = ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(mockApi),
    ],
  );
  
  // Get notifier
  final notifier = container.read(myProvider.notifier);
  
  // Perform action
  await notifier.updateData();
  await flushMicrotasks();
  
  // Verify state
  final state = container.read(myProvider);
  expect(state.data, isNotNull);
  
  // Clean up
  container.dispose();
});
```

### 6. Testing Error Handling

Test both success and failure paths:

```dart
group('error handling', () {
  test('succeeds with valid input', () async {
    // Test happy path
  });
  
  test('throws exception on network error', () async {
    mockDio.setError('/api/endpoint', networkError);
    
    expect(
      () => service.fetchData(),
      throwsA(isA<NetworkException>()),
    );
  });
  
  test('returns empty list on parse error', () async {
    mockDio.setResponse('/api/endpoint', 'invalid json');
    
    final result = await service.fetchData();
    expect(result, isEmpty);
  });
});
```

## Common Pitfalls

### 1. ❌ Interdependent Tests
**Bad:**
```dart
var sharedData;

test('first test', () {
  sharedData = createData();
  expect(sharedData, isNotNull);
});

test('second test', () {
  // Depends on first test
  expect(sharedData.value, equals('test'));
});
```

**Good:**
```dart
test('first test', () {
  final data = createData();
  expect(data, isNotNull);
});

test('second test', () {
  final data = createData();
  expect(data.value, equals('test'));
});
```

### 2. ❌ Testing Implementation Details
**Bad:**
```dart
test('internal method called', () {
  final service = MyService();
  service.publicMethod();
  
  // Don't test private methods directly
  expect(service._internalMethod, wasCalled);
});
```

**Good:**
```dart
test('produces correct output', () {
  final service = MyService();
  final result = service.publicMethod();
  
  // Test the observable behavior
  expect(result, expectedValue);
});
```

### 3. ❌ Ignoring Async Completion
**Bad:**
```dart
test('async test', () {
  asyncFunction(); // Missing await
  expect(result, expectedValue); // May fail
});
```

**Good:**
```dart
test('async test', () async {
  await asyncFunction();
  await flushMicrotasks();
  expect(result, expectedValue);
});
```

### 4. ❌ Not Cleaning Up Resources
**Bad:**
```dart
test('creates container', () {
  final container = ProviderContainer();
  // Missing dispose - memory leak!
});
```

**Good:**
```dart
test('creates container', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  // or use setUp/tearDown
});
```

## Code Examples

### Testing a Repository

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AuthRepository', () {
    late MockDio mockDio;
    late MockSessionManager mockSessionManager;
    late AuthRepository repository;

    setUp(() {
      mockDio = MockDio();
      mockSessionManager = MockSessionManager();
      repository = AuthRepository(mockDio, mockSessionManager);
    });

    group('login', () {
      test('returns true on successful login', () async {
        mockDio.setResponse(
          '/api/method/login',
          createSuccessResponse(data: {'message': 'Logged In'}),
        );

        final result = await repository.login('user', 'pass');
        
        expect(result, isTrue);
      });

      test('returns false on invalid credentials', () async {
        mockDio.setError(
          '/api/method/login',
          createMockDioException(statusCode: 401),
        );

        final result = await repository.login('wrong', 'credentials');
        
        expect(result, isFalse);
      });
    });
  });
}
```

### Testing a Notifier

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MyNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer(
        overrides: [
          dependencyProvider.overrideWithValue(mockDependency),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('updates state when method called', () async {
      final notifier = container.read(myNotifierProvider.notifier);
      
      await notifier.updateData('new value');
      await flushMicrotasks();
      
      final state = container.read(myNotifierProvider);
      expect(state.value, equals('new value'));
    });
  });
}
```

### Testing a Service

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('MyService', () {
    late MockDio mockDio;
    late MyService service;

    setUp(() {
      mockDio = MockDio();
      service = MyService(mockDio);
    });

    test('transforms API data correctly', () async {
      final apiResponse = {
        'message': [
          {'id': '1', 'name': 'Item 1', 'price': 100},
        ],
      };
      
      mockDio.setResponse('/api/items', apiResponse);
      
      final result = await service.getItems();
      
      expect(result, hasLength(1));
      expect(result[0]['id'], equals('1'));
      expect(result[0]['price'], equals(100.0));
    });
  });
}
```

## Continuous Improvement

### Regular Reviews
- Review test coverage monthly
- Update tests when requirements change
- Refactor tests to reduce duplication
- Keep test documentation current

### Test Metrics to Track
- **Coverage Percentage**: Aim for 70%+ overall
- **Test Execution Time**: Keep under 30 seconds for full suite
- **Flaky Test Rate**: Should be near 0%
- **Test Count Growth**: Should match code growth

### When Tests Fail
1. **Don't ignore** - Fix immediately
2. **Investigate root cause** - Not just symptoms
3. **Update test** if requirements changed
4. **Add more tests** if edge case found

## Resources

### Official Documentation
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)

### Recommended Reading
- "Test-Driven Development" by Kent Beck
- "Working Effectively with Legacy Code" by Michael Feathers
- "Growing Object-Oriented Software, Guided by Tests" by Freeman & Pryce

### Tools
- **flutter_test**: Official Flutter testing package
- **mockito/mocktail**: Mocking frameworks
- **golden_toolkit**: Golden file testing
- **integration_test**: E2E testing

## Conclusion

Good tests are:
- **Clear**: Easy to understand what is being tested
- **Comprehensive**: Cover success, failure, and edge cases
- **Maintainable**: Easy to update when code changes
- **Fast**: Execute quickly to enable rapid feedback
- **Reliable**: Produce consistent results

Remember: **Tests are documentation**. They show how the code should be used and what it guarantees.

---

*Last Updated: 2025-10-10*

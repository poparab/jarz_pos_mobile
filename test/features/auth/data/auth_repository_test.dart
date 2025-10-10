import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();
  
  group('AuthRepository', () {
    late MockDio mockDio;
    late MockSessionManager mockSessionManager;
    late AuthRepository authRepository;

    setUp(() {
      mockDio = MockDio();
      mockSessionManager = MockSessionManager();
      authRepository = AuthRepository(mockDio, mockSessionManager);
    });

    group('login', () {
      test('returns true on successful login', () async {
        mockDio.setResponse(
          '/api/method/login',
          createSuccessResponse(data: {'message': 'Logged In'}),
        );

        final result = await authRepository.login('testuser', 'testpass');
        
        expect(result, isTrue);
      });

      test('sends correct credentials in request', () async {
        mockDio.setResponse(
          '/api/method/login',
          createSuccessResponse(data: {'message': 'Logged In'}),
        );

        await authRepository.login('testuser', 'testpass');
        
        final requests = mockDio.requestLog;
        expect(requests, hasLength(1));
        expect(requests.first['method'], equals('POST'));
        expect(requests.first['path'], equals('/api/method/login'));
        expect(requests.first['data'], equals({'usr': 'testuser', 'pwd': 'testpass'}));
      });

      test('returns false on 401 unauthorized', () async {
        mockDio.setError(
          '/api/method/login',
          createMockDioException(
            statusCode: 401,
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await authRepository.login('wrong', 'credentials');
        
        expect(result, isFalse);
      });

      test('returns false when response status is not 200', () async {
        mockDio.setResponse(
          '/api/method/login',
          createSuccessResponse(data: {'message': 'Error'}),
          statusCode: 400,
        );

        final result = await authRepository.login('testuser', 'testpass');
        
        expect(result, isFalse);
      });

      test('rethrows non-401 DioExceptions', () async {
        mockDio.setError(
          '/api/method/login',
          createMockDioException(
            statusCode: 500,
            message: 'Server error',
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => authRepository.login('testuser', 'testpass'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('validateSession', () {
      test('returns true when session is valid', () async {
        mockDio.setResponse(
          '/api/method/frappe.auth.get_logged_user',
          createSuccessResponse(data: {'message': 'test@example.com'}),
        );

        final result = await authRepository.validateSession();
        
        expect(result, isTrue);
      });

      test('returns false when session is invalid', () async {
        mockDio.setError(
          '/api/method/frappe.auth.get_logged_user',
          createMockDioException(statusCode: 401),
        );

        final result = await authRepository.validateSession();
        
        expect(result, isFalse);
      });

      test('returns false when response data is null', () async {
        mockDio.setResponse(
          '/api/method/frappe.auth.get_logged_user',
          null,
        );

        final result = await authRepository.validateSession();
        
        expect(result, isFalse);
      });

      test('returns false on network errors', () async {
        mockDio.setError(
          '/api/method/frappe.auth.get_logged_user',
          createMockDioException(
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          ),
        );

        final result = await authRepository.validateSession();
        
        expect(result, isFalse);
      });
    });

    group('logout', () {
      test('clears session and cookies', () async {
        mockDio.setResponse(
          '/api/method/logout',
          createSuccessResponse(data: {'message': 'Logged out'}),
        );
        
        await mockSessionManager.saveSessionId('test-session');
        await authRepository.logout();
        
        final sessionId = await mockSessionManager.getSessionId();
        expect(sessionId, isNull);
      });

      test('clears session even on logout API error', () async {
        mockDio.setError(
          '/api/method/logout',
          createMockDioException(message: 'Network error'),
        );
        
        await mockSessionManager.saveSessionId('test-session');
        await authRepository.logout();
        
        final sessionId = await mockSessionManager.getSessionId();
        expect(sessionId, isNull);
      });

      test('calls logout API endpoint', () async {
        mockDio.setResponse(
          '/api/method/logout',
          createSuccessResponse(data: {}),
        );

        await authRepository.logout();
        
        final requests = mockDio.requestLog;
        expect(requests.any((r) => r['path'] == '/api/method/logout'), isTrue);
      });
    });
  });
}

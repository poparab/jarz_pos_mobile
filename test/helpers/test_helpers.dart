import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Test helper functions and utilities for common test scenarios

/// Creates a mock Dio instance with base options
Dio createMockDio() {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
}

/// Creates a ProviderContainer with common overrides for testing
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}

/// Flushes microtasks to ensure all async operations complete
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

/// Creates a mock Flutter Secure Storage for testing
FlutterSecureStorage createMockSecureStorage() {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}

/// Helper to create test response data
Map<String, dynamic> createSuccessResponse({
  required dynamic data,
  String message = 'Success',
}) {
  return {
    'success': true,
    'data': data,
    'message': message,
  };
}

/// Helper to create test error response
Map<String, dynamic> createErrorResponse({
  required String error,
  int? statusCode,
}) {
  return {
    'success': false,
    'error': error,
    if (statusCode != null) 'statusCode': statusCode,
  };
}

/// Creates a mock Response object
Response<T> createMockResponse<T>({
  required T data,
  int statusCode = 200,
  String? statusMessage,
  Map<String, dynamic>? headers,
}) {
  return Response(
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage,
    requestOptions: RequestOptions(path: '/test'),
    headers: Headers.fromMap(headers ?? {}),
  );
}

/// Creates a mock DioException
DioException createMockDioException({
  String message = 'Network error',
  int? statusCode,
  DioExceptionType type = DioExceptionType.unknown,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    message: message,
    response: statusCode != null
        ? Response(
            statusCode: statusCode,
            requestOptions: RequestOptions(path: '/test'),
          )
        : null,
  );
}

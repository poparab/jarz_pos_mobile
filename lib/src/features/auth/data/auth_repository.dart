import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/network/cookie_manager.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthRepository {
  AuthRepository(this._dio, this._sessionManager);

  final Dio _dio;
  final SessionManager _sessionManager;

  Future<bool> login(String username, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 AUTH: Attempting login for user: $username');
      }
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'usr': username, 'pwd': password},
      );
      if (kDebugMode) {
        debugPrint('🔐 AUTH: Login response status: ${response.statusCode}');
        debugPrint('🔐 AUTH: Login response data: ${response.data}');
      }
      
      if (response.statusCode == 200) {
        // ERPNext returns {"message": "Logged In"} on success
        // Session cookie is automatically stored by SessionInterceptor
        if (kDebugMode) {
          debugPrint('🔐 AUTH: Login successful');
        }
        return true;
      }
      if (kDebugMode) {
        debugPrint('🔐 AUTH: Login failed - unexpected status code');
      }
      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('🔐 AUTH: Login DioException - type: ${e.type}, statusCode: ${e.response?.statusCode}');
        debugPrint('🔐 AUTH: Login error message: ${e.message}');
        debugPrint('🔐 AUTH: Login error response: ${e.response?.data}');
      }
      if (e.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔐 AUTH: Login unexpected error: $e');
        debugPrint('🔐 AUTH: Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<bool> validateSession() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getLoggedUser,
      );
      return response.statusCode == 200 && response.data != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _sessionManager.clearSession();
      await CookieManager.clearCookies();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return AuthRepository(dio, sessionManager);
});

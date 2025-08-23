import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/session/session_manager.dart';

class AuthRepository {
  AuthRepository(this._dio, this._sessionManager);

  final Dio _dio;
  final SessionManager _sessionManager;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/method/login',
        data: {'usr': username, 'pwd': password},
      );
      if (response.statusCode == 200) {
        // ERPNext returns {"message": "Logged In"} on success
        // Session cookie is automatically stored by SessionInterceptor
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> validateSession() async {
    try {
      final response = await _dio.post(
        '/api/method/frappe.auth.get_logged_user',
      );
      return response.statusCode == 200 && response.data != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/method/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _sessionManager.clearSession();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return AuthRepository(dio, sessionManager);
});

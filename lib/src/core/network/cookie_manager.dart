import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieManager {
  static const _storage = FlutterSecureStorage();
  static const _cookieKey = 'session_cookies';
  static const _sessionIdKey = 'session_id';

  static Future<void> saveCookies(Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      await _storage.write(key: _cookieKey, value: cookies.join('; '));
      
      // Extract session ID from cookies
      for (final cookie in cookies) {
        if (cookie.startsWith('sid=')) {
          final sessionId = cookie.split(';')[0].split('=')[1];
          await _storage.write(key: _sessionIdKey, value: sessionId);
          break;
        }
      }
    }
  }

  static Future<String?> loadCookies() async {
    return await _storage.read(key: _cookieKey);
  }

  static Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }

  static Future<void> clearCookies() async {
    await _storage.deleteAll();
  }

  static Future<void> attachCookiesToRequest(RequestOptions options) async {
    final cookies = await loadCookies();
    if (cookies != null) {
      options.headers['Cookie'] = cookies;
    }
  }

  static Future<bool> hasValidSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }
}

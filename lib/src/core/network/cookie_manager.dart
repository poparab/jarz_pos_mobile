import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieManager {
  static const _storage = FlutterSecureStorage();
  static const _cookieKey = 'session_cookies';
  static const _sessionIdKey = 'session_id';

  static Future<void> saveCookies(Response response) async {
    try {
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
    } catch (e) {
      print('⚠️ CookieManager.saveCookies error: $e');
      // Continue without saving - session will work via response headers
    }
  }

  static Future<String?> loadCookies() async {
    try {
      return await _storage.read(key: _cookieKey);
    } catch (e) {
      print('⚠️ CookieManager.loadCookies error: $e');
      return null;
    }
  }

  static Future<String?> getSessionId() async {
    try {
      return await _storage.read(key: _sessionIdKey);
    } catch (e) {
      print('⚠️ CookieManager.getSessionId error: $e');
      return null;
    }
  }

  static Future<void> clearCookies() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('⚠️ CookieManager.clearCookies error: $e');
    }
  }

  static Future<void> attachCookiesToRequest(RequestOptions options) async {
    try {
      final cookies = await loadCookies();
      if (cookies != null) {
        options.headers['Cookie'] = cookies;
      }
    } catch (e) {
      print('⚠️ CookieManager.attachCookiesToRequest error: $e');
      // Continue without cookies rather than blocking the request
    }
  }

  static Future<bool> hasValidSession() async {
    try {
      final sessionId = await getSessionId();
      return sessionId != null && sessionId.isNotEmpty;
    } catch (e) {
      print('⚠️ CookieManager.hasValidSession error: $e');
      return false;
    }
  }
}

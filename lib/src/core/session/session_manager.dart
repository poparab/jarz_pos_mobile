import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionManager {
  static const _sessionKey = 'erpnext_session_id';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getSessionId() async {
    try {
      return await _storage.read(key: _sessionKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionKey, value: sessionId);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }

  Future<bool> hasValidSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

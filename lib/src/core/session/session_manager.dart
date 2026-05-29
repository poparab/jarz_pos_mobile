import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_keys.dart';

class SessionManager {
  static const _sessionKey = SecureStorageKeys.erpnextSessionId;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> getSessionId() async {
    if (kIsWeb) {
      return null;
    }

    try {
      return await _storage.read(key: _sessionKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSessionId(String sessionId) async {
    if (kIsWeb) {
      return;
    }

    try {
      await _storage.write(key: _sessionKey, value: sessionId);
    } catch (_) {}
  }

  Future<void> clearSession() async {
    if (kIsWeb) {
      return;
    }

    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }

  Future<bool> hasValidSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

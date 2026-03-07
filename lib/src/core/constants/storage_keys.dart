/// Persistent-storage key strings (FlutterSecureStorage, Hive, SharedPreferences,
/// MethodChannel) collected in one place to prevent typos and key collisions.
library;

// ── FlutterSecureStorage ────────────────────────────────────────────────
abstract final class SecureStorageKeys {
  static const erpnextSessionId = 'erpnext_session_id';
  static const sessionCookies = 'session_cookies';
  static const sessionId = 'session_id';
}

// ── Hive box names ──────────────────────────────────────────────────────
abstract final class HiveBoxes {
  static const offlineQueue = 'offline_queue';
  static const printerPrefs = 'pos_printer_prefs';
  static const inventoryCount = 'inventory_count';
  static const appSettings = 'app_settings';
}

// ── Hive keys (within their boxes) ──────────────────────────────────────
abstract final class HiveKeys {
  static const lastPrinterId = 'last_printer_id';
  static const lastPrinterType = 'last_printer_type';
  static const preferredLocale = 'preferred_locale';
}

// ── SharedPreferences keys ──────────────────────────────────────────────
abstract final class PrefKeys {
  static const alarmSoundUri = 'alarm_sound_uri';
  static const alarmSoundTitle = 'alarm_sound_title';
  static const orderAlertLastToken = 'order_alert_last_token';
  static const orderAlertLastUser = 'order_alert_last_user';
  static const orderAlertLastProfiles = 'order_alert_last_profiles';
  static const orderAlertGlobalMute = 'order_alert_global_mute';
}

// ── MethodChannel names ─────────────────────────────────────────────────
abstract final class MethodChannels {
  static const orderAlertNative = 'order_alert_native';
  static const classicPrinter = 'classic_printer';
}

/// Centralised timeout / polling / debounce durations.
///
/// Gather every `Duration(…)` literal here so timing tweaks are one-line changes.
abstract final class NetworkTimeouts {
  static const httpConnect = Duration(seconds: 30);
  static const httpReceive = Duration(seconds: 30);
  static const httpSend = Duration(seconds: 30);
  static const wsHeartbeat = Duration(seconds: 30);
  static const wsReconnectDelay = Duration(seconds: 5);
}

abstract final class PollingIntervals {
  static const connectivity = Duration(seconds: 10);
  static const orderAlert = Duration(seconds: 10);
  static const offlineSync = Duration(minutes: 1);
  static const overlayPoll = Duration(seconds: 2);
  static const notificationPollDefault = Duration(seconds: 30);
  static const waitForProfiles = Duration(seconds: 8);
}

abstract final class BluetoothTimeouts {
  static const scan = Duration(seconds: 4);
  static const defaultScan = Duration(seconds: 8);
  static const connect = Duration(seconds: 10);
}

abstract final class UiDebounce {
  static const customerSearch = Duration(milliseconds: 300);
  static const courierBridge = Duration(milliseconds: 250);
}

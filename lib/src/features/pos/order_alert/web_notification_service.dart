// Conditional export for platform-specific implementations
// Uses stub (no-op) on mobile platforms, full implementation on web
export 'web_notification_service_stub.dart'
    if (dart.library.html) 'web_notification_service_web.dart';

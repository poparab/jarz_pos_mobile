import "package:flutter/foundation.dart";
import "package:intl/intl.dart";

/// Log level enum
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// A simple logging utility class for the Jarz POS application.
class Logger {
  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  
  /// The tag/category for this logger instance
  final String tag;

  /// Creates a new logger with the specified tag
  Logger(this.tag);

  /// Log a debug message
  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// Log an info message
  void info(String message) {
    _log(LogLevel.info, message);
  }

  /// Log a warning message
  void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// Log an error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message);
    if (error != null) {
      _log(LogLevel.error, "Error details: $error");
    }
    if (stackTrace != null) {
      _log(LogLevel.error, "Stack trace: $stackTrace");
    }
  }

  /// Internal logging method
  void _log(LogLevel level, String message) {
    if (kDebugMode) {
      final timestamp = _dateFormat.format(DateTime.now());
      final levelStr = level.toString().split(".").last.toUpperCase();
      debugPrint("[$timestamp] $levelStr [$tag] $message");
    }
  }

  /// Create a child logger with an extended tag
  Logger child(String childTag) {
    return Logger("$tag.$childTag");
  }
}

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../monitoring/sentry_service.dart';
import '../network/frappe_error_message.dart';

class AppErrorRecord {
  const AppErrorRecord({
    required this.timestamp,
    required this.source,
    required this.message,
    required this.details,
    this.summary,
    this.stackTrace,
    this.fatal = false,
    this.occurrences = 1,
  });

  final DateTime timestamp;
  final String source;
  final String message;
  final String? summary;
  final String? stackTrace;
  final Map<String, Object?> details;
  final bool fatal;
  final int occurrences;

  AppErrorRecord copyWith({
    DateTime? timestamp,
    String? source,
    String? message,
    String? summary,
    String? stackTrace,
    Map<String, Object?>? details,
    bool? fatal,
    int? occurrences,
  }) {
    return AppErrorRecord(
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      message: message ?? this.message,
      summary: summary ?? this.summary,
      stackTrace: stackTrace ?? this.stackTrace,
      details: details ?? this.details,
      fatal: fatal ?? this.fatal,
      occurrences: occurrences ?? this.occurrences,
    );
  }

  String toClipboardText() {
    final buffer = StringBuffer()
      ..writeln('Time: ${timestamp.toIso8601String()}')
      ..writeln('Source: $source')
      ..writeln('Fatal: $fatal')
      ..writeln('Occurrences: $occurrences')
      ..writeln('Message: $message');

    if (summary != null && summary != message) {
      buffer.writeln('Summary: $summary');
    }

    if (details.isNotEmpty) {
      buffer
        ..writeln('Details:')
        ..writeln(const JsonEncoder.withIndent('  ').convert(details));
    }

    if (stackTrace != null && stackTrace!.trim().isNotEmpty) {
      buffer
        ..writeln('Stack trace:')
        ..writeln(stackTrace);
    }

    return buffer.toString().trimRight();
  }
}

class AppErrorReporter extends ChangeNotifier {
  AppErrorReporter._();

  static final AppErrorReporter instance = AppErrorReporter._();
  static const int _maxRecords = 40;

  final List<AppErrorRecord> _records = <AppErrorRecord>[];

  UnmodifiableListView<AppErrorRecord> get records =>
      UnmodifiableListView<AppErrorRecord>(_records);

  AppErrorRecord? get latest => _records.isEmpty ? null : _records.last;

  bool get hasRecords => _records.isNotEmpty;

  void clear() {
    if (_records.isEmpty) {
      return;
    }
    _records.clear();
    notifyListeners();
  }

  AppErrorRecord recordMessage({
    required String source,
    required String message,
    String? summary,
    StackTrace? stackTrace,
    Map<String, Object?> details = const <String, Object?>{},
    bool fatal = false,
  }) {
    final record = AppErrorRecord(
      timestamp: DateTime.now(),
      source: source,
      message: extractFrappeErrorMessage(message, fallback: message),
      summary: summary,
      stackTrace: _stackToString(stackTrace),
      details: _sanitizeMap(details),
      fatal: fatal,
    );
    if (_append(record)) {
      unawaited(
        SentryService.instance.captureMessage(
          source: source,
          message: record.message,
          summary: summary,
          stackTrace: stackTrace,
          details: record.details,
          fatal: fatal,
        ),
      );
    }
    return record;
  }

  AppErrorRecord capture({
    required String source,
    required Object error,
    StackTrace? stackTrace,
    String? summary,
    Map<String, Object?> details = const <String, Object?>{},
    bool fatal = false,
  }) {
    final mergedDetails = <String, Object?>{
      ..._extractErrorDetails(error),
      ...details,
    };

    final record = AppErrorRecord(
      timestamp: DateTime.now(),
      source: source,
      message: extractFrappeErrorMessage(error, fallback: error.toString()),
      summary: summary,
      stackTrace: _stackToString(stackTrace),
      details: _sanitizeMap(mergedDetails),
      fatal: fatal,
    );
    if (_append(record)) {
      unawaited(
        SentryService.instance.captureException(
          source: source,
          error: error,
          stackTrace: stackTrace,
          summary: summary,
          details: record.details,
          fatal: fatal,
        ),
      );
    }
    return record;
  }

  void captureFlutterError(
    FlutterErrorDetails details, {
    String source = 'FlutterError',
  }) {
    final information = details.informationCollector
        ?.call()
        .map((node) => node.toDescription())
        .where((line) => line.trim().isNotEmpty)
        .join('\n');

    capture(
      source: source,
      error: details.exception,
      stackTrace: details.stack,
      summary: details.context?.toDescription(),
      fatal: true,
      details: <String, Object?>{
        if (details.library != null) 'library': details.library,
        if (details.context != null)
          'context': details.context!.toDescription(),
        if (information != null && information.isNotEmpty)
          'information': information,
      },
    );
  }

  bool _append(AppErrorRecord record) {
    if (_records.isNotEmpty) {
      final last = _records.last;
      final sameRecord =
          last.source == record.source &&
          last.message == record.message &&
          last.summary == record.summary &&
          last.stackTrace == record.stackTrace &&
          record.timestamp.difference(last.timestamp).inSeconds <= 2;

      if (sameRecord) {
        _records[_records.length - 1] = last.copyWith(
          timestamp: record.timestamp,
          details: <String, Object?>{...last.details, ...record.details},
          fatal: last.fatal || record.fatal,
          occurrences: last.occurrences + 1,
        );
        notifyListeners();
        return false;
      }
    }

    _records.add(record);
    if (_records.length > _maxRecords) {
      _records.removeRange(0, _records.length - _maxRecords);
    }
    notifyListeners();
    return true;
  }

  Map<String, Object?> _extractErrorDetails(Object error) {
    if (error is DioException) {
      return <String, Object?>{
        'dioType': error.type.name,
        'method': error.requestOptions.method,
        'path': error.requestOptions.path,
        if (error.response?.statusCode != null)
          'statusCode': error.response!.statusCode,
        if (error.message != null && error.message!.trim().isNotEmpty)
          'dioMessage': error.message!.trim(),
        if (error.requestOptions.queryParameters.isNotEmpty)
          'queryParameters': error.requestOptions.queryParameters,
        if (error.requestOptions.data != null)
          'requestData': error.requestOptions.data,
        if (error.response?.data != null) 'responseData': error.response!.data,
      };
    }

    return const <String, Object?>{};
  }

  Map<String, Object?> _sanitizeMap(Map<String, Object?> values) {
    final sanitized = <String, Object?>{};
    for (final entry in values.entries) {
      sanitized[entry.key] = _sanitizeValue(entry.key, entry.value);
    }
    return sanitized;
  }

  Object? _sanitizeValue(String key, Object? value) {
    if (_isSensitiveKey(key)) {
      return '<redacted>';
    }

    if (value == null || value is num || value is bool) {
      return value;
    }

    if (value is String) {
      return _truncate(value);
    }

    if (value is Map) {
      final nested = <String, Object?>{};
      for (final entry in value.entries) {
        nested[entry.key.toString()] = _sanitizeValue(
          entry.key.toString(),
          entry.value as Object?,
        );
      }
      return nested;
    }

    if (value is Iterable) {
      return value
          .take(20)
          .map((item) => _sanitizeValue(key, item as Object?))
          .toList(growable: false);
    }

    return _truncate(value.toString());
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('password') ||
        normalized.contains('authorization') ||
        normalized.contains('cookie') ||
        normalized == 'sid' ||
        normalized.contains('secret') ||
        normalized.contains('token');
  }

  String _truncate(String value, {int maxLength = 4000}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}...<truncated>';
  }

  String? _stackToString(StackTrace? stackTrace) {
    final value = stackTrace?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}

class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppErrorReporter.instance.capture(
      source: 'Riverpod:${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      summary: 'Provider evaluation failed',
    );
  }
}

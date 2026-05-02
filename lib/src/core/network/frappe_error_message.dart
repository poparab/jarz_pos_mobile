import 'dart:convert';

import 'package:dio/dio.dart';

String extractFrappeErrorMessage(
  Object error, {
  String fallback = 'Request failed',
}) {
  final message = switch (error) {
    DioException dioError => _extractDioMessage(dioError),
    _ => _extractFromValue(error),
  };

  if (message == null || message.isEmpty || _looksGeneric(message)) {
    return fallback;
  }

  return message;
}

Exception mapFrappeError(
  Object error, {
  String fallback = 'Request failed',
}) {
  return Exception(extractFrappeErrorMessage(error, fallback: fallback));
}

String? _extractDioMessage(DioException error) {
  final payloadMessage = _extractFromValue(error.response?.data);
  if (payloadMessage != null && payloadMessage.isNotEmpty) {
    return payloadMessage;
  }

  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Network connection failed. Please try again.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badCertificate:
      return 'Secure connection failed. Please try again.';
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final dioMessage = _extractFromValue(error.message);
  if (dioMessage != null && dioMessage.isNotEmpty && !_looksGeneric(dioMessage)) {
    return dioMessage;
  }

  final statusCode = error.response?.statusCode;
  if (statusCode != null) {
    return 'Request failed ($statusCode).';
  }

  return null;
}

String? _extractFromValue(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is Map) {
    for (final key in const [
      'message',
      'error',
      '_error_message',
      '_server_messages',
      'exception',
      'exc',
    ]) {
      final candidate = _extractFromValue(value[key]);
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  if (value is List) {
    for (final item in value) {
      final candidate = _extractFromValue(item);
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  return _normalizeMessage(value.toString());
}

String? _normalizeMessage(String raw) {
  var text = raw.trim();
  if (text.isEmpty) {
    return null;
  }

  final decoded = _tryDecodeJsonPayload(text);
  if (decoded != null) {
    final candidate = _extractFromValue(decoded);
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
  }

  final lines = text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (text.contains('Traceback') && lines.isNotEmpty) {
    text = lines.last;
  }

  text = text.replaceFirst(
    RegExp(r'^(?:Exception|Error):\s*', caseSensitive: false),
    '',
  );
  text = text.replaceFirst(
    RegExp(r'^DioException\s*\[[^\]]+\]\s*:\s*', caseSensitive: false),
    '',
  );
  text = text.replaceFirst(
    RegExp(r'^(?:frappe\.exceptions\.)?[A-Za-z0-9_.]+:\s*'),
    '',
  );

  text = _stripHtml(text);
  text = _decodeHtmlEntities(text);
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  return text.isEmpty ? null : text;
}

dynamic _tryDecodeJsonPayload(String raw) {
  final startsWithJson = raw.startsWith('{') || raw.startsWith('[');
  if (!startsWithJson) {
    return null;
  }

  try {
    return jsonDecode(raw);
  } catch (_) {
    return null;
  }
}

String _stripHtml(String input) {
  return input.replaceAll(RegExp(r'<[^>]+>'), ' ');
}

String _decodeHtmlEntities(String input) {
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
  };

  var output = input;
  entities.forEach((entity, replacement) {
    output = output.replaceAll(entity, replacement);
  });
  return output;
}

bool _looksGeneric(String message) {
  final normalized = message.trim().toLowerCase();
  return normalized.isEmpty ||
      normalized == 'bad response' ||
      normalized == 'null' ||
      normalized == 'exception' ||
      normalized.startsWith('dioexception') ||
  normalized.startsWith('request failed (') ||
      normalized.contains('status code of') ||
      normalized.contains('request failed with status');
}
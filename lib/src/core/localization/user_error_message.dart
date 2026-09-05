import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

/// Resolves a technical failure to a short, safe message for a POS user.
///
/// The diagnostics path deliberately remains separate from this presenter.
/// Callers should keep the original [error] for logging and pass it here only
/// for the text that is shown in the UI.
extension UserErrorMessageX on BuildContext {
  String userErrorMessage(Object? error, {String? fallback}) {
    return userErrorMessageFor(
      AppLocalizations.of(this),
      error,
      fallback: fallback,
    );
  }
}

/// Pure form for callers that capture localizations before an asynchronous task.
String userErrorMessageFor(
  AppLocalizations l10n,
  Object? error, {
  String? fallback,
}) {
  // Presenter output may pass through a shared error panel a second time.
  final knownMessages = <String>{
    l10n.userErrorOffline,
    l10n.userErrorTimeout,
    l10n.userErrorCertificate,
    l10n.userErrorCancelled,
    l10n.userErrorUnauthorized,
    l10n.userErrorForbidden,
    l10n.userErrorNotFound,
    l10n.userErrorConflict,
    l10n.userErrorRateLimited,
    l10n.userErrorServer,
    l10n.userErrorUnexpected,
    l10n.userErrorValidationFallback,
    l10n.authInvalidCredentials,
    l10n.appUpdateRequiredBody,
    l10n.userErrorDraftLimit,
    l10n.userErrorReopenOrder,
    l10n.userErrorShippingAddress,
    l10n.userErrorInsufficientStock,
    l10n.userErrorShiftRequired,
    l10n.userErrorAlreadyProcessed,
    l10n.userErrorRequiredFields,
    l10n.manufacturingQuantityMustBePositive,
    l10n.checkoutSelectProfileFirst,
    l10n.posCartEmptyBody,
  };
  if (error is String && knownMessages.contains(error)) return error;
  final category = _classify(error);
  if (error is! Error &&
      (category == _UserErrorCategory.unknown ||
          category == _UserErrorCategory.validation ||
          category == _UserErrorCategory.notFound)) {
    final businessMessage = _businessMessage(l10n, _firstCandidate(error));
    if (businessMessage != null) return businessMessage;
  }
  switch (category) {
    case _UserErrorCategory.offline:
      return l10n.userErrorOffline;
    case _UserErrorCategory.timeout:
      return l10n.userErrorTimeout;
    case _UserErrorCategory.certificate:
      return l10n.userErrorCertificate;
    case _UserErrorCategory.cancelled:
      return l10n.userErrorCancelled;
    case _UserErrorCategory.unauthorized:
      return l10n.userErrorUnauthorized;
    case _UserErrorCategory.invalidCredentials:
      return l10n.authInvalidCredentials;
    case _UserErrorCategory.upgradeRequired:
      return l10n.appUpdateRequiredBody;
    case _UserErrorCategory.forbidden:
      return l10n.userErrorForbidden;
    case _UserErrorCategory.notFound:
      return l10n.userErrorNotFound;
    case _UserErrorCategory.conflict:
      return l10n.userErrorConflict;
    case _UserErrorCategory.rateLimited:
      return l10n.userErrorRateLimited;
    case _UserErrorCategory.server:
      return l10n.userErrorServer;
    case _UserErrorCategory.validation:
      return _validationMessage(l10n, error) ??
          l10n.userErrorValidationFallback;
    case _UserErrorCategory.unknown:
      return _curatedMessage(l10n, error) ?? _safeFallback(l10n, fallback);
  }
}

/// Some services wrap a business refusal in `Exception(message)`. Only retain
/// that message when it matches a known business rule or has the shape of a
/// short validation sentence. An Exception wrapper by itself is not a trust
/// signal.
String? _curatedMessage(AppLocalizations l10n, Object? error) {
  if (error == null || error is Error || error is DioException) return null;
  if (error is! Exception) return null;
  final candidate = _firstCandidate(error);
  if (candidate == null || !_isSafeUserText(candidate)) return null;
  final business = _businessMessage(l10n, candidate);
  if (business != null) return business;
  if (!_looksLikeValidation(candidate)) return null;
  if (_isArabic(l10n) &&
      (!_containsArabic(candidate) || _containsEnglish(candidate))) {
    return null;
  }
  return candidate;
}

enum _UserErrorCategory {
  offline,
  timeout,
  certificate,
  cancelled,
  unauthorized,
  invalidCredentials,
  upgradeRequired,
  forbidden,
  notFound,
  conflict,
  rateLimited,
  server,
  validation,
  unknown,
}

_UserErrorCategory _classify(Object? error) {
  if (error is DioException) {
    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return _UserErrorCategory.timeout;
    }
    if (type == DioExceptionType.cancel) {
      return _UserErrorCategory.cancelled;
    }
    if (type == DioExceptionType.badCertificate) {
      return _UserErrorCategory.certificate;
    }

    final status = error.response?.statusCode;
    final payload = _rawErrorText(error.response?.data)?.toLowerCase() ?? '';
    if (payload.contains('not whitelisted') || payload.contains('cmd=none')) {
      return _UserErrorCategory.server;
    }
    final statusCategory = _categoryForStatus(status);
    if (statusCategory != null) {
      return statusCategory;
    }
    if (type == DioExceptionType.connectionError) {
      return _UserErrorCategory.offline;
    }
    return _classifyText(error.message) == _UserErrorCategory.unknown
        ? _classifyText(_firstCandidate(error.response?.data))
        : _classifyText(error.message);
  }

  final statusCategory = _categoryForStatus(_statusFromValue(error));
  return statusCategory ?? _classifyText(_rawErrorText(error));
}

_UserErrorCategory? _categoryForStatus(int? status) {
  if (status == null) return null;
  if (status == 401) return _UserErrorCategory.unauthorized;
  if (status == 403) return _UserErrorCategory.forbidden;
  if (status == 404) return _UserErrorCategory.notFound;
  if (status == 409) return _UserErrorCategory.conflict;
  if (status == 408) return _UserErrorCategory.timeout;
  if (status == 426) return _UserErrorCategory.upgradeRequired;
  if (status == 429) return _UserErrorCategory.rateLimited;
  if (status >= 500 && status <= 599) return _UserErrorCategory.server;
  if (status == 400 || status == 417 || status == 422) {
    return _UserErrorCategory.validation;
  }
  return null;
}

_UserErrorCategory _classifyText(String? text) {
  if (text == null) return _UserErrorCategory.unknown;
  final value = text.toLowerCase();

  if (_hasAny(value, const [
    'invalid credentials',
    'incorrect password',
    'invalid login',
  ])) {
    return _UserErrorCategory.invalidCredentials;
  }
  if (_hasAny(value, const [
    'status code of 426',
    'upgrade required',
    'app_upgrade_required',
  ])) {
    return _UserErrorCategory.upgradeRequired;
  }

  if (_hasAny(value, const [
    'timeout',
    'timed out',
    'time out',
    'deadline exceeded',
  ])) {
    return _UserErrorCategory.timeout;
  }
  if (_hasAny(value, const [
    'certificate',
    'cert_verify_failed',
    'secure connection',
    'ssl handshake',
    'tls handshake',
  ])) {
    return _UserErrorCategory.certificate;
  }
  if (_hasAny(value, const ['cancelled', 'canceled', 'request was aborted'])) {
    return _UserErrorCategory.cancelled;
  }
  if (_hasAny(value, const [
    'no internet',
    'network is unreachable',
    'network connection failed',
    'failed to connect',
    'failed host lookup',
    'connection refused',
    'connection reset',
    'connection error',
    'socketexception',
    'networkerror',
  ])) {
    return _UserErrorCategory.offline;
  }
  if (_hasAny(value, const [
    'unauthorized',
    'unauthenticated',
    'session has expired',
    'login to access',
    'please log in',
  ])) {
    return _UserErrorCategory.unauthorized;
  }
  if (_hasAny(value, const [
    'forbidden',
    'not permitted',
    'permissionerror',
    'permission denied',
    'do not have permission',
    'does not have permission',
  ])) {
    return _UserErrorCategory.forbidden;
  }
  if (_hasAny(value, const [
    'not found',
    'does not exist',
    'could not be found',
  ])) {
    return _UserErrorCategory.notFound;
  }
  if (_hasAny(value, const [
    'conflict',
    'already exists',
    'duplicate entry',
    'has been modified',
  ])) {
    return _UserErrorCategory.conflict;
  }
  if (_hasAny(value, const [
    'too many requests',
    'rate limit',
    'rate-limit',
    'status code 429',
    'http 429',
  ])) {
    return _UserErrorCategory.rateLimited;
  }
  if (_hasAny(value, const [
    'internal server error',
    'bad gateway',
    'service unavailable',
    'gateway timeout',
    'server error',
  ])) {
    return _UserErrorCategory.server;
  }
  if (_looksLikeValidation(text)) return _UserErrorCategory.validation;
  return _UserErrorCategory.unknown;
}

String? _validationMessage(AppLocalizations l10n, Object? error) {
  final candidate = _firstCandidate(error);
  if (candidate == null) return null;
  final business = _businessMessage(l10n, candidate);
  if (business != null) return business;
  // Frappe commonly sends ValidationError as HTTP 417, but status alone does
  // not make an arbitrary response body safe UI copy.
  if (!_looksLikeValidation(candidate)) return null;
  // An Arabic UI must not surface an English server sentence.
  if (_isArabic(l10n)) {
    return _containsArabic(candidate) && !_containsEnglish(candidate)
        ? candidate
        : null;
  }
  return candidate;
}

String? _businessMessage(AppLocalizations l10n, String? candidate) {
  if (candidate == null || !_isSafeUserText(candidate)) return null;
  final text = candidate.toLowerCase();
  if (text == 'cart is empty' || text.contains('cart cannot be empty'))
    return l10n.posCartEmptyBody;
  if (text == 'no profile selected' || text.contains('select a pos profile'))
    return l10n.checkoutSelectProfileFirst;
  if (text == 'draft_limit_reached') return l10n.userErrorDraftLimit;
  if (text.contains('amendment draft') ||
      text.startsWith('cannot submit amendment:'))
    return l10n.userErrorReopenOrder;
  if (text.contains('shipping address') &&
      _hasAny(text, const [
        'no longer',
        'not available',
        'not found',
        'invalid',
      ]))
    return l10n.userErrorShippingAddress;
  if (_hasAny(text, const [
    'insufficient stock',
    'not enough stock',
    'not enough material in wip',
    'negative stock',
    'exceeds available stock',
  ]))
    return l10n.userErrorInsufficientStock;
  if (text.contains('quantity') &&
      _hasAny(text, const ['greater than zero', 'positive']))
    return l10n.manufacturingQuantityMustBePositive;
  if (text.contains('shift') &&
      _hasAny(text, const ['closed', 'no active', 'not open']))
    return l10n.userErrorShiftRequired;
  if (_hasAny(text, const [
    'already submitted',
    'already paid',
    'already processed',
  ]))
    return l10n.userErrorAlreadyProcessed;
  if (RegExp(
    r'^(please (enter|select)|.+ (is|are) (required|mandatory)\.?$)',
  ).hasMatch(text))
    return l10n.userErrorRequiredFields;
  if (text.contains('amount') &&
      _hasAny(text, const ['invalid', 'positive', 'greater than zero']))
    return l10n.userErrorValidationFallback;
  return null;
}

String _safeFallback(AppLocalizations l10n, String? fallback) {
  final candidate = _cleanCandidate(fallback);
  if (candidate == null || !_isSafeUserText(candidate)) {
    return l10n.userErrorUnexpected;
  }
  if (_isArabic(l10n) &&
      (!_containsArabic(candidate) || _containsEnglish(candidate))) {
    return l10n.userErrorUnexpected;
  }
  return candidate;
}

bool _looksLikeValidation(String value) {
  final normalized = value.toLowerCase();
  if (!_isSafeUserText(value)) return false;
  if (_hasAny(normalized, const [
    'invalid argument',
    'invalid parameter',
    'invalid type',
    'bad state',
    'typeerror',
  ])) {
    return false;
  }
  return _hasAny(normalized, const [
    'required',
    'mandatory',
    'must ',
    'cannot be',
    'can\'t be',
    'invalid',
    'please enter',
    'please select',
    'quantity',
    'stock',
    'available',
    'balance',
    'closed',
    'already submitted',
    'مطلوب',
    'يجب',
    'غير صالح',
    'لا يمكن',
    'الكمية',
    'المخزون',
  ]);
}

bool _isSafeUserText(String value) {
  final text = value.trim();
  if (text.isEmpty || text.length > 240) return false;
  final lower = text.toLowerCase();
  if (_hasAny(lower, const [
    '<html',
    '<!doctype',
    'traceback',
    'stack trace',
    'exception:',
    'error:',
    'stateerror',
    'argumenterror',
    'typeerror',
    'formatexception',
    'databaseerror',
    'operationalerror',
    'programmingerror',
    'bad state:',
    'is not a subtype of type',
    'type cast',
    'caused by:',
    '#0 ',
    'dioexception',
    'sqlalchemy',
    'select * from',
    'insert into',
    'update ',
    'delete from',
    ' at package:',
    'http://',
    'https://',
    'status code of',
    'request failed with status',
  ])) {
    return false;
  }
  if (RegExp(
    r'\bselect\s+(?:distinct\s+)?[`"a-z0-9_.*]+(?:\s*,\s*[`"a-z0-9_.*]+)*\s+from\b',
    caseSensitive: false,
  ).hasMatch(text)) {
    return false;
  }
  return !RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]').hasMatch(text);
}

String? _firstCandidate(Object? value, [int depth = 0]) {
  if (value == null || depth > 5) return null;
  if (value is DioException) {
    return _firstCandidate(value.response?.data, depth + 1) ??
        _cleanCandidate(value.message, depth + 1);
  }
  if (value is Response<dynamic>) return _firstCandidate(value.data, depth + 1);
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    if (text.length > 6000) return null;
    final decoded = _decodeJson(text);
    if (decoded != null) return _firstCandidate(decoded, depth + 1);
    return _cleanCandidate(text, depth);
  }
  if (value is Map) {
    for (final key in const [
      'message',
      'error',
      'detail',
      '_error_message',
      '_server_messages',
      'errors',
      'exception',
      'exc',
      'data',
    ]) {
      final candidate = _firstCandidate(value[key], depth + 1);
      if (candidate != null) return candidate;
    }
    return null;
  }
  if (value is Iterable) {
    for (final item in value.take(10)) {
      final candidate = _firstCandidate(item, depth + 1);
      if (candidate != null) return candidate;
    }
    return null;
  }
  if (value is Exception) {
    // Remove Dart's exact wrapper only. The remaining text still has to pass
    // the business/validation checks; arbitrary textual Error/Exception class
    // prefixes are deliberately retained and rejected by _cleanCandidate.
    return _cleanCandidate(
      value.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      depth,
    );
  }
  return null;
}

String? _rawErrorText(Object? value) {
  if (value == null) return null;
  if (value is String)
    return value.length > 6000 ? value.substring(0, 6000) : value;
  final text = value.toString();
  return text.length > 6000 ? text.substring(0, 6000) : text;
}

dynamic _decodeJson(String value) {
  if (!(value.startsWith('{') || value.startsWith('['))) return null;
  try {
    return jsonDecode(value);
  } catch (_) {
    return null;
  }
}

String? _cleanCandidate(String? raw, [int depth = 0]) {
  if (raw == null || depth > 5) return null;
  var text = raw.trim();
  if (text.isEmpty || text.length > 6000) return null;
  // Frappe's ValidationError prefix is the one supported server wrapper. Do
  // not strip arbitrary Error/Exception classes: their names are useful
  // technical indicators and must reach the safety check.
  text = text.replaceFirst(
    RegExp(
      r'^(?:(?:frappe\.)?exceptions\.)?ValidationError:\s*',
      caseSensitive: false,
    ),
    '',
  );
  if (_hasTechnicalSignature(text)) return null;
  final decoded = _decodeJson(text);
  if (decoded != null) return _firstCandidate(decoded, depth + 1);
  text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text.isEmpty ? null : text;
}

int? _statusFromValue(Object? value) {
  if (value is Response<dynamic>) return value.statusCode;
  if (value is Map) {
    for (final key in const [
      'statusCode',
      'status_code',
      'httpStatus',
      'status',
    ]) {
      final raw = value[key];
      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw);
    }
  }
  return null;
}

bool _isArabic(AppLocalizations l10n) =>
    l10n.localeName.toLowerCase().startsWith('ar');

bool _containsArabic(String value) =>
    RegExp(r'[\u0600-\u06FF]').hasMatch(value);

bool _containsEnglish(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

bool _hasTechnicalSignature(String value) {
  final lower = value.toLowerCase();
  return _hasAny(lower, const [
    '<html',
    '<!doctype',
    'traceback',
    'stack trace',
    'dioexception',
    'sqlalchemy',
    'select * from',
    'insert into',
    'update ',
    'delete from',
    'stateerror',
    'argumenterror',
    'typeerror',
    'formatexception',
    'databaseerror',
    'operationalerror',
    'programmingerror',
    'exception:',
    'error:',
    'bad state:',
    'is not a subtype of type',
    'type cast',
    'caused by:',
    ' at package:',
    ' at dart:',
    'http://',
    'https://',
  ]);
}

bool _hasAny(String value, Iterable<String> needles) =>
    needles.any(value.contains);

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../models/attendance_models.dart';

/// The branch name, or an explicit label for the bucket that has none.
///
/// The `null` branch is a real answer from the server — check-ins it could not
/// attribute to any location. Rendering it as a blank heading is how "no
/// branch resolved" gets read as "a branch whose name failed to load", so it
/// is always spelled out.
String attendanceBranchLabel(BuildContext context, String? shiftLocation) {
  final value = shiftLocation?.trim() ?? '';
  return value.isEmpty ? context.l10n.attendanceNoBranchResolved : value;
}

/// A centred icon + sentence, for every empty and refused state on the feature.
class AttendanceMessageState extends StatelessWidget {
  const AttendanceMessageState({
    super.key,
    required this.icon,
    required this.message,
    this.detail,
    this.onRetry,
    this.tone = AttendanceMessageTone.neutral,
  });

  final IconData icon;
  final String message;
  final String? detail;
  final VoidCallback? onRetry;
  final AttendanceMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      AttendanceMessageTone.neutral => theme.colorScheme.outline,
      AttendanceMessageTone.warning => theme.colorScheme.tertiary,
      AttendanceMessageTone.error => theme.colorScheme.error,
    };
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: color),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.commonRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum AttendanceMessageTone { neutral, warning, error }

/// A failed request, turned into something a branch manager can act on.
///
/// A 403 is special-cased before the generic presenter: the backend answers a
/// scope refusal with an English `PermissionError`, and an Arabic UI drops
/// English server sentences on the floor — which is exactly how every refusal
/// on this app has historically ended up looking like a blank screen. So the
/// permission case is named here, in both languages, with the next step
/// attached.
class AttendanceErrorState extends StatelessWidget {
  const AttendanceErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  static bool isForbidden(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 403) return true;
      final payload = error.response?.data?.toString().toLowerCase() ?? '';
      return payload.contains('permissionerror') ||
          payload.contains('not permitted');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isForbidden(error)) {
      return AttendanceMessageState(
        icon: Icons.lock_outline,
        message: l10n.attendanceAccessDenied,
        detail: l10n.attendanceAccessDeniedHint,
        tone: AttendanceMessageTone.warning,
      );
    }
    // A `frappe.throw` refusal, such as a date range past the server's limit
    // if the client limit ever falls out of step with it. The shared presenter
    // would drop the English sentence in an Arabic UI and leave a generic
    // failure. Here the localized headline says what happened, and the
    // server's own words go underneath, readable even if untranslated.
    final serverMessage = attendanceServerValidationMessage(error);
    if (serverMessage != null) {
      return AttendanceMessageState(
        icon: Icons.rule,
        message: l10n.attendanceServerRefused,
        detail: '$serverMessage\n${l10n.attendanceServerRefusedHint}',
        tone: AttendanceMessageTone.warning,
        onRetry: onRetry,
      );
    }
    return AttendanceMessageState(
      icon: Icons.error_outline,
      message: context.userErrorMessage(error),
      detail: l10n.attendanceLoadFailedHint,
      tone: AttendanceMessageTone.error,
      onRetry: onRetry,
    );
  }
}

/// The plain-text message of a Frappe ValidationError, or null if [error] is
/// not one.
///
/// Frappe sends `frappe.throw` as HTTP 417, with the message in
/// `_server_messages`: a JSON string holding a list of JSON strings, each
/// with a `message`. Some paths only fill `exception`
/// (`"frappe.exceptions.ValidationError: <message>"`). Both are read. Markup
/// is removed and the text is capped, so a traceback can never fill the
/// screen.
String? attendanceServerValidationMessage(Object? error) {
  if (error is! DioException) return null;
  final status = error.response?.statusCode;
  final data = error.response?.data;
  final Map<String, dynamic>? body = switch (data) {
    Map() => Map<String, dynamic>.from(data),
    String() => _tryDecodeMap(data),
    _ => null,
  };
  final excType = body?['exc_type']?.toString() ?? '';
  final exception = body?['exception']?.toString() ?? '';
  final isValidation =
      status == 417 ||
      status == 422 ||
      excType == 'ValidationError' ||
      exception.contains('ValidationError');
  if (!isValidation || body == null) return null;

  final fromServerMessages = _firstServerMessage(body['_server_messages']);
  if (fromServerMessages != null) return fromServerMessages;

  // Checked on the whole line, before the prefix is cut off: a traceback's own
  // first line contains ": ", and cutting there would hide the evidence.
  if (exception.isNotEmpty && !exception.toLowerCase().contains('traceback')) {
    final colon = exception.indexOf(': ');
    final text = colon >= 0 ? exception.substring(colon + 2) : exception;
    final cleaned = _cleanServerText(text);
    if (cleaned != null) return cleaned;
  }
  final message = body['message'];
  return message is String ? _cleanServerText(message) : null;
}

String? _firstServerMessage(dynamic raw) {
  dynamic list = raw;
  if (list is String) list = _tryDecode(list);
  if (list is! List) return null;
  for (final item in list) {
    final decoded = item is String ? _tryDecode(item) : item;
    final text = decoded is Map
        ? decoded['message']?.toString()
        : (decoded is String ? decoded : null);
    final cleaned = _cleanServerText(text);
    if (cleaned != null) return cleaned;
  }
  return null;
}

String? _cleanServerText(String? raw) {
  if (raw == null) return null;
  var text = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.isEmpty) return null;
  if (text.toLowerCase().contains('traceback')) return null;
  return text.length > 240 ? '${text.substring(0, 239)}…' : text;
}

dynamic _tryDecode(String value) {
  try {
    return jsonDecode(value);
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _tryDecodeMap(String value) {
  final decoded = _tryDecode(value);
  return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
}

/// The server's own notice, shown verbatim.
///
/// Used when `hrms_available` is false: the endpoint degrades to
/// `{success, hrms_available: false, notice}` rather than raising, and the
/// notice is the only thing that explains why the screen is empty.
class AttendanceNoticeBanner extends StatelessWidget {
  const AttendanceNoticeBanner({super.key, required this.notice});

  final String notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Nobody clocked in at all in this period."
///
/// The honest default today: check-in is not yet in daily use, so a month of
/// `absent` cells means the data is missing, not that the whole team stayed
/// home. Without this banner the screen is a wall of red that reads as an
/// accusation, and the first person to see it correctly concludes the feature
/// is broken.
class AttendanceNoCheckinsBanner extends StatelessWidget {
  const AttendanceNoCheckinsBanner({super.key, this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: theme.colorScheme.tertiaryContainer,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: dense ? 6 : 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sensors_off,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.attendanceNoCheckins,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!dense)
                  Text(
                    l10n.attendanceNoCheckinsHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The empty/degraded cases every tab shares, decided in one place.
///
/// Returns null when there is nothing wrong and the tab should draw its data.
Widget? attendanceBlockingState(
  BuildContext context, {
  required bool hrmsAvailable,
  required String? notice,
  required AttendanceScope scope,
  required bool hasRows,
}) {
  final l10n = context.l10n;
  if (!hrmsAvailable) {
    return AttendanceMessageState(
      icon: Icons.info_outline,
      message: notice ?? l10n.attendanceHrmsMissing,
      detail: notice == null ? null : l10n.attendanceHrmsMissing,
    );
  }
  if (scope.isEmptyScope) {
    return AttendanceMessageState(
      icon: Icons.location_off_outlined,
      message: l10n.attendanceScopeEmpty,
      detail: l10n.attendanceScopeEmptyHint,
      tone: AttendanceMessageTone.warning,
    );
  }
  if (!hasRows) {
    return AttendanceMessageState(
      icon: Icons.event_busy_outlined,
      message: l10n.attendanceNobodyRostered,
      detail: l10n.attendanceNobodyRosteredHint,
    );
  }
  return null;
}

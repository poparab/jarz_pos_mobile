// The backend refuses with an `[error_code]` prefix; the app turns each code
// into its own Arabic sentence instead of showing the English server text.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_service.dart';
import 'package:jarz_pos/src/features/weekly_count/presentation/weekly_count_format.dart';

DioException _frappeError(Map<String, dynamic> body, {int status = 417}) {
  final options = RequestOptions(path: '/api/method/x');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: body),
    type: DioExceptionType.badResponse,
  );
}

/// What Frappe sends for `frappe.throw(...)`: a JSON list of JSON objects.
String _serverMessages(String message) => jsonEncode([
  jsonEncode({'message': message, 'indicator': 'red'}),
]);

void main() {
  group('code extraction', () {
    test('reads the code from _server_messages', () {
      final e = _frappeError({
        'exc_type': 'ValidationError',
        '_server_messages': _serverMessages(
          '[missing_items] Large Lotus, Small Oreo',
        ),
      });
      expect(weeklyCountErrorCode(e), WeeklyCountErrorCodes.missingItems);
      expect(weeklyCountErrorDetail(e), 'Large Lotus, Small Oreo');
    });

    test('reads the code from exception', () {
      final e = _frappeError({
        'exception':
            'frappe.exceptions.ValidationError: [already_done] Counted this week',
      });
      expect(weeklyCountErrorCode(e), WeeklyCountErrorCodes.alreadyDone);
    });

    test('reads the code from message', () {
      final e = _frappeError({'message': '[no_access] Not your branch'});
      expect(weeklyCountErrorCode(e), WeeklyCountErrorCodes.noAccess);
    });

    test('reads the code from a plain string or exception', () {
      expect(
        weeklyCountErrorCode('[reason_required] Give a reason'),
        WeeklyCountErrorCodes.reasonRequired,
      );
      expect(
        weeklyCountErrorCode(Exception('[invalid_qty] bad')),
        WeeklyCountErrorCodes.invalidQty,
      );
    });

    test('no code when the server sent none', () {
      expect(
        weeklyCountErrorCode(_frappeError({'message': 'Server busy'})),
        isNull,
      );
      expect(weeklyCountErrorCode(null), isNull);
      expect(weeklyCountErrorCode('[Not a code] x'), isNull);
    });
  });

  group('Arabic messages', () {
    final ar = lookupAppLocalizations(const Locale('ar'));

    test('every documented code has its own sentence', () {
      final codes = [
        WeeklyCountErrorCodes.missingItems,
        WeeklyCountErrorCodes.unknownItems,
        WeeklyCountErrorCodes.invalidQty,
        WeeklyCountErrorCodes.alreadyPending,
        WeeklyCountErrorCodes.alreadyDone,
        WeeklyCountErrorCodes.noAccess,
        WeeklyCountErrorCodes.noWarehouse,
        WeeklyCountErrorCodes.reasonRequired,
        WeeklyCountErrorCodes.notPending,
        WeeklyCountErrorCodes.notFound,
        WeeklyCountErrorCodes.postFailed,
        WeeklyCountErrorCodes.noItems,
        WeeklyCountErrorCodes.ownCount,
      ];
      final texts = <String>{};
      for (final code in codes) {
        final text = weeklyCountKnownErrorMessage(ar, code);
        expect(text, isNotNull, reason: code);
        expect(text, isNot(contains('[')), reason: code);
        texts.add(text!);
      }
      expect(texts, hasLength(codes.length));
    });

    test('maps a refusal to its Arabic sentence, not the server text', () {
      final e = _frappeError({
        '_server_messages': _serverMessages(
          '[already_pending] A count is waiting for approval',
        ),
      });
      expect(weeklyCountErrorMessage(ar, e), ar.weeklyCountErrAlreadyPending);
    });

    test('the review and posting codes map to their own sentences', () {
      final cases = {
        '[not_pending] Already reviewed': ar.weeklyCountErrNotPending,
        '[not_found] No such count': ar.weeklyCountErrNotFound,
        '[post_failed] Stock Reconciliation failed':
            ar.weeklyCountErrPostFailed,
        '[no_items] Nothing to count': ar.weeklyCountErrNoItems,
        '[own_count] Someone else must decide': ar.weeklyCountErrOwnCount,
        '[reason_required] Give a reason': ar.weeklyCountErrReasonRequired,
      };
      cases.forEach((message, expected) {
        final e = _frappeError({'_server_messages': _serverMessages(message)});
        expect(weeklyCountErrorMessage(ar, e), expected, reason: message);
      });
      expect(ar.weeklyCountErrNotPending, 'هذا الجرد تمت مراجعته بالفعل');
      expect(ar.weeklyCountErrNoItems, 'لا توجد أصناف للجرد في هذا الفرع');
    });

    test('an unknown code is not mapped', () {
      expect(weeklyCountKnownErrorMessage(ar, 'something_else'), isNull);
      expect(weeklyCountKnownErrorMessage(ar, null), isNull);
    });
  });
}

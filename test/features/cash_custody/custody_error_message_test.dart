import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/user_error_message.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  DioException validation(String message) => DioException(
        requestOptions: RequestOptions(path: '/api/method/test'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/method/test'),
          statusCode: 417,
          data: {'exception': 'frappe.exceptions.ValidationError: $message'},
        ),
      );

  group('custody refusals', () {
    test('should map an insufficient custody balance to Arabic', () {
      expect(
        userErrorMessageFor(
          ar,
          validation('Amount 500.00 exceeds the custody balance 120.00 of Ahmed'),
        ),
        ar.userErrorCustodyInsufficient,
      );
      expect(
        userErrorMessageFor(ar, Exception('Insufficient custody balance')),
        ar.userErrorCustodyInsufficient,
      );
    });

    test('should map disabling a custody with a balance to Arabic', () {
      expect(
        userErrorMessageFor(
          ar,
          validation('Cannot disable a custody holder with a non-zero balance'),
        ),
        ar.userErrorCustodyDisableWithBalance,
      );
    });

    test('should not replace the English server sentence', () {
      final message = userErrorMessageFor(
        en,
        validation('Amount 500.00 exceeds the custody balance 120.00 of Ahmed'),
      );
      expect(message, isNot(en.userErrorCustodyInsufficient));
    });
  });
}

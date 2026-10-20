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

  group('handover rule refusals (F1)', () {
    const sentences = [
      'Jar X: sent 20, split 18. Every unit must go somewhere.',
      'Something changed in this batch. Reload and check again.',
      'You declared part of this batch. Another manager must confirm it. '
          'Ask one to confirm this handover.',
    ];

    for (final sentence in sentences) {
      test('keeps the server sentence after a lead line: $sentence', () {
        for (final l10n in [en, ar]) {
          final message = userErrorMessageFor(l10n, validation(sentence));
          expect(message, startsWith('${l10n.userErrorHandoverRule}\n'));
          expect(message, contains(sentence));
          expect(message, isNot(l10n.userErrorInsufficientStock));
        }
      });
    }

    test('a shortage that also says insufficient stock still maps to it', () {
      expect(
        userErrorMessageFor(en, validation('Insufficient stock for Jar X')),
        en.userErrorInsufficientStock,
      );
    });
  });
}

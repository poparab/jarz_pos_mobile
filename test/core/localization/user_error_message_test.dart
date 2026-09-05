import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/user_error_message.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  DioException dioError({
    DioExceptionType type = DioExceptionType.unknown,
    int? status,
    Object? data,
    String? message,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/api/method/test'),
      type: type,
      message: message,
      response: status == null && data == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/method/test'),
              statusCode: status,
              data: data,
            ),
    );
  }

  group('userErrorMessageFor', () {
    test('keeps business recovery instructions in Arabic', () {
      final cases = <String, String>{
        'Cart is empty': ar.posCartEmptyBody,
        'No profile selected': ar.checkoutSelectProfileFirst,
        'draft_limit_reached': ar.userErrorDraftLimit,
        'Cannot submit amendment: item was not found in the catalog.':
            ar.userErrorReopenOrder,
        'Selected shipping address is no longer available':
            ar.userErrorShippingAddress,
        'Insufficient stock': ar.userErrorInsufficientStock,
        'Quantity must be greater than zero.':
            ar.manufacturingQuantityMustBePositive,
        'No active shift': ar.userErrorShiftRequired,
        'Already submitted': ar.userErrorAlreadyProcessed,
        'Customer is required': ar.userErrorRequiredFields,
        'Invalid credentials': ar.authInvalidCredentials,
      };
      for (final entry in cases.entries) {
        expect(
          userErrorMessageFor(ar, Exception(entry.key)),
          entry.value,
          reason: entry.key,
        );
        expect(
          userErrorMessageFor(ar, entry.value),
          entry.value,
          reason: 'shared error panel',
        );
      }
    });

    test('handles update requirements and broken RPC responses distinctly', () {
      expect(
        userErrorMessageFor(ar, dioError(status: 426)),
        ar.appUpdateRequiredBody,
      );
      expect(
        userErrorMessageFor(
          ar,
          dioError(status: 403, data: {'message': 'Method is not whitelisted'}),
        ),
        ar.userErrorServer,
      );
      expect(
        userErrorMessageFor(
          ar,
          dioError(status: 417, data: {'message': 'cmd=None'}),
        ),
        ar.userErrorServer,
      );
    });

    test(
      'rejects short mixed technical messages and unrecognized payload fields',
      () {
        for (final error in <Object>[
          'خطأ TypeError: invalid stock response',
          'Required SQL SELECT price FROM tabItem',
          {'unrelated': 'Customer is required'},
          FormatException('Unexpected token'),
          {'message': 'Required internal method argument customer_id'},
        ]) {
          final result = userErrorMessageFor(ar, error);
          expect(result, isNot(contains(RegExp(r'[A-Za-z_]'))));
          expect(result.length, lessThanOrEqualTo(240));
        }
      },
    );
    test('maps Dio transport failures to concise English messages', () {
      expect(
        userErrorMessageFor(
          en,
          dioError(type: DioExceptionType.connectionTimeout),
        ),
        en.userErrorTimeout,
      );
      expect(
        userErrorMessageFor(
          en,
          dioError(type: DioExceptionType.connectionError),
        ),
        en.userErrorOffline,
      );
      expect(
        userErrorMessageFor(
          en,
          dioError(type: DioExceptionType.badCertificate),
        ),
        en.userErrorCertificate,
      );
      expect(
        userErrorMessageFor(en, dioError(type: DioExceptionType.cancel)),
        en.userErrorCancelled,
      );
    });

    test('maps HTTP status classes without exposing the response body', () {
      final cases = <int, String>{
        401: en.userErrorUnauthorized,
        403: en.userErrorForbidden,
        404: en.userErrorNotFound,
        409: en.userErrorConflict,
        429: en.userErrorRateLimited,
        500: en.userErrorServer,
      };

      for (final entry in cases.entries) {
        expect(
          userErrorMessageFor(
            en,
            dioError(
              status: entry.key,
              data: '<html>SELECT * FROM secret_table</html>',
            ),
          ),
          entry.value,
          reason: 'status ${entry.key}',
        );
      }
    });

    test('accepts a safe business validation in an English locale', () {
      final error = dioError(
        status: 422,
        data: jsonEncode({'message': 'Quantity must be greater than zero.'}),
      );

      expect(
        userErrorMessageFor(en, error),
        en.manufacturingQuantityMustBePositive,
      );
    });

    test('keeps a safe Arabic validation and translates an English one', () {
      expect(
        userErrorMessageFor(ar, <String, Object?>{
          'message': 'الكمية يجب أن تكون أكبر من صفر',
        }),
        'الكمية يجب أن تكون أكبر من صفر',
      );
      expect(
        userErrorMessageFor(ar, <String, Object?>{
          'message': 'Quantity must be greater than zero.',
        }),
        ar.manufacturingQuantityMustBePositive,
      );
    });

    test('maps wrapped network text before removing technical prefixes', () {
      expect(
        userErrorMessageFor(
          en,
          Exception('Network connection failed. Please try again.'),
        ),
        en.userErrorOffline,
      );
    });

    test('does not expose technical, HTML, SQL, or giant messages', () {
      final technical = <Object?>[
        StateError('Invalid argument'),
        'TypeError: Invalid argument',
        "type 'String' is not a subtype of type 'int'",
        Exception(
          "type 'List<dynamic>' is not a subtype of type "
          "'Map<String, dynamic>'",
        ),
        'SELECT name, rate FROM tabItem WHERE item_code = value',
        'TypeError: Customer is required',
        '<html><body>SELECT * FROM users</body></html>',
        '${'x' * 7000} required',
      ];

      for (final error in technical) {
        final message = userErrorMessageFor(ar, error);
        expect(message, ar.userErrorUnexpected, reason: '$error');
        expect(message, isNot(contains('SELECT')));
        expect(message, isNot(contains('<html')));
        expect(message, isNot(contains('TypeError')));
      }
    });

    test(
      'uses a trusted localized fallback and rejects a technical fallback',
      () {
        expect(
          userErrorMessageFor(
            en,
            Object(),
            fallback: 'Could not save the order.',
          ),
          'Could not save the order.',
        );
        expect(
          userErrorMessageFor(ar, Object(), fallback: 'تعذّر حفظ الطلب.'),
          'تعذّر حفظ الطلب.',
        );
        expect(
          userErrorMessageFor(ar, Object(), fallback: 'TypeError: bad state'),
          ar.userErrorUnexpected,
        );
      },
    );

    test('does not add retry advice to an unknown financial failure', () {
      final message = userErrorMessageFor(
        ar,
        'Payment may already have been processed; check the order status.',
      );

      expect(message, ar.userErrorUnexpected);
      expect(message, isNot(contains('حاول مرة أخرى')));
    });
  });

  group('validation pass-through', () {
    // Frappe answers a ValidationError with HTTP 417 and puts the human reason
    // in `exception`. The prefix is supported, while the body still has to be
    // a known business rule or a short validation-shaped sentence.
    test('maps a known English manufacturing refusal from a 417 body', () {
      final error = dioError(
        type: DioExceptionType.badResponse,
        status: 417,
        data: {'exception': 'ValidationError: Not enough material in WIP'},
      );
      expect(userErrorMessageFor(en, error), en.userErrorInsufficientStock);
    });

    test('an Arabic UI does not surface an English server sentence', () {
      final error = dioError(
        type: DioExceptionType.badResponse,
        status: 417,
        data: {'exception': 'ValidationError: Not enough material in WIP'},
      );
      expect(userErrorMessageFor(ar, error), ar.userErrorInsufficientStock);
    });

    test('an Arabic UI shows an Arabic server reason verbatim', () {
      final error = dioError(
        type: DioExceptionType.badResponse,
        status: 417,
        data: {'exception': 'ValidationError: الكمية غير متاحة في المخزون'},
      );
      expect(userErrorMessageFor(ar, error), 'الكمية غير متاحة في المخزون');
    });

    test('keeps legitimate English and Arabic ValidationError refusals', () {
      expect(
        userErrorMessageFor(
          en,
          dioError(
            type: DioExceptionType.badResponse,
            status: 417,
            data: {
              'exception':
                  'ValidationError: Orders must be completed before closing the shift.',
            },
          ),
        ),
        'Orders must be completed before closing the shift.',
      );
      expect(
        userErrorMessageFor(
          ar,
          dioError(
            type: DioExceptionType.badResponse,
            status: 417,
            data: {
              'exception':
                  'frappe.exceptions.ValidationError: لا يمكن إغلاق الوردية قبل إكمال الطلبات',
            },
          ),
        ),
        'لا يمكن إغلاق الوردية قبل إكمال الطلبات',
      );
    });

    test('HTTP 417 does not make technical payloads user-facing', () {
      final payloads = <Object>[
        {'message': "type 'String' is not a subtype of type 'int'"},
        {'exception': 'TypeError: unexpected object'},
        {'message': 'SELECT name FROM tabItem WHERE disabled = 0'},
        {'message': 'Operation failed in process_order'},
      ];

      for (final payload in payloads) {
        expect(
          userErrorMessageFor(
            en,
            dioError(
              type: DioExceptionType.badResponse,
              status: 417,
              data: payload,
            ),
          ),
          en.userErrorValidationFallback,
          reason: '$payload',
        );
      }
    });

    test('an Arabic UI rejects mixed Arabic and English validation text', () {
      final error = dioError(
        type: DioExceptionType.badResponse,
        status: 417,
        data: {'exception': 'ValidationError: لا يمكن process customer_id'},
      );

      expect(userErrorMessageFor(ar, error), ar.userErrorValidationFallback);
    });

    test('an Exception wrapper is not sufficient to trust unknown text', () {
      expect(
        userErrorMessageFor(en, Exception('Not enough material in WIP')),
        en.userErrorInsufficientStock,
      );
      expect(
        userErrorMessageFor(en, Exception('boom')),
        en.userErrorUnexpected,
      );
    });

    test('a curated message that names a known refusal is localised', () {
      expect(
        userErrorMessageFor(ar, Exception('Insufficient stock for Item X')),
        ar.userErrorInsufficientStock,
      );
    });

    test('an Arabic UI localizes a known English curated message', () {
      expect(
        userErrorMessageFor(ar, Exception('Not enough material in WIP')),
        ar.userErrorInsufficientStock,
      );
    });

    test('technical text and Dart Errors never reach the user', () {
      expect(
        userErrorMessageFor(en, StateError('Bad state: no element')),
        en.userErrorUnexpected,
      );
      expect(
        userErrorMessageFor(en, Exception('<html><body>502 Bad Gateway')),
        en.userErrorServer,
      );
      expect(
        userErrorMessageFor(en, Exception('Traceback (most recent call last)')),
        en.userErrorUnexpected,
      );
    });
  });
}

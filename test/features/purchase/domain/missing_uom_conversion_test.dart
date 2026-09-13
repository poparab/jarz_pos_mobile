import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/purchase/domain/missing_uom_conversion.dart';

const _sentence =
    'SUGAR-01 has no conversion from Box to Kg. Pick another unit or add the conversion on the Item.';

const _expected =
    MissingUomConversion(itemCode: 'SUGAR-01', uom: 'Box', stockUom: 'Kg');

/// The body Frappe sends for a `frappe.throw` raised as a ValidationError.
Map<String, dynamic> _frappeBody(String message) => {
      'exception': 'frappe.exceptions.ValidationError: $message',
      'exc_type': 'ValidationError',
      'exc': jsonEncode([
        'Traceback (most recent call last):\n  File "apps/jarz_pos/jarz_pos/api/purchase.py", line 1\nfrappe.exceptions.ValidationError: $message\n'
      ]),
      '_server_messages': jsonEncode([
        jsonEncode({
          'message': message,
          'title': 'Message',
          'indicator': 'red',
          'raise_exception': 1,
        }),
      ]),
    };

void main() {
  group('parseMissingUomConversion', () {
    test('reads the plain sentence', () {
      expect(parseMissingUomConversion(_sentence), _expected);
    });

    test('reads an Exception whose toString wraps the sentence', () {
      expect(parseMissingUomConversion(Exception(_sentence)), _expected);
      expect(
        parseMissingUomConversion('Purchase failed: ValidationError: $_sentence'),
        _expected,
      );
    });

    test('reads the sentence inside a Frappe _server_messages body', () {
      final body = {
        '_server_messages': _frappeBody(_sentence)['_server_messages'],
      };
      expect(parseMissingUomConversion(body), _expected);
      // The same body still as a raw JSON string.
      expect(parseMissingUomConversion(jsonEncode(body)), _expected);
    });

    test('reads the Frappe exception string alone', () {
      expect(
        parseMissingUomConversion(
            {'exception': 'frappe.exceptions.ValidationError: $_sentence'}),
        _expected,
      );
    });

    test('reads a DioException wrapping the Frappe body', () {
      final options = RequestOptions(
          path: '/api/method/jarz_pos.api.purchase.create_purchase_invoice');
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 417,
          data: _frappeBody(_sentence),
        ),
      );
      expect(parseMissingUomConversion(error), _expected);
    });

    test('keeps item codes and units with spaces, bold tags and entities', () {
      const message =
          '<strong>Cream Cheese 1&amp;2</strong> has no conversion from <strong>Carton 12</strong> to <strong>Gram</strong>. Pick another unit or add the conversion on the Item.';
      expect(
        parseMissingUomConversion(_frappeBody(message)),
        const MissingUomConversion(
            itemCode: 'Cream Cheese 1&2', uom: 'Carton 12', stockUom: 'Gram'),
      );
    });

    test('returns null for any other error', () {
      expect(parseMissingUomConversion(null), isNull);
      expect(parseMissingUomConversion(Exception('Unexpected create PI response')),
          isNull);
      expect(
        parseMissingUomConversion(
            _frappeBody('Supplier SUP-001 is disabled.')),
        isNull,
      );
      final options = RequestOptions(path: '/api/method/x');
      expect(
        parseMissingUomConversion(DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        )),
        isNull,
      );
    });
  });
}

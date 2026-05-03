import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/debug/app_error_reporter.dart';
import 'package:jarz_pos/src/core/utils/logger.dart';

void main() {
  group('AppErrorReporter', () {
    setUp(() {
      AppErrorReporter.instance.clear();
    });

    test(
      'should capture Dio errors from logger and redact sensitive details',
      () {
        // Arrange
        final logger = Logger('ApiClient');
        final error = DioException(
          requestOptions: RequestOptions(
            path: '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            method: 'POST',
            data: <String, Object?>{
              'customer': 'CUST-0001',
              'password': 'super-secret',
            },
          ),
          response: Response<dynamic>(
            requestOptions: RequestOptions(
              path: '/api/method/jarz_pos.api.invoices.create_pos_invoice',
            ),
            statusCode: 417,
            data: <String, Object?>{
              'message': 'Customer test@example.com is disabled',
              'sid': 'private-session',
            },
          ),
          type: DioExceptionType.badResponse,
          message: 'Request failed with status code 417',
        );

        // Act
        logger.error(
          'Invoice creation failed',
          error,
          StackTrace.fromString('stack line'),
        );

        // Assert
        final record = AppErrorReporter.instance.latest;
        expect(record, isNotNull);
        expect(record!.source, 'Logger:ApiClient');
        expect(record.message, 'Customer test@example.com is disabled');
        expect(record.summary, 'Invoice creation failed');
        expect(record.details['statusCode'], 417);

        final requestData =
            record.details['requestData'] as Map<String, Object?>;
        final responseData =
            record.details['responseData'] as Map<String, Object?>;
        expect(requestData['password'], '<redacted>');
        expect(responseData['sid'], '<redacted>');
      },
    );

    test('should keep only the most recent error records', () {
      // Arrange
      for (var index = 0; index < 50; index++) {
        AppErrorReporter.instance.recordMessage(
          source: 'Test',
          message: 'Error $index',
        );
      }

      // Act
      final records = AppErrorReporter.instance.records;

      // Assert
      expect(records, hasLength(40));
      expect(records.first.message, 'Error 10');
      expect(records.last.message, 'Error 49');
    });

    test('should capture provider failures via the global observer', () {
      // Arrange
      final observer = AppProviderObserver();
      final container = ProviderContainer();
      final provider = Provider<int>((ref) => 1, name: 'failingProvider');

      addTearDown(container.dispose);

      // Act
      observer.providerDidFail(
        provider,
        StateError('provider exploded'),
        StackTrace.fromString('provider stack'),
        container,
      );

      // Assert
      final record = AppErrorReporter.instance.latest;
      expect(record, isNotNull);
      expect(record!.source, 'Riverpod:failingProvider');
      expect(record.message, contains('provider exploded'));
      expect(record.summary, 'Provider evaluation failed');
    });
  });
}

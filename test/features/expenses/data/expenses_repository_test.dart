import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/expenses/data/expenses_repository.dart';

/// Captures the create_expense body and answers with a canned expense, so the
/// wire shape can be asserted without a server.
Dio _capturingDio(List<Map<String, dynamic>> bodies) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        bodies.add(Map<String, dynamic>.from(options.data as Map));
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'message': {
                'expense': {
                  'name': 'EXP-1',
                  'period_from': (options.data as Map)['period_from'],
                  'period_to': (options.data as Map)['period_to'],
                  'period_journal_entries': const <String>[],
                },
              },
            },
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('ExpensesRepository.createExpense service period', () {
    test('sends period_from / period_to when set', () async {
      final bodies = <Map<String, dynamic>>[];
      final repo = ExpensesRepository(_capturingDio(bodies));

      final record = await repo.createExpense(
        amount: 900,
        reasonAccount: 'Rent - J',
        expenseDate: '2026-10-06',
        periodFrom: '2026-09-25',
        periodTo: '2026-10-05',
      );

      expect(bodies.single['period_from'], '2026-09-25');
      expect(bodies.single['period_to'], '2026-10-05');
      expect(record.periodFrom, DateTime(2026, 9, 25));
      expect(record.periodTo, DateTime(2026, 10, 5));
    });

    test('omits both keys when no period is given (old request shape)', () async {
      final bodies = <Map<String, dynamic>>[];
      final repo = ExpensesRepository(_capturingDio(bodies));

      final record = await repo.createExpense(amount: 50, reasonAccount: 'Misc - J');

      expect(bodies.single.containsKey('period_from'), isFalse);
      expect(bodies.single.containsKey('period_to'), isFalse);
      expect(record.hasPeriod, isFalse);
    });
  });
}

// Contract tests for Expense API endpoints.
//
// Verifies that ExpensePaymentSource and ExpenseReason can deserialize
// the expense_bootstrap.json fixture. Refresh with snapshot_updater.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/expenses/models/expense_models.dart';

void main() {
  const fixturesDir = 'test/contracts/fixtures';

  group('Expense Contract — bootstrap', () {
    test('payment_sources deserialize to List<ExpensePaymentSource>', () {
      final raw =
          File('$fixturesDir/expense_bootstrap.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final sourcesRaw = json['payment_sources'] as List;
      final sources = sourcesRaw
          .map((e) =>
              ExpensePaymentSource.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(sources, isNotEmpty,
          reason: 'At least one payment source expected');
      for (final s in sources) {
        expect(s.id, isNotEmpty, reason: 'Source id must not be empty');
        expect(s.account, isNotEmpty,
            reason: 'account must not be empty');
        expect(s.label, isNotEmpty, reason: 'label must not be empty');
        expect(s.category, isNotEmpty,
            reason: 'category must not be empty');
      }
    });

    test('reasons deserialize to List<ExpenseReason>', () {
      final raw =
          File('$fixturesDir/expense_bootstrap.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final reasonsRaw = json['reasons'] as List;
      final reasons = reasonsRaw
          .map((e) => ExpenseReason.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(reasons, isNotEmpty,
          reason: 'At least one expense reason expected');
      for (final r in reasons) {
        expect(r.account, isNotEmpty,
            reason: 'Reason account must not be empty');
        expect(r.label, isNotEmpty,
            reason: 'Reason label must not be empty');
      }
    });
  });
}

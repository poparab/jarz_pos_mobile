// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/expenses/models/expense_models.dart';

void main() {
  // ── ExpensePaymentSource ──────────────────────────────────────────────

  group('ExpensePaymentSource.fromJson', () {
    test('parses all fields', () {
      final src = ExpensePaymentSource.fromJson({
        'id': 'src-1',
        'account': 'Cash - JZ',
        'label': 'Cash',
        'category': 'cash',
        'balance': 5000.5,
        'pos_profile': 'Main POS',
      });
      expect(src.id, 'src-1');
      expect(src.account, 'Cash - JZ');
      expect(src.label, 'Cash');
      expect(src.category, 'cash');
      expect(src.balance, 5000.5);
      expect(src.posProfile, 'Main POS');
    });

    test('defaults for missing fields', () {
      final src = ExpensePaymentSource.fromJson({});
      expect(src.id, '');
      expect(src.account, '');
      expect(src.label, '');
      expect(src.category, 'account');
      expect(src.balance, 0);
      expect(src.posProfile, isNull);
    });

    test('balance from string', () {
      final src = ExpensePaymentSource.fromJson({'balance': '1234.56'});
      expect(src.balance, 1234.56);
    });

    test('falls back id to account', () {
      final src = ExpensePaymentSource.fromJson({'account': 'ACC-1'});
      expect(src.id, 'ACC-1');
    });
  });

  group('ExpensePaymentSource getters', () {
    test('isPosProfile', () {
      final src = ExpensePaymentSource.fromJson({'category': 'pos_profile'});
      expect(src.isPosProfile, isTrue);
      expect(src.isCash, isFalse);
    });

    test('isCash', () {
      final src = ExpensePaymentSource.fromJson({'category': 'cash'});
      expect(src.isCash, isTrue);
    });

    test('isBank', () {
      final src = ExpensePaymentSource.fromJson({'category': 'bank'});
      expect(src.isBank, isTrue);
    });

    test('isMobile', () {
      final src = ExpensePaymentSource.fromJson({'category': 'mobile'});
      expect(src.isMobile, isTrue);
    });

    test('displayBalance formats currency', () {
      final src = ExpensePaymentSource.fromJson({'balance': 1500});
      // intl currency format — verify it contains the numeric part
      expect(src.displayBalance, contains('1,500'));
    });
  });

  group('ExpensePaymentSource.toJson', () {
    test('roundtrip', () {
      final original = ExpensePaymentSource.fromJson({
        'id': 'x',
        'account': 'A',
        'label': 'L',
        'category': 'cash',
        'balance': 100,
        'pos_profile': 'P',
      });
      final json = original.toJson();
      final restored = ExpensePaymentSource.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.account, original.account);
      expect(restored.balance, original.balance);
    });
  });

  // ── ExpenseReason ─────────────────────────────────────────────────────

  group('ExpenseReason', () {
    test('fromJson parses fields', () {
      final r = ExpenseReason.fromJson({
        'account': 'Misc Expenses',
        'label': 'Miscellaneous',
      });
      expect(r.account, 'Misc Expenses');
      expect(r.label, 'Miscellaneous');
    });

    test('fromJson defaults', () {
      final r = ExpenseReason.fromJson({});
      expect(r.account, '');
      expect(r.label, '');
    });

    test('toJson roundtrip', () {
      final r = ExpenseReason.fromJson({'account': 'A', 'label': 'L'});
      final json = r.toJson();
      expect(json['account'], 'A');
      expect(json['label'], 'L');
    });
  });

  // ── ExpenseTimelineEvent ──────────────────────────────────────────────

  group('ExpenseTimelineEvent', () {
    test('fromJson all fields', () {
      final e = ExpenseTimelineEvent.fromJson({
        'label': 'Created',
        'timestamp': '2024-06-01T10:00:00',
        'user': 'admin@test.com',
      });
      expect(e.label, 'Created');
      expect(e.timestamp, DateTime(2024, 6, 1, 10));
      expect(e.user, 'admin@test.com');
    });

    test('fromJson with null timestamp', () {
      final e = ExpenseTimelineEvent.fromJson({'label': 'X'});
      expect(e.timestamp, isNull);
      expect(e.user, isNull);
    });

    test('toJson roundtrip', () {
      final e = ExpenseTimelineEvent.fromJson({
        'label': 'Approved',
        'timestamp': '2024-06-15T14:30:00',
        'user': 'u',
      });
      final json = e.toJson();
      expect(json['label'], 'Approved');
      expect(json['timestamp'], contains('2024-06-15'));
    });
  });

  // ── ExpenseRecord ─────────────────────────────────────────────────────

  group('ExpenseRecord.fromJson', () {
    Map<String, dynamic> _full() => {
          'name': 'EXP-001',
          'expense_date': '2024-06-01',
          'amount': 250.75,
          'currency': 'IQD',
          'reason_account': 'Misc',
          'reason_label': 'Miscellaneous',
          'paying_account': 'Cash - JZ',
          'payment_label': 'Cash',
          'payment_source_type': 'cash',
          'pos_profile': 'Main POS',
          'requires_approval': true,
          'docstatus': 0,
          'status': 'Pending Approval',
          'requested_by': 'user1',
          'approved_by': null,
          'approved_on': null,
          'remarks': 'test expense',
          'journal_entry': null,
          'company': 'JARZ',
          'creation': '2024-06-01T08:00:00',
          'modified': '2024-06-01T09:00:00',
          'timeline': [
            {'label': 'Created', 'timestamp': '2024-06-01T08:00:00', 'user': 'u1'},
          ],
        };

    test('parses all fields', () {
      final r = ExpenseRecord.fromJson(_full());
      expect(r.name, 'EXP-001');
      expect(r.amount, 250.75);
      expect(r.currency, 'IQD');
      expect(r.reasonAccount, 'Misc');
      expect(r.payingAccount, 'Cash - JZ');
      expect(r.requiresApproval, isTrue);
      expect(r.docstatus, 0);
      expect(r.status, 'Pending Approval');
      expect(r.remarks, 'test expense');
      expect(r.timeline, hasLength(1));
      expect(r.createdOn, isNotNull);
    });

    test('defaults for missing fields', () {
      final r = ExpenseRecord.fromJson({});
      expect(r.name, '');
      expect(r.amount, 0);
      expect(r.docstatus, 0);
      expect(r.timeline, isEmpty);
    });

    test('amount from string', () {
      final r = ExpenseRecord.fromJson({'amount': '99.5'});
      expect(r.amount, 99.5);
    });

    test('requires_approval from int 1', () {
      final r = ExpenseRecord.fromJson({'requires_approval': 1});
      expect(r.requiresApproval, isTrue);
    });

    test('requires_approval from string "1"', () {
      final r = ExpenseRecord.fromJson({'requires_approval': '1'});
      expect(r.requiresApproval, isTrue);
    });

    test('timeline from JSON string', () {
      final r = ExpenseRecord.fromJson({
        'timeline': '[{"label":"X","timestamp":"2024-01-01T00:00:00"}]',
      });
      expect(r.timeline, hasLength(1));
      expect(r.timeline.first.label, 'X');
    });

    test('timeline from invalid JSON string', () {
      final r = ExpenseRecord.fromJson({'timeline': 'not json'});
      expect(r.timeline, isEmpty);
    });
  });

  group('ExpenseRecord getters', () {
    test('isPending when docstatus=0 and requiresApproval', () {
      final r = ExpenseRecord.fromJson({
        'docstatus': 0,
        'requires_approval': true,
      });
      expect(r.isPending, isTrue);
      expect(r.isApproved, isFalse);
    });

    test('isApproved when docstatus=1', () {
      final r = ExpenseRecord.fromJson({'docstatus': 1});
      expect(r.isApproved, isTrue);
      expect(r.isPending, isFalse);
    });

    test('neither pending nor approved', () {
      final r = ExpenseRecord.fromJson({'docstatus': 0, 'requires_approval': false});
      expect(r.isPending, isFalse);
      expect(r.isApproved, isFalse);
    });
  });

  // ── ExpenseSummary ────────────────────────────────────────────────────

  group('ExpenseSummary', () {
    test('fromJson parses all fields', () {
      final s = ExpenseSummary.fromJson({
        'total_amount': 5000,
        'pending_count': 3,
        'pending_amount': 1500,
        'approved_count': 10,
      });
      expect(s.totalAmount, 5000);
      expect(s.pendingCount, 3);
      expect(s.pendingAmount, 1500);
      expect(s.approvedCount, 10);
    });

    test('fromJson with null returns zeros', () {
      final s = ExpenseSummary.fromJson(null);
      expect(s.totalAmount, 0);
      expect(s.pendingCount, 0);
      expect(s.pendingAmount, 0);
      expect(s.approvedCount, 0);
    });

    test('fromJson with string numbers', () {
      final s = ExpenseSummary.fromJson({
        'total_amount': '999.5',
        'pending_count': '2',
        'pending_amount': '500',
        'approved_count': '7',
      });
      expect(s.totalAmount, 999.5);
      expect(s.pendingCount, 2);
      expect(s.approvedCount, 7);
    });
  });

  // ── ExpenseMonthOption ────────────────────────────────────────────────

  group('ExpenseMonthOption', () {
    test('fromJson', () {
      final m = ExpenseMonthOption.fromJson({'id': '2024-06', 'label': 'June 2024'});
      expect(m.id, '2024-06');
      expect(m.label, 'June 2024');
    });

    test('defaults', () {
      final m = ExpenseMonthOption.fromJson({});
      expect(m.id, '');
      expect(m.label, '');
    });
  });

  // ── ExpenseBootstrap ──────────────────────────────────────────────────

  group('ExpenseBootstrap.fromJson', () {
    test('parses complete payload', () {
      final b = ExpenseBootstrap.fromJson({
        'is_manager': true,
        'current_month': '2024-06',
        'requested_month': '2024-06',
        'months': [
          {'id': '2024-06', 'label': 'June 2024'},
        ],
        'payment_sources': [
          {'id': 'ps1', 'account': 'A', 'label': 'L', 'category': 'cash', 'balance': 100},
        ],
        'reasons': [
          {'account': 'R', 'label': 'Reason'},
        ],
        'expenses': [
          {'name': 'EXP-1', 'amount': 50, 'docstatus': 0},
        ],
        'summary': {
          'total_amount': 50,
          'pending_count': 1,
          'pending_amount': 50,
          'approved_count': 0,
        },
        'applied_filters': {
          'payment_ids': ['ps1'],
        },
      });
      expect(b.isManager, isTrue);
      expect(b.currentMonth, '2024-06');
      expect(b.months, hasLength(1));
      expect(b.paymentSources, hasLength(1));
      expect(b.reasons, hasLength(1));
      expect(b.expenses, hasLength(1));
      expect(b.summary.totalAmount, 50);
      expect(b.appliedPaymentIds, ['ps1']);
    });

    test('defaults for empty payload', () {
      final b = ExpenseBootstrap.fromJson({});
      expect(b.isManager, isFalse);
      expect(b.currentMonth, '');
      expect(b.months, isEmpty);
      expect(b.paymentSources, isEmpty);
      expect(b.reasons, isEmpty);
      expect(b.expenses, isEmpty);
      expect(b.appliedPaymentIds, isEmpty);
    });
  });
}

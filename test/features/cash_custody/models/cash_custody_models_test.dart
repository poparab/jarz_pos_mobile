import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/cash_custody/models/cash_custody_models.dart';
import 'package:jarz_pos/src/features/expenses/models/expense_models.dart';

Map<String, dynamic> _holderJson({
  String name = 'CUST-0001',
  dynamic balance = 250.5,
  dynamic enabled = 1,
  String? lastMovement = '2026-09-20',
}) =>
    {
      'name': name,
      'employee': 'HR-EMP-0001',
      'employee_name': 'Ahmed Ali',
      'user': 'ahmed@example.com',
      'company': 'Jarz',
      'account': 'Custody - Ahmed - J',
      'label_en': 'Ahmed Ali',
      'label_ar': 'أحمد علي',
      'balance': balance,
      'enabled': enabled,
      'last_movement': lastMovement,
    };

void main() {
  group('custody wire parsing helpers', () {
    test('should parse num, int and string amounts', () {
      expect(custodyParseDouble(12), 12.0);
      expect(custodyParseDouble(12.75), 12.75);
      expect(custodyParseDouble('99.5'), 99.5);
      expect(custodyParseDouble(null), 0);
      expect(custodyParseDouble('abc'), 0);
    });

    test('should parse bool, int and string flags', () {
      expect(custodyParseBool(true), isTrue);
      expect(custodyParseBool(1), isTrue);
      expect(custodyParseBool('1'), isTrue);
      expect(custodyParseBool('true'), isTrue);
      expect(custodyParseBool(0), isFalse);
      expect(custodyParseBool('0'), isFalse);
      expect(custodyParseBool(false), isFalse);
      expect(custodyParseBool(null), isFalse);
      expect(custodyParseBool(null, fallback: true), isTrue);
    });
  });

  group('CustodyHolder.fromJson', () {
    test('should read every contract field', () {
      final holder = CustodyHolder.fromJson(_holderJson());

      expect(holder.name, 'CUST-0001');
      expect(holder.employee, 'HR-EMP-0001');
      expect(holder.employeeName, 'Ahmed Ali');
      expect(holder.user, 'ahmed@example.com');
      expect(holder.account, 'Custody - Ahmed - J');
      expect(holder.balance, 250.5);
      expect(holder.enabled, isTrue);
      expect(holder.lastMovement, '2026-09-20');
      expect(holder.localizedName('ar'), 'أحمد علي');
      expect(holder.localizedName('en'), 'Ahmed Ali');
    });

    test('should tolerate string balance, int/string enabled and null date', () {
      final holder = CustodyHolder.fromJson(
        _holderJson(balance: '0', enabled: '0', lastMovement: null),
      );

      expect(holder.balance, 0);
      expect(holder.enabled, isFalse);
      expect(holder.lastMovement, isNull);
      expect(holder.hasBalance, isFalse);
    });

    test('should treat a missing enabled flag as enabled', () {
      final json = _holderJson()..remove('enabled');
      expect(CustodyHolder.fromJson(json).enabled, isTrue);
    });
  });

  group('CustodyOverview.fromJson', () {
    final json = {
      'company': 'Jarz',
      'can_manage': 1,
      'can_manage_holders': 'true',
      'my_holder': _holderJson(name: 'CUST-ME', balance: 40),
      'holders': [
        _holderJson(name: 'CUST-A', balance: 100),
        _holderJson(name: 'CUST-B', balance: '60.25', enabled: 0),
      ],
      'source_accounts': [
        {
          'account': 'Cash - J',
          'label': 'Main Cash',
          'category': 'cash',
          'balance': '5000',
          'pos_profile': null,
        },
      ],
      'return_accounts': [
        {
          'account': 'Nasr City Drawer - J',
          'label': 'Nasr City',
          'label_ar': 'مدينة نصر',
          'category': 'pos_profile',
          'balance': 300,
          'pos_profile': 'Nasr City',
        },
      ],
    };

    test('should parse flags, holders and account options', () {
      final overview = CustodyOverview.fromJson(json);

      expect(overview.canManage, isTrue);
      expect(overview.canManageHolders, isTrue);
      expect(overview.myHolder?.name, 'CUST-ME');
      expect(overview.holders, hasLength(2));
      expect(overview.totalHeld, closeTo(160.25, 1e-9));
      expect(overview.sourceAccounts.single.balance, 5000);
      expect(overview.sourceAccounts.single.posProfile, isNull);
      expect(overview.returnAccounts.single.posProfile, 'Nasr City');
      expect(overview.returnAccounts.single.localizedLabel('ar'), 'مدينة نصر');
      expect(overview.hasAccess, isTrue);
    });

    test('should offer a manager every enabled holder plus their own', () {
      final overview = CustodyOverview.fromJson(json);

      expect(
        overview.payableHolders.map((h) => h.name),
        ['CUST-ME', 'CUST-A'],
      );
    });

    test('should offer a non-manager only their own enabled custody', () {
      final overview = CustodyOverview.fromJson({
        'can_manage': 0,
        'can_manage_holders': 0,
        'my_holder': _holderJson(name: 'CUST-ME'),
        'holders': [],
      });

      expect(overview.payableHolders.map((h) => h.name), ['CUST-ME']);
      expect(overview.hasAccess, isTrue);
      expect(overview.holderNamed('CUST-ME'), isNotNull);
    });

    test('should deny access when neither manager nor holder', () {
      final overview = CustodyOverview.fromJson({
        'can_manage': false,
        'my_holder': null,
      });

      expect(overview.hasAccess, isFalse);
      expect(overview.payableHolders, isEmpty);
      expect(overview.holders, isEmpty);
    });
  });

  group('CustodyStatement.fromJson', () {
    test('should parse balances and entry kinds', () {
      final statement = CustodyStatement.fromJson({
        'holder': _holderJson(),
        'from_date': '2026-09-01',
        'to_date': '2026-09-23',
        'opening_balance': '100',
        'closing_balance': 150,
        'entries': [
          {
            'posting_date': '2026-09-02',
            'voucher_type': 'Journal Entry',
            'voucher_no': 'ACC-JV-1',
            'kind': 'issue',
            'debit': 200,
            'credit': 0,
            'balance': 300,
            'remark': 'float',
            'counter_account': 'Cash - J',
            'counter_label': 'Main Cash',
          },
          {'kind': 'return', 'debit': '0', 'credit': '150', 'balance': '150'},
          {'kind': 'transfer_out', 'credit': 1},
          {'kind': 'something-new'},
        ],
      });

      expect(statement.openingBalance, 100);
      expect(statement.closingBalance, 150);
      expect(statement.holder?.name, 'CUST-0001');
      expect(statement.entries.map((e) => e.kind), [
        CustodyEntryKind.issue,
        CustodyEntryKind.returned,
        CustodyEntryKind.transferOut,
        CustodyEntryKind.other,
      ]);
      expect(statement.entries.first.net, 200);
      expect(statement.entries[1].net, -150);
      expect(statement.entries.first.counterLabel, 'Main Cash');
    });
  });

  group('CustodyMovementResult.fromJson', () {
    test('should read the journal entry and updated holder', () {
      final result = CustodyMovementResult.fromJson({
        'success': true,
        'journal_entry': 'ACC-JV-9',
        'holder': _holderJson(balance: 0),
      });

      expect(result.journalEntry, 'ACC-JV-9');
      expect(result.holder?.balance, 0);
    });
  });

  test('custodyPurchasePaymentOption should prefix the holder name', () {
    expect(custodyPurchasePaymentOption('CUST-0001'), 'custody:CUST-0001');
  });

  group('Expenses bootstrap custody additions', () {
    test('should parse custody_account and flag custody sources', () {
      final bootstrap = ExpenseBootstrap.fromJson({
        'is_manager': false,
        'custody_account': 'Custody - Ahmed - J',
        'payment_sources': [
          {
            'id': 'Custody - Ahmed - J',
            'account': 'Custody - Ahmed - J',
            'label': 'Ahmed Ali',
            'category': 'custody',
            'balance': '75',
          },
          {
            'id': 'Nasr City',
            'account': 'Nasr City Drawer - J',
            'label': 'Nasr City',
            'category': 'pos_profile',
            'balance': 10,
            'pos_profile': 'Nasr City',
          },
        ],
      });

      expect(bootstrap.custodyAccount, 'Custody - Ahmed - J');
      expect(bootstrap.paymentSources.first.isCustody, isTrue);
      expect(bootstrap.paymentSources.first.balance, 75);
      expect(bootstrap.paymentSources.last.isCustody, isFalse);
    });

    test('should leave custody_account null when absent or empty', () {
      expect(ExpenseBootstrap.fromJson({}).custodyAccount, isNull);
      expect(
        ExpenseBootstrap.fromJson({'custody_account': ''}).custodyAccount,
        isNull,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/manager/data/manager_api.dart';

/// Pins the wire shape of `jarz_pos.api.manager.get_employee_ledger`.
///
/// The screen adds two independent debts into one number per person, so a
/// silently dropped field or a string-typed Decimal is money quietly going
/// missing from a manager view.
void main() {
  Map<String, dynamic> fullPayload() => {
        'success': true,
        'hrms_available': true,
        'filters': {
          'from_date': '2026-05-31',
          'to_date': '2026-08-29',
          'branch': 'all',
          'employee': null,
        },
        'summary': {
          'advance_outstanding': 3500.0,
          'order_outstanding': 720.5,
          'total_outstanding': 4220.5,
          'advance_count': 2,
          'order_count': 3,
          'employee_count': 2,
          'currency': 'EGP',
        },
        'employees': [
          {
            'employee': 'HR-EMP-0001',
            'employee_name': 'Mona Adel',
            'user': 'mona@example.com',
            'branch': 'Nasr City',
            'customer': 'Mona Adel (Employee)',
            'advance_outstanding': 3500.0,
            'order_outstanding': 420.5,
            'total_outstanding': 3920.5,
            'advance_count': 2,
            'order_count': 2,
          },
          {
            'employee': '',
            'employee_name': '',
            'user': '',
            'branch': 'Dokki',
            'customer': 'Walk-in Staff',
            'advance_outstanding': 0,
            'order_outstanding': 300.0,
            'total_outstanding': 300.0,
            'advance_count': 0,
            'order_count': 1,
          },
        ],
        'advances': [
          {
            'name': 'HR-EAD-2026-00001',
            'employee': 'HR-EMP-0001',
            'employee_name': 'Mona Adel',
            'posting_date': '2026-08-01',
            'amount': 2000.0,
            'paid_amount': 2000.0,
            'claimed_amount': 0.0,
            'return_amount': 0.0,
            'balance': 2000.0,
            'status': 'Paid',
            'purpose': 'Fuel for the delivery bike',
            'branch': 'Nasr City',
            'paying_account': 'Cash - JZ',
            'currency': 'EGP',
          },
          {
            'name': 'HR-EAD-2026-00002',
            'employee': 'HR-EMP-0001',
            'employee_name': 'Mona Adel',
            'posting_date': '2026-08-10',
            'amount': 2000.0,
            'paid_amount': 2000.0,
            'claimed_amount': 500.0,
            'return_amount': 0.0,
            'balance': 1500.0,
            'status': 'Partly Claimed and Returned',
            'purpose': '',
            'branch': 'Nasr City',
            'paying_account': 'Cash - JZ',
            'currency': 'EGP',
          },
        ],
        'orders': [
          {
            'invoice': 'ACC-SINV-2026-00123',
            'employee': 'HR-EMP-0001',
            'employee_name': 'Mona Adel',
            'customer': 'Mona Adel (Employee)',
            'customer_name': 'Mona Adel',
            'branch': 'Nasr City',
            'posting_date': '2026-08-20',
            'grand_total': 320.5,
            'outstanding_amount': 320.5,
            'status': 'Unpaid',
            'state': 'Received',
            'delivery_note': 'MAT-DN-2026-00045',
          },
          {
            'invoice': 'ACC-SINV-2026-00124',
            'employee': 'HR-EMP-0001',
            'employee_name': 'Mona Adel',
            'customer': 'Mona Adel (Employee)',
            'customer_name': 'Mona Adel',
            'branch': 'Nasr City',
            'posting_date': '2026-08-22',
            'grand_total': 200.0,
            'outstanding_amount': 100.0,
            'status': 'Partly Paid',
            'state': 'Delivered',
            'delivery_note': '',
          },
          {
            'invoice': 'ACC-SINV-2026-00125',
            'employee': '',
            'employee_name': '',
            'customer': 'Walk-in Staff',
            'customer_name': 'Walk-in Staff',
            'branch': 'Dokki',
            'posting_date': '2026-08-25',
            'grand_total': 300.0,
            'outstanding_amount': 300.0,
            'status': 'Unpaid',
            'state': 'Out for delivery',
            'delivery_note': '',
          },
        ],
      };

  // ── EmployeeLedger ──────────────────────────────────────────────────

  group('EmployeeLedger.fromJson', () {
    test('parses the full contract payload', () {
      final ledger = EmployeeLedger.fromJson(fullPayload());

      expect(ledger.hrmsAvailable, isTrue);
      expect(ledger.fromDate, '2026-05-31');
      expect(ledger.toDate, '2026-08-29');
      expect(ledger.branch, 'all');
      expect(ledger.employees, hasLength(2));
      expect(ledger.advances, hasLength(2));
      expect(ledger.orders, hasLength(3));
      expect(ledger.noticeCode, isNull);
      expect(ledger.notice, isNull);
      expect(ledger.hasNotice, isFalse);
      expect(ledger.isEmpty, isFalse);
    });

    test('the two halves add up to the total the summary reports', () {
      final summary = EmployeeLedger.fromJson(fullPayload()).summary;

      expect(
        summary.advanceOutstanding + summary.orderOutstanding,
        closeTo(summary.totalOutstanding, 0.001),
      );
      expect(summary.advanceCount, 2);
      expect(summary.orderCount, 3);
      expect(summary.employeeCount, 2);
      expect(summary.currency, 'EGP');
    });

    test('survives a payload with every optional list and map missing', () {
      final ledger = EmployeeLedger.fromJson({'success': true});

      expect(ledger.hrmsAvailable, isFalse);
      expect(ledger.fromDate, '');
      expect(ledger.employees, isEmpty);
      expect(ledger.advances, isEmpty);
      expect(ledger.orders, isEmpty);
      expect(ledger.summary.totalOutstanding, 0);
      expect(ledger.summary.employeeCount, 0);
      expect(ledger.isEmpty, isTrue);
    });

    test('skips non-map entries rather than throwing on a ragged list', () {
      final ledger = EmployeeLedger.fromJson({
        'employees': ['junk', null, 42],
        'advances': 'not-a-list',
        'orders': null,
      });

      expect(ledger.employees, isEmpty);
      expect(ledger.advances, isEmpty);
      expect(ledger.orders, isEmpty);
    });

    test('exposes a notice_code as information, keeping the payload', () {
      final payload = fullPayload()
        ..['hrms_available'] = false
        ..['notice_code'] = 'hrms_unavailable'
        ..['notice'] = 'HRMS is not installed.';

      final ledger = EmployeeLedger.fromJson(payload);

      expect(ledger.hrmsAvailable, isFalse);
      expect(ledger.noticeCode, 'hrms_unavailable');
      expect(ledger.notice, 'HRMS is not installed.');
      expect(ledger.hasNotice, isTrue);
      // hrms_available: false is not an error — the orders half still stands.
      expect(ledger.orders, hasLength(3));
    });

    test('treats a blank notice_code as no notice at all', () {
      final ledger = EmployeeLedger.fromJson({
        'notice_code': '   ',
        'notice': '',
      });

      expect(ledger.noticeCode, isNull);
      expect(ledger.notice, isNull);
      expect(ledger.hasNotice, isFalse);
    });

    test('groups the detail lines under the employee that owns them', () {
      final ledger = EmployeeLedger.fromJson(fullPayload());

      expect(ledger.advancesFor('HR-EMP-0001'), hasLength(2));
      expect(ledger.ordersFor('HR-EMP-0001'), hasLength(2));
      // The unmatched bucket is keyed by the empty employee id.
      expect(ledger.advancesFor(''), isEmpty);
      expect(ledger.ordersFor(''), hasLength(1));
      expect(ledger.ordersFor('')[0].invoice, 'ACC-SINV-2026-00125');
      expect(ledger.ordersFor('HR-EMP-9999'), isEmpty);
    });
  });

  // ── EmployeeLedgerRow ───────────────────────────────────────────────

  group('EmployeeLedgerRow.fromJson', () {
    test('parses a matched employee row', () {
      final row = EmployeeLedgerRow.fromJson(
        (fullPayload()['employees'] as List)[0] as Map<String, dynamic>,
      );

      expect(row.employee, 'HR-EMP-0001');
      expect(row.displayName, 'Mona Adel');
      expect(row.user, 'mona@example.com');
      expect(row.branch, 'Nasr City');
      expect(row.customer, 'Mona Adel (Employee)');
      expect(row.advanceOutstanding, 3500.0);
      expect(row.orderOutstanding, 420.5);
      expect(row.totalOutstanding, 3920.5);
      expect(row.advanceCount, 2);
      expect(row.orderCount, 2);
      expect(row.isUnmatched, isFalse);
    });

    test('an order with no employee falls back to the customer name', () {
      final row = EmployeeLedgerRow.fromJson(
        (fullPayload()['employees'] as List)[1] as Map<String, dynamic>,
      );

      expect(row.employee, '');
      expect(row.isUnmatched, isTrue);
      // Never blank: the money is real and has to be labelled with something.
      expect(row.displayName, 'Walk-in Staff');
      expect(row.totalOutstanding, 300.0);
    });

    test('falls back to the employee id when the name is missing', () {
      final row = EmployeeLedgerRow.fromJson({'employee': 'HR-EMP-0007'});

      expect(row.employeeName, 'HR-EMP-0007');
      expect(row.displayName, 'HR-EMP-0007');
      expect(row.isUnmatched, isFalse);
    });

    test('an entirely empty row still yields a blank, not a crash', () {
      final row = EmployeeLedgerRow.fromJson(const {});

      expect(row.displayName, '');
      expect(row.totalOutstanding, 0);
      expect(row.isUnmatched, isTrue);
    });
  });

  // ── EmployeeLedgerAdvance ───────────────────────────────────────────

  group('EmployeeLedgerAdvance.fromJson', () {
    test('parses an advance line', () {
      final advance = EmployeeLedgerAdvance.fromJson(
        (fullPayload()['advances'] as List)[1] as Map<String, dynamic>,
      );

      expect(advance.name, 'HR-EAD-2026-00002');
      expect(advance.employee, 'HR-EMP-0001');
      expect(advance.employeeName, 'Mona Adel');
      expect(advance.postingDate, '2026-08-10');
      expect(advance.amount, 2000.0);
      expect(advance.paidAmount, 2000.0);
      expect(advance.claimedAmount, 500.0);
      expect(advance.returnAmount, 0.0);
      // balance is what is still owed, and is not amount minus claimed by
      // definition — it is whatever the backend computed.
      expect(advance.balance, 1500.0);
      expect(advance.status, 'Partly Claimed and Returned');
      expect(advance.purpose, '');
      expect(advance.payingAccount, 'Cash - JZ');
      expect(advance.currency, 'EGP');
    });

    test('accepts money sent as a string', () {
      final advance = EmployeeLedgerAdvance.fromJson({
        'name': 'HR-EAD-2026-00003',
        'amount': '1500.75',
        'balance': '1500.75',
        'paid_amount': ' 1500.75 ',
      });

      expect(advance.amount, 1500.75);
      expect(advance.balance, 1500.75);
      expect(advance.paidAmount, 1500.75);
    });

    test('an unparseable amount reads as zero rather than throwing', () {
      final advance = EmployeeLedgerAdvance.fromJson({
        'name': 'HR-EAD-2026-00004',
        'amount': 'n/a',
        'balance': null,
      });

      expect(advance.amount, 0);
      expect(advance.balance, 0);
    });
  });

  // ── EmployeeLedgerOrder ─────────────────────────────────────────────

  group('EmployeeLedgerOrder.fromJson', () {
    test('parses an order line', () {
      final order = EmployeeLedgerOrder.fromJson(
        (fullPayload()['orders'] as List)[1] as Map<String, dynamic>,
      );

      expect(order.invoice, 'ACC-SINV-2026-00124');
      expect(order.employee, 'HR-EMP-0001');
      expect(order.customerName, 'Mona Adel');
      expect(order.branch, 'Nasr City');
      expect(order.postingDate, '2026-08-22');
      expect(order.grandTotal, 200.0);
      // Only the outstanding half is a debt; the grand total is context.
      expect(order.outstandingAmount, 100.0);
      expect(order.status, 'Partly Paid');
      expect(order.state, 'Delivered');
      expect(order.deliveryNote, '');
    });

    test('labels the order with the invoice name minus the ACC-SINV- prefix', () {
      final order = EmployeeLedgerOrder.fromJson({
        'invoice': 'ACC-SINV-2026-00123',
      });

      expect(order.displayId, '2026-00123');
    });

    test('an order with no employee keeps the customer name as the label', () {
      final order = EmployeeLedgerOrder.fromJson(
        (fullPayload()['orders'] as List)[2] as Map<String, dynamic>,
      );

      expect(order.employee, '');
      expect(order.employeeName, 'Walk-in Staff');
      expect(order.customerName, 'Walk-in Staff');
      expect(order.outstandingAmount, 300.0);
    });

    test('falls back to the customer id when no name is sent', () {
      final order = EmployeeLedgerOrder.fromJson({
        'invoice': 'ACC-SINV-2026-00126',
        'customer': 'CUST-0009',
      });

      expect(order.customerName, 'CUST-0009');
      expect(order.employeeName, 'CUST-0009');
    });
  });

  // ── Balance vs activity ─────────────────────────────────────────────
  //
  // The window scopes which rows are LISTED; the outstanding amounts are an
  // all-time balance. The two are allowed to disagree, and the UI leans on
  // that being parsed faithfully.

  group('EmployeeLedgerSummary.outstandingIsAllTime', () {
    test('parses an explicit true', () {
      final ledger = EmployeeLedger.fromJson(fullPayload());
      expect(ledger.summary.outstandingIsAllTime, isTrue);
    });

    test('parses an explicit false', () {
      final payload = fullPayload();
      (payload['summary'] as Map)['outstanding_is_all_time'] = false;

      expect(
        EmployeeLedger.fromJson(payload).summary.outstandingIsAllTime,
        isFalse,
      );
    });

    test('defaults to true when the field is absent', () {
      final payload = fullPayload();
      (payload['summary'] as Map).remove('outstanding_is_all_time');

      // An older backend that had not split balance from activity yet. Default
      // to all-time so the label never under-claims what the number covers.
      expect(
        EmployeeLedger.fromJson(payload).summary.outstandingIsAllTime,
        isTrue,
      );
    });

    test('defaults to true on a summary that is missing entirely', () {
      final ledger = EmployeeLedger.fromJson({'success': true});
      expect(ledger.summary.outstandingIsAllTime, isTrue);
    });

    test('accepts a Frappe Check sent as 0 or 1', () {
      EmployeeLedgerSummary parse(Object? raw) =>
          EmployeeLedgerSummary.fromJson({'outstanding_is_all_time': raw});

      expect(parse(1).outstandingIsAllTime, isTrue);
      expect(parse(0).outstandingIsAllTime, isFalse);
      expect(parse('false').outstandingIsAllTime, isFalse);
      expect(parse('True').outstandingIsAllTime, isTrue);
      expect(parse('').outstandingIsAllTime, isTrue);
    });

    test('is present on the no_branch_assigned empty state', () {
      final ledger = EmployeeLedger.fromJson({
        'success': true,
        'hrms_available': true,
        'notice_code': 'no_branch_assigned',
        'notice': 'You have no branch assigned.',
        'summary': {
          'advance_outstanding': 0,
          'order_outstanding': 0,
          'total_outstanding': 0,
          'advance_count': 0,
          'order_count': 0,
          'employee_count': 0,
          'currency': 'EGP',
          'outstanding_is_all_time': true,
        },
        'employees': [],
        'advances': [],
        'orders': [],
      });

      expect(ledger.noticeCode, 'no_branch_assigned');
      expect(ledger.summary.outstandingIsAllTime, isTrue);
      expect(ledger.summary.totalOutstanding, 0);
      expect(ledger.isEmpty, isTrue);
    });
  });

  group('a balance older than the window', () {
    /// The debt predates from_date, so nothing is listed for this person but
    /// the money is still owed. Dropping or zeroing either half here is the
    /// bug this group exists to catch.
    Map<String, dynamic> stalePayload() => {
          'success': true,
          'hrms_available': true,
          'filters': {
            'from_date': '2026-08-01',
            'to_date': '2026-08-29',
            'branch': 'all',
            'employee': null,
          },
          'summary': {
            'advance_outstanding': 900.0,
            'order_outstanding': 100.0,
            'total_outstanding': 1000.0,
            'advance_count': 0,
            'order_count': 0,
            'employee_count': 1,
            'currency': 'EGP',
            'outstanding_is_all_time': true,
          },
          'employees': [
            {
              'employee': 'HR-EMP-0042',
              'employee_name': 'Karim Fouad',
              'branch': 'Dokki',
              'advance_outstanding': 900.0,
              'order_outstanding': 100.0,
              'total_outstanding': 1000.0,
              'advance_count': 0,
              'order_count': 0,
            },
            {
              'employee': 'HR-EMP-0043',
              'employee_name': 'Sara Nabil',
              'branch': 'Dokki',
              'advance_outstanding': 0,
              'order_outstanding': 0,
              'total_outstanding': 0,
              'advance_count': 1,
              'order_count': 0,
            },
          ],
          'advances': [
            {
              'name': 'HR-EAD-2026-00099',
              'employee': 'HR-EMP-0043',
              'employee_name': 'Sara Nabil',
              'posting_date': '2026-08-15',
              'amount': 500.0,
              'balance': 0.0,
              'status': 'Claimed',
              'currency': 'EGP',
            },
          ],
          'orders': [],
        };

    test('a non-zero outstanding survives zero listed counts', () {
      final ledger = EmployeeLedger.fromJson(stalePayload());
      final karim = ledger.employees.first;

      expect(karim.totalOutstanding, 1000.0);
      expect(karim.advanceOutstanding, 900.0);
      expect(karim.orderOutstanding, 100.0);
      // Counts describe rows LISTED in the window and are legitimately zero
      // against real money — they must never be read as the balance.
      expect(karim.advanceCount, 0);
      expect(karim.orderCount, 0);
      expect(ledger.advancesFor(karim.employee), isEmpty);
      expect(ledger.ordersFor(karim.employee), isEmpty);
    });

    test('somebody with activity but nothing owed is still listed, at zero', () {
      final ledger = EmployeeLedger.fromJson(stalePayload());
      final sara = ledger.employees[1];

      expect(sara.totalOutstanding, 0);
      expect(sara.advanceCount, 1);
      expect(ledger.advancesFor(sara.employee), hasLength(1));
    });

    test('employee_count counts balances, not listed people', () {
      final ledger = EmployeeLedger.fromJson(stalePayload());

      // Two rows are listed, but only one of them owes anything.
      expect(ledger.employees, hasLength(2));
      expect(ledger.summary.employeeCount, 1);
      expect(ledger.summary.employeeCount, lessThan(ledger.employees.length));
    });

    test('the window bounds the listed rows, not the totals', () {
      final ledger = EmployeeLedger.fromJson(stalePayload());

      expect(ledger.fromDate, '2026-08-01');
      expect(ledger.summary.advanceCount, 0);
      expect(ledger.summary.orderCount, 0);
      expect(ledger.summary.totalOutstanding, 1000.0);
      expect(ledger.summary.outstandingIsAllTime, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';

void main() {
  group('ShiftBalanceDetail', () {
    test('fromJson parses all fields', () {
      final detail = ShiftBalanceDetail.fromJson({
        'mode_of_payment': 'Cash',
        'opening_amount': 500,
        'expected_amount': 1500.75,
        'closing_amount': 1400,
        'difference': -100.75,
      });

      expect(detail.modeOfPayment, 'Cash');
      expect(detail.openingAmount, 500);
      expect(detail.expectedAmount, 1500.75);
      expect(detail.closingAmount, 1400);
      expect(detail.difference, -100.75);
    });

    test('fromJson handles string numbers', () {
      final detail = ShiftBalanceDetail.fromJson({
        'mode_of_payment': 'Card',
        'opening_amount': '200.5',
        'closing_amount': '300',
      });

      expect(detail.openingAmount, 200.5);
      expect(detail.closingAmount, 300);
    });

    test('fromJson defaults missing fields to 0', () {
      final detail = ShiftBalanceDetail.fromJson({});

      expect(detail.modeOfPayment, '');
      expect(detail.openingAmount, 0);
      expect(detail.expectedAmount, 0);
      expect(detail.closingAmount, 0);
      expect(detail.difference, 0);
    });

    test('toJson round-trips correctly', () {
      const detail = ShiftBalanceDetail(
        modeOfPayment: 'Cash',
        openingAmount: 1000,
        expectedAmount: 2000,
        closingAmount: 1900,
        difference: -100,
      );

      final json = detail.toJson();
      final restored = ShiftBalanceDetail.fromJson(json);

      expect(restored.modeOfPayment, detail.modeOfPayment);
      expect(restored.openingAmount, detail.openingAmount);
      expect(restored.closingAmount, detail.closingAmount);
      expect(restored.difference, detail.difference);
    });
  });

  group('ShiftInvoice', () {
    test('fromJson parses all fields', () {
      final inv = ShiftInvoice.fromJson({
        'name': 'INV-2024-001',
        'customer': 'CUST-001',
        'customer_name': 'John Doe',
        'grand_total': 150.5,
        'net_total': 140,
        'status': 'Paid',
        'posting_date': '2024-01-15',
        'creation': '2024-01-15 10:30:00',
        'delivery_status': 'delivered',
      });

      expect(inv.name, 'INV-2024-001');
      expect(inv.customer, 'CUST-001');
      expect(inv.customerName, 'John Doe');
      expect(inv.grandTotal, 150.5);
      expect(inv.netTotal, 140);
      expect(inv.status, 'Paid');
      expect(inv.postingDate, '2024-01-15');
      expect(inv.deliveryStatus, 'delivered');
    });

    test('fromJson defaults missing numeric fields to 0', () {
      final inv = ShiftInvoice.fromJson({
        'name': 'X',
        'customer': 'C',
        'customer_name': 'N',
      });

      expect(inv.grandTotal, 0);
      expect(inv.netTotal, 0);
      expect(inv.status, '');
    });
  });

  group('ShiftAccountMovement', () {
    test('fromJson parses numeric fields from strings', () {
      final mov = ShiftAccountMovement.fromJson({
        'name': 'GL-001',
        'voucher_type': 'Sales Invoice',
        'voucher_no': 'INV-001',
        'debit': '500.5',
        'credit': '0',
        'amount': '500.5',
        'posting_date': '2024-03-01',
        'remarks': 'Payment received',
      });

      expect(mov.name, 'GL-001');
      expect(mov.voucherType, 'Sales Invoice');
      expect(mov.debit, 500.5);
      expect(mov.credit, 0);
      expect(mov.amount, 500.5);
      expect(mov.remarks, 'Payment received');
    });
  });

  group('ShiftEntry', () {
    test('fromJson parses standard fields', () {
      final entry = ShiftEntry.fromJson({
        'name': 'POS-OPN-2024-00001',
        'pos_profile': 'Main Store',
        'status': 'Open',
        'user': 'cashier@test.com',
        'employee_name': 'Ahmed Cashier',
        'period_start_date': '2024-03-10 08:00:00',
        'balance_details': [
          {'mode_of_payment': 'Cash', 'opening_amount': 1000},
        ],
      });

      expect(entry.name, 'POS-OPN-2024-00001');
      expect(entry.posProfile, 'Main Store');
      expect(entry.status, 'Open');
      expect(entry.openedByUser, 'cashier@test.com');
      expect(entry.openedByName, 'Ahmed Cashier');
      expect(entry.periodStartDate, isNotNull);
      expect(entry.balanceDetails, hasLength(1));
    });

    test('fromJson falls back to owner field for openedByUser', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
        'owner': 'owner@test.com',
      });

      expect(entry.openedByUser, 'owner@test.com');
    });

    test('fromJson falls back to created_by for openedByUser', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
        'created_by': 'creator@test.com',
      });

      expect(entry.openedByUser, 'creator@test.com');
    });

    test('fromJson prefers user over owner over created_by', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
        'user': 'user@test.com',
        'owner': 'owner@test.com',
        'created_by': 'creator@test.com',
      });

      expect(entry.openedByUser, 'user@test.com');
    });

    test('fromJson falls back to full_name for openedByName', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
        'full_name': 'Full Name User',
      });

      expect(entry.openedByName, 'Full Name User');
    });

    test('fromJson returns empty strings when owner fields missing', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
      });

      expect(entry.openedByUser, '');
      expect(entry.openedByName, '');
    });

    test('fromJson uses opening_entry as name fallback', () {
      final entry = ShiftEntry.fromJson({
        'opening_entry': 'OPN-0001',
        'pos_profile': 'P1',
        'status': 'Open',
      });

      expect(entry.name, 'OPN-0001');
    });

    test('fromJson handles empty balance_details', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
        'balance_details': [],
      });

      expect(entry.balanceDetails, isEmpty);
    });

    test('fromJson handles null balance_details', () {
      final entry = ShiftEntry.fromJson({
        'name': 'E1',
        'pos_profile': 'P1',
        'status': 'Open',
      });

      expect(entry.balanceDetails, isEmpty);
    });
  });

  group('ShiftSummary', () {
    test('fromJson parses full response', () {
      final summary = ShiftSummary.fromJson({
        'opening_entry': 'POS-OPN-001',
        'status': 'Closed',
        'period_start_date': '2024-03-10 08:00:00',
        'invoice_count': 15,
        'grand_total': 7500.5,
        'net_total': 7000,
        'payment_reconciliation': [
          {'mode_of_payment': 'Cash', 'opening_amount': 500, 'closing_amount': 8000},
        ],
        'sales_invoices': [
          {'name': 'INV-001', 'customer': 'C1', 'customer_name': 'Customer One', 'grand_total': 100},
        ],
        'account_movements': [
          {'name': 'GL-001', 'voucher_type': 'Sales Invoice', 'voucher_no': 'INV-001', 'debit': 100},
        ],
        'account': 'Cash - JRZ',
        'account_balance': 20000,
        'total_sales': 7500.5,
        'total_outflows': 500,
        'net_movement': 7000.5,
        'journal_entry': 'JE-001',
        'closing_entry': 'POS-CL-001',
        'amounts_hidden': 0,
        'variance_visible': 1,
      });

      expect(summary.openingEntry, 'POS-OPN-001');
      expect(summary.status, 'Closed');
      expect(summary.invoiceCount, 15);
      expect(summary.grandTotal, 7500.5);
      expect(summary.paymentReconciliation, hasLength(1));
      expect(summary.salesInvoices, hasLength(1));
      expect(summary.accountMovements, hasLength(1));
      expect(summary.account, 'Cash - JRZ');
      expect(summary.accountBalance, 20000);
      expect(summary.totalSales, 7500.5);
      expect(summary.totalOutflows, 500);
      expect(summary.netMovement, 7000.5);
      expect(summary.journalEntry, 'JE-001');
      expect(summary.closingEntry, 'POS-CL-001');
      expect(summary.amountsHidden, isFalse);
      expect(summary.varianceVisible, isTrue);
    });

    test('fromJson parses blind pre-close summary without money fields', () {
      final summary = ShiftSummary.fromJson({
        'opening_entry': 'POS-OPN-001',
        'status': 'Open',
        'invoice_count': 3,
        'amounts_hidden': 1,
        'variance_visible': 0,
        'courier_close_block': {
          'blocked': true,
          'pos_profile': 'Nasr city',
          'transaction_count': 2,
          'invoice_count': 1,
          'party_count': 1,
          'net_balance': 160,
          'parties': [
            {
              'party_type': 'Employee',
              'party': 'HR-EMP-0001',
              'display_name': 'Ali Courier',
              'transaction_count': 2,
              'invoice_count': 1,
              'net_balance': 160,
              'invoices': ['ACC-SINV-0001'],
            },
          ],
        },
        'payment_reconciliation': [
          {'mode_of_payment': 'Cash'},
        ],
      });

      expect(summary.openingEntry, 'POS-OPN-001');
      expect(summary.invoiceCount, 3);
      expect(summary.amountsHidden, isTrue);
      expect(summary.varianceVisible, isFalse);
      expect(summary.paymentReconciliation, hasLength(1));
      expect(summary.paymentReconciliation.first.modeOfPayment, 'Cash');
      expect(summary.paymentReconciliation.first.expectedAmount, 0);
      expect(summary.totalSales, 0);
      expect(summary.accountMovements, isEmpty);
      expect(summary.courierCloseBlock, isNotNull);
      expect(summary.courierCloseBlock!.blocked, isTrue);
      expect(summary.courierCloseBlock!.parties, hasLength(1));
      expect(summary.courierCloseBlock!.parties.first.displayName, 'Ali Courier');
      expect(summary.courierCloseBlock!.parties.first.invoices, ['ACC-SINV-0001']);
    });

    test('fromJson defaults lists and numbers when missing', () {
      final summary = ShiftSummary.fromJson({
        'opening_entry': 'E1',
        'status': 'Open',
      });

      expect(summary.invoiceCount, 0);
      expect(summary.grandTotal, 0);
      expect(summary.paymentReconciliation, isEmpty);
      expect(summary.salesInvoices, isEmpty);
      expect(summary.accountMovements, isEmpty);
      expect(summary.accountBalance, 0);
      expect(summary.amountsHidden, isFalse);
      expect(summary.varianceVisible, isFalse);
      expect(summary.courierCloseBlock, isNull);
    });
  });
}

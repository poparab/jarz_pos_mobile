import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';

void main() {
  group('KanbanColumn', () {
    test('fromJson falls back to defaults', () {
      final column = KanbanColumn.fromJson({});
      expect(column.id, isEmpty);
      expect(column.name, isEmpty);
      expect(column.color, '#F5F5F5');
    });

    test('toJson roundtrips values', () {
      final column = KanbanColumn(id: 'received', name: 'Received', color: '#FFFFFF');
      final json = column.toJson();
      expect(json, {
        'id': 'received',
        'name': 'Received',
        'color': '#FFFFFF',
      });
    });
  });

  group('InvoiceItem', () {
    test('fromJson coerces numeric fields to double', () {
      final item = InvoiceItem.fromJson({
        'item_code': 'ITEM-001',
        'item_name': 'Sample',
        'qty': 2,
        'rate': 49,
        'amount': 98,
      });
      expect(item.qty, 2);
      expect(item.rate, 49);
      expect(item.amount, 98);
      expect(item.quantity, 2);
    });

    test('toJson mirrors original data', () {
      final item = InvoiceItem(
        itemCode: 'ITEM-002',
        itemName: 'Widget',
        qty: 1.5,
        rate: 10,
        amount: 15,
      );
      expect(item.toJson(), {
        'item_code': 'ITEM-002',
        'item_name': 'Widget',
        'qty': 1.5,
        'rate': 10,
        'amount': 15,
      });
    });
  });

  group('InvoiceCard', () {
    InvoiceCard buildCard({
      Map<String, dynamic>? overrides,
    }) {
      final base = {
        'name': 'SINV-0001',
        'invoice_id_short': '0001',
        'customer_name': 'John Doe',
        'customer': 'CUST-0001',
        'territory': 'Metro',
        'status': 'Received',
        'posting_date': '2024-01-01',
        'grand_total': 150,
        'net_total': 130,
        'total_taxes_and_charges': 20,
        'full_address': '123 Test Street',
        'items': [
          {
            'item_code': 'ITEM-001',
            'item_name': 'Sample',
            'qty': 2,
            'rate': 50,
            'amount': 100,
          }
        ],
      };
      return InvoiceCard.fromJson({
        ...base,
        if (overrides != null) ...overrides,
      });
    }

    test('fromJson normalises booleans and phone fallbacks', () {
      final card = buildCard(overrides: {
        'shipping_income': 5,
        'shipping_expense': 3,
        'customerPhone': '9999',
        'doc_status': 'Paid',
        'courier': 'Courier A',
        'settlement_mode': 'cash',
        'party_type': 'Employee',
        'party': 'EMP-1',
        'has_unsettled_courier_txn': 'True',
        'sales_partner': 'Partner-1',
        'is_pickup': 'true',
      });

      expect(card.shippingIncome, 5);
      expect(card.shippingExpense, 3);
      expect(card.customerPhone, '9999');
      expect(card.docStatus, 'Paid');
      expect(card.courier, 'Courier A');
      expect(card.settlementMode, 'cash');
      expect(card.courierPartyType, 'Employee');
      expect(card.courierParty, 'EMP-1');
      expect(card.hasUnsettledCourierTxn, isTrue);
      expect(card.salesPartner, 'Partner-1');
      expect(card.isPickup, isTrue);
    });

    test('delivery helpers parse future slot windows', () {
      final card = buildCard(overrides: {
        'delivery_date': '2099-06-01',
        'delivery_time_from': '13:30:00',
        'delivery_duration': '00:30:00',
      });

      expect(
        card.deliveryStartDateTime,
        DateTime(2099, 6, 1, 13, 30),
      );
      expect(
        card.deliveryDurationParsed,
        const Duration(minutes: 30),
      );
        expect(card.deliveryDateTimeLabel, '2099-06-01 13:30\u201314:00');
    });

    test('delivery helpers honour backend slot label when provided', () {
      final card = buildCard(overrides: {
        'delivery_slot_label': '  Afternoon Slot  ',
        'delivery_date': '2099-06-01',
        'delivery_time_from': '10:00:00',
      });

      expect(card.deliveryDateTimeLabel, 'Afternoon Slot');
    });

    test('toJson mirrors key invoice fields', () {
      final card = buildCard(overrides: {
        'shipping_income': 8,
        'shipping_expense': 2,
        'customer_phone': '12345',
        'sales_partner': 'Partner-X',
        'is_pickup': 1,
      });

      final json = card.toJson();
      expect(json['name'], 'SINV-0001');
      expect(json['invoice_id_short'], '0001');
      expect(json['shipping_income'], 8);
      expect(json['shipping_expense'], 2);
      expect(json['customer_phone'], '12345');
      expect(json['sales_partner'], 'Partner-X');
      expect(json['is_pickup'], isTrue);
      expect(json['items'], hasLength(1));
      expect(json['items'][0]['item_code'], 'ITEM-001');
    });

    test('derived helpers expose canonically named fields', () {
      final card = buildCard(overrides: {
        'status': 'Processing',
        'posting_date': '2030-12-25',
      });

      expect(card.name, 'SINV-0001');
      expect(card.columnId, 'processing');
      expect(card.date, '2030-12-25');
      expect(card.total, 150);
      expect(card.taxAmount, 20);
      expect(card.address, '123 Test Street');
      expect(card.itemsCount, 1);
    });

    test('copyWith preserves unspecified fields', () {
      final card = buildCard(overrides: {
        'status': 'Received',
        'shipping_income': 5,
      });

      final updated = card.copyWith(status: 'Packed');
      expect(updated.status, 'Packed');
      expect(updated.shippingIncome, 5);
      expect(updated.invoiceIdShort, '0001');
      expect(updated.customerName, 'John Doe');
    });
  });

  group('KanbanFilters', () {
    test('hasFilters returns false when empty', () {
      const filters = KanbanFilters();
      expect(filters.hasFilters, isFalse);
    });

    test('hasFilters true when any field set', () {
      const filters = KanbanFilters(customer: 'CUST-1');
      expect(filters.hasFilters, isTrue);
    });

    test('copyWith keeps unset fields', () {
      const filters = KanbanFilters(searchTerm: 'abc');
      final updated = filters.copyWith(status: 'Paid');
      expect(updated.searchTerm, 'abc');
      expect(updated.status, 'Paid');
      expect(updated.hasFilters, isTrue);
    });
  });

  group('KanbanState', () {
    test('copyWith updates provided fields and preserves others', () {
      final card = InvoiceCard.fromJson({
        'name': 'INV-1',
        'invoice_id_short': 'INV',
        'customer_name': 'Alice',
        'customer': 'CUST',
        'territory': 'Metro',
        'status': 'Received',
        'posting_date': '2024-01-01',
        'grand_total': 10,
        'net_total': 9,
        'total_taxes_and_charges': 1,
        'full_address': 'Address',
        'items': const [],
      });
      final state = KanbanState(
        columns: [KanbanColumn(id: 'received', name: 'Received', color: '#FFF')],
        invoices: {
          'received': [card],
        },
        isLoading: true,
        error: 'oops',
        filters: const KanbanFilters(searchTerm: 'a'),
        customers: [CustomerOption(customer: 'CUST', customerName: 'Alice')],
        transitioningInvoices: {'INV-1'},
        selectedBranches: {'Main'},
      );

      final updated = state.copyWith(
        isLoading: false,
        error: null,
        selectedBranches: {'Main', 'Branch-2'},
      );

      expect(updated.isLoading, isFalse);
      expect(updated.error, isNull);
      expect(updated.columns, same(state.columns));
      expect(updated.invoices['received'], hasLength(1));
      expect(updated.filters.searchTerm, 'a');
      expect(updated.selectedBranches, {'Main', 'Branch-2'});
      expect(updated.transitioningInvoices, {'INV-1'});
    });
  });
}

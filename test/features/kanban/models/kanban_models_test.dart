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

    test('fromJson preserves bundle and discount metadata', () {
      final item = InvoiceItem.fromJson({
        'item_code': 'BUNDLE-001',
        'item_name': 'Meal Deal',
        'qty': 1,
        'rate': 0,
        'amount': 0,
        'price_list_rate': 120,
        'discount_percentage': 100,
        'is_bundle_parent': 1,
        'bundle_code': 'BDL-1',
      });

      expect(item.priceListRate, 120);
      expect(item.discountPercentage, 100);
      expect(item.isBundleParent, isTrue);
      expect(item.bundleCode, 'BDL-1');
    });

    test('toJson mirrors original data', () {
      final item = InvoiceItem(
        itemCode: 'ITEM-002',
        itemName: 'Widget',
        qty: 1.5,
        rate: 10,
        amount: 15,
        priceListRate: 12,
        discountAmount: 2,
        isBundleChild: true,
        parentBundle: 'BDL-1',
        bundleGroupKey: 'ROW-FLAVOR-1',
        bundleGroupName: 'Flavor',
      );
      expect(item.toJson(), {
        'item_code': 'ITEM-002',
        'item_name': 'Widget',
        'qty': 1.5,
        'rate': 10,
        'amount': 15,
        'price_list_rate': 12,
        'discount_percentage': null,
        'discount_amount': 2,
        'is_bundle_parent': false,
        'is_bundle_child': true,
        'bundle_code': null,
        'parent_bundle': 'BDL-1',
        'bundle_group_key': 'ROW-FLAVOR-1',
        'bundle_group_name': 'Flavor',
      });
    });

    test('fromJson toJson preserves bundle group metadata', () {
      final item = InvoiceItem.fromJson({
        'item_code': 'ITEM-CHILD',
        'item_name': 'Child Item',
        'qty': 1,
        'rate': 50,
        'amount': 50,
        'is_bundle_child': 1,
        'parent_bundle': 'BDL-1',
        'bundle_group_key': 'ROW-FLAVOR-1',
        'bundle_group_name': 'Flavor',
      });

      expect(item.bundleGroupKey, 'ROW-FLAVOR-1');
      expect(item.bundleGroupName, 'Flavor');
      expect(item.toJson()['bundle_group_key'], 'ROW-FLAVOR-1');
      expect(item.toJson()['bundle_group_name'], 'Flavor');
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
        'note_count': '2',
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
      expect(card.noteCount, 2);
      expect(card.hasNotes, isTrue);
    });

    test('prefers custom kanban profile over submitted pos profile', () {
      final card = buildCard(overrides: {
        'pos_profile': 'Dokki',
        'custom_kanban_profile': 'Nasr city',
      });

      expect(card.posProfile, 'Nasr city');
    });

    test('should allow delivery slot and transfer actions through ready stage', () {
      for (final status in const ['Received', 'In Progress', 'Preparing', 'Ready']) {
        final card = buildCard(overrides: {'status': status});

        expect(card.canChangeDeliverySlot, isTrue, reason: status);
        expect(card.canTransferOrder, isTrue, reason: status);
      }
    });

    test('should hide delivery slot and transfer actions after ready or when canceled', () {
      for (final status in const [
        'Out for Delivery',
        'out_for_delivery',
        'Delivered',
        'Completed',
        'Cancelled',
        'Canceled',
      ]) {
        final card = buildCard(overrides: {'status': status});

        expect(card.canChangeDeliverySlot, isFalse, reason: status);
        expect(card.canTransferOrder, isFalse, reason: status);
      }
    });

    test('should keep delivery slot hidden for pickup before post-ready stages', () {
      final card = buildCard(overrides: {
        'status': 'Ready',
        'is_pickup': 1,
      });

      expect(card.canChangeDeliverySlot, isFalse);
      expect(card.canTransferOrder, isTrue);
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
      expect(card.deliveryDateTimeLabel, 'Jun 1 1:30 PM\u20132:00 PM');
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
        'posting_time': '18:45:00',
        'creation': '2026-06-01 18:40:00',
      });

      final json = card.toJson();
      expect(json['name'], 'SINV-0001');
      expect(json['invoice_id_short'], '0001');
      expect(json['shipping_income'], 8);
      expect(json['shipping_expense'], 2);
      expect(json['customer_phone'], '12345');
      expect(json['sales_partner'], 'Partner-X');
      expect(json['is_pickup'], isTrue);
      expect(json['posting_time'], '18:45:00');
      expect(json['creation'], '2026-06-01 18:40:00');
      expect(json['items'], hasLength(1));
      expect(json['items'][0]['item_code'], 'ITEM-001');
    });

    test('fromJson exposes posting timestamps for received ordering', () {
      final card = buildCard(overrides: {
        'posting_time': '18:45:00',
        'creation': '2026-06-01 18:40:00',
      });

      expect(card.postingTime, '18:45:00');
      expect(card.creation, '2026-06-01 18:40:00');
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

    test('effectiveCollectionMethod prefers actual method for unsettled unpaid courier cards', () {
      final card = buildCard(overrides: {
        'payment_method': 'Cash',
        'actual_payment_method': 'Instapay',
        'has_unsettled_courier_txn': 1,
        'outstanding_amount': 150,
      });

      expect(card.isFullyPaid, isFalse);
      expect(card.effectiveCollectionMethod, 'Instapay');
    });

    test('effectiveCollectionMethod falls back to requested payment method when needed', () {
      final card = buildCard(overrides: {
        'payment_method': 'Cash',
        'actual_payment_method': 'Instapay',
        'has_unsettled_courier_txn': 0,
        'outstanding_amount': 150,
      });

      expect(card.effectiveCollectionMethod, 'Cash');
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

      final timestamped = card.copyWith(
        postingTime: '14:30:00',
        creation: '2026-06-01 14:00:00',
      );
      expect(timestamped.postingTime, '14:30:00');
      expect(timestamped.creation, '2026-06-01 14:00:00');
    });

    test('copyWith updates note count without disturbing other fields', () {
      final card = buildCard(overrides: {
        'status': 'Received',
        'note_count': 0,
      });

      final updated = card.copyWith(noteCount: 3);

      expect(updated.noteCount, 3);
      expect(updated.hasNotes, isTrue);
      expect(updated.id, card.id);
      expect(updated.status, card.status);
    });
  });

  group('InvoiceNote', () {
    test('fromJson parses custom invoice note payload', () {
      final note = InvoiceNote.fromJson({
        'name': 'JIN-2026-00001',
        'sales_invoice': 'SINV-0001',
        'pos_profile': 'Main',
        'note': 'Call customer before dispatch',
        'added_by': 'test@example.com',
        'added_by_full_name': 'Test User',
        'added_on': '2026-06-04 13:15:00',
      });

      expect(note.name, 'JIN-2026-00001');
      expect(note.salesInvoice, 'SINV-0001');
      expect(note.posProfile, 'Main');
      expect(note.note, 'Call customer before dispatch');
      expect(note.addedByFullName, 'Test User');
      expect(note.addedOnDateTime, DateTime.parse('2026-06-04 13:15:00'));
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

    test('copyWith clears nullable fields when requested', () {
      final filters = KanbanFilters(
        searchTerm: '  ',
        customer: 'CUST-1',
        status: 'Paid',
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 31),
        amountFrom: 100,
        amountTo: 500,
      );

      final updated = filters.copyWith(
        clearCustomer: true,
        clearStatus: true,
        clearDateFrom: true,
        clearDateTo: true,
        clearAmountFrom: true,
        clearAmountTo: true,
      );

      expect(updated.customer, isNull);
      expect(updated.status, isNull);
      expect(updated.dateFrom, isNull);
      expect(updated.dateTo, isNull);
      expect(updated.amountFrom, isNull);
      expect(updated.amountTo, isNull);
      expect(updated.hasFilters, isFalse);
    });

    test('toJson trims search and omits empty nullable filters', () {
      const filters = KanbanFilters(
        searchTerm: '  inv-1  ',
        customer: '',
        status: '',
      );

      expect(filters.toJson(), {
        'searchTerm': 'inv-1',
        'dateFrom': null,
        'dateTo': null,
        'amountFrom': null,
        'amountTo': null,
      });
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

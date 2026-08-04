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

    test('fromJson reads the backend order, tolerating non-int encodings', () {
      expect(KanbanColumn.fromJson({'id': 'returned', 'order': 6}).order, 6);
      expect(KanbanColumn.fromJson({'id': 'returned', 'order': '6'}).order, 6);
      expect(KanbanColumn.fromJson({'id': 'returned', 'order': 6.0}).order, 6);
      expect(KanbanColumn.fromJson({'id': 'returned'}).order, isNull);
    });

    test('toJson emits order only when the backend supplied one', () {
      expect(
        KanbanColumn(id: 'returned', name: 'Returned', color: '#FFF', order: 6)
            .toJson()['order'],
        6,
      );
      expect(
        KanbanColumn(id: 'returned', name: 'Returned', color: '#FFF')
            .toJson()
            .containsKey('order'),
        isFalse,
      );
    });

    test('sorted puts the terminal Returned column last, after Cancelled', () {
      final shuffled = [
        KanbanColumn(id: 'returned', name: 'Returned', color: '#FFF', order: 6),
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF', order: 0),
        KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#FFF', order: 5),
        KanbanColumn(id: 'ready', name: 'Ready', color: '#FFF', order: 2),
      ];

      expect(
        KanbanColumn.sorted(shuffled).map((c) => c.id),
        ['received', 'ready', 'cancelled', 'returned'],
      );
    });

    test('sorted preserves server order when no column declares one', () {
      // An older backend sends no `order`; the board must look exactly as it
      // did before, not get re-shuffled.
      final asServed = [
        KanbanColumn(id: 'received', name: 'Received', color: '#FFF'),
        KanbanColumn(id: 'ready', name: 'Ready', color: '#FFF'),
        KanbanColumn(id: 'cancelled', name: 'Cancelled', color: '#FFF'),
      ];

      expect(
        KanbanColumn.sorted(asServed).map((c) => c.id),
        ['received', 'ready', 'cancelled'],
      );
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

    // ── Post-dispatch return ────────────────────────────────────────────
    test('fromJson reads the current return_status / returned_amount keys', () {
      final card = buildCard(overrides: {
        'return_status': 'Partially Returned',
        'returned_amount': 45.5,
      });

      expect(card.returnStatus, 'Partially Returned');
      expect(card.returnedAmount, 45.5);
      expect(card.isPartiallyReturned, isTrue);
      expect(card.isFullyReturned, isFalse);
      expect(card.hasReturn, isTrue);
    });

    test('fromJson still reads the legacy custom_return_status key', () {
      // Cards queued/cached before the rename must keep working.
      final card = buildCard(overrides: {
        'custom_return_status': 'Fully Returned',
      });

      expect(card.returnStatus, 'Fully Returned');
      expect(card.isFullyReturned, isTrue);
      expect(card.hasReturn, isTrue);
    });

    test('fromJson prefers return_status when both keys are present', () {
      final card = buildCard(overrides: {
        'return_status': 'Fully Returned',
        'custom_return_status': 'Partially Returned',
      });

      expect(card.returnStatus, 'Fully Returned');
      expect(card.isFullyReturned, isTrue);
    });

    test('fromJson treats missing return keys as "nothing returned"', () {
      // Old cached payloads carry neither key; this must not throw.
      final card = buildCard();

      expect(card.returnStatus, isNull);
      expect(card.returnedAmount, 0.0);
      expect(card.hasReturn, isFalse);
      expect(card.isFullyReturned, isFalse);
      expect(card.isPartiallyReturned, isFalse);
    });

    test('fromJson collapses a blank return status to null', () {
      final card = buildCard(overrides: {
        'return_status': '   ',
        'returned_amount': null,
      });

      expect(card.returnStatus, isNull);
      expect(card.hasReturn, isFalse);
      expect(card.returnedAmount, 0.0);
    });

    test('fromJson coerces a stringified returned_amount', () {
      expect(buildCard(overrides: {'returned_amount': '75.25'}).returnedAmount, 75.25);
      expect(buildCard(overrides: {'returned_amount': 12}).returnedAmount, 12.0);
      // Unparseable input degrades to zero rather than throwing.
      expect(buildCard(overrides: {'returned_amount': 'n/a'}).returnedAmount, 0.0);
    });

    test('return status matching is case and whitespace tolerant', () {
      final card = buildCard(overrides: {'return_status': ' fully returned '});

      expect(card.isFullyReturned, isTrue);
    });

    test('a fully returned order can neither be returned again nor cancelled', () {
      final card = buildCard(overrides: {
        'status': 'Returned',
        'return_status': 'Fully Returned',
      });

      expect(card.canReturn, isFalse);
      expect(card.canCancel, isFalse);
      expect(card.canChangeDeliverySlot, isFalse);
      expect(card.canTransferOrder, isFalse);
    });

    test('a partially returned order is not cancellable either', () {
      // Its credit note already reversed part of the order; cancelling on top
      // would double-reverse it.
      final card = buildCard(overrides: {
        'status': 'Received',
        'return_status': 'Partially Returned',
      });

      expect(card.canCancel, isFalse);
    });

    test('toJson round-trips the return fields through fromJson', () {
      final card = buildCard(overrides: {
        'return_status': 'Partially Returned',
        'returned_amount': 30.0,
      });

      final json = card.toJson();
      expect(json['return_status'], 'Partially Returned');
      expect(json['returned_amount'], 30.0);
      // Legacy key is still written so an older build can read our payload.
      expect(json['custom_return_status'], 'Partially Returned');

      final restored = InvoiceCard.fromJson(json);
      expect(restored.returnStatus, 'Partially Returned');
      expect(restored.returnedAmount, 30.0);
      expect(restored.isPartiallyReturned, isTrue);
    });

    test('copyWith carries the return fields forward', () {
      final card = buildCard(overrides: {
        'return_status': 'Fully Returned',
        'returned_amount': 99.0,
      });

      final moved = card.copyWith(status: 'Returned');
      expect(moved.returnStatus, 'Fully Returned');
      expect(moved.returnedAmount, 99.0);
      expect(moved.isFullyReturned, isTrue);
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

    test('fromJson parses latest_note for the card face preview', () {
      final card = buildCard(overrides: {
        'note_count': 2,
        'latest_note': 'Customer wants the bell, not the doorknock',
      });

      expect(card.latestNote, 'Customer wants the bell, not the doorknock');
      expect(card.latestNotePreview, 'Customer wants the bell, not the doorknock');
      expect(card.hasNotes, isTrue);
    });

    test('fromJson trims latest_note and treats blank as absent', () {
      final padded = buildCard(overrides: {
        'note_count': 1,
        'latest_note': '  Ring twice  ',
      });
      expect(padded.latestNote, 'Ring twice');

      final blank = buildCard(overrides: {
        'note_count': 1,
        'latest_note': '   ',
      });
      expect(blank.latestNote, isNull);
      expect(blank.latestNotePreview, isNull);
    });

    test('fromJson leaves latestNote null when backend omits latest_note', () {
      final card = buildCard(overrides: {'note_count': 0});

      expect(card.latestNote, isNull);
      expect(card.latestNotePreview, isNull);
      expect(card.hasNotes, isFalse);
    });

    test('toJson round-trips latest_note', () {
      final card = buildCard(overrides: {
        'note_count': 1,
        'latest_note': 'Fragile — handle with care',
      });

      expect(card.toJson()['latest_note'], 'Fragile — handle with care');
    });

    test('copyWith sets latestNote and preserves it when unspecified', () {
      final card = buildCard(overrides: {'note_count': 0});

      final withNote = card.copyWith(noteCount: 1, latestNote: 'Call on arrival');
      expect(withNote.latestNote, 'Call on arrival');

      final untouched = withNote.copyWith(status: 'Preparing');
      expect(untouched.latestNote, 'Call on arrival');
      expect(untouched.status, 'Preparing');
    });

    test('copyWith clears latestNote only when clearLatestNote is set', () {
      final card = buildCard(overrides: {
        'note_count': 1,
        'latest_note': 'Call on arrival',
      });

      // Passing null must NOT clear — that is the hand-written copyWith contract.
      expect(card.copyWith(latestNote: null).latestNote, 'Call on arrival');

      final cleared = card.copyWith(noteCount: 0, clearLatestNote: true);
      expect(cleared.latestNote, isNull);
      expect(cleared.latestNotePreview, isNull);
      expect(cleared.hasNotes, isFalse);
    });

    group('hasNoteSignal', () {
      // The live staging bug: backend swallowed a query error and returned
      // note_count 0 on every card while latest_note was present and correct.
      // The note affordances must survive that on the text alone.
      test('is true when latest_note is present but note_count is zero', () {
        final card = buildCard(overrides: {
          'note_count': 0,
          'latest_note': 'Customer will pay cash on delivery',
        });

        expect(card.hasNotes, isFalse, reason: 'count is genuinely 0');
        expect(card.latestNotePreview, 'Customer will pay cash on delivery');
        expect(card.hasNoteSignal, isTrue,
            reason: 'note text alone must keep the affordances alive');
      });

      test('is true when latest_note is present but note_count is absent', () {
        final card = buildCard(overrides: {'latest_note': 'Leave at reception'});

        expect(card.noteCount, 0);
        expect(card.hasNotes, isFalse);
        expect(card.hasNoteSignal, isTrue);
      });

      // Mirror case: count says notes exist, text missing (older payloads).
      test('is true when note_count is positive but latest_note is absent', () {
        final card = buildCard(overrides: {'note_count': 3});

        expect(card.latestNotePreview, isNull);
        expect(card.hasNotes, isTrue);
        expect(card.hasNoteSignal, isTrue,
            reason: 'count alone still warrants the tap-to-read prompt');
      });

      test('is false when there is neither a count nor note text', () {
        final card = buildCard(overrides: {'note_count': 0});

        expect(card.hasNotes, isFalse);
        expect(card.latestNotePreview, isNull);
        expect(card.hasNoteSignal, isFalse);
      });

      test('is false when latest_note is blank and note_count is zero', () {
        final card = buildCard(overrides: {
          'note_count': 0,
          'latest_note': '   ',
        });

        expect(card.hasNoteSignal, isFalse,
            reason: 'whitespace-only text is not a signal');
      });

      test('both signals present still reads as a single true', () {
        final card = buildCard(overrides: {
          'note_count': 2,
          'latest_note': 'Ring the bell twice',
        });

        expect(card.hasNotes, isTrue);
        expect(card.hasNoteSignal, isTrue);
      });

      test('hasNotes keeps its strict count-only meaning', () {
        // Guards the split: hasNotes must not be repurposed into the combined
        // signal — the count badge relies on it meaning "we have a real count".
        final textOnly = buildCard(overrides: {
          'note_count': 0,
          'latest_note': 'Text but no count',
        });

        expect(textOnly.hasNotes, isFalse);
        expect(textOnly.hasNoteSignal, isTrue);
      });

      test('clearing notes via copyWith drops the combined signal too', () {
        final card = buildCard(overrides: {
          'note_count': 1,
          'latest_note': 'Call on arrival',
        });
        expect(card.hasNoteSignal, isTrue);

        final cleared = card.copyWith(noteCount: 0, clearLatestNote: true);
        expect(cleared.hasNoteSignal, isFalse);
      });
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

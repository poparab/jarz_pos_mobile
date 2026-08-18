// ignore_for_file: overridden_fields

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/labels/data/labels_repository.dart';
import 'package:jarz_pos/src/features/labels/models/label_models.dart';
import 'package:jarz_pos/src/features/labels/state/labels_notifier.dart';

import '../../helpers/mock_services.dart';

/// Minimal Dio stand-in that captures POST bodies and returns canned data.
class _FakeDio with DioMixin implements Dio {
  final List<({String path, dynamic data})> calls = [];
  dynamic nextMessage = const <String, dynamic>{};

  @override
  BaseOptions options = BaseOptions();

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls.add((path: path, data: data));
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: createSuccessResponse(data: nextMessage) as T,
    );
  }
}

Map<String, dynamic> _labelJson({
  String name = 'JLBL-00001',
  String customer = 'CUST-A',
  String customerName = 'Cafe X',
  String title = 'Mango',
  String? item = 'Mango Jar',
  String? size = 'Medium',
  String? storageLocation = 'Factory - J',
  String status = 'Reorder Now',
  int onHand = 40,
  dynamic daysOfCover = 4.0,
  bool wePrint = true,
  bool tracked = true,
  int labelsPerSheet = 21,
  int suggestedSheets = 3,
  double stockValue = 0,
  double avgCost = 0,
  List<Map<String, dynamic>> openOrders = const [],
}) {
  return {
    'name': name,
    'customer': customer,
    'customer_name': customerName,
    'label_title': title,
    'item': item,
    'size': size,
    'storage_location': storageLocation,
    'enabled': 1,
    'we_print': wePrint ? 1 : 0,
    'tracked': tracked ? 1 : 0,
    'labels_per_unit': 1,
    'labels_per_sheet': labelsPerSheet,
    'default_print_sheets': 2,
    'on_hand_qty': onHand,
    'min_stock_qty': 0,
    'stock_value': stockValue,
    'avg_cost_per_label': avgCost,
    'suggested_print_sheets': suggestedSheets,
    'suggested_print_qty': suggestedSheets * labelsPerSheet,
    'avg_daily_usage': 10.0,
    'days_of_cover': daysOfCover,
    'consumed_in_window': 300,
    'usage_window_days': 30,
    'status': status,
    'needs_attention': ['Out of Stock', 'Reorder Now', 'Reorder Soon']
        .contains(status),
    'lead_days': 4,
    'lead_days_min': 2,
    'lead_days_max': 3,
    'rest_day': 'Friday',
    'expected_ready_if_ordered_today': '2026-08-23',
    'runs_out_on': '2026-08-21',
    'open_print_orders': openOrders,
    'last_movement_on': '2026-08-16',
    'last_counted_on': null,
    'notes': null,
  };
}

LabelsState _stateWith(List<Map<String, dynamic>> labels) {
  return const LabelsState.initial().copyWith(
    dashboard: LabelDashboard.fromJson({
      'summary': const <String, dynamic>{},
      'labels': labels,
      'locations': const <String>[],
      'settings': const <String, dynamic>{},
    }),
  );
}

void main() {
  group('LabelStatus', () {
    test('parses every server status', () {
      expect(LabelStatus.parse('Out of Stock'), LabelStatus.outOfStock);
      expect(LabelStatus.parse('Reorder Now'), LabelStatus.reorderNow);
      expect(LabelStatus.parse('Reorder Soon'), LabelStatus.reorderSoon);
      expect(LabelStatus.parse('On Order'), LabelStatus.onOrder);
      expect(LabelStatus.parse('OK'), LabelStatus.ok);
      expect(LabelStatus.parse('Not Tracked'), LabelStatus.notTracked);
    });

    test('an unrecognised status degrades instead of throwing', () {
      // A server that grew a new status must not crash an older build.
      expect(LabelStatus.parse('Something New'), LabelStatus.unknown);
      expect(LabelStatus.parse(null), LabelStatus.unknown);
    });

    test('only the three shortage states count as needing attention', () {
      expect(LabelStatus.outOfStock.needsAttention, isTrue);
      expect(LabelStatus.reorderNow.needsAttention, isTrue);
      expect(LabelStatus.reorderSoon.needsAttention, isTrue);
      // A batch already at the printer is handled, not outstanding.
      expect(LabelStatus.onOrder.needsAttention, isFalse);
      expect(LabelStatus.ok.needsAttention, isFalse);
      expect(LabelStatus.notTracked.needsAttention, isFalse);
    });
  });

  group('CustomerLabel parsing', () {
    test('reads the computed fields the server sends', () {
      final label = CustomerLabel.fromJson(_labelJson());
      expect(label.customerName, 'Cafe X');
      expect(label.onHandQty, 40);
      expect(label.daysOfCover, 4.0);
      expect(label.status, LabelStatus.reorderNow);
      expect(label.needsAttention, isTrue);
      expect(label.runsOutOn, DateTime(2026, 8, 21));
      // v2 fields.
      expect(label.item, 'Mango Jar');
      expect(label.size, 'Medium');
      expect(label.storageLocation, 'Factory - J');
      expect(label.labelsPerSheet, 21);
      expect(label.defaultPrintSheets, 2);
      expect(label.suggestedPrintSheets, 3);
      expect(label.suggestedPrintQty, 63);
    });

    test('a null days-of-cover stays null rather than becoming zero', () {
      // Zero cover would render as "runs out today" for a label that simply has
      // no usage history yet — the two must not be confused.
      final label = CustomerLabel.fromJson(_labelJson(daysOfCover: null));
      expect(label.daysOfCover, isNull);
    });

    test('falls back to the customer id when the name is missing', () {
      final json = _labelJson()..['customer_name'] = '';
      expect(CustomerLabel.fromJson(json).customerName, 'CUST-A');
    });

    test('missing list fields parse as empty, not null', () {
      final json = _labelJson()..remove('open_print_orders');
      final label = CustomerLabel.fromJson(json);
      expect(label.openPrintOrders, isEmpty);
      expect(label.movements, isEmpty);
      expect(label.nextArrival, isNull);
    });

    test('missing money fields read as zero, not a crash', () {
      final json = _labelJson()
        ..remove('stock_value')
        ..remove('avg_cost_per_label');
      final label = CustomerLabel.fromJson(json);
      expect(label.stockValue, 0);
      expect(label.avgCostPerLabel, 0);
    });

    test('sheet equivalence: N sheets = N x labels-per-sheet', () {
      final label = CustomerLabel.fromJson(_labelJson(labelsPerSheet: 21));
      expect(label.labelsForSheets(2), 42);
      expect(label.labelsForSheets(1), 21);
      // No geometry known → no equivalence claimed, rather than a made-up 0x.
      final unknown = CustomerLabel.fromJson(_labelJson(labelsPerSheet: 0));
      expect(unknown.labelsForSheets(2), 0);
      // Nonsense input never yields a negative label count.
      expect(label.labelsForSheets(-3), 0);
      expect(label.labelsForSheets(0), 0);
    });
  });

  group('groupLabelsByCustomer', () {
    test('groups rows per customer, preserving board order', () {
      final labels = [
        _labelJson(name: 'A1', customer: 'A', customerName: 'Alpha',
            status: 'Out of Stock'),
        _labelJson(name: 'B1', customer: 'B', customerName: 'Beta',
            status: 'Reorder Soon'),
        _labelJson(name: 'A2', customer: 'A', customerName: 'Alpha',
            status: 'OK'),
      ].map(CustomerLabel.fromJson).toList();

      final groups = groupLabelsByCustomer(labels);
      expect(groups.map((g) => g.customer), ['A', 'B']);
      expect(groups.first.labels.map((l) => l.name), ['A1', 'A2']);
      expect(groups.last.labels.map((l) => l.name), ['B1']);
    });

    test('the header stripe carries the WORST status in the group', () {
      final labels = [
        _labelJson(name: 'A1', customer: 'A', status: 'OK'),
        _labelJson(name: 'A2', customer: 'A', status: 'Out of Stock'),
        _labelJson(name: 'A3', customer: 'A', status: 'On Order'),
      ].map(CustomerLabel.fromJson).toList();

      final group = groupLabelsByCustomer(labels).single;
      expect(group.worstStatus, LabelStatus.outOfStock);
      expect(group.needsAttentionCount, 1);
    });

    test('an empty list groups to an empty list', () {
      expect(groupLabelsByCustomer(const []), isEmpty);
    });
  });

  group('LabelPrintOrder', () {
    LabelPrintOrder order(String status, String? due) =>
        LabelPrintOrder.fromJson({
          'name': 'JLPO-00001',
          'qty': 42,
          'qty_sheets': 2,
          'status': status,
          'requested_on': '2026-08-17',
          'expected_ready_date': due,
        });

    test('open statuses are the three pre-arrival ones', () {
      expect(order('Requested', null).isOpen, isTrue);
      expect(order('Printing', null).isOpen, isTrue);
      expect(order('Ready', null).isOpen, isTrue);
      expect(order('Received', null).isOpen, isFalse);
      expect(order('Cancelled', null).isOpen, isFalse);
    });

    test('a past due date on an open batch is overdue', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final due =
          '${past.year}-${past.month.toString().padLeft(2, '0')}-${past.day.toString().padLeft(2, '0')}';
      expect(order('Printing', due).isOverdue, isTrue);
    });

    test('a received batch is never overdue, however late it was', () {
      final past = DateTime.now().subtract(const Duration(days: 30));
      final due =
          '${past.year}-${past.month.toString().padLeft(2, '0')}-${past.day.toString().padLeft(2, '0')}';
      expect(order('Received', due).isOverdue, isFalse);
    });

    test('no due date means overdue cannot be claimed', () {
      expect(order('Requested', null).isOverdue, isFalse);
    });

    test('carries sheets alongside labels', () {
      final o = order('Requested', null);
      expect(o.qtySheets, 2);
      expect(o.qty, 42);
    });
  });

  group('LabelPrintOrder billing', () {
    LabelPrintOrder billedAs(dynamic billingStatus, {String status = 'Received'}) =>
        LabelPrintOrder.fromJson({
          'name': 'JLPO-00001',
          'qty': 42,
          'qty_sheets': 2,
          'status': status,
          'billing_status': billingStatus,
          'purchase_invoice':
              billingStatus == 'Billed' ? 'ACC-PINV-2026-00001' : null,
        });

    test('parses Billed with its purchase invoice', () {
      final order = billedAs('Billed');
      expect(order.isBilled, isTrue);
      expect(order.awaitsBill, isFalse);
      expect(order.purchaseInvoice, 'ACC-PINV-2026-00001');
    });

    test('a missing billing status defaults to Unbilled', () {
      // Rows written before the money fields existed carry no billing_status;
      // "not billed" is the truthful default, never "billed".
      final order = billedAs(null);
      expect(order.billingStatus, 'Unbilled');
      expect(order.isBilled, isFalse);
      expect(order.awaitsBill, isTrue);
    });

    test('awaitsBill is only true once the batch is actually received', () {
      final open = billedAs(null, status: 'Printing');
      expect(open.isBilled, isFalse);
      expect(open.awaitsBill, isFalse);
    });
  });

  group('LabelsState filtering', () {
    final labels = [
      _labelJson(name: 'A', customer: 'CUST-A', customerName: 'Alpha Cafe',
          status: 'Out of Stock', storageLocation: 'Factory - J'),
      _labelJson(name: 'B', customer: 'CUST-B', customerName: 'Beta Roasters',
          status: 'Reorder Soon', storageLocation: 'Branch - Zamalek'),
      _labelJson(
        name: 'C',
        customer: 'CUST-C',
        customerName: 'Gamma Coffee',
        status: 'On Order',
        openOrders: [
          {'name': 'JLPO-1', 'qty': 42, 'qty_sheets': 2, 'status': 'Printing'}
        ],
      ),
      _labelJson(name: 'D', customer: 'CUST-D', customerName: 'Delta Beans',
          status: 'OK'),
      _labelJson(
        name: 'E',
        customer: 'CUST-E',
        customerName: 'Epsilon Bakery',
        status: 'Not Tracked',
        wePrint: false,
        tracked: false,
      ),
    ];

    test('the default filter shows only what needs printing', () {
      final state = _stateWith(labels);
      expect(state.filter, LabelFilter.attention);
      expect(state.visibleLabels.map((l) => l.name), ['A', 'B']);
    });

    test('All shows every row including the customers who print their own', () {
      final state = _stateWith(labels).copyWith(filter: LabelFilter.all);
      expect(state.visibleLabels.length, 5);
    });

    test('At printer picks up anything with a batch in flight', () {
      final state = _stateWith(labels).copyWith(filter: LabelFilter.onOrder);
      expect(state.visibleLabels.map((l) => l.name), ['C']);
    });

    test('Customer prints isolates the untracked labels', () {
      final state = _stateWith(labels).copyWith(filter: LabelFilter.notTracked);
      expect(state.visibleLabels.map((l) => l.name), ['E']);
    });

    test('search narrows within the active filter, case-insensitively', () {
      final state = _stateWith(labels)
          .copyWith(filter: LabelFilter.all, search: 'gamma');
      expect(state.visibleLabels.map((l) => l.name), ['C']);
    });

    test('search that matches nothing yields an empty list, not everything', () {
      final state =
          _stateWith(labels).copyWith(filter: LabelFilter.all, search: 'zzz');
      expect(state.visibleLabels, isEmpty);
    });

    test('the location filter narrows to labels stored there', () {
      final state = _stateWith(labels)
          .copyWith(filter: LabelFilter.all, location: 'Branch - Zamalek');
      expect(state.visibleLabels.map((l) => l.name), ['B']);
    });

    test('clearing the location shows every location again', () {
      final narrowed = _stateWith(labels)
          .copyWith(filter: LabelFilter.all, location: 'Branch - Zamalek');
      final cleared = narrowed.copyWith(clearLocation: true);
      expect(cleared.visibleLabels.length, 5);
    });

    test('visibleGroups groups the filtered rows by customer', () {
      final state = _stateWith(labels).copyWith(filter: LabelFilter.all);
      expect(state.visibleGroups.length, 5); // five distinct customers
      expect(state.visibleGroups.first.labels, hasLength(1));
    });
  });

  group('LabelsRepository wire format', () {
    test('dashboard posts the documented flags', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'summary': <String, dynamic>{},
        'labels': <dynamic>[],
        'locations': <dynamic>[],
        'settings': <String, dynamic>{},
      };

      await LabelsRepository(dio).getDashboard(onlyAttention: true);

      expect(dio.calls.single.path, ApiEndpoints.getLabelDashboard);
      final body = dio.calls.single.data as Map;
      expect(body['only_attention'], 1);
      expect(body['include_untracked'], 1);
    });

    test('dashboard parses the distinct storage locations', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'summary': <String, dynamic>{},
        'labels': <dynamic>[],
        'locations': ['Branch - Zamalek', 'Factory - J'],
        'settings': <String, dynamic>{},
      };

      final dashboard = await LabelsRepository(dio).getDashboard();
      expect(dashboard.locations, ['Branch - Zamalek', 'Factory - J']);
    });

    test('updateLabel sends only the fields the caller passed', () async {
      final dio = _FakeDio();
      dio.nextMessage = _labelJson();

      await LabelsRepository(dio).updateLabel(label: 'JLBL-1', minStockQty: 250);

      final body = dio.calls.single.data as Map;
      expect(body['label'], 'JLBL-1');
      expect(body['min_stock_qty'], 250);
      // Untouched policy must not be overwritten with a default.
      expect(body.containsKey('we_print'), isFalse);
      expect(body.containsKey('default_print_sheets'), isFalse);
      expect(body.containsKey('storage_location'), isFalse);
      expect(body.containsKey('label_title'), isFalse);
    });

    test('an empty storage location is still sent, so it can be cleared', () async {
      final dio = _FakeDio();
      dio.nextMessage = _labelJson();

      await LabelsRepository(dio)
          .updateLabel(label: 'JLBL-1', storageLocation: '');

      final body = dio.calls.single.data as Map;
      expect(body.containsKey('storage_location'), isTrue);
      expect(body['storage_location'], '');
    });

    test('recordCount unwraps the label from the envelope', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'movement': 'JLMV-00002',
        'delta': -5,
        'label': _labelJson(onHand: 35),
      };

      final label = await LabelsRepository(dio)
          .recordCount(label: 'JLBL-1', countedQty: 35);

      expect(dio.calls.single.path, ApiEndpoints.recordLabelCount);
      expect((dio.calls.single.data as Map)['counted_qty'], 35);
      expect(label.onHandQty, 35);
    });

    test('createPrintOrder posts SHEETS and omits blank optional fields', () async {
      final dio = _FakeDio();
      dio.nextMessage = {'print_order': 'JLPO-1', 'label': _labelJson()};

      await LabelsRepository(dio)
          .createPrintOrder(label: 'JLBL-1', qtySheets: 3, printerName: '   ');

      expect(dio.calls.single.path, ApiEndpoints.createLabelPrintOrder);
      final body = dio.calls.single.data as Map;
      expect(body['qty_sheets'], 3);
      // Labels are computed server-side from the sheets — never sent.
      expect(body.containsKey('qty'), isFalse);
      expect(body.containsKey('printer_name'), isFalse);
      expect(body.containsKey('supplier'), isFalse);
      expect(body.containsKey('total_cost'), isFalse);
    });

    test('createPrintOrder carries supplier and net cost when given', () async {
      final dio = _FakeDio();
      dio.nextMessage = {'print_order': 'JLPO-1', 'label': _labelJson()};

      await LabelsRepository(dio).createPrintOrder(
        label: 'JLBL-1',
        qtySheets: 2,
        supplier: 'Print House Co',
        totalCost: 350.5,
      );

      final body = dio.calls.single.data as Map;
      expect(body['supplier'], 'Print House Co');
      expect(body['total_cost'], 350.5);
    });

    test('billPrintOrder posts to bill_print_order and unwraps the label', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'print_order': 'JLPO-1',
        'purchase_invoice': 'ACC-PINV-2026-00001',
        'label': _labelJson(stockValue: 350.5, avgCost: 8.35),
      };

      final label = await LabelsRepository(dio).billPrintOrder(
        printOrder: 'JLPO-1',
        supplier: 'Print House Co',
        totalCost: 350.5,
        billNo: 'PH-118',
      );

      expect(dio.calls.single.path, ApiEndpoints.billLabelPrintOrder);
      final body = dio.calls.single.data as Map;
      expect(body['print_order'], 'JLPO-1');
      expect(body['supplier'], 'Print House Co');
      expect(body['total_cost'], 350.5);
      expect(body['bill_no'], 'PH-118');
      expect(label.stockValue, 350.5);
    });

    test('setupCustomerLabels serialises flavours as a JSON list', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'created': ['JLBL-1', 'JLBL-2'],
        'skipped': [
          {'item_code': 'Mango Jar', 'label': 'JLBL-0'}
        ],
        'price_list': null,
        'labels': <dynamic>[],
        'summary': <String, dynamic>{},
      };

      final result = await LabelsRepository(dio).setupCustomerLabels(
        customer: 'CUST-A',
        flavours: const [
          LabelSetupFlavour(itemCode: 'Berry Jar', openingQty: 30),
          LabelSetupFlavour(itemCode: 'Lemon Jar'),
        ],
        storageLocation: 'Factory - J',
        defaultPrintSheets: 2,
      );

      expect(dio.calls.single.path, ApiEndpoints.setupCustomerLabels);
      final body = dio.calls.single.data as Map;
      expect(body['customer'], 'CUST-A');
      final flavours = body['flavours'] as List;
      expect(flavours, hasLength(2));
      expect(flavours.first, {'item_code': 'Berry Jar', 'opening_qty': 30});
      // Zero opening stock is simply omitted — the server treats absent as 0.
      expect(flavours.last, {'item_code': 'Lemon Jar'});
      expect(body['storage_location'], 'Factory - J');
      expect(body['default_print_sheets'], 2);
      expect(body['we_print'], 1);

      expect(result.createdCount, 2);
      expect(result.skippedCount, 1);
      expect(result.skippedItems, ['Mango Jar']);
    });

    test('flavour options parse with sources and tracked flags', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'customer': 'CUST-A',
        'price_list': 'Cafe X Prices',
        'flavours': [
          {
            'item_code': 'Mango Jar',
            'item_name': 'Mango',
            'size': 'Medium',
            'sources': ['price_list', 'history', 'label'],
            'has_label': 1,
            'label': 'JLBL-1',
          },
          {
            'item_code': 'Berry Jar',
            'item_name': 'Berry',
            'size': 'Large',
            'sources': ['history'],
            'has_label': 0,
            'label': null,
          },
        ],
      };

      final options = await LabelsRepository(dio).getFlavourOptions('CUST-A');

      expect(dio.calls.single.path, ApiEndpoints.getLabelFlavourOptions);
      expect(options.priceList, 'Cafe X Prices');
      expect(options.flavours, hasLength(2));

      final tracked = options.flavours.first;
      expect(tracked.hasLabel, isTrue);
      expect(tracked.label, 'JLBL-1');
      expect(tracked.onPriceList, isTrue);
      expect(tracked.orderedBefore, isTrue);

      final fresh = options.flavours.last;
      expect(fresh.hasLabel, isFalse);
      expect(fresh.onPriceList, isFalse);
      expect(fresh.orderedBefore, isTrue);
      expect(fresh.size, 'Large');
    });

    test('alert count maps the badge payload', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'needs_attention': 3,
        'out_of_stock': 1,
        'reorder_now': 1,
        'reorder_soon': 1,
      };

      final summary = await LabelsRepository(dio).getAlertCount();

      expect(dio.calls.single.path, ApiEndpoints.getLabelAlertCount);
      expect(summary.needsAttention, 3);
      // The badge's urgency split: out of stock plus print-now.
      expect(summary.urgent, 2);
    });
  });

  group('LabelSettings fallbacks', () {
    test('an empty payload still describes the real lead time and sheets', () {
      // A partial response must never render "0-0 working days" or "0 per sheet".
      const s = LabelSettings.fallback();
      final parsed = LabelSettings.fromJson(const {});
      expect(parsed.leadDaysMin, s.leadDaysMin);
      expect(parsed.leadDaysMax, s.leadDaysMax);
      expect(parsed.restDay, s.restDay);
      expect(parsed.bufferDays, s.bufferDays);
      expect(parsed.sheetMedium, 21);
      expect(parsed.sheetLarge, 18);
      expect(parsed.defaultPrintSheets, 2);
    });

    test('an explicit zero buffer is honoured, unlike a zero lead time', () {
      final parsed = LabelSettings.fromJson(const {
        'buffer_days': 0,
        'lead_days_max': 0,
      });
      expect(parsed.bufferDays, 0);
      expect(parsed.leadDaysMax, 3);
    });

    test('flags the server sends are respected', () {
      final parsed = LabelSettings.fromJson(const {'alerts_enabled': 0});
      expect(parsed.alertsEnabled, isFalse);
      expect(parsed.autoConsume, isTrue);
    });

    test('sheet geometry from the server wins over the fallback', () {
      final parsed = LabelSettings.fromJson(const {
        'sheet_medium': 24,
        'sheet_large': 15,
        'default_print_sheets': 4,
        'accounting_ready': 1,
      });
      expect(parsed.sheetMedium, 24);
      expect(parsed.sheetLarge, 15);
      expect(parsed.defaultPrintSheets, 4);
      expect(parsed.accountingReady, isTrue);
    });
  });
}

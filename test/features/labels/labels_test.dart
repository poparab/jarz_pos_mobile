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
  String title = 'Default',
  String status = 'Reorder Now',
  int onHand = 40,
  dynamic daysOfCover = 4.0,
  bool wePrint = true,
  bool tracked = true,
  List<Map<String, dynamic>> openOrders = const [],
}) {
  return {
    'name': name,
    'customer': customer,
    'customer_name': customerName,
    'label_title': title,
    'enabled': 1,
    'we_print': wePrint ? 1 : 0,
    'tracked': tracked ? 1 : 0,
    'applies_to_item_group': null,
    'labels_per_unit': 1,
    'on_hand_qty': onHand,
    'min_stock_qty': 0,
    'reorder_qty': 500,
    'suggested_print_qty': 500,
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

    test('display title hides the "Default" label name', () {
      expect(CustomerLabel.fromJson(_labelJson()).displayTitle, 'Cafe X');
      expect(
        CustomerLabel.fromJson(_labelJson(title: '250g')).displayTitle,
        'Cafe X · 250g',
      );
    });

    test('missing list fields parse as empty, not null', () {
      final json = _labelJson()..remove('open_print_orders');
      final label = CustomerLabel.fromJson(json);
      expect(label.openPrintOrders, isEmpty);
      expect(label.movements, isEmpty);
      expect(label.nextArrival, isNull);
    });
  });

  group('LabelPrintOrder', () {
    LabelPrintOrder order(String status, String? due) =>
        LabelPrintOrder.fromJson({
          'name': 'JLPO-00001',
          'qty': 500,
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
  });

  group('LabelsState filtering', () {
    final labels = [
      _labelJson(name: 'A', customerName: 'Alpha Cafe', status: 'Out of Stock'),
      _labelJson(name: 'B', customerName: 'Beta Roasters', status: 'Reorder Soon'),
      _labelJson(
        name: 'C',
        customerName: 'Gamma Coffee',
        status: 'On Order',
        openOrders: [
          {'name': 'JLPO-1', 'qty': 500, 'status': 'Printing'}
        ],
      ),
      _labelJson(name: 'D', customerName: 'Delta Beans', status: 'OK'),
      _labelJson(
        name: 'E',
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
  });

  group('LabelsRepository wire format', () {
    test('dashboard posts the documented flags', () async {
      final dio = _FakeDio();
      dio.nextMessage = {
        'summary': <String, dynamic>{},
        'labels': <dynamic>[],
        'settings': <String, dynamic>{},
      };

      await LabelsRepository(dio).getDashboard(onlyAttention: true);

      expect(dio.calls.single.path, ApiEndpoints.getLabelDashboard);
      final body = dio.calls.single.data as Map;
      expect(body['only_attention'], 1);
      expect(body['include_untracked'], 1);
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
      expect(body.containsKey('reorder_qty'), isFalse);
      expect(body.containsKey('label_title'), isFalse);
    });

    test('an empty item group is still sent, so the scope can be cleared', () async {
      final dio = _FakeDio();
      dio.nextMessage = _labelJson();

      await LabelsRepository(dio)
          .updateLabel(label: 'JLBL-1', appliesToItemGroup: '');

      final body = dio.calls.single.data as Map;
      expect(body.containsKey('applies_to_item_group'), isTrue);
      expect(body['applies_to_item_group'], '');
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

    test('createPrintOrder omits blank optional fields', () async {
      final dio = _FakeDio();
      dio.nextMessage = {'print_order': 'JLPO-1', 'label': _labelJson()};

      await LabelsRepository(dio)
          .createPrintOrder(label: 'JLBL-1', qty: 500, printerName: '   ');

      final body = dio.calls.single.data as Map;
      expect(body['qty'], 500);
      expect(body.containsKey('printer_name'), isFalse);
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
    test('an empty payload still describes the real lead time', () {
      // A partial response must never render "0-0 working days".
      const s = LabelSettings.fallback();
      final parsed = LabelSettings.fromJson(const {});
      expect(parsed.leadDaysMin, s.leadDaysMin);
      expect(parsed.leadDaysMax, s.leadDaysMax);
      expect(parsed.restDay, s.restDay);
      expect(parsed.bufferDays, s.bufferDays);
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
  });
}

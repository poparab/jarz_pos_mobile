// Courier alerts: JSON parsing (defensive), repository wire shape (the "All"
// filter merges three status calls, acknowledge payload) and the label helpers.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/courier_alerts/data/courier_alert_models.dart';
import 'package:jarz_pos/src/features/courier_alerts/data/courier_alerts_repository.dart';
import 'package:jarz_pos/src/features/courier_alerts/presentation/courier_alert_labels.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Object? Function(RequestOptions options) respond = (_) => const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'message': respond(options)}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _alert({
  String name = 'CA-0001',
  String type = 'Detour',
  String severity = 'High',
  String status = 'Open',
  String? detectedOn = '2026-10-14 10:30:00',
}) => {
  'name': name,
  'anomaly_type': type,
  'severity': severity,
  'status': status,
  'detected_on': detectedOn,
  'party_type': 'Employee',
  'party': 'HR-EMP-1',
  'party_name': 'Mostafa',
  'branch': 'Maadi',
  'invoice': 'ACC-SINV-1',
  'details': 'Off route by 1.2 km',
};

void main() {
  group('CourierAlert.fromJson', () {
    test('parses a full row', () {
      final a = CourierAlert.fromJson(_alert());
      expect(a.name, 'CA-0001');
      expect(a.anomalyType, 'Detour');
      expect(a.severity, CourierAlertSeverity.high);
      expect(a.status, CourierAlertStatus.open);
      expect(a.isOpen, isTrue);
      expect(a.detectedOn, isNotNull);
      expect(a.courierLabel, 'Mostafa');
      expect(a.invoice, 'ACC-SINV-1');
      expect(a.branch, 'Maadi');
      expect(a.details, 'Off route by 1.2 km');
    });

    test('degrades blanks and unknown values instead of throwing', () {
      final a = CourierAlert.fromJson({
        'name': 'CA-2',
        'anomaly_type': 'Brand New Thing',
        'severity': 'weird',
        'status': null,
        'detected_on': 'not a date',
        'party_name': '  ',
        'party': 'HR-EMP-9',
      });
      expect(a.severity, CourierAlertSeverity.low);
      expect(a.status, CourierAlertStatus.open);
      expect(a.detectedOn, isNull);
      expect(a.partyName, isNull);
      expect(a.courierLabel, 'HR-EMP-9');
      expect(a.invoice, isNull);
    });

    test('reads reviewed and dismissed status case-insensitively', () {
      expect(
        parseCourierAlertStatus('Reviewed'),
        CourierAlertStatus.reviewed,
      );
      expect(
        parseCourierAlertStatus('dismissed'),
        CourierAlertStatus.dismissed,
      );
      expect(parseCourierAlertSeverity('MEDIUM'), CourierAlertSeverity.medium);
    });
  });

  group('result and counts', () {
    test('CourierAlertsResult reads alerts and totals', () {
      final r = CourierAlertsResult.fromJson({
        'alerts': [_alert(), _alert(name: 'CA-2', severity: 'Low')],
        'open_count': 7,
        'high_count': '2',
      });
      expect(r.alerts, hasLength(2));
      expect(r.openCount, 7);
      expect(r.highCount, 2);
      expect(r.counts.openCount, 7);
    });

    test('a missing or malformed body is an empty result', () {
      final r = CourierAlertsResult.fromJson({'alerts': 'nope'});
      expect(r.alerts, isEmpty);
      expect(r.openCount, 0);
      expect(CourierAlertCounts.fromJson({}).openCount, 0);
      expect(CourierAlertCounts.zero.highCount, 0);
    });
  });

  group('CourierAlertsRepository', () {
    late _Adapter adapter;
    late CourierAlertsRepository repository;

    setUp(() {
      adapter = _Adapter();
      repository = CourierAlertsRepository(Dio()..httpClientAdapter = adapter);
    });

    test('open-only is one POST with status Open', () async {
      adapter.respond = (_) => {
        'alerts': [_alert()],
        'open_count': 1,
        'high_count': 1,
      };
      final r = await repository.listAlerts(limit: 20);
      expect(adapter.requests, hasLength(1));
      final req = adapter.requests.single;
      expect(req.method, 'POST');
      expect(req.path, ApiEndpoints.courierListAlerts);
      expect(req.data, {'status': 'Open', 'limit': 20});
      expect(r.alerts.single.name, 'CA-0001');
    });

    test('All merges Open, Reviewed and Dismissed newest first', () async {
      adapter.respond = (o) {
        final status = (o.data as Map)['status'];
        return {
          'alerts': [
            if (status == 'Open')
              _alert(name: 'CA-open', detectedOn: '2026-10-14 09:00:00'),
            if (status == 'Reviewed')
              _alert(
                name: 'CA-rev',
                status: 'Reviewed',
                detectedOn: '2026-10-14 11:00:00',
              ),
            if (status == 'Dismissed')
              _alert(
                name: 'CA-dis',
                status: 'Dismissed',
                detectedOn: '2026-10-13 08:00:00',
              ),
          ],
          'open_count': 4,
          'high_count': 1,
        };
      };
      final r = await repository.listAlerts(openOnly: false, limit: 50);
      expect(
        adapter.requests.map((o) => (o.data as Map)['status']).toSet(),
        {'Open', 'Reviewed', 'Dismissed'},
      );
      expect(r.alerts.map((a) => a.name).toList(), [
        'CA-rev',
        'CA-open',
        'CA-dis',
      ]);
      expect(r.openCount, 4);
      expect(r.highCount, 1);
    });

    test('All respects the limit after merging', () async {
      adapter.respond = (o) => {
        'alerts': [
          _alert(name: 'a-${(o.data as Map)['status']}'),
          _alert(name: 'b-${(o.data as Map)['status']}'),
        ],
      };
      final r = await repository.listAlerts(openOnly: false, limit: 4);
      expect(r.alerts, hasLength(4));
    });

    test('acknowledge sends status and a trimmed note', () async {
      adapter.respond = (_) => _alert(status: 'Dismissed');
      final a = await repository.acknowledge(
        name: 'CA-0001',
        status: CourierAlertStatus.dismissed,
        note: '  road works  ',
      );
      final req = adapter.requests.single;
      expect(req.path, ApiEndpoints.courierAcknowledgeAlert);
      expect(req.data, {
        'name': 'CA-0001',
        'status': 'Dismissed',
        'note': 'road works',
      });
      expect(a.status, CourierAlertStatus.dismissed);
    });

    test('acknowledge leaves the note out when blank', () async {
      adapter.respond = (_) => _alert(status: 'Reviewed');
      await repository.acknowledge(
        name: 'CA-0001',
        status: CourierAlertStatus.reviewed,
        note: '   ',
      );
      expect(adapter.requests.single.data, {
        'name': 'CA-0001',
        'status': 'Reviewed',
      });
    });

    test('getCounts reads open and high totals', () async {
      adapter.respond = (_) => {'open_count': 3, 'high_count': 1};
      final c = await repository.getCounts();
      expect(adapter.requests.single.path, ApiEndpoints.courierAlertCounts);
      expect(c.openCount, 3);
      expect(c.highCount, 1);
    });
  });

  group('labels', () {
    test('every known anomaly type counts as known', () {
      for (final t in knownCourierAnomalyTypes) {
        expect(courierAlertTypeIsKnown(t), isTrue, reason: t);
      }
      expect(courierAlertTypeIsKnown('Something New'), isFalse);
    });

    test('severity colours are distinct', () {
      final colours = CourierAlertSeverity.values
          .map(courierAlertSeverityColor)
          .toSet();
      expect(colours, hasLength(3));
    });
  });
}

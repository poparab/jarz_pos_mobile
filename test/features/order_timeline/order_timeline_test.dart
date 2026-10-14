// Delivery timeline: JSON parsing, the rendered view and the quiet-hide rules.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_preview_map.dart';
import 'package:jarz_pos/src/features/order_timeline/data/order_timeline.dart';
import 'package:jarz_pos/src/features/order_timeline/data/order_timeline_repository.dart';
import 'package:jarz_pos/src/features/order_timeline/presentation/order_timeline_section.dart';

import '../../helpers/fake_tile_provider.dart';

const _payload = <String, dynamic>{
  'invoice': 'ACC-SINV-2026-00001',
  'courier': {'party_type': 'Employee', 'party': 'HR-EMP-1', 'name': 'Kareem'},
  'events': [
    {
      'key': 'created',
      'label': 'Created',
      'at': '2026-10-14 12:00:00',
      'latitude': null,
      'longitude': null,
      'source': 'invoice',
    },
    {
      'key': 'out_for_delivery',
      'label': 'Out for delivery',
      'at': '2026-10-14 12:40:00',
      'latitude': 30.05,
      'longitude': 31.23,
      'source': 'state_log',
    },
    {
      'key': 'arrived',
      'label': 'Arrived',
      'at': '2026-10-14 13:05:00',
      'latitude': 30.06,
      'longitude': 31.25,
      'source': 'stop',
    },
    {
      'key': 'brand_new_event',
      'label': 'Something new',
      'at': '2026-10-14 13:06:00',
    },
  ],
  'segments': [
    {
      'key': 'prep',
      'label': 'Preparation',
      'from': '2026-10-14 12:00:00',
      'to': '2026-10-14 12:40:00',
      'minutes': 40,
      'target_minutes': 30,
      'over': true,
    },
    {
      'key': 'travel',
      'label': 'Travel',
      'from': '2026-10-14 12:45:00',
      'to': '2026-10-14 13:05:00',
      'minutes': 20,
      'target_minutes': null,
      'over': false,
    },
  ],
  'total_minutes': 65,
};

Widget _app(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      locationTileProviderProvider.overrideWithValue(FakeTileProvider()),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

Finder _rows(String prefix) => find.byWidgetPredicate((w) {
  final key = w.key;
  return key is ValueKey && key.value.toString().startsWith(prefix);
});

class _FakeRepository implements OrderTimelineRepository {
  _FakeRepository(this._answer);

  final Future<OrderTimeline?> Function() _answer;

  @override
  Future<OrderTimeline?> getTimeline(String invoiceId) => _answer();
}

void main() {
  group('OrderTimeline.fromJson', () {
    test('reads the contract shape', () {
      final t = OrderTimeline.fromJson(_payload);
      expect(t.invoice, 'ACC-SINV-2026-00001');
      expect(t.courierName, 'Kareem');
      expect(t.totalMinutes, 65);
      expect(t.events, hasLength(4));
      expect(t.events[1].key, TimelineEventKey.outForDelivery);
      expect(t.events[1].at, DateTime(2026, 10, 14, 12, 40));
      expect(t.events[1].hasLocation, isTrue);
      expect(t.events[0].hasLocation, isFalse);
      expect(t.locatedEvents, hasLength(2));
      expect(t.segments, hasLength(2));
      expect(t.segments[0].over, isTrue);
      expect(t.segments[0].targetMinutes, 30);
      expect(t.segments[1].targetMinutes, isNull);
      expect(t.isEmpty, isFalse);
    });

    test('is tolerant of missing and odd fields', () {
      final t = OrderTimeline.fromJson({
        'events': [
          {'key': 'delivered', 'at': 'not a date', 'latitude': '0', 'longitude': '0'},
          'garbage',
        ],
        'segments': 'nope',
        'total_minutes': null,
        'courier': null,
      });
      expect(t.invoice, '');
      expect(t.courierName, isNull);
      expect(t.totalMinutes, isNull);
      expect(t.events, hasLength(1));
      expect(t.events.single.at, isNull);
      // Null Island is a failed parse, not a place.
      expect(t.events.single.hasLocation, isFalse);
      expect(t.segments, isEmpty);
    });

    test('an empty payload is empty', () {
      expect(OrderTimeline.fromJson(const {}).isEmpty, isTrue);
    });
  });

  group('OrderTimelineView', () {
    testWidgets('renders events, stages, total and highlights the over one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          OrderTimelineView(
            timeline: OrderTimeline.fromJson(_payload),
            tileProvider: FakeTileProvider(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Delivery timeline'), findsOneWidget);
      expect(find.text('Courier: Kareem'), findsOneWidget);
      expect(find.byKey(OrderTimelineView.totalKey), findsOneWidget);
      expect(find.text('Total 65 min'), findsOneWidget);
      expect(_rows(OrderTimelineView.eventRowKeyPrefix), findsNWidgets(4));
      // Known keys use the localized label, an unknown key the server's.
      expect(find.text('Order created'), findsOneWidget);
      expect(find.text('Arrived at the customer'), findsOneWidget);
      expect(find.text('Something new'), findsOneWidget);
      // Stages: minutes against target, only the late one flagged.
      expect(_rows(OrderTimelineView.segmentRowKeyPrefix), findsNWidgets(2));
      expect(find.text('40 min'), findsOneWidget);
      expect(find.text('target 30 min'), findsOneWidget);
      expect(find.byKey(OrderTimelineView.overKey), findsOneWidget);
      expect(find.text('Over target'), findsOneWidget);
      // Located events get a map.
      expect(find.byKey(OrderTimelineView.mapKey), findsOneWidget);
    });

    testWidgets('no located events means no map', (tester) async {
      final timeline = OrderTimeline.fromJson({
        'events': [
          {'key': 'created', 'label': 'Created', 'at': '2026-10-14 12:00:00'},
        ],
      });
      await tester.pumpWidget(_app(OrderTimelineView(timeline: timeline)));
      await tester.pump();
      expect(find.byKey(OrderTimelineView.mapKey), findsNothing);
    });
  });

  group('OrderTimelineSection', () {
    Future<void> pumpSection(
      WidgetTester tester,
      Future<OrderTimeline?> Function() answer,
    ) async {
      await tester.pumpWidget(
        _app(
          const OrderTimelineSection(invoiceId: 'ACC-SINV-2026-00001'),
          overrides: [
            orderTimelineRepositoryProvider.overrideWithValue(
              _FakeRepository(answer),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the timeline when the server answers', (tester) async {
      await pumpSection(
        tester,
        () async => OrderTimeline.fromJson(_payload),
      );
      expect(find.byKey(OrderTimelineSection.sectionKey), findsOneWidget);
    });

    testWidgets('hides quietly on a 403 / 404 (repository returns null)', (
      tester,
    ) async {
      await pumpSection(tester, () async => null);
      expect(find.byKey(OrderTimelineSection.sectionKey), findsNothing);
      expect(find.text('Delivery timeline'), findsNothing);
    });

    testWidgets('hides quietly when the call throws', (tester) async {
      await pumpSection(tester, () async => throw Exception('boom'));
      expect(find.byKey(OrderTimelineSection.sectionKey), findsNothing);
      expect(find.text('Delivery timeline'), findsNothing);
    });
  });

  group('OrderTimelineRepository', () {
    OrderTimelineRepository repoThatFails(int status) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: status),
              type: DioExceptionType.badResponse,
            ),
          ),
        ),
      );
      return OrderTimelineRepository(dio);
    }

    test('403 and 404 mean "nothing to show"', () async {
      expect(await repoThatFails(403).getTimeline('X'), isNull);
      expect(await repoThatFails(404).getTimeline('X'), isNull);
    });

    test('other failures still throw', () async {
      expect(
        () => repoThatFails(500).getTimeline('X'),
        throwsA(isA<DioException>()),
      );
    });
  });
}

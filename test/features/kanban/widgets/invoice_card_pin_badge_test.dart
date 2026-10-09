// The map-pin badge on the Kanban invoice card.
//
// A courier dispatched against an address with no coordinates has nothing but
// free text to navigate by, and nobody finds out until the delivery is already
// late. The badge exists so that is visible on the board *before* the card is
// dragged to Out for Delivery — these tests pin down when it appears and what
// it says.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/services/kanban_service.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';

/// Inert stand-in for the real KanbanNotifier, whose constructor opens sockets
/// and arms polling timers. The card only reads state at build time.
class _FakeKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _FakeKanbanNotifier() : super(KanbanState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records that the address editor was opened (its first step loads the
/// customer's address book) and fails the load, so the editor stops at its
/// error snackbar instead of reaching the network.
class _FakeKanbanService implements KanbanService {
  int addressBookLoads = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getCustomerShippingAddresses) {
      addressBookLoads++;
      return Future<Map<String, dynamic>>.error(Exception('offline'));
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeAddressRepository implements CustomerAddressRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getTerritories) {
      return Future<List<Map<String, dynamic>>>.value(const []);
    }
    return super.noSuchMethod(invocation);
  }
}

InvoiceCard _card({
  String status = 'Ready',
  double? latitude,
  double? longitude,
  bool isPickup = false,
  bool? hasLocationPinFlag,
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-00042',
    invoiceIdShort: '42',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: status,
    postingDate: '2026-08-05',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    requiresAcceptanceFlag: false,
    outstandingAmount: 0,
    isPickup: isPickup,
    addressLatitude: latitude,
    addressLongitude: longitude,
    hasLocationPinFlag: hasLocationPinFlag,
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  InvoiceCard invoice, {
  _FakeKanbanService? service,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kanbanProvider.overrideWith((ref) => _FakeKanbanNotifier()),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
        kanbanServiceProvider
            .overrideWithValue(service ?? _FakeKanbanService()),
        customerAddressRepositoryProvider
            .overrideWithValue(_FakeAddressRepository()),
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
        home: Scaffold(
          body: ListView(
            children: [
              SizedBox(width: 380, child: InvoiceCardWidget(invoice: invoice)),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Captures url_launcher calls. In `flutter test` no platform plugin is
/// registered, so `launchUrl` goes through the default method channel, which
/// can be mocked without a new dependency.
List<String> _mockUrlLauncher(WidgetTester tester) {
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final launched = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
      (call) async {
    if (call.method == 'launch') {
      launched.add((call.arguments as Map)['url'] as String);
      return true;
    }
    return true;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));
  return launched;
}

void main() {
  group('InvoiceCard pin state', () {
    test('a complete in-range pair counts as pinned', () {
      expect(_card(latitude: 30.0444, longitude: 31.2357).hasLocationPin,
          isTrue);
    });

    test('a half-written pair does not', () {
      expect(_card(latitude: 30.0444).hasLocationPin, isFalse);
    });

    test('Null Island does not — that is what a failed parse looks like', () {
      expect(_card(latitude: 0, longitude: 0).hasLocationPin, isFalse);
    });

    test('out-of-range values do not', () {
      expect(_card(latitude: 300, longitude: 31.2).hasLocationPin, isFalse);
    });

    test('an explicit backend flag overrides the coordinates', () {
      expect(
        _card(latitude: 30.0444, longitude: 31.2357, hasLocationPinFlag: false)
            .hasLocationPin,
        isFalse,
      );
    });

    test('payloads that predate the geo fields read as unpinned', () {
      final legacy = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
      });
      expect(legacy.hasLocationPin, isFalse);
      expect(legacy.needsLocationPin, isTrue);
    });

    test('reads the raw Address custom_* keys as well as the flat ones', () {
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
        'custom_latitude': 30.0444,
        'custom_longitude': 31.2357,
        'custom_geo_source': 'pos_link',
        'custom_geo_confidence': 20,
      });
      expect(card.hasLocationPin, isTrue);
      expect(card.geoSource, 'pos_link');
      expect(card.geoConfidence, 20);
    });

    test('survives a cache round trip', () {
      final original = _card(latitude: 30.0444, longitude: 31.2357);
      final restored = InvoiceCard.fromJson(original.toJson());
      expect(restored.hasLocationPin, isTrue);
      expect(restored.addressLatitude, closeTo(30.0444, 1e-9));
    });

    test('parses location_link and survives a round trip', () {
      const link = 'https://www.google.com/maps/search/?api=1&query=30.0444,31.2357';
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
        'address_latitude': 30.0444,
        'address_longitude': 31.2357,
        'has_location_pin': 1,
        'location_link': link,
      });
      expect(card.locationLink, link);
      expect(card.mapsUrl, link);
      expect(InvoiceCard.fromJson(card.toJson()).locationLink, link);
    });

    test('a legacy pasted link wins even without coordinates', () {
      const link = 'https://maps.app.goo.gl/abc123';
      final card = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
        'location_link': link,
      });
      expect(card.mapsUrl, link);
    });

    test('absent or blank location_link reads as null', () {
      final absent = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
      });
      expect(absent.locationLink, isNull);
      expect(absent.mapsUrl, isNull);

      final blank = InvoiceCard.fromJson({
        'name': 'ACC-SINV-2026-00042',
        'status': 'Ready',
        'posting_date': '2026-08-05',
        'grand_total': 450,
        'items': const [],
        'location_link': '  ',
      });
      expect(blank.locationLink, isNull);
      expect(blank.mapsUrl, isNull);
    });

    test('mapsUrl falls back to the coordinates on an older backend', () {
      expect(
        _card(latitude: 30.0444, longitude: 31.2357).mapsUrl,
        'https://www.google.com/maps/search/?api=1&query=30.044400,31.235700',
      );
    });

    test('mapsUrl is null for Null Island, half pairs and a false flag', () {
      expect(_card(latitude: 0, longitude: 0).mapsUrl, isNull);
      expect(_card(latitude: 30.0444).mapsUrl, isNull);
      expect(
        _card(latitude: 30.0444, longitude: 31.2357, hasLocationPinFlag: false)
            .mapsUrl,
        isNull,
      );
      // A true flag with no coordinates and no link has nowhere to go.
      expect(_card(hasLocationPinFlag: true).mapsUrl, isNull);
    });

    test('pickups are never nagged about a pin', () {
      expect(_card(isPickup: true).showsLocationPinBadge, isFalse);
    });

    test('the badge goes quiet once the order is done', () {
      for (final status in const [
        'Delivered',
        'Completed',
        'Cancelled',
        'Returned',
      ]) {
        expect(_card(status: status).showsLocationPinBadge, isFalse,
            reason: status);
      }
    });

    test('it stays up while the order is still in flight', () {
      for (final status in const [
        'Recieved',
        'In Progress',
        'Ready',
        'Out for Delivery',
      ]) {
        expect(_card(status: status).showsLocationPinBadge, isTrue,
            reason: status);
      }
    });
  });

  group('InvoiceCardWidget pin badge', () {
    testWidgets('warns when a live delivery order has no coordinates',
        (tester) async {
      await _pumpCard(tester, _card());

      expect(find.text('No map pin'), findsOneWidget);
      expect(find.text('Pinned'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('confirms when the address carries coordinates',
        (tester) async {
      await _pumpCard(tester, _card(latitude: 30.0444, longitude: 31.2357));

      expect(find.text('Pinned'), findsOneWidget);
      expect(find.text('No map pin'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a pinned badge opens the Maps URL', (tester) async {
      final launched = _mockUrlLauncher(tester);
      final service = _FakeKanbanService();
      await _pumpCard(tester, _card(latitude: 30.0444, longitude: 31.2357),
          service: service);

      await tester.tap(find.text('Pinned'));
      await tester.pump();

      expect(launched, [
        'https://www.google.com/maps/search/?api=1&query=30.044400,31.235700',
      ]);
      expect(service.addressBookLoads, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long-pressing a pinned badge opens the address editor',
        (tester) async {
      final launched = _mockUrlLauncher(tester);
      final service = _FakeKanbanService();
      await _pumpCard(tester, _card(latitude: 30.0444, longitude: 31.2357),
          service: service);

      await tester.longPress(find.text('Pinned'));
      await tester.pump();

      expect(launched, isEmpty);
      expect(service.addressBookLoads, 1);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('tapping an unpinned badge opens the address editor',
        (tester) async {
      final launched = _mockUrlLauncher(tester);
      final service = _FakeKanbanService();
      await _pumpCard(tester, _card(), service: service);

      await tester.tap(find.text('No map pin'));
      await tester.pump();

      expect(launched, isEmpty);
      expect(service.addressBookLoads, 1);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('says nothing on a pickup order', (tester) async {
      await _pumpCard(tester, _card(isPickup: true));

      expect(find.text('No map pin'), findsNothing);
      expect(find.text('Pinned'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('says nothing once the order has been delivered',
        (tester) async {
      await _pumpCard(tester, _card(status: 'Delivered'));

      expect(find.text('No map pin'), findsNothing);
      expect(find.text('Pinned'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

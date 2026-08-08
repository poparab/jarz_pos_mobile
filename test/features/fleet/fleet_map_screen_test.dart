import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/fleet/data/fleet_repository.dart';
import 'package:jarz_pos/src/features/fleet/data/models/fleet_models.dart';
import 'package:jarz_pos/src/features/fleet/presentation/screens/fleet_map_screen.dart';
import 'package:jarz_pos/src/features/fleet/state/fleet_providers.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_preview_map.dart';

import '../../helpers/fake_tile_provider.dart';

/// One courier in the canned response.
///
/// [ageMinutes] is how old the fix should look; null means the payload carried
/// no timestamp. Null [lat]/[lng] means the courier is reporting in but cannot
/// be placed.
class _FakeCourier {
  const _FakeCourier({
    required this.id,
    required this.name,
    this.ageMinutes,
    this.lat,
    this.lng,
    this.accuracy,
  });

  final String id;
  final String name;
  final int? ageMinutes;
  final double? lat;
  final double? lng;
  final double? accuracy;
}

String _two(int value) => value.toString().padLeft(2, '0');

/// Frappe's naive `YYYY-MM-DD HH:MM:SS` on the site clock.
String _stamp(DateTime value) =>
    '${value.year}-${_two(value.month)}-${_two(value.day)} '
    '${_two(value.hour)}:${_two(value.minute)}:${_two(value.second)}';

class _FakeFleetRepository extends FleetRepository {
  _FakeFleetRepository({this.couriers = const [], this.error}) : super(Dio());

  List<_FakeCourier> couriers;
  Object? error;

  int calls = 0;
  final List<String?> branches = [];

  @override
  Future<FleetSnapshot> getLivePositions({String? branch}) async {
    calls++;
    branches.add(branch);
    final failure = error;
    if (failure != null) throw failure;

    // Timestamps are built off the real clock the screen also reads, so the
    // rendered ages are exact rather than depending on the machine's date.
    final now = DateTime.now();
    return FleetSnapshot.fromJson({
      'success': true,
      'ttl_seconds': 900,
      'branches': [
        {
          'branch': 'Nasr city',
          'as_of': _stamp(now),
          'ttl_seconds': 900,
          'count': couriers.length,
          'couriers': [
            for (final courier in couriers)
              {
                'courier': courier.id,
                'courier_name': courier.name,
                if (courier.lat != null) 'lat': courier.lat,
                if (courier.lng != null) 'lng': courier.lng,
                if (courier.ageMinutes != null)
                  'ts': _stamp(
                    now.subtract(Duration(minutes: courier.ageMinutes!)),
                  ),
                if (courier.accuracy != null) 'accuracy_m': courier.accuracy,
              },
          ],
        },
      ],
    }, fetchedAt: now);
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required FleetRepository repository,
  bool canView = true,
  String? branch,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fleetRepositoryProvider.overrideWithValue(repository),
        canAccessManagerDashboardRoleProvider.overrideWithValue(canView),
        // Keep the map off the real tile server.
        locationTileProviderProvider.overrideWithValue(FakeTileProvider()),
        if (branch != null)
          fleetBranchFilterProvider.overrideWith((ref) => branch),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FleetMapScreen(),
      ),
    ),
  );
  // Let the initial load resolve. `pumpAndSettle` is avoided on purpose: the
  // screen ticks on a timer, so it never settles.
  await tester.pump();
  await tester.pump();
}

/// Unmounts the screen so its ticker and the poll timer are cancelled before
/// the test framework checks for pending timers.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}

AppLocalizations _en() => lookupAppLocalizations(const Locale('en'));

void main() {
  testWidgets('a 403 says the user is not a supervisor and offers no retry', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      error: const FleetPermissionDeniedException(),
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetForbiddenTitle), findsOneWidget);
    expect(find.text(l10n.fleetForbiddenBody), findsOneWidget);
    // Retrying can never fix a role decision, so neither control is offered.
    expect(find.text(l10n.commonRetry), findsNothing);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(FlutterMap), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('a non-supervisor never even reaches the endpoint', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository();

    await _pumpScreen(tester, repository: repository, canView: false);

    expect(find.text(l10n.fleetForbiddenTitle), findsOneWidget);
    await _disposeScreen(tester);
  });

  testWidgets('no couriers at all reads as a shift problem', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository();

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetEmptyNoCouriersTitle), findsOneWidget);
    expect(find.text(l10n.fleetEmptyNoPositionsTitle), findsNothing);
    // Never a blank map with no caption.
    expect(find.byType(FlutterMap), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('couriers with no fix read as a device problem, and are named', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(id: 'C1', name: 'Ahmed'),
        _FakeCourier(id: 'C2', name: 'Mona'),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetEmptyNoPositionsTitle), findsOneWidget);
    expect(find.text(l10n.fleetEmptyNoCouriersTitle), findsNothing);
    expect(
      find.text(l10n.fleetEmptyNoPositionsNames('Ahmed، Mona')),
      findsOneWidget,
    );

    await _disposeScreen(tester);
  });

  testWidgets('plots one named marker per located courier', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 1,
          lat: 30.05,
          lng: 31.24,
        ),
        _FakeCourier(
          id: 'C2',
          name: 'Mona',
          ageMinutes: 7,
          lat: 30.08,
          lng: 31.30,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.byType(FlutterMap), findsOneWidget);
    // The age rides on the label, so staleness survives a colour-blind reader.
    expect(find.text('Ahmed · ${l10n.fleetAgeShortMinutes(1)}'), findsOneWidget);
    expect(find.text('Mona · ${l10n.fleetAgeShortMinutes(7)}'), findsOneWidget);
    expect(find.text(l10n.fleetCouriersOnMap(2)), findsOneWidget);
    // Legend thresholds come from the server's TTL (900 s → 5 / 10 min).
    expect(find.text(l10n.fleetLegendFresh(5)), findsOneWidget);
    expect(find.text(l10n.fleetLegendStale(10)), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('a mixed response maps the located and banners the rest', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 1,
          lat: 30.05,
          lng: 31.24,
        ),
        _FakeCourier(id: 'C2', name: 'Mona'),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.byType(FlutterMap), findsOneWidget);
    // The unplaceable courier must not silently vanish from the count.
    expect(find.text(l10n.fleetUnlocatedBanner(1)), findsOneWidget);
    expect(find.text(l10n.fleetEmptyNoPositionsNames('Mona')), findsOneWidget);
    expect(find.text(l10n.fleetCouriersOnMap(1)), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('tapping a marker opens the detail sheet', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 3,
          lat: 30.05,
          lng: 31.24,
          accuracy: 18.4,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    await tester.tap(find.text('Ahmed · ${l10n.fleetAgeShortMinutes(3)}'));
    await tester.pump();

    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.text('Nasr city'), findsOneWidget);
    // Relative, not absolute: an exact timestamp is useless at a glance.
    expect(find.text(l10n.fleetAgeMinutes(3)), findsOneWidget);
    expect(find.text(l10n.fleetAccuracyValue('18')), findsOneWidget);
    expect(find.text(l10n.fleetFreshnessFresh), findsOneWidget);

    // Closing puts the map back to itself.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Nasr city'), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('an unreported accuracy says so instead of showing zero', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 2,
          lat: 30.05,
          lng: 31.24,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);
    await tester.tap(find.text('Ahmed · ${l10n.fleetAgeShortMinutes(2)}'));
    await tester.pump();

    expect(find.text(l10n.fleetAccuracyUnknown), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('a stale fix warns in the header', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 12, // past two thirds of the 900 s TTL
          lat: 30.05,
          lng: 31.24,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetStaleWarning), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('a fresh-only map does not cry stale', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 1,
          lat: 30.05,
          lng: 31.24,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetStaleWarning), findsNothing);
    expect(find.text(l10n.fleetRefreshFailed), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('a failed refresh warns but keeps the last known map', (
    tester,
  ) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'Ahmed',
          ageMinutes: 1,
          lat: 30.05,
          lng: 31.24,
        ),
      ],
    );

    await _pumpScreen(tester, repository: repository);
    expect(find.byType(FlutterMap), findsOneWidget);

    repository.error = Exception('network down');
    await tester.pump(kFleetPollInterval);
    await tester.pump();

    expect(find.text(l10n.fleetRefreshFailed), findsOneWidget);
    // Blanking the map would lose the dispatcher their last known picture.
    expect(find.byType(FlutterMap), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('a first-load failure offers a retry', (tester) async {
    final l10n = _en();
    final repository = _FakeFleetRepository(error: Exception('network down'));

    await _pumpScreen(tester, repository: repository);

    expect(find.text(l10n.fleetErrorTitle), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.fleetEmptyNoCouriersTitle), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('the manual refresh re-reads immediately', (tester) async {
    final repository = _FakeFleetRepository();

    await _pumpScreen(tester, repository: repository);
    expect(repository.calls, 1);

    await tester.tap(find.byIcon(Icons.refresh).first);
    await tester.pump();

    expect(repository.calls, 2);

    await _disposeScreen(tester);
  });

  testWidgets('the provider hands the branch scope to the repository', (
    tester,
  ) async {
    final repository = _FakeFleetRepository();

    await _pumpScreen(tester, repository: repository, branch: 'Nasr city');

    expect(repository.branches, ['Nasr city']);

    await _disposeScreen(tester);
  });

  testWidgets('renders right-to-left in Arabic', (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final repository = _FakeFleetRepository(
      couriers: const [
        _FakeCourier(
          id: 'C1',
          name: 'أحمد',
          ageMinutes: 1,
          lat: 30.05,
          lng: 31.24,
        ),
      ],
    );

    await _pumpScreen(
      tester,
      repository: repository,
      locale: const Locale('ar'),
    );

    expect(find.text(ar.fleetTitle), findsOneWidget);
    expect(find.text(ar.fleetCouriersOnMap(1)), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(FlutterMap))),
      TextDirection.rtl,
    );

    await _disposeScreen(tester);
  });
}

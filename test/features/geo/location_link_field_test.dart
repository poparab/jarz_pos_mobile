// The paste-a-Maps-link field.
//
// Everything here runs against a fake [GeoRepository] — no test may reach a
// real backend, and the map preview is stubbed so no test reaches a tile server
// either (flutter_map's network provider retries with delays, which would
// outlive the test as a pending timer).
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/geo/data/models/maps_link_preview.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/geo_repository.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_link_field.dart';

/// Records every link it was asked about and answers with a scripted preview.
class _FakeGeoRepository implements GeoRepository {
  _FakeGeoRepository(this._answer);

  final MapsLinkPreview Function(String link) _answer;
  final List<String> calls = <String>[];

  @override
  Future<MapsLinkPreview> previewMapsLink(String link) async {
    calls.add(link);
    return _answer(link);
  }
}

/// A repository that always fails the way a dead network does.
class _ThrowingGeoRepository implements GeoRepository {
  final List<String> calls = <String>[];

  @override
  Future<MapsLinkPreview> previewMapsLink(String link) async {
    calls.add(link);
    throw Exception('connection failed');
  }
}

const _cairo = LatLng(30.0444, 31.2357);

Future<LocationLinkValue?> _pumpField(
  WidgetTester tester, {
  required GeoRepository repository,
  LocationLinkValue initialValue = LocationLinkValue.empty,
  ValueChanged<LocationLinkValue>? onChanged,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [geoRepositoryProvider.overrideWithValue(repository)],
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
          body: SizedBox(
            width: 420,
            child: LocationLinkField(
              initialValue: initialValue,
              onChanged: onChanged,
              // Stub the map: the real one fetches OSM tiles.
              previewBuilder: (context, point) => Text(
                'MAP ${point.latitude},${point.longitude}',
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return null;
}

/// Type [text], let the debounce fire, and settle the resolve.
Future<void> _paste(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(LocationLinkField.textFieldKey), text);
  // Past the field's 600 ms debounce.
  await tester.pump(const Duration(milliseconds: 700));
  // Let the (already completed) repository future land.
  await tester.pump();
  await tester.pump();
}

MapsLinkPreview _resolved({double distance = 4200}) => MapsLinkPreview(
      success: true,
      latitude: _cairo.latitude,
      longitude: _cairo.longitude,
      precision: 'pos_link',
      distanceFromBranchM: distance,
    );

void main() {
  testWidgets('resolves a long Google Maps link and confirms the point',
      (tester) async {
    final repo = _FakeGeoRepository((_) => _resolved());
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(
      tester,
      'https://www.google.com/maps/place/Cairo/@30.0444,31.2357,15z',
    );

    expect(repo.calls.single,
        'https://www.google.com/maps/place/Cairo/@30.0444,31.2357,15z');
    expect(find.textContaining('Location confirmed'), findsOneWidget);
    // Distance is shown in the unit staff think in.
    expect(find.textContaining('4.2 km'), findsOneWidget);
    // The preview renders at the resolved point.
    expect(find.text('MAP 30.0444,31.2357'), findsOneWidget);

    expect(emitted, isNotNull);
    expect(emitted!.isConfirmed, isTrue);
    expect(emitted!.latitude, closeTo(30.0444, 1e-9));
    expect(emitted!.precision, 'pos_link');
    expect(emitted!.toRequestFields()['geo_source'], 'pos_link');
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolves a short maps.app.goo.gl link', (tester) async {
    // The whole point of the backend round trip: only the server can follow
    // the redirect, so the field must hand the short link over untouched.
    final repo = _FakeGeoRepository((_) => _resolved(distance: 850));
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, 'https://maps.app.goo.gl/aBcD1234');

    expect(repo.calls.single, 'https://maps.app.goo.gl/aBcD1234');
    expect(find.textContaining('Location confirmed'), findsOneWidget);
    // Sub-kilometre distances stay in metres.
    expect(find.textContaining('850 m'), findsOneWidget);
    expect(emitted!.isConfirmed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolves a bare lat,lng pair', (tester) async {
    final repo = _FakeGeoRepository((_) => _resolved());
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, '30.0444, 31.2357');

    expect(repo.calls.single, '30.0444, 31.2357');
    expect(find.textContaining('Location confirmed'), findsOneWidget);
    expect(emitted!.isConfirmed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects text that is not a location without calling the server',
      (tester) async {
    final repo = _FakeGeoRepository((_) => _resolved());
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, 'behind the big pharmacy');

    expect(repo.calls, isEmpty, reason: 'obvious non-links never hit the API');
    expect(find.textContaining('does not look like a Maps link'), findsOneWidget);
    expect(emitted!.isConfirmed, isFalse);
    expect(emitted!.toRequestFields().containsKey('latitude'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refuses a point that resolves implausibly far from the branch',
      (tester) async {
    // 400 km out is someone else's city — stamping it would send a courier
    // nowhere, and it is far harder to spot later than a red line here.
    final repo = _FakeGeoRepository((_) => _resolved(distance: 400000));
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, 'https://maps.app.goo.gl/farAway');

    expect(repo.calls, hasLength(1));
    expect(find.textContaining('400.0 km'), findsOneWidget);
    expect(find.textContaining('too far'), findsOneWidget);
    expect(find.textContaining('Location confirmed'), findsNothing);
    // No map for a rejected point, and no coordinates on the value.
    expect(find.textContaining('MAP '), findsNothing);
    expect(emitted!.isConfirmed, isFalse);
    expect(emitted!.toRequestFields().containsKey('latitude'), isFalse);
    // The raw link is still carried so the save records what was pasted.
    expect(emitted!.link, 'https://maps.app.goo.gl/farAway');
    expect(tester.takeException(), isNull);
  });

  testWidgets('surfaces a server failure as an inline error', (tester) async {
    final repo = _FakeGeoRepository(
      (_) => const MapsLinkPreview.failure('could not follow redirect'),
    );

    await _pumpField(tester, repository: repo);
    await _paste(tester, 'https://maps.app.goo.gl/expired');

    expect(find.textContaining('Could not read a location'), findsOneWidget);
    expect(find.textContaining('Location confirmed'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tells a dead network apart from a bad link', (tester) async {
    final repo = _ThrowingGeoRepository();

    await _pumpField(tester, repository: repo);
    await _paste(tester, 'https://maps.app.goo.gl/aBcD1234');

    expect(repo.calls, hasLength(1));
    expect(find.textContaining('Could not check the location'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear resets the field and the emitted value', (tester) async {
    final repo = _FakeGeoRepository((_) => _resolved());
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, 'https://maps.app.goo.gl/aBcD1234');
    expect(emitted!.isConfirmed, isTrue);

    await tester.tap(find.byKey(LocationLinkField.clearButtonKey));
    await tester.pump();

    expect(emitted!.isConfirmed, isFalse);
    expect(emitted!.link, isEmpty);
    expect(find.textContaining('MAP '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an existing pin opens already confirmed, with no API call',
      (tester) async {
    final repo = _FakeGeoRepository((_) => _resolved());

    await _pumpField(
      tester,
      repository: repo,
      initialValue: const LocationLinkValue(
        link: 'https://maps.app.goo.gl/saved',
        latitude: 30.0444,
        longitude: 31.2357,
        precision: 'customer_pin',
      ),
    );

    expect(repo.calls, isEmpty);
    expect(find.textContaining('Location confirmed'), findsOneWidget);
    expect(find.text('MAP 30.0444,31.2357'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing a resolved link drops the stale pin immediately',
      (tester) async {
    // The coordinates on screen must never belong to text the user has since
    // changed — that is exactly how a wrong pin gets saved.
    final repo = _FakeGeoRepository((_) => _resolved());
    LocationLinkValue? emitted;

    await _pumpField(
      tester,
      repository: repo,
      onChanged: (value) => emitted = value,
    );
    await _paste(tester, 'https://maps.app.goo.gl/aBcD1234');
    expect(emitted!.isConfirmed, isTrue);

    await tester.enterText(
      find.byKey(LocationLinkField.textFieldKey),
      'https://maps.app.goo.gl/some',
    );
    await tester.pump();

    expect(emitted!.isConfirmed, isFalse);
    expect(find.textContaining('not confirmed yet'), findsOneWidget);
    expect(find.textContaining('MAP '), findsNothing);

    // Flush the debounce so the test leaves no pending timer behind.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
  });
}

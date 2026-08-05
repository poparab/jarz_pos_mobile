// Wiring test: does the pin staff pasted actually leave the address dialog?
//
// The dialog is the single seam every address save goes through — POS customer
// selection and the Kanban "edit address" action both read its result map. If
// the geo keys are dropped here the field looks like it works and nothing is
// ever stored, which is exactly the failure that hides for weeks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/repositories/customer_address_repository.dart';
import 'package:jarz_pos/src/core/widgets/customer_shipping_address_dialog.dart';
import 'package:jarz_pos/src/features/geo/data/models/maps_link_preview.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/geo_repository.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_link_field.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_preview_map.dart';

import '../../../helpers/fake_tile_provider.dart';

/// The dialog only calls the address repository for inline edit/delete, which
/// these tests never reach.
class _FakeAddressRepository implements CustomerAddressRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGeoRepository implements GeoRepository {
  final List<String> calls = <String>[];

  @override
  Future<MapsLinkPreview> previewMapsLink(String link) async {
    calls.add(link);
    return const MapsLinkPreview(
      success: true,
      latitude: 30.0444,
      longitude: 31.2357,
      precision: 'pos_link',
      distanceFromBranchM: 3100,
    );
  }
}

void main() {
  testWidgets('a pasted, resolved link leaves the dialog with its coordinates',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final geo = _FakeGeoRepository();
    Map<String, String>? captured;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          geoRepositoryProvider.overrideWithValue(geo),
          // Keep the preview map off the network.
          locationTileProviderProvider.overrideWithValue(FakeTileProvider()),
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
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  captured = await CustomerShippingAddressDialog.show(
                    context,
                    customerName: 'Sarah Johnson',
                    customer: 'CUST-0042',
                    addresses: const [],
                    territories: const [],
                    initialSelectedAddressName: '',
                    initialPhone: '01001234567',
                    repository: _FakeAddressRepository(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Free-text address (the "add new" tab is the default with no saved rows).
    await tester.enterText(
      find.byKey(CustomerShippingAddressDialog.newAddressFieldKey),
      '12 Nile St, Maadi',
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(LocationLinkField.textFieldKey),
      'https://maps.app.goo.gl/aBcD1234',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump();

    expect(geo.calls.single, 'https://maps.app.goo.gl/aBcD1234');

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!['address'], '12 Nile St, Maadi');
    expect(captured!['location_link'], 'https://maps.app.goo.gl/aBcD1234');
    expect(captured!['latitude'], '30.0444');
    expect(captured!['longitude'], '31.2357');
    expect(captured!['geo_source'], 'pos_link');
  });

  testWidgets('an untouched link field adds no geo keys to the result',
      (tester) async {
    // Re-saving an address for an unrelated reason must not re-stamp its pin —
    // the geo write is rank-guarded on the backend, but a client that sends
    // coordinates it was never given is how a stale pin gets resurrected.
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final geo = _FakeGeoRepository();
    Map<String, String>? captured;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          geoRepositoryProvider.overrideWithValue(geo),
          // Keep the preview map off the network.
          locationTileProviderProvider.overrideWithValue(FakeTileProvider()),
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
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  captured = await CustomerShippingAddressDialog.show(
                    context,
                    customerName: 'Sarah Johnson',
                    customer: 'CUST-0042',
                    addresses: const [
                      {
                        'name': 'Sarah-Home',
                        'full_address': '12 Nile St, Maadi',
                        'phone': '01001234567',
                        'custom_latitude': 30.0444,
                        'custom_longitude': 31.2357,
                        'custom_geo_source': 'customer_pin',
                      },
                    ],
                    territories: const [],
                    initialSelectedAddressName: 'Sarah-Home',
                    initialPhone: '01001234567',
                    repository: _FakeAddressRepository(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The saved address already has a pin, so the field opens confirmed…
    expect(find.textContaining('Location confirmed'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!['address_name'], 'Sarah-Home');
    // …but nothing was touched, so no geo key rides along.
    expect(captured!.containsKey('latitude'), isFalse);
    expect(captured!.containsKey('location_link'), isFalse);
    expect(geo.calls, isEmpty);
  });
}

// The map picker must not hand back its own starting point as a pin.
//
// With no existing pin it opens on the Cairo fallback centre. Confirming that
// untouched point saved Tahrir as the door for 21 addresses (order #19830 in
// El Shorouk), so the confirm stays disabled until the map is tapped.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_point_picker.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_preview_map.dart';

import '../../helpers/fake_tile_provider.dart';

const _confirm = ValueKey('location_point_picker_confirm');

Future<void> _pump(WidgetTester tester, {LatLng? initial}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
        home: LocationPointPicker(initial: initial),
      ),
    ),
  );
  await tester.pump();
}

bool _confirmEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(_confirm)).onPressed != null;

void main() {
  testWidgets('no existing pin: confirm is disabled until the map is tapped',
      (tester) async {
    await _pump(tester);
    expect(_confirmEnabled(tester), isFalse);

    await tester.tapAt(tester.getCenter(find.byType(LocationPointPicker)) +
        const Offset(40, -60));
    // flutter_map holds a tap until the double-tap window has passed.
    await tester.pump(const Duration(milliseconds: 500));
    expect(_confirmEnabled(tester), isTrue);
  });

  testWidgets('an existing pin can be confirmed as it stands', (tester) async {
    await _pump(tester, initial: const LatLng(30.1286, 31.6066));
    expect(_confirmEnabled(tester), isTrue);
  });
}

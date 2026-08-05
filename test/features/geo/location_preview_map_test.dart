// The OSM thumbnail behind the location-link field.
//
// Tiles come from an injected local provider: `flutter_map`'s network provider
// wraps an HTTP client that retries with delays, and those retries outlive the
// test as pending timers. Nothing here should touch a tile server.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:jarz_pos/src/features/geo/presentation/widgets/location_preview_map.dart';

import '../../helpers/fake_tile_provider.dart';

void main() {
  testWidgets('renders a map with a marker at the resolved point',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: LocationPreviewMap(
              point: const LatLng(30.0444, 31.2357),
              tileProvider: FakeTileProvider(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(MarkerLayer), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('is not interactive, so it cannot swallow a form scroll',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: LocationPreviewMap(
              point: const LatLng(30.0444, 31.2357),
              tileProvider: FakeTileProvider(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final options = tester.widget<FlutterMap>(find.byType(FlutterMap)).options;
    expect(options.interactionOptions.flags, InteractiveFlag.none);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead_maps_preview.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/lead_maps_import_card.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  required LeadMapsPreviewResolver resolver,
  LeadMapsValue initialValue = LeadMapsValue.empty,
  ValueChanged<LeadMapsValue>? onChanged,
}) async {
  await tester.pumpWidget(
    ProviderScope(
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
            child: LeadMapsImportCard(
              resolver: resolver,
              initialValue: initialValue,
              onChanged: onChanged,
              previewBuilder: (context, point) =>
                  Text('MAP ${point.latitude},${point.longitude}'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LeadMapsPreview _resolved(String link, double latitude, double longitude) =>
    LeadMapsPreview(
      success: true,
      resolved: true,
      url: link,
      canonicalUrl: link,
      latitude: latitude,
      longitude: longitude,
    );

void main() {
  testWidgets('saved link offers an explicit lookup without starting one', (
    tester,
  ) async {
    var calls = 0;
    await _pumpCard(
      tester,
      initialValue: const LeadMapsValue(
        mapsUrl: 'https://maps.app.goo.gl/saved',
      ),
      resolver: (link, {keepPolling}) async {
        calls++;
        return _resolved(link, 30, 31);
      },
    );

    expect(calls, 0);
    expect(find.byKey(LeadMapsImportCard.getDetailsKey), findsOneWidget);

    await tester.tap(find.byKey(LeadMapsImportCard.getDetailsKey));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('MAP 30.0,31.0'), findsOneWidget);
  });

  testWidgets('clear remains available and cancels a visible pending result', (
    tester,
  ) async {
    final response = Completer<LeadMapsPreview>();
    LeadMapsValue? value;
    await _pumpCard(
      tester,
      resolver: (link, {keepPolling}) => response.future,
      onChanged: (next) => value = next,
    );

    await tester.enterText(
      find.byKey(LeadMapsImportCard.inputKey),
      'https://maps.app.goo.gl/slow',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(LeadMapsImportCard.clearKey), findsOneWidget);

    await tester.tap(find.byKey(LeadMapsImportCard.clearKey));
    await tester.pump();
    response.complete(_resolved('https://maps.app.goo.gl/slow', 30, 31));
    await tester.pumpAndSettle();

    expect(value, LeadMapsValue.empty);
    expect(find.textContaining('MAP '), findsNothing);
  });

  testWidgets('failed lookup exposes Retry and keeps the link', (tester) async {
    var calls = 0;
    LeadMapsValue? value;
    await _pumpCard(
      tester,
      resolver: (link, {keepPolling}) async {
        calls++;
        if (calls == 1) throw Exception('offline');
        return _resolved(link, 30, 31);
      },
      onChanged: (next) => value = next,
    );

    await tester.enterText(
      find.byKey(LeadMapsImportCard.inputKey),
      'https://maps.app.goo.gl/retry',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(value!.mapsUrl, 'https://maps.app.goo.gl/retry');
    expect(value!.hasCoordinates, isFalse);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.byKey(LeadMapsImportCard.getDetailsKey));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(value!.hasCoordinates, isTrue);
  });

  testWidgets('pending timeout stays retryable and can finish later', (
    tester,
  ) async {
    var calls = 0;
    LeadMapsValue? value;
    await _pumpCard(
      tester,
      resolver: (link, {keepPolling}) async {
        calls++;
        if (calls == 1) {
          return LeadMapsPreview(
            success: true,
            resolved: false,
            pending: true,
            requestId: 'request-slow',
            url: link,
            canonicalUrl: link,
          );
        }
        return _resolved(link, 30, 31);
      },
      onChanged: (next) => value = next,
    );

    await tester.enterText(
      find.byKey(LeadMapsImportCard.inputKey),
      'https://maps.app.goo.gl/still-working',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(value!.mapsUrl, 'https://maps.app.goo.gl/still-working');
    expect(find.textContaining('taking longer'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.byKey(LeadMapsImportCard.getDetailsKey));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(value!.hasCoordinates, isTrue);
    expect(find.text('MAP 30.0,31.0'), findsOneWidget);
  });
}

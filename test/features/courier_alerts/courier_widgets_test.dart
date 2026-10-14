// Widget smoke tests: the alert detail sheet (acknowledge call, both
// languages, narrow phone) and the one-time courier PIN card.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/courier_alerts/data/courier_alert_models.dart';
import 'package:jarz_pos/src/features/courier_alerts/data/courier_alerts_repository.dart';
import 'package:jarz_pos/src/features/courier_alerts/presentation/courier_alert_sheet.dart';
import 'package:jarz_pos/src/features/user_admin/models/courier_setup_models.dart';
import 'package:jarz_pos/src/features/user_admin/presentation/widgets/courier_setup_widgets.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'message': {
          'name': 'CA-1',
          'anomaly_type': 'Detour',
          'severity': 'High',
          'status': 'Reviewed',
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _alert = CourierAlert(
  name: 'CA-1',
  anomalyType: 'Detour',
  severity: CourierAlertSeverity.high,
  status: CourierAlertStatus.open,
  partyName: 'Mostafa',
  invoice: 'ACC-SINV-1',
  branch: 'Maadi',
  details: 'Off route by 1.2 km',
);

Future<void> _pump(
  WidgetTester tester,
  Widget body, {
  Locale locale = const Locale('en'),
  Size size = const Size(360, 780),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: body),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('alert sheet shows the alert and acknowledges ($locale)', (
      tester,
    ) async {
      final adapter = _Adapter();
      final repo = CourierAlertsRepository(Dio()..httpClientAdapter = adapter);
      await _pump(
        tester,
        const CourierAlertSheet(alert: _alert),
        locale: locale,
        overrides: [courierAlertsRepositoryProvider.overrideWithValue(repo)],
      );
      expect(find.text('Mostafa'), findsWidgets);
      expect(find.text('ACC-SINV-1'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final l10n = await AppLocalizations.delegate.load(locale);
      await tester.tap(find.text(l10n.courierAlertsMarkReviewed));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(1));
      expect((adapter.requests.single.data as Map)['status'], 'Reviewed');
    });
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('courier result card shows the PIN once ($locale)', (
      tester,
    ) async {
      await _pump(
        tester,
        const CourierResultDialog(
          signInId: '01012345678',
          pin: '482913',
          displayName: 'Ali',
          links: CourierLinks(
            webUrl: 'https://erp.example.com/courier',
            apkUrl: 'https://erp.example.com/courier.apk',
          ),
          diagnosis: CourierDiagnosis(
            problems: ['no_pos_profile'],
          ),
        ),
        locale: locale,
      );
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(find.text('482913'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
      expect(find.text(l10n.courierSetupPinOnce), findsOneWidget);
      expect(find.text(l10n.courierSetupShareWhatsapp), findsOneWidget);
      expect(find.text(l10n.courierSetupProblemNoPosProfile), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('result card without a PIN explains and hides share', (
    tester,
  ) async {
    await _pump(
      tester,
      const CourierResultDialog(signInId: '0101', pin: null),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.courierSetupNoPin), findsOneWidget);
    expect(find.text(l10n.courierSetupShareWhatsapp), findsNothing);
  });
}

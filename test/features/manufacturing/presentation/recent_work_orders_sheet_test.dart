import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/manufacturing/data/manufacturing_service.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/recent_work_orders_sheet.dart';

import '../../../helpers/mock_services.dart';

MockDio _dio() {
  final dio = MockDio();
  dio.setResponse(ApiEndpoints.listRecentWorkOrders, {
    'message': [
      {
        'name': 'MFG-WO-jarz-2026-00108',
        'production_item': 'SAV-01',
        'item_name': 'Savoiardi',
        'qty': 12.0,
        'produced_qty': 10.0,
        'status': 'Completed',
        'creation': '2026-09-23 16:54:28.424887',
        'posted_at': '2026-09-22 23:59:00',
      },
      {
        'name': 'MFG-WO-jarz-2026-00109',
        'production_item': 'FUDGE',
        'item_name': 'Fudge Cake',
        'qty': 3.0,
        'status': 'In Process',
        'creation': '2026-09-23 17:00:00',
        'posted_at': null,
      },
    ],
  });
  return dio;
}

Future<void> _open(WidgetTester tester, MockDio dio, Locale locale) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        manufacturingServiceProvider.overrideWithValue(ManufacturingService(dio)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => showRecentWorkOrders(context, ref),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 800)]) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('renders both dates at $size in $locale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await _open(tester, _dio(), locale);

        expect(tester.takeException(), isNull);
        expect(find.textContaining('MFG-WO-jarz-2026-00108'), findsOneWidget);
        if (locale.languageCode == 'en') {
          expect(find.textContaining('Stock: '), findsOneWidget);
          expect(find.textContaining('Created: '), findsWidgets);
          expect(find.text('Backdated'), findsOneWidget);
          expect(find.text('Made 10 of 12'), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('Not in stock yet'),
            100,
            scrollable: find.byType(Scrollable).last,
          );
          expect(find.text('Not in stock yet'), findsOneWidget);
        }
      });
    }
  }

  testWidgets('phone with the keyboard open does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.reset);

    await _open(tester, _dio(), const Locale('en'));

    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an in-progress status switches to created date', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dio = _dio();

    await _open(tester, dio, const Locale('en'));
    await tester.tap(find.text('All statuses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In process').last);
    await tester.pumpAndSettle();

    expect(dio.requestLog.last['data']['status'], equals('In Process'));
    expect(dio.requestLog.last['data']['date_basis'], equals('creation'));
  });

  testWidgets('changing the date basis re-queries the server', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dio = _dio();

    await _open(tester, dio, const Locale('en'));
    expect(dio.requestLog.last['data']['date_basis'], equals('posting'));

    await tester.tap(find.text('Created date'));
    await tester.pumpAndSettle();
    expect(dio.requestLog.last['data']['date_basis'], equals('creation'));

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(dio.requestLog.last['data']['from_date'], isNotNull);
  });
}

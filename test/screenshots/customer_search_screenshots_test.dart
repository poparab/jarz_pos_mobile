// Visual harness — NOT run by CI (no workflow job globs test/screenshots).
//
// Renders the POS customer search on a phone and on a tablet so the dropdown
// behaviour can be inspected rather than merely asserted on.
//
//   flutter test test/screenshots/customer_search_screenshots_test.dart --update-goldens
//
// Writes PNGs to test/screenshots/shots/.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart';

const _customers = <Map<String, dynamic>>[
  {
    'name': 'CUST-0001',
    'customer_name': 'Ali Hassan',
    'mobile_no': '01001234567',
    'territory': 'EGNASRCITY',
    'territory_name': 'Nasr City',
    'territory_name_ar': 'مدينة نصر',
    'delivery_income': 30,
  },
  {
    'name': 'CUST-0002',
    'customer_name': 'Aliaa Mostafa',
    'mobile_no': '01119876543',
    'territory': 'EGMAADI',
    'territory_name': 'Maadi',
    'territory_name_ar': 'المعادي',
    'delivery_income': 45,
  },
  {
    'name': 'CUST-0003',
    'customer_name': 'Ali Fathy',
    'mobile_no': '01277001122',
    'territory': 'EGHELIOPOLIS',
    'territory_name': 'Heliopolis',
    'territory_name_ar': 'مصر الجديدة',
    'delivery_income': 35,
  },
];

class _FakePosRepository extends PosRepository {
  _FakePosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> searchCustomers(
    String query, {
    String? customerType,
  }) async => _customers;
}

class _FakeDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];
}

final _flutterFonts = () {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null || root.isEmpty) return '';
  return '$root${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
      '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts';
}();

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final present = paths
        .where((p) => p.isNotEmpty && File(p).existsSync())
        .toList();
    if (present.isEmpty) return;
    final loader = FontLoader(family);
    for (final path in present) {
      loader.addFont(
        Future.value(File(path).readAsBytesSync().buffer.asByteData()),
      );
    }
    await loader.load();
  }

  String sdkFont(String name) => _flutterFonts.isEmpty
      ? ''
      : '$_flutterFonts${Platform.pathSeparator}$name';

  await load('Roboto', [
    sdkFont('roboto-regular.ttf'),
    sdkFont('roboto-medium.ttf'),
    sdkFont('roboto-bold.ttf'),
  ]);
  await load('MaterialIcons', [sdkFont('materialicons-regular.otf')]);
  await load('Inter', [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]);
  await load('Tajawal', [
    'assets/fonts/Tajawal-Regular.ttf',
    'assets/fonts/Tajawal-Bold.ttf',
  ]);
}

ThemeData _appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
);

/// Mirrors the POS screen: the customer bar is the topmost element, sitting
/// directly under the app bar with the item grid below it.
Future<void> _pumpPos(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        posRepositoryProvider.overrideWithValue(_FakePosRepository()),
        draftCartRepositoryProvider.overrideWithValue(
          _FakeDraftCartRepository(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _appTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(title: const Text('POS')),
          body: Column(
            children: [
              Builder(
                builder: (context) => Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const CustomerSearchWidget(),
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF3F1F7),
                  alignment: Alignment.center,
                  child: const Text('items grid'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('01 phone — collapsed customer bar', (tester) async {
    await _pumpPos(tester, const Size(390, 844));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('shots/customer_search_01_phone_bar.png'),
    );
  });

  testWidgets('02 phone — full-screen search with results', (tester) async {
    await _pumpPos(tester, const Size(390, 844));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ali');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('shots/customer_search_02_phone_results.png'),
    );
  });

  testWidgets('03 tablet — inline dropdown opens downward', (tester) async {
    await _pumpPos(tester, const Size(1024, 768));
    await tester.enterText(find.byType(TextField), 'Ali');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('shots/customer_search_03_tablet_dropdown.png'),
    );
  });
}

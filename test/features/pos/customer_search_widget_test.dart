import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    'mobile_no': '01000000000',
    'territory': 'EGNASRCITY',
    'territory_name': 'Nasr City',
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

/// Hive never boots in a widget test, so keep the draft store inert.
class _FakeDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];
}

Widget _wrap() {
  return ProviderScope(
    overrides: [
      posRepositoryProvider.overrideWithValue(_FakePosRepository()),
      draftCartRepositoryProvider.overrideWithValue(_FakeDraftCartRepository()),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(12),
          child: CustomerSearchWidget(),
        ),
      ),
    ),
  );
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('CustomerSearchWidget', () {
    testWidgets(
      'phones use a full-screen search page, never an anchored dropdown',
      (tester) async {
        await _setSize(tester, const Size(400, 800));
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        // The customer bar is the topmost element on the POS screen, so an
        // anchored overlay has nowhere to open. There must be no Autocomplete.
        expect(find.byType(Autocomplete<Map<String, dynamic>>), findsNothing);

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Full-screen route: its own Scaffold with the field in the app bar.
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'Ali');
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(find.text('Ali Hassan'), findsOneWidget);
        expect(find.text('01000000000'), findsOneWidget);
        // Quick add trails the matches instead of replacing them.
        expect(find.text('Quick Add Customer'), findsOneWidget);
      },
    );

    testWidgets('tablets keep the inline dropdown and open it downward', (
      tester,
    ) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final autocomplete = tester.widget<Autocomplete<Map<String, dynamic>>>(
        find.byType(Autocomplete<Map<String, dynamic>>),
      );
      expect(
        autocomplete.optionsViewOpenDirection,
        OptionsViewOpenDirection.down,
      );
    });
  });
}

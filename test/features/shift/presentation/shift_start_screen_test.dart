import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/shift/data/shift_repository.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';
import 'package:jarz_pos/src/features/shift/presentation/shift_start_screen.dart';

class _FakeShiftRepository extends ShiftRepository {
  _FakeShiftRepository({
    required this.paymentMethods,
    this.activeShift,
  }) : super(Dio());

  final List<Map<String, dynamic>> paymentMethods;
  ShiftEntry? activeShift;
  List<Map<String, dynamic>>? startedOpeningBalances;
  String? startedPosProfile;

  @override
  Future<ShiftEntry?> getActiveShift({String? posProfile}) async {
    return activeShift;
  }

  @override
  Future<List<Map<String, dynamic>>> getShiftPaymentMethods(String posProfile) async {
    return paymentMethods
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  @override
  Future<String> startShift({
    required String posProfile,
    required List<Map<String, dynamic>> openingBalances,
  }) async {
    startedPosProfile = posProfile;
    startedOpeningBalances = openingBalances
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    activeShift = const ShiftEntry(
      name: 'POS-OPN-001',
      posProfile: 'Main',
      status: 'Open',
    );
    return 'POS-OPN-001';
  }
}

class _DummyPosRepository extends PosRepository {
  _DummyPosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getPosProfiles() async => const [];

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(String posProfile) async =>
      const [];
}

class _DummyDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];

  @override
  Future<void> upsert(draft) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _PosNotifierStub extends PosNotifier {
  _PosNotifierStub(PosState initialState)
      : super(_DummyPosRepository(), _DummyDraftCartRepository()) {
    state = initialState;
  }
}

Future<void> _pumpShiftStartScreen(
  WidgetTester tester,
  _FakeShiftRepository repository,
) async {
  final router = GoRouter(
    initialLocation: AppRoutes.shiftStart,
    routes: [
      GoRoute(
        path: AppRoutes.shiftStart,
        builder: (context, state) => const ShiftStartScreen(),
      ),
      GoRoute(
        path: AppRoutes.pos,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('POS screen')),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login screen')),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(repository),
        posNotifierProvider.overrideWith(
          (ref) => _PosNotifierStub(
            PosState(
              profiles: const [
                {'name': 'Main'},
              ],
              selectedProfile: const {'name': 'Main'},
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('ShiftStartScreen blind count', () {
    testWidgets('shows an empty counted cash field and blocks empty submit', (
      tester,
    ) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: null,
        paymentMethods: const [
          {
            'mode_of_payment': 'Cash',
            'account': 'Main Cash - J',
            'amounts_hidden': 1,
          },
        ],
      );

      // Act
      await _pumpShiftStartScreen(tester, repository);

      // Assert
      final amountField = tester.widget<TextField>(find.byType(TextField));
      expect(amountField.controller?.text ?? '', isEmpty);
      expect(find.text('Counted Opening Cash'), findsOneWidget);
      expect(find.text('Count the cash in the drawer and enter the amount.'), findsOneWidget);
      expect(find.textContaining('System Balance:'), findsNothing);
      expect(find.textContaining('Difference:'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Start Shift'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the counted cash amount.'), findsOneWidget);
      expect(repository.startedOpeningBalances, isNull);
    });

    testWidgets('submits only the user entered opening count and navigates to POS', (
      tester,
    ) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: null,
        paymentMethods: const [
          {
            'mode_of_payment': 'Cash',
            'account': 'Main Cash - J',
            'amounts_hidden': 1,
          },
        ],
      );

      // Act
      await _pumpShiftStartScreen(tester, repository);
      await tester.enterText(find.byType(TextField), '145.75');
      await tester.tap(find.widgetWithText(FilledButton, 'Start Shift'));
      await tester.pumpAndSettle();

      // Assert
      expect(repository.startedPosProfile, 'Main');
      expect(repository.startedOpeningBalances, const [
        {
          'mode_of_payment': 'Cash',
          'account': 'Main Cash - J',
          'opening_amount': 145.75,
        },
      ]);
      expect(find.text('POS screen'), findsOneWidget);
    });
  });
}
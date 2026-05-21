import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/cart_widget.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

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

Future<void> _pumpCartWidget(WidgetTester tester, PosState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub(state)),
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
        home: const Scaffold(body: CartWidget()),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

PosState _buildState({
  required bool isAmendmentDraft,
  String? amendmentSourceInvoiceId,
}) {
  return PosState(
    selectedProfile: const {'name': 'Main'},
    cartItems: const [
      {
        'item_code': 'ITEM-1',
        'item_name': 'Blueberry Large',
        'quantity': 1,
        'rate': 160,
        'type': 'item',
      },
    ],
    isPickup: true,
    isAmendmentDraft: isAmendmentDraft,
    amendmentSourceInvoiceId: amendmentSourceInvoiceId,
  );
}

void main() {
  group('CartWidget amendment checkout', () {
    testWidgets(
      'shows submit amendment action when amendment draft has source invoice',
      (tester) async {
        await _pumpCartWidget(
          tester,
          _buildState(
            isAmendmentDraft: true,
            amendmentSourceInvoiceId: 'ACC-SINV-2026-15739',
          ),
        );

        expect(find.text('Submit Amendment'), findsOneWidget);
        expect(find.text('Amendment submit unavailable'), findsNothing);
        expect(
          find.text(
            'Review the changes carefully, then submit to replace the original invoice.',
          ),
          findsOneWidget,
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets(
      'disables amendment submit when draft is missing source invoice',
      (tester) async {
        await _pumpCartWidget(
          tester,
          _buildState(isAmendmentDraft: true),
        );

        expect(find.text('Submit Amendment'), findsOneWidget);
        expect(
          find.text(
            'Amendment submission is unavailable for this draft. Return to the order and reopen the amendment.',
          ),
          findsOneWidget,
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      },
    );
  });
}
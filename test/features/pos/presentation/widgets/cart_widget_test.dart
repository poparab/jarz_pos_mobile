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

/// Builds a bundle cart item whose `bundle_details` came back through JSON, as
/// happens for a restored draft / offline-cached cart. The decoded value is a
/// `Map<String, dynamic>` holding `List<dynamic>`, NOT the
/// `Map<String, List<Map<String, dynamic>>>` the widget used to hard-cast to.
PosState _buildBundleState({required Object? selectedItems}) {
  return PosState(
    selectedProfile: const {'name': 'Main'},
    cartItems: [
      {
        'item_code': 'BUNDLE-1',
        'item_name': 'Family Box',
        'quantity': 1,
        'rate': 500,
        'type': 'bundle',
        'bundle_details': <String, dynamic>{
          'bundle_id': 'BUNDLE-1',
          'bundle_info': <String, dynamic>{
            'item_groups': <dynamic>[
              <String, dynamic>{'group_name': 'Flavours', 'group_key': 'g1'},
            ],
          },
          'selected_items': selectedItems,
        },
      },
    ],
    isPickup: true,
  );
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

        // The promo section also renders an ElevatedButton ("Apply"), so scope
        // the lookup to the amendment/checkout button via its label.
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Submit Amendment'),
            matching: find.byType(ElevatedButton),
          ),
        );
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

        // The promo section also renders an ElevatedButton ("Apply"), so scope
        // the lookup to the amendment/checkout button via its label.
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Submit Amendment'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(button.onPressed, isNull);
      },
    );
  });

  group('CartWidget bundle details rendering', () {
    testWidgets(
      'renders JSON-decoded bundle selections without a cast error',
      (tester) async {
        // Regression: a hard `as Map<String, List<Map<String, dynamic>>>?` cast
        // threw "_Map<String, dynamic> is not a subtype of ..." during build.
        await _pumpCartWidget(
          tester,
          _buildBundleState(
            selectedItems: <String, dynamic>{
              'g1': <dynamic>[
                <String, dynamic>{'name': 'Blueberry'},
                <String, dynamic>{'name': 'Blueberry'},
                <String, dynamic>{'name': 'Mango'},
              ],
            },
          ),
        );

        expect(tester.takeException(), isNull);
        // Identical items are collapsed into a count.
        expect(find.text('Flavours: Blueberry x2, Mango'), findsOneWidget);
      },
    );

    testWidgets(
      'renders the strongly typed in-memory bundle shape unchanged',
      (tester) async {
        await _pumpCartWidget(
          tester,
          _buildBundleState(
            selectedItems: <String, List<Map<String, dynamic>>>{
              'g1': <Map<String, dynamic>>[
                <String, dynamic>{'name': 'Mango'},
              ],
            },
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Flavours: Mango'), findsOneWidget);
      },
    );

    for (final malformed in <(String, Object?)>[
      ('null selections', null),
      ('a string instead of a map', 'not-a-map'),
      ('a list instead of a map', <dynamic>[]),
      ('non-map entries', <String, dynamic>{
        'g1': <dynamic>['just a string', 42],
      }),
      ('a non-list group value', <String, dynamic>{'g1': 'oops'}),
    ]) {
      testWidgets(
        'survives malformed bundle selections: ${malformed.$1}',
        (tester) async {
          // The cart must degrade to hiding the details, never throw at build.
          await _pumpCartWidget(
            tester,
            _buildBundleState(selectedItems: malformed.$2),
          );

          expect(tester.takeException(), isNull);
          expect(find.text('Family Box'), findsOneWidget);
        },
      );
    }
  });
}
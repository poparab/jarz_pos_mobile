import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/basket_rollup.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/stock_alternative.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/basket_shortage_banner.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/stock_elsewhere_note.dart';

/// The consolidated pick list on the Batch tab.
///
/// Nothing here changes what the list blocks — the Start button reads
/// `rollup.hasShortages`, which these rows do not touch. The only question is
/// whether the operator is told that the fix is a transfer rather than a
/// purchase.
Future<void> _pump(
  WidgetTester tester,
  BasketRollup rollup, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(
        body: SingleChildScrollView(child: BasketPickList(rollup: rollup)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

RollupComponent _short({
  double? availableElsewhere,
  List<StockAlternative>? alternatives,
}) {
  return RollupComponent(
    itemCode: 'RM-LABEL',
    itemName: 'Jar label',
    uom: 'Nos',
    sourceWarehouse: 'Raw Material - J',
    requiredQty: 8,
    availableQty: 0,
    missingQty: 8,
    reason: 'insufficient_stock',
    availableElsewhere: availableElsewhere,
    alternatives: alternatives,
  );
}

void main() {
  testWidgets('a shortage sitting in other stores names the fullest one',
      (tester) async {
    await _pump(
      tester,
      BasketRollup(
        ok: false,
        components: [
          _short(
            availableElsewhere: 48.5,
            alternatives: const [
              StockAlternative(warehouse: 'Stores - J', availableQty: 40.5),
              StockAlternative(warehouse: 'Nasr City - J', availableQty: 8),
            ],
          ),
        ],
        shortages: [_short()],
      ),
    );

    expect(find.text('Short by 8 Nos'), findsOneWidget);
    expect(
      find.text(
        '40.5 Nos is in Stores - J and 1 more '
        '\u2014 needs a stock transfer, not a purchase',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a lookup that found none anywhere says so', (tester) async {
    await _pump(
      tester,
      BasketRollup(
        ok: false,
        components: [
          _short(
            availableElsewhere: 0,
            alternatives: const <StockAlternative>[],
          ),
        ],
        shortages: [_short()],
      ),
    );

    expect(
      find.text('None of it in any other store \u2014 this one has to be bought'),
      findsOneWidget,
    );
  });

  testWidgets('a server that never looked adds no row at all', (tester) async {
    await _pump(
      tester,
      BasketRollup(ok: false, components: [_short()], shortages: [_short()]),
    );

    expect(find.text('Short by 8 Nos'), findsOneWidget);
    expect(tester.getSize(find.byType(StockElsewhereNote)), Size.zero);
    expect(find.textContaining('stock transfer'), findsNothing);
    expect(find.textContaining('any other store'), findsNothing);
  });

  testWidgets('a covered component is never asked where else it is',
      (tester) async {
    await _pump(
      tester,
      const BasketRollup(
        components: [
          RollupComponent(
            itemCode: 'RM-FLOUR',
            itemName: 'Flour',
            uom: 'Kg',
            requiredQty: 4,
            availableQty: 100,
          ),
        ],
      ),
    );

    expect(find.text('All materials available'), findsOneWidget);
    expect(find.byType(StockElsewhereNote), findsNothing);
  });

  testWidgets('the Arabic hint lays out at 360 dp without overflowing',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      BasketRollup(
        ok: false,
        components: [
          _short(
            availableElsewhere: 48.5,
            alternatives: const [
              StockAlternative(warehouse: 'Stores - J', availableQty: 40.5),
              StockAlternative(warehouse: 'Nasr City - J', availableQty: 8),
            ],
          ),
        ],
        shortages: [_short()],
      ),
      locale: const Locale('ar'),
    );

    expect(tester.takeException(), isNull);
  });
}

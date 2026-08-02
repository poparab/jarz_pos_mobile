import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/widgets/batch_cost_panel.dart';

Future<void> _pump(WidgetTester tester, BatchCost cost) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: BatchCostView(cost: cost)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('says the cost is unavailable instead of rendering a fake zero',
      (tester) async {
    await _pump(
      tester,
      const BatchCost(
        workOrder: 'MFG-WO-0001',
        materialCost: 812.5,
        producedQty: 0,
        currency: 'EGP',
      ),
    );

    expect(find.text('No cost yet — nothing produced'), findsOneWidget);
    // Materials are known even before anything comes out, so that figure stays.
    expect(find.text('Materials'), findsOneWidget);
    // The per-unit and standard tiles are absent rather than showing 0.00.
    expect(find.text('Per unit'), findsNothing);
    expect(find.text('Standard'), findsNothing);
    expect(find.text('Variance'), findsNothing);
  });

  testWidgets('shows a per-unit cost but no variance when the BOM has no '
      'standard', (tester) async {
    await _pump(
      tester,
      const BatchCost(
        workOrder: 'MFG-WO-0001',
        materialCost: 900,
        producedQty: 30,
        costPerUnit: 30,
        currency: 'EGP',
      ),
    );

    expect(find.text('Per unit'), findsOneWidget);
    expect(find.text('Standard'), findsNothing);
    expect(find.text('Variance'), findsNothing);
    // Half the comparison is missing, and the panel says so.
    expect(find.text('No cost yet — nothing produced'), findsOneWidget);
  });

  testWidgets('a zero standard is treated as no standard at all',
      (tester) async {
    // A BOM with no costing comes back as 0, and dividing by it would report a
    // 100% unfavourable variance on every batch.
    await _pump(
      tester,
      const BatchCost(
        workOrder: 'MFG-WO-0001',
        materialCost: 900,
        producedQty: 30,
        costPerUnit: 30,
        standardPerUnit: 0,
        currency: 'EGP',
      ),
    );

    expect(find.text('Standard'), findsNothing);
    expect(find.text('Variance'), findsNothing);
    expect(find.text('No cost yet — nothing produced'), findsOneWidget);
  });

  testWidgets('names an overrun against standard', (tester) async {
    await _pump(
      tester,
      const BatchCost(
        workOrder: 'MFG-WO-0001',
        materialCost: 900,
        producedQty: 30,
        costPerUnit: 30,
        standardPerUnit: 25,
        varianceAmount: 5,
        variancePct: 20,
        currency: 'EGP',
      ),
    );

    expect(find.text('Per unit'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Variance'), findsOneWidget);
    expect(find.text('20% over standard'), findsOneWidget);
    expect(find.text('No cost yet — nothing produced'), findsNothing);
  });

  testWidgets('names a saving against standard', (tester) async {
    await _pump(
      tester,
      const BatchCost(
        workOrder: 'MFG-WO-0001',
        materialCost: 660,
        producedQty: 30,
        costPerUnit: 22,
        standardPerUnit: 25,
        varianceAmount: -3,
        variancePct: -12,
        currency: 'EGP',
      ),
    );

    expect(find.text('12% under standard'), findsOneWidget);
  });
}

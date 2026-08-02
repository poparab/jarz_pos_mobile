import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manufacturing/data/models/running_batch.dart';
import 'package:jarz_pos/src/features/manufacturing/presentation/screens/production_running_tab.dart';
import 'package:jarz_pos/src/features/manufacturing/state/running_batches_notifier.dart';

class _StubRunningBatches extends RunningBatchesNotifier {
  _StubRunningBatches(this._batches);
  final List<RunningBatch> _batches;

  @override
  Future<List<RunningBatch>> build() async => _batches;
}

const _running = RunningBatch(
  workOrder: 'MFG-WO-0001',
  itemCode: 'CAKE-A',
  itemName: 'Cake A',
  bomName: 'BOM-CAKE-A-001',
  stockUom: 'Nos',
  qty: 30,
  producedQty: 12,
  status: 'In Process',
  startedBy: 'baker@jarz.test',
  startedAt: '2026-08-02 07:15:00',
  elapsedMinutes: 95,
);

UserRoles _roles(List<String> roles) =>
    UserRoles(user: 'someone@jarz.test', roles: roles);

Future<void> _pump(
  WidgetTester tester, {
  required List<RunningBatch> batches,
  required List<String> roles,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        runningBatchesProvider.overrideWith(() => _StubRunningBatches(batches)),
        userRolesFutureProvider.overrideWith((ref) async => _roles(roles)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ProductionRunningTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders a running batch with its planned and produced figures',
      (tester) async {
    await _pump(
      tester,
      batches: const [_running],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('Cake A'), findsOneWidget);
    expect(find.text('MFG-WO-0001'), findsOneWidget);
    expect(find.text('30 Nos planned · 12 produced'), findsOneWidget);
    expect(find.textContaining('baker@jarz.test'), findsOneWidget);
    // 95 minutes reads as "1h 35m", not "95 min" — past the hour the operator
    // should not have to divide.
    expect(find.text('1h 35m'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('elapsed under an hour stays in plain minutes', (tester) async {
    await _pump(
      tester,
      batches: [_running.copyWith(elapsedMinutes: 45)],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('45 min'), findsOneWidget);
  });

  testWidgets('says so plainly when nothing is running', (tester) async {
    await _pump(
      tester,
      batches: const [],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('No batches running'), findsOneWidget);
  });

  testWidgets('surfaces leftover WIP as a warning, not a footnote',
      (tester) async {
    await _pump(
      tester,
      batches: const [
        RunningBatch(
          workOrder: 'MFG-WO-0002',
          itemCode: 'CAKE-B',
          itemName: 'Cake B',
          stockUom: 'Kg',
          qty: 10,
          wipLeftoverQty: 4.5,
        ),
      ],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('4.5 Kg left in WIP'), findsOneWidget);
    expect(find.text('Return to store'), findsOneWidget);
  });

  testWidgets('an operator sees the stranded material but cannot move it',
      (tester) async {
    // The gate is deliberately narrower than the board's own view permission,
    // which admits Production Operator: returning WIP is a stock correction.
    await _pump(
      tester,
      batches: const [
        RunningBatch(
          workOrder: 'MFG-WO-0002',
          itemCode: 'CAKE-B',
          itemName: 'Cake B',
          stockUom: 'Kg',
          qty: 10,
          wipLeftoverQty: 4.5,
        ),
      ],
      roles: const [RoleNames.productionOperator],
    );

    expect(find.text('4.5 Kg left in WIP'), findsOneWidget);
    expect(find.text('Return to store'), findsNothing);
    // Operators may still finish what they started.
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('a batch with no SOP offers no SOP button', (tester) async {
    await _pump(
      tester,
      batches: const [_running],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('View SOP'), findsNothing);
  });

  testWidgets('a batch stamped with an SOP version offers to open it',
      (tester) async {
    await _pump(
      tester,
      batches: [_running.copyWith(sopVersion: 'SOP-0007#3')],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('View SOP'), findsOneWidget);
  });

  testWidgets('flags a work order that was never actually started',
      (tester) async {
    await _pump(
      tester,
      batches: const [
        RunningBatch(
          workOrder: 'MFG-WO-0003',
          itemCode: 'CAKE-C',
          itemName: 'Cake C',
          stockUom: 'Nos',
          qty: 5,
        ),
      ],
      roles: const [RoleNames.manufacturingManager],
    );

    expect(find.text('This batch was never started'), findsOneWidget);
    // Warned, not blocked — the server owns the rule and a missing timestamp
    // must not strand real material on the floor.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}

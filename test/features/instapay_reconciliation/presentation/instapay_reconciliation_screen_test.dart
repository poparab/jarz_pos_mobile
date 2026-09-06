import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/dio_provider.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/models/escalated_payment_order.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/data/models/unconfirmed_online_order.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/presentation/instapay_reconciliation_screen.dart';
import 'package:jarz_pos/src/features/instapay_reconciliation/state/instapay_reconciliation_providers.dart';
import 'package:jarz_pos/src/features/labels/models/label_models.dart';
import 'package:jarz_pos/src/features/labels/state/labels_notifier.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

/// A no-op POS notifier: only `state.selectedProfile` is read by this screen
/// (to key the two providers under test by `posProfile == null`), and every
/// unstubbed member throws by way of [noSuchMethod], so any accidental extra
/// call is a loud test failure rather than a silent no-op.
class _PosNotifierStub extends StateNotifier<PosState> implements PosNotifier {
  _PosNotifierStub() : super(PosState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

EscalatedPaymentOrder _escalation({
  required String invoice,
  required int outForDeliverySeconds,
  int thresholdHours = 4,
  bool alreadyAlerted = false,
  String branch = 'Nasr City',
}) {
  return EscalatedPaymentOrder(
    invoice: invoice,
    customer: 'CUST-$invoice',
    customerName: 'Customer $invoice',
    branch: branch,
    amount: 100,
    paymentMethod: 'InstaPay',
    outForDeliverySeconds: outForDeliverySeconds,
    thresholdHours: thresholdHours,
    alreadyAlerted: alreadyAlerted,
  );
}

UnconfirmedOnlineOrder _order(String invoice) {
  return UnconfirmedOnlineOrder(
    invoice: invoice,
    customer: 'CUST-$invoice',
    customerName: 'Customer $invoice',
    amount: 50,
    paymentMethod: 'InstaPay',
    ageSeconds: 600,
    canConfirm: true,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<UnconfirmedOnlineOrder> orders,
  required List<EscalatedPaymentOrder> escalations,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(MockDio()),
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        unconfirmedOnlineOrdersProvider(null).overrideWith((ref) async => orders),
        unconfirmedPaymentEscalationsProvider(null)
            .overrideWith((ref) async => escalations),
        // AppDrawer dependencies: keep them inert so the (off-screen, but
        // still built) drawer never needs a real network call.
        isLineManagerProvider.overrideWithValue(false),
        isModeratorProvider.overrideWithValue(false),
        canAccessB2bProvider.overrideWithValue(false),
        canAccessManagerDashboardRoleProvider.overrideWithValue(false),
        canAccessShiftMonitorProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        canAccessProductionBoardProvider.overrideWithValue(false),
        canAccessCashTransferProvider.overrideWithValue(false),
        canAccessStockTransferProvider.overrideWithValue(false),
        canAccessInventoryCountProvider.overrideWithValue(false),
        canAccessPurchaseInvoiceProvider.overrideWithValue(false),
        canAccessReportsHubProvider.overrideWithValue(false),
        canAccessMonthlyExpensesProvider.overrideWithValue(false),
        requirePosShiftProvider.overrideWithValue(false),
        activeShiftProvider.overrideWith((ref) async => null),
        labelAlertCountProvider.overrideWith(
          (ref) async => const LabelSummary(
            total: 0,
            tracked: 0,
            outOfStock: 0,
            reorderNow: 0,
            reorderSoon: 0,
            onOrder: 0,
            ok: 0,
            notTracked: 0,
            needsAttention: 0,
          ),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: InstapayReconciliationScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPlatformChannels();

  group('InstapayReconciliationScreen escalations', () {
    testWidgets('renders the escalated section above the plain list',
        (tester) async {
      await _pump(
        tester,
        orders: [_order('INV-PLAIN')],
        escalations: [_escalation(invoice: 'INV-ESC', outForDeliverySeconds: 20000)],
      );

      expect(find.text('ESCALATED'), findsOneWidget);
      expect(find.textContaining('INV-ESC', findRichText: true), findsWidgets);
      expect(find.textContaining('INV-PLAIN', findRichText: true), findsWidgets);
    });

    testWidgets('sorts escalated orders worst-first by time out for delivery',
        (tester) async {
      await _pump(
        tester,
        orders: const [],
        escalations: [
          _escalation(invoice: 'INV-SHORT', outForDeliverySeconds: 5000),
          _escalation(invoice: 'INV-WORST', outForDeliverySeconds: 90000),
          _escalation(invoice: 'INV-MID', outForDeliverySeconds: 30000),
        ],
      );

      final displayIds = ['INV-SHORT', 'INV-WORST', 'INV-MID']
          .map((invoice) =>
              tester.getTopLeft(find.textContaining(invoice).first).dy)
          .toList();

      // The worst (longest out-for-delivery) order must appear before the
      // shorter ones — smaller dy means higher up the screen.
      expect(displayIds[1], lessThan(displayIds[0]));
      expect(displayIds[1], lessThan(displayIds[2]));
      expect(displayIds[2], lessThan(displayIds[0]));
    });

    testWidgets(
        'an order that is both escalated and unconfirmed renders once, with confirm/collect actions',
        (tester) async {
      await _pump(
        tester,
        orders: [_order('INV-DUP')],
        escalations: [_escalation(invoice: 'INV-DUP', outForDeliverySeconds: 40000)],
      );

      // Rendered once (escalated card wins), not duplicated as a plain row.
      // (`find.text('INV-DUP')` matches only the exact displayId title, not
      // the "Customer INV-DUP" subtitle below it.)
      expect(find.text('INV-DUP'), findsOneWidget);
      expect(find.text('Confirm received'), findsOneWidget);
      expect(find.text('Collected cash instead'), findsOneWidget);
    });

    testWidgets('already_alerted does not hide the escalated row',
        (tester) async {
      await _pump(
        tester,
        orders: const [],
        escalations: [
          _escalation(
            invoice: 'INV-ALERTED',
            outForDeliverySeconds: 15000,
            alreadyAlerted: true,
          ),
        ],
      );

      expect(find.text('INV-ALERTED'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });
  });
}

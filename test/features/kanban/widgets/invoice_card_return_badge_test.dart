// The post-dispatch return badge on the Kanban invoice card.
//
// A FULLY returned order lands in the terminal "Returned" column, so the column
// header already tells the story. The badge earns its keep on the PARTIALLY
// returned card, which keeps its old state and therefore sits in an active
// column looking exactly like an untouched order. These tests lock that in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';

/// Inert stand-in for the real KanbanNotifier, whose constructor opens sockets
/// and arms polling timers. The card only reads state at build time.
class _FakeKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _FakeKanbanNotifier() : super(KanbanState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InvoiceCard _card({
  String status = 'Out For Delivery',
  String? returnStatus,
  double returnedAmount = 0.0,
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-00042',
    invoiceIdShort: '42',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: status,
    postingDate: '2026-07-19',
    deliverySlotLabel: 'Jul 19 - 5:00 PM',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: [
      InvoiceItem(
        itemCode: 'CAKE-01',
        itemName: 'Chocolate Cake',
        qty: 2,
        rate: 225,
        amount: 450,
      ),
    ],
    requiresAcceptanceFlag: false,
    outstandingAmount: 0,
    returnStatus: returnStatus,
    returnedAmount: returnedAmount,
  );
}

Future<void> _pumpCard(WidgetTester tester, InvoiceCard invoice) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kanbanProvider.overrideWith((ref) => _FakeKanbanNotifier()),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
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
        home: Scaffold(
          body: ListView(
            children: [
              SizedBox(width: 380, child: InvoiceCardWidget(invoice: invoice)),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows a partial-return badge on a card still in an active column',
      (tester) async {
    await _pumpCard(
      tester,
      _card(returnStatus: 'Partially Returned', returnedAmount: 120),
    );

    expect(find.textContaining('Partially returned'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the returned amount when the backend reports one',
      (tester) async {
    await _pumpCard(
      tester,
      _card(returnStatus: 'Partially Returned', returnedAmount: 120),
    );

    expect(find.textContaining('120'), findsWidgets);
  });

  testWidgets('falls back to a plain label when no amount was returned',
      (tester) async {
    await _pumpCard(tester, _card(returnStatus: 'Partially Returned'));

    expect(find.text('Partially returned'), findsOneWidget);
  });

  testWidgets('shows a full-return badge on a fully returned card',
      (tester) async {
    await _pumpCard(
      tester,
      _card(
        status: 'Returned',
        returnStatus: 'Fully Returned',
        returnedAmount: 450,
      ),
    );

    expect(find.textContaining('Returned'), findsWidgets);
    expect(find.textContaining('Partially returned'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draws no badge on an untouched order', (tester) async {
    await _pumpCard(tester, _card());

    expect(find.textContaining('returned'), findsNothing);
    expect(find.textContaining('Returned'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draws no badge when the payload predates the return fields',
      (tester) async {
    // Old cached/offline payloads carry neither key — the card must render
    // exactly as before, not throw and not paint an empty badge.
    final legacy = InvoiceCard.fromJson({
      'name': 'ACC-SINV-2026-00042',
      'customer_name': 'Sarah Johnson',
      'status': 'Ready',
      'posting_date': '2026-07-19',
      'grand_total': 450,
      'items': const [],
    });

    await _pumpCard(tester, legacy);

    expect(legacy.hasReturn, isFalse);
    expect(find.textContaining('eturned'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

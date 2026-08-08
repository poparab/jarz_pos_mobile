// The delivery area line on the Kanban invoice card.
//
// Dispatchers hand out orders by area, and the card used to show location only
// through the sub-territory chip — which renders exclusively for territories
// that HAVE sub-territories, so most cards showed none at all. These tests pin
// down that every card with a territory shows one, and that it agrees with the
// Arabic-first precedence the rest of the card already uses.
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
  String territory = 'Maadi',
  String? territoryDisplay,
  String? territoryNameAr,
  bool isPickup = false,
}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-00042',
    invoiceIdShort: '42',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: territory,
    territoryDisplay: territoryDisplay,
    territoryNameAr: territoryNameAr,
    status: 'Ready',
    postingDate: '2026-08-05',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    requiresAcceptanceFlag: false,
    outstandingAmount: 0,
    isPickup: isPickup,
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
  group('InvoiceCard delivery area', () {
    testWidgets('shows the raw territory when nothing better is available',
        (tester) async {
      await _pumpCard(tester, _card(territory: 'Maadi'));
      expect(find.text('Maadi'), findsOneWidget);
    });

    testWidgets('prefers the display label over the raw territory',
        (tester) async {
      await _pumpCard(
        tester,
        _card(territory: 'maadi-1', territoryDisplay: 'Maadi Degla'),
      );
      expect(find.text('Maadi Degla'), findsOneWidget);
      expect(find.text('maadi-1'), findsNothing);
    });

    testWidgets('prefers the Arabic name above all — same precedence the rest '
        'of the card uses, so a card and its sheet never disagree',
        (tester) async {
      await _pumpCard(
        tester,
        _card(
          territory: 'maadi-1',
          territoryDisplay: 'Maadi Degla',
          territoryNameAr: 'المعادي',
        ),
      );
      expect(find.text('المعادي'), findsOneWidget);
      expect(find.text('Maadi Degla'), findsNothing);
    });

    testWidgets('renders nothing rather than an empty row when there is no '
        'territory at all', (tester) async {
      await _pumpCard(tester, _card(territory: ''));
      expect(find.byIcon(Icons.place_outlined), findsNothing);
    });

    testWidgets('a whitespace-only territory counts as absent', (tester) async {
      await _pumpCard(tester, _card(territory: '   '));
      expect(find.byIcon(Icons.place_outlined), findsNothing);
    });

    testWidgets('pickup orders still show their area', (tester) async {
      // A pickup has no delivery run, but the area is still how staff find the
      // order, so it is not gated on isPickup.
      await _pumpCard(tester, _card(territory: 'Zamalek', isPickup: true));
      expect(find.text('Zamalek'), findsOneWidget);
    });
  });
}

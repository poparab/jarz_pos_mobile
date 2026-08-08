// The courier run-progress badge on the Kanban invoice card.
//
// "7/12 delivered" is the difference between a dispatcher knowing where a run
// stands and phoning the courier to ask. These tests pin when the badge appears,
// what it says, and — most importantly — that it stays off every card that is not
// a stop on somebody's run, because that is what keeps the board readable.
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
/// and arms polling timers. Unlike the pin-badge fake this one carries board
/// state, because the run progress is derived from exactly that.
class _FakeKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _FakeKanbanNotifier(Map<String, List<InvoiceCard>> invoices)
      : super(KanbanState(invoices: invoices));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InvoiceCard _stop({
  required String id,
  String status = 'Out for Delivery',
  String? courierParty = 'EMP-COURIER-001',
  String? courier = 'Ahmed Hassan',
  String? deliveredAt,
  String? failureReason,
  int? attemptNo,
  int? sequence,
  bool isPickup = false,
}) {
  return InvoiceCard(
    id: id,
    invoiceIdShort: id,
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: status,
    postingDate: '2026-08-08',
    deliverySlotLabel: 'Aug 8 - 5:00 PM',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    requiresAcceptanceFlag: false,
    outstandingAmount: 0,
    isPickup: isPickup,
    courier: courier,
    courierParty: courierParty,
    deliveredAt: deliveredAt,
    deliveryFailureReason: failureReason,
    deliveryAttemptNo: attemptNo,
    deliverySequence: sequence,
  );
}

/// Pump [subject]'s card with [board] as the whole Kanban board, so the derived
/// run progress sees the same stops the dispatcher would.
Future<void> _pumpCard(
  WidgetTester tester, {
  required InvoiceCard subject,
  required List<InvoiceCard> board,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kanbanProvider.overrideWith(
          (ref) => _FakeKanbanNotifier({'board': board}),
        ),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(false),
        managerAccessProvider.overrideWith((ref) => false),
      ],
      child: MaterialApp(
        locale: locale,
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
              SizedBox(width: 380, child: InvoiceCardWidget(invoice: subject)),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('run progress badge', () {
    testWidgets('reports progress across the courier\'s stops', (tester) async {
      final subject = _stop(id: 'A');
      final board = [
        subject,
        _stop(id: 'B', status: 'Delivered'),
        _stop(id: 'C', status: 'Delivered'),
        _stop(id: 'D'),
      ];

      await _pumpCard(tester, subject: subject, board: board);

      expect(find.text('2/4 delivered'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('prefixes the stop number on a sequenced run', (tester) async {
      final subject = _stop(id: 'A', sequence: 3);
      await _pumpCard(
        tester,
        subject: subject,
        board: [subject, _stop(id: 'B', status: 'Delivered')],
      );

      expect(find.text('Stop 3 · 1/2 delivered'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('omits the stop number on an unsequenced run', (tester) async {
      // Sequencing is optional by contract — an unsequenced run must still work.
      final subject = _stop(id: 'A', sequence: 0);
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.text('0/1 delivered'), findsOneWidget);
      expect(find.textContaining('Stop'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('surfaces missed stops in the run summary', (tester) async {
      final subject = _stop(id: 'A');
      final board = [
        subject,
        _stop(id: 'B', status: 'Delivered'),
        _stop(id: 'C', failureReason: 'CUSTOMER_UNREACHABLE'),
      ];

      await _pumpCard(tester, subject: subject, board: board);

      expect(find.text('1/3 delivered · 1 missed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('flags this stop when its own delivery was missed',
        (tester) async {
      // The invoice stays at Out for Delivery by design (§5 invariant 4), so
      // without this badge nothing on the board says the attempt failed.
      final subject = _stop(id: 'A', failureReason: 'WRONG_ADDRESS', attemptNo: 2);
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.text('Delivery missed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not flag a stop that was eventually delivered',
        (tester) async {
      final subject = _stop(
        id: 'A',
        attemptNo: 2,
        deliveredAt: '2026-08-08 14:32:00',
      );
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.text('Delivery missed'), findsNothing);
      expect(find.text('1/1 delivered'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('counts only the courier who owns this card', (tester) async {
      final subject = _stop(id: 'A', courierParty: 'EMP-1');
      final board = [
        subject,
        _stop(id: 'B', courierParty: 'EMP-1', status: 'Delivered'),
        // Another courier's whole run must not leak into this card's count.
        _stop(id: 'C', courierParty: 'EMP-2', status: 'Delivered'),
        _stop(id: 'D', courierParty: 'EMP-2', status: 'Delivered'),
      ];

      await _pumpCard(tester, subject: subject, board: board);

      expect(find.text('1/2 delivered'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('run progress badge stays off cards that are not stops', () {
    testWidgets('an order still in preparation', (tester) async {
      final subject = _stop(id: 'A', status: 'Ready');
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.textContaining('delivered'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an order with no courier assigned', (tester) async {
      final subject = _stop(id: 'A', courierParty: null, courier: null);
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.textContaining('delivered'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a pickup order', (tester) async {
      final subject = _stop(id: 'A', isPickup: true);
      await _pumpCard(tester, subject: subject, board: [subject]);

      expect(find.textContaining('delivered'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('localisation', () {
    testWidgets('renders the badge in Egyptian Arabic', (tester) async {
      final subject = _stop(id: 'A', sequence: 2);
      final board = [subject, _stop(id: 'B', status: 'Delivered')];

      await _pumpCard(
        tester,
        subject: subject,
        board: board,
        locale: const Locale('ar'),
      );

      // Arabic must be a real translation, not an English fallback.
      expect(find.textContaining('اتسلّم'), findsOneWidget);
      expect(find.textContaining('محطة 2'), findsOneWidget);
      expect(find.text('Stop 2 · 1/2 delivered'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the missed badge in Egyptian Arabic', (tester) async {
      final subject = _stop(id: 'A', failureReason: 'WRONG_ADDRESS');
      await _pumpCard(
        tester,
        subject: subject,
        board: [subject],
        locale: const Locale('ar'),
      );

      expect(find.text('التسليم فات'), findsOneWidget);
      expect(find.text('Delivery missed'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

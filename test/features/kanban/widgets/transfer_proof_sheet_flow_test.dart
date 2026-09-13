// Card -> Pay -> InstaPay when a screenshot is already attached but not yet
// confirmed. Covers the two branches after the proof step: a confirm-tier user
// is asked explicitly and then pays; anyone else is told a manager must
// confirm. Neither needs the image picker, so both run as widget tests.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/kanban/models/kanban_models.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/kanban/widgets/invoice_card_widget.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _RecordingKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _RecordingKanbanNotifier({
    this.confirmError,
    this.confirmReply = const {'success': true},
    this.confirmGate,
    this.receiptStatus = 'Unconfirmed',
  }) : super(KanbanState());

  final Object? confirmError;
  final Map<String, dynamic> confirmReply;

  /// When set, confirmReceipt waits on it, keeping the sheet busy mid-request.
  final Completer<void>? confirmGate;

  /// What the server says about PR-0042 when the sheet re-reads it.
  final String receiptStatus;
  final List<String> calls = [];

  @override
  Future<List<Map<String, dynamic>>> listPaymentReceipts({
    String? posProfile,
    String? status,
  }) async {
    return [
      {
        'name': 'PR-0042',
        'payment_method': 'InstaPay',
        'status': receiptStatus,
        'receipt_image_url': '/private/files/transfer.jpg',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>?> confirmReceipt({
    required String receiptName,
  }) async {
    calls.add('confirm:$receiptName');
    if (confirmGate != null) await confirmGate!.future;
    if (confirmError != null) throw confirmError!;
    return confirmReply;
  }

  @override
  Future<Map<String, dynamic>?> payInvoice({
    required String invoiceId,
    required String paymentMode,
    String? posProfile,
  }) async {
    calls.add('pay:$paymentMode');
    return {'success': true, 'payment_entry': 'ACC-PAY-0001'};
  }

  @override
  Future<void> loadInvoices({bool immediate = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PosNotifierStub extends StateNotifier<PosState> implements PosNotifier {
  _PosNotifierStub() : super(PosState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InvoiceCard _cardWithUnconfirmedProof({String? paymentConfirmationStatus}) {
  return InvoiceCard(
    id: 'ACC-SINV-2026-18289',
    invoiceIdShort: '18289',
    customerName: 'Sarah Johnson',
    customer: 'CUST-0042',
    territory: 'Maadi',
    status: 'Ready',
    postingDate: '2026-09-13',
    grandTotal: 450,
    netTotal: 450,
    totalTaxesAndCharges: 0,
    fullAddress: '12 Nile St, Maadi, Cairo',
    items: const [],
    outstandingAmount: 450,
    isPickup: false,
    posProfile: 'Maadi',
    paymentReceiptName: 'PR-0042',
    paymentReceiptMethod: 'InstaPay',
    paymentReceiptStatus: 'Unconfirmed',
    paymentReceiptImageUrl: '/private/files/transfer.jpg',
    paymentConfirmationStatus: paymentConfirmationStatus,
  );
}

Future<void> _openInstapayProof(
  WidgetTester tester, {
  required _RecordingKanbanNotifier kanban,
  required bool canConfirm,
  InvoiceCard? card,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kanbanProvider.overrideWith((ref) => kanban),
        posNotifierProvider.overrideWith((ref) => _PosNotifierStub()),
        isLineManagerProvider.overrideWithValue(false),
        canActAsLineManagerProvider.overrideWithValue(canConfirm),
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
              SizedBox(
                width: 380,
                child: InvoiceCardWidget(
                  invoice: card ?? _cardWithUnconfirmedProof(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.payment).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Instapay'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    dotenv.loadFromString(isOptional: true);
  });

  testWidgets(
    'staff without the confirm tier are told a manager must confirm',
    (tester) async {
      final kanban = _RecordingKanbanNotifier();
      await _openInstapayProof(tester, kanban: kanban, canConfirm: false);

      expect(find.text(en.transferProofAlreadyUploaded), findsOneWidget);
      await tester.tap(find.text(en.transferProofContinue));
      await tester.pumpAndSettle();

      expect(kanban.calls, isEmpty);
      expect(
        find.text(en.transferProofAwaitingManager('Instapay')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a manager confirms explicitly, then the invoice is paid', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier();
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    // Nothing is confirmed until the manager says the transfer arrived.
    expect(find.text(en.transferProofConfirmTitle), findsOneWidget);
    expect(kanban.calls, isEmpty);

    await tester.tap(find.text(en.transferProofConfirmYes));
    await tester.pumpAndSettle();

    expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
    expect(find.text(en.invoicePaymentSuccess('ACC-PAY-0001')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a manager who has not seen the transfer leaves it unconfirmed', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier();
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.transferProofConfirmNo));
    await tester.pumpAndSettle();

    expect(kanban.calls, isEmpty);
    expect(find.text(en.transferProofAwaitingConfirmation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a server permission refusal on confirm falls back to "manager"', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(
      confirmError: Exception(
        'Failed to confirm receipt: You do not have permission to confirm this receipt',
      ),
    );
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.transferProofConfirmYes));
    await tester.pumpAndSettle();

    expect(kanban.calls, ['confirm:PR-0042']);
    expect(
      find.text(en.transferProofAwaitingManager('Instapay')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  // Review follow-ups (integration review of 378a95a).

  testWidgets(
    'a stale "Awaiting Payment" card still pays when confirm only stamped',
    (tester) async {
      // The card believes the order awaits a transfer, but the server's own
      // check did not post the payment: it only stamped the receipt.
      final kanban = _RecordingKanbanNotifier();
      await _openInstapayProof(
        tester,
        kanban: kanban,
        canConfirm: true,
        card: _cardWithUnconfirmedProof(
          paymentConfirmationStatus: 'Awaiting Payment',
        ),
      );

      await tester.tap(find.text(en.transferProofContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transferProofConfirmYes));
      await tester.pumpAndSettle();

      expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a confirm that recorded the payment is not paid again', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(
      confirmReply: const {
        'success': true,
        'message': 'Receipt confirmed and payment recorded',
        'payment_entry': 'ACC-PAY-0002',
      },
    );
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.transferProofConfirmYes));
    await tester.pumpAndSettle();

    expect(kanban.calls, ['confirm:PR-0042']);
    expect(find.text(en.receiptConfirmedSuccess), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a shift refusal on confirm says a shift is needed, not a manager',
    (tester) async {
      final kanban = _RecordingKanbanNotifier(
        confirmError: Exception(
          'Failed to confirm receipt: No open shift on branch Maadi, so '
          'confirming an online payment is not allowed. Start a shift on this '
          'branch first.',
        ),
      );
      await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

      await tester.tap(find.text(en.transferProofContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transferProofConfirmYes));
      await tester.pumpAndSettle();

      expect(kanban.calls, ['confirm:PR-0042']);
      expect(find.text(en.userErrorShiftRequired), findsOneWidget);
      expect(
        find.text(en.transferProofAwaitingManager('Instapay')),
        findsNothing,
      );
      // The sheet stays open so the user can start a shift and retry.
      expect(find.text(en.transferProofTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a receipt rejected since the board loaded is not confirmed', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(receiptStatus: 'Rejected');
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    expect(find.text(en.transferProofConfirmTitle), findsNothing);
    expect(find.text(en.transferProofRejected), findsOneWidget);
    expect(find.text(en.transferProofContinue), findsNothing);
    expect(kanban.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android back is ignored while a confirm is in flight', (
    tester,
  ) async {
    final gate = Completer<void>();
    final kanban = _RecordingKanbanNotifier(confirmGate: gate);
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.transferProofConfirmYes));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(kanban.calls, ['confirm:PR-0042']);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(en.transferProofTitle), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android back on an idle sheet closes it through Close', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier();
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);
    expect(find.text(en.transferProofTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text(en.transferProofTitle), findsNothing);
    expect(kanban.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

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
import 'package:jarz_pos/src/features/kanban/widgets/transfer_proof_sheet.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _RecordingKanbanNotifier extends StateNotifier<KanbanState>
    implements KanbanNotifier {
  _RecordingKanbanNotifier({
    this.confirmError,
    this.confirmReply = const {'success': true},
    this.confirmGate,
    this.receiptStatus = 'Unconfirmed',
    this.receiptGone = false,
    this.receiptLookupError,
    this.payError,
  }) : super(KanbanState());

  /// When true, get_payment_receipt answers "no current receipt" (null).
  final bool receiptGone;

  /// When set, getPaymentReceipt throws it (an old server, a not-found...).
  final Object? receiptLookupError;

  /// Receipt reads, in order: `get:<name>` or `list`. Kept apart from [calls]
  /// so the write sequence assertions stay about writes.
  final List<String> reads = [];

  /// When set, payInvoice throws it (e.g. the server's shift gate).
  final Object? payError;

  /// How many times the board was reloaded.
  int loads = 0;

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
    reads.add('list');
    return [if (!receiptGone) _row()];
  }

  Map<String, dynamic> _row() => {
    'name': 'PR-0042',
    'payment_method': 'InstaPay',
    'status': receiptStatus,
    'receipt_image_url': '/private/files/transfer.jpg',
  };

  @override
  Future<Map<String, dynamic>?> getPaymentReceipt({
    required String receiptName,
  }) async {
    reads.add('get:$receiptName');
    if (receiptLookupError != null) throw receiptLookupError!;
    return receiptGone ? null : _row();
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
    if (payError != null) throw payError!;
    return {'success': true, 'payment_entry': 'ACC-PAY-0001'};
  }

  @override
  Future<void> loadInvoices({bool immediate = false}) async {
    loads++;
  }

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
    // Nothing was learned about the receipt, so nothing to reload.
    expect(kanban.loads, 0);
    expect(tester.takeException(), isNull);
  });

  // Review follow-ups (pre-release review of 378a95a, round 2).

  testWidgets(
    'a second Continue activation before the dialog is drawn confirms once',
    (tester) async {
      final kanban = _RecordingKanbanNotifier();
      await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

      // A pointer double tap is absorbed by the Navigator for the frame after
      // a push, but a second activation that skips hit testing (a keyboard or
      // accessibility "tap") still reaches the handler the button was last
      // built with. Capture that handler and fire it twice, the second time
      // after the first flow's receipt re-read has finished and its dialog
      // has been pushed but not drawn.
      final button = find.ancestor(
        of: find.text(en.transferProofContinue),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      final onPressed = tester.widget<ButtonStyleButton>(button).onPressed!;
      onPressed();
      await tester.idle();
      onPressed();
      await tester.pumpAndSettle();

      expect(find.text(en.transferProofConfirmTitle), findsOneWidget);

      await tester.tap(find.text(en.transferProofConfirmYes));
      await tester.pumpAndSettle();

      expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
      expect(find.text(en.transferProofConfirmTitle), findsNothing);
      expect(find.text(en.transferProofTitle), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a pay refused after the confirm refreshes the board so Pay pays directly',
    (tester) async {
      // Confirm stamped the receipt; pay_invoice then refused (no open shift).
      // The receipt is now Confirmed on the server, so the stale card must be
      // reloaded: on the old snapshot, Pay reopens the sheet and a new
      // screenshot is refused because the receipt is no longer editable.
      final kanban = _RecordingKanbanNotifier(
        payError: Exception(
          'No open shift on branch Maadi, so paying an invoice is not allowed. '
          'Start a shift on this branch first.',
        ),
      );
      await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

      await tester.tap(find.text(en.transferProofContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transferProofConfirmYes));
      await tester.pumpAndSettle();

      expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
      expect(kanban.loads, 1);
      expect(find.text(en.userErrorShiftRequired), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  // The "receipt changed" loop, and the bounded re-read.

  Finder sheetClose() => find.descendant(
    of: find.byType(TransferProofSheet),
    matching: find.byIcon(Icons.close),
  );

  testWidgets(
    'closing after "receipt changed" reloads the board so Pay sees the truth',
    (tester) async {
      final kanban = _RecordingKanbanNotifier(receiptGone: true);
      await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

      await tester.tap(find.text(en.transferProofContinue));
      await tester.pumpAndSettle();
      expect(find.text(en.transferProofReceiptChanged), findsOneWidget);
      expect(kanban.loads, 0);

      await tester.tap(sheetClose());
      await tester.pumpAndSettle();

      expect(find.text(en.transferProofTitle), findsNothing);
      expect(kanban.loads, 1);
      expect(kanban.calls, isEmpty);
      // A quiet reload: no "awaiting" note that would misstate what happened.
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Android back after a rejection found on re-read reloads too', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(receiptStatus: 'Rejected');
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();
    expect(find.text(en.transferProofRejected), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text(en.transferProofTitle), findsNothing);
    expect(kanban.loads, 1);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the re-read fetches the one receipt, never the branch list', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier();
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    expect(find.text(en.transferProofConfirmTitle), findsOneWidget);
    expect(kanban.reads, ['get:PR-0042']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a server without get_payment_receipt falls back to the list', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(
      receiptLookupError: Exception(
        'Failed to get method for command '
        'jarz_pos.api.payment_receipts.get_payment_receipt with module '
        "'jarz_pos.api.payment_receipts' has no attribute "
        "'get_payment_receipt'",
      ),
    );
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    expect(kanban.reads, ['get:PR-0042', 'list']);
    expect(find.text(en.transferProofConfirmTitle), findsOneWidget);
    await tester.tap(find.text(en.transferProofConfirmYes));
    await tester.pumpAndSettle();
    expect(kanban.calls, ['confirm:PR-0042', 'pay:InstaPay']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a not-found answer stops the confirm and does not fall back', (
    tester,
  ) async {
    final kanban = _RecordingKanbanNotifier(
      receiptLookupError: Exception('POS Payment Receipt PR-0042 not found'),
    );
    await _openInstapayProof(tester, kanban: kanban, canConfirm: true);

    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    expect(kanban.reads, ['get:PR-0042']);
    expect(find.text(en.transferProofReceiptChanged), findsOneWidget);
    expect(find.text(en.transferProofConfirmTitle), findsNothing);
    expect(kanban.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

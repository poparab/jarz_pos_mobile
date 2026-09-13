// Card -> Pay -> InstaPay when a screenshot is already attached but not yet
// confirmed. Covers the two branches after the proof step: a confirm-tier user
// is asked explicitly and then pays; anyone else is told a manager must
// confirm. Neither needs the image picker, so both run as widget tests.
library;

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
  _RecordingKanbanNotifier({this.confirmError}) : super(KanbanState());

  final Object? confirmError;
  final List<String> calls = [];

  @override
  Future<Map<String, dynamic>?> confirmReceipt({
    required String receiptName,
  }) async {
    calls.add('confirm:$receiptName');
    if (confirmError != null) throw confirmError!;
    return {'success': true};
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

InvoiceCard _cardWithUnconfirmedProof() {
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
  );
}

Future<void> _openInstapayProof(
  WidgetTester tester, {
  required _RecordingKanbanNotifier kanban,
  required bool canConfirm,
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
                child: InvoiceCardWidget(invoice: _cardWithUnconfirmedProof()),
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

  testWidgets('staff without the confirm tier are told a manager must confirm',
      (tester) async {
    final kanban = _RecordingKanbanNotifier();
    await _openInstapayProof(tester, kanban: kanban, canConfirm: false);

    expect(find.text(en.transferProofAlreadyUploaded), findsOneWidget);
    await tester.tap(find.text(en.transferProofContinue));
    await tester.pumpAndSettle();

    expect(kanban.calls, isEmpty);
    expect(find.text(en.transferProofAwaitingManager('Instapay')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a manager confirms explicitly, then the invoice is paid',
      (tester) async {
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

  testWidgets('a manager who has not seen the transfer leaves it unconfirmed',
      (tester) async {
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

  testWidgets('a server permission refusal on confirm falls back to "manager"',
      (tester) async {
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
    expect(find.text(en.transferProofAwaitingManager('Instapay')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/session/session_manager.dart';
import 'package:jarz_pos/src/features/auth/data/auth_repository.dart';
import 'package:jarz_pos/src/features/shift/data/shift_repository.dart';
import 'package:jarz_pos/src/features/shift/models/shift_models.dart';
import 'package:jarz_pos/src/features/shift/presentation/shift_end_screen.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

Finder _buttonWithLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
}

class _RecordingAuthRepository extends AuthRepository {
  _RecordingAuthRepository() : super(Dio(), SessionManager());

  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

class _FakeShiftRepository extends ShiftRepository {
  _FakeShiftRepository({
    required this.activeShift,
    required this.summary,
    this.endShiftSummary,
  }) : super(Dio());

  final ShiftEntry? activeShift;
  final ShiftSummary summary;
  final ShiftSummary? endShiftSummary;
  List<Map<String, dynamic>>? submittedClosingBalances;
  String? submittedOpeningEntry;
  List<String>? submittedCourierAcknowledgement;

  @override
  Future<ShiftEntry?> getActiveShift({String? posProfile}) async {
    return activeShift;
  }

  @override
  Future<ShiftSummary> getShiftSummary(String openingEntry) async {
    return summary;
  }

  @override
  Future<ShiftSummary> endShift({
    required String openingEntry,
    required List<Map<String, dynamic>> closingBalances,
    List<String> acknowledgedCourierTransactions = const [],
  }) async {
    submittedOpeningEntry = openingEntry;
    submittedClosingBalances = closingBalances
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    submittedCourierAcknowledgement =
        List<String>.from(acknowledgedCourierTransactions);
    return endShiftSummary ?? summary;
  }
}

Future<void> _pumpShiftEndScreen(
  WidgetTester tester,
  _FakeShiftRepository repository, {
  AuthRepository? authRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(repository),
        activeShiftProvider.overrideWith((ref) async => repository.activeShift),
        // Closing a shift signs the operator out, so every path through this
        // screen needs an auth repository that does not touch the network.
        authRepositoryProvider.overrideWithValue(
          authRepository ?? _RecordingAuthRepository(),
        ),
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
        home: const ShiftEndScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('ShiftEndScreen blind count', () {
    testWidgets('shows a blank counted closing cash field for the cash payment row', (tester) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash'),
          ],
          amountsHidden: true,
        ),
      );

      // Act
      await _pumpShiftEndScreen(tester, repository);

      // Assert
      final amountField = tester.widget<TextField>(find.byType(TextField));
      expect(amountField.controller?.text ?? '', isEmpty);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Counted Closing Cash'), findsOneWidget);
      expect(find.text('Count the cash in the drawer and enter the amount.'), findsOneWidget);
    });

    testWidgets('blocks submitting when counted closing cash is empty', (tester) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash'),
          ],
          amountsHidden: true,
        ),
      );

      // Act
      await _pumpShiftEndScreen(tester, repository);
      await tester.tap(_buttonWithLabel('End Shift').first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter the counted cash amount.'), findsOneWidget);
      expect(repository.submittedClosingBalances, isNull);
    });

    testWidgets('submits the entered counted closing cash amount', (tester) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash'),
          ],
          amountsHidden: true,
        ),
        endShiftSummary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Closed',
          closingEntry: 'POS-CL-001',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(
              modeOfPayment: 'Cash',
              closingAmount: 145.75,
            ),
          ],
          amountsHidden: false,
          varianceVisible: true,
        ),
      );

      // Act
      await _pumpShiftEndScreen(tester, repository);
      await tester.enterText(find.byType(TextField), '145.75');
      await tester.tap(_buttonWithLabel('End Shift').first);
      await tester.pumpAndSettle();

      // Assert
      expect(repository.submittedOpeningEntry, 'POS-OPN-001');
      expect(repository.submittedClosingBalances, const [
        {
          'mode_of_payment': 'Cash',
          'closing_amount': 145.75,
        },
      ]);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows an actionable empty state when no closing payment modes are available', (tester) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 0,
          paymentReconciliation: [],
          amountsHidden: true,
        ),
      );

      // Act
      await _pumpShiftEndScreen(tester, repository);

      // Assert
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Cash entry is unavailable'), findsOneWidget);
      expect(
        find.text('No closing payment method is available for this shift. Reopen the shift or contact support.'),
        findsOneWidget,
      );
      final endShiftButton = tester.widget<ButtonStyleButton>(_buttonWithLabel('End Shift'));
      expect(endShiftButton.onPressed, isNull);
      expect(repository.submittedClosingBalances, isNull);
    });
  });

  group('ShiftEndScreen sign-out on close', () {
    // Ending a shift must end the session with it: a counted-out till may not
    // stay signed in while the operator walks away.
    testWidgets('drops the session as soon as the shift closes', (tester) async {
      // Arrange
      final authRepository = _RecordingAuthRepository();
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash'),
          ],
          amountsHidden: true,
        ),
        endShiftSummary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Closed',
          closingEntry: 'POS-CL-001',
          invoiceCount: 1,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash', closingAmount: 145.75),
          ],
          amountsHidden: false,
        ),
      );

      // Act
      await _pumpShiftEndScreen(
        tester,
        repository,
        authRepository: authRepository,
      );
      await tester.enterText(find.byType(TextField), '145.75');
      await tester.tap(_buttonWithLabel('End Shift').first);
      await tester.pumpAndSettle();

      // Assert: signed out on the spot, and the closing summary still stands so
      // the operator can read it before handing the terminal over.
      expect(authRepository.logoutCalls, 1);
      expect(find.text('Shift ended successfully.'), findsOneWidget);
      expect(_buttonWithLabel('Logout'), findsOneWidget);
    });
  });

  group('ShiftEndScreen courier blocker', () {
    testWidgets('shows settlement guidance when courier balances block closing', (tester) async {
      // Arrange
      final repository = _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 3,
          paymentReconciliation: [
            ShiftBalanceDetail(modeOfPayment: 'Cash'),
          ],
          amountsHidden: true,
          courierCloseBlock: ShiftCourierCloseBlock(
            blocked: true,
            posProfile: 'Dokki',
            transactionCount: 2,
            invoiceCount: 1,
            partyCount: 1,
            netBalance: 160,
            parties: [
              ShiftCourierCloseParty(
                partyType: 'Employee',
                party: 'HR-EMP-0001',
                displayName: 'Ali Courier',
                transactionCount: 2,
                invoiceCount: 1,
                netBalance: 160,
                invoices: ['ACC-SINV-0001'],
              ),
            ],
          ),
        ),
      );

      // Act
      await _pumpShiftEndScreen(tester, repository);

      // Assert
      expect(find.text('Settle courier balances before ending the shift'), findsOneWidget);
      expect(find.textContaining('2 unsettled courier transaction(s)'), findsOneWidget);
      expect(find.textContaining('Ali Courier'), findsOneWidget);
      expect(find.text('Review & Settle Couriers'), findsOneWidget);
    });
  });

  group('ShiftEndScreen courier carry-over', () {
    const carryBlock = ShiftCourierCloseBlock(
      blocked: true,
      requiresAcknowledgement: true,
      posProfile: 'Dokki',
      transactionCount: 2,
      invoiceCount: 2,
      partyCount: 1,
      netBalance: 160,
      parties: [
        ShiftCourierCloseParty(
          partyType: 'Employee',
          party: 'HR-EMP-0001',
          displayName: 'Ali Courier',
          transactionCount: 2,
          invoiceCount: 2,
          netBalance: 160,
        ),
      ],
      transactions: [
        ShiftCourierCloseTransaction(
          courierTransaction: 'CT-0001',
          referenceInvoice: 'ACC-SINV-0001',
          customerName: 'Mona',
          partyType: 'Employee',
          party: 'HR-EMP-0001',
          displayName: 'Ali Courier',
          netBalance: 90,
        ),
        ShiftCourierCloseTransaction(
          courierTransaction: 'CT-0002',
          referenceInvoice: 'ACC-SINV-0002',
          customerName: 'Karim',
          partyType: 'Employee',
          party: 'HR-EMP-0001',
          displayName: 'Ali Courier',
          netBalance: 70,
          carried: true,
          carryCount: 2,
          daysOutstanding: 3,
        ),
      ],
    );

    _FakeShiftRepository buildRepository() {
      return _FakeShiftRepository(
        activeShift: const ShiftEntry(
          name: 'POS-OPN-001',
          posProfile: 'Dokki',
          status: 'Open',
        ),
        summary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Open',
          invoiceCount: 3,
          paymentReconciliation: [ShiftBalanceDetail(modeOfPayment: 'Cash')],
          amountsHidden: true,
          courierCloseBlock: carryBlock,
        ),
        endShiftSummary: const ShiftSummary(
          openingEntry: 'POS-OPN-001',
          status: 'Closed',
          closingEntry: 'POS-CLO-001',
          carriedCourierCount: 2,
          carriedCourierAmount: 160,
        ),
      );
    }

    testWidgets('lists every unsettled invoice and flags one already carried', (tester) async {
      final repository = buildRepository();

      await _pumpShiftEndScreen(tester, repository);

      expect(find.text('Money still with couriers'), findsOneWidget);
      expect(find.textContaining('ACC-SINV-0001'), findsOneWidget);
      expect(find.textContaining('ACC-SINV-0002'), findsOneWidget);
      // The second night out reads differently from the first.
      expect(find.textContaining('Carried 2 shift(s)'), findsOneWidget);
      expect(find.text('0 of 2 confirmed'), findsOneWidget);
    });

    testWidgets('refuses to close while one invoice is unconfirmed', (tester) async {
      final repository = buildRepository();
      await _pumpShiftEndScreen(tester, repository);

      // Confirm only the first of the two.
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('1 of 2 confirmed'), findsOneWidget);
      final endButton = tester.widget<ButtonStyleButton>(
        _buttonWithLabel('End Shift').first,
      );
      expect(endButton.onPressed, isNull);
      expect(repository.submittedCourierAcknowledgement, isNull);
    });

    testWidgets('closes once every invoice is confirmed and sends the acknowledgement', (tester) async {
      final repository = buildRepository();
      await _pumpShiftEndScreen(tester, repository);

      await tester.tap(find.text('Confirm all'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 2 confirmed'), findsOneWidget);

      // The carry checklist pushes the cash count below the fold, and a
      // ListView only mounts what it lays out.
      await tester.scrollUntilVisible(
        find.byType(TextField),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField).first, '1000');
      await tester.pumpAndSettle();

      await tester.tap(_buttonWithLabel('End Shift').first);
      await tester.pumpAndSettle();

      expect(
        repository.submittedCourierAcknowledgement,
        equals(['CT-0001', 'CT-0002']),
      );
      // The closer's last screen says what walked out the door.
      expect(find.textContaining('still with couriers'), findsOneWidget);
    });
  });
}
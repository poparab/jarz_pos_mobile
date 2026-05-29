import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
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

class _FakeShiftRepository extends ShiftRepository {
  _FakeShiftRepository({
    required this.activeShift,
    required this.summary,
    ShiftSummary? endShiftSummary,
  }) : endShiftSummary = endShiftSummary,
       super(Dio());

  final ShiftEntry? activeShift;
  final ShiftSummary summary;
  final ShiftSummary? endShiftSummary;
  List<Map<String, dynamic>>? submittedClosingBalances;
  String? submittedOpeningEntry;

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
  }) async {
    submittedOpeningEntry = openingEntry;
    submittedClosingBalances = closingBalances
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    return endShiftSummary ?? summary;
  }
}

Future<void> _pumpShiftEndScreen(
  WidgetTester tester,
  _FakeShiftRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shiftRepositoryProvider.overrideWithValue(repository),
        activeShiftProvider.overrideWith((ref) async => repository.activeShift),
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
}
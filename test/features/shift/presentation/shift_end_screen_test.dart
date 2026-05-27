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

class _FakeShiftRepository extends ShiftRepository {
  _FakeShiftRepository({
    required this.activeShift,
    required this.summary,
  }) : super(Dio());

  final ShiftEntry? activeShift;
  final ShiftSummary summary;

  @override
  Future<ShiftEntry?> getActiveShift({String? posProfile}) async {
    return activeShift;
  }

  @override
  Future<ShiftSummary> getShiftSummary(String openingEntry) async {
    return summary;
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
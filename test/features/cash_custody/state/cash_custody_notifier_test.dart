import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/cash_custody/data/cash_custody_repository.dart';
import 'package:jarz_pos/src/features/cash_custody/models/cash_custody_models.dart';
import 'package:jarz_pos/src/features/cash_custody/state/cash_custody_notifier.dart';

import '../fake_cash_custody_repository.dart';

void main() {
  late FakeCashCustodyRepository repo;
  late ProviderContainer container;

  ProviderContainer makeContainer({bool cashTransferTier = false}) {
    return ProviderContainer(overrides: [
      cashCustodyRepositoryProvider.overrideWithValue(repo),
      canAccessCashTransferProvider.overrideWithValue(cashTransferTier),
    ]);
  }

  setUp(() {
    repo = FakeCashCustodyRepository();
  });

  tearDown(() => container.dispose());

  group('custodyOverviewProvider / custodyMenuVisibleProvider', () {
    test('should show the menu to a holder who is not a manager', () async {
      repo.overview = CustodyOverview(
        canManage: false,
        canManageHolders: false,
        myHolder: fakeCustodyHolder(),
        holders: const [],
        sourceAccounts: const [],
        returnAccounts: const [],
      );
      container = makeContainer();

      await container.read(custodyOverviewProvider.future);

      expect(container.read(custodyMenuVisibleProvider), isTrue);
    });

    test('should hide the menu from a user who is neither', () async {
      container = makeContainer(cashTransferTier: true);

      await container.read(custodyOverviewProvider.future);

      expect(container.read(custodyMenuVisibleProvider), isFalse);
    });

    test('should fall back to the cash-transfer tier on error', () async {
      repo.overviewError = Exception('boom');
      container = makeContainer(cashTransferTier: true);

      await expectLater(
        container.read(custodyOverviewProvider.future),
        throwsException,
      );

      expect(container.read(custodyMenuVisibleProvider), isTrue);
    });
  });

  group('CustodyActionsNotifier', () {
    test('should issue and refetch the overview', () async {
      container = makeContainer();
      await container.read(custodyOverviewProvider.future);
      expect(repo.overviewCalls, 1);

      final result = await container.read(custodyActionsProvider.notifier).issue(
            holder: 'CUST-1',
            fromAccount: 'Cash - J',
            amount: 50,
            postingDate: '2026-09-23 10:30:00',
            remark: 'float',
          );
      await container.read(custodyOverviewProvider.future);

      expect(result.journalEntry, 'ACC-JV-1');
      expect(result.holder?.balance, 150);
      expect(repo.calls,
          contains('issue:CUST-1:Cash - J:50.0:2026-09-23 10:30:00:float'));
      expect(repo.overviewCalls, 2);
      expect(container.read(custodyActionsProvider).isSubmitting, isFalse);
    });

    test('should return cash to the chosen account', () async {
      container = makeContainer();

      final result = await container
          .read(custodyActionsProvider.notifier)
          .returnCash(holder: 'CUST-1', toAccount: 'Drawer - J', amount: 100);

      expect(result.holder?.balance, 0);
      expect(repo.calls, contains('return:CUST-1:Drawer - J:100.0'));
    });

    test('should add a holder and toggle one', () async {
      container = makeContainer();
      final notifier = container.read(custodyActionsProvider.notifier);

      final added = await notifier.addHolder('HR-EMP-2');
      await notifier.setHolderEnabled('CUST-2', false);

      expect(added.name, 'CUST-2');
      expect(repo.calls, containsAll(['add:HR-EMP-2', 'enabled:CUST-2:false']));
    });

    test('should rethrow a refusal and clear the submitting flag', () async {
      repo.movementError = Exception('Custody balance is insufficient');
      container = makeContainer();

      await expectLater(
        container
            .read(custodyActionsProvider.notifier)
            .returnCash(holder: 'CUST-1', toAccount: 'Drawer - J', amount: 500),
        throwsException,
      );

      expect(container.read(custodyActionsProvider).isSubmitting, isFalse);
    });
  });

  group('CustodyStatementNotifier', () {
    test('should load on creation and reload with a date range', () async {
      container = makeContainer();
      final sub = container.listen(
        custodyStatementProvider('CUST-1'),
        (_, _) {},
      );
      await Future<void>.delayed(Duration.zero);

      expect(sub.read().statement?.closingBalance, 100);
      expect(repo.calls, contains('statement:CUST-1:null:null'));

      await container
          .read(custodyStatementProvider('CUST-1').notifier)
          .setRange(DateTime(2026, 9, 1), DateTime(2026, 9, 23));

      expect(repo.calls, contains('statement:CUST-1:2026-09-01:2026-09-23'));
      expect(sub.read().hasRange, isTrue);

      await container
          .read(custodyStatementProvider('CUST-1').notifier)
          .clearRange();
      expect(sub.read().hasRange, isFalse);
      sub.close();
    });
  });
}

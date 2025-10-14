import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/pos_repository.dart';

class PosAccountBalance {
  final String account;
  final String currency;
  final double balance;

  const PosAccountBalance({
    required this.account,
    required this.currency,
    required this.balance,
  });
}

final posAccountBalanceProvider = FutureProvider.autoDispose.family<PosAccountBalance, String>((ref, profile) async {
  final repository = ref.watch(posRepositoryProvider);
  final data = await repository.getPosProfileAccountBalance(profile);
  final account = (data['account'] ?? '').toString();
  final currency = (data['currency'] ?? '').toString();
  double balance;
  final rawBalance = data['balance'];
  if (rawBalance is num) {
    balance = rawBalance.toDouble();
  } else {
    balance = double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;
  }
  return PosAccountBalance(account: account, currency: currency, balance: balance);
});

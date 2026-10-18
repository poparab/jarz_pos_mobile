import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/b2b_repository.dart';
import '../data/models/b2b_active_accounts.dart';

/// Loads the "My customers" landing data (Active-stage accounts + numbers).
/// autoDispose, like [b2bTodayProvider]: every visit re-fetches.
final b2bActiveAccountsProvider =
    FutureProvider.autoDispose<B2bActiveAccounts>((ref) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getActiveAccounts();
});

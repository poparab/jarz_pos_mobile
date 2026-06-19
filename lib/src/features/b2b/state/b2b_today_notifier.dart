import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/b2b_repository.dart';
import '../data/models/b2b_models.dart';

/// Loads the B2B rep's follow-ups (todos + reorder-due) for the Today screen.
final b2bTodayProvider = FutureProvider.autoDispose<B2bFollowups>((ref) async {
  final repo = ref.watch(b2bRepositoryProvider);
  return repo.getMyFollowups();
});

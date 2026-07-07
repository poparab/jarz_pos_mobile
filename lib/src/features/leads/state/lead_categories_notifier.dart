import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leads_repository.dart';
import '../data/models/lead.dart';

/// Loads the lead categories used for filter chips and the add-lead dropdown.
final leadCategoriesProvider =
    AsyncNotifierProvider<LeadCategoriesNotifier, List<LeadCategory>>(
      LeadCategoriesNotifier.new,
    );

class LeadCategoriesNotifier extends AsyncNotifier<List<LeadCategory>> {
  LeadsRepository get _repo => ref.read(leadsRepositoryProvider);

  @override
  Future<List<LeadCategory>> build() async {
    return _repo.getLeadCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getLeadCategories);
  }

  /// Creates a new category and appends it to the current list.
  Future<LeadCategory> add({
    required String categoryName,
    String? color,
  }) async {
    final created = await _repo.saveLeadCategory(
      categoryName: categoryName,
      color: color,
    );
    final current = state.valueOrNull ?? const <LeadCategory>[];
    state = AsyncValue.data([...current, created]);
    return created;
  }
}

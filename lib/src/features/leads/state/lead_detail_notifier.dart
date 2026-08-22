import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leads_repository.dart';
import '../data/models/lead.dart';
import 'leads_notifier.dart';

/// Loads the full detail for a single lead, keyed by its `name`.
final leadDetailProvider =
    AsyncNotifierProvider.family<LeadDetailNotifier, Lead, String>(
      LeadDetailNotifier.new,
    );

class LeadDetailNotifier extends FamilyAsyncNotifier<Lead, String> {
  LeadsRepository get _repo => ref.read(leadsRepositoryProvider);

  @override
  Future<Lead> build(String leadName) async {
    return _repo.getLead(leadName);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getLead(arg));
  }

  /// Persists edited status/notes/category (and any other lead fields) and
  /// refreshes both this detail and the cached catalog.
  Future<void> save(Map<String, dynamic> payload) async {
    await _repo.saveLead(payload, name: arg);
    await refresh();
    // Keep the list catalog in sync with edited fields.
    unawaitedRefreshCatalog();
  }

  /// Records (or clears) the manual-inspection "not suitable" verdict, then
  /// refreshes this detail and the cached catalog so the list drops/re-shows
  /// the lead immediately.
  Future<void> setSuitability({
    required bool notSuitable,
    String? reason,
    String? notes,
  }) async {
    await _repo.setLeadSuitability(
      name: arg,
      notSuitable: notSuitable,
      reason: reason,
      notes: notes,
    );
    await refresh();
    unawaitedRefreshCatalog();
  }

  /// Replaces the people recorded against this lead, then refreshes the detail
  /// and the cached catalog (cards show who to ask for, so they go stale too).
  Future<void> saveContacts(List<LeadContact> contacts) async {
    await _repo.saveLeadContacts(name: arg, contacts: contacts);
    await refresh();
    unawaitedRefreshCatalog();
  }

  /// Saves a primary or shipping address, then refreshes the detail.
  Future<void> saveAddress({
    required String kind,
    required LeadAddress address,
  }) async {
    await _repo.setLeadAddress(name: arg, kind: kind, address: address);
    await refresh();
  }

  void unawaitedRefreshCatalog() {
    // Fire-and-forget catalog refresh so the list reflects edits on return.
    ref.read(leadsProvider.notifier).refresh();
  }
}

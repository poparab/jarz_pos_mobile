import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/storage_keys.dart';
import '../data/leads_repository.dart';
import '../data/models/lead.dart';

/// Loads the full lightweight lead catalog once and caches it to a Hive box so
/// reopening the feature is instant (and works offline). Network is the source
/// of truth; the cache is a fallback while the network request is in flight or
/// when it fails.
final leadsProvider =
    AsyncNotifierProvider<LeadsNotifier, List<Lead>>(LeadsNotifier.new);

class LeadsNotifier extends AsyncNotifier<List<Lead>> {
  static const _cacheKey = 'catalog';

  LeadsRepository get _repo => ref.read(leadsRepositoryProvider);

  @override
  Future<List<Lead>> build() async {
    // Serve the cached catalog immediately if present, then refresh from the
    // network. If the network fails but we have a cache, keep the cache.
    final cached = await _readCache();
    try {
      final fresh = await _repo.getLeads();
      await _writeCache(fresh);
      return fresh;
    } catch (error) {
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// Force-refreshes from the network, updating the cache on success.
  ///
  /// Keeps the current catalog on screen while the request is in flight rather
  /// than emitting a bare [AsyncValue.loading]: a bare loading state replaces
  /// the whole list with a spinner, losing scroll position and making a
  /// routine revalidation look like a reload. `copyWithPrevious` keeps the old
  /// rows visible and merely marks them stale, which is what lets this be
  /// called automatically instead of only from a button.
  Future<void> refresh() async {
    final previous = state;
    state = const AsyncValue<List<Lead>>.loading().copyWithPrevious(previous);
    final next = await AsyncValue.guard(() async {
      final fresh = await _repo.getLeads();
      await _writeCache(fresh);
      return fresh;
    });
    // A failed background revalidation must not blank a catalog the rep is
    // reading — keep the last good data and let the next attempt fix it. With
    // no previous data there is nothing to preserve, so the error surfaces.
    if (next.hasError && previous.hasValue) {
      state = previous;
      return;
    }
    state = next;
  }

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(HiveBoxes.leadsCache)) {
      return Hive.box(HiveBoxes.leadsCache);
    }
    return Hive.openBox(HiveBoxes.leadsCache);
  }

  Future<List<Lead>?> _readCache() async {
    try {
      final box = await _openBox();
      final raw = box.get(_cacheKey);
      if (raw is! String || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => Lead.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<Lead> leads) async {
    try {
      final box = await _openBox();
      final encoded = jsonEncode(leads.map((e) => e.toJson()).toList());
      await box.put(_cacheKey, encoded);
    } catch (_) {
      // A cache write failure must never break the live data flow.
    }
  }
}

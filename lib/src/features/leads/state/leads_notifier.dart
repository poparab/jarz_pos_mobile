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
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final fresh = await _repo.getLeads();
      await _writeCache(fresh);
      return fresh;
    });
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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/storage_keys.dart';
import '../models/draft_cart.dart';

/// Maximum number of concurrent draft carts allowed.
const kDraftCartLimit = 10;

/// Thrown when the user tries to create an 11th draft.
class DraftLimitReachedException implements Exception {
  const DraftLimitReachedException();
  @override
  String toString() => 'Draft limit reached ($kDraftCartLimit max)';
}

/// Hive-backed persistence for local draft carts.
/// Drafts are stored as plain Maps (JSON-safe), keyed by their UUID.
class DraftCartRepository {
  late Box _box;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _box = await Hive.openBox(HiveBoxes.draftCarts);
    _initialized = true;
  }

  /// Load all drafts sorted by [DraftCart.updatedAt] descending (newest first).
  Future<List<DraftCart>> loadAll() async {
    await _init();
    final drafts = <DraftCart>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        drafts.add(DraftCart.fromMap(raw as Map));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ DraftCartRepository: skipping unreadable draft $key: $e');
        }
      }
    }
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  /// Persist (insert or update) a draft.
  /// Throws [DraftLimitReachedException] if inserting a new id would exceed the limit.
  Future<void> upsert(DraftCart draft) async {
    await _init();
    final isNew = !_box.containsKey(draft.id);
    if (isNew && _box.length >= kDraftCartLimit) {
      throw const DraftLimitReachedException();
    }
    await _box.put(draft.id, draft.toMap());
    if (kDebugMode) {
      debugPrint('💾 DraftCartRepository: saved draft ${draft.id} "${draft.label}"');
    }
  }

  /// Delete a single draft by id. No-op if not found.
  Future<void> delete(String id) async {
    await _init();
    await _box.delete(id);
    if (kDebugMode) {
      debugPrint('🗑️ DraftCartRepository: deleted draft $id');
    }
  }

  /// Delete all drafts.
  Future<void> clearAll() async {
    await _init();
    await _box.clear();
  }
}

final draftCartRepositoryProvider = Provider<DraftCartRepository>((_) {
  return DraftCartRepository();
});

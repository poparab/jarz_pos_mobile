import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineQueue {
  static const _boxName = 'offline_queue';
  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await init();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'timestamp': DateTime.now().toIso8601String(),
      'data': transaction,
      'status': 'pending',
      'endpoint': transaction['endpoint'] ?? '',
      'method': transaction['method'] ?? 'POST',
    });
    if (kDebugMode) {
      debugPrint('🔄 OFFLINE: Added transaction to queue: $id');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    await init();
    final transactions = <Map<String, dynamic>>[];
    for (var key in _box.keys) {
      final transaction = _box.get(key);
      if (transaction != null && transaction['status'] == 'pending') {
        transactions.add(Map<String, dynamic>.from(transaction));
      }
    }
    return transactions;
  }

  Future<void> markAsProcessed(String id) async {
    await init();
    final transaction = _box.get(id);
    if (transaction != null) {
      transaction['status'] = 'processed';
      transaction['processed_at'] = DateTime.now().toIso8601String();
      await _box.put(id, transaction);
      if (kDebugMode) {
        debugPrint('✅ OFFLINE: Marked transaction as processed: $id');
      }
    }
  }

  Future<void> markAsError(String id, String error) async {
    await init();
    final transaction = _box.get(id);
    if (transaction != null) {
      transaction['status'] = 'error';
      transaction['error'] = error;
      transaction['error_at'] = DateTime.now().toIso8601String();
      await _box.put(id, transaction);
      if (kDebugMode) {
        debugPrint('❌ OFFLINE: Marked transaction as error: $id - $error');
      }
    }
  }

  Future<void> clearProcessed() async {
    await init();
    final keysToRemove = <dynamic>[];
    for (var key in _box.keys) {
      final transaction = _box.get(key);
      if (transaction != null && transaction['status'] == 'processed') {
        keysToRemove.add(key);
      }
    }
    await _box.deleteAll(keysToRemove);
    if (kDebugMode) {
      debugPrint('🧹 OFFLINE: Cleared ${keysToRemove.length} processed transactions');
    }
  }

  Future<int> getPendingCount() async {
    await init();
    int count = 0;
    for (var key in _box.keys) {
      final transaction = _box.get(key);
      if (transaction != null && transaction['status'] == 'pending') {
        count++;
      }
    }
    return count;
  }

  Future<void> clearAll() async {
    await init();
    await _box.clear();
    if (kDebugMode) {
      debugPrint('🗑️ OFFLINE: Cleared all transactions');
    }
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  return OfflineQueue();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';
import '../debug/app_error_reporter.dart';

class OfflineQueue {
  static const _boxName = HiveBoxes.offlineQueue;
  Box<dynamic>? _box;
  final Map<String, Map<String, dynamic>> _memoryTransactions =
      <String, Map<String, dynamic>>{};
  bool _initialized = false;
  bool _storageUnavailable = false;

  @visibleForTesting
  OfflineQueue.memoryOnly() {
    _storageUnavailable = true;
  }

  OfflineQueue();

  Future<void> init() async {
    if (_initialized || _storageUnavailable) return;

    try {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box(_boxName);
      } else {
        await Hive.initFlutter();
        _box = await Hive.openBox(_boxName);
      }
      _initialized = true;
    } catch (error, stackTrace) {
      _storageUnavailable = true;
      AppErrorReporter.instance.capture(
        source: 'OfflineQueue.init',
        error: error,
        stackTrace: stackTrace,
        summary: 'Offline queue storage unavailable; using in-memory queue for this session',
        details: const <String, Object?>{'box': _boxName},
      );
      if (kDebugMode) {
        debugPrint('OFFLINE: Falling back to in-memory queue: $error');
      }
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await init();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _putTransaction(id, {
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
    for (final key in _keys) {
      final transaction = _getTransaction(key);
      if (transaction != null && transaction['status'] == 'pending') {
        transactions.add(transaction);
      }
    }
    return transactions;
  }

  Future<void> markAsProcessed(String id) async {
    await init();
    final transaction = _getTransaction(id);
    if (transaction != null) {
      transaction['status'] = 'processed';
      transaction['processed_at'] = DateTime.now().toIso8601String();
      await _putTransaction(id, transaction);
      if (kDebugMode) {
        debugPrint('✅ OFFLINE: Marked transaction as processed: $id');
      }
    }
  }

  Future<void> markAsError(String id, String error) async {
    await init();
    final transaction = _getTransaction(id);
    if (transaction != null) {
      transaction['status'] = 'error';
      transaction['error'] = error;
      transaction['error_at'] = DateTime.now().toIso8601String();
      await _putTransaction(id, transaction);
      if (kDebugMode) {
        debugPrint('❌ OFFLINE: Marked transaction as error: $id - $error');
      }
    }
  }

  /// Maximum replay attempts before a queued action is considered dead.
  static const int maxReplayAttempts = 3;

  /// Record a failed replay attempt.
  ///
  /// Returns `true` once the action has exhausted [maxReplayAttempts] and has
  /// been parked as `error`. A single failed replay used to park the action
  /// immediately, so an order dispatched offline could be dropped for good
  /// because of one flaky request on reconnect — with nothing shown to the
  /// staff member who was told it had gone through.
  Future<bool> markAttemptFailed(String id, String error) async {
    await init();
    final transaction = _getTransaction(id);
    if (transaction == null) return true;

    final attempts = ((transaction['attempts'] as num?)?.toInt() ?? 0) + 1;
    transaction['attempts'] = attempts;
    transaction['error'] = error;
    transaction['error_at'] = DateTime.now().toIso8601String();

    final exhausted = attempts >= maxReplayAttempts;
    transaction['status'] = exhausted ? 'error' : 'pending';
    await _putTransaction(id, transaction);

    if (kDebugMode) {
      debugPrint(
        '⚠️ OFFLINE: attempt $attempts/$maxReplayAttempts failed for $id'
        '${exhausted ? ' — parked' : ' — will retry'}: $error',
      );
    }
    return exhausted;
  }

  /// Actions that exhausted their retries and need a human to look at them.
  Future<List<Map<String, dynamic>>> getFailedTransactions() async {
    await init();
    final failed = <Map<String, dynamic>>[];
    for (final key in _keys) {
      final transaction = _getTransaction(key);
      if (transaction != null && transaction['status'] == 'error') {
        failed.add(transaction);
      }
    }
    return failed;
  }

  Future<void> clearProcessed() async {
    await init();
    final keysToRemove = <dynamic>[];
    for (final key in _keys) {
      final transaction = _getTransaction(key);
      if (transaction != null && transaction['status'] == 'processed') {
        keysToRemove.add(key);
      }
    }
    await _deleteTransactions(keysToRemove);
    if (kDebugMode) {
      debugPrint('🧹 OFFLINE: Cleared ${keysToRemove.length} processed transactions');
    }
  }

  Future<int> getPendingCount() async {
    await init();
    int count = 0;
    for (final key in _keys) {
      final transaction = _getTransaction(key);
      if (transaction != null && transaction['status'] == 'pending') {
        count++;
      }
    }
    return count;
  }

  Future<void> clearAll() async {
    await init();
    await _clearTransactions();
    if (kDebugMode) {
      debugPrint('🗑️ OFFLINE: Cleared all transactions');
    }
  }

  Iterable<dynamic> get _keys => _storageUnavailable
      ? _memoryTransactions.keys
      : (_box?.keys ?? const <dynamic>[]);

  Map<String, dynamic>? _getTransaction(dynamic key) {
    final transaction = _storageUnavailable
        ? _memoryTransactions[key]
        : _box?.get(key);
    if (transaction is Map) {
      return Map<String, dynamic>.from(transaction);
    }
    return null;
  }

  Future<void> _putTransaction(String id, Map<String, dynamic> transaction) async {
    if (_storageUnavailable) {
      _memoryTransactions[id] = Map<String, dynamic>.from(transaction);
      return;
    }
    await _box!.put(id, transaction);
  }

  Future<void> _deleteTransactions(Iterable<dynamic> keys) async {
    if (_storageUnavailable) {
      for (final key in keys) {
        _memoryTransactions.remove(key);
      }
      return;
    }
    await _box!.deleteAll(keys);
  }

  Future<void> _clearTransactions() async {
    if (_storageUnavailable) {
      _memoryTransactions.clear();
      return;
    }
    await _box!.clear();
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  return OfflineQueue();
});

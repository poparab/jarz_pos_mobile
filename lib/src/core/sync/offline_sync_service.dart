import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../offline/offline_queue.dart';
import '../network/dio_provider.dart';
import 'package:flutter/foundation.dart';

class OfflineSyncService {
  final OfflineQueue _offlineQueue;
  final Dio _dio;
  Timer? _syncTimer;
  bool _isSyncing = false;

  OfflineSyncService(this._offlineQueue, this._dio);

  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      syncPendingTransactions();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  Future<void> syncPendingTransactions() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingTransactions = await _offlineQueue.getPendingTransactions();
      
      if (pendingTransactions.isEmpty) {
        _isSyncing = false;
        return;
      }

      if (kDebugMode) {
        debugPrint('🔄 SYNC: Processing ${pendingTransactions.length} pending transactions');
      }

      for (final transaction in pendingTransactions) {
        await _processSingleTransaction(transaction);
      }

      // Clean up processed transactions
      await _offlineQueue.clearProcessed();
      
      if (kDebugMode) {
        debugPrint('✅ SYNC: Completed processing pending transactions');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SYNC: Error during sync: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSingleTransaction(Map<String, dynamic> transaction) async {
    final id = transaction['id'] as String;
    final endpoint = transaction['endpoint'] as String?;
    final method = transaction['method'] as String?;
    final data = transaction['data'];

    if (endpoint == null || method == null) {
      await _offlineQueue.markAsError(id, 'Missing endpoint or method');
      return;
    }

    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(endpoint, data: data);
          break;
        case 'PUT':
          response = await _dio.put(endpoint, data: data);
          break;
        case 'PATCH':
          response = await _dio.patch(endpoint, data: data);
          break;
        default:
          await _offlineQueue.markAsError(id, 'Unsupported method: $method');
          return;
      }

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        await _offlineQueue.markAsProcessed(id);
        if (kDebugMode) {
          debugPrint('✅ SYNC: Successfully processed transaction $id');
        }
      } else {
        await _offlineQueue.markAsError(id, 'HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        // If it's a client error (4xx), don't retry
        if (e.response?.statusCode != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
          await _offlineQueue.markAsError(id, 'Client error: ${e.response?.statusCode} - ${e.message}');
        } else {
          // Server error or network error - leave in queue for retry
          if (kDebugMode) {
            debugPrint('⏳ SYNC: Retrying transaction $id later due to: ${e.message}');
          }
        }
      } else {
        await _offlineQueue.markAsError(id, 'Unknown error: $e');
      }
    }
  }

  Future<int> getPendingCount() async {
    return await _offlineQueue.getPendingCount();
  }

  Future<void> forceSyncNow() async {
    await syncPendingTransactions();
  }

  void dispose() {
    stopPeriodicSync();
  }
}

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final offlineQueue = ref.watch(offlineQueueProvider);
  final dio = ref.watch(dioProvider);
  final service = OfflineSyncService(offlineQueue, dio);
  
  // Start periodic sync
  service.startPeriodicSync();
  
  ref.onDispose(() => service.dispose());
  return service;
});

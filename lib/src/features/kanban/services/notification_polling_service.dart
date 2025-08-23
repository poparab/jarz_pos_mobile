import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';

class NotificationPollingService {
  final Dio _dio;
  Timer? _pollingTimer;
  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  String? _lastCheckTime;
  bool _isPolling = false;
  
  NotificationPollingService(this._dio);
  
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  
  /// Start polling for notifications every [intervalSeconds] seconds
  void startPolling({int intervalSeconds = 30}) {
    if (_isPolling) return;
    
    _isPolling = true;
    if (kDebugMode) {
      print('📊 POLLING: Starting notification polling every ${intervalSeconds}s');
    }
    
    // Initial check
    _checkForUpdates();
    
    // Set up periodic timer
    _pollingTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _checkForUpdates(),
    );
  }
  
  /// Stop the polling timer
  void stopPolling() {
    if (!_isPolling) return;
    
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (kDebugMode) {
      print('📊 POLLING: Stopped notification polling');
    }
  }
  
  /// Check for updates since last check
  Future<void> _checkForUpdates() async {
    if (!_isPolling) return;
    
    try {
      final Map<String, dynamic> data = {};
      if (_lastCheckTime != null) {
        data['last_check'] = _lastCheckTime;
      }
      
      final response = await _dio.post(
        '/api/method/jarz_pos.api.notifications.check_for_updates',
        data: data,
      );
      
      if (response.statusCode == 200) {
        final result = response.data;
        
        if (result is Map && result['message'] is Map) {
          final messageData = result['message'] as Map<String, dynamic>;
          
          if (messageData['success'] == true && messageData['has_updates'] == true) {
            if (kDebugMode) {
              print('📊 POLLING: Found ${messageData['total_updates']} updates');
            }
            
            // Emit notification about updates
            _notificationController.add({
              'type': 'updates_available',
              'new_count': messageData['new_count'],
              'modified_count': messageData['modified_count'],
              'total_updates': messageData['total_updates'],
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // Fetch detailed updates
            await _fetchRecentInvoices();
          } else {
            if (kDebugMode) {
              print('📊 POLLING: No updates found');
            }
          }
          
          // Update last check time
          _lastCheckTime = messageData['current_time'] ?? DateTime.now().toIso8601String();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ POLLING: Error checking for updates: $e');
      }
      // Don't stop polling on errors, just log and continue
    }
  }
  
  /// Fetch recent invoices and emit detailed notifications
  Future<void> _fetchRecentInvoices({int minutes = 5}) async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.notifications.get_recent_invoices',
        data: {'minutes': minutes},
      );
      
      if (response.statusCode == 200) {
        final result = response.data;
        
        if (result is Map && result['message'] is Map) {
          final messageData = result['message'] as Map<String, dynamic>;
          
          if (messageData['success'] == true) {
            final newInvoices = messageData['new_invoices'] as List<dynamic>? ?? [];
            final modifiedInvoices = messageData['modified_invoices'] as List<dynamic>? ?? [];
            
            // Emit new invoice notifications
            for (final invoice in newInvoices) {
              _notificationController.add({
                'type': 'new_invoice',
                'data': invoice,
                'timestamp': DateTime.now().toIso8601String(),
              });
              if (kDebugMode) {
                print('📊 POLLING: New invoice notification: ${invoice['name']}');
              }
            }
            
            // Emit modified invoice notifications  
            for (final invoice in modifiedInvoices) {
              _notificationController.add({
                'type': 'invoice_updated',
                'data': invoice,
                'timestamp': DateTime.now().toIso8601String(),
              });
              if (kDebugMode) {
                print('📊 POLLING: Modified invoice notification: ${invoice['name']}');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ POLLING: Error fetching recent invoices: $e');
      }
    }
  }
  
  /// Manually trigger a check (for pull-to-refresh, etc.)
  Future<Map<String, dynamic>?> manualCheck() async {
    if (kDebugMode) {
      print('📊 POLLING: Manual check triggered');
    }
    
    try {
      await _fetchRecentInvoices(minutes: 10); // Check last 10 minutes
      return {
        'success': true,
        'message': 'Manual check completed',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Test the notification endpoints
  Future<Map<String, dynamic>> testNotifications() async {
    try {
      // Test the websocket emission endpoint
      final response = await _dio.post(
        '/api/method/jarz_pos.api.notifications.test_websocket_emission',
      );
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('📊 POLLING: Test websocket emission successful');
        }
        return response.data['message'] as Map<String, dynamic>? ?? {'success': true};
      }
      
      return {'success': false, 'error': 'Invalid response'};
    } catch (e) {
      if (kDebugMode) {
        print('❌ POLLING: Test notifications error: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }
  
  /// Get debug info about websocket configuration
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final response = await _dio.post(
        '/api/method/jarz_pos.api.notifications.get_websocket_debug_info',
      );
      
      if (response.statusCode == 200) {
        return response.data['message'] as Map<String, dynamic>? ?? {'success': true};
      }
      
      return {'success': false, 'error': 'Invalid response'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  void dispose() {
    stopPolling();
    _notificationController.close();
  }
}

final notificationPollingServiceProvider = Provider<NotificationPollingService>((ref) {
  final dio = ref.watch(dioProvider);
  final service = NotificationPollingService(dio);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

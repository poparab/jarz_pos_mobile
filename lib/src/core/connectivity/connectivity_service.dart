import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

class ConnectivityService {
  final _connectivityController = StreamController<bool>.broadcast();
  Timer? _connectivityTimer;
  bool _lastKnownStatus = true;

  Stream<bool> get connectivityStream => _connectivityController.stream;

  void startMonitoring() {
    // Check connectivity every 10 seconds
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectivity();
    });
    
    // Initial check
    _checkConnectivity();
  }

  void stopMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (isConnected != _lastKnownStatus) {
        _lastKnownStatus = isConnected;
        _connectivityController.add(isConnected);
        if (kDebugMode) {
          debugPrint(isConnected ? '🌐 CONNECTIVITY: Online' : '🔌 CONNECTIVITY: Offline');
        }
      }
    } catch (e) {
      if (_lastKnownStatus != false) {
        _lastKnownStatus = false;
        _connectivityController.add(false);
        if (kDebugMode) {
          debugPrint('🔌 CONNECTIVITY: Offline (${e.toString()})');
        }
      }
    }
  }

  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool get isOnline => _lastKnownStatus;

  void dispose() {
    stopMonitoring();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.startMonitoring();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

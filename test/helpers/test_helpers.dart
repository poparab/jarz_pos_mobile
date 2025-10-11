import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ensure platform channels used by plugins are available in headless tests.
void setupMockPlatformChannels() {
  // Ensure test bindings are initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Mock path_provider channel
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  messenger.setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
    if (call.method == 'getTemporaryDirectory') {
      return Directory.systemTemp.path;
    }
    return null;
  });

  // Basic flutter_secure_storage mock to avoid channel errors
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  messenger.setMockMethodCallHandler(secureStorageChannel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'read':
      case 'write':
      case 'delete':
      case 'deleteAll':
      case 'readAll':
      case 'containsKey':
        return null;
      default:
        return null;
    }
  });
}

/// Flush microtasks to ensure async operations complete in tests.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

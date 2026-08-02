import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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

/// Temp directory backing Hive for the current test file, if [setUpTestHive]
/// has run. One per test process, so concurrently-running test files (and CI
/// shards) never share box files.
Directory? _testHiveDir;

/// Initialise Hive against a fresh, uniquely-named temp directory.
///
/// The app bootstraps Hive with `Hive.initFlutter()` in `main()`, which
/// `flutter test` never runs. Any production code path that opens a box —
/// e.g. `LoginNotifier` clearing per-user caches through
/// `DraftCartRepository` — then throws
/// `HiveError: You need to initialize Hive or provide a path to store the box.`
/// Worse, Hive completes its internal `_openingBoxes` completer with that
/// error and nobody listens to it, so it escapes as an *unhandled* async
/// error and fails the test even though the caller catches the rethrow.
///
/// Call this from `setUpAll` and pair it with [tearDownTestHive] in
/// `tearDownAll`. [prefix] only affects the temp directory name and is handy
/// when debugging leftover directories.
Future<void> setUpTestHive({String prefix = 'jarz-pos-test'}) async {
  setupMockPlatformChannels();
  final dir = await Directory.systemTemp.createTemp('$prefix-hive-');
  _testHiveDir = dir;
  Hive.init(dir.path);
}

/// Close every box opened during the test file and delete the temp directory
/// created by [setUpTestHive], so each run starts from an empty store.
Future<void> tearDownTestHive() async {
  // Some production paths clear user-scoped caches fire-and-forget
  // (`unawaited(...)`); give any in-flight box operation a turn to finish
  // before the boxes are closed out from under it.
  await flushMicrotasks();
  await Hive.close();
  final dir = _testHiveDir;
  _testHiveDir = null;
  if (dir != null && await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

/// Empty the named Hive boxes that are currently open (leaving them open), so
/// state cannot leak from one test to the next. Boxes that were never opened
/// are skipped, so this is safe to call from an unconditional `tearDown`.
Future<void> clearOpenTestHiveBoxes(Iterable<String> boxNames) async {
  for (final name in boxNames) {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).clear();
    }
  }
}

/// Flush microtasks to ensure async operations complete in tests.
Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

/// Yield to the event loop until [condition] holds or [timeout] elapses.
///
/// For fire-and-forget production work (`unawaited(...)`) there is no future to
/// await, and a single microtask flush is not enough to cover real disk IO.
/// This never asserts — always follow it with the real `expect`, so a condition
/// that never becomes true still fails loudly.
Future<void> pumpUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
  Duration step = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(step);
  }
}

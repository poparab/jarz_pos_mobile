import 'dart:io';

/// Mobile implementation: DNS lookup via dart:io.
Future<bool> checkConnectivityPlatform() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

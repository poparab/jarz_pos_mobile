/// Web implementation: always reports online.
/// The browser itself handles offline detection via failed fetch requests.
Future<bool> checkConnectivityPlatform() async {
  return true;
}

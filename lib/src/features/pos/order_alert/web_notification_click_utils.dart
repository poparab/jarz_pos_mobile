String? extractNotificationIdFromUrl(String? url) {
  final candidate = (url ?? '').trim();
  if (candidate.isEmpty) {
    return null;
  }

  final parsed = Uri.tryParse(candidate);
  if (parsed == null) {
    return null;
  }

  final notificationId = parsed.queryParameters['notification']?.trim() ?? '';
  return notificationId.isEmpty ? null : notificationId;
}
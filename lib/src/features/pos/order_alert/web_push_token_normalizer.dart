String? normalizeWebPushTokenCandidate(Object? candidate) {
  if (candidate == null) {
    return null;
  }

  final normalized = candidate.toString().trim();
  if (normalized.isEmpty) {
    return null;
  }

  final lower = normalized.toLowerCase();
  if (lower == 'null' || lower == 'undefined') {
    return null;
  }

  return normalized;
}
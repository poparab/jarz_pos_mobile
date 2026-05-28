String normalizeWebAppBasePath(String? path) {
  final trimmed = (path ?? '').trim();
  if (trimmed.isEmpty || trimmed == '/') {
    return '/';
  }

  final segments = trimmed
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
  if (segments.isEmpty) {
    return '/';
  }

  return '/${segments.join('/')}/';
}

String buildWebAppAssetUrl(String basePath, String relativePath) {
  final normalizedBasePath = normalizeWebAppBasePath(basePath);
  final normalizedRelativePath = relativePath.startsWith('/')
      ? relativePath.substring(1)
      : relativePath;

  return normalizedBasePath == '/'
      ? '/$normalizedRelativePath'
      : '$normalizedBasePath$normalizedRelativePath';
}
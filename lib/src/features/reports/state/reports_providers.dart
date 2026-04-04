import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reports_repository.dart';

final finalProductsReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchFinalProductsReport();
});

final materialsReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(reportsRepositoryProvider);
  return repo.fetchMaterialsReport();
});

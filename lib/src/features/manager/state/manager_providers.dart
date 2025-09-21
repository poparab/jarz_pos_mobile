import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/manager_api.dart';

final selectedBranchProvider = StateProvider<String?>((ref) => 'all');
final selectedStateProvider = StateProvider<String?>((ref) => 'all');

final dashboardSummaryProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(managerApiProvider);
  final summary = await api.getSummary();
  // keep current selected branch if still exists, else fallback
  final selected = ref.read(selectedBranchProvider);
  if (selected != null && selected != 'all') {
    final exists = summary.branches.any((b) => b.name == selected);
    if (!exists) ref.read(selectedBranchProvider.notifier).state = 'all';
  }
  return summary;
});

final managerOrdersProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(managerApiProvider);
  final branch = ref.watch(selectedBranchProvider);
  final state = ref.watch(selectedStateProvider);
  final normalized = (state == null || state == 'all') ? null : state;
  return api.getOrders(branch: branch, state: normalized);
});

final managerStatesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final api = ref.read(managerApiProvider);
  return api.getStates();
});

// Lightweight access check for Manager Dashboard visibility
final managerAccessProvider = FutureProvider<bool>((ref) async {
  final api = ref.read(managerApiProvider);
  try {
    await api.getSummary();
    return true;
  } on DioException catch (e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) return false;
    rethrow;
  } catch (_) {
    // On other errors (e.g., offline), don't break UI; hide manager menu by default
    return false;
  }
});

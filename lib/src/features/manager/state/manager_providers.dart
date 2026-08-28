import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/user_service.dart';
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

final pendingCustomShippingProvider = FutureProvider.autoDispose<List<CustomShippingRequest>>((ref) async {
  final api = ref.read(managerApiProvider);
  return api.getPendingCustomShippingRequests();
});

/// How far back the Employee Ledger looks.
///
/// The backend defaults to a 90-day window ending today when no dates are
/// sent, so [EmployeeLedgerWindow.days90] is the default here too and the two
/// agree on first paint. Outstanding money older than the window is invisible,
/// which is why the longer presets exist.
enum EmployeeLedgerWindow {
  days30(30),
  days90(90),
  days180(180),
  days365(365);

  const EmployeeLedgerWindow(this.days);
  final int days;
}

final employeeLedgerWindowProvider =
    StateProvider<EmployeeLedgerWindow>((ref) => EmployeeLedgerWindow.days90);

/// Per-employee outstanding: HRMS cash advances plus unpaid Employee-purpose
/// POS orders. Watches the shared branch chips so the whole dashboard filters
/// together, and the window dropdown so the range control refetches.
final employeeLedgerProvider =
    FutureProvider.autoDispose<EmployeeLedger>((ref) async {
  final api = ref.read(managerApiProvider);
  final branch = ref.watch(selectedBranchProvider);
  final window = ref.watch(employeeLedgerWindowProvider);

  final today = DateTime.now();
  final from = today.subtract(Duration(days: window.days));

  return api.getEmployeeLedger(
    // `all` (any case) is the backend no-filter sentinel, so it passes through
    // untouched; the chips already store exactly that string.
    branch: branch,
    fromDate: _isoDate(from),
    toDate: _isoDate(today),
  );
});

/// `YYYY-MM-DD`, the only date shape the endpoint accepts.
String _isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

// Lightweight access check for Manager Dashboard visibility
final managerAccessProvider = FutureProvider<bool>((ref) async {
  final roles = await ref.watch(userRolesFutureProvider.future);
  if (!roles.canAccessManagerDashboard) {
    return false;
  }
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/labels_repository.dart';
import '../models/label_models.dart';

/// Which slice of the label board is on screen.
enum LabelFilter {
  attention,
  all,
  onOrder,
  notTracked;

  bool matches(CustomerLabel label) {
    switch (this) {
      case LabelFilter.attention:
        return label.needsAttention;
      case LabelFilter.all:
        return true;
      case LabelFilter.onOrder:
        return label.status == LabelStatus.onOrder || label.hasOpenPrintOrder;
      case LabelFilter.notTracked:
        return !label.tracked;
    }
  }
}

class LabelsState {
  final bool isLoading;
  final bool isSubmitting;
  final bool initialized;
  final String? error;
  final LabelDashboard dashboard;
  final LabelFilter filter;

  /// Selected storage location, or null for every location.
  final String? location;
  final String search;

  const LabelsState({
    required this.isLoading,
    required this.isSubmitting,
    required this.initialized,
    required this.error,
    required this.dashboard,
    required this.filter,
    required this.location,
    required this.search,
  });

  /// Opens on the labels that need printing — the reason anyone opens this
  /// screen — and falls back to everything when nothing is wrong, so a healthy
  /// board never renders as an empty one.
  const LabelsState.initial()
      : isLoading = false,
        isSubmitting = false,
        initialized = false,
        error = null,
        dashboard = const LabelDashboard.empty(),
        filter = LabelFilter.attention,
        location = null,
        search = '';

  LabelSummary get summary => dashboard.summary;
  LabelSettings get settings => dashboard.settings;

  /// The rows to render: filtered, narrowed by location, then by the search box.
  List<CustomerLabel> get visibleLabels {
    final query = search.trim().toLowerCase();
    final where = location?.trim();
    return dashboard.labels.where((label) {
      if (!filter.matches(label)) return false;
      if (where != null && where.isNotEmpty && label.storageLocation != where) {
        return false;
      }
      if (query.isEmpty) return true;
      return label.customerName.toLowerCase().contains(query) ||
          label.customer.toLowerCase().contains(query) ||
          label.labelTitle.toLowerCase().contains(query);
    }).toList();
  }

  /// The visible rows grouped one customer at a time, board order preserved.
  List<LabelCustomerGroup> get visibleGroups =>
      groupLabelsByCustomer(visibleLabels);

  bool get hasAlerts => summary.needsAttention > 0;

  LabelsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? initialized,
    String? error,
    bool clearError = false,
    LabelDashboard? dashboard,
    LabelFilter? filter,
    String? location,
    bool clearLocation = false,
    String? search,
  }) {
    return LabelsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialized: initialized ?? this.initialized,
      error: clearError ? null : (error ?? this.error),
      dashboard: dashboard ?? this.dashboard,
      filter: filter ?? this.filter,
      location: clearLocation ? null : (location ?? this.location),
      search: search ?? this.search,
    );
  }
}

final labelsNotifierProvider =
    StateNotifierProvider<LabelsNotifier, LabelsState>((ref) {
  return LabelsNotifier(ref.watch(labelsRepositoryProvider));
});

/// Badge count for the drawer and the B2B pipeline header.
///
/// `autoDispose` on purpose: it should re-fetch each time a screen that shows
/// the badge is entered, not freeze whatever the first read of the session
/// returned.
final labelAlertCountProvider = FutureProvider.autoDispose<LabelSummary>((ref) async {
  return ref.watch(labelsRepositoryProvider).getAlertCount();
});

class LabelsNotifier extends StateNotifier<LabelsState> {
  final LabelsRepository _repo;

  LabelsNotifier(this._repo) : super(const LabelsState.initial());

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashboard = await _repo.getDashboard();
      // A board with nothing wrong would render empty under the default
      // "Needs printing" filter, which reads as a broken screen rather than as
      // good news. Fall back to All the first time that happens.
      final filter = (!state.initialized &&
              dashboard.summary.needsAttention == 0 &&
              dashboard.labels.isNotEmpty)
          ? LabelFilter.all
          : state.filter;
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        dashboard: dashboard,
        filter: filter,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        error: _message(error),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashboard = await _repo.getDashboard();
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        dashboard: dashboard,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _message(error));
    }
  }

  void setFilter(LabelFilter filter) => state = state.copyWith(filter: filter);

  /// Null (or an empty string) selects every location.
  void setLocation(String? location) {
    if (location == null || location.trim().isEmpty) {
      state = state.copyWith(clearLocation: true);
    } else {
      state = state.copyWith(location: location);
    }
  }

  void setSearch(String search) => state = state.copyWith(search: search);

  void clearError() => state = state.copyWith(clearError: true);

  /// Splices one freshly-returned label back into the board without a full
  /// reload, then refreshes in the background so the summary counts follow.
  void applyUpdated(CustomerLabel updated) {
    final labels = [...state.dashboard.labels];
    final index = labels.indexWhere((l) => l.name == updated.name);
    if (index >= 0) {
      labels[index] = updated;
    } else {
      labels.add(updated);
    }
    state = state.copyWith(
      dashboard: LabelDashboard(
        summary: state.dashboard.summary,
        labels: labels,
        locations: state.dashboard.locations,
        settings: state.dashboard.settings,
      ),
    );
    // The summary and the sort order are server-computed, so pull them again.
    unawaitedRefresh();
  }

  void unawaitedRefresh() {
    refresh().catchError((_) {});
  }

  /// Runs a write and reports failure through the shared error channel, so
  /// every action sheet gets the same treatment without repeating try/catch.
  Future<T?> run<T>(Future<T> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final result = await action();
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: _message(error));
      return null;
    }
  }

  String _message(Object error) => labelErrorMessage(error);
}

/// Frappe puts the useful sentence inside its own exception wrapper; strip
/// the Dio noise so the snackbar is readable. Shared with the detail screen so
/// a manager-gate rejection reads as the server's sentence, not a stack trace.
String labelErrorMessage(Object error) {
  final text = error.toString();
  final match = RegExp(r'"?_server_messages"?\s*:\s*"(.*?)"').firstMatch(text);
  if (match != null) return match.group(1) ?? text;
  return text.replaceFirst('Exception: ', '');
}

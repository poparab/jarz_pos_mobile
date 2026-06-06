import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/product_analytics_models.dart';
import '../data/product_analytics_repository.dart';

// ── Date filter ──────────────────────────────────────────────────────────

enum DateFilterPreset { last30, last90, thisMonth, custom }

extension DateFilterPresetLabel on DateFilterPreset {
  String get label {
    switch (this) {
      case DateFilterPreset.last30:
        return '30d';
      case DateFilterPreset.last90:
        return '90d';
      case DateFilterPreset.thisMonth:
        return 'This Month';
      case DateFilterPreset.custom:
        return 'Custom';
    }
  }
}

class DateFilter {
  final DateFilterPreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;

  const DateFilter({
    this.preset = DateFilterPreset.last30,
    this.customFrom,
    this.customTo,
  });

  DateFilter copyWith({
    DateFilterPreset? preset,
    DateTime? customFrom,
    DateTime? customTo,
  }) =>
      DateFilter(
        preset: preset ?? this.preset,
        customFrom: customFrom ?? this.customFrom,
        customTo: customTo ?? this.customTo,
      );

  static final _fmt = DateFormat('yyyy-MM-dd');

  String get dateFrom {
    final now = DateTime.now();
    switch (preset) {
      case DateFilterPreset.last30:
        return _fmt.format(now.subtract(const Duration(days: 29)));
      case DateFilterPreset.last90:
        return _fmt.format(now.subtract(const Duration(days: 89)));
      case DateFilterPreset.thisMonth:
        return _fmt.format(DateTime(now.year, now.month, 1));
      case DateFilterPreset.custom:
        return customFrom != null ? _fmt.format(customFrom!) : _fmt.format(now.subtract(const Duration(days: 29)));
    }
  }

  String get dateTo {
    final now = DateTime.now();
    if (preset == DateFilterPreset.custom && customTo != null) {
      return _fmt.format(customTo!);
    }
    return _fmt.format(now);
  }

  String get displayLabel {
    if (preset == DateFilterPreset.custom && customFrom != null && customTo != null) {
      return '${_fmt.format(customFrom!)} → ${_fmt.format(customTo!)}';
    }
    return preset.label;
  }
}

// ── Providers ────────────────────────────────────────────────────────────

final dateFilterProvider = StateProvider<DateFilter>(
  (ref) => const DateFilter(preset: DateFilterPreset.last30),
);

final productAnalyticsProvider =
    FutureProvider.autoDispose<ProductAnalyticsData>((ref) async {
  final filter = ref.watch(dateFilterProvider);
  final repo = ref.watch(productAnalyticsRepositoryProvider);
  return repo.fetchAnalytics(
    dateFrom: filter.dateFrom,
    dateTo: filter.dateTo,
  );
});

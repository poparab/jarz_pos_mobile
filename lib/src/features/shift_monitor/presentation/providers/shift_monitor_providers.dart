import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/shift_monitor_repository.dart';
import '../../models/shift_monitor_models.dart';

enum ShiftMonitorQuickRange { today, last7Days, custom }

enum ShiftMonitorStatusFilter { all, open, closed }

class ShiftMonitorQuery {
  const ShiftMonitorQuery({
    required this.fromDate,
    required this.toDate,
    this.posProfile,
    required this.status,
  });

  final String fromDate;
  final String toDate;
  final String? posProfile;
  final ShiftMonitorStatusFilter status;
}

final shiftMonitorQuickRangeProvider = StateProvider<ShiftMonitorQuickRange>((
  ref,
) {
  return ShiftMonitorQuickRange.today;
});

final shiftMonitorDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  return null;
});

final shiftMonitorSelectedProfileProvider = StateProvider<String?>((ref) {
  return null;
});

final shiftMonitorStatusFilterProvider =
    StateProvider<ShiftMonitorStatusFilter>((ref) {
      return ShiftMonitorStatusFilter.all;
    });

final shiftMonitorQueryProvider = Provider<ShiftMonitorQuery>((ref) {
  final quickRange = ref.watch(shiftMonitorQuickRangeProvider);
  final customRange = ref.watch(shiftMonitorDateRangeProvider);
  final selectedProfile = ref.watch(shiftMonitorSelectedProfileProvider);
  final status = ref.watch(shiftMonitorStatusFilterProvider);
  final today = DateTime.now();

  DateTime start;
  DateTime end;
  switch (quickRange) {
    case ShiftMonitorQuickRange.today:
      start = _dateOnly(today);
      end = _dateOnly(today);
    case ShiftMonitorQuickRange.last7Days:
      end = _dateOnly(today);
      start = end.subtract(const Duration(days: 6));
    case ShiftMonitorQuickRange.custom:
      final range = customRange;
      if (range == null) {
        start = _dateOnly(today);
        end = _dateOnly(today);
      } else {
        start = _dateOnly(range.start);
        end = _dateOnly(range.end);
      }
  }

  return ShiftMonitorQuery(
    fromDate: _formatQueryDate(start),
    toDate: _formatQueryDate(end),
    posProfile: selectedProfile,
    status: status,
  );
});

final shiftMonitorDataProvider =
    FutureProvider.autoDispose<ShiftMonitorResponse>((ref) async {
      final repository = ref.watch(shiftMonitorRepositoryProvider);
      final query = ref.watch(shiftMonitorQueryProvider);
      return repository.fetchShiftMonitor(
        fromDate: query.fromDate,
        toDate: query.toDate,
        posProfile: query.posProfile,
        status: query.status.name,
      );
    });

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _formatQueryDate(DateTime value) =>
    DateFormat('yyyy-MM-dd').format(value);

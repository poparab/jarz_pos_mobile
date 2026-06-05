import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/shift_monitor/presentation/providers/shift_monitor_providers.dart';

void main() {
  test('last 7 days query spans seven calendar days', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(shiftMonitorQuickRangeProvider.notifier).state =
        ShiftMonitorQuickRange.last7Days;

    final query = container.read(shiftMonitorQueryProvider);
    final fromDate = DateTime.parse(query.fromDate);
    final toDate = DateTime.parse(query.toDate);

    expect(query.status, ShiftMonitorStatusFilter.all);
    expect(toDate.difference(fromDate).inDays, 6);
  });

  test('custom range query uses chosen dates and selected filters', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(shiftMonitorQuickRangeProvider.notifier).state =
        ShiftMonitorQuickRange.custom;
    container.read(shiftMonitorDateRangeProvider.notifier).state =
        DateTimeRange(start: DateTime(2026, 6, 1), end: DateTime(2026, 6, 3));
    container.read(shiftMonitorSelectedProfileProvider.notifier).state =
        'Dokki';
    container.read(shiftMonitorStatusFilterProvider.notifier).state =
        ShiftMonitorStatusFilter.closed;

    final query = container.read(shiftMonitorQueryProvider);

    expect(query.fromDate, '2026-06-01');
    expect(query.toDate, '2026-06-03');
    expect(query.posProfile, 'Dokki');
    expect(query.status, ShiftMonitorStatusFilter.closed);
  });
}

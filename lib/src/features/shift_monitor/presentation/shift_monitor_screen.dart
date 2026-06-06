import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/frappe_error_message.dart';
import '../../../core/network/user_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../manager/state/manager_providers.dart';
import '../models/shift_monitor_models.dart';
import 'providers/shift_monitor_providers.dart';

class ShiftMonitorScreen extends ConsumerWidget {
  const ShiftMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canAccess = ref.watch(canAccessShiftMonitorProvider);
    final dataAsync = ref.watch(shiftMonitorDataProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.managerMenuTooltip,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(l10n.shiftMonitorTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            onPressed: () => ref.invalidate(shiftMonitorDataProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !canAccess
          ? _AccessDeniedState()
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(managerAccessProvider);
                ref.invalidate(shiftMonitorDataProvider);
                await ref.read(shiftMonitorDataProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _ShiftMonitorFilterBar(),
                  const SizedBox(height: 16),
                  dataAsync.when(
                    data: (data) => _ShiftMonitorContent(data: data),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => _ErrorState(error: error),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AccessDeniedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 42),
            const SizedBox(height: 12),
            Text(
              l10n.shiftMonitorAccessRequired,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.shiftMonitorAccessDeniedBody,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftMonitorFilterBar extends ConsumerWidget {
  const _ShiftMonitorFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(shiftMonitorQuickRangeProvider);
    final status = ref.watch(shiftMonitorStatusFilterProvider);
    final selectedProfile = ref.watch(shiftMonitorSelectedProfileProvider);
    final response = ref.watch(shiftMonitorDataProvider).valueOrNull;
    final customRange = ref.watch(shiftMonitorDateRangeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.shiftMonitorFiltersTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ShiftMonitorQuickRange>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ShiftMonitorQuickRange.today,
                  label: Text(l10n.shiftMonitorToday),
                ),
                ButtonSegment(
                  value: ShiftMonitorQuickRange.last7Days,
                  label: Text(l10n.shiftMonitorLast7Days),
                ),
                ButtonSegment(
                  value: ShiftMonitorQuickRange.custom,
                  label: Text(l10n.shiftMonitorCustomRange),
                ),
              ],
              selected: {range},
              onSelectionChanged: (selection) {
                ref.read(shiftMonitorQuickRangeProvider.notifier).state =
                    selection.first;
              },
            ),
            const SizedBox(height: 12),
            if (ResponsiveUtils.isPhone(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: selectedProfile,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shiftMonitorProfileFilter,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.managerAll),
                      ),
                      for (final profile in response?.profiles ?? const [])
                        DropdownMenuItem<String?>(
                          value: profile.name,
                          child: Text(profile.title),
                        ),
                    ],
                    onChanged: (value) {
                      ref.read(shiftMonitorSelectedProfileProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ShiftMonitorStatusFilter>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.shiftMonitorStatusFilter,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ShiftMonitorStatusFilter.all,
                        child: Text(l10n.shiftMonitorStatusAll),
                      ),
                      DropdownMenuItem(
                        value: ShiftMonitorStatusFilter.open,
                        child: Text(l10n.shiftMonitorStatusOpen),
                      ),
                      DropdownMenuItem(
                        value: ShiftMonitorStatusFilter.closed,
                        child: Text(l10n.shiftMonitorStatusClosed),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(shiftMonitorStatusFilterProvider.notifier).state = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        initialDateRange: customRange,
                      );
                      if (picked == null) return;
                      ref.read(shiftMonitorDateRangeProvider.notifier).state = picked;
                      ref.read(shiftMonitorQuickRangeProvider.notifier).state =
                          ShiftMonitorQuickRange.custom;
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      customRange == null
                          ? l10n.shiftMonitorPickDateRange
                          : l10n.shiftMonitorDateRangeValue(
                              formatDate(context, customRange.start),
                              formatDate(context, customRange.end),
                            ),
                    ),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String?>(
                      initialValue: selectedProfile,
                      decoration: InputDecoration(
                        labelText: l10n.shiftMonitorProfileFilter,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.managerAll),
                        ),
                        for (final profile in response?.profiles ?? const [])
                          DropdownMenuItem<String?>(
                            value: profile.name,
                            child: Text(profile.title),
                          ),
                      ],
                      onChanged: (value) {
                        ref.read(shiftMonitorSelectedProfileProvider.notifier).state = value;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<ShiftMonitorStatusFilter>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: l10n.shiftMonitorStatusFilter,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ShiftMonitorStatusFilter.all,
                          child: Text(l10n.shiftMonitorStatusAll),
                        ),
                        DropdownMenuItem(
                          value: ShiftMonitorStatusFilter.open,
                          child: Text(l10n.shiftMonitorStatusOpen),
                        ),
                        DropdownMenuItem(
                          value: ShiftMonitorStatusFilter.closed,
                          child: Text(l10n.shiftMonitorStatusClosed),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(shiftMonitorStatusFilterProvider.notifier).state = value;
                        }
                      },
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        initialDateRange: customRange,
                      );
                      if (picked == null) return;
                      ref.read(shiftMonitorDateRangeProvider.notifier).state = picked;
                      ref.read(shiftMonitorQuickRangeProvider.notifier).state =
                          ShiftMonitorQuickRange.custom;
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      customRange == null
                          ? l10n.shiftMonitorPickDateRange
                          : l10n.shiftMonitorDateRangeValue(
                              formatDate(context, customRange.start),
                              formatDate(context, customRange.end),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ShiftMonitorContent extends StatelessWidget {
  const _ShiftMonitorContent({required this.data});

  final ShiftMonitorResponse data;

  @override
  Widget build(BuildContext context) {
    final groups = _groupShifts(data.shifts);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCards(summary: data.summary),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.shiftMonitorNoData),
            ),
          )
        else
          for (final group in groups) ...[
            _ShiftProfileCard(group: group),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final ShiftMonitorSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth > 480
            ? 220.0
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: itemWidth,
              label: l10n.shiftMonitorOpenCount,
              value: formatCount(context, summary.openCount),
              color: Colors.blue,
            ),
            _SummaryCard(
              width: itemWidth,
              label: l10n.shiftMonitorClosedCount,
              value: formatCount(context, summary.closedCount),
              color: Colors.green,
            ),
            _SummaryCard(
              width: itemWidth,
              label: l10n.shiftMonitorDiscrepancyCount,
              value: formatCount(context, summary.discrepancyCount),
              color: Colors.orange,
            ),
            _SummaryCard(
              width: itemWidth,
              label: l10n.shiftMonitorDiscrepancyTotal,
              value: formatCurrency(context, summary.discrepancyTotal),
              color: summary.discrepancyTotal == 0
                  ? Colors.grey
                  : Colors.deepOrange,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftProfileCard extends StatelessWidget {
  const _ShiftProfileCard({required this.group});

  final _ShiftProfileGroup group;

  @override
  Widget build(BuildContext context) {
    final latest = group.latest;
    final l10n = context.l10n;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: group.shifts.length == 1,
        title: Text(
          group.profileName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(shift: latest),
              _InfoPill(
                icon: Icons.play_circle_outline,
                label: l10n.shiftMonitorLatestStart(
                  latest.openedAt == null
                      ? l10n.commonNotSpecified
                      : formatDateTime(context, latest.openedAt!),
                ),
              ),
              _InfoPill(
                icon: Icons.person_outline,
                label: latest.openerLabel.isEmpty
                    ? l10n.commonNotSpecified
                    : latest.openerLabel,
              ),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.shiftMonitorShiftCount(group.shifts.length),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          for (final shift in group.shifts) ...[
            _ShiftDetailsCard(shift: shift),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ShiftDetailsCard extends StatelessWidget {
  const _ShiftDetailsCard({required this.shift});

  final ShiftMonitorShift shift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final differenceColor = switch (shift.differenceKind) {
      'surplus' => Colors.green,
      'shortage' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(shift: shift),
              if (shift.hasDiscrepancy)
                Chip(
                  label: Text(
                    '${_differenceLabel(context, shift.differenceKind)} • ${formatCurrency(context, shift.differenceAmount ?? 0)}',
                  ),
                  backgroundColor: differenceColor.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: differenceColor.withValues(alpha: 0.18),
                  ),
                  labelStyle: TextStyle(color: differenceColor),
                )
              else
                Chip(label: Text(l10n.shiftMonitorNoDiscrepancy)),
              if ((shift.journalEntry ?? '').isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.receipt_long, size: 18),
                  label: Text(shift.journalEntry!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FactTile(
                label: l10n.shiftMonitorOpenedAt,
                value: shift.openedAt == null
                    ? l10n.commonNotSpecified
                    : formatDateTime(context, shift.openedAt!),
              ),
              _FactTile(
                label: l10n.shiftMonitorOpenedBy,
                value: shift.openerLabel.isEmpty
                    ? l10n.commonNotSpecified
                    : shift.openerLabel,
              ),
              _FactTile(
                label: l10n.shiftMonitorClosedAt,
                value: shift.closedAt == null
                    ? l10n.commonNotSpecified
                    : formatDateTime(context, shift.closedAt!),
              ),
              _FactTile(
                label: l10n.shiftMonitorClosedBy,
                value: shift.closerLabel.isEmpty
                    ? l10n.commonNotSpecified
                    : shift.closerLabel,
              ),
              _FactTile(
                label: l10n.shiftMonitorCashAccount,
                value: (shift.cashAccount ?? '').isEmpty
                    ? l10n.commonNotSpecified
                    : shift.cashAccount!,
              ),
              _FactTile(
                label: l10n.shiftMonitorOpeningCash,
                value: formatCurrency(context, shift.openingAmount),
              ),
              _FactTile(
                label: l10n.shiftMonitorExpectedClosingCash,
                value: shift.expectedClosingAmount == null
                    ? l10n.commonNotSpecified
                    : formatCurrency(context, shift.expectedClosingAmount!),
              ),
              _FactTile(
                label: l10n.shiftMonitorActualClosingCash,
                value: shift.actualClosingAmount == null
                    ? l10n.commonNotSpecified
                    : formatCurrency(context, shift.actualClosingAmount!),
              ),
              _FactTile(
                label: l10n.shiftMonitorDifference,
                value: shift.differenceAmount == null
                    ? l10n.commonNotSpecified
                    : formatCurrency(context, shift.differenceAmount!),
                valueColor: differenceColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.shift});

  final ShiftMonitorShift shift;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpen = shift.isOpen;
    final color = isOpen ? Colors.blue : Colors.green;
    return Chip(
      label: Text(
        isOpen ? l10n.shiftMonitorStatusOpen : l10n.shiftMonitorStatusClosed,
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.18)),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final message = extractFrappeErrorMessage(
      error,
      fallback: l10n.commonError,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.commonError,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(shiftMonitorDataProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftProfileGroup {
  const _ShiftProfileGroup({required this.profileName, required this.shifts});

  final String profileName;
  final List<ShiftMonitorShift> shifts;

  ShiftMonitorShift get latest => shifts.first;
}

List<_ShiftProfileGroup> _groupShifts(List<ShiftMonitorShift> shifts) {
  final groups = <String, List<ShiftMonitorShift>>{};
  final order = <String>[];

  for (final shift in shifts) {
    final key = shift.posProfile;
    final bucket = groups.putIfAbsent(key, () {
      order.add(key);
      return <ShiftMonitorShift>[];
    });
    bucket.add(shift);
  }

  return [
    for (final key in order)
      _ShiftProfileGroup(profileName: key, shifts: groups[key]!),
  ];
}

String _differenceLabel(BuildContext context, String kind) {
  final l10n = context.l10n;
  switch (kind) {
    case 'surplus':
      return l10n.shiftMonitorDifferenceSurplus;
    case 'shortage':
      return l10n.shiftMonitorDifferenceShortage;
    default:
      return l10n.shiftMonitorNoDiscrepancy;
  }
}

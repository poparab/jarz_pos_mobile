import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/roster_models.dart';
import '../../state/roster_providers.dart';

/// The month's hours, as payroll reads them.
Future<void> showRosterHoursSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const RosterHoursSheet(),
  );
}

class RosterHoursSheet extends ConsumerWidget {
  const RosterHoursSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hoursAsync = ref.watch(rosterHoursProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: hoursAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(context.userErrorMessage(error)),
          ),
          data: (hours) => ListView(
            controller: controller,
            children: [
              Text(
                l10n.rosterHoursTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // Says outright where the number comes from. Auto-attendance is
                // off, so these are rostered hours, not clocked hours — and
                // somebody will eventually ask why they differ from the
                // check-in log.
                l10n.rosterHoursBasis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _Totals(hours: hours),
              const SizedBox(height: 16),
              if (hours.rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l10n.rosterNobodyRostered)),
                )
              else
                ...hours.rows.map((row) => _HoursRowTile(row: row)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.hours});

  final RosterHours hours;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric(
            label: l10n.rosterWorkedHours,
            value: _trimZero(hours.totalWorkedHours),
          ),
          _Metric(
            label: l10n.rosterOvertimeHours,
            value: _trimZero(hours.totalOvertimeHours),
          ),
          _Metric(
            label: l10n.rosterCreditedHours,
            value: _trimZero(hours.totalCreditedHours),
            emphasise: true,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasise ? theme.colorScheme.primary : null,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _HoursRowTile extends StatelessWidget {
  const _HoursRowTile({required this.row});

  final RosterHoursRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasOvertime = row.overtimeHours > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.employeeName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (row.isCourier)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      l10n.rosterCourierTag(_trimZero(row.overtimeMultiplier)),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.rosterRowDays(row.workedDays, row.offDays, row.coverDays),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _Pill(
                  label: l10n.rosterWorkedHours,
                  value: _trimZero(row.workedHours),
                ),
                if (hasOvertime)
                  _Pill(
                    label: l10n.rosterOvertimeHours,
                    value: _trimZero(row.overtimeHours),
                  ),
                if (hasOvertime)
                  _Pill(
                    label: l10n.rosterCreditedOvertime,
                    value: _trimZero(row.creditedOvertimeHours),
                    highlight: true,
                  ),
                _Pill(
                  label: l10n.rosterCreditedHours,
                  value: _trimZero(row.creditedHours),
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: highlight ? theme.colorScheme.onPrimaryContainer : null,
          fontWeight: highlight ? FontWeight.w700 : null,
        ),
      ),
    );
  }
}

String _trimZero(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

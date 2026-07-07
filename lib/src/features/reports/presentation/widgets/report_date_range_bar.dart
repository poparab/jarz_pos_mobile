import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/reports_providers.dart';

/// A From/To date-range control with quick-range shortcuts, bound to the shared
/// [reportRangeProvider]. Reused by every analytics dashboard so the six screens
/// present an identical range picker. RTL/Arabic-aware.
class ReportDateRangeBar extends ConsumerWidget {
  const ReportDateRangeBar({super.key});

  Future<void> _pickFrom(
    BuildContext context,
    WidgetRef ref,
    ReportRange range,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: range.from,
      firstDate: DateTime(2018),
      lastDate: range.to,
    );
    if (picked != null) {
      ref.read(reportRangeProvider.notifier).state = range.copyWith(from: picked);
    }
  }

  Future<void> _pickTo(
    BuildContext context,
    WidgetRef ref,
    ReportRange range,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: range.to,
      firstDate: range.from,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(reportRangeProvider.notifier).state = range.copyWith(to: picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final df = DateFormat.yMMMd();

    void setRange(ReportRange r) =>
        ref.read(reportRangeProvider.notifier).state = r;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: l10n.reportsFrom,
                    value: df.format(range.from),
                    onTap: () => _pickFrom(context, ref, range),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateField(
                    label: l10n.reportsTo,
                    value: df.format(range.to),
                    onTap: () => _pickTo(context, ref, range),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _QuickChip(
                  label: l10n.reportsRangeThisMonth,
                  onTap: () => setRange(ReportRange.thisMonth()),
                ),
                _QuickChip(
                  label: l10n.reportsRangeLast30Days,
                  onTap: () => setRange(ReportRange.lastDays(30)),
                ),
                _QuickChip(
                  label: l10n.reportsRangeLast90Days,
                  onTap: () => setRange(ReportRange.lastDays(90)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          value,
          style: theme.textTheme.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

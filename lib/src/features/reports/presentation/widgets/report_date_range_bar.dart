import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import '../../state/reports_providers.dart';

/// Localised chip label for a [ReportRangePreset].
String reportRangePresetLabel(AppLocalizations l10n, ReportRangePreset p) =>
    switch (p) {
      ReportRangePreset.today => l10n.rptRangeToday,
      ReportRangePreset.yesterday => l10n.rptRangeYesterday,
      ReportRangePreset.last7Days => l10n.rptRangeLast7Days,
      ReportRangePreset.thisMonth => l10n.rptRangeThisMonth,
      ReportRangePreset.lastMonth => l10n.rptRangeLastMonth,
      ReportRangePreset.last30Days => l10n.rptRangeLast30Days,
      ReportRangePreset.last90Days => l10n.rptRangeLast90Days,
      ReportRangePreset.thisYear => l10n.rptRangeThisYear,
    };

/// A From/To date-range control with a scrollable row of quick presets
/// (Today … Year to date), bound to the shared [reportRangeProvider]. The
/// chip matching the current range is highlighted. RTL/Arabic-aware.
///
/// Set [embedded] to drop the surrounding card (used by `ReportFilterBar`,
/// which supplies its own).
class ReportDateRangeBar extends ConsumerWidget {
  final bool embedded;

  const ReportDateRangeBar({super.key, this.embedded = false});

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: range.to.isAfter(today) ? today : range.to,
      firstDate: range.from,
      lastDate: today.isBefore(range.from) ? range.from : today,
    );
    if (picked != null) {
      ref.read(reportRangeProvider.notifier).state = range.copyWith(to: picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(reportRangeProvider);
    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMd(locale);
    final selected = range.matchingPreset();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in ReportRangePreset.values)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    label: Text(reportRangePresetLabel(l10n, p)),
                    selected: p == selected,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) =>
                        ref.read(reportRangeProvider.notifier).state = p.range(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    if (embedded) return content;
    return Card(
      margin: const EdgeInsetsDirectional.all(8),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        child: content,
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
              const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 12),
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

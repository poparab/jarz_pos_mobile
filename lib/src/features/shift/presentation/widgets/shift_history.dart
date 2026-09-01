import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/history_sheet.dart';
import '../../data/shift_repository.dart';

/// Shifts that have already been closed.
///
/// Closing a shift used to remove it from the app entirely: `get_active_shift`
/// answers only about the open one and the monitor lists only what is still
/// open, so yesterday's close was unreachable from every screen.
abstract final class ShiftHistory {
  static Future<void> show(BuildContext context, WidgetRef ref) {
    final repository = ref.read(shiftRepositoryProvider);
    final filters = _ShiftHistoryFilters();

    return HistorySheet.show<Map<String, dynamic>>(
      context,
      title: context.l10n.shiftHistoryTitle,
      emptyMessage: context.l10n.shiftHistoryEmpty,
      fetch: (query) async {
        final result = await repository.listShifts(
          limit: query.limit,
          page: query.page,
          mineOnly: filters.mineOnly,
          fromDate: query.fromDate == null
              ? null
              : _apiDate.format(query.fromDate!),
          toDate:
              query.toDate == null ? null : _apiDate.format(query.toDate!),
        );
        filters.amountsHidden = result.amountsHidden;
        return HistoryPage(items: result.shifts, total: result.total);
      },
      filterBuilder: (context, refresh) => _FilterRow(
        filters: filters,
        onChanged: refresh,
      ),
      itemBuilder: (context, shift) => _ShiftCard(
        shift: shift,
        amountsHidden: filters.amountsHidden,
      ),
    );
  }

  static final _apiDate = DateFormat('yyyy-MM-dd');
}

/// Mutable filter state shared between the sheet's filter row, its fetcher and
/// its cards. `amountsHidden` is the server's answer, not a local guess — it
/// decides both the banner and whether a card renders money at all.
class _ShiftHistoryFilters {
  bool mineOnly = false;
  bool amountsHidden = true;
}

class _FilterRow extends StatefulWidget {
  final _ShiftHistoryFilters filters;
  final VoidCallback onChanged;

  const _FilterRow({required this.filters, required this.onChanged});

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only a manager sees other people's shifts, so only a manager has
        // anything to narrow down.
        if (!widget.filters.amountsHidden)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilterChip(
              label: Text(l10n.shiftHistoryMineOnly),
              selected: widget.filters.mineOnly,
              onSelected: (value) {
                setState(() => widget.filters.mineOnly = value);
                widget.onChanged();
              },
            ),
          ),
        if (widget.filters.amountsHidden)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.shiftHistoryAmountsHidden,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final Map<String, dynamic> shift;
  final bool amountsHidden;

  const _ShiftCard({required this.shift, required this.amountsHidden});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isOpen = shift['is_open'] == true;
    final difference = (shift['difference'] as num?) ?? 0;
    final reconciliation = ((shift['payment_reconciliation'] as List?) ??
            const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final start = shift['period_start_date']?.toString();
    final end = shift['period_end_date']?.toString();

    final header = Row(
      children: [
        Expanded(
          child: Text(
            (shift['pos_profile'] ?? '').toString(),
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Chip(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          label: Text(
            isOpen ? l10n.shiftHistoryStatusOpen : l10n.shiftHistoryStatusClosed,
            style: theme.textTheme.labelSmall,
          ),
          backgroundColor: isOpen
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
        ),
      ],
    );

    final subtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOpen
              ? l10n.shiftHistoryStillOpen
              : l10n.shiftHistoryDuration(
                  formatDateString(context, start,
                      pattern: 'MMM d, h:mm a'),
                  formatDateString(context, end, pattern: 'MMM d, h:mm a'),
                ),
          style: theme.textTheme.bodySmall,
        ),
        if ((shift['user_full_name'] ?? '').toString().isNotEmpty)
          Text(
            l10n.shiftHistoryOpenedBy(shift['user_full_name'].toString()),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        if (!amountsHidden && shift['grand_total'] != null)
          Text(
            '${l10n.commonTotalLabel}: ${formatCurrency(context, (shift['grand_total'] as num?) ?? 0)}'
            ' · ${l10n.shiftHistoryDifference}: ${formatCurrency(context, difference)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: difference == 0
                  ? theme.hintColor
                  : theme.colorScheme.error,
              fontWeight: difference == 0 ? null : FontWeight.w600,
            ),
          ),
      ],
    );

    // Nothing to expand into when the per-mode rows are withheld or absent, so
    // a plain tile — an ExpansionTile that opens onto nothing reads as broken.
    if (reconciliation.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: ListTile(
          title: header,
          subtitle: subtitle,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: header,
        subtitle: subtitle,
        children: [
          for (final row in reconciliation)
            ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsetsDirectional.only(start: 24, end: 16),
              title: Text(
                (row['mode_of_payment'] ?? '').toString(),
                style: theme.textTheme.bodySmall,
              ),
              subtitle: Text(
                '${formatCurrency(context, (row['expected_amount'] as num?) ?? 0)}'
                ' -> ${formatCurrency(context, (row['closing_amount'] as num?) ?? 0)}',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              trailing: Text(
                formatCurrency(context, (row['difference'] as num?) ?? 0),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ((row['difference'] as num?) ?? 0) == 0
                      ? theme.hintColor
                      : theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

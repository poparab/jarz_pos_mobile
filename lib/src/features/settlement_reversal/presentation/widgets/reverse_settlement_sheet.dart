import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/history_sheet.dart';
import '../../data/models/recent_settlement.dart';
import '../../data/settlement_reversal_service.dart';
import 'unsettle_flow_dialog.dart';

/// Entry point for "reverse a settlement": a searchable list of settlements
/// the server knows about, newest first — never a text field asking for a
/// Journal Entry name.
///
/// Reads `list_recent_settlements`, which is branch-scoped exactly like
/// `get_courier_balances`: a settlement made on another device, or before
/// this feature shipped, shows up here too — unlike the retired local Hive
/// cache this replaces.
///
/// [posProfile], when given, scopes the list to the branch currently open;
/// omit it to show every branch the caller belongs to.
abstract final class ReverseSettlementSheet {
  static Future<void> show(
    BuildContext context, {
    String? posProfile,
  }) {
    final container = ProviderScope.containerOf(context, listen: false);
    final service = container.read(settlementReversalServiceProvider);

    // The server takes no search/paging parameters of its own — one call
    // brings back everything within the branch scope, and the sheet's
    // built-in search/date-range/paging chrome filters that in memory. Every
    // fetch hits the server fresh (no client-side cache across calls) so the
    // sheet's own refresh button, and reopening after a reversal, always show
    // the current already_reversed state.
    Future<HistoryPage<RecentSettlement>> fetch(HistoryQuery query) async {
      var rows = await service.listRecentSettlements(
        posProfile: posProfile,
        limit: 200,
        includeReversed: true,
      );

      if (query.fromDate != null) {
        rows = rows.where((r) {
          final posted = _parseDate(r.postingDate);
          return posted == null || !posted.isBefore(query.fromDate!);
        }).toList();
      }
      if (query.toDate != null) {
        final endOfDay = DateTime(
          query.toDate!.year,
          query.toDate!.month,
          query.toDate!.day,
          23,
          59,
          59,
        );
        rows = rows.where((r) {
          final posted = _parseDate(r.postingDate);
          return posted == null || !posted.isAfter(endOfDay);
        }).toList();
      }
      final search = query.search?.trim().toLowerCase();
      if (search != null && search.isNotEmpty) {
        rows = rows.where((r) {
          return r.journalEntry.toLowerCase().contains(search) ||
              r.party.toLowerCase().contains(search) ||
              r.displayName.toLowerCase().contains(search);
        }).toList();
      }

      final total = rows.length;
      final page = rows
          .skip(query.page * query.limit)
          .take(query.limit)
          .toList(growable: false);
      return HistoryPage(items: page, total: total);
    }

    return HistorySheet.show<RecentSettlement>(
      context,
      title: context.l10n.unsettleHistoryTitle,
      searchHint: context.l10n.unsettleHistorySearchHint,
      emptyMessage: context.l10n.unsettleHistoryEmpty,
      showDateRange: true,
      fetch: fetch,
      itemBuilder: (context, row) => _RecentSettlementCard(record: row),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return DateTime.tryParse(raw);
}

class _RecentSettlementCard extends StatelessWidget {
  final RecentSettlement record;
  const _RecentSettlementCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final reversed = record.alreadyReversed;

    final subtitleParts = <String>[
      if (record.posProfile != null && record.posProfile!.isNotEmpty)
        record.posProfile!,
      l10n.unsettleRecordInvoiceCount(record.transactionCount),
      if (record.postingDate != null)
        formatDateString(context, record.postingDate),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: Icon(
          reversed ? Icons.undo : Icons.receipt_long,
          color: reversed ? theme.hintColor : null,
        ),
        title: Text(record.displayName, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.unsettleRecordJournalEntry(record.journalEntry),
              style: theme.textTheme.bodySmall,
            ),
            Text(
              subtitleParts.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            if (reversed)
              Text(
                record.reversalJournalEntry != null
                    ? l10n.unsettleReversalEntryLabel(record.reversalJournalEntry!)
                    : l10n.unsettleAlreadyReversedLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: record.netAmount != null
            ? Text(
                formatCurrency(context, record.netAmount!.abs()),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              )
            : null,
        isThreeLine: true,
        enabled: !reversed,
        onTap: reversed
            ? null
            : () => showUnsettleFlowDialog(context, record.journalEntry),
      ),
    );
  }
}

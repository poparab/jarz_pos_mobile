import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/history_sheet.dart';
import '../../data/stock_transfer_service.dart';

/// What this screen already moved. Submitting a transfer used to be
/// write-only: nothing in the app could tell a repeated transfer from a first
/// one, so the only way to check was to open Desk.
abstract final class StockTransferHistory {
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static Future<void> show(BuildContext context, WidgetRef ref) {
    final service = ref.read(stockTransferServiceProvider);
    return HistorySheet.show<Map<String, dynamic>>(
      context,
      title: context.l10n.stockTransferHistoryTitle,
      searchHint: context.l10n.stockTransferHistorySearchHint,
      emptyMessage: context.l10n.stockTransferHistoryEmpty,
      fetch: (query) async {
        final result = await service.listTransfers(
          limit: query.limit,
          page: query.page,
          search: query.search,
          fromDate:
              query.fromDate == null ? null : _apiDate.format(query.fromDate!),
          toDate: query.toDate == null ? null : _apiDate.format(query.toDate!),
        );
        return HistoryPage(items: result.transfers, total: result.total);
      },
      itemBuilder: (context, transfer) => _TransferCard(transfer: transfer),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final Map<String, dynamic> transfer;

  const _TransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = ((transfer['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final source = (transfer['source_warehouse'] ?? '').toString();
    final target = (transfer['target_warehouse'] ?? '').toString();
    // A transfer built by this screen is always one warehouse pair. An entry
    // made by hand in Desk need not be, and then there is no single route to
    // name — say so rather than showing whichever line happened to be first.
    final route = source.isEmpty || target.isEmpty
        ? l10n.stockTransferHistoryMixed
        : l10n.stockTransferHistoryRoute(source, target);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(route,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              l10n.stockTransferHistorySummary(
                formatCount(context, items.length),
                formatCount(context, (transfer['total_qty'] as num?) ?? 0),
              ),
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${formatDateString(context, transfer['posting_date']?.toString())}'
              ' · ${transfer['name'] ?? ''}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
            if ((transfer['owner_name'] ?? '').toString().isNotEmpty)
              Text(
                transfer['owner_name'].toString(),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
          ],
        ),
        children: [
          for (final item in items)
            ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsetsDirectional.only(start: 24, end: 16),
              title: Text(
                (item['item_name'] ?? item['item_code'] ?? '').toString(),
                style: theme.textTheme.bodySmall,
              ),
              subtitle: (item['item_name'] != null &&
                      item['item_code'] != null &&
                      item['item_name'] != item['item_code'])
                  ? Text(item['item_code'].toString(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor))
                  : null,
              trailing: Text(
                '${formatCount(context, (item['qty'] as num?) ?? 0)}'
                ' ${item['uom'] ?? ''}'.trim(),
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

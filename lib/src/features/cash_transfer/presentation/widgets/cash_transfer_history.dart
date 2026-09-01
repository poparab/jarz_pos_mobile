import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/history_sheet.dart';
import '../../data/cash_transfer_service.dart';

/// Cash already moved between drawers and accounts.
abstract final class CashTransferHistory {
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static Future<void> show(BuildContext context, WidgetRef ref) {
    final service = ref.read(cashTransferServiceProvider);
    return HistorySheet.show<Map<String, dynamic>>(
      context,
      title: context.l10n.cashTransferHistoryTitle,
      searchHint: context.l10n.cashTransferHistorySearchHint,
      emptyMessage: context.l10n.cashTransferHistoryEmpty,
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
      itemBuilder: (context, transfer) => _CashTransferCard(transfer: transfer),
    );
  }
}

class _CashTransferCard extends StatelessWidget {
  final Map<String, dynamic> transfer;

  const _CashTransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remark = (transfer['user_remark'] ?? '').toString().trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (transfer['from_label'] ?? transfer['from_account'] ?? '')
                        .toString(),
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Expanded(
                  child: Text(
                    (transfer['to_label'] ?? transfer['to_account'] ?? '')
                        .toString(),
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  formatCurrency(context, (transfer['amount'] as num?) ?? 0),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  formatDateString(context, transfer['posting_date']?.toString()),
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              [
                (transfer['name'] ?? '').toString(),
                if ((transfer['owner_name'] ?? '').toString().isNotEmpty)
                  transfer['owner_name'].toString(),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            if (remark.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(remark, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/history_sheet.dart';
import '../../data/inventory_count_service.dart';

/// Counts already submitted, and what each one corrected.
abstract final class InventoryCountHistory {
  static final _apiDate = DateFormat('yyyy-MM-dd');

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    String? warehouse,
  }) {
    final service = ref.read(inventoryCountServiceProvider);
    return HistorySheet.show<Map<String, dynamic>>(
      context,
      title: context.l10n.inventoryCountHistoryTitle,
      searchHint: context.l10n.inventoryCountHistorySearchHint,
      emptyMessage: context.l10n.inventoryCountHistoryEmpty,
      fetch: (query) async {
        final result = await service.listReconciliations(
          limit: query.limit,
          page: query.page,
          search: query.search,
          warehouse: warehouse,
          fromDate:
              query.fromDate == null ? null : _apiDate.format(query.fromDate!),
          toDate: query.toDate == null ? null : _apiDate.format(query.toDate!),
        );
        return HistoryPage(items: result.counts, total: result.total);
      },
      itemBuilder: (context, count) => _CountCard(count: count),
    );
  }
}

class _CountCard extends StatelessWidget {
  final Map<String, dynamic> count;

  const _CountCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = ((count['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final difference = (count['difference_amount'] as num?) ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          (count['warehouse'] ?? count['name'] ?? '').toString(),
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${l10n.inventoryCountHistoryAdjusted(formatCount(context, (count['item_count'] as num?) ?? items.length))}'
              ' · ${l10n.inventoryCountHistoryDeltas(formatCount(context, (count['increase_count'] as num?) ?? 0), formatCount(context, (count['decrease_count'] as num?) ?? 0))}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${formatDateString(context, count['posting_date']?.toString())}'
              ' · ${count['name'] ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            if (difference != 0)
              Text(
                '${l10n.inventoryCountHistoryValueChange}: ${formatCurrency(context, difference)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: difference < 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
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
              // Before and after, then the delta — the delta alone hides
              // whether a count of 12 corrected 11 or 400.
              subtitle: Text(
                '${formatCount(context, (item['current_qty'] as num?) ?? 0)}'
                ' -> ${formatCount(context, (item['qty'] as num?) ?? 0)}',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
              trailing: _DeltaChip(
                delta: (item['qty_difference'] as num?) ?? 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final num delta;

  const _DeltaChip({required this.delta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        delta < 0 ? theme.colorScheme.error : theme.colorScheme.primary;
    final sign = delta > 0 ? '+' : '';
    return Text(
      '$sign${formatCount(context, delta)}',
      style: theme.textTheme.bodySmall
          ?.copyWith(color: color, fontWeight: FontWeight.w700),
    );
  }
}

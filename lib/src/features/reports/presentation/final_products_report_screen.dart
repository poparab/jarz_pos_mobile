import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../state/reports_providers.dart';

class FinalProductsReportScreen extends ConsumerWidget {
  const FinalProductsReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(finalProductsReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsFinalProducts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(finalProductsReportProvider),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(finalProductsReportProvider),
                  child: Text(l10n.reportsRetry),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final warehouses = List<String>.from(data['warehouses'] ?? []);
          final items = List<Map<String, dynamic>>.from(
            (data['items'] as List? ?? []).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          );

          if (items.isEmpty) {
            return Center(child: Text(l10n.reportsNoData));
          }

          return _FinalProductsTable(
            warehouses: warehouses,
            items: items,
          );
        },
      ),
    );
  }
}

class _FinalProductsTable extends StatelessWidget {
  final List<String> warehouses;
  final List<Map<String, dynamic>> items;

  const _FinalProductsTable({
    required this.warehouses,
    required this.items,
  });

  String _shortWarehouse(String warehouse) {
    // Strip " - <company>" suffix for compact display
    final dashIdx = warehouse.lastIndexOf(' - ');
    return dashIdx > 0 ? warehouse.substring(0, dashIdx) : warehouse;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final cellStyle = theme.textTheme.bodySmall;
    final totalStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
            headingRowHeight: 48,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 48,
            border: TableBorder.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
            columns: [
              DataColumn(
                label: Text(l10n.reportsItemName, style: headerStyle),
              ),
              DataColumn(
                label: Text(l10n.reportsItemGroup, style: headerStyle),
              ),
              ...warehouses.map(
                (wh) => DataColumn(
                  label: Text(_shortWarehouse(wh), style: headerStyle),
                  numeric: true,
                ),
              ),
              DataColumn(
                label: Text(l10n.reportsTotal, style: headerStyle),
                numeric: true,
              ),
            ],
            rows: items.map((item) {
              final whQty = Map<String, dynamic>.from(
                item['warehouse_qty'] as Map? ?? {},
              );
              final total = (item['total_qty'] as num?)?.toDouble() ?? 0;

              return DataRow(cells: [
                DataCell(Text(
                  item['item_name']?.toString() ?? '',
                  style: cellStyle,
                )),
                DataCell(Text(
                  item['item_group']?.toString() ?? '',
                  style: cellStyle,
                )),
                ...warehouses.map((wh) {
                  final qty = (whQty[wh] as num?)?.toDouble() ?? 0;
                  return DataCell(Text(
                    qty > 0 ? _formatQty(qty) : '-',
                    style: cellStyle,
                  ));
                }),
                DataCell(Text(
                  _formatQty(total),
                  style: totalStyle,
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _formatQty(double qty) {
    return qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
  }
}

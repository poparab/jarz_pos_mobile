import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../core/localization/localization_extensions.dart';
import '../state/reports_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (_tabController.index == 0) {
      ref.invalidate(finalProductsReportProvider);
    } else {
      ref.invalidate(materialsReportProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.reportsFinalProducts),
            Tab(text: l10n.reportsMaterials),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FinalProductsTab(),
          _MaterialsTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Final Products ──────────────────────────────────────────────

class _FinalProductsTab extends ConsumerWidget {
  const _FinalProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(finalProductsReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorBody(
        error: error.toString(),
        onRetry: () => ref.invalidate(finalProductsReportProvider),
      ),
      data: (data) {
        final groups = List<Map<String, dynamic>>.from(
          (data['groups'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
        if (groups.isEmpty) return Center(child: Text(l10n.reportsNoData));
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final groupName = group['group_name']?.toString() ?? '';
            final warehouses = List<String>.from(group['warehouses'] ?? []);
            final items = List<Map<String, dynamic>>.from(
              (group['items'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map)),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: 16),
                _SectionHeader(title: groupName, count: items.length),
                const SizedBox(height: 6),
                _FinalProductsTable(warehouses: warehouses, items: items),
              ],
            );
          },
        );
      },
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

// ── Tab 2: Materials & Consumables ─────────────────────────────────────

class _MaterialsTab extends ConsumerWidget {
  const _MaterialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(materialsReportProvider);

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorBody(
        error: error.toString(),
        onRetry: () => ref.invalidate(materialsReportProvider),
      ),
      data: (data) {
        final rawMaterials = _parseItems(data['raw_materials']);
        final subAssemblies = _parseItems(data['sub_assemblies']);
        final consumables = _parseItems(data['consumables']);

        if (rawMaterials.isEmpty &&
            subAssemblies.isEmpty &&
            consumables.isEmpty) {
          return Center(child: Text(l10n.reportsNoData));
        }

        return _MaterialsBody(
          rawMaterials: rawMaterials,
          subAssemblies: subAssemblies,
          consumables: consumables,
        );
      },
    );
  }

  List<Map<String, dynamic>> _parseItems(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}

class _MaterialsBody extends StatelessWidget {
  final List<Map<String, dynamic>> rawMaterials;
  final List<Map<String, dynamic>> subAssemblies;
  final List<Map<String, dynamic>> consumables;

  const _MaterialsBody({
    required this.rawMaterials,
    required this.subAssemblies,
    required this.consumables,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        if (rawMaterials.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.reportsRawMaterials,
            count: rawMaterials.length,
          ),
          const SizedBox(height: 6),
          _CompactItemGrid(items: rawMaterials),
          const SizedBox(height: 16),
        ],
        if (subAssemblies.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.reportsSubAssemblies,
            count: subAssemblies.length,
          ),
          const SizedBox(height: 6),
          _CompactItemGrid(items: subAssemblies),
          const SizedBox(height: 16),
        ],
        if (consumables.isNotEmpty)
          _CollapsibleSection(
            title: l10n.reportsConsumables,
            itemCount: consumables.length,
            initiallyExpanded: false,
            child: _CompactItemGrid(items: consumables),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        _CountBadge(count: count),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool initiallyExpanded;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.itemCount,
    required this.initiallyExpanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          _CountBadge(count: itemCount),
        ],
      ),
      children: [child],
    );
  }
}

/// Compact grid: 2 items per row showing name, qty badge, and warehouse lines.
class _CompactItemGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _CompactItemGrid({required this.items});

  String _formatQty(double qty) {
    return qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
  }

  String _shortWarehouse(String warehouse) {
    final dashIdx = warehouse.lastIndexOf(' - ');
    return dashIdx > 0 ? warehouse.substring(0, dashIdx) : warehouse;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = 4;
      final cardWidth = (constraints.maxWidth - 8 * (crossCount - 1)) / crossCount;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final itemName = item['item_name']?.toString() ?? '';
          final stockUom = item['stock_uom']?.toString() ?? '';
          final totalQty = (item['total_qty'] as num?)?.toDouble() ?? 0;
          final whQty = Map<String, dynamic>.from(
            item['warehouse_qty'] as Map? ?? {},
          );

          return SizedBox(
            width: cardWidth,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itemName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_formatQty(totalQty)} $stockUom',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    if (whQty.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...whQty.entries.map((e) {
                        final qty = (e.value as num?)?.toDouble() ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            '${_shortWarehouse(e.key)}: ${_formatQty(qty)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.reportsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

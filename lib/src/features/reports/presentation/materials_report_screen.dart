import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../state/reports_providers.dart';

class MaterialsReportScreen extends ConsumerWidget {
  const MaterialsReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(materialsReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsMaterials),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(materialsReportProvider),
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
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(materialsReportProvider),
                  child: Text(l10n.reportsRetry),
                ),
              ],
            ),
          ),
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

          return _MaterialsReportBody(
            rawMaterials: rawMaterials,
            subAssemblies: subAssemblies,
            consumables: consumables,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _parseItems(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}

class _MaterialsReportBody extends StatelessWidget {
  final List<Map<String, dynamic>> rawMaterials;
  final List<Map<String, dynamic>> subAssemblies;
  final List<Map<String, dynamic>> consumables;

  const _MaterialsReportBody({
    required this.rawMaterials,
    required this.subAssemblies,
    required this.consumables,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (rawMaterials.isNotEmpty) ...[
          _SectionHeader(title: l10n.reportsRawMaterials),
          const SizedBox(height: 8),
          ...rawMaterials.map((item) => _MaterialItemCard(item: item)),
          const SizedBox(height: 24),
        ],
        if (subAssemblies.isNotEmpty) ...[
          _SectionHeader(title: l10n.reportsSubAssemblies),
          const SizedBox(height: 8),
          ...subAssemblies.map((item) => _MaterialItemCard(item: item)),
          const SizedBox(height: 24),
        ],
        if (consumables.isNotEmpty)
          _CollapsibleSection(
            title: l10n.reportsConsumables,
            itemCount: consumables.length,
            initiallyExpanded: false,
            children: consumables
                .map((item) => _MaterialItemCard(item: item))
                .toList(),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final int itemCount;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _CollapsibleSection({
    required this.title,
    required this.itemCount,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$itemCount',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
      children: children,
    );
  }
}

class _MaterialItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MaterialItemCard({required this.item});

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
    final itemName = item['item_name']?.toString() ?? '';
    final stockUom = item['stock_uom']?.toString() ?? '';
    final totalQty = (item['total_qty'] as num?)?.toDouble() ?? 0;
    final whQty = Map<String, dynamic>.from(
      item['warehouse_qty'] as Map? ?? {},
    );

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
                    itemName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_formatQty(totalQty)} $stockUom',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (whQty.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: whQty.entries.map((e) {
                  final qty = (e.value as num?)?.toDouble() ?? 0;
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '${_shortWarehouse(e.key)}: ${_formatQty(qty)}',
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

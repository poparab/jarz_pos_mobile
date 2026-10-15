import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/models/report_envelopes.dart';
import '../../data/models/report_json.dart';
import '../../state/reports_providers.dart';
import '../widgets/report_branch_selector.dart';
import '../widgets/report_states.dart';

/// The stock-count reports (Final Products + Materials & Consumables), per
/// branch, with stock values and group / grand totals. [initialTab] is 0 for
/// Final Products, 1 for Materials.
///
/// [singleReport] shows only the [initialTab] report, with no tab bar and no
/// swiping, for the role-gated `/reports/final-products` and
/// `/reports/materials` routes (a materials-only user must not reach the
/// Final Products tab). The two-tab mode is offered only to users who may see
/// both reports; anyone else gets the single Materials report.
class StockReportsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final bool singleReport;
  const StockReportsScreen({
    super.key,
    this.initialTab = 0,
    this.singleReport = false,
  });

  @override
  ConsumerState<StockReportsScreen> createState() => _StockReportsScreenState();
}

class _StockReportsScreenState extends ConsumerState<StockReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh(int tab, String? branch) {
    if (tab == 0) {
      ref.invalidate(finalProductsReportProvider(branch));
    } else {
      ref.invalidate(materialsReportProvider(branch));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final branch = ref.watch(reportBranchProvider);
    final roles = ref.watch(userRolesFutureProvider).valueOrNull;
    final canSeeBoth = roles?.canViewAllReports ?? false;

    final single = widget.singleReport || !canSeeBoth;
    if (single) {
      // Outside the explicit single-report routes, a user who cannot see
      // Final Products only ever gets Materials.
      final tab = widget.singleReport || canSeeBoth
          ? widget.initialTab.clamp(0, 1)
          : 1;
      final finalProducts = tab == 0;
      return Scaffold(
        appBar: AppBar(
          title: Text(
            finalProducts ? l10n.reportsFinalProducts : l10n.reportsMaterials,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.rptG2Refresh,
              onPressed: () => _refresh(tab, branch),
            ),
          ],
        ),
        body: _WithBranch(
          child: finalProducts
              ? _FinalProductsTab(branch: branch)
              : _MaterialsTab(branch: branch),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.rptG2Refresh,
            onPressed: () => _refresh(_tabController.index, branch),
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
      body: _WithBranch(
        child: TabBarView(
          controller: _tabController,
          children: [
            _FinalProductsTab(branch: branch),
            _MaterialsTab(branch: branch),
          ],
        ),
      ),
    );
  }
}

/// The branch selector above a report body.
class _WithBranch extends StatelessWidget {
  final Widget child;
  const _WithBranch({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
          child: ReportBranchSelector(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ── Totals strip ───────────────────────────────────────────────────────

/// "Total qty: N  •  Stock value: X" for a group or the whole report.
class _TotalsLine extends StatelessWidget {
  final StockReportTotals totals;

  const _TotalsLine({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final parts = [
      '${l10n.rptG2TotalQty}: ${_formatQty(context, totals.qty)}',
      '${l10n.rptG2StockValue}: ${formatCurrency(context, totals.stockValue)}',
    ];
    return Text(parts.join('  •  '), style: style);
  }
}

class _GrandTotalCard extends StatelessWidget {
  final StockReportTotals totals;
  const _GrandTotalCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.rptG2GrandTotal,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(context, totals.stockValue),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.rptG2TotalQty, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  _formatQty(context, totals.qty),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Totals are only shown when the server sent them (older servers did not).
StockReportTotals? _totalsOrNull(Object? v) =>
    v is Map ? StockReportTotals.fromJson(v) : null;

// ── Tab 1: Final Products ──────────────────────────────────────────────

class _FinalProductsTab extends ConsumerWidget {
  final String? branch;
  const _FinalProductsTab({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(finalProductsReportProvider(branch));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(finalProductsReportProvider(branch).future),
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ReportErrorView(
          error: error,
          onRetry: () => ref.invalidate(finalProductsReportProvider(branch)),
        ),
        data: (data) {
          final groups = ReportJson.list(data['groups']);
          if (groups.isEmpty) {
            return ReportEmptyView(message: l10n.reportsNoData);
          }
          final grand = _totalsOrNull(data['totals']);
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.all(8),
            itemCount: groups.length + (grand == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (grand != null && index == 0) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: _GrandTotalCard(totals: grand),
                );
              }
              final group = groups[index - (grand == null ? 0 : 1)];
              final groupName = ReportJson.str(group['group_name']);
              final warehouses = ReportJson.strings(group['warehouses']);
              final items = ReportJson.list(group['items']);
              final totals = _totalsOrNull(group['totals']);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  _SectionHeader(title: groupName, count: items.length),
                  if (totals != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 2),
                      child: _TotalsLine(totals: totals),
                    ),
                  const SizedBox(height: 6),
                  _FinalProductsTable(warehouses: warehouses, items: items),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FinalProductsTable extends StatelessWidget {
  final List<String> warehouses;
  final List<JsonMap> items;

  const _FinalProductsTable({
    required this.warehouses,
    required this.items,
  });

  double _resolveItemColumnWidth({
    required double tableWidth,
    required int metricColumnCount,
  }) {
    if (metricColumnCount == 0) return tableWidth;

    final preferredWidth = tableWidth * 0.34;
    final compactWidth = tableWidth * 0.24;
    final maxWidthWhileKeepingMetricsReadable =
        tableWidth - (metricColumnCount * 44.0);

    if (maxWidthWhileKeepingMetricsReadable >= preferredWidth) {
      return preferredWidth;
    }

    return maxWidthWhileKeepingMetricsReadable > compactWidth
        ? maxWidthWhileKeepingMetricsReadable
        : compactWidth;
  }

  Widget _buildHeaderCell({
    required String text,
    required double width,
    required TextStyle? style,
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      width: width,
      child: Tooltip(
        message: text,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            text,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }

  Widget _buildTextCell({
    required String text,
    required double width,
    required TextStyle? style,
  }) {
    return SizedBox(
      width: width,
      child: Tooltip(
        message: text,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              text,
              style: style,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericCell({
    required String text,
    required double width,
    required TextStyle? style,
    String? tooltip,
  }) {
    return SizedBox(
      width: width,
      child: Tooltip(
        message: tooltip ?? text,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 8),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                text,
                style: style,
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final headerStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final cellStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final totalStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final negativeStyle = cellStyle?.copyWith(color: theme.colorScheme.error);
    final negativeTotalStyle =
        totalStyle?.copyWith(color: theme.colorScheme.error);
    // Stock value is a newer key; only add the column when the server sends it.
    final hasValue = items.any((i) => i.containsKey('stock_value'));

    return LayoutBuilder(builder: (context, constraints) {
      final viewportWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final rawTableWidth = viewportWidth - 16;
      final tableWidth = rawTableWidth > 240 ? rawTableWidth : 240.0;
      final metricColumnCount = warehouses.length + 1 + (hasValue ? 1 : 0);
      final itemColWidth = _resolveItemColumnWidth(
        tableWidth: tableWidth,
        metricColumnCount: metricColumnCount,
      );
      final dataColWidth = metricColumnCount == 0
          ? 0.0
          : (tableWidth - itemColWidth) / metricColumnCount;

      return Padding(
        padding: const EdgeInsetsDirectional.all(8),
        child: SizedBox(
          width: tableWidth,
          child: DataTable(
            columnSpacing: 0,
            horizontalMargin: 0,
            headingRowHeight: 48,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 48,
            border: TableBorder.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
            columns: [
              DataColumn(
                label: _buildHeaderCell(
                  text: l10n.reportsItemName,
                  width: itemColWidth,
                  style: headerStyle,
                ),
              ),
              ...warehouses.map(
                (wh) => DataColumn(
                  label: _buildHeaderCell(
                    text: _shortWarehouse(wh),
                    width: dataColWidth,
                    style: headerStyle,
                    textAlign: TextAlign.end,
                  ),
                  numeric: true,
                ),
              ),
              DataColumn(
                label: _buildHeaderCell(
                  text: l10n.reportsTotal,
                  width: dataColWidth,
                  style: headerStyle,
                  textAlign: TextAlign.end,
                ),
                numeric: true,
              ),
              if (hasValue)
                DataColumn(
                  label: _buildHeaderCell(
                    text: l10n.rptG2StockValue,
                    width: dataColWidth,
                    style: headerStyle,
                    textAlign: TextAlign.end,
                  ),
                  numeric: true,
                ),
            ],
            rows: items.map((item) {
              final whQty = ReportJson.map(item['warehouse_qty']);
              final total = ReportJson.dbl(item['total_qty']);
              final itemName = ReportJson.str(item['item_name']);
              final value = ReportJson.dbl(item['stock_value']);

              return DataRow(cells: [
                DataCell(_buildTextCell(
                  text: itemName,
                  width: itemColWidth,
                  style: cellStyle,
                )),
                ...warehouses.map((wh) {
                  final qty = ReportJson.dbl(whQty[wh]);
                  // A negative bin is stock the branch has oversold. It used to
                  // collapse to the same '-' as an empty cell, which is the one
                  // reading that hides it.
                  final formattedQty =
                      qty != 0 ? _formatQty(context, qty) : '-';
                  return DataCell(_buildNumericCell(
                    text: formattedQty,
                    width: dataColWidth,
                    style: qty < 0 ? negativeStyle : cellStyle,
                    tooltip: '${_shortWarehouse(wh)}: $formattedQty',
                  ));
                }),
                DataCell(_buildNumericCell(
                  text: _formatQty(context, total),
                  width: dataColWidth,
                  style: total < 0 ? negativeTotalStyle : totalStyle,
                  tooltip:
                      '${l10n.reportsTotal}: ${_formatQty(context, total)}',
                )),
                if (hasValue)
                  DataCell(_buildNumericCell(
                    text: formatCompactCurrency(context, value),
                    width: dataColWidth,
                    style: value < 0 ? negativeStyle : cellStyle,
                    tooltip:
                        '${l10n.rptG2StockValue}: ${formatCurrency(context, value)}',
                  )),
              ]);
            }).toList(),
          ),
        ),
      );
    });
  }
}

// ── Tab 2: Materials & Consumables ─────────────────────────────────────

class _MaterialsTab extends ConsumerWidget {
  final String? branch;
  const _MaterialsTab({required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(materialsReportProvider(branch));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(materialsReportProvider(branch).future),
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ReportErrorView(
          error: error,
          onRetry: () => ref.invalidate(materialsReportProvider(branch)),
        ),
        data: (data) {
          final rawMaterials = ReportJson.list(data['raw_materials']);
          final subAssemblies = ReportJson.list(data['sub_assemblies']);
          final consumables = ReportJson.list(data['consumables']);

          if (rawMaterials.isEmpty &&
              subAssemblies.isEmpty &&
              consumables.isEmpty) {
            return ReportEmptyView(message: l10n.reportsNoData);
          }

          final buckets = ReportJson.map(data['bucket_totals']);
          return _MaterialsBody(
            rawMaterials: rawMaterials,
            subAssemblies: subAssemblies,
            consumables: consumables,
            grandTotals: _totalsOrNull(data['totals']),
            rawTotals: _totalsOrNull(buckets['raw_materials']),
            subTotals: _totalsOrNull(buckets['sub_assemblies']),
            consumableTotals: _totalsOrNull(buckets['consumables']),
          );
        },
      ),
    );
  }
}

class _MaterialsBody extends StatelessWidget {
  final List<JsonMap> rawMaterials;
  final List<JsonMap> subAssemblies;
  final List<JsonMap> consumables;
  final StockReportTotals? grandTotals;
  final StockReportTotals? rawTotals;
  final StockReportTotals? subTotals;
  final StockReportTotals? consumableTotals;

  const _MaterialsBody({
    required this.rawMaterials,
    required this.subAssemblies,
    required this.consumables,
    this.grandTotals,
    this.rawTotals,
    this.subTotals,
    this.consumableTotals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      children: [
        if (grandTotals != null) ...[
          _GrandTotalCard(totals: grandTotals!),
          const SizedBox(height: 12),
        ],
        if (rawMaterials.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.reportsRawMaterials,
            count: rawMaterials.length,
          ),
          if (rawTotals != null) _TotalsLine(totals: rawTotals!),
          const SizedBox(height: 6),
          _CompactItemGrid(items: rawMaterials),
          const SizedBox(height: 16),
        ],
        if (subAssemblies.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.reportsSubAssemblies,
            count: subAssemblies.length,
          ),
          if (subTotals != null) _TotalsLine(totals: subTotals!),
          const SizedBox(height: 6),
          _CompactItemGrid(items: subAssemblies),
          const SizedBox(height: 16),
        ],
        if (consumables.isNotEmpty)
          _CollapsibleSection(
            title: l10n.reportsConsumables,
            itemCount: consumables.length,
            initiallyExpanded: false,
            totals: consumableTotals,
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
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
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
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        formatCount(context, count),
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
  final StockReportTotals? totals;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.itemCount,
    required this.initiallyExpanded,
    required this.child,
    this.totals,
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
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CountBadge(count: itemCount),
        ],
      ),
      subtitle: totals == null ? null : _TotalsLine(totals: totals!),
      children: [child],
    );
  }
}

/// Compact grid: 2 items per row showing name, qty badge, value and
/// warehouse lines.
class _CompactItemGrid extends StatelessWidget {
  final List<JsonMap> items;
  const _CompactItemGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = ResponsiveUtils.getGridColumns(context, min: 2, max: 4);
      final cardWidth = (constraints.maxWidth - 8 * (crossCount - 1)) / crossCount;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final itemName = ReportJson.str(item['item_name']);
          final stockUom = ReportJson.str(item['stock_uom']);
          final totalQty = ReportJson.dbl(item['total_qty']);
          final value = ReportJson.dblOrNull(item['stock_value']);
          final whQty = ReportJson.map(item['warehouse_qty']);

          return SizedBox(
            width: cardWidth,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsetsDirectional.all(8),
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
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_formatQty(context, totalQty)} $stockUom',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          // An oversold material reaches this card, so it has
                          // to read as a problem rather than as a small number.
                          color: totalQty < 0
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    if (value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.rptG2StockValue}: '
                        '${formatCurrency(context, value)}',
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (whQty.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...whQty.entries.map((e) {
                        final qty = ReportJson.dbl(e.value);
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(top: 1),
                          child: Text(
                            '${_shortWarehouse(e.key)}: '
                            '${_formatQty(context, qty)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: qty < 0
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
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

String _shortWarehouse(String warehouse) {
  final dashIdx = warehouse.lastIndexOf(' - ');
  return dashIdx > 0 ? warehouse.substring(0, dashIdx) : warehouse;
}

/// Quantities with up to two decimals, grouped, in the app's locale.
String _formatQty(BuildContext context, double qty) =>
    NumberFormat('#,##0.##', context.l10n.localeName).format(qty);

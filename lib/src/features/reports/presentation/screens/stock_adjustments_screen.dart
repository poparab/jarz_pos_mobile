import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/business_reports.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_chart_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Waste & stock adjustments (`business_reports.get_stock_adjustments`):
/// stock counts and waste issues valued at their stock value difference.
/// Values are signed — negative is stock lost (shown red), positive is stock
/// found. Branch = the POS Profile's warehouse.
class StockAdjustmentsScreen extends ConsumerWidget {
  const StockAdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = l10n.rptStockAdjustmentsTitle;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(stockAdjustmentsProvider(q));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ReportExportButton(
            title: title,
            rows: () => _csvRows(context, async.valueOrNull),
          ),
        ],
      ),
      body: Column(
        children: [
          const ReportFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  _settle(ref.refresh(stockAdjustmentsProvider(q).future)),
              child: async.when(
                skipLoadingOnRefresh: true,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(stockAdjustmentsProvider(q)),
                ),
                data: (d) => d.isEmpty
                    ? const ReportEmptyView(icon: Icons.inventory_2_outlined)
                    : _Body(data: d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

Future<void> _settle(Future<Object?> reload) async {
  try {
    await reload;
  } catch (_) {}
}

String _csvNum(double v) => v.toStringAsFixed(2);

String _qty(BuildContext context, double v) =>
    NumberFormat.decimalPatternDigits(
      locale: context.l10n.localeName,
      decimalDigits: v == v.truncateToDouble() ? 0 : 2,
    ).format(v);

/// Signed money: a leading `+` on gains so the sign is never ambiguous.
String _signed(BuildContext context, double v) =>
    v > 0 ? '+${formatCurrency(context, v)}' : formatCurrency(context, v);

Color? _valueColor(BuildContext context, double v) {
  if (v < 0) return Theme.of(context).colorScheme.error;
  if (v > 0) return Colors.green.shade700;
  return null;
}

String _typeLabel(BuildContext context, String type) {
  final l10n = context.l10n;
  return switch (type.trim()) {
    'Stock Reconciliation' => l10n.rptWasteTypeStockReconciliation,
    'Material Issue' => l10n.rptWasteTypeMaterialIssue,
    'Material Receipt' => l10n.rptWasteTypeMaterialReceipt,
    'Stock Entry' => l10n.rptWasteTypeStockEntry,
    '' => '—',
    final other => other,
  };
}

String _dateLabel(BuildContext context, StockAdjustmentEntry e) {
  final d = e.postingDay;
  if (d == null) return e.postingDate;
  return DateFormat.yMMMd(context.l10n.localeName).format(d);
}

const _palette = <Color>[
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFFFB8C00),
  Color(0xFF43A047),
  Color(0xFF8E24AA),
  Color(0xFF00897B),
  Color(0xFF6D4C41),
  Color(0xFF546E7A),
];

List<List<String>> _csvRows(BuildContext context, StockAdjustments? d) {
  if (d == null) return const [];
  final l10n = context.l10n;
  return [
    [
      l10n.rptWasteDate,
      l10n.rptWasteType,
      l10n.rptWasteVoucher,
      l10n.rptWasteWarehouse,
      l10n.rptWasteItemCode,
      l10n.rptWasteQty,
      l10n.rptWasteValue,
      l10n.rptWasteRemarks,
    ],
    for (final e in d.entries)
      [
        e.postingDate,
        e.voucherType,
        e.voucherNo,
        e.warehouse,
        e.itemCode,
        e.qty.toString(),
        _csvNum(e.value),
        e.remarks,
      ],
  ];
}

// ── Body ──────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final StockAdjustments data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 900;
        final byType = _ByTypeCard(rows: data.byType);
        final byBranch = _ByBranchCard(rows: data.byBranch);
        final items = _WorstItemsCard(rows: data.byItem);
        final entries = _EntriesCard(rows: data.entries, wide: width >= 700);

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              child: _KpiGrid(totals: data.totals),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
              child: Text(
                context.l10n.rptWasteSignHint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            if (wide) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(8),
                      child: byType,
                    ),
                  ),
                  Expanded(child: byBranch),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: items),
                  Expanded(flex: 3, child: entries),
                ],
              ),
            ] else ...[
              if (data.byType.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.all(8),
                  child: byType,
                ),
              if (data.byBranch.isNotEmpty) byBranch,
              items,
              entries,
            ],
          ],
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final StockAdjustmentsTotals totals;
  const _KpiGrid({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tiles = [
      KpiCard(
        label: l10n.rptWasteLoss,
        value: formatCurrency(context, totals.lossValue),
        icon: Icons.trending_down,
        color: theme.colorScheme.error,
      ),
      KpiCard(
        label: l10n.rptWasteGain,
        value: formatCurrency(context, totals.gainValue),
        icon: Icons.trending_up,
        color: Colors.green.shade700,
      ),
      KpiCard(
        label: l10n.rptWasteNet,
        value: _signed(context, totals.netValue),
        icon: Icons.balance_outlined,
        color: _valueColor(context, totals.netValue),
      ),
      KpiCard(
        label: l10n.rptWasteEntriesCount,
        value: formatCount(context, totals.entries),
        icon: Icons.receipt_long_outlined,
        color: theme.colorScheme.tertiary,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 600 ? 4 : 2;
        const spacing = 8.0;
        final cardWidth = (w - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in tiles) SizedBox(width: cardWidth, child: t),
          ],
        );
      },
    );
  }
}

// ── By type (donut) ───────────────────────────────────────────────────────

class _ByTypeCard extends StatelessWidget {
  final List<StockAdjustmentType> rows;
  const _ByTypeCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = [...rows]
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final total = data.fold<double>(0, (s, e) => s + e.value.abs());

    return ReportChartCard(
      title: l10n.rptWasteByType,
      isEmpty: data.isEmpty || total <= 0,
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                pieTouchData: PieTouchData(enabled: false),
                sections: [
                  for (var i = 0; i < data.length; i++)
                    PieChartSectionData(
                      value: data[i].value.abs(),
                      color: _palette[i % _palette.length],
                      radius: 40,
                      title: total > 0 && data[i].value.abs() / total >= 0.08
                          ? NumberFormat.percentPattern(l10n.localeName)
                              .format(data[i].value.abs() / total)
                          : '',
                      titleStyle: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < data.length; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _palette[i % _palette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _typeLabel(context, data[i].type),
                                style: theme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_signed(context, data[i].value)} · '
                                '${formatCount(context, data[i].entries)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _valueColor(context, data[i].value),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── By branch (loss / gain bars) ──────────────────────────────────────────

class _ByBranchCard extends StatelessWidget {
  final List<StockAdjustmentBranch> rows;
  const _ByBranchCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final data = [...rows]..sort((a, b) => a.netValue.compareTo(b.netValue));
    final maxV = data.fold<double>(
      0,
      (m, b) => [m, b.lossValue, b.gainValue].reduce((x, y) => x > y ? x : y),
    );
    final red = theme.colorScheme.error;
    final green = Colors.green.shade600;

    Widget bar(double v, Color color) => LayoutBuilder(
          builder: (context, c) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              height: 8,
              width: maxV <= 0 ? 0 : (v / maxV * c.maxWidth).clamp(0.0, c.maxWidth),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );

    Widget legend(String text, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(text, style: theme.textTheme.labelSmall),
          ],
        );

    return ReportSectionCard(
      title: l10n.rptWasteByBranch,
      trailing: Wrap(
        spacing: 8,
        children: [legend(l10n.rptWasteLoss, red), legend(l10n.rptWasteGain, green)],
      ),
      child: data.isEmpty
          ? Text(l10n.reportNoData)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final b in data)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.displayName.isEmpty ? '—' : b.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              _signed(context, b.netValue),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _valueColor(context, b.netValue),
                              ),
                            ),
                          ],
                        ),
                        if (b.branch.isNotEmpty && b.warehouse.isNotEmpty)
                          Text(
                            b.warehouse,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 4),
                        bar(b.lossValue, red),
                        const SizedBox(height: 2),
                        bar(b.gainValue, green),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Worst items ───────────────────────────────────────────────────────────

class _WorstItemsCard extends StatelessWidget {
  final List<StockAdjustmentItem> rows;
  const _WorstItemsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReportSectionCard(
      title: l10n.rptWasteWorstItems,
      child: ReportTable(
        columns: [
          ReportColumn(l10n.rptWasteItem, flex: 4),
          ReportColumn(l10n.rptWasteQty, numeric: true, flex: 2),
          ReportColumn(l10n.rptWasteValue, numeric: true, flex: 3),
        ],
        rows: [
          for (final r in rows)
            [
              r.displayName,
              r.uom.isEmpty ? _qty(context, r.qty) : '${_qty(context, r.qty)} ${r.uom}',
              _signed(context, r.value),
            ],
        ],
        maxRows: 10,
        cellColor: (r, c) => c == 2 ? _valueColor(context, rows[r].value) : null,
      ),
    );
  }
}

// ── Entries + detail ──────────────────────────────────────────────────────

class _EntriesCard extends StatelessWidget {
  final List<StockAdjustmentEntry> rows;
  final bool wide;
  const _EntriesCard({required this.rows, required this.wide});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final columns = [
      ReportColumn(l10n.rptWasteDate, flex: 2),
      ReportColumn(l10n.rptWasteVoucher, flex: 3),
      ReportColumn(l10n.rptWasteItem, flex: 3),
      if (wide) ReportColumn(l10n.rptWasteQty, numeric: true, flex: 2),
      ReportColumn(l10n.rptWasteValue, numeric: true, flex: 3),
    ];
    final valueCol = columns.length - 1;
    return ReportSectionCard(
      title: l10n.rptWasteEntries,
      child: ReportTable(
        columns: columns,
        rows: [
          for (final e in rows)
            [
              _dateLabel(context, e),
              e.voucherNo,
              e.itemCode,
              if (wide) _qty(context, e.qty),
              _signed(context, e.value),
            ],
        ],
        maxRows: 25,
        cellColor: (r, c) =>
            c == valueCol ? _valueColor(context, rows[r].value) : null,
        onRowTap: (i) => _showEntryDetail(context, rows[i]),
      ),
    );
  }
}

void _showEntryDetail(BuildContext context, StockAdjustmentEntry e) {
  final l10n = context.l10n;
  final items = <(String, String, Color?)>[
    (l10n.rptWasteType, _typeLabel(context, e.voucherType), null),
    (l10n.rptWasteDate, _dateLabel(context, e), null),
    (l10n.rptWasteWarehouse, e.warehouse.isEmpty ? '—' : e.warehouse, null),
    (l10n.rptWasteItemCode, e.itemCode.isEmpty ? '—' : e.itemCode, null),
    (l10n.rptWasteQty, _qty(context, e.qty), null),
    (l10n.rptWasteValue, _signed(context, e.value), _valueColor(context, e.value)),
  ];
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(
                e.voucherNo,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final (label, value, color) in items)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(label, style: theme.textTheme.bodyMedium),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 2,
                        child: Text(
                          value,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (e.remarks.trim().isNotEmpty) ...[
                const Divider(height: 20),
                Text(l10n.rptWasteRemarks, style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(e.remarks.trim(), style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      );
    },
  );
}

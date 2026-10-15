import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/business_reports.dart';
import '../../state/reports_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_section_card.dart';
import '../widgets/report_states.dart';
import '../widgets/report_table.dart';

/// Promo code performance (`business_reports.get_promo_performance`):
/// discount cost against the orders, revenue, new customers and repeat
/// orders each code brought. Consumer (B2C) orders only — B2B supply orders
/// are excluded by the backend, and the screen says so.
class PromoPerformanceScreen extends ConsumerWidget {
  const PromoPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = l10n.rptPromoTitle;
    final q = ref.watch(reportQueryProvider);
    final async = ref.watch(promoPerformanceProvider(q));

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
                  _settle(ref.refresh(promoPerformanceProvider(q).future)),
              child: async.when(
                skipLoadingOnRefresh: true,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => ReportErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(promoPerformanceProvider(q)),
                ),
                data: (d) => (d.isEmpty && d.totals.ordersTotal == 0)
                    ? ReportEmptyView(
                        message: l10n.rptPromoNoCodes,
                        icon: Icons.local_offer_outlined,
                      )
                    : _PromoBody(data: d),
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

String _pct(BuildContext context, double v, {int digits = 1}) =>
    NumberFormat.decimalPercentPattern(
      locale: context.l10n.localeName,
      decimalDigits: digits,
    ).format(v / 100);

String _csvNum(double v) => v.toStringAsFixed(2);

/// Discount as a share of the revenue the coded orders brought; null when
/// there was no revenue.
double? _discountRate(double discount, double revenue) =>
    revenue > 0 ? discount / revenue * 100 : null;

List<List<String>> _csvRows(BuildContext context, PromoPerformance? d) {
  if (d == null) return const [];
  final l10n = context.l10n;
  return [
    [
      l10n.rptPromoCode,
      l10n.rptPromoOrders,
      l10n.rptPromoDiscount,
      l10n.rptPromoRevenueShort,
      l10n.rptPromoAovShort,
      l10n.rptPromoNew,
      l10n.rptPromoRepeatAfter,
      l10n.rptPromoDiscountRate,
    ],
    for (final c in d.codes)
      [
        c.code,
        '${c.orders}',
        _csvNum(c.discount),
        _csvNum(c.revenue),
        _csvNum(c.aov),
        '${c.newCustomers}',
        '${c.repeatAfter}',
        _discountRate(c.discount, c.revenue)?.toStringAsFixed(2) ?? '',
      ],
  ];
}

// ── Body ──────────────────────────────────────────────────────────────────

class _PromoBody extends StatelessWidget {
  final PromoPerformance data;
  const _PromoBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final codes = [...data.codes]
      ..sort((a, b) {
        final byOrders = b.orders.compareTo(a.orders);
        return byOrders != 0 ? byOrders : b.revenue.compareTo(a.revenue);
      });
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final chart = _CodesChartCard(codes: codes);
        final table = _CodesTableCard(
          codes: codes,
          showAllColumns: constraints.maxWidth >= 700,
        );
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
          children: [
            const _ScopeBanner(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              child: _KpiGrid(totals: data.totals),
            ),
            const SizedBox(height: 4),
            if (codes.isEmpty)
              ReportSectionCard(
                title: context.l10n.rptPromoCodesTitle,
                child: Text(context.l10n.rptPromoNoCodes),
              )
            else if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: chart),
                  Expanded(flex: 3, child: table),
                ],
              )
            else ...[
              chart,
              table,
            ],
          ],
        );
      },
    );
  }
}

class _ScopeBanner extends StatelessWidget {
  const _ScopeBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  context.l10n.rptPromoConsumerOnly,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final PromoPerformanceTotals totals;
  const _KpiGrid({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final aovDiff = totals.promoAov - totals.nonPromoAov;
    final rate = _discountRate(totals.discountTotal, totals.promoRevenue);
    final hasBothAov = totals.promoAov > 0 && totals.nonPromoAov > 0;

    final tiles = [
      KpiCard(
        label: l10n.rptPromoOrdersWithPromo,
        value: formatCount(context, totals.ordersWithPromo),
        icon: Icons.local_offer_outlined,
        delta: totals.ordersTotal > 0
            ? l10n.rptPromoShareOfOrders(
                _pct(context, totals.promoOrderSharePct),
                formatCount(context, totals.ordersTotal),
              )
            : null,
      ),
      KpiCard(
        label: l10n.rptPromoDiscountTotal,
        value: formatCurrency(context, totals.discountTotal),
        icon: Icons.money_off_outlined,
        color: theme.colorScheme.error,
        delta: rate == null
            ? null
            : '${l10n.rptPromoDiscountRate}: ${_pct(context, rate)}',
        deltaColor: theme.colorScheme.error,
      ),
      KpiCard(
        label: l10n.rptPromoRevenue,
        value: formatCurrency(context, totals.promoRevenue),
        icon: Icons.payments_outlined,
        color: Colors.green.shade700,
      ),
      KpiCard(
        label: l10n.rptPromoAov,
        value: formatCurrency(context, totals.promoAov),
        icon: Icons.shopping_cart_outlined,
        color: theme.colorScheme.secondary,
        delta: hasBothAov
            ? l10n.rptPromoAovDiff(
                '${aovDiff >= 0 ? '+' : ''}${formatCurrency(context, aovDiff)}',
              )
            : null,
        deltaColor: aovDiff >= 0 ? Colors.green.shade700 : theme.colorScheme.error,
      ),
      KpiCard(
        label: l10n.rptPromoNonPromoAov,
        value: formatCurrency(context, totals.nonPromoAov),
        icon: Icons.shopping_basket_outlined,
        color: theme.colorScheme.tertiary,
      ),
      KpiCard(
        label: l10n.rptPromoNewCustomers,
        value: formatCount(context, totals.newCustomersViaPromo),
        icon: Icons.person_add_alt_outlined,
        color: Colors.indigo.shade400,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1100 ? 6 : (w >= 600 ? 3 : 2);
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

// ── Chart: revenue vs discount per code ───────────────────────────────────

class _CodesChartCard extends StatelessWidget {
  final List<PromoCodeRow> codes;
  const _CodesChartCard({required this.codes});

  static const _topN = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final top = ([...codes]..sort((a, b) => b.revenue.compareTo(a.revenue)))
        .take(_topN)
        .toList();
    final maxV = top.fold<double>(
      0,
      (m, c) => [m, c.revenue, c.discount].reduce((a, b) => a > b ? a : b),
    );
    final revenueColor = Colors.green.shade600;
    final discountColor = theme.colorScheme.error;

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
      title: l10n.rptPromoChartTitle,
      trailing: Wrap(
        spacing: 8,
        children: [
          legend(l10n.rptPromoRevenueShort, revenueColor),
          legend(l10n.rptPromoDiscount, discountColor),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in top)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.code,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        formatCompactCurrency(context, c.revenue),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: revenueColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCompactCurrency(context, c.discount),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: discountColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  bar(c.revenue, revenueColor),
                  const SizedBox(height: 2),
                  bar(c.discount, discountColor),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Codes table + detail ──────────────────────────────────────────────────

class _CodesTableCard extends StatelessWidget {
  final List<PromoCodeRow> codes;
  final bool showAllColumns;
  const _CodesTableCard({required this.codes, required this.showAllColumns});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String money(double v) => showAllColumns
        ? formatCurrency(context, v)
        : formatCompactCurrency(context, v);

    final columns = [
      ReportColumn(l10n.rptPromoCode, flex: 3),
      ReportColumn(l10n.rptPromoOrders, numeric: true, flex: 2),
      ReportColumn(l10n.rptPromoDiscount, numeric: true, flex: 3),
      ReportColumn(l10n.rptPromoRevenueShort, numeric: true, flex: 3),
      if (showAllColumns) ...[
        ReportColumn(l10n.rptPromoAovShort, numeric: true, flex: 3),
        ReportColumn(l10n.rptPromoNew, numeric: true, flex: 2),
        ReportColumn(l10n.rptPromoRepeatAfter, numeric: true, flex: 2),
      ],
    ];
    final rows = [
      for (final c in codes)
        [
          c.code,
          formatCount(context, c.orders),
          money(c.discount),
          money(c.revenue),
          if (showAllColumns) ...[
            money(c.aov),
            formatCount(context, c.newCustomers),
            formatCount(context, c.repeatAfter),
          ],
        ],
    ];

    return ReportSectionCard(
      title: l10n.rptPromoCodesTitle,
      subtitle: l10n.rptPromoConsumerOnly,
      child: ReportTable(
        columns: columns,
        rows: rows,
        maxRows: 15,
        cellColor: (r, c) =>
            c == 2 ? Theme.of(context).colorScheme.error : null,
        onRowTap: (i) => _showCodeDetail(context, codes[i]),
      ),
    );
  }
}

void _showCodeDetail(BuildContext context, PromoCodeRow c) {
  final l10n = context.l10n;
  final rate = _discountRate(c.discount, c.revenue);
  final items = <(String, String, String?)>[
    (l10n.rptPromoOrders, formatCount(context, c.orders), null),
    (l10n.rptPromoDiscount, formatCurrency(context, c.discount), null),
    (l10n.rptPromoRevenueShort, formatCurrency(context, c.revenue), null),
    (l10n.rptPromoAovShort, formatCurrency(context, c.aov), null),
    if (rate != null) (l10n.rptPromoDiscountRate, _pct(context, rate), null),
    (l10n.rptPromoNew, formatCount(context, c.newCustomers), null),
    (
      l10n.rptPromoRepeatAfter,
      formatCount(context, c.repeatAfter),
      l10n.rptPromoRepeatAfterHelp,
    ),
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
              Row(
                children: [
                  Icon(Icons.local_offer_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.code,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final (label, value, help) in items)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: theme.textTheme.bodyMedium),
                            if (help != null)
                              Text(
                                help,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

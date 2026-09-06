import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/network/user_service.dart';
import '../../data/models/report_json.dart';
import '../../data/models/velocity_alerts.dart';
import '../../data/velocity_alerts_repository.dart';
import '../../state/velocity_alerts_providers.dart';
import '../widgets/kpi_card.dart';

/// Reorder & Velocity Alerts dashboard: the weekly sales-velocity job's
/// current critical / watch / slow-mover / overstock buckets, an item-level
/// velocity detail on tap, and a manager-tier manual recalculation trigger.
///
/// Read-only otherwise. Consumes [velocityAlertSummaryProvider]; gated on the
/// Reports hub by `UserRoles.canViewAllReports` (mirrors the backend's
/// `frappe.only_for("JARZ Manager")` on every `api/forecasting.py` endpoint).
class VelocityAlertsScreen extends ConsumerWidget {
  const VelocityAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(velocityAlertSummaryProvider);
    final roles = ref.watch(userRolesFutureProvider).valueOrNull;
    final canRecalculate = roles?.canViewAllReports ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.velocityReportTitle),
        actions: [
          if (canRecalculate)
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: l10n.velocityReportRecalculateAction,
              onPressed: () => _confirmAndRecalculate(context, ref),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(velocityAlertSummaryProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(velocityAlertSummaryProvider);
            await ref.read(velocityAlertSummaryProvider.future);
          },
          child: _Body(data: data),
        ),
      ),
    );
  }

  Future<void> _confirmAndRecalculate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.velocityReportRecalculateConfirmTitle),
        content: Text(l10n.velocityReportRecalculateConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.velocityReportRecalculateAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(velocityAlertsRepositoryProvider);
      final count = await repo.runVelocityUpdateNow();
      ref.invalidate(velocityAlertSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.velocityReportRecalculateSuccess(count)),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.velocityReportRecalculateError)),
      );
    }
  }
}

// ── Body ─────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final VelocityAlertSummary data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _KpiWrap(cards: [
          KpiCard(
            label: l10n.velocityReportSummaryCritical,
            value: '${data.critical.length}',
            icon: Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          KpiCard(
            label: l10n.velocityReportSummaryWatch,
            value: '${data.watchList.length}',
            icon: Icons.visibility_outlined,
            color: Colors.amber.shade800,
          ),
          KpiCard(
            label: l10n.velocityReportSummarySlow,
            value: '${data.slowMovers.length}',
            icon: Icons.trending_down,
            color: Colors.blueGrey,
          ),
          KpiCard(
            label: l10n.velocityReportSummaryOverstock,
            value: '${data.overstocked.length}',
            icon: Icons.warehouse_outlined,
            color: Colors.indigo,
          ),
        ]),
        const SizedBox(height: 12),
        _AlertSection(
          title: l10n.velocityReportSummaryCritical,
          icon: Icons.error_outline,
          color: theme.colorScheme.error,
          rows: data.critical,
          trailingBuilder: (r) => _daysBadge(context, r, theme.colorScheme.error),
        ),
        const SizedBox(height: 12),
        _AlertSection(
          title: l10n.velocityReportSummaryWatch,
          icon: Icons.visibility_outlined,
          color: Colors.amber.shade800,
          rows: data.watchList,
          trailingBuilder: (r) => _daysBadge(context, r, Colors.amber.shade800),
        ),
        const SizedBox(height: 12),
        _AlertSection(
          title: l10n.velocityReportSummarySlow,
          icon: Icons.trending_down,
          color: Colors.blueGrey,
          rows: data.slowMovers,
          trailingBuilder: (r) => Text(
            localizedVelocityTrend(context, _text(r, const ['trend'])),
            style: theme.textTheme.labelSmall,
          ),
        ),
        const SizedBox(height: 12),
        _AlertSection(
          title: l10n.velocityReportSummaryOverstock,
          icon: Icons.warehouse_outlined,
          color: Colors.indigo,
          rows: data.overstocked,
          trailingBuilder: (r) => _daysBadge(context, r, Colors.indigo),
        ),
      ],
    );
  }

  Widget _daysBadge(BuildContext context, JsonMap r, Color color) {
    final days = _text(r, const ['days_remaining']);
    if (days.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        days,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _KpiWrap extends StatelessWidget {
  final List<Widget> cards;
  const _KpiWrap({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final crossCount = maxW >= 700 ? 4 : 2;
      const spacing = 8.0;
      final cardWidth = (maxW - spacing * (crossCount - 1)) / crossCount;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final c in cards) SizedBox(width: cardWidth, child: c),
        ],
      );
    });
  }
}

// ── Alert section (tappable rows → item velocity detail) ───────────────────

class _AlertSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<JsonMap> rows;
  final Widget Function(JsonMap row) trailingBuilder;

  const _AlertSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.rows,
    required this.trailingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${rows.length}',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(
                  l10n.reportsNoData,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
            else
              for (final row in rows)
                _AlertRow(row: row, trailing: trailingBuilder(row)),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final JsonMap row;
  final Widget trailing;
  const _AlertRow({required this.row, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCode = _text(row, const ['item_code']);
    final itemName = _text(row, const ['item_name', 'item_code'], fallback: '—');
    final group = _text(row, const ['item_group']);
    final stock = _text(row, const ['stock_on_hand']);

    return ListTile(
      dense: true,
      onTap: itemCode.isEmpty
          ? null
          : () => _showVelocityDetail(context, itemCode, itemName),
      title: Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (group.isNotEmpty) group,
          if (stock.isNotEmpty) '${context.l10n.reportsColumnStock}: $stock',
        ].join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: trailing,
    );
  }
}

void _showVelocityDetail(BuildContext context, String itemCode, String itemName) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _VelocityDetailSheet(itemCode: itemCode, itemName: itemName),
  );
}

class _VelocityDetailSheet extends ConsumerWidget {
  final String itemCode;
  final String itemName;
  const _VelocityDetailSheet({required this.itemCode, required this.itemName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final async = ref.watch(itemVelocityDetailProvider(itemCode));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.velocityReportDetailTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(itemName, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.reportError),
              ),
              data: (detail) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(context, l10n.reportsColumnVelocity30d,
                      detail.velocity30d.toStringAsFixed(2)),
                  _detailRow(context, l10n.reportsColumnVelocity60d,
                      detail.velocity60d.toStringAsFixed(2)),
                  _detailRow(context, l10n.reportsColumnTrend,
                      localizedVelocityTrend(context, detail.trend)),
                  _detailRow(context, l10n.reportsColumnStock,
                      detail.stockOnHand.toStringAsFixed(0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.reportError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.reportsRetry)),
          ],
        ),
      ),
    );
  }
}

/// First non-empty stringified value among [keys], else [fallback].
String _text(JsonMap r, List<String> keys, {String fallback = ''}) {
  for (final k in keys) {
    final v = r[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  }
  return fallback;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/network/user_service.dart';
import '../../data/customer_segments_repository.dart';
import '../../data/models/customer_segments.dart';
import '../../data/models/report_json.dart';
import '../../state/customer_segments_providers.dart';
import '../widgets/kpi_card.dart';

/// Customer Segments (RFM) dashboard: the nightly job's current segment
/// counts, a drill-down per segment with pin/unpin and an in-app export view,
/// and a manager-tier manual recalculation trigger.
///
/// Consumes [segmentSummaryProvider]; gated on the Reports hub by
/// `UserRoles.canViewAllReports` (mirrors the backend's
/// `frappe.only_for("JARZ Manager")` on every `api/segmentation.py` endpoint).
class CustomerSegmentsScreen extends ConsumerWidget {
  const CustomerSegmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(segmentSummaryProvider);
    final roles = ref.watch(userRolesFutureProvider).valueOrNull;
    final canRecalculate = roles?.canViewAllReports ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.segmentReportTitle),
        actions: [
          if (canRecalculate)
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: l10n.segmentReportRecalculateAction,
              onPressed: () => _confirmAndRecalculate(context, ref),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(segmentSummaryProvider),
        ),
        data: (rows) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(segmentSummaryProvider);
            await ref.read(segmentSummaryProvider.future);
          },
          child: _Body(rows: rows),
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
        title: Text(l10n.segmentReportRecalculateConfirmTitle),
        content: Text(l10n.segmentReportRecalculateConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.segmentReportRecalculateAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(customerSegmentsRepositoryProvider);
      final result = await repo.runSegmentationNow();
      final updated = result['updated'];
      ref.invalidate(segmentSummaryProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.segmentReportRecalculateSuccess(
              updated is num ? updated.toInt() : 0,
            ),
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.segmentReportRecalculateError)),
      );
    }
  }
}

// ── Body ─────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final List<SegmentSummaryRow> rows;
  const _Body({required this.rows});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final total = rows.fold<int>(0, (s, r) => s + r.count);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        KpiCard(
          label: l10n.segmentReportTotalCustomers,
          value: formatCount(context, total),
          icon: Icons.groups_outlined,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.reportsNoData,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final row in rows) _SegmentRow(row: row),
              ],
            ),
          ),
      ],
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final SegmentSummaryRow row;
  const _SegmentRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = _segmentStyle(row.segment);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: style.color.withValues(alpha: 0.14),
        foregroundColor: style.color,
        child: Icon(style.icon, size: 18),
      ),
      title: Text(localizedCustomerSegment(context, row.segment)),
      subtitle: Text(
        '${l10n.segmentReportColumnCount}: ${formatCount(context, row.count)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SegmentCustomersScreen(segment: row.segment),
        ),
      ),
    );
  }
}

class _SegmentStyle {
  final IconData icon;
  final Color color;
  const _SegmentStyle(this.icon, this.color);
}

/// Purely presentational (icon + colour) per RFM segment — no localized text
/// here, [localizedCustomerSegment] owns the label. Unknown/legacy segment
/// strings fall back to a neutral tone rather than guessing.
_SegmentStyle _segmentStyle(String segment) {
  switch (segment.trim().toLowerCase()) {
    case 'champion':
    case 'champions':
      return const _SegmentStyle(Icons.star, Colors.amber);
    case 'loyal':
      return _SegmentStyle(Icons.favorite, Colors.green.shade700);
    case 'potential loyalist':
      return _SegmentStyle(Icons.trending_up, Colors.teal.shade600);
    case 'new customer':
      return const _SegmentStyle(Icons.fiber_new_outlined, Colors.blue);
    case 'at risk':
      return const _SegmentStyle(Icons.warning_amber_outlined, Colors.orange);
    case "can't lose them":
      return const _SegmentStyle(Icons.priority_high, Colors.deepOrange);
    case 'lost':
      return const _SegmentStyle(Icons.person_off_outlined, Colors.redAccent);
    case 'one-time':
      return const _SegmentStyle(Icons.looks_one_outlined, Colors.blueGrey);
    default:
      return const _SegmentStyle(Icons.help_outline, Colors.grey);
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

// ── Segment drill-down: customer list, pin/unpin, in-app export ────────────

/// Lists every customer currently in [segment] (`segmentation.export_segment`)
/// with a per-row pin/unpin action and a "Copy All" export.
///
/// Exported data is presented in-app rather than downloaded: the app runs on
/// Android and web alike, and there is no existing file-download precedent in
/// this codebase to follow (other screens that hand the user exported data
/// use `Clipboard.setData` + a confirmation SnackBar — see `AboutScreen` and
/// the materials "copy link" action — so this view does the same).
class SegmentCustomersScreen extends ConsumerWidget {
  final String segment;
  const SegmentCustomersScreen({super.key, required this.segment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(segmentCustomersProvider(segment));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.segmentReportCustomersTitle(
          localizedCustomerSegment(context, segment),
        )),
        actions: [
          async.maybeWhen(
            data: (rows) => IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: l10n.segmentReportCopyAll,
              onPressed: rows.isEmpty
                  ? null
                  : () => _copyAll(context, rows),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(segmentCustomersProvider(segment)),
        ),
        data: (rows) => rows.isEmpty
            ? Center(child: Text(l10n.segmentReportExportEmpty))
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(segmentCustomersProvider(segment));
                  await ref.read(segmentCustomersProvider(segment).future);
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _CustomerRow(row: rows[i], segment: segment),
                ),
              ),
      ),
    );
  }

  void _copyAll(BuildContext context, List<SegmentCustomerRow> rows) {
    final l10n = context.l10n;
    final buffer = StringBuffer()
      ..writeln('Customer,Mobile,Territory,Segment,RecencyDays,'
          'FrequencyCount,AvgOrderValue,UpdatedOn');
    for (final r in rows) {
      buffer.writeln([
        _csv(_str(r, const ['customer_name', 'customer_id'])),
        _csv(_str(r, const ['mobile_no'])),
        _csv(_str(r, const ['territory'])),
        _csv(_str(r, const ['customer_segment'])),
        _csv(_str(r, const ['rfm_recency_days'])),
        _csv(_str(r, const ['rfm_frequency_count'])),
        _csv(_str(r, const ['rfm_avg_order_value'])),
        _csv(_str(r, const ['segment_updated_on'])),
      ].join(','));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.segmentReportCopied)),
    );
  }
}

class _CustomerRow extends ConsumerWidget {
  final SegmentCustomerRow row;
  final String segment;
  const _CustomerRow({required this.row, required this.segment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = _str(row, const ['customer_name', 'customer_id'], fallback: '—');
    final mobile = _str(row, const ['mobile_no']);
    final territory = _str(row, const ['territory']);
    final avgOrder = _num(row, const ['rfm_avg_order_value']);
    final recency = _str(row, const ['rfm_recency_days']);
    final frequency = _str(row, const ['rfm_frequency_count']);

    final subtitleParts = <String>[
      if (mobile.isNotEmpty) mobile,
      if (territory.isNotEmpty) territory,
      if (recency.isNotEmpty) '${recency}d',
      if (frequency.isNotEmpty) 'x$frequency',
    ];

    return ListTile(
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitleParts.join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatCurrency(context, avgOrder),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<bool>(
            icon: const Icon(Icons.more_vert),
            onSelected: (pin) => _confirmAndOverride(context, ref, pin),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: true, child: Text(ctx.l10n.segmentReportPin)),
              PopupMenuItem(value: false, child: Text(ctx.l10n.segmentReportUnpin)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndOverride(
    BuildContext context,
    WidgetRef ref,
    bool pin,
  ) async {
    final l10n = context.l10n;
    final customerId = _str(row, const ['customer_id']);
    final customerName = _str(row, const ['customer_name', 'customer_id']);
    if (customerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pin ? l10n.segmentReportPin : l10n.segmentReportUnpin),
        content: Text(
          pin
              ? l10n.segmentReportPinConfirmBody(customerName)
              : l10n.segmentReportUnpinConfirmBody(customerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(pin ? l10n.segmentReportPin : l10n.segmentReportUnpin),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(customerSegmentsRepositoryProvider);
      await repo.setSegmentOverride(
        customer: customerId,
        override: pin,
        manualSegment: pin ? _str(row, const ['customer_segment']) : null,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.segmentReportOverrideSuccess)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.segmentReportOverrideError)),
      );
    }
  }
}

// ── Row helpers (null-safe) ────────────────────────────────────────────────

String _str(JsonMap r, List<String> keys, {String fallback = ''}) {
  for (final k in keys) {
    final v = r[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  }
  return fallback;
}

double _num(JsonMap r, List<String> keys) {
  for (final k in keys) {
    final v = r[k];
    if (v is num) return v.toDouble();
    if (v is String) {
      final p = double.tryParse(v.trim());
      if (p != null) return p;
    }
  }
  return 0;
}

/// Minimal CSV field escaping for the clipboard export (wraps in quotes and
/// doubles inner quotes when the value contains a comma/quote/newline).
String _csv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/customer_segments_repository.dart';
import '../../data/models/customer_segments.dart';
import '../../data/models/report_json.dart';
import '../../state/customer_segments_providers.dart';
import '../../state/reports_providers.dart';
import '../widgets/report_export_button.dart';
import '../widgets/report_states.dart';

// The segment summary that used to live here is now a section of the
// Customers report (`customer_analytics_screen.dart`); this file keeps only
// the per-segment drill-down that section opens.

/// Lists every customer currently in [segment] (`segmentation.export_segment`)
/// with a per-row pin/unpin action and a CSV export through the share sheet.
class SegmentCustomersScreen extends ConsumerWidget {
  final String segment;
  const SegmentCustomersScreen({super.key, required this.segment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(segmentCustomersProvider(segment));
    final title = l10n.segmentReportCustomersTitle(
      localizedCustomerSegment(context, segment),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ReportExportButton(
            title: title,
            rows: () => segmentCustomersCsvRows(
              context,
              async.valueOrNull ?? const [],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(segmentCustomersProvider(segment).future),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ReportErrorView(
            error: e,
            onRetry: () => ref.invalidate(segmentCustomersProvider(segment)),
          ),
          data: (rows) => rows.isEmpty
              ? ReportEmptyView(
                  message: l10n.segmentReportExportEmpty,
                  icon: Icons.groups_outlined,
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _CustomerRow(row: rows[i], segment: segment),
                ),
        ),
      ),
    );
  }
}

/// CSV rows (localised header first) for a segment's customer list.
/// Numbers stay raw so a spreadsheet can sum them.
List<List<String>> segmentCustomersCsvRows(
  BuildContext context,
  List<SegmentCustomerRow> rows,
) {
  final l10n = context.l10n;
  return [
    [
      l10n.commonCustomerLabel,
      l10n.rptG2ColumnMobile,
      l10n.rptG2ColumnTerritory,
      l10n.reportsColumnSegment,
      l10n.reportsColumnRecencyDays,
      l10n.reportsColumnFrequency,
      l10n.reportsColumnAov,
      l10n.rptG2ColumnUpdatedOn,
    ],
    for (final r in rows)
      [
        _str(r, const ['customer_name', 'customer_id']),
        _str(r, const ['mobile_no']),
        _str(r, const ['territory']),
        localizedCustomerSegment(context, _str(r, const ['customer_segment'])),
        _str(r, const ['rfm_recency_days']),
        _str(r, const ['rfm_frequency_count']),
        _str(r, const ['rfm_avg_order_value']),
        _str(r, const ['segment_updated_on']),
      ],
  ];
}

class _CustomerRow extends ConsumerWidget {
  final SegmentCustomerRow row;
  final String segment;
  const _CustomerRow({required this.row, required this.segment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = _str(row, const ['customer_name', 'customer_id'], fallback: '—');
    final mobile = _str(row, const ['mobile_no']);
    final territory = _str(row, const ['territory']);
    final avgOrder = _num(row, const ['rfm_avg_order_value']);
    final recency = ReportJson.dblOrNull(row['rfm_recency_days']);
    final frequency = ReportJson.dblOrNull(row['rfm_frequency_count']);

    final subtitleParts = <String>[
      if (mobile.isNotEmpty) mobile,
      if (territory.isNotEmpty) territory,
      if (recency != null)
        l10n.rptG2RecencyDaysAgo(formatCount(context, recency.round())),
      if (frequency != null)
        l10n.rptG2OrdersCount(formatCount(context, frequency.round())),
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
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<bool>(
            icon: const Icon(Icons.more_vert),
            onSelected: (pin) => _confirmAndOverride(context, ref, pin),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: true, child: Text(ctx.l10n.segmentReportPin)),
              PopupMenuItem(
                  value: false, child: Text(ctx.l10n.segmentReportUnpin)),
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
        // The row's real RFM segment, never an overlay such as "Regular"
        // (in the Regular drill-down a row's own segment is its RFM bucket;
        // null pins whatever the customer holds now).
        manualSegment: pin
            ? manualSegmentForPin(_str(row, const ['customer_segment']))
            : null,
      );
      // Pinning can move the customer between segments: reload this list,
      // the summary counts and the Customers report that inlines them.
      ref.invalidate(segmentCustomersProvider(segment));
      ref.invalidate(segmentSummaryProvider);
      ref.invalidate(customerReportProvider);
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
    final v = ReportJson.dblOrNull(r[k]);
    if (v != null) return v;
  }
  return 0;
}

import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/report_json.dart';
import 'report_alert_text.dart';

enum ReportAlertSeverity {
  critical,
  warning,
  info,
  success;

  /// Accepts the spellings the backends use: `danger|error|critical`,
  /// `warning|warn`, `success|ok|good`; anything else is [info].
  static ReportAlertSeverity parse(Object? v) =>
      switch (ReportJson.str(v).trim().toLowerCase()) {
        'danger' || 'error' || 'critical' || 'high' => ReportAlertSeverity.critical,
        'warning' || 'warn' || 'medium' => ReportAlertSeverity.warning,
        'success' || 'ok' || 'good' => ReportAlertSeverity.success,
        _ => ReportAlertSeverity.info,
      };

  Color color(BuildContext context) => switch (this) {
        ReportAlertSeverity.critical => Colors.red.shade700,
        ReportAlertSeverity.warning => Colors.orange.shade800,
        ReportAlertSeverity.success => Colors.green.shade700,
        ReportAlertSeverity.info => Theme.of(context).colorScheme.primary,
      };

  IconData get icon => switch (this) {
        ReportAlertSeverity.critical => Icons.error_outline,
        ReportAlertSeverity.warning => Icons.warning_amber_outlined,
        ReportAlertSeverity.success => Icons.check_circle_outline,
        ReportAlertSeverity.info => Icons.info_outline,
      };

  /// Sort rank: critical first.
  int get rank => switch (this) {
        ReportAlertSeverity.critical => 0,
        ReportAlertSeverity.warning => 1,
        ReportAlertSeverity.info => 2,
        ReportAlertSeverity.success => 3,
      };
}

/// One alert line. [message] may contain light HTML (stripped on render).
class ReportAlert {
  final ReportAlertSeverity severity;
  final String message;
  final String? detail;
  final VoidCallback? onTap;

  const ReportAlert({
    required this.message,
    this.severity = ReportAlertSeverity.info,
    this.detail,
    this.onTap,
  });

  /// From a backend alert map: severity from `severity`, `type` or `level`;
  /// text from `message`, `title` or `text`; optional `detail`/`description`.
  factory ReportAlert.fromJson(JsonMap j, {VoidCallback? onTap}) => ReportAlert(
        severity: ReportAlertSeverity.parse(j['severity'] ?? j['type'] ?? j['level']),
        message: ReportJson.str(j['message'] ?? j['title'] ?? j['text']),
        detail: ReportJson.strOrNull(j['detail'] ?? j['description']),
        onTap: onTap,
      );

  /// Parses a list of alert maps, dropping empty messages.
  static List<ReportAlert> listFrom(Object? v) => ReportJson.listOf(v, ReportAlert.fromJson)
      .where((a) => a.message.trim().isNotEmpty)
      .toList(growable: false);
}

/// The one alerts card every report uses: a titled card listing alerts with
/// a severity colour and icon, collapsed to [collapsedCount] with a
/// "Show all (n)" toggle. Renders nothing when [alerts] is empty.
class ReportAlertsCard extends StatefulWidget {
  final List<ReportAlert> alerts;
  final String? title;
  final int collapsedCount;

  /// Sort critical → success before display (stable within a severity).
  final bool sortBySeverity;

  const ReportAlertsCard({
    super.key,
    required this.alerts,
    this.title,
    this.collapsedCount = 3,
    this.sortBySeverity = true,
  });

  @override
  State<ReportAlertsCard> createState() => _ReportAlertsCardState();
}

class _ReportAlertsCardState extends State<ReportAlertsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final all = widget.alerts.where((a) => a.message.trim().isNotEmpty).toList();
    if (all.isEmpty) return const SizedBox.shrink();
    if (widget.sortBySeverity) {
      final indexed = all.asMap().entries.toList()
        ..sort((a, b) {
          final r = a.value.severity.rank.compareTo(b.value.severity.rank);
          return r != 0 ? r : a.key.compareTo(b.key);
        });
      all
        ..clear()
        ..addAll(indexed.map((e) => e.value));
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final shown = _expanded ? all : all.take(widget.collapsedCount).toList();

    return Card(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.title ?? l10n.reportAlerts,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${all.length}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final a in shown) _AlertTile(alert: a),
            if (all.length > widget.collapsedCount)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? l10n.reportShowLess
                        : l10n.reportShowAllCount(all.length),
                  ),
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final ReportAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert.severity.color(context);
    final detail = alert.detail == null ? null : stripHtml(alert.detail!);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 6),
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: alert.onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(alert.severity.icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stripHtml(alert.message), style: theme.textTheme.bodyMedium),
                      if (detail != null && detail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 2),
                          child: Text(
                            detail,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (alert.onTap != null)
                  Icon(Icons.chevron_right,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

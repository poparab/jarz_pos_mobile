import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../data/models/chat_models.dart';
import '../../state/chat_providers.dart';

/// `/chats/metrics` — managers' KPIs from `get_chat_metrics` for a date
/// range (default: the last 7 days, inclusive of today).
class ChatMetricsScreen extends ConsumerStatefulWidget {
  const ChatMetricsScreen({super.key});

  @override
  ConsumerState<ChatMetricsScreen> createState() => _ChatMetricsScreenState();
}

class _ChatMetricsScreenState extends ConsumerState<ChatMetricsScreen> {
  static final _wire = DateFormat('yyyy-MM-dd');
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(ref.read(chatClockProvider)());
    _range = DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today,
    );
  }

  ({String from, String to}) get _key =>
      (from: _wire.format(_range.start), to: _wire.format(_range.end));

  Future<void> _pickRange() async {
    final today = DateUtils.dateOnly(ref.read(chatClockProvider)());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      initialDateRange: _range,
    );
    if (picked != null && mounted) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final roles = ref.watch(userRolesFutureProvider);
    final allowed = ref.watch(canViewChatMetricsProvider);

    Widget body;
    if (roles.isLoading && !roles.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (roles.hasValue && !allowed) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.chatMetricsNotAllowed, textAlign: TextAlign.center),
        ),
      );
    } else {
      final key = _key;
      final async = ref.watch(chatMetricsProvider(key));
      body = async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.userErrorMessage(e, fallback: l10n.chatMetricsLoadError),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(chatMetricsProvider(key)),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (metrics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(chatMetricsProvider(key));
            await ref.read(chatMetricsProvider(key).future);
          },
          child: _MetricsBody(metrics: metrics),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatMetricsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TextButton.icon(
            key: const ValueKey('chat-metrics-range'),
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              '${formatDate(context, _range.start)} – '
              '${formatDate(context, _range.end)}',
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}

class _MetricsBody extends StatelessWidget {
  const _MetricsBody({required this.metrics});

  final ChatMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String count(num value) => formatCount(context, value);
    final drafts = metrics.drafts;
    final median = metrics.medianFirstResponseMinutes;
    final percent = NumberFormat.decimalPercentPattern(
      locale: l10n.localeName,
      decimalDigits: 0,
    ).format(metrics.asIsPercent / 100);

    Widget tile(String label, String value, {Color? color}) => Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(color: color),
                ),
              ],
            ),
          ),
        );

    Widget grid(List<Widget> children) => LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 3 : 2;
            final width =
                (constraints.maxWidth - (columns - 1) * 8) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final child in children)
                  SizedBox(width: width, child: child),
              ],
            );
          },
        );

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(title, style: theme.textTheme.titleMedium),
        );

    return ListView(
      key: const ValueKey('chat-metrics-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        grid([
          tile(l10n.chatMetricsConversations, count(metrics.conversations)),
          tile(l10n.chatMetricsInbound, count(metrics.inboundMessages)),
          tile(l10n.chatMetricsOutbound, count(metrics.outboundMessages)),
          tile(
            l10n.chatMetricsMedianFirstResponse,
            median == null
                ? '—'
                : l10n.chatMetricsMinutes(
                    NumberFormat.decimalPattern(l10n.localeName)
                        .format(double.parse(median.toStringAsFixed(1))),
                  ),
          ),
          tile(
            l10n.chatMetricsUnansweredOpen,
            count(metrics.unansweredOpen),
            color: metrics.unansweredOpen > 0 ? theme.colorScheme.error : null,
          ),
          tile(
            l10n.chatMetricsWaitingOverAlert,
            count(metrics.waitingOverAlert),
            color:
                metrics.waitingOverAlert > 0 ? theme.colorScheme.error : null,
          ),
        ]),
        section(l10n.chatMetricsDrafts),
        grid([
          tile(l10n.chatMetricsTotal, count(drafts.total)),
          tile(l10n.chatMetricsAsIsRate, percent),
          tile(l10n.chatMetricsSentAsIs, count(drafts.sentAsIs)),
          tile(l10n.chatMetricsSentEdited, count(drafts.sentEdited)),
          tile(l10n.chatMetricsRejected, count(drafts.rejected)),
          tile(l10n.chatMetricsSuperseded, count(drafts.superseded)),
          tile(l10n.chatMetricsBlocked, count(drafts.blocked)),
          tile(
            l10n.chatMetricsPlanted,
            l10n.chatMetricsPlantedValue(
              count(metrics.plantedCaught),
              count(metrics.plantedTotal),
            ),
          ),
          tile(
            l10n.chatMetricsCost,
            NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2)
                .format(metrics.costUsd),
          ),
        ]),
        section(l10n.chatMetricsByModerator),
        if (metrics.byModerator.isEmpty)
          Text(l10n.chatMetricsNoModerators)
        else
          Card(
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.chatMetricsModerator)),
                  DataColumn(label: Text(l10n.chatMetricsModSent), numeric: true),
                  DataColumn(label: Text(l10n.chatMetricsModAsIs), numeric: true),
                  DataColumn(label: Text(l10n.chatMetricsModEdited), numeric: true),
                  DataColumn(label: Text(l10n.chatMetricsRejected), numeric: true),
                ],
                rows: [
                  for (final row in metrics.byModerator)
                    DataRow(cells: [
                      DataCell(Text(row.fullName)),
                      DataCell(Text(count(row.sent))),
                      DataCell(Text(count(row.asIs))),
                      DataCell(Text(count(row.edited))),
                      DataCell(Text(count(row.rejected))),
                    ]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

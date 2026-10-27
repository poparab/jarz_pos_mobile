import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import '../widgets/followup_card.dart';

/// The last 7 days of `get_sent_report`: every automatic WhatsApp follow-up
/// sent, whether it was delivered / read, and whether the customer replied or
/// ordered again.
class FollowupSentScreen extends ConsumerWidget {
  const FollowupSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(followupSentLast7DaysProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.followupsSentTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.userErrorMessage(e), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(followupSentLast7DaysProvider),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
        data: (report) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(followupSentLast7DaysProvider);
            await ref.read(followupSentLast7DaysProvider.future);
          },
          child: _SentBody(report: report),
        ),
      ),
    );
  }
}

/// Arabic-first label for a WhatsApp delivery status.
String followupWaStatusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  return switch (status.toLowerCase()) {
    'delivered' => l10n.followupsSentDelivered,
    'read' => l10n.followupsSentRead,
    'failed' => l10n.followupsSentFailed,
    _ => l10n.followupsSentTotal,
  };
}

class _SentBody extends StatelessWidget {
  const _SentBody({required this.report});

  final FollowupSentReport report;

  String _stepLabel(BuildContext context, String step) =>
      followupStepLabel(context, FollowupRow(name: '', step: step));

  String _reasonLabel(BuildContext context, String reason) {
    final l10n = context.l10n;
    return switch (reason) {
      'Order cancelled' => l10n.followupsSentReasonOrderCancelled,
      'Order returned' => l10n.followupsSentReasonOrderReturned,
      'Excluded: B2B / employee' => l10n.followupsSentReasonExcluded,
      'New order' => l10n.followupsSentReasonNewOrder,
      'Opted out' => l10n.followupsSentReasonOptedOut,
      'Quality complaint' => l10n.followupsSentReasonQuality,
      '' => l10n.commonNotSpecified,
      _ => reason,
    };
  }

  Color _statusColor(ThemeData theme, String status) =>
      switch (status.toLowerCase()) {
        'read' => Colors.blue,
        'delivered' => Colors.green,
        'failed' => theme.colorScheme.error,
        _ => theme.colorScheme.outline,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget metric(String label, int value) => Card(
          child: ListTile(
            title: Text(label),
            trailing: Text(
              formatCount(context, value),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );

    Widget section(String title, List<Widget> rows) => Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                if (rows.isEmpty)
                  ListTile(dense: true, title: Text(l10n.followupsStatsEmpty)),
                ...rows,
              ],
            ),
          ),
        );

    final steps = report.byStep.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final reasons = report.cancelled.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        metric(l10n.followupsSentTotal, report.total('sent')),
        metric(l10n.followupsSentDelivered, report.total('delivered')),
        metric(l10n.followupsSentRead, report.total('read')),
        metric(l10n.followupsSentFailed, report.total('failed')),
        metric(l10n.followupsSentReplied, report.total('replied')),
        metric(l10n.followupsSentReordered, report.total('reordered')),
        metric(l10n.followupsSentOptedOut, report.optedOutCustomers),
        metric(l10n.followupsSentRefused, report.refusedWaitingForStaff),
        section(l10n.followupsSentByStep, [
          for (final e in steps)
            ListTile(
              dense: true,
              title: Text(_stepLabel(context, e.key)),
              subtitle: Text(
                l10n.followupsSentStepSummary(
                  formatCount(context, e.value['sent'] ?? 0),
                  formatCount(context, e.value['read'] ?? 0),
                  formatCount(context, e.value['reordered'] ?? 0),
                ),
              ),
            ),
        ]),
        section(l10n.followupsSentByDay, [
          for (final e in report.byDay.entries)
            ListTile(
              dense: true,
              title: Text(formatDateString(context, e.key)),
              trailing: Text(formatCount(context, e.value)),
            ),
        ]),
        section(l10n.followupsSentCancelled, [
          for (final e in reasons)
            ListTile(
              dense: true,
              title: Text(_reasonLabel(context, e.key)),
              trailing: Text(formatCount(context, e.value)),
            ),
        ]),
        section(l10n.followupsSentMessages, [
          for (final item in report.items)
            ListTile(
              title: Text(item.customerName),
              subtitle: Text(
                [
                  _stepLabel(context, item.step),
                  formatDateString(
                    context,
                    item.sentAt,
                    pattern: 'MMM d • h:mm a',
                  ),
                  if (item.offerCode.isNotEmpty)
                    l10n.followupsSentCode(item.offerCode),
                  if (item.replied) l10n.followupsSentReplied,
                  if (item.reordered)
                    l10n.followupsSentReorderInvoice(item.reorderInvoice),
                  if (item.error.isNotEmpty) item.error,
                ].join(' · '),
              ),
              isThreeLine: true,
              trailing: Text(
                followupWaStatusLabel(context, item.waStatus),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _statusColor(theme, item.waStatus),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ]),
      ],
    );
  }
}

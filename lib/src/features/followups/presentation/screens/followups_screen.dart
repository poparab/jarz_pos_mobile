import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../printing/receipt/receipt_delivery.dart';
import '../../data/followup_whatsapp.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import '../widgets/followup_card.dart';
import '../widgets/log_touch_sheet.dart';
import 'followup_stats_screen.dart';

/// "Follow-ups today" (المتابعات): the sender's daily list of reorder-plan
/// touches — WhatsApp messages and calls after delivery — split into overdue
/// and due today. Gated in the drawer by `UserRoles.canAccessFollowups`
/// (the line-manager tier, as `api/customer_followups.py` enforces).
class FollowupsScreen extends ConsumerStatefulWidget {
  const FollowupsScreen({super.key});

  @override
  ConsumerState<FollowupsScreen> createState() => _FollowupsScreenState();
}

class _FollowupsScreenState extends ConsumerState<FollowupsScreen> {
  /// Touches with a skip in flight, so their buttons cannot fire twice.
  final Set<String> _busy = <String>{};

  Future<void> _refresh() =>
      ref.read(followupsTodayProvider.notifier).refresh();

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openWhatsapp(Uri? uri) async {
    if (uri == null) {
      _snack(context.l10n.followupsNoWhatsapp);
      return;
    }
    await openWhatsAppOrOfferRetry(
      messenger: ScaffoldMessenger.of(context),
      uri: uri,
      failureMessage: context.l10n.invoiceWhatsAppOpenFailed,
      retryLabel: context.l10n.commonRetry,
    );
  }

  Future<void> _copyMessage(FollowupRow row) async {
    final copied = context.l10n.followupsMessageCopied;
    await Clipboard.setData(ClipboardData(text: row.messageText));
    if (mounted) _snack(copied);
  }

  Future<void> _call(FollowupRow row) async {
    final uri = followupTelUri(row.phone);
    if (uri == null) {
      _snack(context.l10n.followupsNoPhone);
      return;
    }
    try {
      await launchUrl(uri);
    } catch (e) {
      if (mounted) _snack(context.userErrorMessage(e));
    }
  }

  Future<void> _log(FollowupRow row) async {
    final l10n = context.l10n;
    final result = await showLogTouchSheet(context, row);
    if (result == null || !mounted) return;
    final task = result.escalationTask;
    _snack(task == null ? l10n.followupsLogged : l10n.followupsEscalated(task));
    final code = result.apologyCode;
    if (code != null) await _showApology(row, code);
  }

  Future<void> _showApology(FollowupRow row, String code) async {
    final l10n = context.l10n;
    final uri = followupWhatsappUriFor(
      followupMsisdn(row),
      followupApologyText(code),
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.followupsApologyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.followupsApologyBody),
            const SizedBox(height: 12),
            SelectableText(
              code,
              style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonClose),
          ),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (mounted) _snack(l10n.followupsApologyCopied);
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.followupsApologyCopy),
          ),
          if (uri != null)
            FilledButton.icon(
              onPressed: () => _openWhatsapp(uri),
              icon: const Icon(Icons.chat, size: 18),
              label: Text(l10n.followupsApologySend),
            ),
        ],
      ),
    );
  }

  Future<void> _skip(FollowupRow row) async {
    final l10n = context.l10n;
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.followupsSkipTitle),
        content: TextField(
          controller: reasonCtrl,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            labelText: l10n.commonReasonLabel,
            hintText: l10n.followupsSkipReasonHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.followupsActionSkip),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text;
    reasonCtrl.dispose();
    if (confirmed != true || !mounted) return;

    setState(() => _busy.add(row.name));
    try {
      await ref
          .read(followupsTodayProvider.notifier)
          .skipTouch(name: row.name, reason: reason);
      if (mounted) _snack(l10n.followupsSkipped);
    } catch (e) {
      if (mounted) _snack(userErrorMessageFor(l10n, e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(followupsTodayProvider);
    final canViewStats = ref.watch(canViewFollowupStatsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.followupsTitle),
        actions: [
          if (canViewStats)
          IconButton(
            tooltip: l10n.followupsStatsAction,
            icon: const Icon(Icons.query_stats),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FollowupStatsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          message: context.userErrorMessage(e, fallback: l10n.followupsLoadFailed),
          onRetry: () => ref.invalidate(followupsTodayProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: _refresh,
          child: _buildList(context, data),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, FollowupsToday data) {
    final l10n = context.l10n;
    final overdue = data.overdueRows;
    final today = data.todayRows;

    Widget card(FollowupRow row) => FollowupCard(
          key: ValueKey(row.name),
          row: row,
          busy: _busy.contains(row.name),
          onWhatsapp: () => _openWhatsapp(followupWhatsappUri(row)),
          onCopy: () => _copyMessage(row),
          onCall: () => _call(row),
          onLog: () => _log(row),
          onSkip: () => _skip(row),
        );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _SummaryChips(summary: data.summary),
        if (data.rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Text(
                l10n.followupsEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        if (overdue.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.followupsSectionOverdue,
            count: overdue.length,
            color: Theme.of(context).colorScheme.error,
          ),
          for (final r in overdue) card(r),
        ],
        if (today.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.followupsSectionToday,
            count: today.length,
            color: Theme.of(context).colorScheme.primary,
          ),
          for (final r in today) card(r),
        ],
      ],
    );
  }
}

class _SummaryChips extends StatelessWidget {
  const _SummaryChips({required this.summary});

  final FollowupSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    Widget chip(IconData icon, String label, int value, Color color) => Chip(
          avatar: Icon(icon, size: 18, color: color),
          label: Text('$label: ${formatCount(context, value)}'),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          chip(Icons.event_note_outlined, l10n.followupsSummaryDue,
              summary.due, scheme.primary),
          chip(Icons.warning_amber_outlined, l10n.followupsSummaryOverdue,
              summary.overdue, scheme.error),
          chip(Icons.call_outlined, l10n.followupsSummaryCalls, summary.calls,
              Colors.indigo),
          chip(Icons.chat_outlined, l10n.followupsSummaryMessages,
              summary.messages, Colors.green.shade700),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        '$title (${formatCount(context, count)})',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../printing/receipt/receipt_delivery.dart';
import '../../data/followup_filter.dart';
import '../../data/followup_whatsapp.dart';
import '../../data/models/followup_models.dart';
import '../../state/followups_providers.dart';
import '../widgets/call_brief_sheet.dart';
import '../widgets/followup_card.dart';
import '../widgets/log_touch_sheet.dart';

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

  /// Touches whose Claude message is being written right now.
  final Set<String> _drafting = <String>{};

  /// Touches already asked for a message this session, so a template
  /// fallback is not re-requested (and re-waited for) on every tap.
  final Set<String> _drafted = <String>{};

  /// What the sender narrowed the list to; kept across refreshes.
  FollowupFilter _filter = FollowupFilter.none;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _setFilter(FollowupFilter next) => setState(() => _filter = next);

  void _clearFilter() {
    _searchCtrl.clear();
    _setFilter(FollowupFilter.none);
  }

  /// The row as it is now in state (the drafted text may have arrived).
  FollowupRow _fresh(FollowupRow row) {
    final rows = ref.read(followupsTodayProvider).valueOrNull?.rows;
    if (rows == null) return row;
    for (final r in rows) {
      if (r.name == row.name) return r;
    }
    return row;
  }

  /// Makes sure [row] carries its Claude message; returns the row to use.
  /// Quiet on failure: the template text already on the row is used.
  Future<FollowupRow> _ensureMessage(FollowupRow row, {bool refresh = false}) async {
    if (!refresh && (row.aiMessage.trim().isNotEmpty || _drafted.contains(row.name))) {
      return _fresh(row);
    }
    if (_drafting.contains(row.name)) return _fresh(row);
    setState(() => _drafting.add(row.name));
    try {
      await ref
          .read(followupsTodayProvider.notifier)
          .draftMessage(row.name, refresh: refresh);
      _drafted.add(row.name);
    } catch (_) {
      // Keep going with the template text the row already has.
    } finally {
      if (mounted) setState(() => _drafting.remove(row.name));
    }
    return _fresh(row);
  }

  Future<void> _whatsappFor(FollowupRow row) async {
    final fresh = row.isCall ? row : await _ensureMessage(row);
    if (!mounted) return;
    await _openWhatsapp(followupWhatsappUri(fresh));
  }

  Future<void> _rewrite(FollowupRow row) async {
    await _ensureMessage(row, refresh: true);
  }

  Future<void> _brief(FollowupRow row) async {
    await showCallBriefSheet(
      context,
      row: _fresh(row),
      onCall: () => _call(row),
      onWhatsapp: () => _whatsappFor(row),
    );
  }

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
    final fresh = await _ensureMessage(row);
    await Clipboard.setData(ClipboardData(text: fresh.messageText));
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
    // The dialog's TextField is still mounted during the exit animation, so
    // dispose only once the route transition is surely over.
    Future<void>.delayed(const Duration(seconds: 1), reasonCtrl.dispose);
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
              tooltip: l10n.followupResultsTitle,
              icon: const Icon(Icons.insights_outlined),
              onPressed: () => context.push(AppRoutes.followupResults),
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
    final shown = _filter.apply(data.rows);
    final overdue = shown.where((r) => r.isOverdue).toList(growable: false);
    final today = shown.where((r) => !r.isOverdue).toList(growable: false);

    Widget card(FollowupRow row) => FollowupCard(
          key: ValueKey(row.name),
          row: row,
          busy: _busy.contains(row.name),
          drafting: _drafting.contains(row.name),
          onWhatsapp: () => _whatsappFor(row),
          onBrief: () => _brief(row),
          onRewrite: () => _rewrite(row),
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
        if (data.rows.isNotEmpty)
          _FilterBar(
            filter: _filter,
            options: FollowupFilterOptions.of(data.rows),
            searchCtrl: _searchCtrl,
            onChanged: _setFilter,
            onClear: _clearFilter,
          ),
        if (data.rows.isNotEmpty && shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Text(
                l10n.labelsEmptyNoMatch,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
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

/// Search plus filter chips over today's list: channel, overdue, customer
/// type, value band, regular, and menus for step, segment and territory.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.options,
    required this.searchCtrl,
    required this.onChanged,
    required this.onClear,
  });

  final FollowupFilter filter;
  final FollowupFilterOptions options;
  final TextEditingController searchCtrl;
  final ValueChanged<FollowupFilter> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = filter;

    Widget toggle(String label, bool selected, VoidCallback onTap,
            {IconData? icon}) =>
        FilterChip(
          avatar: icon == null ? null : Icon(icon, size: 18),
          label: Text(label),
          selected: selected,
          showCheckmark: icon == null,
          onSelected: (_) => onTap(),
        );

    String stepLabel(String step) =>
        followupStepLabel(context, FollowupRow(name: '', step: step));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchCtrl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.customerSearchHint,
              border: const OutlineInputBorder(),
              suffixIcon: f.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.commonClear,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchCtrl.clear();
                        onChanged(f.copyWith(query: ''));
                      },
                    ),
            ),
            onChanged: (v) => onChanged(f.copyWith(query: v)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              toggle(
                l10n.followupsChannelCall,
                f.channel == FollowupChannel.call,
                () => onChanged(f.channel == FollowupChannel.call
                    ? f.copyWith(clearChannel: true)
                    : f.copyWith(channel: FollowupChannel.call)),
                icon: Icons.call_outlined,
              ),
              toggle(
                l10n.followupsChannelMessage,
                f.channel == FollowupChannel.message,
                () => onChanged(f.channel == FollowupChannel.message
                    ? f.copyWith(clearChannel: true)
                    : f.copyWith(channel: FollowupChannel.message)),
                icon: Icons.chat_outlined,
              ),
              toggle(
                l10n.followupsSummaryOverdue,
                f.overdueOnly,
                () => onChanged(f.copyWith(overdueOnly: !f.overdueOnly)),
              ),
              for (final type in const ['New', 'Repeat'])
                toggle(
                  type == 'New'
                      ? l10n.followupsCustomerNew
                      : l10n.followupsCustomerRepeat,
                  f.customerType == type,
                  () => onChanged(f.customerType == type
                      ? f.copyWith(clearCustomerType: true)
                      : f.copyWith(customerType: type)),
                ),
              for (final band in const ['High', 'Low'])
                toggle(
                  band == 'High'
                      ? l10n.followupsValueHigh
                      : l10n.followupsValueLow,
                  f.valueBand == band,
                  () => onChanged(f.valueBand == band
                      ? f.copyWith(clearValueBand: true)
                      : f.copyWith(valueBand: band)),
                ),
              toggle(
                l10n.followupsRegular,
                f.regularOnly,
                () => onChanged(f.copyWith(regularOnly: !f.regularOnly)),
              ),
              if (options.steps.length > 1)
                _MenuChip(
                  icon: Icons.timeline,
                  allLabel: l10n.productionFilterAll,
                  values: options.steps,
                  selected: f.step,
                  labelOf: stepLabel,
                  onSelected: (v) => onChanged(v == null
                      ? f.copyWith(clearStep: true)
                      : f.copyWith(step: v)),
                ),
              if (options.segments.isNotEmpty)
                _MenuChip(
                  icon: Icons.groups_outlined,
                  allLabel: l10n.productionFilterAll,
                  values: options.segments,
                  selected: f.segment,
                  labelOf: (s) => localizedCustomerSegment(context, s),
                  onSelected: (v) => onChanged(v == null
                      ? f.copyWith(clearSegment: true)
                      : f.copyWith(segment: v)),
                ),
              if (options.territories.isNotEmpty)
                _MenuChip(
                  icon: Icons.place_outlined,
                  allLabel: l10n.leadFieldTerritory,
                  values: options.territories,
                  selected: f.territory,
                  labelOf: (t) => t,
                  onSelected: (v) => onChanged(v == null
                      ? f.copyWith(clearTerritory: true)
                      : f.copyWith(territory: v)),
                ),
              if (f.isActive)
                ActionChip(
                  avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: Text(l10n.masterOrdersClearFilters),
                  onPressed: onClear,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A chip that opens a menu of [values]; shows the picked one, or
/// [allLabel] when nothing is picked. Picking the first entry clears it.
class _MenuChip extends StatelessWidget {
  const _MenuChip({
    required this.icon,
    required this.allLabel,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final IconData icon;
  final String allLabel;
  final List<String> values;
  final String? selected;
  final String Function(String) labelOf;
  final ValueChanged<String?> onSelected;

  /// Menu value for "all"; real values are never empty.
  static const _all = '';

  @override
  Widget build(BuildContext context) {
    final picked = selected;
    return PopupMenuButton<String>(
      tooltip: allLabel,
      onSelected: (v) => onSelected(v == _all ? null : v),
      itemBuilder: (_) => [
        PopupMenuItem(value: _all, child: Text(allLabel)),
        for (final v in values)
          CheckedPopupMenuItem(
            value: v,
            checked: v == picked,
            child: Text(labelOf(v)),
          ),
      ],
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(picked == null ? allLabel : labelOf(picked)),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        backgroundColor: picked == null
            ? null
            : Theme.of(context).colorScheme.secondaryContainer,
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

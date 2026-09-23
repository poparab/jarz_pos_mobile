import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/localization/user_error_message.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/cash_custody_models.dart';
import '../state/cash_custody_notifier.dart';
import 'custody_holder_detail.dart';
import 'custody_labels.dart';
import 'widgets/custody_candidate_picker.dart';

/// Cash Custody (العُهد).
///
/// A manager sees every holder; a holder who is not a manager lands straight
/// on their own balance and statement. Anyone else is told they hold none --
/// the server decides all three from `get_custody_overview`.
class CashCustodyScreen extends ConsumerWidget {
  const CashCustodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overviewAsync = ref.watch(custodyOverviewProvider);
    final overview = overviewAsync.valueOrNull;
    final isHolderOnly =
        overview != null && !overview.canManage && overview.myHolder != null;

    Widget body;
    if (overview == null) {
      body = overviewAsync.hasError
          ? _ErrorState(
              error: overviewAsync.error,
              onRetry: () => ref.invalidate(custodyOverviewProvider),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (overview.canManage) {
      body = _ManagerView(overview: overview);
    } else if (overview.myHolder != null) {
      body = CustodyHolderDetailView(holderName: overview.myHolder!.name);
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.refresh(custodyOverviewProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(custodyIcon, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Center(child: Text(l10n.custodyNotAHolder)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHolderOnly ? l10n.custodyMyTitle : l10n.custodyTitle),
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: overview != null && overview.canManageHolders
          ? FloatingActionButton.extended(
              onPressed: () => _addHolder(context, ref),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.custodyAddHolder),
            )
          : null,
    );
  }

  Future<void> _addHolder(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final candidate = await CustodyCandidatePicker.show(context);
    if (candidate == null || !context.mounted) return;
    try {
      await ref.read(custodyActionsProvider.notifier).addHolder(
            candidate.employee,
          );
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.custodyHolderAdded(candidate.displayName)),
      ));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
    }
  }
}

class _ErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

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
            Text(context.userErrorMessage(error), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerView extends ConsumerWidget {
  final CustodyOverview overview;
  const _ManagerView({required this.overview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = custodyColor(context);
    final holders = [...overview.holders]
      // Live custodies first, the largest balance on top.
      ..sort((a, b) {
        if (a.enabled != b.enabled) return a.enabled ? -1 : 1;
        return b.balance.compareTo(a.balance);
      });

    return RefreshIndicator(
      onRefresh: () => ref.refresh(custodyOverviewProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          Card(
            elevation: 0,
            color: color.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(custodyIcon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.custodyTotalHeld,
                            style: theme.textTheme.bodySmall),
                        Text(
                          formatCurrency(context, overview.totalHeld),
                          key: const Key('custody-total-held'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.custodyHoldersCount(formatCount(context, holders.length)),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (holders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.custodyNoHolders)),
            )
          else
            for (final holder in holders)
              _HolderCard(
                holder: holder,
                canToggle: overview.canManageHolders,
              ),
        ],
      ),
    );
  }
}

class _HolderCard extends ConsumerStatefulWidget {
  final CustodyHolder holder;
  final bool canToggle;
  const _HolderCard({required this.holder, required this.canToggle});

  @override
  ConsumerState<_HolderCard> createState() => _HolderCardState();
}

class _HolderCardState extends ConsumerState<_HolderCard> {
  bool _busy = false;

  Future<void> _toggle(bool enable) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    // The server refuses this too; saying so here saves a round trip and
    // tells the manager what to do instead.
    if (!enable && widget.holder.hasBalance) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.custodyDisableHasBalance)),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(custodyActionsProvider.notifier)
          .setHolderEnabled(widget.holder.name, enable);
      messenger.showSnackBar(SnackBar(
        content: Text(enable
            ? l10n.custodyHolderEnabledMsg
            : l10n.custodyHolderDisabledMsg),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final holder = widget.holder;
    final languageCode = Localizations.localeOf(context).languageCode;
    final subtitle = holder.lastMovement == null
        ? l10n.custodyNoMovement
        : l10n.custodyLastMovement(
            formatDateString(context, holder.lastMovement));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: custodyColor(context).withValues(alpha: 0.12),
          child: Icon(custodyIcon, color: custodyColor(context)),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                holder.localizedName(languageCode),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!holder.enabled) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l10n.custodyDisabledBadge,
                    style: theme.textTheme.labelSmall),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(context, holder.balance),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.canToggle)
              Tooltip(
                message: l10n.custodyEnableTooltip,
                child: Switch(
                  value: holder.enabled,
                  onChanged: _busy ? null : _toggle,
                ),
              ),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CustodyHolderDetailScreen(holderName: holder.name),
          ),
        ),
      ),
    );
  }
}

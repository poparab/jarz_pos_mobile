import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/localization/user_error_message.dart';
import '../models/cash_custody_models.dart';
import '../state/cash_custody_notifier.dart';
import 'custody_labels.dart';
import 'widgets/custody_movement_sheet.dart';

/// A manager drilling into one holder from the list.
class CustodyHolderDetailScreen extends ConsumerWidget {
  final String holderName;
  const CustodyHolderDetailScreen({super.key, required this.holderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final holder = ref
        .watch(custodyOverviewProvider)
        .valueOrNull
        ?.holderNamed(holderName);
    return Scaffold(
      appBar: AppBar(
        title: Text(holder?.localizedName(languageCode) ?? holderName),
      ),
      body: CustodyHolderDetailView(holderName: holderName),
    );
  }
}

/// Balance, issue/return actions and the statement for one holder.
///
/// Used as the whole screen for a holder who is not a manager, and inside
/// [CustodyHolderDetailScreen] for a manager.
class CustodyHolderDetailView extends ConsumerWidget {
  final String holderName;
  const CustodyHolderDetailView({super.key, required this.holderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(custodyOverviewProvider).valueOrNull;
    final statementState = ref.watch(custodyStatementProvider(holderName));
    final statementNotifier =
        ref.read(custodyStatementProvider(holderName).notifier);
    final holder =
        overview?.holderNamed(holderName) ?? statementState.statement?.holder;

    Future<void> refresh() async {
      ref.invalidate(custodyOverviewProvider);
      await statementNotifier.load();
    }

    final children = <Widget>[];
    if (holder != null) {
      children.add(_BalanceCard(holder: holder));
      children.add(const SizedBox(height: 12));
      children.add(_Actions(holder: holder, overview: overview));
      children.add(const SizedBox(height: 16));
    }

    children.add(_StatementHeader(
      state: statementState,
      onPickRange: () async {
        final now = DateTime.now();
        final initial = statementState.hasRange
            ? DateTimeRange(
                start: statementState.fromDate!,
                end: statementState.toDate!,
              )
            : DateTimeRange(
                start: now.subtract(const Duration(days: 30)),
                end: now,
              );
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 3),
          lastDate: now.add(const Duration(days: 1)),
          initialDateRange: initial,
        );
        if (picked != null) {
          await statementNotifier.setRange(picked.start, picked.end);
        }
      },
      onClearRange: statementNotifier.clearRange,
    ));

    final statement = statementState.statement;
    if (statementState.isLoading && statement == null) {
      children.add(const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else if (statementState.error != null && statement == null) {
      children.add(Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              context.userErrorMessage(statementState.error),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: statementNotifier.load,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ));
    } else if (statement != null) {
      if (statementState.isLoading) {
        children.add(const LinearProgressIndicator(minHeight: 2));
      }
      children.add(_OpeningClosingRow(statement: statement));
      if (statement.entries.isEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(l10n.custodyStatementEmpty)),
        ));
      } else {
        for (final entry in statement.entries) {
          children.add(_StatementEntryTile(entry: entry));
        }
      }
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: children,
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final CustodyHolder holder;
  const _BalanceCard({required this.holder});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final color = custodyColor(context);
    return Card(
      color: color.withValues(alpha: 0.08),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(custodyIcon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    holder.localizedName(languageCode),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (!holder.enabled)
                  Chip(
                    label: Text(l10n.custodyDisabledBadge),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.custodyCurrentBalance, style: theme.textTheme.bodySmall),
            Text(
              formatCurrency(context, holder.balance),
              key: const Key('custody-balance'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              holder.lastMovement == null
                  ? l10n.custodyNoMovement
                  : l10n.custodyLastMovement(
                      formatDateString(context, holder.lastMovement)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  final CustodyHolder holder;
  final CustodyOverview? overview;
  const _Actions({required this.holder, required this.overview});

  Future<void> _open(
    BuildContext context,
    CustodyMovementMode mode,
    List<CustodyAccountOption> accounts,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await CustodyMovementSheet.show(
      context,
      mode: mode,
      holder: holder,
      accounts: accounts,
    );
    if (result != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.custodyPosted(result.journalEntry ?? '-')),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sources = overview?.sourceAccounts ?? const <CustodyAccountOption>[];
    final returns = overview?.returnAccounts ?? const <CustodyAccountOption>[];
    final canIssue = holder.enabled && sources.isNotEmpty;
    final canReturn = holder.balance > custodyBalanceEpsilon && returns.isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key('custody-issue-button'),
            onPressed: canIssue
                ? () => _open(context, CustodyMovementMode.issue, sources)
                : null,
            icon: const Icon(Icons.south_west),
            label: Text(l10n.custodyIssueAction, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('custody-return-button'),
            onPressed: canReturn
                ? () => _open(context, CustodyMovementMode.returnCash, returns)
                : null,
            icon: const Icon(Icons.north_east),
            label: Text(l10n.custodyReturnAction, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}

class _StatementHeader extends StatelessWidget {
  final CustodyStatementState state;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;

  const _StatementHeader({
    required this.state,
    required this.onPickRange,
    required this.onClearRange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statement = state.statement;
    String rangeLabel = l10n.custodyPickDates;
    if (state.hasRange) {
      rangeLabel = l10n.custodyRangeLabel(
        formatDate(context, state.fromDate!),
        formatDate(context, state.toDate!),
      );
    } else if (statement?.fromDate != null && statement?.toDate != null) {
      rangeLabel = l10n.custodyRangeLabel(
        formatDateString(context, statement!.fromDate),
        formatDateString(context, statement.toDate),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.custodyStatementTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(rangeLabel, overflow: TextOverflow.ellipsis),
              onPressed: onPickRange,
            ),
          ),
          if (state.hasRange)
            IconButton(
              tooltip: l10n.commonClear,
              icon: const Icon(Icons.close),
              onPressed: onClearRange,
            ),
        ],
      ),
    );
  }
}

class _OpeningClosingRow extends StatelessWidget {
  final CustodyStatement statement;
  const _OpeningClosingRow({required this.statement});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l10n.custodyOpeningBalance}: '
              '${formatCurrency(context, statement.openingBalance)}',
              style: small,
            ),
          ),
          Expanded(
            child: Text(
              '${l10n.custodyClosingBalance}: '
              '${formatCurrency(context, statement.closingBalance)}',
              style: small,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementEntryTile extends StatelessWidget {
  final CustodyStatementEntry entry;
  const _StatementEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final incoming = entry.net >= 0;
    final color = incoming ? Colors.green.shade700 : Colors.red.shade700;
    final amount = incoming ? entry.debit : entry.credit;
    final lines = <String>[
      [
        if (entry.postingDate != null)
          formatDateString(context, entry.postingDate),
        if (entry.voucherNo != null) entry.voucherNo!,
      ].join(' • '),
      if ((entry.counterLabel ?? entry.counterAccount) != null)
        l10n.custodyCounterAccount(
            (entry.counterLabel ?? entry.counterAccount)!),
      if (entry.remark != null) entry.remark!,
    ]..removeWhere((line) => line.isEmpty);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(custodyKindIcon(entry.kind), size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    custodyKindLabel(l10n, entry.kind),
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final line in lines)
                    Text(line, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${incoming ? '+' : '-'}${formatCurrency(context, amount)}',
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
                Text(
                  l10n.custodyRunningBalance(
                      formatCurrency(context, entry.balance)),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

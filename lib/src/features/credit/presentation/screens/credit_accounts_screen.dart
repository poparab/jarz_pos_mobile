import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/models/credit_models.dart';
import '../../state/credit_providers.dart';

/// Shops carrying an open credit balance, largest balance first.
///
/// This screen is deliberately NOT an overdue board. Settlement here is
/// rolling and informal — a shop pays invoice N when invoice N+1 arrives — so
/// an invoice being 40 days old is business as usual, not an incident. The
/// signals are therefore a BALANCE and an AGE, in neutral type. No red
/// "OVERDUE" chip: alarm styling on a normal state trains people to ignore it.
class CreditAccountsScreen extends ConsumerWidget {
  const CreditAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ledgerAsync = ref.watch(creditLedgerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l10n.creditAccountsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditLedgerProvider);
          await ref.read(creditLedgerProvider.future);
        },
        child: ledgerAsync.when(
          data: (ledger) => _CreditAccountsBody(ledger: ledger),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                context.userErrorMessage(
                  extractFrappeErrorMessage(
                    error,
                    fallback: l10n.creditAccountsLoadFailed,
                  ),
                  fallback: l10n.creditAccountsLoadFailed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(creditLedgerProvider),
                  child: Text(l10n.commonRetry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditAccountsBody extends StatelessWidget {
  final CreditLedger ledger;
  const _CreditAccountsBody({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final summary = ledger.summary;
    final rows = ledger.owing;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(l10n.creditAccountsSubtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        if (ledger.hasNotice) _CreditLedgerNotice(ledger: ledger),
        _CreditLedgerSummaryCard(ledger: ledger),
        const SizedBox(height: 12),
        const _CreditLedgerWindowFilter(),
        const SizedBox(height: 8),
        // Everything from here down is window-scoped, and says so. The range
        // belongs to the listed invoices, never to the balances above it.
        if (ledger.filters.fromDate.isNotEmpty &&
            ledger.filters.toDate.isNotEmpty)
          Text(
            l10n.creditAccountsActivityRange(
              formatDateString(context, ledger.filters.fromDate),
              formatDateString(context, ledger.filters.toDate),
            ),
            style: theme.textTheme.labelLarge?.copyWith(color: muted),
          ),
        Text(
          l10n.creditAccountsListedInvoiceCount(summary.invoiceCount),
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.creditAccountsEmpty),
            ),
          )
        else
          for (final row in rows) _CreditAccountTile(ledger: ledger, row: row),
      ],
    );
  }
}

/// The lookback control for the ACTIVITY FEED. Changing it never changes a
/// balance — the wording under the total says so.
class _CreditLedgerWindowFilter extends ConsumerWidget {
  const _CreditLedgerWindowFilter();

  String _label(BuildContext context, CreditLedgerWindow window) {
    final l10n = context.l10n;
    return switch (window) {
      CreditLedgerWindow.days30 => l10n.creditAccountsWindow30,
      CreditLedgerWindow.days90 => l10n.creditAccountsWindow90,
      CreditLedgerWindow.days180 => l10n.creditAccountsWindow180,
      CreditLedgerWindow.days365 => l10n.creditAccountsWindow365,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(creditLedgerWindowProvider);

    return Row(
      children: [
        Text(l10n.creditAccountsPeriodLabel),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CreditLedgerWindow>(
            value: selected,
            isExpanded: true,
            onChanged: (value) {
              if (value == null) return;
              ref.read(creditLedgerWindowProvider.notifier).state = value;
            },
            items: [
              for (final window in CreditLedgerWindow.values)
                DropdownMenuItem<CreditLedgerWindow>(
                  value: window,
                  child: Text(_label(context, window)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A `notice_code` is information, never a failure — a truncated result set
/// still leaves real money on screen, so it reads as a banner.
class _CreditLedgerNotice extends StatelessWidget {
  final CreditLedger ledger;
  const _CreditLedgerNotice({required this.ledger});

  String _message(BuildContext context) {
    final l10n = context.l10n;
    switch (ledger.noticeCode) {
      case 'results_truncated':
        return l10n.creditAccountsNoticeResultsTruncated;
      default:
        // An unknown code still carries a server-written explanation.
        return (ledger.notice ?? '').trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message(context);
    if (message.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditLedgerSummaryCard extends StatelessWidget {
  final CreditLedger ledger;
  const _CreditLedgerSummaryCard({required this.ledger});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = ledger.summary;
    // The backend reports whether the money ignores the date window. The label
    // follows that flag rather than assuming, so the card can never claim a
    // windowed figure is the whole balance.
    final allTime = summary.outstandingIsAllTime;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              allTime
                  ? l10n.creditAccountsTotalOutstandingAllTime
                  : l10n.creditAccountsTotalOutstanding,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(
                context,
                summary.totalOutstanding,
                currencyCode: summary.currency,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.creditAccountsCustomerCount(summary.customerCount),
              style: theme.textTheme.bodySmall,
            ),
            if (allTime) ...[
              const SizedBox(height: 6),
              Text(
                l10n.creditAccountsAllTimeHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One shop: balance, open invoice count, age of the oldest.
class _CreditAccountTile extends StatelessWidget {
  final CreditLedger ledger;
  final CreditCustomerRow row;
  const _CreditAccountTile({required this.ledger, required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency =
        row.currency.isNotEmpty ? row.currency : ledger.summary.currency;
    final age = row.oldestInvoiceAgeDays;

    return Card(
      child: ListTile(
        title: Text(
          row.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${l10n.creditAccountsOpenInvoiceCount(row.invoiceCount)}'
          ' • ${age == null ? l10n.creditAccountsOldestUnknown : l10n.creditAccountsOldestAge(age)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          formatCurrency(context, row.totalOutstanding, currencyCode: currency),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: () => context.push(
          AppRoutes.creditAccountDetail,
          extra: {
            'customer': row.customer,
            'customer_name': row.displayName,
          },
        ),
      ),
    );
  }
}

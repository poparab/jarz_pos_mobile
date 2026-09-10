import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/models/credit_models.dart';
import '../../state/credit_providers.dart';
import '../widgets/record_credit_payment_sheet.dart';

/// One shop's credit account: the running balance, its open invoices oldest
/// first, and the action that records a payment against them.
///
/// Oldest-first is not a display preference — it is the order the backend
/// allocates a payment in. Listing them any other way would make the FIFO
/// result look arbitrary.
class CreditAccountDetailScreen extends ConsumerWidget {
  final String customer;
  final String customerName;

  const CreditAccountDetailScreen({
    super.key,
    required this.customer,
    this.customerName = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ledgerAsync = ref.watch(creditLedgerProvider);
    final profileAsync = ref.watch(customerCreditProfileProvider(customer));

    return Scaffold(
      appBar: AppBar(
        title: Text(customerName.isNotEmpty ? customerName : customer),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(creditLedgerProvider);
          ref.invalidate(customerCreditProfileProvider(customer));
          await ref.read(creditLedgerProvider.future);
        },
        child: ledgerAsync.when(
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
            ],
          ),
          data: (ledger) {
            final row = ledger.rowFor(customer);
            final invoices = ledger.invoicesFor(customer);
            final balance = row?.totalOutstanding ?? 0;
            final currency = row?.currency.isNotEmpty == true
                ? row!.currency
                : ledger.summary.currency;

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _BalanceCard(
                  balance: balance,
                  currency: currency,
                  invoiceCount: row?.invoiceCount ?? invoices.length,
                  profile: profileAsync.valueOrNull,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(l10n.creditAccountRecordPayment),
                  onPressed: () => _recordPayment(
                    context,
                    ref,
                    balance: balance,
                    currency: currency,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.creditAccountFifoHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.creditAccountOpenInvoicesTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (invoices.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      // A balance with nothing listed is normal, not an
                      // inconsistency: the invoices are simply older than the
                      // selected window. It must never read as "nothing owed".
                      child: Text(l10n.creditAccountNoInvoicesInWindow),
                    ),
                  )
                else
                  for (final invoice in invoices)
                    _CreditInvoiceTile(invoice: invoice, currency: currency),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref, {
    required double balance,
    required String currency,
  }) async {
    final posProfile = ref.read(creditLedgerPosProfileProvider);
    final result = await RecordCreditPaymentSheet.show(
      context,
      customer: customer,
      customerName: customerName,
      balance: balance,
      currency: currency,
      initialPosProfile: posProfile,
    );
    if (result == null || !context.mounted) return;
    // FIFO means the outcome is regularly not the one the user pictured, so
    // it is read back explicitly rather than as a "saved" snackbar.
    await CreditPaymentResultDialog.show(
      context,
      result: result,
      currency: currency,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final int invoiceCount;
  final CustomerCreditProfile? profile;

  const _BalanceCard({
    required this.balance,
    required this.currency,
    required this.invoiceCount,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final creditProfile = profile;

    final terms = <String>[
      if (creditProfile != null && creditProfile.hasTerms)
        l10n.creditAccountTerms(creditProfile.creditDays),
      if (creditProfile != null && creditProfile.hasLimit) ...[
        l10n.creditAccountLimit(
          formatCurrency(
            context,
            creditProfile.creditLimit,
            currencyCode: currency,
          ),
        ),
        l10n.creditAccountAvailable(
          formatCurrency(
            context,
            creditProfile.availableCredit,
            currencyCode: currency,
          ),
        ),
      ],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.creditAccountBalanceLabel,
              style: theme.textTheme.labelLarge?.copyWith(color: muted),
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(context, balance, currencyCode: currency),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.creditAccountsOpenInvoiceCount(invoiceCount),
              style: theme.textTheme.bodySmall,
            ),
            if (terms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                terms.join(' • '),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One open invoice. The age is a neutral fact, not an alarm: with rolling
/// settlement an invoice waiting on the next delivery is the normal state.
class _CreditInvoiceTile extends StatelessWidget {
  final CreditInvoice invoice;
  final String currency;

  const _CreditInvoiceTile({required this.invoice, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final age = invoice.ageDays;
    final effectiveCurrency =
        invoice.currency.isNotEmpty ? invoice.currency : currency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.displayId,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDateString(context, invoice.postingDate),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (age != null)
                    Text(
                      l10n.creditAccountInvoiceAge(age),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.creditAccountInvoiceOutstandingLabel,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
                Text(
                  formatCurrency(
                    context,
                    invoice.outstandingAmount,
                    currencyCode: effectiveCurrency,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Only worth showing when a partial payment has already been
                // applied — otherwise it repeats the outstanding amount.
                if ((invoice.grandTotal - invoice.outstandingAmount).abs() >=
                    0.005)
                  Text(
                    '${l10n.creditAccountInvoiceTotalLabel} '
                    '${formatCurrency(context, invoice.grandTotal, currencyCode: effectiveCurrency)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

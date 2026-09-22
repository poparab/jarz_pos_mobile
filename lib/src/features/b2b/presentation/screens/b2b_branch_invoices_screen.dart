import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_display_mappers.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/b2b_repository.dart';
import '../../data/models/b2b_models.dart';

/// Every invoice of a B2B account, filterable per branch. A shop with several
/// branches is billed on one Customer; the branch is the shipping Address each
/// invoice went to, so this screen answers "what did branch X order and owe".
class B2bBranchInvoicesScreen extends ConsumerStatefulWidget {
  final String doctype;
  final String name;
  final String accountTitle;
  final List<B2bBranch> branches;

  /// Whether to offer the "Unassigned" filter (invoices matching no branch).
  final bool hasUnassigned;

  /// The branch filter to open on: an `address_name`,
  /// [B2bRepository.unassignedBranch], or null for all invoices.
  final String? initialBranch;

  const B2bBranchInvoicesScreen({
    super.key,
    required this.doctype,
    required this.name,
    required this.accountTitle,
    this.branches = const [],
    this.hasUnassigned = false,
    this.initialBranch,
  });

  @override
  ConsumerState<B2bBranchInvoicesScreen> createState() =>
      _B2bBranchInvoicesScreenState();
}

class _B2bBranchInvoicesScreenState
    extends ConsumerState<B2bBranchInvoicesScreen> {
  String? _branch;
  late Future<B2bAccountInvoices> _future;

  @override
  void initState() {
    super.initState();
    _branch = widget.initialBranch;
    _future = _load();
  }

  Future<B2bAccountInvoices> _load() {
    return ref
        .read(b2bRepositoryProvider)
        .getAccountInvoices(
          doctype: widget.doctype,
          name: widget.name,
          branch: _branch,
        );
  }

  void _select(String? branch) {
    if (branch == _branch) return;
    setState(() {
      _branch = branch;
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      // The FutureBuilder renders the failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.b2bInvoicesTitle),
            Text(
              widget.accountTitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _filters(context),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<B2bAccountInvoices>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          context.userErrorMessage(snapshot.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: FilledButton(
                            onPressed: _refresh,
                            child: Text(l10n.commonRetry),
                          ),
                        ),
                      ],
                    );
                  }
                  return _list(context, snapshot.requireData);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final l10n = context.l10n;
    final chips = <Widget>[
      ChoiceChip(
        label: Text(l10n.b2bFilterAllBranches),
        selected: _branch == null,
        onSelected: (_) => _select(null),
      ),
      for (final branch in widget.branches)
        if (branch.key.isNotEmpty)
          ChoiceChip(
            label: Text(branch.displayName),
            selected: _branch == branch.key,
            onSelected: (_) => _select(branch.key),
          ),
      if (widget.hasUnassigned)
        ChoiceChip(
          label: Text(l10n.b2bUnassignedShort),
          selected: _branch == B2bRepository.unassignedBranch,
          onSelected: (_) => _select(B2bRepository.unassignedBranch),
        ),
    ];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  Widget _list(BuildContext context, B2bAccountInvoices data) {
    final l10n = context.l10n;
    final showBranch = _branch == null;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      children: [
        _SummaryCard(summary: data.summary),
        if (data.truncated)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.b2bInvoicesTruncated(data.invoices.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 8),
        if (data.invoices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              l10n.b2bNoInvoicesForSelection,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final invoice in data.invoices)
            B2bInvoiceTile(invoice: invoice, showBranch: showBranch),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final B2bBranchStats summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasOutstanding = summary.outstanding > 0.005;
    Widget cell(String label, String value, {Color? color}) => Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            cell(l10n.b2bSummaryInvoices, '${summary.invoiceCount}'),
            cell(
              l10n.b2bSummaryBilled,
              formatCurrency(context, summary.totalBilled),
            ),
            cell(
              l10n.b2bSummaryOutstanding,
              formatCurrency(context, summary.outstanding),
              color: hasOutstanding ? theme.colorScheme.error : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// One invoice row: display id, date, purpose, payment method, status, the
/// branch it went to (when not already filtered to one), amount and what is
/// still owed.
class B2bInvoiceTile extends StatelessWidget {
  final B2bRecentInvoice invoice;
  final bool showBranch;

  const B2bInvoiceTile({
    super.key,
    required this.invoice,
    this.showBranch = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final outstanding = invoice.outstandingAmount ?? 0;
    final details = <String>[
      if (invoice.postingDate case final date? when date.isNotEmpty) date,
      if (invoice.orderPurpose case final purpose? when purpose.isNotEmpty)
        purpose,
      if (invoice.paymentMethod != null)
        localizedPaymentMethodLabel(context, invoice.paymentMethod),
      if (invoice.status case final status? when status.isNotEmpty)
        localizedStatusLabel(context, status),
    ];
    final branch = invoice.branchName ?? invoice.branchAddress;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Flexible(
              child: Text(
                invoice.displayId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (invoice.isReturn) ...[
              const SizedBox(width: 6),
              _Badge(
                text: l10n.b2bInvoiceReturn,
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty) Text(details.join(' · ')),
            if (showBranch)
              Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      branch ?? l10n.b2bUnassignedShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              invoice.grandTotal == null
                  ? ''
                  : formatCurrency(context, invoice.grandTotal!),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (outstanding > 0.005)
              Text(
                l10n.b2bOutstandingAmount(formatCurrency(context, outstanding)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

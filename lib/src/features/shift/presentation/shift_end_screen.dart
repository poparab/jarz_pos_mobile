import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization_extensions.dart';
import '../models/shift_models.dart';
import '../state/shift_notifier.dart';

class ShiftEndScreen extends ConsumerStatefulWidget {
  const ShiftEndScreen({super.key});

  @override
  ConsumerState<ShiftEndScreen> createState() => _ShiftEndScreenState();
}

class _ShiftEndScreenState extends ConsumerState<ShiftEndScreen> {
  final Map<String, TextEditingController> _controllers = {};
  ShiftSummary? _endResult;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shiftState = ref.watch(shiftNotifierProvider);
    final activeShiftAsync = ref.watch(activeShiftProvider);

    // Show post-close summary if shift was just ended
    if (_endResult != null) {
      return _buildClosedSummary(context, _endResult!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftEndTitle)),
      body: activeShiftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load active shift: $e')),
        data: (activeShift) {
          if (activeShift == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.shiftNoActive),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/pos'),
                    child: Text(l10n.shiftBackToPos),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder(
            future: ref.read(shiftNotifierProvider.notifier).getCurrentShiftSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final summary = snapshot.data;
              if (summary == null) {
                return const Center(child: Text('Unable to load shift summary.'));
              }

              return _buildPreCloseView(context, summary, shiftState);
            },
          );
        },
      ),
    );
  }

  // ── Pre-close view: invoices table + closing input ──

  Widget _buildPreCloseView(BuildContext context, ShiftSummary summary, ShiftState shiftState) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header info ──
          Text('Shift: ${summary.openingEntry}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _infoRow(l10n.shiftInvoices(summary.invoiceCount), Icons.receipt_long),
          _infoRow(l10n.shiftGrandTotal(summary.grandTotal.toStringAsFixed(2)), Icons.attach_money),
          if (summary.account != null)
            _infoRow(
              '${l10n.shiftAccountBalance}: ${summary.accountBalance.toStringAsFixed(2)}',
              Icons.account_balance,
            ),
          const Divider(height: 24),

          // ── Closing balance input ──
          Text(l10n.shiftClosingPrompt, style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          ...summary.paymentReconciliation.map((row) {
            final controller = _controllers.putIfAbsent(
              row.modeOfPayment,
              () => TextEditingController(text: row.expectedAmount.toStringAsFixed(2)),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row.modeOfPayment} (${l10n.shiftExpectedAmount(row.expectedAmount.toStringAsFixed(2))})',
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.shiftClosingAmountLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  Builder(builder: (context) {
                    final confirmed = double.tryParse(controller.text) ?? 0;
                    final diff = confirmed - row.expectedAmount;
                    if (diff == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${l10n.shiftDifference}: ${diff.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: diff > 0 ? Colors.green : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          // ── Sales Invoices list ──
          if (summary.salesInvoices.isNotEmpty) ...[
            const Divider(height: 24),
            Text(l10n.shiftSalesInvoices, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Expanded(child: _buildInvoicesTable(context, summary.salesInvoices)),
          ] else
            const Expanded(child: SizedBox.shrink()),

          // ── Error ──
          if (shiftState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                shiftState.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          // ── End Shift button ──
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: shiftState.isLoading ? null : () => _handleEndShift(summary),
              child: Text(l10n.shiftEndButton),
            ),
          ),
        ],
      ),
    );
  }

  // ── Post-close summary ──

  Widget _buildClosedSummary(BuildContext context, ShiftSummary result) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftClosedSummaryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.shiftEndedSuccess, style: theme.textTheme.titleMedium?.copyWith(color: Colors.green)),
            const SizedBox(height: 12),
            if (result.closingEntry != null)
              _infoRow('${l10n.shiftClosingEntry}: ${result.closingEntry}', Icons.check_circle),
            _infoRow(l10n.shiftInvoices(result.invoiceCount), Icons.receipt_long),
            _infoRow(l10n.shiftGrandTotal(result.grandTotal.toStringAsFixed(2)), Icons.attach_money),
            if (result.account != null)
              _infoRow(
                '${l10n.shiftAccountBalance}: ${result.accountBalance.toStringAsFixed(2)}',
                Icons.account_balance,
              ),
            if (result.journalEntry != null && result.journalEntry!.isNotEmpty && result.journalEntry != 'null')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.shiftJournalCreated}: ${result.journalEntry}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Payment reconciliation ──
            const Divider(height: 24),
            ...result.paymentReconciliation.map((row) {
              final diff = row.closingAmount - row.expectedAmount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row.modeOfPayment, style: theme.textTheme.bodyMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.shiftExpectedAmount(row.expectedAmount.toStringAsFixed(2))),
                        Text(
                          '${l10n.shiftClosingAmountLabel}: ${row.closingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: diff == 0 ? null : (diff > 0 ? Colors.green : theme.colorScheme.error),
                            fontWeight: diff == 0 ? null : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            // ── Sales Invoices ──
            if (result.salesInvoices.isNotEmpty) ...[
              const Divider(height: 24),
              Text(l10n.shiftSalesInvoices, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Expanded(child: _buildInvoicesTable(context, result.salesInvoices)),
            ] else
              const Expanded(child: SizedBox.shrink()),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.invalidate(activeShiftProvider);
                  context.go('/pos');
                },
                child: Text(l10n.shiftBackToPos),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _infoRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable(BuildContext context, List<ShiftInvoice> invoices) {
    final l10n = context.l10n;
    return ListView.separated(
      shrinkWrap: true,
      itemCount: invoices.length,
      separatorBuilder: (context2, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(
            '${inv.customerName}  •  ${inv.deliveryStatus ?? l10n.shiftNoDeliveryStatus}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            inv.grandTotal.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }

  Future<void> _handleEndShift(ShiftSummary summary) async {
    final balances = summary.paymentReconciliation.map((row) {
      final text = _controllers[row.modeOfPayment]?.text ?? '0';
      final amount = double.tryParse(text) ?? 0;
      return {
        'mode_of_payment': row.modeOfPayment,
        'closing_amount': amount,
      };
    }).toList();

    final result = await ref
        .read(shiftNotifierProvider.notifier)
        .endShift(closingBalances: balances);

    if (!mounted) return;
    if (result != null) {
      ref.invalidate(activeShiftProvider);
      setState(() {
        _endResult = result;
      });
    }
  }
}

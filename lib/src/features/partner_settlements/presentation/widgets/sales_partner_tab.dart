import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/partner_settlements_service.dart';

/// One row per Sales Partner's unsettled commission. Settling posts the
/// batch commission + VAT recognition journal entry for EVERY unsettled
/// transaction that partner has — there is no per-transaction reconciliation
/// here, unlike the Delivery Partner tab, because the backend endpoint
/// itself aggregates the whole unsettled set.
class SalesPartnerTab extends ConsumerStatefulWidget {
  const SalesPartnerTab({super.key});

  @override
  ConsumerState<SalesPartnerTab> createState() => _SalesPartnerTabState();
}

class _SalesPartnerTabState extends ConsumerState<SalesPartnerTab> {
  List<Map<String, dynamic>> _balances = const [];
  bool _loading = true;
  bool _submitting = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(partnerSettlementsServiceProvider);
      final balances = await service.getSalesPartnerBalances();
      if (!mounted) return;
      setState(() => _balances = balances);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndSettle(Map<String, dynamic> row) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final salesPartner = (row['sales_partner'] ?? '').toString();
    final base = (row['total_base'] as num?)?.toDouble() ?? 0.0;
    final vat = (row['total_vat'] as num?)?.toDouble() ?? 0.0;
    final total = (row['total_fees'] as num?)?.toDouble() ?? 0.0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(dialogL10n.partnerSettlementSalesConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogL10n.partnerSettlementSalesConfirmMessage),
              const Divider(height: 20),
              _line(
                dialogL10n.partnerSettlementCommissionLabel,
                formatCurrency(dialogContext, base),
              ),
              _line(
                dialogL10n.partnerSettlementVatLabel,
                formatCurrency(dialogContext, vat),
              ),
              const Divider(height: 20),
              _line(
                dialogL10n.partnerSettlementFeeTotalLabel,
                formatCurrency(dialogContext, total),
                emphasize: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogL10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(dialogL10n.commonConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final service = ref.read(partnerSettlementsServiceProvider);
      final result = await service.settleSalesPartner(
        salesPartner: salesPartner,
      );
      if (!mounted) return;
      final journalEntry = result['journal_entry'];
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            journalEntry == null
                ? l10n.partnerSettlementSalesNothingToSettle
                : l10n.partnerSettlementSettledMessage('$journalEntry'),
          ),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _line(String label, String value, {bool emphasize = false}) {
    final style = emphasize
        ? const TextStyle(fontWeight: FontWeight.w700)
        : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.userErrorMessage(_error.toString())),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    }
    if (_balances.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(l10n.partnerSettlementSalesEmptyBalances),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _balances.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = _balances[index];
              final salesPartner = (row['sales_partner'] ?? '').toString();
              final orderCount = (row['order_count'] as num?)?.toInt() ?? 0;
              final onlineFees =
                  (row['online_fees'] as num?)?.toDouble() ?? 0.0;
              final cashFees = (row['cash_fees'] as num?)?.toDouble() ?? 0.0;
              final totalFees = (row['total_fees'] as num?)?.toDouble() ?? 0.0;

              return ListTile(
                leading: const Icon(Icons.handshake_outlined),
                title: Text(salesPartner),
                subtitle: Text(
                  '${l10n.partnerSettlementOrderCount(orderCount)} • '
                  '${l10n.partnerSettlementOnlineCashSplit(
                    formatCurrency(context, onlineFees),
                    formatCurrency(context, cashFees),
                  )}',
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(context, totalFees),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed:
                          _submitting ? null : () => _confirmAndSettle(row),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.partnerSettlementSettleCommissionButton),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_submitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

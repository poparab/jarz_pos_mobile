import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/partner_settlements_service.dart';

/// One editable extra-charge line: a subscription, waiting time, a
/// returned-trip charge — anything the partner bills that never accrued
/// per order. Kept as controllers rather than a Freezed model since this
/// state never leaves the widget.
class _ChargeRow {
  final TextEditingController description = TextEditingController();
  final TextEditingController amount = TextEditingController();

  double get amountValue => double.tryParse(amount.text.trim()) ?? 0.0;

  void dispose() {
    description.dispose();
    amount.dispose();
  }
}

/// The reconciliation screen for one Delivery Partner's weekly bank
/// transfer: tick only the trips whose fee matches the partner's own
/// invoice, add whatever fixed charges are on it, confirm, and post.
///
/// Anything left unticked stays unbilled and reappears on next week's list —
/// this screen makes that explicit rather than offering a single "pay all".
class DeliveryPartnerSettleScreen extends ConsumerStatefulWidget {
  const DeliveryPartnerSettleScreen({
    super.key,
    required this.deliveryPartner,
    required this.displayName,
  });

  final String deliveryPartner;
  final String displayName;

  @override
  ConsumerState<DeliveryPartnerSettleScreen> createState() =>
      _DeliveryPartnerSettleScreenState();
}

class _DeliveryPartnerSettleScreenState
    extends ConsumerState<DeliveryPartnerSettleScreen> {
  List<Map<String, dynamic>> _trips = const [];
  final Set<String> _selected = {};
  final List<_ChargeRow> _charges = [];
  final _bankAccountCtrl = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bankAccountCtrl.dispose();
    for (final c in _charges) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(partnerSettlementsServiceProvider);
      final trips = await service.getDeliveryPartnerUnsettledDetails(
        widget.deliveryPartner,
      );
      if (!mounted) return;
      setState(() {
        _trips = trips;
        // Nothing is pre-ticked: this moves real money, so the operator must
        // affirmatively agree with a trip (or use "select all") rather than
        // settling everything by default and unticking exceptions.
        _selected.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _feesTotal {
    double sum = 0;
    for (final trip in _trips) {
      final name = (trip['name'] ?? '').toString();
      if (!_selected.contains(name)) continue;
      sum += (trip['fee'] as num?)?.toDouble() ??
          (trip['partner_fee'] as num?)?.toDouble() ??
          0.0;
    }
    return sum;
  }

  List<Map<String, dynamic>> get _extraChargesPayload => _charges
      .where((c) => c.amountValue != 0)
      .map((c) => {
            'description': c.description.text.trim(),
            'amount': c.amountValue,
          })
      .toList();

  double get _chargesTotal =>
      _charges.fold(0.0, (sum, c) => sum + c.amountValue);

  double get _grandTotal => _feesTotal + _chargesTotal;

  bool get _canSettle => _selected.isNotEmpty || _chargesTotal != 0;

  void _addCharge() {
    setState(() => _charges.add(_ChargeRow()));
  }

  void _removeCharge(int index) {
    setState(() => _charges.removeAt(index).dispose());
  }

  void _toggleAll(bool select) {
    setState(() {
      _selected.clear();
      if (select) {
        _selected.addAll(_trips.map((t) => (t['name'] ?? '').toString()));
      }
    });
  }

  Future<void> _confirmAndSubmit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    if (!_canSettle) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.partnerSettlementNothingToSettle)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(dialogL10n.partnerSettlementConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogL10n.partnerSettlementConfirmMessage),
              const SizedBox(height: 12),
              Text(dialogL10n.partnerSettlementConfirmTripsLine(
                _selected.length,
              )),
              Text(dialogL10n.partnerSettlementConfirmChargesLine(
                _extraChargesPayload.length,
              )),
              const Divider(height: 20),
              _summaryLine(
                dialogL10n.partnerSettlementFeesSubtotal,
                formatCurrency(dialogContext, _feesTotal),
              ),
              _summaryLine(
                dialogL10n.partnerSettlementChargesSubtotal,
                formatCurrency(dialogContext, _chargesTotal),
              ),
              const Divider(height: 20),
              _summaryLine(
                dialogL10n.partnerSettlementGrandTotal,
                formatCurrency(dialogContext, _grandTotal),
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
      final result = await service.settleDeliveryPartner(
        deliveryPartner: widget.deliveryPartner,
        bankAccount: _bankAccountCtrl.text.trim().isEmpty
            ? null
            : _bankAccountCtrl.text.trim(),
        courierTransactions: _selected.toList(),
        extraCharges: _extraChargesPayload,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.partnerSettlementSettledMessage(
              '${result['journal_entry'] ?? ''}',
            ),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _summaryLine(String label, String value, {bool emphasize = false}) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.partnerSettlementTripsTitle(widget.displayName)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.userErrorMessage(_error.toString())),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _load,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              : _buildContent(context, l10n),
      bottomNavigationBar: (_loading || _error != null)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _summaryLine(
                      l10n.partnerSettlementFeesSubtotal,
                      formatCurrency(context, _feesTotal),
                    ),
                    _summaryLine(
                      l10n.partnerSettlementChargesSubtotal,
                      formatCurrency(context, _chargesTotal),
                    ),
                    const Divider(),
                    _summaryLine(
                      l10n.partnerSettlementGrandTotal,
                      formatCurrency(context, _grandTotal),
                      emphasize: true,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_submitting || !_canSettle)
                            ? null
                            : _confirmAndSubmit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(l10n.partnerSettlementSettleButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.partnerSettlementSelectedOfTotal(
                _selected.length,
                _trips.length,
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _trips.isEmpty ? null : () => _toggleAll(true),
                  child: Text(l10n.partnerSettlementSelectAll),
                ),
                TextButton(
                  onPressed: _trips.isEmpty ? null : () => _toggleAll(false),
                  child: Text(l10n.partnerSettlementDeselectAll),
                ),
              ],
            ),
          ],
        ),
        if (_selected.length < _trips.length)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l10n.partnerSettlementUnselectedWarning,
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ),
        if (_trips.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(l10n.partnerSettlementTripsEmpty)),
          )
        else
          ..._trips.map((trip) {
            final name = (trip['name'] ?? '').toString();
            final invoice = (trip['invoice'] ??
                    trip['reference_invoice'] ??
                    '')
                .toString();
            final fee = (trip['fee'] as num?)?.toDouble() ??
                (trip['partner_fee'] as num?)?.toDouble() ??
                0.0;
            final date = trip['date']?.toString();
            return CheckboxListTile(
              key: ValueKey(name),
              value: _selected.contains(name),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(name);
                  } else {
                    _selected.remove(name);
                  }
                });
              },
              title: Text(
                invoice.isEmpty
                    ? l10n.partnerSettlementTripNoInvoice
                    : l10n.partnerSettlementTripInvoiceLabel(invoice),
              ),
              subtitle: date == null
                  ? null
                  : Text(formatDateString(context, date)),
              secondary: Text(
                formatCurrency(context, fee),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.partnerSettlementExtraChargesTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addCharge,
              icon: const Icon(Icons.add),
              label: Text(l10n.partnerSettlementAddCharge),
            ),
          ],
        ),
        Text(
          l10n.partnerSettlementExtraChargesHint,
          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (_charges.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.partnerSettlementNoCharges),
          )
        else
          ..._charges.asMap().entries.map((entry) {
            final index = entry.key;
            final charge = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: charge.description,
                      decoration: InputDecoration(
                        labelText: l10n.partnerSettlementChargeLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: charge.amount,
                      decoration: InputDecoration(
                        labelText: l10n.partnerSettlementChargeAmount,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.partnerSettlementRemoveCharge,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeCharge(index),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bankAccountCtrl,
          decoration: InputDecoration(
            labelText: l10n.partnerSettlementBankAccountOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

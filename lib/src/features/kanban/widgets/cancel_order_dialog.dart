import 'package:flutter/material.dart';

import '../models/kanban_models.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/localization/localization_extensions.dart';

class CancelOrderResult {
  final String reason;
  final String? notes;

  const CancelOrderResult({required this.reason, this.notes});
}

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({super.key, required this.invoice});

  final InvoiceCard invoice;

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  static const List<String> _presetReasons = CancelReasons.defaults;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customReasonController = TextEditingController();
  String? _selectedReason;

  @override
  void dispose() {
    _notesController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final invoice = widget.invoice;
    final isPaid = invoice.isFullyPaid;
    final hasPartial = invoice.hasPartialPayment;
    final totalLabel = _formatCurrency(invoice.grandTotal);
    final outstandingLabel = _formatCurrency(invoice.outstandingAmount);

    return AlertDialog(
      title: Text(l10n.cancelOrderTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cancelOrderInvoiceLabel(invoice.invoiceIdShort.isNotEmpty ? invoice.invoiceIdShort : invoice.id),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.cancelOrderTotalLabel(totalLabel)),
              if (!isPaid) Text(l10n.cancelOrderOutstandingLabel(outstandingLabel)),
              const SizedBox(height: 12),
              if (hasPartial)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.orange.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    l10n.cancelOrderPartialPaymentWarning,
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedReason ?? 'none'),
                decoration: InputDecoration(
                  labelText: l10n.cancelOrderReasonLabel,
                ),
                initialValue: _selectedReason,
                items: _presetReasons
                    .map(
                      (reason) => DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return l10n.cancelOrderSelectReasonValidation;
                  }
                  if (value == 'Other' && _customReasonController.text.trim().isEmpty) {
                    return l10n.cancelOrderProvideReasonValidation;
                  }
                  return null;
                },
              ),
              if (_selectedReason == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customReasonController,
                  decoration: InputDecoration(
                    labelText: l10n.cancelOrderCustomReasonLabel,
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return l10n.cancelOrderDescribeReasonValidation;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.cancelOrderAdditionalNotesOptional,
                ),
                minLines: 2,
                maxLines: 4,
              ),
              if (isPaid) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.teal.withValues(alpha: 0.12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.cancelOrderCreditNoteInfo,
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
        FilledButton(
          onPressed: hasPartial
              ? null
              : () {
                  if (_formKey.currentState?.validate() != true) {
                    return;
                  }
                  final reason = _selectedReason == 'Other'
                      ? _customReasonController.text.trim()
                      : (_selectedReason ?? '').trim();
                  final notes = _notesController.text.trim();
                  Navigator.of(context).pop(
                    CancelOrderResult(
                      reason: reason,
                      notes: notes.isEmpty ? null : notes,
                    ),
                  );
                },
          child: Text(l10n.cancelOrderConfirmButton),
        ),
      ],
    );
  }
}

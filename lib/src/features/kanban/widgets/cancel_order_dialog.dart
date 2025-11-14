import 'package:flutter/material.dart';

import '../models/kanban_models.dart';

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
  static const List<String> _presetReasons = <String>[
    'Customer requested cancellation',
    'Order created in error / duplicate',
    'Inventory unavailable',
    'Payment issue',
    'Other',
  ];

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
    final invoice = widget.invoice;
    final isPaid = invoice.isFullyPaid;
    final hasPartial = invoice.hasPartialPayment;
    final totalLabel = _formatCurrency(invoice.grandTotal);
    final outstandingLabel = _formatCurrency(invoice.outstandingAmount);

    return AlertDialog(
      title: const Text('Cancel Order'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice: ${invoice.invoiceIdShort.isNotEmpty ? invoice.invoiceIdShort : invoice.id}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text('Total: $totalLabel'),
              if (!isPaid) Text('Outstanding: $outstandingLabel'),
              const SizedBox(height: 12),
              if (hasPartial)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.orange.withValues(alpha: 0.15),
                  ),
                  child: const Text(
                    'This invoice has a partial payment. Please settle or refund the payment before cancelling.',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedReason ?? 'none'),
                decoration: const InputDecoration(
                  labelText: 'Cancellation reason',
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
                    return 'Select a reason to continue';
                  }
                  if (value == 'Other' && _customReasonController.text.trim().isEmpty) {
                    return 'Provide a reason';
                  }
                  return null;
                },
              ),
              if (_selectedReason == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Custom reason',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please describe the cancellation reason';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional notes (optional)',
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
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A credit note will be issued automatically so the accounts stay balanced.',
                          style: TextStyle(color: Colors.teal),
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
          child: const Text('Close'),
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
          child: const Text('Confirm cancellation'),
        ),
      ],
    );
  }
}

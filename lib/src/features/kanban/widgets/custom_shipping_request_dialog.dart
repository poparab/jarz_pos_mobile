import 'package:flutter/material.dart';

/// Dialog for requesting custom shipping expense on an invoice.
class CustomShippingRequestDialog extends StatefulWidget {
  final String invoiceName;
  final double currentShippingExpense;

  const CustomShippingRequestDialog({
    super.key,
    required this.invoiceName,
    required this.currentShippingExpense,
  });

  @override
  State<CustomShippingRequestDialog> createState() => _CustomShippingRequestDialogState();
}

class _CustomShippingRequestDialogState extends State<CustomShippingRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.deepOrange),
          const SizedBox(width: 8),
          const Expanded(child: Text('Request Custom Shipping', style: TextStyle(fontSize: 16))),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current shipping expense (read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Shipping', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    Text(
                      '\$${widget.currentShippingExpense.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Requested Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Amount is required';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Reason input
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Why custom shipping is needed...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please provide a reason (min 10 characters)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'amount': double.parse(_amountController.text),
                'reason': _reasonController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

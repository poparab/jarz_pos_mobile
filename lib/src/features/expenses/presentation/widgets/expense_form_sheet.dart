import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/expense_models.dart';
import '../../state/expenses_notifier.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final bool isManager;
  final List<ExpenseReason> reasons;
  final List<ExpensePaymentSource> paymentSources;

  const ExpenseFormSheet({
    super.key,
    required this.isManager,
    required this.reasons,
    required this.paymentSources,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseReason? _selectedReason;
  ExpensePaymentSource? _selectedSource;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.reasons.isNotEmpty) {
      _selectedReason = widget.reasons.first;
    }
    if (widget.paymentSources.isNotEmpty) {
      _selectedSource = widget.paymentSources.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel = DateFormat('MMMM d, yyyy').format(_selectedDate);
    final submitLabel = widget.isManager ? 'Record expense' : 'Submit for approval';
    final hasOptions = widget.reasons.isNotEmpty && widget.paymentSources.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Expense',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final amount = double.tryParse(trimmed);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expense date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateLabel),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseReason>(
                value: _selectedReason,
                items: widget.reasons
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason.label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
                decoration: const InputDecoration(
                  labelText: 'Reason (Indirect expense account)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Select a reason' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpensePaymentSource>(
                value: _selectedSource,
                items: widget.paymentSources
                    .map((source) => DropdownMenuItem(
                          value: source,
                          child: Text('${source.label}${_extraLabel(source)}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSource = value),
                decoration: const InputDecoration(
                  labelText: 'Pay from',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Select a payment source' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: !_submitting && hasOptions ? _handleSubmit : null,
                  child: _submitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(submitLabel),
                ),
              ),
              if (!hasOptions)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Expenses cannot be created until a reason and payment source are available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(expensesNotifierProvider.notifier);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final reason = _selectedReason!;
    final source = _selectedSource!;
    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() => _submitting = true);
    final record = await notifier.createExpense(
      amount: amount,
      reasonAccount: reason.account,
      expenseDate: isoDate,
      remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      posProfile: widget.isManager ? source.posProfile : source.posProfile ?? source.label,
      payingAccount: widget.isManager ? source.account : null,
      paymentSourceType: widget.isManager ? _typeLabel(source) : null,
      paymentLabel: source.label,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (record != null) {
      Navigator.of(context).pop(record);
    }
  }

  String _extraLabel(ExpensePaymentSource source) {
    if (source.posProfile != null && source.posProfile!.isNotEmpty && source.posProfile != source.label) {
      return ' • ${source.posProfile}';
    }
    return '';
  }

  String _typeLabel(ExpensePaymentSource source) {
    switch (source.category) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank';
      case 'mobile':
        return 'Mobile Wallet';
      case 'pos_profile':
        return 'POS Profile';
      default:
        return 'Account';
    }
  }
}

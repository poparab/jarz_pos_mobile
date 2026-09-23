import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../../cash_custody/models/cash_custody_models.dart'
    show custodyBalanceEpsilon;
import '../../../cash_custody/presentation/custody_labels.dart';
import '../../models/expense_models.dart';
import '../../state/expenses_notifier.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final bool isManager;
  final List<ExpenseReason> reasons;
  final List<ExpensePaymentSource> paymentSources;

  /// The caller's own custody account, so it reads "My custody" rather than
  /// the holder's name.
  final String? custodyAccount;

  const ExpenseFormSheet({
    super.key,
    required this.isManager,
    required this.reasons,
    required this.paymentSources,
    this.custodyAccount,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  /// Whether the operator picked a clock time.
  ///
  /// False keeps the legacy date-only request, so an untouched picker still
  /// lets the server stamp the time from its own clock rather than from a
  /// tablet's.
  bool _timeExplicit = false;
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
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final dateLabel = _timeExplicit
        ? formatDateTime(context, _selectedDate,
            pattern: 'MMMM d, yyyy • h:mm a')
        : formatDate(context, _selectedDate, pattern: 'MMMM d, yyyy');
    final submitLabel = widget.isManager ? l10n.expensesSubmitManager : l10n.expensesSubmitStaff;
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
                    l10n.expensesNewExpense,
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
                decoration: InputDecoration(
                  labelText: l10n.expensesAmountLabel,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final amount = double.tryParse(trimmed);
                  if (amount == null || amount <= 0) {
                    return l10n.expensesAmountInvalid;
                  }
                  // A custody can never go negative. The server enforces it;
                  // this only saves the round trip and says why.
                  final source = _selectedSource;
                  if (source != null &&
                      source.isCustody &&
                      amount > source.balance + custodyBalanceEpsilon) {
                    return l10n.custodyAmountExceedsBalance(
                      formatCurrency(context, source.balance),
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await pickPostingDateTime(
                    context,
                    initial: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _timeExplicit = true;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.expensesDateLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(dateLabel),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseReason>(
                key: ValueKey<String?>(_selectedReason?.account),
                initialValue: _selectedReason,
                items: widget.reasons
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                      child: Text(reason.localizedLabel(languageCode)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
                decoration: InputDecoration(
                  labelText: l10n.expensesReasonLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null ? l10n.expensesReasonRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpensePaymentSource>(
                key: ValueKey<String?>(_selectedSource?.account ?? _selectedSource?.label),
                initialValue: _selectedSource,
                isExpanded: true,
                items: widget.paymentSources
                    .map((source) {
                      if (source.isCustody) {
                        return DropdownMenuItem(
                          value: source,
                          child: _custodyItem(context, source, languageCode),
                        );
                      }
                      final sourceLabel = source.localizedLabel(languageCode);
                      return DropdownMenuItem(
                        value: source,
                        child: Text(
                          '$sourceLabel${_extraLabel(source)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSource = value);
                  // Re-check the amount against the newly chosen balance.
                  if (_amountController.text.trim().isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
                decoration: InputDecoration(
                  labelText: l10n.expensesPayFromLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null ? l10n.expensesPaymentSourceRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.expensesRemarksLabel,
                  border: const OutlineInputBorder(),
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
                    l10n.expensesNoOptions,
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
    final isoDate = _timeExplicit
        ? formatPostingDateTimeForApi(_selectedDate)
        : formatPostingDateForApi(_selectedDate);

    setState(() => _submitting = true);
    // A custody is paid by account, never through a POS profile: both a
    // holder and a manager send its account with source type "custody".
    // Every other source keeps its original request shape.
    final isCustody = source.isCustody;
    final record = await notifier.createExpense(
      amount: amount,
      reasonAccount: reason.account,
      expenseDate: isoDate,
      remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      posProfile: isCustody
          ? null
          : (widget.isManager ? source.posProfile : source.posProfile ?? source.label),
      payingAccount: isCustody || widget.isManager ? source.account : null,
      paymentSourceType: isCustody
          ? 'custody'
          : (widget.isManager ? _typeLabel(context, source) : null),
      paymentLabel: source.label,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (record != null) {
      Navigator.of(context).pop(record);
    }
  }

  Widget _custodyItem(
    BuildContext context,
    ExpensePaymentSource source,
    String languageCode,
  ) {
    final l10n = context.l10n;
    final isMine = widget.custodyAccount != null &&
        source.account == widget.custodyAccount;
    final label = isMine
        ? l10n.custodyMine
        : custodyDisplayLabel(l10n, source.localizedLabel(languageCode));
    return Row(
      children: [
        Icon(custodyIcon, size: 18, color: custodyColor(context)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(formatCurrency(context, source.balance)),
      ],
    );
  }

  String _extraLabel(ExpensePaymentSource source) {
    if (source.posProfile != null && source.posProfile!.isNotEmpty && source.posProfile != source.label) {
      return ' • ${source.posProfile}';
    }
    return '';
  }

  String _typeLabel(BuildContext context, ExpensePaymentSource source) {
    final l10n = context.l10n;
    switch (source.category) {
      case 'cash':
        return l10n.expenseSourceCash;
      case 'bank':
        return l10n.expenseSourceBank;
      case 'mobile':
        return l10n.expenseSourceMobileWallet;
      case 'pos_profile':
        return l10n.expenseSourcePosProfile;
      default:
        return l10n.expenseSourceAccount;
    }
  }
}

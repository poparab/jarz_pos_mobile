import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../models/monthly_expense_models.dart';
import '../../state/monthly_expenses_notifier.dart';

/// Add or edit a `Jarz Recurring Expense`.
///
/// Every picker is filled from the payload — categories, frequencies, expense
/// accounts, cost centers and the cash-or-bank list — so the form can only ever
/// offer values the server will accept. Nothing here is hard-coded: a category
/// added in Desk shows up on the next load without an app release.
class RecurringExpenseFormSheet extends StatefulWidget {
  /// Null for a create.
  final RecurringExpenseItem? item;

  final MonthlyExpensesPayload payload;

  final Future<MonthlyExpenseActionResult> Function(RecurringExpenseDraft draft)
      onSubmit;

  const RecurringExpenseFormSheet({
    super.key,
    required this.payload,
    required this.onSubmit,
    this.item,
  });

  @override
  State<RecurringExpenseFormSheet> createState() =>
      _RecurringExpenseFormSheetState();
}

class _RecurringExpenseFormSheetState extends State<RecurringExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dayController;
  late final TextEditingController _supplierController;
  late final TextEditingController _notesController;

  String? _category;
  String? _frequency;
  String? _expenseAccount;
  String? _costCenter;
  String? _defaultPayingAccount;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.expenseName ?? '');
    _amountController = TextEditingController(
      text: item == null ? '' : item.amount.toStringAsFixed(2),
    );
    _dayController = TextEditingController(
      text: item?.dayOfMonth?.toString() ?? '',
    );
    _supplierController = TextEditingController(text: item?.supplier ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    // An existing value that is no longer in the server's option list is kept
    // rather than silently reset: dropping it would rewrite the row's category
    // to something the manager never chose, on a save they made for an
    // unrelated field.
    _category = _initial(widget.payload.categories, item?.category);
    _frequency = _initial(widget.payload.frequencies, item?.frequency);
    _expenseAccount = item?.expenseAccount.isNotEmpty == true
        ? item!.expenseAccount
        : (widget.payload.expenseAccounts.isNotEmpty
            ? widget.payload.expenseAccounts.first.account
            : null);
    _costCenter = item?.costCenter;
    _defaultPayingAccount = item?.defaultPayingAccount;
    _startDate = item?.startDate;
    _endDate = item?.endDate;
  }

  String? _initial(List<String> options, String? current) {
    final value = current?.trim() ?? '';
    if (value.isNotEmpty) return value;
    return options.isNotEmpty ? options.first : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final payload = widget.payload;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final categories = _withCurrent(payload.categories, _category);
    final frequencies = _withCurrent(payload.frequencies, _frequency);
    final hasOptions = categories.isNotEmpty &&
        frequencies.isNotEmpty &&
        payload.expenseAccounts.isNotEmpty;

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
                children: [
                  Expanded(
                    child: Text(
                      _isEdit
                          ? l10n.monthlyExpensesEditTitle
                          : l10n.monthlyExpensesNewTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.monthlyExpensesNameRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesAmountLabel,
                  border: const OutlineInputBorder(),
                  prefixText:
                      '${currencySymbol(context, currencyCode: payload.currency)} ',
                ),
                validator: (value) {
                  final amount = double.tryParse((value ?? '').trim());
                  if (amount == null || amount <= 0) {
                    return l10n.monthlyExpensesAmountRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _dropdown<String>(
                label: l10n.monthlyExpensesCategoryLabel,
                value: _category,
                values: categories,
                labelOf: (value) => value,
                onChanged: (value) => setState(() => _category = value),
                requiredMessage: l10n.monthlyExpensesCategoryRequired,
              ),
              const SizedBox(height: 16),
              _dropdown<String>(
                label: l10n.monthlyExpensesFrequencyLabel,
                value: _frequency,
                values: frequencies,
                labelOf: (value) => value,
                onChanged: (value) => setState(() => _frequency = value),
                requiredMessage: l10n.monthlyExpensesFrequencyRequired,
              ),
              const SizedBox(height: 16),
              _dropdown<String>(
                label: l10n.monthlyExpensesAccountLabel,
                value: _expenseAccount,
                values: payload.expenseAccounts.map((a) => a.account).toList(),
                labelOf: (account) => payload.expenseAccounts
                    .firstWhere(
                      (a) => a.account == account,
                      orElse: () =>
                          ExpenseAccountOption(account: account, label: account),
                    )
                    .displayLabel,
                onChanged: (value) => setState(() => _expenseAccount = value),
                requiredMessage: l10n.monthlyExpensesAccountRequired,
              ),
              const SizedBox(height: 16),
              _optionalDropdown<String>(
                label: l10n.monthlyExpensesCostCenterLabel,
                value: _costCenter,
                values: payload.costCenters.map((c) => c.name).toList(),
                labelOf: (name) => payload.costCenters
                    .firstWhere(
                      (c) => c.name == name,
                      orElse: () => CostCenterOption(name: name, label: name),
                    )
                    .displayLabel,
                onChanged: (value) => setState(() => _costCenter = value),
              ),
              const SizedBox(height: 16),
              _optionalDropdown<String>(
                label: l10n.monthlyExpensesDefaultPayingAccountLabel,
                value: _defaultPayingAccount,
                values:
                    payload.paymentSources.map((s) => s.account).toList(),
                labelOf: (account) => payload.paymentSources
                    .firstWhere(
                      (s) => s.account == account,
                      orElse: () => MonthlyExpensePaymentSource(
                        id: account,
                        account: account,
                        label: account,
                      ),
                    )
                    .localizedLabel(languageCode),
                onChanged: (value) =>
                    setState(() => _defaultPayingAccount = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesDayOfMonthLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;
                  final day = int.tryParse(text);
                  // 28, not 31: the server REFUSES a day that does not
                  // exist in February rather than silently clamping it,
                  // so accepting 30 here would only defer the rejection
                  // to a failed save.
                  if (day == null || day < 1 || day > 28) {
                    return l10n.monthlyExpensesDayOfMonthInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _datePicker(
                label: l10n.monthlyExpensesStartDateLabel,
                value: _startDate,
                onPicked: (value) => setState(() => _startDate = value),
              ),
              const SizedBox(height: 16),
              _datePicker(
                label: l10n.monthlyExpensesEndDateLabel,
                value: _endDate,
                onPicked: (value) => setState(() => _endDate = value),
                clearable: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierController,
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesSupplierLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesNotesLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (!_submitting && hasOptions) ? _handleSubmit : null,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.commonSave),
                ),
              ),
              if (!hasOptions)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n.monthlyExpensesFormMissingOptions,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Keeps a value the server no longer offers in the list, so the dropdown
  /// cannot assert on an unknown selection.
  List<String> _withCurrent(List<String> options, String? current) {
    final value = current?.trim() ?? '';
    if (value.isEmpty || options.contains(value)) return options;
    return [...options, value];
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T value) labelOf,
    required ValueChanged<T?> onChanged,
    required String requiredMessage,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey<String>('$label:$value'),
      initialValue: values.contains(value) ? value : null,
      isExpanded: true,
      items: values
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (selected) => selected == null ? requiredMessage : null,
    );
  }

  Widget _optionalDropdown<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T value) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    final l10n = context.l10n;
    return DropdownButtonFormField<T?>(
      key: ValueKey<String>('$label:$value'),
      initialValue: values.contains(value) ? value : null,
      isExpanded: true,
      items: <DropdownMenuItem<T?>>[
        DropdownMenuItem<T?>(
          value: null,
          child: Text(l10n.monthlyExpensesNoneOption),
        ),
        ...values.map((item) => DropdownMenuItem<T?>(
              value: item,
              child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPicked,
    bool clearable = false,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: clearable && value != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onPicked(null),
                )
              : const Icon(Icons.calendar_today),
        ),
        child: Text(
          value == null
              ? context.l10n.commonNotSpecified
              : formatDate(context, value),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? iso(DateTime? date) =>
        date == null ? null : DateFormat('yyyy-MM-dd').format(date);
    String? trimmedOrNull(TextEditingController controller) {
      final text = controller.text.trim();
      return text.isEmpty ? null : text;
    }

    final draft = RecurringExpenseDraft(
      name: widget.item?.name,
      expenseName: _nameController.text.trim(),
      category: _category ?? '',
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      frequency: _frequency ?? '',
      expenseAccount: _expenseAccount ?? '',
      dayOfMonth: int.tryParse(_dayController.text.trim()),
      costCenter: _costCenter,
      supplier: trimmedOrNull(_supplierController),
      defaultPayingAccount: _defaultPayingAccount,
      startDate: iso(_startDate),
      endDate: iso(_endDate),
      notes: trimmedOrNull(_notesController),
    );

    setState(() => _submitting = true);
    final result = await widget.onSubmit(draft);
    if (!mounted) return;
    setState(() => _submitting = false);
    // A failure has already been surfaced by the screen's error listener; the
    // sheet stays open so the manager does not lose what they typed.
    if (result.success) Navigator.of(context).pop(true);
  }
}

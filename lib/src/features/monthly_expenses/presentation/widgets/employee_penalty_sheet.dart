import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/widgets/posting_date_confirmation_dialog.dart';
import '../../models/monthly_expense_models.dart';
import '../../state/monthly_expenses_notifier.dart';

/// The call the sheet makes. A callback rather than a notifier reference so the
/// sheet stays a dumb form: it collects a unit, a number and a reason, and the
/// screen decides which employee and which month that belongs to.
typedef EmployeePenaltySubmit = Future<MonthlyExpenseActionResult> Function({
  required PenaltyDraft draft,
  bool allowOverpay,
});

/// Records a penalty against one employee for the selected month.
///
/// The point of this sheet is the EQUIVALENCE. A penalty is agreed with the
/// employee in whichever unit the conversation happened in — "two days" or "six
/// hundred pounds" — and both sides need to see the other number before anyone
/// agrees to it. So the conversion is computed locally, from the row's own
/// [SalaryRow.dayRate], and updated on every keystroke; the server recomputes
/// it authoritatively and snapshots the rate it used, but by then the manager
/// has already been shown what they are signing.
///
/// The days figure is deliberately NOT rounded to a whole number: 1.5 days is a
/// real answer, and rounding it would misstate the penalty in the direction
/// nobody checks.
class EmployeePenaltySheet extends StatefulWidget {
  final SalaryRow row;
  final String currency;

  /// The period the penalty is deducted from, already localized.
  final String periodLabel;

  /// `deductions.penalty_units` — the server's Select options, in its own
  /// vocabulary. Falls back to the three the DocType ships with.
  final List<String> penaltyUnits;

  /// `deductions.days_per_month`. Shown in the day-rate hint so the manager can
  /// see the basis rather than having to trust the number.
  final int daysPerMonth;

  final EmployeePenaltySubmit onSubmit;

  const EmployeePenaltySheet({
    super.key,
    required this.row,
    required this.currency,
    required this.periodLabel,
    required this.onSubmit,
    this.penaltyUnits = PenaltyUnit.all,
    this.daysPerMonth = 30,
  });

  @override
  State<EmployeePenaltySheet> createState() => _EmployeePenaltySheetState();
}

class _EmployeePenaltySheetState extends State<EmployeePenaltySheet> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _reasonController = TextEditingController();

  late String _unit;
  DateTime _penaltyDate = DateTime.now();
  bool _submitting = false;

  /// No salary structure means a day has no monetary value for this employee,
  /// so Days and Half days cannot be priced at all. The sheet refuses them up
  /// front with the reason, instead of letting the manager fill the form and
  /// collecting a server rejection they have to interpret.
  bool get _hasDayRate => widget.row.dayRate > 0;

  List<String> get _units =>
      widget.penaltyUnits.isEmpty ? PenaltyUnit.all : widget.penaltyUnits;

  @override
  void initState() {
    super.initState();
    // Money first when days cannot be priced: it is the only unit that works,
    // and opening on a disabled segment reads as a broken sheet.
    _unit = _hasDayRate
        ? (_units.contains(PenaltyUnit.days) ? PenaltyUnit.days : _units.first)
        : PenaltyUnit.money;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get _typedValue =>
      double.tryParse(_valueController.text.trim().replaceAll(',', '')) ?? 0;

  double get _amount => penaltyAmountFor(
        unit: _unit,
        quantity: _unit == PenaltyUnit.money ? 0 : _typedValue,
        amount: _unit == PenaltyUnit.money ? _typedValue : 0,
        dayRate: widget.row.dayRate,
      );

  double get _days => penaltyDaysFor(
        unit: _unit,
        quantity: _unit == PenaltyUnit.money ? 0 : _typedValue,
        amount: _unit == PenaltyUnit.money ? _typedValue : 0,
        dayRate: widget.row.dayRate,
      );

  bool get _canSubmit =>
      !_submitting && _typedValue > 0 && _reasonController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                      l10n.monthlyExpensesPenaltyTitle(widget.row.displayName),
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                widget.periodLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _unitSelector(context),
              if (!_hasDayRate)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.monthlyExpensesPenaltyNoDayRate,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _valueLabel(context),
                  border: const OutlineInputBorder(),
                  prefixText: _unit == PenaltyUnit.money
                      ? '${currencySymbol(context, currencyCode: widget.currency)} '
                      : null,
                ),
                // Every keystroke redraws the equivalence line below. That is
                // the whole feature: the two numbers have to move together
                // while the manager is still deciding.
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final parsed =
                      double.tryParse((value ?? '').trim().replaceAll(',', ''));
                  if (parsed == null || parsed <= 0) {
                    return l10n.monthlyExpensesPenaltyQuantityInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _equivalence(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.monthlyExpensesPenaltyReasonLabel,
                  border: const OutlineInputBorder(),
                ),
                // Rebuilds so the submit button follows the reason field: a
                // penalty with no stated reason is not defensible to the
                // employee, and the server refuses it anyway.
                onChanged: (_) => setState(() {}),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.monthlyExpensesPenaltyReasonRequired
                    : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _penaltyDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 400)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _penaltyDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.monthlyExpensesPenaltyDateLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(formatDate(context, _penaltyDate)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSubmit ? () => _submit() : null,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.monthlyExpensesPenaltySubmit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitSelector(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        for (final unit in _units)
          ButtonSegment<String>(
            value: unit,
            label: Text(_unitLabel(context, unit)),
            // Days and half-days are unpriceable without a day rate.
            enabled: unit == PenaltyUnit.money || _hasDayRate,
          ),
      ],
      selected: {_unit},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        setState(() => _unit = selection.first);
      },
    );
  }

  /// The live two-way equivalence, and the day rate it rests on.
  ///
  /// Rendered as the loudest thing on the sheet, in a filled block: it is the
  /// number the manager will read out to the employee, and burying it under the
  /// input would leave it unread.
  Widget _equivalence(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final typed = _typedValue;

    // Days -> money, money -> days. Both directions come from the same pair of
    // helpers the DocType's validate mirrors, so the sheet and the server
    // cannot drift.
    final equivalent = _unit == PenaltyUnit.money
        ? l10n.monthlyExpensesPenaltyDaysAmount(_formatDays(context, _days))
        : formatCurrency(context, _amount, currencyCode: widget.currency);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // An empty or zero input shows a zero equivalence rather than
            // nothing: a line that appears and disappears as you type reads as
            // a glitch, and "= 0" is the honest answer to an empty field.
            l10n.monthlyExpensesPenaltyEquals(typed > 0
                ? equivalent
                : (_unit == PenaltyUnit.money
                    ? l10n.monthlyExpensesPenaltyDaysAmount(
                        _formatDays(context, 0))
                    : formatCurrency(context, 0,
                        currencyCode: widget.currency))),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          if (_hasDayRate)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.monthlyExpensesPenaltyDayRateHint(
                  formatCurrency(context, widget.row.dayRate,
                      currencyCode: widget.currency),
                  formatCount(context, widget.daysPerMonth),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _valueLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (_unit) {
      case PenaltyUnit.days:
        return l10n.monthlyExpensesPenaltyDaysLabel;
      case PenaltyUnit.halfDays:
        return l10n.monthlyExpensesPenaltyHalfDaysLabel;
      case PenaltyUnit.money:
      default:
        return l10n.monthlyExpensesPenaltyAmountLabel;
    }
  }

  String _unitLabel(BuildContext context, String unit) {
    final l10n = context.l10n;
    switch (unit) {
      case PenaltyUnit.days:
        return l10n.monthlyExpensesPenaltyUnitDays;
      case PenaltyUnit.halfDays:
        return l10n.monthlyExpensesPenaltyUnitHalfDays;
      case PenaltyUnit.money:
        return l10n.monthlyExpensesPenaltyUnitMoney;
      // A unit this build has not heard of shows as itself. The vocabulary
      // belongs to the server, and relabelling an unknown option would be a
      // guess about money.
      default:
        return unit;
    }
  }

  Future<void> _submit({bool allowOverpay = false}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isMoney = _unit == PenaltyUnit.money;
    final draft = PenaltyDraft(
      employee: widget.row.employee,
      unit: _unit,
      // Exactly one of the two travels: the server owns the conversion and
      // snapshots the rate it used, so sending both would be two sources of
      // truth for one number.
      quantity: isMoney ? null : _typedValue,
      amount: isMoney ? _typedValue : null,
      reason: _reasonController.text.trim(),
      penaltyDate: formatPostingDateForApi(_penaltyDate),
    );

    setState(() => _submitting = true);
    final result =
        await widget.onSubmit(draft: draft, allowOverpay: allowOverpay);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      Navigator.of(context).pop(true);
      return;
    }

    // The server refuses a month whose penalties would exceed the salary, and
    // says by how much — the same shape as the pay sheet's overpay question,
    // and the same answer: the manager is the one who knows whether it is
    // right. Suspension without pay for a whole month is a real decision.
    if (result.needsOverpayConfirmation) {
      final confirmed = await _confirmOverpay(result.overpayMessage!);
      if (!mounted || confirmed != true) return;
      await _submit(allowOverpay: true);
      return;
    }

    // Anything else is a real failure; the screen's error listener has shown
    // it, and the sheet stays open with the values intact.
  }

  Future<bool?> _confirmOverpay(String serverMessage) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.monthlyExpensesOverpayTitle),
          // The server's own sentence, verbatim: it carries the overshoot, and
          // the generic presenter would throw that away.
          content: Text(serverMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.monthlyExpensesOverpayConfirm),
            ),
          ],
        );
      },
    );
  }
}

/// A day count for display: as many decimals as it actually has, up to two.
///
/// 2 stays "2", 1.5 stays "1.5", and 600 against a 450 day rate is "1.33"
/// rather than a rounded "1" — a penalty stated as a whole number it is not
/// would be wrong in the direction nobody audits.
String formatPenaltyDays(BuildContext context, double days) =>
    _formatDays(context, days);

String _formatDays(BuildContext context, double days) {
  final rounded = (days * 100).round() / 100;
  if ((rounded - rounded.roundToDouble()).abs() < 0.0001) {
    return formatCount(context, rounded.round());
  }
  return formatCount(context, rounded);
}

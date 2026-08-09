import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kanban_models.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/localization/localized_display_mappers.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/utils/responsive_utils.dart';

/// The Kanban board's filter bar.
///
/// Everything is reachable without opening anything: the search field is always
/// visible and each dimension is one chip that shows its current value. A set
/// chip carries its own clear affordance, so there is no second "active
/// filters" row duplicating the same state.
class KanbanFiltersWidget extends StatefulWidget {
  final KanbanFilters filters;
  final List<CustomerOption> customers;
  final Function(KanbanFilters) onFiltersChanged;

  /// Cards currently on the board. Shown next to the filters so staff can see
  /// at a glance that a filter is why the board looks empty.
  final int resultCount;
  final bool isLoading;

  /// Supplied by the phone bottom sheet; adds a "Done" affordance.
  final VoidCallback? onClose;

  const KanbanFiltersWidget({
    super.key,
    required this.filters,
    required this.customers,
    required this.onFiltersChanged,
    this.resultCount = 0,
    this.isLoading = false,
    this.onClose,
  });

  @override
  State<KanbanFiltersWidget> createState() => _KanbanFiltersWidgetState();
}

/// Long enough that a fast typist issues one request, short enough that the
/// board feels like it is reacting to the keystroke.
const _searchDebounce = Duration(milliseconds: 350);

class _KanbanFiltersWidgetState extends State<KanbanFiltersWidget> {
  late KanbanFilters _currentFilters;
  late final TextEditingController _searchController;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
    _searchController = TextEditingController(text: _currentFilters.searchTerm);
  }

  @override
  void didUpdateWidget(KanbanFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters && widget.filters != _currentFilters) {
      // The board cleared or replaced the filters from elsewhere (the empty-state
      // "Clear all" button). Drop any keystroke still waiting to be sent, or it
      // would land afterwards and put the search term straight back.
      _searchDebounceTimer?.cancel();
      setState(() {
        _currentFilters = widget.filters;
      });
      _syncSearchController(widget.filters.searchTerm);
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _syncSearchController(String value) {
    if (_searchController.text == value) return;
    _searchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  /// Commit [filters] to the board. Every path except typing is immediate —
  /// picking a customer or a date is a deliberate act and should feel instant.
  void _apply(KanbanFilters filters) {
    _searchDebounceTimer?.cancel();
    setState(() => _currentFilters = filters);
    widget.onFiltersChanged(filters);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchTerm: value);
    });
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      widget.onFiltersChanged(_currentFilters);
    });
  }

  void _submitSearch() {
    _searchDebounceTimer?.cancel();
    widget.onFiltersChanged(_currentFilters);
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty && _currentFilters.searchTerm.isEmpty) {
      return;
    }
    _searchController.clear();
    _apply(_currentFilters.copyWith(searchTerm: ''));
  }

  void _clearAllFilters() {
    _searchController.clear();
    _apply(const KanbanFilters());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasFilters = _currentFilters.hasFilters;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.onClose != null,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.kanbanFilterSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _currentFilters.searchTerm.isNotEmpty
                          ? IconButton(
                              tooltip: l10n.commonClear,
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onClose,
                    child: Text(l10n.kanbanFilterDone),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // One chip per dimension, horizontally scrollable so a long
            // customer name never forces the row to wrap on a phone.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _dimensionChip(
                    icon: Icons.person_outline,
                    label: _customerFilterLabel(context),
                    selected: _currentFilters.customer?.isNotEmpty == true,
                    onTap: () => _showCustomerPicker(context),
                    onClear: () =>
                        _apply(_currentFilters.copyWith(clearCustomer: true)),
                  ),
                  const SizedBox(width: 8),
                  _dimensionChip(
                    icon: Icons.payments_outlined,
                    label: (_currentFilters.status?.isEmpty ?? true)
                        ? l10n.kanbanFilterAllStatuses
                        : localizedStatusLabel(context, _currentFilters.status),
                    selected: _currentFilters.status?.isNotEmpty == true,
                    onTap: () => _showStatusPicker(context),
                    onClear: () =>
                        _apply(_currentFilters.copyWith(clearStatus: true)),
                  ),
                  const SizedBox(width: 8),
                  _dimensionChip(
                    icon: Icons.event_outlined,
                    label: _dateChipLabel(context),
                    selected: _currentFilters.dateFrom != null ||
                        _currentFilters.dateTo != null,
                    onTap: () => _showDatePicker(context),
                    onClear: () => _apply(_currentFilters.copyWith(
                      clearDateFrom: true,
                      clearDateTo: true,
                    )),
                  ),
                  const SizedBox(width: 8),
                  _dimensionChip(
                    icon: Icons.sell_outlined,
                    label: _amountChipLabel(context),
                    selected: _currentFilters.amountFrom != null ||
                        _currentFilters.amountTo != null,
                    onTap: () => _showAmountRangePicker(context),
                    onClear: () => _apply(_currentFilters.copyWith(
                      clearAmountFrom: true,
                      clearAmountTo: true,
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            SizedBox(
              height: 36,
              child: Row(
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasFilters)
                    Flexible(
                      child: Text(
                        l10n.kanbanFilterMatchCount(widget.resultCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  if (hasFilters)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.filter_alt_off, size: 18),
                      label: Text(l10n.kanbanFilterClearAll),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dimensionChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: InputChip(
        avatar: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
        selected: selected,
        showCheckmark: false,
        onPressed: onTap,
        onDeleted: selected ? onClear : null,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }

  // ── Labels ───────────────────────────────────────────────────────────────

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
        .format(date);
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  String _dateChipLabel(BuildContext context) {
    final from = _currentFilters.dateFrom;
    final to = _currentFilters.dateTo;
    if (from == null && to == null) return context.l10n.kanbanFilterAllDates;
    if (from != null && to != null) {
      if (_isSameDay(from, to)) return _formatDate(context, from);
      return '${_formatDate(context, from)} – ${_formatDate(context, to)}';
    }
    if (from != null) {
      return '${context.l10n.kanbanFilterFromDate}: ${_formatDate(context, from)}';
    }
    return '${context.l10n.kanbanFilterToDate}: ${_formatDate(context, to!)}';
  }

  String _amountChipLabel(BuildContext context) {
    final from = _currentFilters.amountFrom;
    final to = _currentFilters.amountTo;
    if (from == null && to == null) return context.l10n.kanbanFilterAllAmounts;
    final symbol = currencySymbol(context);
    if (from != null && to != null) {
      return '$symbol ${_formatAmount(from)} – ${_formatAmount(to)}';
    }
    if (from != null) return '≥ $symbol ${_formatAmount(from)}';
    return '≤ $symbol ${_formatAmount(to!)}';
  }

  String _customerFilterLabel(BuildContext context) {
    final customer = _currentFilters.customer;
    if (customer?.isNotEmpty != true) {
      return context.l10n.kanbanFilterAllCustomers;
    }
    return _customerDisplayName(customer!);
  }

  CustomerOption? _findCustomer(String customer) {
    for (final option in widget.customers) {
      if (option.customer == customer) return option;
    }
    return null;
  }

  String _customerDisplayName(String customer) {
    final option = _findCustomer(customer);
    final label = option?.customerName.trim();
    if (label != null && label.isNotEmpty) return label;
    return option?.customer ?? customer;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _showCustomerPicker(BuildContext context) async {
    final selection = await showDialog<_CustomerSelection>(
      context: context,
      builder: (_) => _CustomerPickerDialog(
        customers: widget.customers,
        selected: _currentFilters.customer,
      ),
    );
    if (selection == null || !mounted) return;
    _apply(selection.customer == null
        ? _currentFilters.copyWith(clearCustomer: true)
        : _currentFilters.copyWith(customer: selection.customer));
  }

  void _showStatusPicker(BuildContext context) {
    final l10n = context.l10n;
    const statuses = [
      InvoiceStatus.paid,
      InvoiceStatus.unpaid,
      InvoiceStatus.cancelled,
      InvoiceStatus.returnStatus,
    ];

    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.kanbanFilterStatusTitle),
        children: [
          _statusOption(
            context,
            label: l10n.kanbanFilterAllStatuses,
            value: null,
          ),
          ...statuses.map(
            (status) => _statusOption(
              context,
              label: localizedStatusLabel(context, status),
              value: status,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusOption(
    BuildContext dialogContext, {
    required String label,
    required String? value,
  }) {
    final selected = _currentFilters.status == value;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      selected: selected,
      onTap: () {
        Navigator.of(dialogContext).pop();
        _apply(value == null
            ? _currentFilters.copyWith(clearStatus: true)
            : _currentFilters.copyWith(status: value));
      },
    );
  }

  /// Date presets first, custom range last. Dispatchers almost always want
  /// "today" or "this week"; making them drive a two-ended calendar for that
  /// was the slowest interaction on the board.
  void _showDatePicker(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.kanbanFilterDateRange),
        children: [
          ListTile(
            title: Text(l10n.kanbanFilterAllDates),
            trailing: (_currentFilters.dateFrom == null &&
                    _currentFilters.dateTo == null)
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.of(dialogContext).pop();
              _apply(_currentFilters.copyWith(
                clearDateFrom: true,
                clearDateTo: true,
              ));
            },
          ),
          ListTile(
            title: Text(l10n.kanbanFilterDateToday),
            onTap: () {
              Navigator.of(dialogContext).pop();
              _apply(_currentFilters.copyWith(dateFrom: today, dateTo: today));
            },
          ),
          ListTile(
            title: Text(l10n.kanbanFilterDateLast7Days),
            onTap: () {
              Navigator.of(dialogContext).pop();
              _apply(_currentFilters.copyWith(
                dateFrom: today.subtract(const Duration(days: 6)),
                dateTo: today,
              ));
            },
          ),
          ListTile(
            title: Text(l10n.kanbanFilterDateLast30Days),
            onTap: () {
              Navigator.of(dialogContext).pop();
              _apply(_currentFilters.copyWith(
                dateFrom: today.subtract(const Duration(days: 29)),
                dateTo: today,
              ));
            },
          ),
          ListTile(
            title: Text(l10n.kanbanFilterDateThisMonth),
            onTap: () {
              Navigator.of(dialogContext).pop();
              _apply(_currentFilters.copyWith(
                dateFrom: DateTime(today.year, today.month, 1),
                dateTo: today,
              ));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text(l10n.kanbanFilterDateCustom),
            onTap: () async {
              Navigator.of(dialogContext).pop();
              await _showCustomDateRangePicker(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomDateRangePicker(BuildContext context) async {
    final from = _currentFilters.dateFrom;
    final to = _currentFilters.dateTo;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: from != null && to != null
          ? DateTimeRange(start: from, end: to)
          : null,
    );

    if (picked != null) {
      _apply(_currentFilters.copyWith(
        dateFrom: picked.start,
        dateTo: picked.end,
      ));
    }
  }

  Future<void> _showAmountRangePicker(BuildContext context) async {
    final range = await showDialog<_AmountRange>(
      context: context,
      builder: (_) => _AmountRangeDialog(
        from: _currentFilters.amountFrom,
        to: _currentFilters.amountTo,
        format: _formatAmount,
        parse: _parseAmount,
      ),
    );
    if (range == null || !mounted) return;
    _apply(_currentFilters.copyWith(
      amountFrom: range.from,
      amountTo: range.to,
      clearAmountFrom: range.from == null,
      clearAmountTo: range.to == null,
    ));
  }
}

/// Result of the customer picker. `customer == null` means "all customers";
/// dismissing the dialog returns null instead, so "cleared" and "cancelled"
/// stay distinguishable.
class _CustomerSelection {
  const _CustomerSelection(this.customer);
  final String? customer;
}

class _CustomerPickerDialog extends StatefulWidget {
  const _CustomerPickerDialog({required this.customers, required this.selected});

  final List<CustomerOption> customers;
  final String? selected;

  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _searchController.text.trim().toLowerCase();
    final filteredCustomers = widget.customers.where((customer) {
      if (query.isEmpty) return true;
      return customer.customer.toLowerCase().contains(query) ||
          customer.customerName.toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      title: Text(l10n.kanbanFilterCustomerTitle),
      content: SizedBox(
        width: ResponsiveUtils.getDialogWidth(
          context,
          small: 500,
          medium: 560,
          large: 640,
        ),
        height: ResponsiveUtils.getDialogHeight(
          context,
          phoneFraction: 0.72,
          tabletFraction: 0.5,
          max: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.kanbanFilterCustomerName,
                hintText: l10n.kanbanFilterCustomerHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: Text(l10n.kanbanFilterAllCustomers),
                    trailing: widget.selected?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.check),
                    onTap: () => Navigator.of(context)
                        .pop(const _CustomerSelection(null)),
                  ),
                  if (filteredCustomers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(l10n.masterOrdersNoResults)),
                    )
                  else
                    ...filteredCustomers.map(
                      (customer) => ListTile(
                        title: Text(
                          customer.customerName.isNotEmpty
                              ? customer.customerName
                              : customer.customer,
                        ),
                        subtitle: customer.customerName.isNotEmpty
                            ? Text(customer.customer)
                            : null,
                        trailing: widget.selected == customer.customer
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.of(context)
                            .pop(_CustomerSelection(customer.customer)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}

class _AmountRange {
  const _AmountRange(this.from, this.to);
  final double? from;
  final double? to;
}

class _AmountRangeDialog extends StatefulWidget {
  const _AmountRangeDialog({
    required this.from,
    required this.to,
    required this.format,
    required this.parse,
  });

  final double? from;
  final double? to;
  final String Function(double) format;
  final double? Function(String) parse;

  @override
  State<_AmountRangeDialog> createState() => _AmountRangeDialogState();
}

class _AmountRangeDialogState extends State<_AmountRangeDialog> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(
      text: widget.from == null ? '' : widget.format(widget.from!),
    );
    _toController = TextEditingController(
      text: widget.to == null ? '' : widget.format(widget.to!),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final symbol = currencySymbol(context);

    return AlertDialog(
      title: Text(l10n.kanbanFilterAmountRange),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _fromController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.kanbanFilterFromAmount,
              prefixText: '$symbol ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _toController,
            decoration: InputDecoration(
              labelText: l10n.kanbanFilterToAmount,
              prefixText: '$symbol ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(const _AmountRange(null, null)),
          child: Text(l10n.commonClear),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.kanbanFilterApply),
        ),
      ],
    );
  }

  void _submit() {
    var from = widget.parse(_fromController.text);
    var to = widget.parse(_toController.text);
    // A reversed range is a typo, not an empty result — swap rather than
    // silently returning nothing.
    if (from != null && to != null && from > to) {
      final temp = from;
      from = to;
      to = temp;
    }
    Navigator.of(context).pop(_AmountRange(from, to));
  }
}

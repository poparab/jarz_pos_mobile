import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kanban_models.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/localization/localized_display_mappers.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/utils/responsive_utils.dart';

class KanbanFiltersWidget extends StatefulWidget {
  final KanbanFilters filters;
  final List<CustomerOption> customers;
  final Function(KanbanFilters) onFiltersChanged;

  const KanbanFiltersWidget({
    super.key,
    required this.filters,
    required this.customers,
    required this.onFiltersChanged,
  });

  @override
  State<KanbanFiltersWidget> createState() => _KanbanFiltersWidgetState();
}

class _KanbanFiltersWidgetState extends State<KanbanFiltersWidget> {
  late KanbanFilters _currentFilters;
  late final TextEditingController _searchController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
    _searchController = TextEditingController(text: _currentFilters.searchTerm);
  }

  @override
  void didUpdateWidget(KanbanFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      setState(() {
        _currentFilters = widget.filters;
      });
      _syncSearchController(widget.filters.searchTerm);
    }
  }

  @override
  void dispose() {
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

  void _applyFilters() {
    widget.onFiltersChanged(_currentFilters);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchTerm: value);
    });
    _applyFilters();
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty && _currentFilters.searchTerm.isEmpty) {
      return;
    }
    _searchController.clear();
    setState(() {
      _currentFilters = _currentFilters.copyWith(searchTerm: '');
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter header with expand/collapse
          ListTile(
            title: Text(
              context.l10n.kanbanFilterTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: _hasActiveFilters()
                ? Text(context.l10n.kanbanFilterActiveCount(_getActiveFiltersCount()))
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasActiveFilters())
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(context.l10n.kanbanFilterClearAll),
                  ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            tileColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          ),

          // Collapsible filter content
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search term
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: context.l10n.kanbanFilterSearch,
                      hintText: context.l10n.kanbanFilterSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _currentFilters.searchTerm.trim().isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                  ),

                  const SizedBox(height: 16),

                  // Quick filter chips
                  Wrap(
                    spacing: 8,
                    children: [
                      // Customer filter
                      FilterChip(
                        label: Text(_customerFilterLabel(context)),
                        selected: _currentFilters.customer?.isNotEmpty == true,
                        onSelected: (_) => _showCustomerPicker(context),
                      ),

                      // Status filter
                      FilterChip(
                        label: Text(
                          (_currentFilters.status?.isEmpty ?? true)
                              ? context.l10n.kanbanFilterAllStatuses
                              : localizedStatusLabel(context, _currentFilters.status),
                        ),
                        selected: _currentFilters.status?.isNotEmpty == true,
                        onSelected: (_) => _showStatusPicker(context),
                      ),

                      // Date range filter
                      FilterChip(
                        label: Text(_getDateRangeText()),
                        selected:
                            _currentFilters.dateFrom != null ||
                            _currentFilters.dateTo != null,
                        onSelected: (_) => _showDateRangePicker(context),
                      ),

                      // Amount range filter
                      FilterChip(
                        label: Text(_getAmountRangeText()),
                        selected:
                            _currentFilters.amountFrom != null ||
                            _currentFilters.amountTo != null,
                        onSelected: (_) => _showAmountRangePicker(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Active filters display
                  if (_hasActiveFilters()) ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.l10n.kanbanFilterActiveLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _buildActiveFilterChips(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _currentFilters.hasFilters;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_currentFilters.searchTerm.trim().isNotEmpty) count++;
    if (_currentFilters.customer?.isNotEmpty == true) count++;
    if (_currentFilters.status?.isNotEmpty == true) count++;
    if (_currentFilters.dateFrom != null || _currentFilters.dateTo != null) {
      count++;
    }
    if (_currentFilters.amountFrom != null || _currentFilters.amountTo != null) {
      count++;
    }
    return count;
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    final searchTerm = _currentFilters.searchTerm.trim();
    if (searchTerm.isNotEmpty) {
      chips.add(
        _buildRemovableChip('${context.l10n.kanbanFilterSearch}: $searchTerm', () {
          _searchController.clear();
          setState(() {
            _currentFilters = _currentFilters.copyWith(searchTerm: '');
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.customer?.isNotEmpty == true) {
      chips.add(
        _buildRemovableChip('${context.l10n.commonCustomerLabel}: ${_customerDisplayName(_currentFilters.customer!)}', () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(clearCustomer: true);
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.status?.isNotEmpty == true) {
      chips.add(
        _buildRemovableChip('${context.l10n.kanbanFilterStatusTitle}: ${localizedStatusLabel(context, _currentFilters.status)}', () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(clearStatus: true);
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.dateFrom != null || _currentFilters.dateTo != null) {
      chips.add(
        _buildRemovableChip(_dateRangeChipLabel(context), () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(
              clearDateFrom: true,
              clearDateTo: true,
            );
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.amountFrom != null || _currentFilters.amountTo != null) {
      chips.add(
        _buildRemovableChip(_amountRangeChipLabel(context), () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(
              clearAmountFrom: true,
              clearAmountTo: true,
            );
          });
          _applyFilters();
        }),
      );
    }

    return chips;
  }

  Widget _buildRemovableChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _currentFilters = const KanbanFilters();
    });
    _applyFilters();
  }

  String _getDateRangeText() {
    if (_currentFilters.dateFrom != null && _currentFilters.dateTo != null) {
      return context.l10n.kanbanFilterDateRange;
    } else if (_currentFilters.dateFrom != null) {
      return context.l10n.kanbanFilterFromDate;
    } else if (_currentFilters.dateTo != null) {
      return context.l10n.kanbanFilterToDate;
    }
    return context.l10n.kanbanFilterAllDates;
  }

  String _getAmountRangeText() {
    if (_currentFilters.amountFrom != null &&
        _currentFilters.amountTo != null) {
      return context.l10n.kanbanFilterAmountRange;
    } else if (_currentFilters.amountFrom != null) {
      return context.l10n.kanbanFilterMinAmount;
    } else if (_currentFilters.amountTo != null) {
      return context.l10n.kanbanFilterMaxAmount;
    }
    return context.l10n.kanbanFilterAllAmounts;
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

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(date);
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  String _dateRangeChipLabel(BuildContext context) {
    final from = _currentFilters.dateFrom;
    final to = _currentFilters.dateTo;
    if (from != null && to != null) {
      return '${context.l10n.kanbanFilterDateRange}: ${_formatDate(context, from)} - ${_formatDate(context, to)}';
    }
    if (from != null) {
      return '${context.l10n.kanbanFilterFromDate}: ${_formatDate(context, from)}';
    }
    return '${context.l10n.kanbanFilterToDate}: ${_formatDate(context, to!)}';
  }

  String _amountRangeChipLabel(BuildContext context) {
    final from = _currentFilters.amountFrom;
    final to = _currentFilters.amountTo;
    if (from != null && to != null) {
      return '${context.l10n.kanbanFilterAmountRange}: ${_formatAmount(from)} - ${_formatAmount(to)}';
    }
    if (from != null) {
      return '${context.l10n.kanbanFilterMinAmount}: ${_formatAmount(from)}';
    }
    return '${context.l10n.kanbanFilterMaxAmount}: ${_formatAmount(to!)}';
  }

  double? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  void _showCustomerPicker(BuildContext context) {
    final l10n = context.l10n;
    final searchController = TextEditingController();
    final dialogHeight = ResponsiveUtils.getDialogHeight(
      context,
      phoneFraction: 0.72,
      tabletFraction: 0.5,
      max: 360,
    );
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final query = searchController.text.trim().toLowerCase();
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
              height: dialogHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.kanbanFilterCustomerName,
                      hintText: l10n.kanbanFilterCustomerHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setDialogState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.people_alt_outlined),
                          title: Text(l10n.kanbanFilterAllCustomers),
                          trailing: _currentFilters.customer?.isNotEmpty == true
                              ? null
                              : const Icon(Icons.check),
                          onTap: () {
                            setState(() {
                              _currentFilters = _currentFilters.copyWith(clearCustomer: true);
                            });
                            Navigator.of(context).pop();
                            _applyFilters();
                          },
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
                              trailing: _currentFilters.customer == customer.customer
                                  ? const Icon(Icons.check)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _currentFilters = _currentFilters.copyWith(
                                    customer: customer.customer,
                                  );
                                });
                                Navigator.of(context).pop();
                                _applyFilters();
                              },
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(clearCustomer: true);
                  });
                  Navigator.of(context).pop();
                  _applyFilters();
                },
                child: Text(l10n.commonClear),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final l10n = context.l10n;
    final statuses = [InvoiceStatus.paid, InvoiceStatus.unpaid, InvoiceStatus.cancelled, InvoiceStatus.returnStatus];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kanbanFilterStatusTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<String?>(
              groupValue: _currentFilters.status,
              onChanged: (value) {
                setState(() {
                  _currentFilters = value == null
                      ? _currentFilters.copyWith(clearStatus: true)
                      : _currentFilters.copyWith(status: value);
                });
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String?>(
                    title: Text(l10n.kanbanFilterAllStatuses),
                    value: null,
                    dense: true,
                  ),
                  ...statuses.map(
                    (status) => RadioListTile<String?>(
                      title: Text(localizedStatusLabel(context, status)),
                      value: status,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _currentFilters.dateFrom != null && _currentFilters.dateTo != null
          ? DateTimeRange(
              start: _currentFilters.dateFrom!,
              end: _currentFilters.dateTo!,
            )
          : null,
    );

    if (picked != null) {
      setState(() {
        _currentFilters = _currentFilters.copyWith(
          dateFrom: picked.start,
          dateTo: picked.end,
        );
      });
      _applyFilters();
    }
  }

  void _showAmountRangePicker(BuildContext context) {
    final l10n = context.l10n;
    final fromController = TextEditingController(
      text: _currentFilters.amountFrom?.toString() ?? '',
    );
    final toController = TextEditingController(
      text: _currentFilters.amountTo?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kanbanFilterAmountRange),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fromController,
              decoration: InputDecoration(
                labelText: l10n.kanbanFilterFromAmount,
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: toController,
              decoration: InputDecoration(
                labelText: l10n.kanbanFilterToAmount,
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentFilters = _currentFilters.copyWith(
                    clearAmountFrom: true,
                    clearAmountTo: true,
                );
              });
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: Text(l10n.commonClear),
          ),
          TextButton(
            onPressed: () {
              var fromAmount = _parseAmount(fromController.text);
              var toAmount = _parseAmount(toController.text);
              if (fromAmount != null && toAmount != null && fromAmount > toAmount) {
                final temp = fromAmount;
                fromAmount = toAmount;
                toAmount = temp;
              }

              setState(() {
                _currentFilters = _currentFilters.copyWith(
                  amountFrom: fromAmount,
                  amountTo: toAmount,
                  clearAmountFrom: fromAmount == null,
                  clearAmountTo: toAmount == null,
                );
              });
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: Text(l10n.kanbanFilterApply),
          ),
        ],
      ),
    );
  }
}

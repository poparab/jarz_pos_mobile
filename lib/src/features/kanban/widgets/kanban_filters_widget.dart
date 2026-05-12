import 'package:flutter/material.dart';
import '../models/kanban_models.dart';
import '../../../core/constants/business_constants.dart';
import '../../../core/localization/localized_display_mappers.dart';
import '../../../core/localization/localization_extensions.dart';

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
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
  }

  @override
  void didUpdateWidget(KanbanFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      setState(() {
        _currentFilters = widget.filters;
      });
    }
  }

  void _applyFilters() {
    widget.onFiltersChanged(_currentFilters);
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
                    decoration: InputDecoration(
                      labelText: context.l10n.kanbanFilterSearch,
                      hintText: context.l10n.kanbanFilterSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentFilters = _currentFilters.copyWith(
                          searchTerm: value,
                        );
                      });
                      _applyFilters();
                    },
                    controller: TextEditingController(
                      text: _currentFilters.searchTerm,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick filter chips
                  Wrap(
                    spacing: 8,
                    children: [
                      // Customer filter
                      FilterChip(
                        label: Text(
                          (_currentFilters.customer?.isEmpty ?? true)
                              ? context.l10n.kanbanFilterAllCustomers
                              : _currentFilters.customer!,
                        ),
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
    return _currentFilters.searchTerm.isNotEmpty ||
        (_currentFilters.customer?.isNotEmpty == true) ||
        (_currentFilters.status?.isNotEmpty == true) ||
        _currentFilters.dateFrom != null ||
        _currentFilters.dateTo != null ||
        _currentFilters.amountFrom != null ||
        _currentFilters.amountTo != null;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_currentFilters.searchTerm.isNotEmpty) count++;
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

    if (_currentFilters.searchTerm.isNotEmpty) {
      chips.add(
        _buildRemovableChip('${context.l10n.kanbanFilterSearch}: ${_currentFilters.searchTerm}', () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(searchTerm: '');
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.customer?.isNotEmpty == true) {
      chips.add(
        _buildRemovableChip('${context.l10n.commonCustomerLabel}: ${_currentFilters.customer}', () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(customer: null);
          });
          _applyFilters();
        }),
      );
    }

    if (_currentFilters.status?.isNotEmpty == true) {
      chips.add(
        _buildRemovableChip('${context.l10n.kanbanFilterStatusTitle}: ${localizedStatusLabel(context, _currentFilters.status)}', () {
          setState(() {
            _currentFilters = _currentFilters.copyWith(status: null);
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

  void _showCustomerPicker(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kanbanFilterCustomerTitle),
        content: TextField(
          decoration: InputDecoration(
            labelText: l10n.kanbanFilterCustomerName,
            hintText: l10n.kanbanFilterCustomerHint,
          ),
          onChanged: (value) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(customer: value);
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentFilters = _currentFilters.copyWith(customer: null);
              });
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: Text(l10n.commonClear),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: Text(l10n.kanbanFilterApply),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final l10n = context.l10n;
    final statuses = [InvoiceStatus.draft, InvoiceStatus.paid, InvoiceStatus.unpaid, InvoiceStatus.cancelled, InvoiceStatus.returnStatus];

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
                  _currentFilters = _currentFilters.copyWith(status: value);
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
                  amountFrom: null,
                  amountTo: null,
                );
              });
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: Text(l10n.commonClear),
          ),
          TextButton(
            onPressed: () {
              final fromAmount = double.tryParse(fromController.text);
              final toAmount = double.tryParse(toController.text);

              setState(() {
                _currentFilters = _currentFilters.copyWith(
                  amountFrom: fromAmount,
                  amountTo: toAmount,
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

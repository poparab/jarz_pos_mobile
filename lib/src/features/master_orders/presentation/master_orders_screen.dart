import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../core/localization/localization_extensions.dart';
import '../state/master_orders_providers.dart';

class MasterOrdersScreen extends ConsumerStatefulWidget {
  const MasterOrdersScreen({super.key});

  @override
  ConsumerState<MasterOrdersScreen> createState() =>
      _MasterOrdersScreenState();
}

class _MasterOrdersScreenState extends ConsumerState<MasterOrdersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(masterOrdersFiltersProvider.notifier).state =
          ref.read(masterOrdersFiltersProvider).copyWith(
                search: value.isEmpty ? null : value,
                clearSearch: value.isEmpty,
                page: 1,
              );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(masterOrdersFiltersProvider.notifier).state =
        ref.read(masterOrdersFiltersProvider).copyWith(
              clearSearch: true,
              page: 1,
            );
  }

  void _setPage(int page) {
    ref.read(masterOrdersFiltersProvider.notifier).state =
        ref.read(masterOrdersFiltersProvider).copyWith(page: page);
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(masterOrdersFiltersProvider.notifier).state =
        const MasterOrdersFilters();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = ref.watch(masterOrdersFiltersProvider);
    final ordersAsync = ref.watch(masterOrdersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.masterOrdersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(masterOrdersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.masterOrdersSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Filter chips row
          ordersAsync.when(
            data: (data) {
              final filterOptions =
                  data['filters'] as Map<String, dynamic>? ?? {};
              return _FilterBar(
                states: List<String>.from(filterOptions['states'] ?? []),
                branches: List<String>.from(filterOptions['branches'] ?? []),
                paymentStatuses:
                    List<String>.from(filterOptions['payment_statuses'] ?? []),
                filters: filters,
                onFiltersChanged: (newFilters) {
                  ref.read(masterOrdersFiltersProvider.notifier).state =
                      newFilters;
                },
                onReset: _resetFilters,
              );
            },
            loading: () => const SizedBox(height: 8),
            error: (_, _) => const SizedBox(height: 8),
          ),

          // Results
          Expanded(
            child: ordersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error.toString(),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(masterOrdersProvider),
                        child: Text(l10n.reportsRetry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) {
                final invoices = List<Map<String, dynamic>>.from(
                  (data['invoices'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map)),
                );
                final total = (data['total'] as num?)?.toInt() ?? 0;
                final page = (data['page'] as num?)?.toInt() ?? 1;
                final totalPages =
                    (data['total_pages'] as num?)?.toInt() ?? 1;

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(l10n.masterOrdersNoResults,
                            style: theme.textTheme.bodyLarge),
                        if (filters.search != null ||
                            filters.status != null ||
                            filters.branch != null ||
                            filters.paymentStatus != null) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _resetFilters,
                            child: Text(l10n.masterOrdersClearFilters),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Result count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            l10n.masterOrdersResultCount(total),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Invoice list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(masterOrdersProvider);
                          await ref.read(masterOrdersProvider.future);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            return _OrderCard(
                                invoice: invoices[index]);
                          },
                        ),
                      ),
                    ),

                    // Pagination
                    if (totalPages > 1)
                      _PaginationBar(
                        currentPage: page,
                        totalPages: totalPages,
                        onPageChanged: _setPage,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ─────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final List<String> states;
  final List<String> branches;
  final List<String> paymentStatuses;
  final MasterOrdersFilters filters;
  final ValueChanged<MasterOrdersFilters> onFiltersChanged;
  final VoidCallback onReset;

  const _FilterBar({
    required this.states,
    required this.branches,
    required this.paymentStatuses,
    required this.filters,
    required this.onFiltersChanged,
    required this.onReset,
  });

  bool get _hasActiveFilters =>
      filters.status != null ||
      filters.branch != null ||
      filters.paymentStatus != null ||
      filters.fromDate != null ||
      filters.toDate != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Status filter
            _FilterDropdown(
              label: l10n.masterOrdersFilterStatus,
              value: filters.status,
              options: states,
              onChanged: (val) => onFiltersChanged(
                val == null
                    ? filters.copyWith(clearStatus: true, page: 1)
                    : filters.copyWith(status: val, page: 1),
              ),
            ),
            const SizedBox(width: 8),

            // Branch filter
            _FilterDropdown(
              label: l10n.masterOrdersFilterBranch,
              value: filters.branch,
              options: branches,
              onChanged: (val) => onFiltersChanged(
                val == null
                    ? filters.copyWith(clearBranch: true, page: 1)
                    : filters.copyWith(branch: val, page: 1),
              ),
            ),
            const SizedBox(width: 8),

            // Payment status filter
            _FilterDropdown(
              label: l10n.masterOrdersFilterPayment,
              value: filters.paymentStatus,
              options: paymentStatuses,
              onChanged: (val) => onFiltersChanged(
                val == null
                    ? filters.copyWith(clearPaymentStatus: true, page: 1)
                    : filters.copyWith(paymentStatus: val, page: 1),
              ),
            ),
            const SizedBox(width: 8),

            // Date filter button
            _DateFilterChip(
              fromDate: filters.fromDate,
              toDate: filters.toDate,
              onDateRangeSelected: (from, to) => onFiltersChanged(
                filters.copyWith(
                  fromDate: from,
                  toDate: to,
                  clearFromDate: from == null,
                  clearToDate: to == null,
                  page: 1,
                ),
              ),
            ),

            if (_hasActiveFilters) ...[
              const SizedBox(width: 8),
              ActionChip(
                avatar: Icon(Icons.clear, size: 16,
                    color: theme.colorScheme.error),
                label: Text(l10n.masterOrdersClearFilters,
                    style: TextStyle(color: theme.colorScheme.error)),
                onPressed: onReset,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = value != null;
    return FilterChip(
      selected: isActive,
      label: Text(isActive ? '$label: $value' : label),
      onSelected: (_) async {
        final result = await showModalBottomSheet<String?>(
          context: context,
          builder: (ctx) => _OptionPickerSheet(
            title: label,
            options: options,
            currentValue: value,
          ),
        );
        if (result == '__clear__') {
          onChanged(null);
        } else if (result != null) {
          onChanged(result);
        }
      },
      avatar: isActive
          ? GestureDetector(
              onTap: () => onChanged(null),
              child: Icon(Icons.close, size: 16,
                  color: theme.colorScheme.onSecondaryContainer),
            )
          : null,
    );
  }
}

class _OptionPickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? currentValue;

  const _OptionPickerSheet({
    required this.title,
    required this.options,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (currentValue != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, '__clear__'),
                    child: Text(context.l10n.masterOrdersClearFilters),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (ctx, i) {
                final opt = options[i];
                final selected = opt == currentValue;
                return ListTile(
                  title: Text(opt),
                  trailing: selected
                      ? Icon(Icons.check,
                          color: theme.colorScheme.primary)
                      : null,
                  selected: selected,
                  onTap: () => Navigator.pop(context, opt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  final void Function(String? from, String? to) onDateRangeSelected;

  const _DateFilterChip({
    this.fromDate,
    this.toDate,
    required this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isActive = fromDate != null || toDate != null;
    String label = l10n.masterOrdersFilterDate;
    if (isActive) {
      if (fromDate != null && toDate != null) {
        label = '$fromDate - $toDate';
      } else if (fromDate != null) {
        label = '${l10n.masterOrdersFilterDateFrom} $fromDate';
      } else {
        label = '${l10n.masterOrdersFilterDateTo} $toDate';
      }
    }

    return FilterChip(
      selected: isActive,
      label: Text(label),
      onSelected: (_) async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: now.add(const Duration(days: 365)),
          initialDateRange: fromDate != null && toDate != null
              ? DateTimeRange(
                  start: DateTime.parse(fromDate!),
                  end: DateTime.parse(toDate!),
                )
              : null,
        );
        if (picked != null) {
          final fmt = DateFormat('yyyy-MM-dd');
          onDateRangeSelected(
            fmt.format(picked.start),
            fmt.format(picked.end),
          );
        } else if (isActive) {
          onDateRangeSelected(null, null);
        }
      },
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const _OrderCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final name = invoice['name']?.toString() ?? '';
    final customerName = invoice['customer_name']?.toString() ?? '';
    final postingDate = invoice['posting_date']?.toString() ?? '';
    final postingTime = invoice['posting_time']?.toString() ?? '';
    final grandTotal = (invoice['grand_total'] as num?)?.toDouble() ?? 0;
    final outstanding =
        (invoice['outstanding_amount'] as num?)?.toDouble() ?? 0;
    final state = invoice['state']?.toString() ?? '';
    final branch = invoice['branch']?.toString() ?? '';
    final paymentStatus = invoice['payment_status']?.toString() ?? '';

    final isPaid = paymentStatus.toLowerCase() == 'paid';

    // Format time to show only HH:MM
    String shortTime = '';
    if (postingTime.isNotEmpty) {
      final parts = postingTime.split(':');
      if (parts.length >= 2) {
        shortTime = '${parts[0]}:${parts[1]}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Invoice ID + amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${grandTotal.toStringAsFixed(2)} ${l10n.masterOrdersCurrency}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Row 2: Customer + date/time
            Row(
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$postingDate $shortTime',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 3: Status chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (state.isNotEmpty)
                  _StatusChip(
                    label: state,
                    color: _stateColor(state, theme),
                  ),
                if (branch.isNotEmpty)
                  _StatusChip(
                    label: branch,
                    color: theme.colorScheme.secondaryContainer,
                    textColor: theme.colorScheme.onSecondaryContainer,
                  ),
                _StatusChip(
                  label: paymentStatus,
                  color: isPaid
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  textColor:
                      isPaid ? Colors.green.shade800 : Colors.orange.shade800,
                ),
                if (outstanding > 0)
                  _StatusChip(
                    label:
                        '${l10n.masterOrdersOutstanding}: ${outstanding.toStringAsFixed(2)}',
                    color: Colors.red.shade50,
                    textColor: Colors.red.shade800,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _stateColor(String state, ThemeData theme) {
    switch (state.toLowerCase()) {
      case 'received':
      case 'recieved':
        return Colors.blue.shade50;
      case 'in progress':
      case 'preparing':
        return Colors.amber.shade50;
      case 'ready':
        return Colors.teal.shade50;
      case 'out for delivery':
        return Colors.purple.shade50;
      case 'delivered':
      case 'completed':
        return Colors.green.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const _StatusChip({
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Pagination Bar ─────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed:
                currentPage > 1 ? () => onPageChanged(1) : null,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            iconSize: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$currentPage / $totalPages',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(totalPages)
                : null,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

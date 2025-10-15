import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/repositories/pos_repository.dart';
import '../../state/pos_notifier.dart';
// providers file not present; we use repository providers directly

// Dynamic customer search provider that switches between name and phone search
final dynamicCustomerSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      query,
    ) async {
      if (query.isEmpty) return [];

      final repository = ref.watch(posRepositoryProvider);

      // Check if query contains only digits (phone search) or contains letters (name search)
      // Uncomment if needed for different search types
      // final isPhoneSearch = RegExp(r'^[0-9+\-\s()]+$').hasMatch(query.trim());

      try {
        // Use the same search method but the backend will handle different search types
        return await repository.searchCustomers(query);
      } catch (e) {
        return [];
      }
    });

// Territories provider (local) backed by PosRepository
final territoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>(
  (ref, search) async {
    final repo = ref.watch(posRepositoryProvider);
    return await repo.getTerritories(search: search);
  },
);

class CustomerSearchWidget extends ConsumerStatefulWidget {
  const CustomerSearchWidget({super.key});

  @override
  ConsumerState<CustomerSearchWidget> createState() =>
      _CustomerSearchWidgetState();
}

class _CustomerSearchWidgetState extends ConsumerState<CustomerSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentQuery = query;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedCustomer = ref.watch(
      posNotifierProvider.select((state) => state.selectedCustomer),
    );

    if (selectedCustomer != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildSelectedCustomer(selectedCustomer)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (kDebugMode) {
                      debugPrint('Customer unselect button pressed'); // Debug
                    }
                    ref.read(posNotifierProvider.notifier).unselectCustomer();
                  },
                  tooltip: l10n.posCustomerUnselect,
                  color: Theme.of(context).colorScheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.person_search,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.person_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _showQuickAddCustomerDialog(''),
          tooltip: l10n.posCustomerAdd,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedCustomer(Map<String, dynamic> customer) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          customer['customer_name'] ??
              customer['name'] ??
              l10n.posUnknownCustomer,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        if (customer['mobile_no'] != null)
          Text(
            customer['mobile_no'],
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        if (customer['territory'] != null)
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer['territory'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (customer['delivery_income'] != null &&
            customer['delivery_income'] > 0)
          Row(
            children: [
              Icon(Icons.attach_money, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                l10n.posCustomerDeliveryIncomeValue(
                  _formatCurrency(customer['delivery_income']),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value is num) {
      return '\$${value.toStringAsFixed(2)}';
    }
    if (value == null) {
      return '\$0.00';
    }
    return '\$${value.toString()}';
  }

  Widget _buildSearchField() {
    final isPhoneSearch = RegExp(
      r'^[0-9+\-\s()]+$',
    ).hasMatch(_currentQuery.trim());

    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }

        try {
          final customers = await ref.read(
            dynamicCustomerSearchProvider(textEditingValue.text).future,
          );

          // If no customers found, add a "Quick Add Customer" option
          if (customers.isEmpty && textEditingValue.text.trim().isNotEmpty) {
            return [
              {
                '_isQuickAdd': true,
                'customer_name': 'Quick Add Customer: ${textEditingValue.text}',
                'searchQuery': textEditingValue.text,
              },
            ];
          }

          return customers;
        } catch (e) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
      },
      displayStringForOption: (customer) =>
          customer['customer_name'] ?? customer['name'] ?? 'Unknown',
      onSelected: (customer) {
        if (customer['_isQuickAdd'] == true) {
          _showQuickAddCustomerDialog(customer['searchQuery'] ?? '');
        } else {
          ref.read(posNotifierProvider.notifier).selectCustomer(customer);
          _controller.clear();
          _focusNode.unfocus();
          setState(() {
            _currentQuery = '';
          });
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        _controller.text = controller.text;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          onChanged: _onSearchChanged,
          keyboardType: isPhoneSearch
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: isPhoneSearch
                ? 'Search by phone number...'
                : 'Search by customer name...',
            prefixIcon: Icon(isPhoneSearch ? Icons.phone : Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: _currentQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _currentQuery = '';
                      });
                    },
                  )
                : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 450),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final customer = options.elementAt(index);
                  final isQuickAdd = customer['_isQuickAdd'] == true;

                  return InkWell(
                    onTap: () => onSelected(customer),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isQuickAdd
                            ? Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isQuickAdd
                                ? Icons.add_circle
                                : (isPhoneSearch ? Icons.phone : Icons.person),
                            size: 20,
                            color: isQuickAdd
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isQuickAdd
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Quick Add Customer',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                      Text(
                                        'Tap to create new customer',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        customer['customer_name'] ??
                                            customer['name'] ??
                                            'Unknown',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (customer['mobile_no'] != null)
                                        Text(
                                          customer['mobile_no'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontWeight: isPhoneSearch
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      if (customer['territory'] != null)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                customer['territory'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (customer['delivery_income'] != null &&
                                          customer['delivery_income'] > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 12,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Income: \$${customer['delivery_income']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            if (customer['delivery_expense'] !=
                                                    null &&
                                                customer['delivery_expense'] >
                                                    0) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.money_off,
                                                size: 12,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Expense: \$${customer['delivery_expense']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuickAddCustomerDialog(String initialQuery) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: QuickAddCustomerWidget(
            initialQuery: initialQuery,
            onCustomerCreated: (customer) {
              Navigator.pop(context);
              ref.read(posNotifierProvider.notifier).selectCustomer(customer);
              _controller.clear();
              _focusNode.unfocus();
              setState(() {
                _currentQuery = '';
              });
            },
          ),
        ),
      ),
    );
  }
}

// Quick Add Customer Widget
class QuickAddCustomerWidget extends ConsumerStatefulWidget {
  final String initialQuery;
  final Function(Map<String, dynamic>) onCustomerCreated;

  const QuickAddCustomerWidget({
    super.key,
    required this.initialQuery,
    required this.onCustomerCreated,
  });

  @override
  ConsumerState<QuickAddCustomerWidget> createState() =>
      _QuickAddCustomerWidgetState();
}

class _QuickAddCustomerWidgetState
    extends ConsumerState<QuickAddCustomerWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedTerritoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate name or mobile based on search query
    final isPhone = RegExp(
      r'^[0-9+\-\s()]+$',
    ).hasMatch(widget.initialQuery.trim());
    if (isPhone) {
      _mobileController.text = widget.initialQuery;
    } else {
      _nameController.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If a Sales Partner is selected on the POS, address becomes optional
    final selectedSalesPartner = ref.watch(
      posNotifierProvider.select((s) => s.selectedSalesPartner),
    );
    final bool hasPartner = selectedSalesPartner != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Add Customer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // First row - Customer Name and Mobile Number
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Customer name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Mobile number is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Second row - Territory and Location Link
                    Row(
                      children: [
                        Expanded(child: _buildTerritorySelector()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location Link (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                              hintText: 'Google Maps link, etc.',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Third row - Detailed Address (full width)
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: hasPartner
                            ? 'Detailed Address (Optional)'
                            : 'Detailed Address *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on),
                        alignLabelWithHint: true,
                        helperText: hasPartner
                            ? 'Optional when Sales Partner is selected'
                            : null,
                      ),
                      validator: (value) {
                        if (!hasPartner) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createCustomer,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Customer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerritorySelector() {
    final territoriesAsync = ref.watch(territoriesProvider(null));

    return territoriesAsync.when(
      data: (territories) => DropdownButtonFormField<String>(
        initialValue: _selectedTerritoryId,
        decoration: const InputDecoration(
          labelText: 'Territory *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.location_on),
        ),
        isExpanded: true,
        menuMaxHeight: 320,
        alignment: AlignmentDirectional.centerStart,
        items: territories.map<DropdownMenuItem<String>>((territory) {
          final deliveryInfo =
              territory['delivery_income'] != null &&
                  territory['delivery_income'] > 0
              ? ' (Income: \$${territory['delivery_income']})'
              : '';
          return DropdownMenuItem<String>(
            value: territory['name'],
            child: SizedBox(
              width: 360,
              child: Text(
                '${territory['territory_name'] ?? 'Unknown Territory'}$deliveryInfo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedTerritoryId = value;
            // no-op: name used directly from selection for server call
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a territory';
          }
          return null;
        },
      ),
      loading: () => TextFormField(
        decoration: InputDecoration(
          labelText: 'Territory *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.location_on),
          suffixIcon: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        enabled: false,
      ),
      error: (error, stack) => TextFormField(
        decoration: InputDecoration(
          labelText: 'Territory *',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.location_on),
          errorText: 'Failed to load territories',
        ),
        enabled: false,
      ),
    );
  }

  void _createCustomer() async {
    if (!_formKey.currentState!.validate() || _selectedTerritoryId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
        // If Sales Partner is selected and address is empty, auto-fill with partner name
  final selectedSalesPartner = ref.read(posNotifierProvider.select((s) => s.selectedSalesPartner));
      final bool hasPartner = selectedSalesPartner != null;
      String addressValue = _addressController.text.trim();
      if (hasPartner && addressValue.isEmpty) {
  final Map<String, dynamic> sp = selectedSalesPartner;
        String partnerLabel = 'Sales Partner';
        for (final key in const ['title', 'partner_name', 'name']) {
          final val = sp[key];
          if (val != null && val.toString().trim().isNotEmpty) {
            partnerLabel = val.toString();
            break;
          }
        }
        addressValue = partnerLabel;
      }

  final newCustomer = await ref.read(posRepositoryProvider).createCustomer(
    customerName: _nameController.text.trim(),
    mobileNumber: _mobileController.text.trim(),
    territoryId: _selectedTerritoryId!,
    detailedAddress: addressValue,
    locationLink: _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : null,
      );

      if (mounted) {
        widget.onCustomerCreated(newCustomer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final friendly = e is ApiException ? e.message : 'Failed to create customer';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendly),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

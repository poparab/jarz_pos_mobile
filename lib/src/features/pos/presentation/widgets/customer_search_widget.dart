import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/timing_config.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/customer_shipping_address_dialog.dart';
import '../../../../core/repositories/customer_address_repository.dart';
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
final territoriesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((
      ref,
      search,
    ) async {
      final repo = ref.watch(posRepositoryProvider);
      return await repo.getTerritories(search: search);
    });

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
    _debounceTimer = Timer(UiDebounce.customerSearch, () {
      if (mounted) {
        setState(() {
          _currentQuery = query;
        });
      }
    });
  }

  Map<String, dynamic> _mergeCustomerAddressBook(
    Map<String, dynamic> customer,
    Map<String, dynamic> addressBook,
    List<Map<String, dynamic>> territories,
  ) {
    final addresses = (addressBook['addresses'] as List? ?? const [])
        .whereType<Map>()
        .map((address) => Map<String, dynamic>.from(address))
        .toList();
    final selectedAddress = addressBook['selected_address'] is Map
        ? Map<String, dynamic>.from(addressBook['selected_address'] as Map)
        : <String, dynamic>{};
    final selectedPhone =
        selectedAddress['phone']?.toString().trim().isNotEmpty == true
        ? selectedAddress['phone'].toString().trim()
        : (addressBook['default_phone']?.toString().trim() ??
              customer['mobile_no']?.toString().trim() ??
              '');
    final selectedTerritory = _firstNonEmptyString(selectedAddress, const [
      'city',
      'state',
      'territory',
    ]);
    final territory = _findTerritory(territories, selectedTerritory);
    final deliveryIncome =
        _asDouble(
          territory?['delivery_income'] ??
              selectedAddress['delivery_income'] ??
              customer['delivery_income'],
        ) ??
        0.0;
    final territoryDisplay = _firstNonEmptyString(territory ?? const {}, const [
      'territory_name',
      'name',
      'id',
    ]);

    return {
      ...customer,
      'shipping_addresses': addresses,
      'selected_shipping_address_name':
          addressBook['selected_address_name']?.toString().trim() ?? '',
      'selected_shipping_address':
          selectedAddress['full_address']?.toString().trim() ?? '',
      if (selectedTerritory.isNotEmpty) ...{
        'territory': selectedTerritory,
        'selected_shipping_address_territory': selectedTerritory,
      },
      if (territoryDisplay.isNotEmpty) 'territory_name': territoryDisplay,
      'delivery_income': deliveryIncome,
      'selected_shipping_address_delivery_income': deliveryIncome,
      'selected_shipping_phone': selectedPhone,
      if (selectedPhone.isNotEmpty) 'mobile_no': selectedPhone,
    };
  }

  String _firstNonEmptyString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString().trim() ?? '');
  }

  Map<String, dynamic>? _findTerritory(
    List<Map<String, dynamic>> territories,
    String territoryValue,
  ) {
    final normalized = territoryValue.trim();
    if (normalized.isEmpty) {
      return null;
    }

    for (final territory in territories) {
      final candidates = [
        territory['name'],
        territory['id'],
        territory['territory_name'],
      ].map((value) => value?.toString().trim()).whereType<String>();
      if (candidates.any((candidate) => candidate == normalized)) {
        return territory;
      }
    }
    return null;
  }

  Future<void> _selectCustomerWithShippingAddress(
    Map<String, dynamic> customer, {
    bool forcePicker = false,
  }) async {
    final customerName = customer['name']?.toString().trim() ?? '';
    if (customerName.isEmpty) {
      return;
    }

    final repository = ref.read(posRepositoryProvider);
    final addressRepo = ref.read(customerAddressRepositoryProvider);
    Map<String, dynamic> addressBook;
    List<Map<String, dynamic>> territories;
    try {
      final results = await Future.wait([
        repository.getCustomerShippingAddresses(customer: customerName),
        addressRepo.getTerritories(),
      ]);
      addressBook = results[0] as Map<String, dynamic>;
      territories = (results[1] as List).cast<Map<String, dynamic>>();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerShippingAddressLoadFailed)),
      );
      return;
    }

    if (!mounted) return;

    final addresses = (addressBook['addresses'] as List? ?? const [])
        .whereType<Map>()
        .map((address) => Map<String, dynamic>.from(address))
        .toList();

    if (forcePicker || addresses.length > 1 || addresses.isEmpty) {
      final selection = await CustomerShippingAddressDialog.show(
        context,
        customerName: customer['customer_name']?.toString() ?? customerName,
        customer: customerName,
        addresses: addresses,
        territories: territories,
        initialSelectedAddressName:
            addressBook['selected_address_name']?.toString() ?? '',
        initialPhone:
            addressBook['default_phone']?.toString() ??
            customer['mobile_no']?.toString() ??
            '',
        repository: addressRepo,
      );
      if (selection == null || !mounted) {
        return;
      }

      try {
        final saveResult = await repository.saveCustomerShippingAddress(
          customer: customerName,
          phone: selection['phone']?.toString() ?? '',
          addressName: selection['address_name']?.toString(),
          address: selection['address']?.toString(),
          territory: selection['territory']?.toString(),
        );
        addressBook = saveResult['address_book'] is Map
            ? Map<String, dynamic>.from(saveResult['address_book'] as Map)
            : addressBook;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.invoiceAddressUpdateFailed)),
        );
        return;
      }
    }

    if (!mounted) return;
    ref
        .read(posNotifierProvider.notifier)
        .selectCustomer(
          _mergeCustomerAddressBook(customer, addressBook, territories),
        );
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _currentQuery = '';
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
                  icon: const Icon(Icons.location_on),
                  onPressed: () => _selectCustomerWithShippingAddress(
                    selectedCustomer,
                    forcePicker: true,
                  ),
                  tooltip: l10n.customerShippingAddressTitle,
                  color: Theme.of(context).colorScheme.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
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
        if ((customer['selected_shipping_address'] ?? '').toString().isNotEmpty)
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
                  customer['selected_shipping_address'].toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
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
                  customer['territory_name_ar']?.toString() ??
                      customer['territory_name']?.toString() ??
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

    final isPhone = ResponsiveUtils.isPhone(context);
    return Autocomplete<Map<String, dynamic>>(
      optionsViewOpenDirection: isPhone
          ? OptionsViewOpenDirection.up
          : OptionsViewOpenDirection.down,
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
          _selectCustomerWithShippingAddress(
            Map<String, dynamic>.from(customer),
          );
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
                ? context.l10n.customerSearchByPhone
                : context.l10n.customerSearchByName,
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
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ResponsiveUtils.isPhoneLandscape(context)
                    ? 180
                    : 250,
                maxWidth: ResponsiveUtils.getDialogWidth(
                  context,
                  small: 450,
                  medium: 450,
                  large: 450,
                ),
              ),
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
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.3)
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
                                        context.l10n.quickAddCustomerTitle,
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
                                        context.l10n.quickAddCustomerTap,
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
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.getDialogWidth(
              context,
              small: 800,
              medium: 800,
              large: 800,
            ),
            maxHeight: ResponsiveUtils.getDialogHeight(
              context,
              phoneFraction: 0.9,
              tabletFraction: 0.78,
              max: 600,
            ),
          ),
          child: QuickAddCustomerWidget(
            initialQuery: initialQuery,
            onCustomerCreated: (customer) {
              Navigator.pop(context);
              _selectCustomerWithShippingAddress(customer);
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
  final _secondaryMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedTerritoryId;
  bool _isLoading = false;

  // Customer type / group (Phase 2 commercial policy support).
  static const _kIndividual = 'Individual';
  static const _kCompany = 'Company';
  // Company customer groups offered for B2B-style accounts.
  static const _companyCustomerGroups = <String>[
    'B2B',
    'Distributor',
    'Employee',
    'Sample',
  ];
  String _customerType = _kIndividual;
  String? _customerGroup;

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
    _secondaryMobileController.dispose();
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
                  context.l10n.quickAddCustomerTitle,
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
                            decoration: InputDecoration(
                              labelText: context.l10n.customerNameLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.l10n.customerNameRequired;
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
                            decoration: InputDecoration(
                              labelText: context.l10n.mobileNumberLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.l10n.mobileNumberRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Second phone number (optional)
                    TextFormField(
                      controller: _secondaryMobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: context.l10n.secondaryPhoneLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone_android),
                        hintText: context.l10n.secondaryPhoneHint,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer type (Individual / Company) + group when Company
                    _buildCustomerTypeSelector(),
                    if (_customerType == _kCompany) ...[
                      const SizedBox(height: 16),
                      _buildCustomerGroupSelector(),
                    ],
                    const SizedBox(height: 16),

                    // Second row - Territory and Location Link
                    Row(
                      children: [
                        Expanded(child: _buildTerritorySelector()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: context.l10n.locationLinkLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.link),
                              hintText: context.l10n.locationLinkHint,
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
                            ? context.l10n.detailedAddressOptional
                            : context.l10n.detailedAddressRequired,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on),
                        alignLabelWithHint: true,
                        helperText: hasPartner
                            ? context.l10n.addressOptionalPartner
                            : null,
                      ),
                      validator: (value) {
                        if (!hasPartner) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n.addressRequired;
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
                    child: Text(context.l10n.commonCancel),
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
                        : Text(context.l10n.posCreateCustomer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTypeSelector() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customerTypeLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(
                value: _kIndividual,
                label: Text(context.l10n.customerTypeIndividual),
                icon: const Icon(Icons.person_outline),
              ),
              ButtonSegment<String>(
                value: _kCompany,
                label: Text(context.l10n.customerTypeCompany),
                icon: const Icon(Icons.business_outlined),
              ),
            ],
            selected: {_customerType},
            onSelectionChanged: (selection) {
              setState(() {
                _customerType = selection.first;
                if (_customerType == _kIndividual) {
                  _customerGroup = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGroupSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _customerGroup,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: context.l10n.customerGroupLabel,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.groups_outlined),
      ),
      items: _companyCustomerGroups
          .map(
            (group) =>
                DropdownMenuItem<String>(value: group, child: Text(group)),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _customerGroup = value;
        });
      },
      validator: (value) {
        if (_customerType == _kCompany && (value == null || value.isEmpty)) {
          return context.l10n.customerGroupRequired;
        }
        return null;
      },
    );
  }

  Widget _buildTerritorySelector() {
    final territoriesAsync = ref.watch(territoriesProvider(null));

    return territoriesAsync.when(
      data: (territories) => DropdownButtonFormField<String>(
        initialValue: _selectedTerritoryId,
        decoration: InputDecoration(
          labelText: context.l10n.territoryLabel,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.location_on),
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
              width: ResponsiveUtils.isPhone(context) ? 260 : 360,
              child: Text(
                '${territory['territory_name_ar'] ?? territory['territory_name'] ?? context.l10n.unknownTerritory}$deliveryInfo',
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
            return context.l10n.territorySelectRequired;
          }
          return null;
        },
      ),
      loading: () => TextFormField(
        decoration: InputDecoration(
          labelText: context.l10n.territoryLabel,
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
          labelText: context.l10n.territoryLabel,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.location_on),
          errorText: context.l10n.territoryLoadFailed,
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
      final selectedSalesPartner = ref.read(
        posNotifierProvider.select((s) => s.selectedSalesPartner),
      );
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

      final newCustomer = await ref
          .read(posRepositoryProvider)
          .createCustomer(
            customerName: _nameController.text.trim(),
            mobileNumber: _mobileController.text.trim(),
            territoryId: _selectedTerritoryId!,
            detailedAddress: addressValue,
            locationLink: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            secondaryMobile: _secondaryMobileController.text.trim().isNotEmpty
                ? _secondaryMobileController.text.trim()
                : null,
            customerType: _customerType,
            customerGroup: _customerType == _kCompany ? _customerGroup : null,
          );

      if (mounted) {
        widget.onCustomerCreated(newCustomer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.posCustomerCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final friendly = e is ApiException
            ? e.message
            : context.l10n.customerCreateFailed;
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

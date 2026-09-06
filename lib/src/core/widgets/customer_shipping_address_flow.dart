import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../repositories/customer_address_repository.dart';
import 'customer_shipping_address_dialog.dart';

/// Loads and selects a standard Customer shipping Address, then returns the
/// customer map shape consumed by POS invoice creation. B2B callers can require
/// named branches and keep the Customer primary address unchanged.
Future<Map<String, dynamic>?> chooseCustomerShippingAddress(
  BuildContext context, {
  required Map<String, dynamic> customer,
  required CustomerAddressRepository repository,
  Map<String, dynamic>? initialAddressBook,
  bool forcePicker = false,
  bool requireBranchName = false,
  bool setAsPrimary = true,
}) async {
  final customerId = customer['name']?.toString().trim() ?? '';
  if (customerId.isEmpty) return null;

  Map<String, dynamic> addressBook;
  List<Map<String, dynamic>> territories;
  try {
    final results = await Future.wait<Object>([
      initialAddressBook == null
          ? repository.getAddresses(customer: customerId)
          : Future<Map<String, dynamic>>.value(initialAddressBook),
      repository.getTerritories(),
    ]);
    addressBook = Map<String, dynamic>.from(results[0] as Map);
    territories = (results[1] as List).cast<Map<String, dynamic>>();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerShippingAddressLoadFailed)),
      );
    }
    return null;
  }

  if (!context.mounted) return null;
  final addresses = _selectableAddresses(addressBook);
  Map<String, String>? selection;

  if (!forcePicker &&
      addresses.length == 1 &&
      !_asBool(addresses.single['territory_missing'])) {
    final only = addresses.single;
    final name = only['name']?.toString().trim() ?? '';
    if (name.isEmpty) return null;
    selection = {
      'address_name': name,
      'phone':
          _firstNonEmpty(only, const ['phone']) ??
          addressBook['default_phone']?.toString().trim() ??
          customer['mobile_no']?.toString().trim() ??
          '',
    };
  } else {
    selection = await CustomerShippingAddressDialog.show(
      context,
      customerName:
          customer['customer_name']?.toString().trim().isNotEmpty == true
          ? customer['customer_name'].toString().trim()
          : customerId,
      customer: customerId,
      addresses: addresses,
      territories: territories,
      initialSelectedAddressName:
          addressBook['selected_address_name']?.toString() ?? '',
      initialPhone:
          addressBook['default_phone']?.toString() ??
          customer['mobile_no']?.toString() ??
          '',
      repository: repository,
      requireBranchName: requireBranchName,
    );
    if (selection == null || !context.mounted) return null;
  }

  try {
    final saved = await repository.saveAddress(
      customer: customerId,
      phone: selection['phone'] ?? '',
      addressName: selection['address_name'],
      branchName: selection['branch_name'],
      address: selection['address'],
      territory: selection['territory'],
      locationLink: selection['location_link'],
      latitude: double.tryParse(selection['latitude'] ?? ''),
      longitude: double.tryParse(selection['longitude'] ?? ''),
      geoSource: selection['geo_source'],
      setAsPrimary: setAsPrimary,
    );
    addressBook = saved['address_book'] is Map
        ? Map<String, dynamic>.from(saved['address_book'] as Map)
        : addressBook;
    final selectedName =
        saved['selected_address_name']?.toString().trim().isNotEmpty == true
        ? saved['selected_address_name'].toString().trim()
        : selection['address_name']?.trim() ?? '';
    if (selectedName.isNotEmpty) {
      addressBook = _withExplicitSelection(addressBook, selectedName);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invoiceAddressUpdateFailed)),
      );
    }
    return null;
  }

  return mergeCustomerAddressBook(customer, addressBook, territories);
}

Map<String, dynamic> mergeCustomerAddressBook(
  Map<String, dynamic> customer,
  Map<String, dynamic> addressBook,
  List<Map<String, dynamic>> territories,
) {
  final addresses = _selectableAddresses(addressBook);
  final selectedName =
      addressBook['selected_address_name']?.toString().trim() ?? '';
  final selectedAddress = addressBook['selected_address'] is Map
      ? Map<String, dynamic>.from(addressBook['selected_address'] as Map)
      : addresses.cast<Map<String, dynamic>?>().firstWhere(
              (address) => address?['name']?.toString().trim() == selectedName,
              orElse: () => null,
            ) ??
            <String, dynamic>{};
  final selectedPhone =
      _firstNonEmpty(selectedAddress, const ['phone']) ??
      addressBook['default_phone']?.toString().trim() ??
      customer['mobile_no']?.toString().trim() ??
      '';
  final territoryMissing = _asBool(selectedAddress['territory_missing']);
  final selectedTerritory = territoryMissing
      ? ''
      : (_firstNonEmpty(selectedAddress, const ['effective_territory']) ?? '');
  final selectedTerritoryPosProfile = territoryMissing
      ? ''
      : (_firstNonEmpty(selectedAddress, const ['territory_pos_profile']) ??
            '');
  final territory = _findTerritory(territories, selectedTerritory);
  final deliveryIncome = territoryMissing
      ? 0.0
      : (_asDouble(
              territory?['delivery_income'] ??
                  selectedAddress['delivery_income'] ??
                  customer['delivery_income'],
            ) ??
            0.0);

  return {
    ...customer,
    'shipping_addresses': addresses,
    'selected_shipping_address_name': selectedName,
    'selected_shipping_address':
        selectedAddress['full_address']?.toString().trim() ?? '',
    'selected_shipping_branch_name': customerShippingBranchLabel(
      selectedAddress,
    ),
    'selected_shipping_address_territory_missing': territoryMissing,
    if (selectedTerritory.isNotEmpty) ...{
      'territory': selectedTerritory,
      'selected_shipping_address_territory': selectedTerritory,
    },
    if (selectedTerritoryPosProfile.isNotEmpty)
      'selected_shipping_address_territory_pos_profile':
          selectedTerritoryPosProfile,
    if (territory != null) ...{
      if (_firstNonEmpty(territory, const ['territory_name', 'name', 'id'])
          case final display?)
        'territory_name': display,
      if (_firstNonEmpty(territory, const ['territory_name_ar'])
          case final arabic?)
        'territory_name_ar': arabic,
    },
    'delivery_income': deliveryIncome,
    'selected_shipping_address_delivery_income': deliveryIncome,
    'selected_shipping_phone': selectedPhone,
    if (selectedPhone.isNotEmpty) 'mobile_no': selectedPhone,
  };
}

String customerShippingBranchLabel(Map<String, dynamic> address) =>
    _firstNonEmpty(address, const [
      'branch_name',
      'address_title',
      'address_line1',
      'name',
    ]) ??
    '';

List<Map<String, dynamic>> _selectableAddresses(
  Map<String, dynamic> addressBook,
) {
  final raw = addressBook['branch_options'] is List
      ? addressBook['branch_options'] as List
      : addressBook['addresses'] as List? ?? const [];
  return raw.whereType<Map>().map((address) {
    final normalized = Map<String, dynamic>.from(address);
    normalized.putIfAbsent(
      'name',
      () => normalized['address_name']?.toString() ?? '',
    );
    return normalized;
  }).toList();
}

Map<String, dynamic> _withExplicitSelection(
  Map<String, dynamic> addressBook,
  String selectedName,
) {
  final rows = _selectableAddresses(addressBook);
  final selected = rows.cast<Map<String, dynamic>?>().firstWhere(
    (address) => address?['name']?.toString().trim() == selectedName,
    orElse: () => null,
  );
  return {
    ...addressBook,
    'selected_address_name': selectedName,
    if (selected != null) 'selected_address': selected,
  };
}

String? _firstNonEmpty(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString() == '1';

Map<String, dynamic>? _findTerritory(
  List<Map<String, dynamic>> territories,
  String value,
) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  for (final territory in territories) {
    final match = const [
      'name',
      'id',
      'territory_name',
    ].any((key) => territory[key]?.toString().trim() == normalized);
    if (match) return territory;
  }
  return null;
}

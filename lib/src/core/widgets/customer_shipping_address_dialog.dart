import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

class CustomerShippingAddressDialog extends StatefulWidget {
  final String customerName;
  final List<Map<String, dynamic>> addresses;
  final String initialSelectedAddressName;
  final String initialPhone;
  final String? title;

  const CustomerShippingAddressDialog({
    super.key,
    required this.customerName,
    required this.addresses,
    required this.initialSelectedAddressName,
    required this.initialPhone,
    this.title,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String customerName,
    required List<Map<String, dynamic>> addresses,
    required String initialSelectedAddressName,
    required String initialPhone,
    String? title,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => CustomerShippingAddressDialog(
        customerName: customerName,
        addresses: addresses,
        initialSelectedAddressName: initialSelectedAddressName,
        initialPhone: initialPhone,
        title: title,
      ),
    );
  }

  @override
  State<CustomerShippingAddressDialog> createState() =>
      _CustomerShippingAddressDialogState();
}

class _CustomerShippingAddressDialogState
    extends State<CustomerShippingAddressDialog> {
  late final TextEditingController _phoneController;
  late final TextEditingController _newAddressController;
  late bool _isAddingNewAddress;
  String? _selectedAddressName;

  @override
  void initState() {
    super.initState();
    _selectedAddressName = widget.initialSelectedAddressName.isNotEmpty
        ? widget.initialSelectedAddressName
        : (widget.addresses.isNotEmpty
            ? widget.addresses.first['name']?.toString()
            : null);
    _isAddingNewAddress = widget.addresses.isEmpty;

    final selectedAddress = widget.addresses.cast<Map<String, dynamic>?>().firstWhere(
          (address) =>
              address?['name']?.toString() == _selectedAddressName,
          orElse: () => null,
        );
    final initialPhone =
        selectedAddress?['phone']?.toString().trim().isNotEmpty == true
            ? selectedAddress!['phone'].toString().trim()
            : widget.initialPhone;

    _phoneController = TextEditingController(text: initialPhone);
    _newAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _newAddressController.dispose();
    super.dispose();
  }

  void _selectSavedAddress(String? addressName) {
    setState(() {
      _selectedAddressName = addressName;
    });

    final selectedAddress = widget.addresses.cast<Map<String, dynamic>?>().firstWhere(
          (address) => address?['name']?.toString() == addressName,
          orElse: () => null,
        );
    final selectedPhone = selectedAddress?['phone']?.toString().trim() ?? '';
    if (selectedPhone.isNotEmpty) {
      _phoneController.text = selectedPhone;
    }
  }

  void _submit() {
    final newAddress = _newAddressController.text.trim();
    if (_isAddingNewAddress && newAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invoiceAddressEmpty)),
      );
      return;
    }

    if (!_isAddingNewAddress && (_selectedAddressName ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerShippingAddressSelectRequired)),
      );
      return;
    }

    Navigator.of(context).pop({
      if (!_isAddingNewAddress) 'address_name': _selectedAddressName!.trim(),
      if (_isAddingNewAddress) 'address': newAddress,
      'phone': _phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title ?? l10n.customerShippingAddressTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customerName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.customerShippingAddressSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (widget.addresses.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.customerShippingAddressSavedTab),
                      selected: !_isAddingNewAddress,
                      onSelected: (_) {
                        setState(() {
                          _isAddingNewAddress = false;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.customerShippingAddressNewTab),
                      selected: _isAddingNewAddress,
                      onSelected: (_) {
                        setState(() {
                          _isAddingNewAddress = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (!_isAddingNewAddress && widget.addresses.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.addresses.length,
                    itemBuilder: (context, index) {
                      final address = widget.addresses[index];
                      final addressName = address['name']?.toString() ?? '';
                      final subtitleParts = <String>[];
                      final phone = address['phone']?.toString().trim() ?? '';
                      if (phone.isNotEmpty) {
                        subtitleParts.add(phone);
                      }
                      if (address['is_primary_address'] == true) {
                        subtitleParts.add('Primary');
                      }
                      final isSelected = _selectedAddressName == addressName;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _selectSavedAddress(addressName),
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                          title: Text(address['full_address']?.toString() ?? ''),
                          subtitle: subtitleParts.isEmpty
                              ? null
                              : Text(subtitleParts.join(' • ')),
                        ),
                      );
                    },
                  ),
                )
              else ...[
                if (widget.addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.customerShippingAddressEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                TextField(
                  controller: _newAddressController,
                  decoration: InputDecoration(
                    labelText: l10n.invoiceDeliveryAddressLabel,
                    prefixIcon: const Icon(Icons.edit_location_alt),
                    border: const OutlineInputBorder(),
                    helperText: l10n.invoiceAddressHelper,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.invoicePhoneNumber,
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
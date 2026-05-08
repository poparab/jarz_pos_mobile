import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../repositories/customer_address_repository.dart';

/// Dialog for selecting, adding, editing, and deleting customer shipping
/// addresses.
///
/// Returns a ``Map<String, String>?`` with:
///   - ``address_name`` when an existing saved address is chosen, OR
///   - ``address`` (free-text) when adding a brand-new address,
///   plus ``phone`` in both cases.
///
/// Edit and delete are handled inline; the dialog calls
/// [CustomerAddressRepository] directly and refreshes its own list.
class CustomerShippingAddressDialog extends StatefulWidget {
  final String customerName;
  final String customer;
  final List<Map<String, dynamic>> addresses;
  final List<Map<String, dynamic>> territories;
  final String initialSelectedAddressName;
  final String initialPhone;
  final String? title;
  final CustomerAddressRepository repository;

  const CustomerShippingAddressDialog({
    super.key,
    required this.customerName,
    required this.customer,
    required this.addresses,
    required this.territories,
    required this.initialSelectedAddressName,
    required this.initialPhone,
    required this.repository,
    this.title,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String customerName,
    required String customer,
    required List<Map<String, dynamic>> addresses,
    required List<Map<String, dynamic>> territories,
    required String initialSelectedAddressName,
    required String initialPhone,
    required CustomerAddressRepository repository,
    String? title,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => CustomerShippingAddressDialog(
        customerName: customerName,
        customer: customer,
        addresses: addresses,
        territories: territories,
        initialSelectedAddressName: initialSelectedAddressName,
        initialPhone: initialPhone,
        repository: repository,
        title: title,
      ),
    );
  }

  @override
  State<CustomerShippingAddressDialog> createState() =>
      _CustomerShippingAddressDialogState();
}

/// Which tab is shown.
enum _Tab { saved, addNew }

/// Internal sub-state when editing a saved address inline.
class _EditState {
  _EditState({
    required this.addressName,
    required this.line1Controller,
    required this.line2Controller,
    required this.phoneController,
    required this.pincodeController,
    required this.selectedTerritory,
  });

  final String addressName;
  final TextEditingController line1Controller;
  final TextEditingController line2Controller;
  final TextEditingController phoneController;
  final TextEditingController pincodeController;
  String? selectedTerritory;

  void dispose() {
    line1Controller.dispose();
    line2Controller.dispose();
    phoneController.dispose();
    pincodeController.dispose();
  }
}

class _CustomerShippingAddressDialogState
    extends State<CustomerShippingAddressDialog> {
  late final TextEditingController _phoneController;
  late final TextEditingController _newAddressController;
  late final TextEditingController _newLine2Controller;
  late final TextEditingController _newPincodeController;

  late List<Map<String, dynamic>> _addresses;
  late _Tab _tab;
  String? _selectedAddressName;
  String? _newTerritory;

  _EditState? _editState;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _addresses = List.from(widget.addresses);
    _selectedAddressName = widget.initialSelectedAddressName.isNotEmpty
        ? widget.initialSelectedAddressName
        : (_addresses.isNotEmpty ? _addresses.first['name']?.toString() : null);
    _tab = _addresses.isEmpty ? _Tab.addNew : _Tab.saved;

    final selectedAddress =
        _addresses.cast<Map<String, dynamic>?>().firstWhere(
              (a) => a?['name']?.toString() == _selectedAddressName,
              orElse: () => null,
            );
    final initialPhone =
        selectedAddress?['phone']?.toString().trim().isNotEmpty == true
            ? selectedAddress!['phone'].toString().trim()
            : widget.initialPhone;

    _phoneController = TextEditingController(text: initialPhone);
    _newAddressController = TextEditingController();
    _newLine2Controller = TextEditingController();
    _newPincodeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _newAddressController.dispose();
    _newLine2Controller.dispose();
    _newPincodeController.dispose();
    _editState?.dispose();
    super.dispose();
  }

  // â”€â”€ helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _selectSavedAddress(String? addressName) {
    setState(() {
      _selectedAddressName = addressName;
      _editState = null;
    });
    final selected = _addresses.cast<Map<String, dynamic>?>().firstWhere(
          (a) => a?['name']?.toString() == addressName,
          orElse: () => null,
        );
    final phone = selected?['phone']?.toString().trim() ?? '';
    if (phone.isNotEmpty) _phoneController.text = phone;
  }

  void _startEdit(Map<String, dynamic> address) {
    _editState?.dispose();
    setState(() {
      _editState = _EditState(
        addressName: address['name']?.toString() ?? '',
        line1Controller:
            TextEditingController(text: address['address_line1']?.toString() ?? ''),
        line2Controller:
            TextEditingController(text: address['address_line2']?.toString() ?? ''),
        phoneController:
            TextEditingController(text: address['phone']?.toString() ?? ''),
        pincodeController:
            TextEditingController(text: address['pincode']?.toString() ?? ''),
        selectedTerritory: address['city']?.toString(),
      );
    });
  }

  void _cancelEdit() {
    _editState?.dispose();
    setState(() {
      _editState = null;
    });
  }

  Future<void> _saveEdit() async {
    final es = _editState;
    if (es == null) return;

    final line1 = es.line1Controller.text.trim();
    if (line1.isEmpty) {
      _showError(context.l10n.customerShippingAddressLine1Required);
      return;
    }

    setState(() => _isBusy = true);
    try {
      final updated = await widget.repository.updateAddress(
        customer: widget.customer,
        addressName: es.addressName,
        addressLine1: line1,
        addressLine2: es.line2Controller.text.trim(),
        city: es.selectedTerritory,
        phone: es.phoneController.text.trim(),
        pincode: es.pincodeController.text.trim(),
      );
      // Refresh list from server response.
      final newAddresses = (updated['addresses'] as List? ?? [])
          .whereType<Map>()
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      setState(() {
        _addresses = newAddresses;
        _editState?.dispose();
        _editState = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.customerShippingAddressUpdateSuccess)),
        );
      }
    } catch (e) {
      _showError('${context.l10n.customerShippingAddressUpdateFailed}: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> address) async {
    final addressName = address['name']?.toString() ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.customerShippingAddressDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final result = await widget.repository.deleteAddress(
        customer: widget.customer,
        addressName: addressName,
      );
      final newAddresses =
          ((result['address_book'] as Map?)?['addresses'] as List? ?? [])
              .whereType<Map>()
              .map((a) => Map<String, dynamic>.from(a))
              .toList();
      setState(() {
        _addresses = newAddresses;
        if (_selectedAddressName == addressName) {
          _selectedAddressName =
              newAddresses.isNotEmpty ? newAddresses.first['name']?.toString() : null;
        }
        if (newAddresses.isEmpty) _tab = _Tab.addNew;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.customerShippingAddressDeleteSuccess)),
        );
      }
    } catch (e) {
      _showError('${context.l10n.customerShippingAddressDeleteFailed}: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _submit() {
    if (_tab == _Tab.addNew) {
      final newAddress = _newAddressController.text.trim();
      if (newAddress.isEmpty) {
        _showError(context.l10n.invoiceAddressEmpty);
        return;
      }
      Navigator.of(context).pop({
        'address': newAddress,
        'phone': _phoneController.text.trim(),
        if (_newTerritory != null && _newTerritory!.isNotEmpty)
          'territory': _newTerritory!,
      });
    } else {
      if ((_selectedAddressName ?? '').trim().isEmpty) {
        _showError(context.l10n.customerShippingAddressSelectRequired);
        return;
      }
      Navigator.of(context).pop({
        'address_name': _selectedAddressName!.trim(),
        'phone': _phoneController.text.trim(),
      });
    }
  }

  // â”€â”€ build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
          if (_isBusy)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customerName,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.customerShippingAddressSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              // Tab chips.
              if (_addresses.isNotEmpty || _tab == _Tab.saved) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_addresses.isNotEmpty)
                      ChoiceChip(
                        label: Text(l10n.customerShippingAddressSavedTab),
                        selected: _tab == _Tab.saved,
                        onSelected: (_) {
                          setState(() {
                            _tab = _Tab.saved;
                            _editState?.dispose();
                            _editState = null;
                          });
                        },
                      ),
                    ChoiceChip(
                      label: Text(l10n.customerShippingAddressNewTab),
                      selected: _tab == _Tab.addNew,
                      onSelected: (_) {
                        setState(() {
                          _tab = _Tab.addNew;
                          _editState?.dispose();
                          _editState = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Saved addresses list.
              if (_tab == _Tab.saved && _addresses.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final addressName = address['name']?.toString() ?? '';
                      final isSelected = _selectedAddressName == addressName;
                      final isEditing = _editState?.addressName == addressName;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: isEditing
                            ? _buildEditForm(address)
                            : _buildAddressRow(
                                address: address,
                                addressName: addressName,
                                isSelected: isSelected,
                              ),
                      );
                    },
                  ),
                ),
              // Empty state.
              if (_tab == _Tab.saved && _addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.customerShippingAddressEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              // Add new form.
              if (_tab == _Tab.addNew) ...[
                TextField(
                  controller: _newAddressController,
                  decoration: InputDecoration(
                    labelText: l10n.invoiceDeliveryAddressLabel,
                    prefixIcon: const Icon(Icons.edit_location_alt),
                    border: const OutlineInputBorder(),
                    helperText: l10n.invoiceAddressHelper,
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                _TerritoryDropdown(
                  territories: widget.territories,
                  value: _newTerritory,
                  onChanged: (v) => setState(() => _newTerritory = v),
                  label: l10n.customerShippingAddressTerritoryLabel,
                ),
              ],
              const SizedBox(height: 16),
              // Phone field (shown only when not inside an inline edit form).
              if (_editState == null)
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
        if (_editState == null)
          ElevatedButton.icon(
            onPressed: _isBusy ? null : _submit,
            icon: const Icon(Icons.save),
            label: Text(l10n.commonSave),
          ),
      ],
    );
  }

  Widget _buildAddressRow({
    required Map<String, dynamic> address,
    required String addressName,
    required bool isSelected,
  }) {
    final subtitleParts = <String>[];
    final phone = address['phone']?.toString().trim() ?? '';
    if (phone.isNotEmpty) subtitleParts.add(phone);
    if (address['is_primary_address'] == true) subtitleParts.add('Primary');

    return ListTile(
      onTap: () => _selectSavedAddress(addressName),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(address['full_address']?.toString() ?? ''),
      subtitle:
          subtitleParts.isEmpty ? null : Text(subtitleParts.join(' â€¢ ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: context.l10n.customerShippingAddressEditTab,
            onPressed: _isBusy ? null : () => _startEdit(address),
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.customerShippingAddressDeleteConfirm,
            color: Theme.of(context).colorScheme.error,
            onPressed: _isBusy ? null : () => _confirmDelete(address),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(Map<String, dynamic> address) {
    final es = _editState!;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerShippingAddressEditTitle,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: es.line1Controller,
            decoration: InputDecoration(
              labelText: l10n.customerShippingAddressLine1Label,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: es.line2Controller,
            decoration: InputDecoration(
              labelText: l10n.customerShippingAddressLine2Label,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 8),
          _TerritoryDropdown(
            territories: widget.territories,
            value: es.selectedTerritory,
            onChanged: (v) => setState(() => es.selectedTerritory = v),
            label: l10n.customerShippingAddressTerritoryLabel,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: es.phoneController,
            decoration: InputDecoration(
              labelText: l10n.invoicePhoneNumber,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: es.pincodeController,
            decoration: InputDecoration(
              labelText: l10n.customerShippingAddressPincodeLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isBusy ? null : _cancelEdit,
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isBusy ? null : _saveEdit,
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple dropdown for territory selection.
class _TerritoryDropdown extends StatelessWidget {
  const _TerritoryDropdown({
    required this.territories,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final List<Map<String, dynamic>> territories;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (territories.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<String>(
      value: territories.any((t) => t['name']?.toString() == value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      isExpanded: true,
      items: territories
          .map(
            (t) => DropdownMenuItem<String>(
              value: t['name']?.toString() ?? '',
              child: Text(t['territory_name']?.toString() ?? t['name']?.toString() ?? ''),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}


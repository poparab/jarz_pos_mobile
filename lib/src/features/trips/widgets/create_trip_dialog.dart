import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localized_display_mappers.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../kanban/models/kanban_models.dart';
import '../../kanban/providers/kanban_provider.dart';
import '../providers/trip_provider.dart';

/// Dialog shown when user creates a delivery trip from multi-selected invoices.
class CreateTripDialog extends ConsumerStatefulWidget {
  final List<InvoiceCard> selectedInvoices;

  const CreateTripDialog({super.key, required this.selectedInvoices});

  @override
  ConsumerState<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends ConsumerState<CreateTripDialog> {
  String? _selectedPartyType;
  String? _selectedParty;
  bool _isLoading = false;
  List<Map<String, dynamic>> _couriers = [];

  double get _totalAmount => widget.selectedInvoices.fold(0.0, (s, i) => s + i.grandTotal);
  double get _totalShipping => widget.selectedInvoices.fold(0.0, (s, i) => s + i.shippingExpense);

  Set<String> get _territories {
    return widget.selectedInvoices.map((i) {
      final sub = i.subTerritoryDisplay ?? i.subTerritory;
      final terr = i.territoryNameAr ?? i.territoryDisplay ?? i.territory;
      return (sub != null && sub.isNotEmpty) ? sub : terr;
    }).toSet();
  }

  bool get _allSameTerritory => _territories.length == 1;

  @override
  void initState() {
    super.initState();
    _loadCouriers();
  }

  Future<void> _loadCouriers() async {
    try {
      final svc = ref.read(kanbanServiceProvider);
      final couriers = await svc.rawPost('/api/method/jarz_pos.api.couriers.get_active_couriers', {});
      if (couriers is Map && couriers['data'] != null) {
        setState(() {
          _couriers = List<Map<String, dynamic>>.from(couriers['data'] as List);
        });
      } else if (couriers is List) {
        setState(() {
          _couriers = List<Map<String, dynamic>>.from(couriers);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(l10n.tripsCreateTripTitle, style: const TextStyle(fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: ResponsiveUtils.getDialogWidth(
          context,
          small: 400,
          medium: 460,
          large: 520,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(l10n.tripsOrdersLabel, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Text('${widget.selectedInvoices.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(l10n.tripsTotalAmount, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Text(formatCurrency(context, _totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(l10n.tripsTotalShipping, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Text(formatCurrency(context, _totalShipping), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange[700])),
                    ]),
                    if (_allSameTerritory) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber[700]!),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.double_arrow, size: 14, color: Colors.amber[800]),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.tripsSameTerritory(_territories.first),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Courier selection
              Text(l10n.tripsSelectCourier, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_couriers.isEmpty)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    itemCount: _couriers.length,
                    itemBuilder: (context, index) {
                      final c = _couriers[index];
                      final partyType = (c['party_type'] ?? '').toString();
                      final party = (c['party'] ?? c['name'] ?? '').toString();
                      final label = (c['display_name'] ?? c['employee_name'] ?? c['supplier_name'] ?? party).toString();
                      final isSelected = _selectedParty == party && _selectedPartyType == partyType;

                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor: Colors.indigo.withValues(alpha: 0.08),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected ? Colors.indigo : Colors.grey[300],
                          child: Icon(
                            partyType == 'Employee' ? Icons.person : Icons.business,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        title: Text(label, style: const TextStyle(fontSize: 13)),
                        subtitle: Text(localizedPartyTypeLabel(context, partyType), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        onTap: () => setState(() {
                          _selectedPartyType = partyType;
                          _selectedParty = party;
                        }),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedParty == null ? null : _createTrip,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l10n.tripsCreateTripButton, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _createTrip() async {
    // Client-side pre-validation: check sub-territory requirements
    final missingSubTerritory = widget.selectedInvoices
        .where((inv) => inv.hasSubTerritories && (inv.subTerritory == null || inv.subTerritory!.isEmpty))
        .toList();
    if (missingSubTerritory.isNotEmpty) {
      if (mounted) {
        final names = missingSubTerritory.map((inv) => inv.id).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.tripsSubTerritoryRequired(names)),
            backgroundColor: Colors.orange[800],
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tripNotifier = ref.read(tripProvider.notifier);
      final trip = await tripNotifier.createTrip(
        invoiceNames: widget.selectedInvoices.map((i) => i.id).toList(),
        partyType: _selectedPartyType!,
        party: _selectedParty!,
      );
      if (trip != null && mounted) {
        Navigator.of(context).pop(trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tripsCreateTripFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

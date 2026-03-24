import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_models.dart';
import '../providers/trip_provider.dart';

/// Detailed view of a single delivery trip with invoice list and actions.
class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripName;
  const TripDetailScreen({super.key, required this.tripName});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    ref.read(tripProvider.notifier).loadTripDetails(widget.tripName);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripProvider);
    final trip = state.selectedTrip;

    return Scaffold(
      appBar: AppBar(title: Text(widget.tripName)),
      body: trip == null
          ? state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(child: Text(state.error ?? 'Trip not found'))
          : RefreshIndicator(
              onRefresh: () => ref.read(tripProvider.notifier).loadTripDetails(widget.tripName),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(trip),
                  const SizedBox(height: 16),
                  _buildInvoiceList(trip),
                ],
              ),
            ),
      bottomNavigationBar: trip != null && trip.isCreated ? _buildSendBar(trip) : null,
    );
  }

  Widget _buildHeader(DeliveryTrip trip) {
    final statusColor = switch (trip.status) {
      'Created' => Colors.blue,
      'Out for Delivery' => Colors.orange,
      'Completed' => Colors.green,
      _ => Colors.grey,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: statusColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(trip.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(trip.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const Divider(height: 20),
            _detailRow('Courier', trip.courierDisplayName),
            _detailRow('Date', trip.tripDate),
            _detailRow('Orders', trip.totalOrders.toString()),
            _detailRow('Total Amount', '\$${trip.totalAmount.toStringAsFixed(2)}'),
            _detailRow('Shipping Expense', '\$${trip.totalShippingExpense.toStringAsFixed(2)}'),
            if (trip.isDoubleShipping) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[700]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.double_arrow, size: 14, color: Colors.amber[800]),
                    const SizedBox(width: 4),
                    Text(
                      'Double Shipping — ${trip.doubleShippingTerritory ?? 'Same territory'}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                    ),
                  ],
                ),
              ),
            ],
            if (trip.notes != null && trip.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${trip.notes}', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(DeliveryTrip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoices (${trip.invoices.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...trip.invoices.map(_buildInvoiceRow),
      ],
    );
  }

  Widget _buildInvoiceRow(TripInvoice inv) {
    final statusColor = switch (inv.invoiceStatus) {
      'Delivered' => Colors.green,
      'Out for Delivery' => Colors.orange,
      'Return' || 'Returned to Sender' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inv.invoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(inv.customerName, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text(
                    inv.subTerritory ?? inv.territory,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${inv.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    inv.invoiceStatus,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendBar(DeliveryTrip trip) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: _sending ? null : () => _sendForDelivery(trip),
          icon: _sending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send),
          label: Text(_sending ? 'Sending...' : 'Send for Delivery'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _sendForDelivery(DeliveryTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send for Delivery'),
        content: Text('Send ${trip.totalOrders} orders for delivery?\n\nCourier: ${trip.courierDisplayName}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      await ref.read(tripProvider.notifier).sendForDelivery(trip.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip sent for delivery')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

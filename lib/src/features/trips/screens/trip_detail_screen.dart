import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/localization_extensions.dart';
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
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(tripDetailProvider(widget.tripName));

    return Scaffold(
      appBar: AppBar(title: Text(widget.tripName)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.commonErrorWithDetails(err.toString()), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(tripDetailProvider(widget.tripName)),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (trip) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tripDetailProvider(widget.tripName));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(trip),
              const SizedBox(height: 16),
              _buildInvoiceList(trip),
            ],
          ),
        ),
      ),
      bottomNavigationBar: detailAsync.whenOrNull(
        data: (trip) {
          if (trip.isCreated) return _buildSendBar(trip);
          if (trip.isOutForDelivery) return _buildMarkDeliveredBar(trip);
          return null;
        },
      ),
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
        ...trip.invoices.map((inv) => _TripInvoiceCard(invoice: inv)),
      ],
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
          label: Text(_sending ? context.l10n.tripsSending : context.l10n.tripsSendForDeliveryTitle),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkDeliveredBar(DeliveryTrip trip) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: _sending ? null : () => _markAsDelivered(trip),
          icon: _sending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_outline),
          label: Text(_sending ? context.l10n.tripsMarking : context.l10n.tripsMarkAsDeliveredButton),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
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
        title: Text(context.l10n.tripsSendForDeliveryTitle),
        content: Text(context.l10n.tripsSendForDeliveryContent(trip.totalOrders, trip.courierDisplayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.commonConfirm)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      await ref.read(tripProvider.notifier).sendForDelivery(trip.name);
      if (!mounted) return;
      // Refresh the detail view
      ref.invalidate(tripDetailProvider(widget.tripName));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tripsSentForDeliverySuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonErrorWithDetails(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _markAsDelivered(DeliveryTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.tripsMarkAsDeliveredButton),
        content: Text(context.l10n.tripsMarkAllAsDeliveredContent(trip.totalOrders)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: Text(context.l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      await ref.read(tripProvider.notifier).markAsDelivered(trip.name);
      if (!mounted) return;
      ref.invalidate(tripDetailProvider(widget.tripName));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tripsTripMarkedSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonErrorWithDetails(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

/// Expandable card showing full details of a trip invoice.
class _TripInvoiceCard extends StatefulWidget {
  final TripInvoice invoice;
  const _TripInvoiceCard({required this.invoice});

  @override
  State<_TripInvoiceCard> createState() => _TripInvoiceCardState();
}

class _TripInvoiceCardState extends State<_TripInvoiceCard> {
  bool _expanded = false;

  TripInvoice get inv => widget.invoice;

  Color get _statusColor => switch (inv.invoiceStatus) {
    'Delivered' => Colors.green,
    'Out for Delivery' => Colors.orange,
    'Return' || 'Returned to Sender' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactRow(),
              if (_expanded) ...[
                const Divider(height: 16),
                _buildExpandedDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(inv.invoice, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  _statusBadge(inv.invoiceStatus, _statusColor),
                  if (inv.isPaid) ...[
                    const SizedBox(width: 4),
                    _statusBadge('Paid', Colors.green),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(inv.customerName, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              Text(inv.subTerritoryDisplay ?? inv.territoryDisplay ?? inv.subTerritory ?? inv.territory, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            if (inv.shippingExpense > 0)
              Text('Ship: \$${inv.shippingExpense.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact info
        if (inv.customerPhone != null && inv.customerPhone!.isNotEmpty)
          _infoTile(Icons.phone, inv.customerPhone!, onTap: () {
            final cleaned = inv.customerPhone!.replaceAll(RegExp(r'[^\d+]'), '');
            launchUrl(Uri.parse('tel:$cleaned'));
          }),
        if (inv.address != null && inv.address!.isNotEmpty)
          _infoTile(Icons.location_on, inv.address!),

        // Delivery slot
        if (inv.deliverySlotLabel != null && inv.deliverySlotLabel!.isNotEmpty) ...[
          const SizedBox(height: 4),
          _infoTile(Icons.schedule, inv.deliverySlotLabel!),
        ],
        if (inv.deliveryDate != null && inv.deliveryDate!.isNotEmpty)
          _infoTile(Icons.calendar_today, inv.deliveryDate!),

        // Payment info
        const SizedBox(height: 6),
        Row(
          children: [
            _labelValue('Payment', inv.paymentMethod ?? 'N/A'),
            const SizedBox(width: 16),
            _labelValue('Outstanding', '\$${inv.outstandingAmount.toStringAsFixed(2)}'),
          ],
        ),

        // Items table
        if (inv.items.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: Text('Item', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                      Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('Rate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                      Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                // Rows
                ...inv.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text(item.itemName, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 1, child: Text(item.qty.toStringAsFixed(0), style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('\$${item.rate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10), textAlign: TextAlign.right)),
                      Expanded(flex: 2, child: Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10), textAlign: TextAlign.right)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _infoTile(IconData icon, String text, {VoidCallback? onTap}) {
    final content = Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700]))),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: onTap != null
          ? InkWell(onTap: onTap, child: content)
          : content,
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

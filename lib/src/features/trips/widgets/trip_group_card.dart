import 'package:flutter/material.dart';
import '../../kanban/models/kanban_models.dart';

/// Collapsible card that groups trip invoices in the OFD column.
class TripGroupCard extends StatefulWidget {
  final String tripName;
  final String courierDisplayName;
  final bool isDoubleShipping;
  final List<InvoiceCard> invoices;

  const TripGroupCard({
    super.key,
    required this.tripName,
    required this.courierDisplayName,
    this.isDoubleShipping = false,
    required this.invoices,
  });

  @override
  State<TripGroupCard> createState() => _TripGroupCardState();
}

class _TripGroupCardState extends State<TripGroupCard> {
  bool _expanded = false;

  double get _totalAmount =>
      widget.invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.indigo.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          // Collapsed header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, size: 18, color: Colors.indigo[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tripName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.courierDisplayName} · ${widget.invoices.length} orders',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isDoubleShipping) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber[700]!),
                      ),
                      child: Text(
                        '2× Ship',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '\$${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // Expanded invoice list
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.invoices.map((inv) => _buildInvoiceRow(inv)),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(InvoiceCard inv) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.customerName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  inv.subTerritory ?? inv.territory,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '\$${inv.grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

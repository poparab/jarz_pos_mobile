import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kanban_models.dart';
import '../providers/kanban_provider.dart';
import '../../pos/state/pos_notifier.dart';

class InvoiceCardWidget extends ConsumerStatefulWidget {
  final InvoiceCard invoice;
  final bool isDragging;
  final bool compact; // new: compact representation for drag feedback

  const InvoiceCardWidget({
    super.key,
    required this.invoice,
    this.isDragging = false,
    this.compact = false,
  });

  @override
  ConsumerState<InvoiceCardWidget> createState() => _InvoiceCardWidgetState();
}

class _InvoiceCardWidgetState extends ConsumerState<InvoiceCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _shortInvoiceName(String full) {
    const prefix = 'ACC-SINV-';
    if (full.startsWith(prefix)) {
      return full.substring(prefix.length);
    }
    return full;
  }

  @override
  Widget build(BuildContext context) {
    final transitioning = ref.watch(kanbanProvider.select((s) => s.transitioningInvoices.contains(widget.invoice.id)));
    final card = _buildCard();
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: widget.isDragging ? 0.92 : (transitioning ? 0.55 : 1),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: widget.isDragging ? 1.02 : 1,
        child: Stack(
          children: [
            card,
            if (transitioning)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    final hasProfile = ref.read(posNotifierProvider).selectedProfile != null;
  final isOutForDelivery = _isPostOutForDelivery(widget.invoice.status);
  // Show settlement only when backend indicates there is an unsettled courier transaction
  final hasUnsettled = widget.invoice.hasUnsettledCourierTxn;
  final canSettleSingle = isOutForDelivery && hasUnsettled && (widget.invoice.courierPartyType != null && widget.invoice.courierParty != null);
    if (widget.compact) {
      return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.blueAccent.withValues(alpha: 0.7),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _shortInvoiceName(widget.invoice.name),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.invoice.customerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${widget.invoice.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: widget.isDragging ? 8 : 2,
  shadowColor: widget.isDragging ? Colors.blue.withValues(alpha: 0.3) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.isDragging ? Colors.blue : Colors.grey[300]!,
            width: widget.isDragging ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            InkWell(
              onTap: _toggleExpansion,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.invoice.hasUnsettledCourierTxn)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepOrange.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _shortInvoiceName(widget.invoice.name),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Always-visible action buttons (Pay / Delivery / Print)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.invoice.effectiveStatus.toLowerCase() != 'paid' && !hasUnsettled)
                              Tooltip(
                                message: 'Pay',
                                child: IconButton(
                                  icon: const Icon(Icons.payment, size: 18),
                                  splashRadius: 18,
                                  onPressed: ref.read(kanbanProvider.select((s) => s.transitioningInvoices.contains(widget.invoice.id))) ? null : () => _payInvoice(context),
                                ),
                              ),
                            if (widget.invoice.effectiveStatus.toLowerCase() == 'paid' &&
                                !_isPostOutForDelivery(widget.invoice.status))
                              Tooltip(
                                message: 'Delivery',
                                child: IconButton(
                                  icon: const Icon(Icons.local_shipping, size: 18),
                                  splashRadius: 18,
                                  onPressed: widget.invoice.docStatus?.toLowerCase() != 'paid'
                                      ? null
                                      : (!hasProfile || ref.read(kanbanProvider.select((s) => s.transitioningInvoices.contains(widget.invoice.id)))
                                          ? null
                                          : () => _handleOutForDelivery(context)),
                                ),
                              ),
                            Tooltip(
                              message: 'Print',
                              child: IconButton(
                                icon: const Icon(Icons.print, size: 18),
                                splashRadius: 18,
                                onPressed: ref.read(kanbanProvider.select((s) => s.transitioningInvoices.contains(widget.invoice.id))) ? null : () => _printInvoice(context),
                              ),
                            ),
                            if (hasUnsettled)
                              Tooltip(
                                message: 'Settle Courier',
                                child: IconButton(
                                  icon: const Icon(Icons.handshake, size: 18, color: Colors.teal),
                                  splashRadius: 18,
                                  onPressed: ref.read(kanbanProvider.select((s) => s.transitioningInvoices.contains(widget.invoice.id))) ? null : () => _settleCourierTransaction(context),
                                ),
                              ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Customer and amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                widget.invoice.customerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${widget.invoice.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (widget.invoice.shippingExpenseDisplay > 0) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shipping Exp:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '\$${widget.invoice.shippingExpenseDisplay.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              widget.invoice.effectiveStatus,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.invoice.effectiveStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(widget.invoice.effectiveStatus),
                            ),
                          ),
                        ),
                        Text(
                          widget.invoice.requiredDeliveryDate != null && widget.invoice.requiredDeliveryDate!.isNotEmpty
                              ? widget.invoice.requiredDeliveryDate!
                              : widget.invoice.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.invoice.address.isNotEmpty) ...[
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.invoice.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (widget.invoice.items.isNotEmpty) ...[
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.invoice.items.map(
                        (item) => _buildItemRow(item),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Invoice totals
                    _buildTotalsSection(),

                    const SizedBox(height: 12),

                    // (Action buttons moved to header; keep spacing alignment placeholder)
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.itemName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'x${item.quantity.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${item.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Total',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                '\$${widget.invoice.netTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping Income',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                '\$${widget.invoice.shippingIncomeDisplay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping Expense',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                '\$${widget.invoice.shippingExpenseDisplay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${widget.invoice.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'overdue':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool _isPostOutForDelivery(String status) {
    final s = status.toLowerCase();
    // Recognize states at or beyond the delivery dispatch stage
    return s == 'out for delivery' ||
        s == 'out_for_delivery' ||
        s.contains('out for delivery') ||
        s.contains('out_for_delivery') ||
        s == 'delivered' ||
        s == 'completed' ||
        s == 'returned';
  }

  void _payInvoice(BuildContext context) async {
    // New rule: allow payment in any state except already Paid or Cancelled
    final statusLower = widget.invoice.status.toLowerCase();
    if (statusLower == 'paid' || statusLower == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice already ${widget.invoice.status}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final method = await _showPaymentMethodSheet(context);
    if (method == null) return; // user cancelled
    await _submitPayment(method); // TODO back-end integration
  }

  Future<String?> _showPaymentMethodSheet(BuildContext context) async {
    String? selected = 'Cash';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, size: 20),
                    const SizedBox(width: 8),
                    Text('Select Payment Method',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                _paymentOptionTile(
                  title: 'InstaPay',
                  value: 'InstaPay',
                  groupValue: selected,
                  onChanged: (v) => setModalState(() => selected = v),
                  icon: Icons.account_balance,
                ),
                _paymentOptionTile(
                  title: 'Wallet',
                  value: 'Wallet',
                  groupValue: selected,
                  onChanged: (v) => setModalState(() => selected = v),
                  icon: Icons.account_balance_wallet,
                ),
                _paymentOptionTile(
                  title: 'Cash',
                  value: 'Cash',
                  groupValue: selected,
                  onChanged: (v) => setModalState(() => selected = v),
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(selected),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paymentOptionTile({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          color: selected ? Colors.green.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? Colors.green : Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.green[800] : Colors.black87,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.green : Colors.grey[600],
              size: 20,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _submitPayment(String method) async {
    // Resolve KanbanNotifier
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(kanbanProvider.notifier);
    final posState = container.read(posNotifierProvider);
    final messenger = ScaffoldMessenger.of(context);
    String? posProfile;
    if (method.toLowerCase() == 'cash') {
      posProfile = posState.selectedProfile?['name'];
      if (posProfile == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No POS profile selected for Cash payment')),
        );
        return;
      }
    }
    try {
      messenger.showSnackBar(
        SnackBar(content: Text('Processing $method payment...')),
      );
      final result = await notifier.payInvoice(
        invoiceId: widget.invoice.name,
        paymentMode: method,
        posProfile: posProfile,
      );
      if (result != null && result['success'] == true) {
        messenger.showSnackBar(
          SnackBar(content: Text('Payment successful (${result['payment_entry']})')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Payment failed')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    }
  }

  void _printInvoice(BuildContext context) {
    // TODO: Integrate with receipt/printing service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print invoice ${widget.invoice.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleOutForDelivery(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(kanbanProvider.notifier);
    final posState = container.read(posNotifierProvider);
    final messenger = ScaffoldMessenger.of(context);

  final result = await _showCourierSettlementDialog(context);
    if (result == null) return; // cancelled
  final courier = result['courier'] as String;
  final partyType = result['party_type'] as String?;
  final party = result['party'] as String?;
  final courierDisplay = result['courier_display'] as String?;
    final mode = result['mode'] as String; // pay_now | settle_later
    final posProfile = posState.selectedProfile?['name'];
    if (posProfile == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Select POS profile first')),
      );
      return;
    }

    // If invoice is unpaid and user chose settle_later -> use backend to mark courier outstanding
    final isUnpaid = widget.invoice.status.toLowerCase() == 'unpaid';
    if (isUnpaid && mode == 'settle_later') {
      try {
        final res = await notifier.markCourierOutstanding(
          invoiceId: widget.invoice.name,
          courier: courier,
          partyType: partyType,
          party: party,
          courierDisplay: courierDisplay,
        );
        if (res == null || (res['success'] != true && res['status'] != 'success')) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Failed to mark courier outstanding')),
          );
          return;
        }
        // No popup for settle later per requirement; card will move optimistically and reconcile via reload.
        messenger.showSnackBar(
          const SnackBar(content: Text('Marked Out For Delivery (settle later)')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return;
    }

    // If invoice is unpaid and user chose pay_now we perform a Cash payment first
    if (isUnpaid && mode == 'pay_now') {
      try {
        messenger.showSnackBar(
          const SnackBar(content: Text('Collecting cash payment...')),
        );
        final payRes = await notifier.payInvoice(
          invoiceId: widget.invoice.name,
          paymentMode: 'Cash',
          posProfile: posProfile,
        );
        if (payRes == null || payRes['success'] != true) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Payment failed, aborting delivery')),
          );
          return;
        }
        messenger.showSnackBar(
          SnackBar(content: Text('Payment OK (${payRes['payment_entry']})')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Payment error: $e')),
        );
        return; // abort delivery if payment errored
      }
    }
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Processing Delivery...')),
      );
      final res = await notifier.outForDeliveryUnified(
        invoiceId: widget.invoice.name,
        courier: courier,
        mode: mode,
        posProfile: posProfile,
  partyType: partyType,
  party: party,
  courierDisplay: courierDisplay,
      );
  if (res != null && res['success'] == true) {
        messenger.showSnackBar(
          SnackBar(content: Text('Updated: JE ${res['journal_entry'] ?? '-'}')),
        );
        // If invoice already paid & choosing pay_now: show confirmation dialog to pay courier shipping expense
        final wasPaidBefore = (widget.invoice.status.toLowerCase() == 'paid' || widget.invoice.effectiveStatus.toLowerCase() == 'paid');
        if (mode == 'pay_now') { // show regardless, but wording differs
          final rawAmt = res['shipping_amount'] ?? res['shipping_expense'] ?? res['shippingExpense'] ?? res['shipping'];
          double? amt;
          if (rawAmt is num) {
            amt = rawAmt.toDouble();
          } else if (rawAmt is String) {
            amt = double.tryParse(rawAmt);
          }
                    final amountLabel = amt != null ? '\$${amt.toStringAsFixed(2)}' : null;
          if (!context.mounted) return; // ensure valid context before dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Pay Courier Shipping'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wasPaidBefore
                                    ? 'Pay the courier the shipping expense amount now:'
                                    : 'Pay the courier the shipping expense amount now:',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    if (amountLabel != null)
                      Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(amountLabel,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                    if (amountLabel == null)
                      const Text('Amount not returned by server. Please verify in system.',
                          style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Done'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Delivery action failed')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> _showCourierSettlementDialog(BuildContext context) async {
  String? courier;
  String? partyType;
  String? party;
    String mode = 'pay_now';
    bool loading = true;
  List<Map<String, String>> couriers = [];
  bool creating = false;
  String newPartyType = 'Employee';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

    final container = ProviderScope.containerOf(context, listen: false);
    try {
      couriers = await container.read(kanbanProvider.notifier).getCouriers();
      final posProfile = container.read(posNotifierProvider).selectedProfile?['name'];
      if (posProfile != null) {
        couriers = couriers.where((c) => (c['branch'] == null || c['branch']!.isEmpty) ? true : c['branch'] == posProfile).toList();
      }
    } catch (_) {}
    loading = false;

  if (!context.mounted) return null; // avoid context use if widget disposed
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Delivery'),
            content: SizedBox(
              width: 640,
              child: loading
                  ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        if (widget.invoice.status.toLowerCase() == 'unpaid')
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              border: Border.all(color: Colors.amber.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, size: 18, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Invoice is UNPAID. Choose "Courier Collects Cash Now" to record a cash payment before marking Out For Delivery, or use "Settle Later" to defer collection.',
                                    style: const TextStyle(fontSize: 12, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!creating) ...[
                          if (couriers.isEmpty) ...[
                            const Icon(Icons.local_shipping_outlined, size: 48, color: Colors.orange),
                            const SizedBox(height: 12),
                            Text('No couriers available', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Create a courier then proceed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(height: 16),
                          ] else ...[
                            LayoutBuilder(
                              builder: (ctx, constraints) {
                                final isWide = constraints.maxWidth > 560;
                                final crossAxisCount = isWide ? 3 : 2;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: couriers.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.8,
                                  ),
                                  itemBuilder: (ctx, i) {
                                    final c = couriers[i];
                                    final selected = courier == c['party'];
                                    return InkWell(
                                      onTap: () => setState(() {
                                        courier = c['party'];
                                        partyType = c['party_type'];
                                        party = c['party'];
                                      }),
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: selected ? Colors.blue : Colors.grey[300]!,
                                            width: selected ? 2 : 1,
                                          ),
                                          color: selected ? Colors.blue.withValues(alpha: 0.06) : Colors.white,
                                          boxShadow: [
                                            if (selected)
                                              BoxShadow(
                                                color: Colors.blue.withValues(alpha: 0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: selected ? Colors.blue : Colors.grey[200],
                                              child: Icon(Icons.person, color: selected ? Colors.white : Colors.grey[600]),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    c['display_name'] ?? c['party']!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: selected ? Colors.blue[800] : Colors.black87,
                                                    ),
                                                  ),
                                                  if (c['party_type'] != null)
                                                    Text(
                                                      c['party_type']!,
                                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('New Courier'),
                              onPressed: () => setState(() => creating = true),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: const InputDecoration(labelText: 'First Name'),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: lastNameController,
                                  decoration: const InputDecoration(labelText: 'Last Name'),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'Phone'),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: newPartyType,
                            decoration: const InputDecoration(labelText: 'Type'),
                            items: const [
                              DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                              DropdownMenuItem(value: 'Supplier', child: Text('Supplier')),
                            ],
                            onChanged: (v) => setState(() => newPartyType = v ?? 'Employee'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: loading ? null : () => setState(() => creating = false),
                                child: const Text('Back'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: loading
                                    ? null
                                    : () async {
                                        final firstName = firstNameController.text.trim();
                                        final lastName = lastNameController.text.trim();
                                        final phone = phoneController.text.trim();
                                        if (firstName.isEmpty || lastName.isEmpty) return;
                                        setState(() => loading = true);
                                        try {
                                          final posProfile = container.read(posNotifierProvider).selectedProfile?['name'];
                                          final created = await container.read(kanbanProvider.notifier).createDeliveryParty(
                                            partyType: newPartyType,
                                            firstName: firstName,
                                            lastName: lastName,
                                            phone: phone,
                                            posProfile: posProfile,
                                          );
                                          if (created != null) {
                                            couriers = [...couriers, created];
                                            courier = created['party'];
                                            partyType = created['party_type'];
                                            party = created['party'];
                                            creating = false;
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Create failed: $e')),
                                            );
                                          }
                                        } finally {
                                          setState(() => loading = false);
                                        }
                                      },
                                icon: const Icon(Icons.check),
                                label: const Text('Save'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Mode', style: Theme.of(context).textTheme.titleSmall),
                          ),
                          RadioGroup<String>(
                            groupValue: mode,
                            onChanged: (v) => setState(() => mode = v!),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  title: Text(widget.invoice.status.toLowerCase() == 'unpaid'
                                      ? 'Courier Collects Cash Now'
                                      : 'Pay Now (Already Paid)'),
                                  value: 'pay_now',
                                  dense: true,
                                ),
                                const RadioListTile<String>(
                                  title: Text('Settle Later'),
                                  value: 'settle_later',
                                  dense: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              if (!creating)
                ElevatedButton(
                  onPressed: courier == null || loading ? null : () => Navigator.pop(ctx, {
                    'courier': courier,
                    'mode': mode,
                    'party_type': partyType,
                    'party': party,
                    'courier_display': couriers.firstWhere(
                      (e) => e['party'] == courier,
                      orElse: () => const {},
                    )['display_name'],
                  }),
                  child: const Text('Confirm'),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _settleCourierTransaction(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final posProfile = ref.read(posNotifierProvider).selectedProfile?['name'];
    final partyType = widget.invoice.courierPartyType;
    final party = widget.invoice.courierParty;
    if (posProfile == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
      return;
    }
    // Backend now has fallback logic, so we don't need to check for party info here
    final isPaid = widget.invoice.effectiveStatus.toLowerCase() == 'paid';
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Settling courier...')));
      final notifier = ref.read(kanbanProvider.notifier);
      Map<String, dynamic>? res;
      if (isPaid) {
        res = await notifier.settleSingleInvoicePaid(
          invoiceId: widget.invoice.name,
          posProfile: posProfile,
          partyType: partyType ?? '',
          party: party ?? '',
        );
      } else {
        res = await notifier.settleCourierCollectedPayment(
          invoiceId: widget.invoice.name,
          posProfile: posProfile,
          partyType: partyType ?? '',
          party: party ?? '',
        );
      }
      res ??= {};
      if (!mounted) return;
      if (res['success'] == true) {
        final amt = (res['shipping_amount'] as num?)?.toDouble();
        final courierName = party;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Courier Settlement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay the courier $courierName amount',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (amt != null)
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.teal, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '\$${amt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  )
                else
                  const Text('Amount not found', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        );
        try { await ref.read(kanbanProvider.notifier).loadInvoices(); } catch (_) {}
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Settlement failed')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Settlement error: $e')));
    }
  }
}

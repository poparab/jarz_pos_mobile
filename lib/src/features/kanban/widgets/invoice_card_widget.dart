// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kanban_models.dart';
import '../providers/kanban_provider.dart';
import '../../pos/state/pos_notifier.dart';
import '../../../core/network/courier_service.dart';
import '../../../core/network/user_service.dart';
import '../../manager/data/manager_api.dart';
import 'settlement_preview_dialog.dart';
import '../../printing/pos_printer_provider.dart';
import '../../printing/pos_printer_service.dart';
import '../../pos/order_alert/data/order_alert_service.dart';
import '../../../core/utils/responsive_utils.dart';
// Invoice card widget displaying a Sales Invoice within the Kanban board.

class InvoiceCardWidget extends ConsumerStatefulWidget {
  final InvoiceCard invoice;
  final bool isDragging;
  final bool compact;
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
  bool _isAccepting = false; // Track acceptance state for optimistic UI

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

  Future<void> _printInvoice(BuildContext context) async {
    final printer = ref.read(posPrinterServiceProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preparing receipt...'), duration: Duration(seconds: 1)));
    // Attempt to fetch enriched invoice details for phone/address/shipping if not already present
    InvoiceCard enriched = widget.invoice;
    try {
      // Only fetch if phone missing (we don't currently store phone on card) or to ensure latest shipping
      final details = await ref.read(invoiceDetailsProvider(widget.invoice.id).future);
      if (details != null) {
        enriched = details;
      }
    } catch (_) {}
    // Map items (fallback aggregated item if list empty)
    final items = enriched.items.isNotEmpty
        ? enriched.items
            .map((e) => PrintableInvoiceItem(name: e.itemName, qty: e.qty, rate: e.rate))
            .toList()
        : [PrintableInvoiceItem(name: 'Items (${enriched.itemsCount})', qty: 1, rate: enriched.netTotal)];
    // Paid/outstanding heuristic from card
    final isPaid = (enriched.docStatus?.toLowerCase() == 'paid') || (enriched.effectiveStatus.toLowerCase() == 'paid');
    final paid = isPaid ? enriched.total : 0.0;
    final outstanding = ((enriched.total - paid).clamp(0.0, enriched.total)).toDouble();
    // Use delivery slot from model if available
    final deliveryDT = enriched.deliveryStartDateTime ?? _parseDelivery(enriched.requiredDeliveryDate);
    final inv = PrintableInvoice(
      id: enriched.name,
      date: DateTime.now(),
      customer: enriched.customerName,
      customerAddress: enriched.address.isNotEmpty ? enriched.address : null,
      customerPhone: enriched.customerPhone, // may be null if backend does not supply
      deliveryDateTime: deliveryDT,
      total: enriched.total,
      paid: paid,
      outstanding: outstanding,
      shipping: enriched.isPickup ? 0.0 : enriched.shippingIncome,
      items: items,
    );
    // If not connected attempt reconnect to last saved printer silently
    if (!printer.isConnected && !printer.isClassicConnected) {
      final ok = await printer.connectLastSaved();
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printer not connected. Open Printer Selection from menu.')));
        return;
      }
    }
    final res = await printer.printInvoice(inv);
    if (!mounted) return; // avoid using context after async gap
    switch (res) {
      case PrintResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printed successfully')),
        );
        break;
      case PrintResult.disconnected:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer disconnected')),);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $res')),);
    }
  }

  DateTime? _parseDelivery(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    try {
      // Accept common formats like '2025-01-31 14:20' or ISO
      return DateTime.tryParse(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> _acceptOrder(BuildContext context) async {
    // Set optimistic state immediately
    setState(() {
      _isAccepting = true;
    });

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Accept Order'),
          ],
        ),
        content: Text(
          'Accept order ${_shortInvoiceName(widget.invoice.name)} for ${widget.invoice.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      // Reset if user cancels
      setState(() {
        _isAccepting = false;
      });
      return;
    }

    // Call the acknowledgment API
    try {
      final orderAlertService = ref.read(orderAlertServiceProvider);
      await orderAlertService.acknowledgeInvoice(widget.invoice.id);
      
      if (!context.mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Order ${_shortInvoiceName(widget.invoice.name)} accepted!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh the kanban board to update the UI
      ref.read(kanbanProvider.notifier).loadInvoices();
    } catch (e) {
      // Reset state on error
      setState(() {
        _isAccepting = false;
      });
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to accept order: $e')),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
    final card = _buildCard(transitioning);
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

  Widget _buildCard(bool transitioning) {
    final hasProfile = ref.read(posNotifierProvider).selectedProfile != null;
    // Show settlement only when backend indicates there is an unsettled courier transaction
    final hasUnsettled = widget.invoice.hasUnsettledCourierTxn;
    final hasPartner = (widget.invoice.salesPartner ?? '').isNotEmpty;
    final requiresAcceptance = widget.invoice.requiresAcceptance;
    final trailingWidgets = <Widget>[];
    
    // Responsive sizes
    final iconSize = ResponsiveUtils.getIconSize(context, small: 14, medium: 16, large: 18);
    final buttonIconSize = ResponsiveUtils.getIconSize(context, small: 12, medium: 14, large: 16);
    final buttonPadding = ResponsiveUtils.getButtonPadding(context,
      small: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      medium: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      large: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    final buttonFontSize = ResponsiveUtils.getResponsiveFontSize(context, 12);

    // Add prominent acceptance button if pending (not already accepted or accepting)
    if (requiresAcceptance && !widget.invoice.isAccepted && !_isAccepting) {
      trailingWidgets.add(
        Tooltip(
          message: 'Accept Order',
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              onPressed: transitioning ? null : () => _acceptOrder(context),
              icon: Icon(Icons.check_circle, size: buttonIconSize),
              label: Text('Accept', style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: buttonPadding,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.invoice.isPickup) {
      trailingWidgets.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.7)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store_mall_directory, size: 12, color: Colors.indigo),
              SizedBox(width: 4),
              Text('Pickup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo)),
            ],
          ),
        ),
      );
    }

    if (hasPartner) {
      trailingWidgets.add(
        Tooltip(
          message: 'Sales Partner',
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.handshake,
              size: iconSize,
              color: Colors.deepPurple,
            ),
          ),
        ),
      );
    }

    final canShowPay = !hasPartner && widget.invoice.effectiveStatus.toLowerCase() != 'paid' && !hasUnsettled;
    if (canShowPay) {
      trailingWidgets.add(
        Tooltip(
          message: 'Pay',
          child: IconButton(
            icon: Icon(Icons.payment, size: iconSize),
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, small: 4, medium: 5, large: 6)),
            constraints: BoxConstraints(
              minWidth: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
              minHeight: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
            ),
            splashRadius: ResponsiveUtils.getIconSize(context, small: 16, medium: 18, large: 20),
            onPressed: transitioning ? null : () => _payInvoice(context),
          ),
        ),
      );
    }

    // Removed "Out for Delivery" icon - functionality available elsewhere
    // final canShowDelivery = !_isPostOutForDelivery(widget.invoice.status);
    // if (canShowDelivery) {
    //   trailingWidgets.add(
    //     Tooltip(
    //       message: 'Delivery',
    //       child: IconButton(
    //         icon: Icon(Icons.local_shipping, size: iconSize),
    //         ...
    //       ),
    //     ),
    //   );
    // }

    trailingWidgets.add(
      Tooltip(
        message: 'Print',
        child: IconButton(
          icon: Icon(Icons.print, size: iconSize),
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, small: 4, medium: 5, large: 6)),
          constraints: BoxConstraints(
            minWidth: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
            minHeight: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
          ),
          splashRadius: ResponsiveUtils.getIconSize(context, small: 16, medium: 18, large: 20),
          onPressed: transitioning ? null : () => _printInvoice(context),
        ),
      ),
    );

    // Add three-dot menu for additional actions
    final isLineManager = ref.watch(isLineManagerProvider);
    
    trailingWidgets.add(
      Tooltip(
        message: 'More Options',
        child: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: iconSize),
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, small: 4, medium: 5, large: 6)),
          constraints: BoxConstraints(
            minWidth: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
            minHeight: ResponsiveUtils.getIconSize(context, small: 32, medium: 34, large: 36),
          ),
          splashRadius: ResponsiveUtils.getIconSize(context, small: 16, medium: 18, large: 20),
          enabled: !transitioning,
          onSelected: (value) async {
            if (value == 'edit_address') {
              await _editCustomerAddress(context);
            } else if (value == 'transfer_order') {
              await _transferOrder(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_address',
              child: Row(
                children: [
                  Icon(Icons.edit_location, size: 18),
                  SizedBox(width: 8),
                  Text('Edit Customer Address'),
                ],
              ),
            ),
            if (isLineManager)
              const PopupMenuItem(
                value: 'transfer_order',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 18),
                    SizedBox(width: 8),
                    Text('Transfer Order'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    // Removed "Settle Courier" icon - functionality available elsewhere
    // if (hasUnsettled) {
    //   trailingWidgets.add(
    //     Tooltip(
    //       message: 'Settle Courier',
    //       child: IconButton(
    //         icon: const Icon(Icons.handshake, size: 18, color: Colors.teal),
    //         ...
    //       ),
    //     ),
    //   );
    // }

    trailingWidgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
    if (widget.compact) {
      final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 15);
      final titleFontSize = ResponsiveUtils.getResponsiveFontSize(context, 14);
      final padding = ResponsiveUtils.getCardPadding(context, 
        small: const EdgeInsets.all(8),
        medium: const EdgeInsets.all(10),
        large: const EdgeInsets.all(12),
      );
      
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
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _shortInvoiceName(widget.invoice.name),
                style: TextStyle(
                  fontSize: fontSize,
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
                      style: TextStyle(fontSize: titleFontSize * 0.85),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${widget.invoice.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: titleFontSize,
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
            color: (widget.invoice.isAccepted || _isAccepting)
                ? Colors.green[600]!
                : (widget.isDragging ? Colors.blue : Colors.grey[300]!),
            width: (widget.invoice.isAccepted || _isAccepting) ? 2 : (widget.isDragging ? 2 : 1),
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
                padding: ResponsiveUtils.getCardPadding(context,
                  small: const EdgeInsets.all(12),
                  medium: const EdgeInsets.all(14),
                  large: const EdgeInsets.all(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.invoice.hasUnsettledCourierTxn)
                          Container(
                            width: ResponsiveUtils.getIconSize(context, small: 8, medium: 9, large: 10),
                            height: ResponsiveUtils.getIconSize(context, small: 8, medium: 9, large: 10),
                            margin: EdgeInsets.only(right: 6, top: ResponsiveUtils.getSpacing(context, small: 3, medium: 3.5, large: 4)),
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
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (trailingWidgets.isNotEmpty) SizedBox(width: ResponsiveUtils.getSpacing(context, small: 6, medium: 7, large: 8)),
                        if (trailingWidgets.isNotEmpty)
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                spacing: ResponsiveUtils.getSpacing(context, small: 2, medium: 3, large: 4),
                                runSpacing: ResponsiveUtils.getSpacing(context, small: 2, medium: 3, large: 4),
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.end,
                                children: trailingWidgets,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, small: 6, medium: 7, large: 8)),

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
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                widget.invoice.customerName,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if ((widget.invoice.phone ?? widget.invoice.customerPhone ?? '').isNotEmpty) ...[
                                SizedBox(height: ResponsiveUtils.getSpacing(context, small: 1, medium: 1.5, large: 2)),
                                GestureDetector(
                                  onTap: () {
                                    final phone = widget.invoice.phone ?? widget.invoice.customerPhone;
                                    if (phone != null && phone.isNotEmpty) {
                                      _showPhoneOptions(context, phone);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone, size: 11, color: Colors.blue[700]),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          (widget.invoice.phone ?? widget.invoice.customerPhone)!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[700],
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // Payment method badge
                              if (widget.invoice.paymentMethod != null && widget.invoice.paymentMethod!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                _buildPaymentMethodBadge(widget.invoice.paymentMethod!),
                              ],
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
                            // Hide shipping expense line for Sales Partner invoices per new rule
                            if ((widget.invoice.salesPartner == null || widget.invoice.salesPartner!.isEmpty) && widget.invoice.shippingExpenseDisplay > 0) ...[
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
                        // Show delivery slot label if available; fallback to posting date
                        Builder(builder: (context) {
                          final label = (widget.invoice.deliveryDateTimeLabel).trim();
                          final show = label.isNotEmpty;
                          return Text(
                            show ? label : widget.invoice.postingDateHumanized,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        }),
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
                    if (!widget.invoice.isPickup && widget.invoice.address.isNotEmpty) ...[
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
    final hasPartner = (widget.invoice.salesPartner ?? '').isNotEmpty;
    final children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Net Total', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Text('\$${widget.invoice.netTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
      const SizedBox(height: 4),
    ];
    if (!hasPartner && !widget.invoice.isPickup) {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Income', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text('\$${widget.invoice.shippingIncomeDisplay.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );
      children.add(const SizedBox(height: 4));
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Expense', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text('\$${widget.invoice.shippingExpenseDisplay.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    children.addAll([
      const Divider(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('\$${widget.invoice.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    ]);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(children: children),
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
        
        // Show collect cash dialog for cash payments
        if (method.toLowerCase() == 'cash') {
          final amount = result['amount'] ?? result['allocated_amount'];
          if (amount != null && context.mounted) {
            _showCollectCashDialog(context, amount.toString(), widget.invoice.name);
          }
        }
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

  void _showCollectCashDialog(BuildContext context, String amount, String invoiceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💰 Collect Cash'),
        content: Text(
          'Please collect from the customer:\n\n'
          'Total Amount: $amount EGP\n\n'
          'This includes:\n'
          '• Order items\n'
          '• Shipping fee\n\n'
          'Invoice: $invoiceId',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOutForDelivery(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(kanbanProvider.notifier);
    final posState = container.read(posNotifierProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Fast-path for Sales Partner invoices:
    // 1. If already paid + has Sales Partner -> direct state change (legacy fast path retained)
    // 2. NEW: If UNPAID + has Sales Partner -> auto create cash Payment Entry & OFD via backend endpoint (skip courier UI completely)
    final hasPartner = ((widget.invoice.salesPartner ?? '').isNotEmpty);
    final isPaid = (widget.invoice.status).toString().toLowerCase() == 'paid' || (widget.invoice.effectiveStatus).toString().toLowerCase() == 'paid';
    final posProfileName = posState.selectedProfile?['name'];

    if (hasPartner) {
      final statusLower = (widget.invoice.status).toString().toLowerCase();
      final effLower = (widget.invoice.effectiveStatus).toString().toLowerCase();
      final isUnpaid = statusLower == 'unpaid' || effLower == 'unpaid' || statusLower == 'overdue' || effLower == 'overdue' || statusLower.contains('part') || effLower.contains('part');
      if (isUnpaid) {
        if (posProfileName == null) {
          messenger.showSnackBar(const SnackBar(content: Text('Select POS Profile first')));
          return;
        }
        messenger.showSnackBar(const SnackBar(content: Text('Collecting cash & dispatching (Sales Partner)...')));
        try {
          // We don't have a direct method: call raw endpoint via notifier/apiService if available
          final raw = await container.read(kanbanProvider.notifier).callBackend(
            '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
            data: {
              'invoice_name': widget.invoice.name,
              'pos_profile': posProfileName,
              'mode_of_payment': 'Cash',
            },
          );
          if ((raw['success'] == true) || (raw['message']?['success'] == true)) {
            messenger.showSnackBar(const SnackBar(content: Text('Cash collected & sent Out For Delivery')));
            await notifier.refreshSingle(widget.invoice.name);
          } else {
            messenger.showSnackBar(SnackBar(content: Text('Failed: ${(raw['message'] ?? raw).toString()}')));
          }
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        return;
      } else if (isPaid) {
        try {
          await notifier.updateInvoiceState(widget.invoice.name, 'Out For Delivery');
          messenger.showSnackBar(const SnackBar(content: Text('Sent Out For Delivery (DN will be created)')));
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('Action failed: $e')));
        }
        return;
      }
    }

    final result = await _showCourierSettlementDialog(context, hideSettleLater: true);
    if (result == null) return; // cancelled
    final courier = result['courier'] as String?;
    final courierDisplay = result['courier_display'] as String?;
    String? partyType = result['party_type'] as String?;
    String? party = result['party'] as String?;
    final mode = (result['mode'] ?? 'pay_now').toString();
    final posProfile = posState.selectedProfile?['name'];
    if (posProfile == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
      return;
    }

    final courierLabel = courierDisplay?.isNotEmpty == true
        ? courierDisplay!
        : ((courier != null && courier.isNotEmpty) ? courier : 'UNKNOWN');

    if (mode == 'later') {
      try {
        final courierService = ref.read(courierServiceProvider);
        final preview = await courierService.generateSettlementPreview(
          invoice: widget.invoice.name,
          partyType: partyType,
          party: party,
          mode: 'later',
          recentPaymentSeconds: 30,
        );
        final previewPartyType = (preview['party_type'] ?? '').toString().trim();
        final previewParty = (preview['party'] ?? '').toString().trim();
        partyType = (partyType?.trim().isNotEmpty ?? false) ? partyType!.trim() : (previewPartyType.isNotEmpty ? previewPartyType : null);
        party = (party?.trim().isNotEmpty ?? false) ? party!.trim() : (previewParty.isNotEmpty ? previewParty : null);
        final token = (preview['preview_token'] ?? preview['token'] ?? '').toString();
        if (partyType == null || party == null || token.isEmpty) {
          messenger.showSnackBar(const SnackBar(content: Text('Settle Later failed: courier party missing.')));
          return;
        }
        final res = await courierService.confirmSettlement(
          invoice: widget.invoice.name,
          previewToken: token,
          mode: 'later',
          posProfile: posProfile,
          partyType: partyType,
          party: party,
          courier: courierLabel,
        );
        if (res['success'] == true) {
          messenger.showSnackBar(const SnackBar(content: Text('Marked to Settle Later')));
        } else {
          messenger.showSnackBar(const SnackBar(content: Text('Settle Later failed')));
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Settle Later error: $e')));
      }
      return;
    }

    // For pay_now flows always use preview -> confirm so backend handles paid/unpaid logic uniformly
    if (mode == 'pay_now') {
      try {
        final courierService = ref.read(courierServiceProvider);
        final preview = await courierService.generateSettlementPreview(
          invoice: widget.invoice.name,
          partyType: partyType,
          party: party,
          mode: mode,
          recentPaymentSeconds: 30,
        );
        final previewPartyType = (preview['party_type'] ?? '').toString().trim();
        final previewParty = (preview['party'] ?? '').toString().trim();
        partyType = (partyType?.trim().isNotEmpty ?? false) ? partyType!.trim() : (previewPartyType.isNotEmpty ? previewPartyType : null);
        party = (party?.trim().isNotEmpty ?? false) ? party!.trim() : (previewParty.isNotEmpty ? previewParty : null);
        if (partyType == null || party == null) {
          messenger.showSnackBar(const SnackBar(content: Text('Settlement failed: courier party missing.')));
          return;
        }
        if (!mounted) return;
        final confirmed = await showSettlementConfirmDialog(
          context,
          preview,
          invoice: widget.invoice.name,
          territory: widget.invoice.territory,
          orderFallback: widget.invoice.grandTotal,
          shippingFallback: widget.invoice.shippingExpenseDisplay.toDouble(),
        );
        if (confirmed != true) return;
        final token = (preview['preview_token'] ?? preview['token'] ?? '').toString();
        if (token.isEmpty) {
          messenger.showSnackBar(const SnackBar(content: Text('Preview expired. Please retry.')));
          return;
        }
        messenger.showSnackBar(const SnackBar(content: Text('Confirming settlement...')));
        final res = await courierService.confirmSettlement(
          invoice: widget.invoice.name,
          previewToken: token,
          mode: mode,
          posProfile: posProfile,
          partyType: partyType,
          party: party,
          paymentMode: 'Cash',
          courier: courierLabel,
        );
        if (res['success'] == true) {
          messenger.showSnackBar(const SnackBar(content: Text('Settlement confirmed')));
          try {
            await notifier.refreshSingle(widget.invoice.name);
          } catch (_) {}
        } else {
          messenger.showSnackBar(const SnackBar(content: Text('Settlement failed')));
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Settlement error: $e')));
      }
      return;
    }

    try {
      messenger.showSnackBar(const SnackBar(content: Text('Processing Delivery...')));
      final res = await notifier.outForDeliveryUnified(
        invoiceId: widget.invoice.name,
        courier: courier ?? 'UNKNOWN',
        mode: mode,
        posProfile: posProfile,
        partyType: partyType,
        party: party,
        courierDisplay: courierDisplay,
      );
      if (res != null && res['success'] == true) {
        messenger.showSnackBar(const SnackBar(content: Text('Updated')));
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Delivery action failed')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<Map<String, dynamic>?> _showCourierSettlementDialog(BuildContext context, {bool hideSettleLater = true}) async {
    String? courier;
    String? partyType;
    String? party;
    String mode = 'pay_now';
    bool loading = true;
    List<Map<String, String>> couriers = [];
    bool creating = false;
    String newPartyType = 'Supplier'; // Default to Supplier (Employee has validation issues on staging)

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
    if (!context.mounted) return null;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Delivery'),
            content: SizedBox(
              width: ResponsiveUtils.getDialogWidth(context, small: 350, medium: 480, large: 640),
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
                                      'Invoice is UNPAID. Choose "Courier Collects Cash Now" to record a cash payment before marking Out For Delivery.',
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
                          // Only Pay Now option is available per new rule
                          RadioGroup<String>(
                            groupValue: mode,
                            onChanged: (v) => setState(() => mode = v ?? mode),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  title: Text('Pay Now (Cash)'),
                                  value: 'pay_now',
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
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (!creating)
                ElevatedButton(
                  onPressed: courier == null || loading
                      ? null
                      : () => Navigator.pop(ctx, {
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
          );
        },
      ),
    );
  }

  Future<void> _settleCourierTransaction(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final posProfile = ref.read(posNotifierProvider).selectedProfile?['name'];
    // Treat blank strings from model as null so we can adopt backend preview values
    String? partyType = (widget.invoice.courierPartyType?.trim().isEmpty ?? true)
        ? null
        : widget.invoice.courierPartyType;
    String? party = (widget.invoice.courierParty?.trim().isEmpty ?? true)
        ? null
        : widget.invoice.courierParty;
    if (posProfile == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Select POS profile first')));
      return;
    }

    try {
      // 1. Fetch settlement preview (signed net amount logic)
      final courierService = ref.read(courierServiceProvider);
      // Fallback: if invoice missing party info try preview without filters first to derive existing CT party
      Map<String, dynamic> preview;
      try {
        preview = await courierService.getSettlementPreview(
          invoice: widget.invoice.name,
          partyType: partyType,
          party: party,
        );
      } catch (_) {
        preview = await courierService.getSettlementPreview(invoice: widget.invoice.name);
      }
      // Adopt party derived by backend if we passed blanks / nulls
      if (partyType == null || partyType.trim().isEmpty) {
        final pv = (preview['party_type'] ?? '').toString().trim();
        if (pv.isNotEmpty) partyType = pv;
      }
      if (party == null || party.trim().isEmpty) {
        final pv = (preview['party'] ?? '').toString().trim();
        if (pv.isNotEmpty) party = pv;
      }
      // Validate we now have party identifiers (backend endpoints require them)
      if (partyType == null || partyType.isEmpty || party == null || party.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Cannot settle: courier party not resolved. Assign courier or retry.')));
        return;
      }
      if (!context.mounted) return;

      // 2. Show confirmation dialog with collect / pay details (shared helper)
      final confirmed = await showSettlementConfirmDialog(
        context,
        preview,
        invoice: widget.invoice.name,
        territory: widget.invoice.territory,
        orderFallback: widget.invoice.grandTotal, // use invoice total when preview omits
        shippingFallback: (widget.invoice.shippingExpenseDisplay).toDouble(),
      );
      if (confirmed != true) return; // user cancelled

      // 3. Determine which backend endpoint based on net amount sign
      final netRaw = preview['net_amount'];
      final net = (netRaw is num) ? netRaw.toDouble() : double.tryParse(netRaw?.toString() ?? '0') ?? 0.0;

      final notifier = ref.read(kanbanProvider.notifier);
      Map<String, dynamic>? res;

      if (net > 0) {
        // Branch collects from courier (courier collected payment from customer)
        res = await notifier.settleCourierCollectedPayment(
          invoiceId: widget.invoice.name,
          posProfile: posProfile,
          partyType: partyType,
          party: party,
        );
      } else if (net < 0) {
        // Branch pays courier shipping expense
        res = await notifier.settleSingleInvoicePaid(
          invoiceId: widget.invoice.name,
          posProfile: posProfile,
          partyType: partyType,
          party: party,
        );
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Nothing to settle')));
        return;
      }

  if (!context.mounted) return;
      if (res != null && (res['success'] == true || res['journal_entry'] != null)) {
        messenger.showSnackBar(const SnackBar(content: Text('Settlement complete')));
        try {
          await ref.read(kanbanProvider.notifier).loadInvoices();
        } catch (_) {}
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Settlement failed')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Settlement error: $e')));
    }
  }

  /// Build payment method badge with color coding
  Widget _buildPaymentMethodBadge(String paymentMethod) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (paymentMethod) {
      case 'Cash':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.attach_money;
        break;
      case 'Instapay':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.account_balance;
        break;
      case 'Mobile Wallet':
        bgColor = Colors.purple[50]!;
        textColor = Colors.purple[700]!;
        icon = Icons.phone_android;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Text(
            paymentMethod,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Edit customer address dialog
  Future<void> _editCustomerAddress(BuildContext context) async {
    final addressController = TextEditingController(text: widget.invoice.address);
    final phoneController = TextEditingController(text: widget.invoice.customerPhone ?? '');
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit_location, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Customer Address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: ResponsiveUtils.getDialogWidth(context, small: 320, medium: 420, large: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name (read-only)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone number
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Address
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    helperText: 'Enter the full delivery address',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                
                // Info message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will update the customer\'s default address and phone number.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newAddress = addressController.text.trim();
              final newPhone = phoneController.text.trim();
              
              if (newAddress.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Address cannot be empty')),
                );
                return;
              }
              
              Navigator.pop(ctx, {
                'address': newAddress,
                'phone': newPhone,
              });
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    // Show loading indicator
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Updating customer address...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final notifier = ref.read(kanbanProvider.notifier);
      final success = await notifier.updateCustomerAddress(
        customer: widget.invoice.customer,
        address: result['address']!,
        phone: result['phone']!,
      );

      messenger.clearSnackBars();
      
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Customer address updated successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Refresh the invoice to show updated address
        await notifier.refreshSingle(widget.invoice.name);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Failed to update address'),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Show dialog with options to call or copy phone number
  Future<void> _showPhoneOptions(BuildContext context, String phoneNumber) async {
    // Remove any whitespace or formatting to get clean number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.phone, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Phone Number'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the phone number (non-selectable, non-trimmed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      phoneNumber, // Display original format with spaces
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              // Copy to clipboard
              await Clipboard.setData(ClipboardData(text: cleanNumber));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Copied: $cleanNumber'),
                      ],
                    ),
                    backgroundColor: Colors.green[600],
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              // Launch phone dialer
              final uri = Uri(scheme: 'tel', path: cleanNumber);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Unable to make phone call'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.call),
            label: const Text('Call'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  // Transfer order to another POS profile
  Future<void> _transferOrder(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(kanbanProvider.notifier);

    try {
      // Get current POS profile
      final currentProfile = ref.read(posNotifierProvider).selectedProfile?['name'] as String?;
      if (currentProfile == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No POS profile selected'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Fetch available POS profiles
      final managerApi = ref.read(managerApiProvider);
      final summary = await managerApi.getSummary();
      final branches = summary.branches;

      if (!context.mounted) return;

      // Filter out current profile
      final availableBranches = branches
          .where((b) => b.name != currentProfile)
          .toList();

      if (availableBranches.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No other POS profiles available for transfer'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Show dialog to select target POS profile
      String? selectedBranch = availableBranches.first.name;
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz, size: 24),
                  SizedBox(width: 12),
                  Text('Transfer Order'),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${widget.invoice.customerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invoice: ${widget.invoice.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Target POS Profile:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBranch,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: availableBranches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch.name,
                          child: Text(branch.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The order will be moved to the selected POS profile and reset to "Received" state for acceptance.',
                              style: TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Transfer'),
                ),
              ],
            ),
          );
        },
      );

      if (!context.mounted || confirmed != true || selectedBranch == null) return;

      // Show loading indicator
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Transferring order...'),
            ],
          ),
          duration: Duration(hours: 1),
        ),
      );

      // Call backend to transfer (selectedBranch is guaranteed non-null here)
      final success = await notifier.transferInvoice(
        invoiceId: widget.invoice.name,
        newBranch: selectedBranch!,
      );

      messenger.clearSnackBars();

      if (!context.mounted) return;

      if (success) {
        // Refresh the kanban board
        ref.invalidate(kanbanProvider);
        
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Order transferred successfully to ${availableBranches.firstWhere((b) => b.name == selectedBranch).title}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Failed to transfer order')),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// End of InvoiceCardWidget state class


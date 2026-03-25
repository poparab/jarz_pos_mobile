import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

// Shared settlement dialogs used across Kanban and POS screens, to avoid duplication.
// Computes consistent labels from preview:
// - net_amount > 0  => Collect From Courier (Order - Shipping)
// - net_amount < 0  => Pay Courier (Order - Shipping)
// Also shows an explicit Paid/Unpaid line derived from preview flags.

double _asDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

double _firstNumberFrom(Map<String, dynamic> preview, List<String> keys, {double fallback = 0}) {
  for (final k in keys) {
    if (preview.containsKey(k) && preview[k] != null) {
      final v = _asDouble(preview[k]);
      return v;
    }
  }
  return fallback;
}

bool _hasAnyKey(Map<String, dynamic> map, List<String> keys) {
  for (final k in keys) {
    if (map.containsKey(k) && map[k] != null) return true;
  }
  return false;
}

DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    // Try ISO8601 first
    DateTime? dt = DateTime.tryParse(v);
    if (dt != null) return dt;
    // Try common Frappe format: 'YYYY-MM-DD HH:MM:SS'
    final s = v.trim();
    if (s.contains(' ') && !s.contains('T')) {
      dt = DateTime.tryParse(s.replaceFirst(' ', 'T'));
      if (dt != null) return dt;
    }
  }
  return null;
}

bool _isUnpaidEffective(Map<String, dynamic> preview) {
  final invStatusStr = (preview['invoice_status']?.toString() ?? '').toLowerCase();
  final outstanding = preview['outstanding'];
  final isOutstanding = (outstanding is num) ? (outstanding > 0.01) : false;
  final flag = preview['is_unpaid_effective'] == true;
  final paidAfterOfd = preview['paid_after_ofd'] == true;
  // Recent payment threshold: if paid within last 30 seconds, still treat as Unpaid for settlement flow
  const recentSecs = 30;
  double? secsAgo;
  for (final k in const [
  'last_payment_seconds',
  'last_payment_seconds_ago',
    'seconds_since_last_payment',
    'age_last_payment_seconds',
  ]) {
    final v = preview[k];
    if (v != null) {
      if (v is num) {
        secsAgo = v.toDouble();
      } else if (v is String) {
        secsAgo = double.tryParse(v);
      }
      if (secsAgo != null) break;
    }
  }
  DateTime? lastPaidAt;
  for (final k in const [
    'last_payment_at',
    'last_payment_on',
    'last_payment_time',
    'last_payment_timestamp',
    'payment_entry_time',
    'payment_entry_created',
    'payment_time',
    'payment_timestamp',
  ]) {
    final ts = _parseDateTime(preview[k]);
    if (ts != null) {
      lastPaidAt = ts;
      break;
    }
  }
  bool recentlyPaid = false;
  if (secsAgo != null) {
    recentlyPaid = secsAgo < recentSecs;
  } else if (lastPaidAt != null) {
    final now = DateTime.now();
    final diff = now.difference(lastPaidAt).inSeconds.abs();
    recentlyPaid = diff < recentSecs;
  }

  // Treat invoices paid after OFD or paid very recently as effectively Unpaid for settlement purposes
  return recentlyPaid || paidAfterOfd || flag || isOutstanding || invStatusStr == 'unpaid' || invStatusStr == 'overdue' || invStatusStr == 'partially paid';
}

({
  bool actionCollect,
  double netSigned,
  double shipping,
  double order,
  bool unpaidEffective,
  bool paidAfterOfd,
  bool recentlyPaid,
  bool isPartnerOrder,
  String? deliveryPartner,
  Color paidColor,
  IconData paidIcon,
})
_computeDisplay(Map<String, dynamic> preview, {double? orderFallback, double? shippingFallback}) {
  // Read order/shipping robustly from multiple potential keys
  const orderKeys = [
    'order_amount', 'order_total', 'order', 'invoice_total', 'grand_total', 'total', 'total_amount', 'amount', 'invoice_amount', 'net_total'
  ];
  const shippingKeys = [
    'shipping_amount', 'shipping', 'shipping_expense', 'shippingExpense', 'shipping_total', 'shipping_cost', 'shipping_charge'
  ];

  final hasOrderInPreview = _hasAnyKey(preview, orderKeys);
  final hasShippingInPreview = _hasAnyKey(preview, shippingKeys);

  double order = _firstNumberFrom(preview, orderKeys, fallback: 0);
  double shipping = _firstNumberFrom(preview, shippingKeys, fallback: 0);

  // If preview lacks these fields, adopt provided fallbacks (e.g., from InvoiceCard or list details)
  if (!hasOrderInPreview && (orderFallback != null)) order = orderFallback;
  if (!hasShippingInPreview && (shippingFallback != null)) shipping = shippingFallback;
  // If preview provided zero/invalid values, prefer a positive fallback
  if ((order <= 0) && (orderFallback != null) && (orderFallback > 0)) order = orderFallback;
  if ((shipping <= 0) && (shippingFallback != null) && (shippingFallback > 0)) shipping = shippingFallback;
  // Prefer backend-provided signed net if available; else fallback to Order - Shipping
  final backendNet = _firstNumberFrom(preview, ['net_amount', 'netAmount', 'net_balance', 'net'], fallback: double.nan);
  final net = backendNet.isNaN ? (order - shipping) : backendNet;

  final actionCollect = net > 0;

  final unpaidEff = _isUnpaidEffective(preview);
  final paidAfterOfd = preview['paid_after_ofd'] == true;
  final paidColor = unpaidEff ? Colors.orange : Colors.green;
  final paidIcon = unpaidEff ? Icons.error_outline : Icons.check_circle_outline;
  bool recentlyPaid = false;

  for (final k in const ['last_payment_seconds', 'last_payment_seconds_ago', 'seconds_since_last_payment', 'age_last_payment_seconds']) {
  if (!preview.containsKey(k)) continue;
    final v = preview[k];
    if (v != null) {
      double? s;
      if (v is num) s = v.toDouble();
      if (v is String) s = double.tryParse(v);
      if (s != null && s < 30) {
        recentlyPaid = true;
      }
      break;
    }
  }

  // Detect partner order
  final isPartnerOrder = preview['is_partner_order'] == true || preview['is_partner_order'] == 1;
  final deliveryPartner = (preview['delivery_partner'] ?? '').toString();

  return (
    actionCollect: actionCollect,
    netSigned: net,
    shipping: shipping,
    order: order,
    unpaidEffective: unpaidEff,
    paidAfterOfd: paidAfterOfd,
    recentlyPaid: recentlyPaid,
    isPartnerOrder: isPartnerOrder,
    deliveryPartner: deliveryPartner.isEmpty ? null : deliveryPartner,
    paidColor: paidColor,
    paidIcon: paidIcon,
  );
}

Widget _netChip(String value, Color color, String label) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    ),
  );
}

Future<bool?> showSettlementConfirmDialog(
  BuildContext context,
  Map<String, dynamic> preview, {
  String? invoice,
  String? territory,
  double? orderFallback,
  double? shippingFallback,
}) async {
  final l10n = AppLocalizations.of(context);
  final d = _computeDisplay(preview, orderFallback: orderFallback, shippingFallback: shippingFallback);
  final absNet = d.netSigned.abs();
  final orderLabel = d.order.toStringAsFixed(2);
  final shipLabel = d.shipping.toStringAsFixed(2);
  final netLabel = absNet.toStringAsFixed(2);
  final title = d.isPartnerOrder
    ? 'Partner Delivery Settlement'
    : (d.actionCollect
      ? l10n.settlementTitleCollectFromCourier
      : (d.netSigned < 0 ? l10n.settlementTitlePayCourier : l10n.settlementTitleCourierSettlement));
  final paidLabel = d.unpaidEffective ? l10n.settlementStatusUnpaid : l10n.settlementStatusPaid;
  final paidNote = d.recentlyPaid
    ? l10n.settlementPaidNoteRecent
    : (d.paidAfterOfd
      ? (d.unpaidEffective
        ? l10n.settlementPaidNoteAfterOfdUnpaid
        : l10n.settlementPaidNoteAfterOfd)
      : '');

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (d.isPartnerOrder) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.handshake, size: 16, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    'Partner: ${d.deliveryPartner ?? ""}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (invoice != null) ...[
            Text(l10n.websocketInvoiceLabel(invoice)),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(d.paidIcon, size: 18, color: d.paidColor),
              const SizedBox(width: 6),
              Text(l10n.settlementInvoiceStatus(paidLabel, paidNote),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: d.paidColor)),
            ],
          ),
          const SizedBox(height: 8),
          if (d.isPartnerOrder) ...[
            // Partner orders: show full amount to collect (no shipping deduction)
            if (d.unpaidEffective) ...[
              const Text('Collect full order amount from courier:'),
              const SizedBox(height: 6),
              _netChip(netLabel, Colors.indigo, 'Collect (Full Amount)'),
            ] else ...[
              const Text('Online-paid — no cash exchange with courier'),
              const SizedBox(height: 6),
              _netChip('0.00', Colors.green, 'No Cash Exchange'),
            ],
          ] else ...[
            if (d.actionCollect) ...[
              Text(l10n.settlementCollectFormula),
              const SizedBox(height: 6),
              _netChip(netLabel, Colors.indigo, l10n.settlementNetToCollect),
            ] else if (d.netSigned < 0) ...[
              Text(l10n.settlementPayFormula),
              const SizedBox(height: 6),
              _netChip(netLabel, Colors.deepOrange, l10n.settlementPayAmount),
            ] else ...[
              Text(l10n.settlementNothingToSettle),
            ],
          ],
          const SizedBox(height: 12),
          if (d.isPartnerOrder) ...[
            Row(children: [const Icon(Icons.receipt_long, size: 18, color: Colors.teal), const SizedBox(width: 6), Text('Order: $orderLabel')]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.local_shipping, size: 18, color: Colors.grey), const SizedBox(width: 6), Text('Partner fee (tracked): $shipLabel', style: const TextStyle(color: Colors.grey, fontSize: 12))]),
          ] else ...[
            Row(children: [const Icon(Icons.receipt_long, size: 18, color: Colors.teal), const SizedBox(width: 6), Text(l10n.settlementOrderLabel(orderLabel))]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.local_shipping, size: 18, color: Colors.deepOrange), const SizedBox(width: 6), Text(l10n.settlementShippingLabel(shipLabel))]),
          ],
          if (territory != null && territory.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.map, size: 18, color: Colors.blueGrey), const SizedBox(width: 6), Text(l10n.settlementTerritoryLabel(territory))]),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.commonConfirm)),
      ],
    ),
  );
}

Future<void> showSettlementInfoDialog(
  BuildContext context,
  Map<String, dynamic> preview, {
  String? invoice,
  String? territory,
  double? orderFallback,
  double? shippingFallback,
}) async {
  final l10n = AppLocalizations.of(context);
  final d = _computeDisplay(preview, orderFallback: orderFallback, shippingFallback: shippingFallback);
  final absNet = d.netSigned.abs();
  final orderLabel = d.order.toStringAsFixed(2);
  final shipLabel = d.shipping.toStringAsFixed(2);
  final netLabel = absNet.toStringAsFixed(2);

  final isPartner = d.isPartnerOrder;
  final partnerName = d.deliveryPartner ?? '';

  final title = isPartner
    ? 'Partner Settlement Info'
    : d.actionCollect
      ? l10n.settlementTitleCollectFromCourier
      : (d.netSigned < 0 ? l10n.settlementTitlePayCourier : l10n.settlementTitleCourierSettlement);
  final paidLabel = d.unpaidEffective ? l10n.settlementStatusUnpaid : l10n.settlementStatusPaid;
  final paidNote = d.recentlyPaid
    ? l10n.settlementPaidNoteRecent
    : (d.paidAfterOfd
      ? (d.unpaidEffective
        ? l10n.settlementPaidNoteAfterOfdUnpaid
        : l10n.settlementPaidNoteAfterOfd)
      : '');

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPartner && partnerName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.handshake, size: 16, color: Colors.deepPurple.shade400),
                  const SizedBox(width: 6),
                  Text('Partner: $partnerName',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (invoice != null) ...[
            Text(l10n.websocketInvoiceLabel(invoice)),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Icon(d.paidIcon, size: 18, color: d.paidColor),
              const SizedBox(width: 6),
              Text(l10n.settlementInvoiceStatus(paidLabel, paidNote),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: d.paidColor)),
            ],
          ),
          const SizedBox(height: 8),
          if (isPartner) ...[
            // Partner order: show full order amount as the settlement amount
            if (d.unpaidEffective) ...[
              Text('Collected full order amount from courier'),
              const SizedBox(height: 6),
              _netChip(orderLabel, Colors.indigo, 'Full amount'),
            ] else ...[
              Text('Online paid — no cash exchange'),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.local_shipping, size: 18, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text('Partner fee (tracked): $shipLabel',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
          ] else ...[
            if (d.actionCollect) ...[
              Text(l10n.settlementCollectFormula),
              const SizedBox(height: 6),
              _netChip(netLabel, Colors.indigo, l10n.settlementNetToCollect),
            ] else if (d.netSigned < 0) ...[
              Text(l10n.settlementPayFormula),
              const SizedBox(height: 6),
              _netChip(netLabel, Colors.deepOrange, l10n.settlementPayAmount),
            ] else ...[
              Text(l10n.settlementNothingToSettle),
            ],
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.receipt_long, size: 18, color: Colors.teal), const SizedBox(width: 6), Text(l10n.settlementOrderLabel(orderLabel))]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.local_shipping, size: 18, color: Colors.deepOrange), const SizedBox(width: 6), Text(l10n.settlementShippingLabel(shipLabel))]),
          ],
          if (territory != null && territory.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.map, size: 18, color: Colors.blueGrey), const SizedBox(width: 6), Text(l10n.settlementTerritoryLabel(territory))]),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.commonClose)),
      ],
    ),
  );
}

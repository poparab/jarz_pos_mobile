import '../../../../core/utils/order_display_id.dart';
import 'escalated_payment_order.dart';

/// An unpaid online (InstaPay / Mobile Wallet) order that is already Out for
/// Delivery and awaiting the manager's bank-transfer confirmation.
///
/// Mirrors the row shape returned by
/// `jarz_pos.api.couriers.list_unconfirmed_online_orders`.
class UnconfirmedOnlineOrder {
  final String invoice;
  final int? wooOrderId;
  final String customer;
  final String customerName;
  final double amount;
  final String? expectedReference;
  final String? paymentMethod;
  final String? courierPartyType;
  final String? courierParty;
  final String? courierName;
  final String? unconfirmedSince;
  final int ageSeconds;
  final String? receiptName;
  final String? receiptStatus;
  final String? receiptImageUrl;
  final bool canConfirm;

  const UnconfirmedOnlineOrder({
    required this.invoice,
    this.wooOrderId,
    required this.customer,
    required this.customerName,
    required this.amount,
    this.expectedReference,
    this.paymentMethod,
    this.courierPartyType,
    this.courierParty,
    this.courierName,
    this.unconfirmedSince,
    this.ageSeconds = 0,
    this.receiptName,
    this.receiptStatus,
    this.receiptImageUrl,
    this.canConfirm = false,
  });

  factory UnconfirmedOnlineOrder.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0.0;
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    String? toStr(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return UnconfirmedOnlineOrder(
      invoice: (json['invoice'] ?? json['name'] ?? '').toString(),
      wooOrderId: normalizeWooOrderId(json['woo_order_id']),
      customer: (json['customer'] ?? '').toString(),
      customerName:
          (json['customer_name'] ?? json['customer'] ?? '').toString(),
      amount: toDouble(json['amount']),
      expectedReference: toStr(json['expected_reference']),
      paymentMethod: toStr(json['payment_method']),
      courierPartyType: toStr(json['courier_party_type']),
      courierParty: toStr(json['courier_party']),
      courierName: toStr(json['courier_name']),
      unconfirmedSince: toStr(json['unconfirmed_since']),
      ageSeconds: toInt(json['age_seconds']),
      receiptName: toStr(json['receipt_name']),
      receiptStatus: toStr(json['receipt_status']),
      receiptImageUrl: toStr(json['receipt_image_url']),
      canConfirm: [1, true, '1', 'true', 'True'].contains(json['can_confirm']),
    );
  }

  /// Adapts an [EscalatedPaymentOrder] into the shape the reconciliation
  /// screen's confirm / convert-to-cash actions already understand, so an
  /// escalated row gets the exact same actions as a plain unconfirmed one
  /// without duplicating that logic.
  ///
  /// Courier fields are unknown at this point (the escalation feed does not
  /// carry them) — `canConfirm: true` is safe because the escalation is a
  /// stricter superset of "unconfirmed", so if the plain list would allow
  /// confirming it, so does this one; a courier is asked for on demand when
  /// converting to cash, same as any unconfirmed order with none assigned.
  factory UnconfirmedOnlineOrder.forEscalation(EscalatedPaymentOrder order) {
    return UnconfirmedOnlineOrder(
      invoice: order.invoice,
      wooOrderId: order.wooOrderId,
      customer: order.customer,
      customerName: order.customerName,
      amount: order.amount,
      paymentMethod: order.paymentMethod,
      unconfirmedSince: order.outForDeliverySince,
      ageSeconds: order.outForDeliverySeconds,
      canConfirm: true,
    );
  }

  /// True when a receipt screenshot has been attached to this order.
  bool get hasReceiptImage => (receiptImageUrl ?? '').trim().isNotEmpty;

  /// What the reconciliation screens label this order with.
  String get displayId => orderDisplayId(invoice, wooOrderId: wooOrderId);
}

import '../../../../core/utils/order_display_id.dart';

/// An unpaid online (InstaPay / Mobile Wallet) order that has been Out for
/// Delivery past the configured escalation threshold.
///
/// Surfaced by the hourly escalation job — the same job that writes a
/// Notification Log per manager that nobody reads — via
/// `jarz_pos.api.escalations.list_unconfirmed_online_payment_escalations`.
/// This is money that already left the building without the payment being
/// confirmed, so every row here is a strict superset of the risk carried by a
/// plain [UnconfirmedOnlineOrder]: it is unconfirmed AND overdue.
class EscalatedPaymentOrder {
  final String invoice;
  final int? wooOrderId;
  final String customer;
  final String customerName;
  final String? branch;
  final double amount;
  final String? paymentMethod;
  final String? outForDeliverySince;
  final int outForDeliverySeconds;
  final int thresholdHours;

  /// Whether the hourly job has already written a Notification Log for this
  /// order. Informational only — never used to hide a row: an order the job
  /// already alerted on is exactly as much at risk as one it has not gotten
  /// to yet.
  final bool alreadyAlerted;

  const EscalatedPaymentOrder({
    required this.invoice,
    this.wooOrderId,
    required this.customer,
    required this.customerName,
    this.branch,
    required this.amount,
    this.paymentMethod,
    this.outForDeliverySince,
    this.outForDeliverySeconds = 0,
    this.thresholdHours = 0,
    this.alreadyAlerted = false,
  });

  factory EscalatedPaymentOrder.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0.0;
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    String? toStr(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return EscalatedPaymentOrder(
      invoice: (json['invoice'] ?? json['name'] ?? '').toString(),
      wooOrderId: normalizeWooOrderId(json['woo_order_id']),
      customer: (json['customer'] ?? '').toString(),
      customerName:
          (json['customer_name'] ?? json['customer'] ?? '').toString(),
      branch: toStr(json['branch']),
      amount: toDouble(json['amount']),
      paymentMethod: toStr(json['payment_method']),
      outForDeliverySince: toStr(json['out_for_delivery_since']),
      outForDeliverySeconds: toInt(json['out_for_delivery_seconds']),
      thresholdHours: toInt(json['threshold_hours']),
      alreadyAlerted:
          [1, true, '1', 'true', 'True'].contains(json['already_alerted']),
    );
  }

  /// What the reconciliation screen labels this order with.
  String get displayId => orderDisplayId(invoice, wooOrderId: wooOrderId);
}

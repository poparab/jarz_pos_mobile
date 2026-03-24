/// Models for the Delivery Trip feature.

class DeliveryTrip {
  final String name;
  final String tripDate;
  final String courierPartyType;
  final String courierParty;
  final String courierDisplayName;
  final String status;
  final bool isDoubleShipping;
  final String? doubleShippingTerritory;
  final int totalOrders;
  final double totalAmount;
  final double totalShippingExpense;
  final String? notes;
  final List<TripInvoice> invoices;

  DeliveryTrip({
    required this.name,
    required this.tripDate,
    required this.courierPartyType,
    required this.courierParty,
    required this.courierDisplayName,
    required this.status,
    this.isDoubleShipping = false,
    this.doubleShippingTerritory,
    this.totalOrders = 0,
    this.totalAmount = 0,
    this.totalShippingExpense = 0,
    this.notes,
    this.invoices = const [],
  });

  factory DeliveryTrip.fromJson(Map<String, dynamic> json) {
    final invoicesRaw = json['invoices'];
    final invoicesList = invoicesRaw is List
        ? invoicesRaw
            .whereType<Map>()
            .map((e) => TripInvoice.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <TripInvoice>[];

    return DeliveryTrip(
      name: (json['name'] ?? '').toString(),
      tripDate: (json['trip_date'] ?? '').toString(),
      courierPartyType: (json['courier_party_type'] ?? '').toString(),
      courierParty: (json['courier_party'] ?? '').toString(),
      courierDisplayName: (json['courier_display_name'] ?? '').toString(),
      status: (json['status'] ?? 'Created').toString(),
      isDoubleShipping: [1, true, '1', 'true'].contains(json['is_double_shipping']),
      doubleShippingTerritory: json['double_shipping_territory']?.toString(),
      totalOrders: _toInt(json['total_orders']),
      totalAmount: _toDouble(json['total_amount']),
      totalShippingExpense: _toDouble(json['total_shipping_expense']),
      notes: json['notes']?.toString(),
      invoices: invoicesList,
    );
  }

  bool get isCreated => status == 'Created';
  bool get isOutForDelivery => status == 'Out for Delivery';
  bool get isCompleted => status == 'Completed';
}

class TripInvoice {
  final String invoice;
  final String customerName;
  final String territory;
  final String? subTerritory;
  final double grandTotal;
  final double shippingExpense;
  final String invoiceStatus;

  TripInvoice({
    required this.invoice,
    required this.customerName,
    required this.territory,
    this.subTerritory,
    this.grandTotal = 0,
    this.shippingExpense = 0,
    this.invoiceStatus = '',
  });

  factory TripInvoice.fromJson(Map<String, dynamic> json) {
    return TripInvoice(
      invoice: (json['invoice'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      territory: (json['territory'] ?? '').toString(),
      subTerritory: json['sub_territory']?.toString(),
      grandTotal: _toDouble(json['grand_total']),
      shippingExpense: _toDouble(json['shipping_expense']),
      invoiceStatus: (json['invoice_status'] ?? '').toString(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value == null) return 0;
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

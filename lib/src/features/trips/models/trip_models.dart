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
  final String? territoryDisplay;
  final String? subTerritoryDisplay;
  final double grandTotal;
  final double shippingExpense;
  final String invoiceStatus;
  final double outstandingAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String address;
  final String customerPhone;
  final List<TripInvoiceItem> items;
  final String deliveryDate;
  final String deliveryTimeFrom;
  final dynamic deliveryDuration;
  final String deliverySlotLabel;

  TripInvoice({
    required this.invoice,
    required this.customerName,
    required this.territory,
    this.subTerritory,
    this.territoryDisplay,
    this.subTerritoryDisplay,
    this.grandTotal = 0,
    this.shippingExpense = 0,
    this.invoiceStatus = '',
    this.outstandingAmount = 0,
    this.paymentStatus = '',
    this.paymentMethod = '',
    this.address = '',
    this.customerPhone = '',
    this.items = const [],
    this.deliveryDate = '',
    this.deliveryTimeFrom = '',
    this.deliveryDuration,
    this.deliverySlotLabel = '',
  });

  bool get isPaid => outstandingAmount <= 0.01;

  factory TripInvoice.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final itemsList = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) => TripInvoiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <TripInvoiceItem>[];

    return TripInvoice(
      invoice: (json['invoice'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      territory: (json['territory'] ?? '').toString(),
      subTerritory: json['sub_territory']?.toString(),
      territoryDisplay: json['territory_display']?.toString(),
      subTerritoryDisplay: json['sub_territory_display']?.toString(),
      grandTotal: _toDouble(json['grand_total']),
      shippingExpense: _toDouble(json['shipping_expense']),
      invoiceStatus: (json['invoice_status'] ?? '').toString(),
      outstandingAmount: _toDouble(json['outstanding_amount']),
      paymentStatus: (json['payment_status'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      customerPhone: (json['customer_phone'] ?? '').toString(),
      items: itemsList,
      deliveryDate: (json['delivery_date'] ?? '').toString(),
      deliveryTimeFrom: (json['delivery_time_from'] ?? '').toString(),
      deliveryDuration: json['delivery_duration'],
      deliverySlotLabel: (json['delivery_slot_label'] ?? '').toString(),
    );
  }
}

class TripInvoiceItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;

  TripInvoiceItem({
    required this.itemCode,
    required this.itemName,
    this.qty = 0,
    this.rate = 0,
    this.amount = 0,
  });

  factory TripInvoiceItem.fromJson(Map<String, dynamic> json) {
    return TripInvoiceItem(
      itemCode: (json['item_code'] ?? '').toString(),
      itemName: (json['item_name'] ?? '').toString(),
      qty: _toDouble(json['qty']),
      rate: _toDouble(json['rate']),
      amount: _toDouble(json['amount']),
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

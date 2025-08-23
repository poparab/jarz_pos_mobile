class KanbanColumn {
  final String id;
  final String name;
  final String color;

  KanbanColumn({required this.id, required this.name, required this.color});

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    return KanbanColumn(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#F5F5F5',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color};
  }
}

class InvoiceCard {
  final String id;
  final String invoiceIdShort;
  final String customerName;
  final String customer;
  final String territory;
  final String? requiredDeliveryDate;
  final String status;
  final String postingDate;
  final double grandTotal;
  final double netTotal;
  final double totalTaxesAndCharges;
  final String fullAddress;
  final List<InvoiceItem> items;

  InvoiceCard({
    required this.id,
    required this.invoiceIdShort,
    required this.customerName,
    required this.customer,
    required this.territory,
    this.requiredDeliveryDate,
    required this.status,
    required this.postingDate,
    required this.grandTotal,
    required this.netTotal,
    required this.totalTaxesAndCharges,
    required this.fullAddress,
    required this.items,
  });

  factory InvoiceCard.fromJson(Map<String, dynamic> json) {
    return InvoiceCard(
      id: json['name'] ?? '',
      invoiceIdShort: json['invoice_id_short'] ?? '',
      customerName: json['customer_name'] ?? '',
      customer: json['customer'] ?? '',
      territory: json['territory'] ?? '',
      requiredDeliveryDate: json['required_delivery_date'],
      status: json['status'] ?? '',
      postingDate: json['posting_date'] ?? '',
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      netTotal: (json['net_total'] ?? 0).toDouble(),
      totalTaxesAndCharges: (json['total_taxes_and_charges'] ?? 0).toDouble(),
      fullAddress: json['full_address'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'invoice_id_short': invoiceIdShort,
      'customer_name': customerName,
      'customer': customer,
      'territory': territory,
      'required_delivery_date': requiredDeliveryDate,
      'status': status,
      'posting_date': postingDate,
      'grand_total': grandTotal,
      'net_total': netTotal,
      'total_taxes_and_charges': totalTaxesAndCharges,
      'full_address': fullAddress,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  InvoiceCard copyWith({
    String? id,
    String? invoiceIdShort,
    String? customerName,
    String? customer,
    String? territory,
    String? requiredDeliveryDate,
    String? status,
    String? postingDate,
    double? grandTotal,
    double? netTotal,
    double? totalTaxesAndCharges,
    String? fullAddress,
    List<InvoiceItem>? items,
  }) {
    return InvoiceCard(
      id: id ?? this.id,
      invoiceIdShort: invoiceIdShort ?? this.invoiceIdShort,
      customerName: customerName ?? this.customerName,
      customer: customer ?? this.customer,
      territory: territory ?? this.territory,
      requiredDeliveryDate: requiredDeliveryDate ?? this.requiredDeliveryDate,
      status: status ?? this.status,
      postingDate: postingDate ?? this.postingDate,
      grandTotal: grandTotal ?? this.grandTotal,
      netTotal: netTotal ?? this.netTotal,
      totalTaxesAndCharges: totalTaxesAndCharges ?? this.totalTaxesAndCharges,
      fullAddress: fullAddress ?? this.fullAddress,
      items: items ?? this.items,
    );
  }

  // UI compatibility getters
  String get name => id;
  String get columnId => status.toLowerCase().replaceAll(' ', '_');
  String get date => postingDate;
  double get total => grandTotal;
  double get taxAmount => totalTaxesAndCharges;
  String get address => fullAddress;
}

class InvoiceItem {
  final String itemCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;

  InvoiceItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'qty': qty,
      'rate': rate,
      'amount': amount,
    };
  }

  // UI compatibility getter
  double get quantity => qty;
}

class KanbanFilters {
  final String searchTerm;
  final String? customer;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? amountFrom;
  final double? amountTo;

  const KanbanFilters({
    this.searchTerm = '',
    this.customer,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.amountFrom,
    this.amountTo,
  });

  factory KanbanFilters.fromJson(Map<String, dynamic> json) {
    return KanbanFilters(
      searchTerm: json['searchTerm'] ?? '',
      customer: json['customer'],
      status: json['status'],
      dateFrom: json['dateFrom'] != null
          ? DateTime.parse(json['dateFrom'])
          : null,
      dateTo: json['dateTo'] != null ? DateTime.parse(json['dateTo']) : null,
      amountFrom: json['amountFrom']?.toDouble(),
      amountTo: json['amountTo']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchTerm': searchTerm,
      'customer': customer,
      'status': status,
      'dateFrom': dateFrom?.toIso8601String(),
      'dateTo': dateTo?.toIso8601String(),
      'amountFrom': amountFrom,
      'amountTo': amountTo,
    };
  }

  KanbanFilters copyWith({
    String? searchTerm,
    String? customer,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? amountFrom,
    double? amountTo,
  }) {
    return KanbanFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      customer: customer ?? this.customer,
      status: status ?? this.status,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      amountFrom: amountFrom ?? this.amountFrom,
      amountTo: amountTo ?? this.amountTo,
    );
  }

  bool get hasFilters =>
      searchTerm.isNotEmpty ||
      customer != null ||
      status != null ||
      dateFrom != null ||
      dateTo != null ||
      amountFrom != null ||
      amountTo != null;
}

class CustomerOption {
  final String customer;
  final String customerName;

  CustomerOption({required this.customer, required this.customerName});

  factory CustomerOption.fromJson(Map<String, dynamic> json) {
    return CustomerOption(
      customer: json['customer'] ?? '',
      customerName: json['customer_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'customer': customer, 'customer_name': customerName};
  }
}

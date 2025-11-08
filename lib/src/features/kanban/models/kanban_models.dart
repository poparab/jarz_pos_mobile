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
  // Legacy single datetime (kept for backward compatibility when present)
  final String? requiredDeliveryDate;
  // New delivery slot fields from backend
  final String? deliveryDate; // e.g. '2025-09-09'
  final String? deliveryTimeFrom; // e.g. '14:30:00'
  final dynamic deliveryDuration; // seconds/int or 'HH:MM:SS' string
  final String? deliverySlotLabel; // optional preformatted label from backend
  final String status;
  final String postingDate;
  final double grandTotal;
  final double netTotal;
  final double totalTaxesAndCharges;
  final String fullAddress;
  final List<InvoiceItem> items;
  final double shippingIncome; // new
  final double shippingExpense; // new
  final String? customerPhone; // optional phone (may come from detailed fetch)
  final String? docStatus; // ERPNext document status separate from kanban state
  final String? courier; // new: assigned courier
  final String? settlementMode; // legacy compatibility (now: pay_now only)
  final String? courierPartyType; // Employee/Supplier
  final String? courierParty; // party id
  final bool hasUnsettledCourierTxn; // new flag from backend
  final String? salesPartner; // optional sales partner on the invoice
  final bool isPickup; // new: pickup orders
  final String? acceptanceStatus; // new: Pending/Accepted status for order acceptance
  final bool? requiresAcceptanceFlag; // optional flag directly from backend
  final String? paymentMethod; // new: Cash, Instapay, or Mobile Wallet
  final String? posProfile; // POS Profile for payment receipt tracking

  InvoiceCard({
    required this.id,
    required this.invoiceIdShort,
    required this.customerName,
    required this.customer,
    required this.territory,
    this.requiredDeliveryDate,
    this.deliveryDate,
    this.deliveryTimeFrom,
    this.deliveryDuration,
    this.deliverySlotLabel,
    required this.status,
    required this.postingDate,
    required this.grandTotal,
    required this.netTotal,
    required this.totalTaxesAndCharges,
    required this.fullAddress,
    required this.items,
    this.shippingIncome = 0.0,
    this.shippingExpense = 0.0,
  this.customerPhone,
    this.docStatus,
    this.courier,
    this.settlementMode,
  this.courierPartyType,
  this.courierParty,
  this.hasUnsettledCourierTxn = false,
  this.salesPartner,
  this.isPickup = false,
  this.acceptanceStatus,
  this.requiresAcceptanceFlag,
  this.paymentMethod,
  this.posProfile,
  });

  factory InvoiceCard.fromJson(Map<String, dynamic> json) {
    bool? requiresAcceptanceFlag;
    final rawRequiresAcceptance = json['requires_acceptance'];
    if (rawRequiresAcceptance is bool) {
      requiresAcceptanceFlag = rawRequiresAcceptance;
    } else if (rawRequiresAcceptance is num) {
      requiresAcceptanceFlag = rawRequiresAcceptance != 0;
    } else if (rawRequiresAcceptance is String) {
      final normalized = rawRequiresAcceptance.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        requiresAcceptanceFlag = ['1', 'true', 'yes', 'y'].contains(normalized);
      }
    }

    return InvoiceCard(
      id: json['name'] ?? '',
      invoiceIdShort: json['invoice_id_short'] ?? '',
      customerName: json['customer_name'] ?? '',
      customer: json['customer'] ?? '',
      territory: json['territory'] ?? '',
      requiredDeliveryDate: json['required_delivery_date'],
      deliveryDate: json['delivery_date']?.toString(),
      deliveryTimeFrom: json['delivery_time_from']?.toString(),
      deliveryDuration: json['delivery_duration'],
      deliverySlotLabel: json['delivery_slot_label']?.toString(),
      status: json['status'] ?? '',
      postingDate: json['posting_date'] ?? '',
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      netTotal: (json['net_total'] ?? 0).toDouble(),
      totalTaxesAndCharges: (json['total_taxes_and_charges'] ?? 0).toDouble(),
      fullAddress: json['full_address'] ?? '',
      items: (json['items'] as List? ?? []).map((item) => InvoiceItem.fromJson(item)).toList(),
      shippingIncome: (json['shipping_income'] ?? 0).toDouble(),
      shippingExpense: (json['shipping_expense'] ?? 0).toDouble(),
  customerPhone: (json['customer_phone'] ?? json['phone'] ?? json['customerPhone'])?.toString(),
      docStatus: json['doc_status'],
      courier: json['courier'],
      settlementMode: json['settlement_mode'] ?? json['settlement'],
  courierPartyType: json['party_type'] ?? json['courier_party_type'],
  courierParty: json['party'] ?? json['courier_party'],
  // Backend may return 0/1 int, bool, or string variants; normalize to bool
  hasUnsettledCourierTxn: [1, true, '1', 'true', 'True']
      .contains(json['has_unsettled_courier_txn']),
  salesPartner: (json['sales_partner'] ?? json['salesPartner'] ?? json['partner'])?.toString(),
      isPickup: [1, true, '1', 'true', 'True'].contains(json['is_pickup']) ||
          ((json['remarks'] ?? '').toString().toLowerCase().contains('[pickup]')),
      acceptanceStatus: (json['acceptance_status'] ?? json['custom_acceptance_status'])?.toString(),
      requiresAcceptanceFlag: requiresAcceptanceFlag,
      paymentMethod: (json['payment_method'] ?? json['custom_payment_method'])?.toString(),
      posProfile: (json['pos_profile'] ?? json['custom_kanban_profile'])?.toString(),
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
      'delivery_date': deliveryDate,
      'delivery_time_from': deliveryTimeFrom,
      'delivery_duration': deliveryDuration,
      'delivery_slot_label': deliverySlotLabel,
      'status': status,
      'posting_date': postingDate,
      'grand_total': grandTotal,
      'net_total': netTotal,
      'total_taxes_and_charges': totalTaxesAndCharges,
      'full_address': fullAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_income': shippingIncome,
      'shipping_expense': shippingExpense,
  'customer_phone': customerPhone,
      'courier': courier,
      'settlement_mode': settlementMode,
  'party_type': courierPartyType,
  'party': courierParty,
  'has_unsettled_courier_txn': hasUnsettledCourierTxn,
  'sales_partner': salesPartner,
  'is_pickup': isPickup,
  'acceptance_status': acceptanceStatus,
  'requires_acceptance': requiresAcceptanceFlag,
  'payment_method': paymentMethod,
  'pos_profile': posProfile,
    };
  }

  InvoiceCard copyWith({
    String? id,
    String? invoiceIdShort,
    String? customerName,
    String? customer,
    String? territory,
    String? requiredDeliveryDate,
    String? deliveryDate,
    String? deliveryTimeFrom,
    dynamic deliveryDuration,
    String? deliverySlotLabel,
    String? status,
    String? postingDate,
    double? grandTotal,
    double? netTotal,
    double? totalTaxesAndCharges,
    String? fullAddress,
    List<InvoiceItem>? items,
    double? shippingIncome,
    double? shippingExpense,
  String? customerPhone,
    String? docStatus,
    String? courier,
    String? settlementMode,
  String? courierPartyType,
  String? courierParty,
  bool? hasUnsettledCourierTxn,
  String? salesPartner,
  bool? isPickup,
  String? acceptanceStatus,
  bool? requiresAcceptanceFlag,
  String? paymentMethod,
  String? posProfile,
  }) {
    return InvoiceCard(
      id: id ?? this.id,
      invoiceIdShort: invoiceIdShort ?? this.invoiceIdShort,
      customerName: customerName ?? this.customerName,
      customer: customer ?? this.customer,
      territory: territory ?? this.territory,
      requiredDeliveryDate: requiredDeliveryDate ?? this.requiredDeliveryDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTimeFrom: deliveryTimeFrom ?? this.deliveryTimeFrom,
      deliveryDuration: deliveryDuration ?? this.deliveryDuration,
      deliverySlotLabel: deliverySlotLabel ?? this.deliverySlotLabel,
      status: status ?? this.status,
      postingDate: postingDate ?? this.postingDate,
      grandTotal: grandTotal ?? this.grandTotal,
      netTotal: netTotal ?? this.netTotal,
      totalTaxesAndCharges: totalTaxesAndCharges ?? this.totalTaxesAndCharges,
      fullAddress: fullAddress ?? this.fullAddress,
      items: items ?? this.items,
      shippingIncome: shippingIncome ?? this.shippingIncome,
      shippingExpense: shippingExpense ?? this.shippingExpense,
  customerPhone: customerPhone ?? this.customerPhone,
      docStatus: docStatus ?? this.docStatus,
      courier: courier ?? this.courier,
      settlementMode: settlementMode ?? this.settlementMode,
  courierPartyType: courierPartyType ?? this.courierPartyType,
  courierParty: courierParty ?? this.courierParty,
  hasUnsettledCourierTxn: hasUnsettledCourierTxn ?? this.hasUnsettledCourierTxn,
  salesPartner: salesPartner ?? this.salesPartner,
  isPickup: isPickup ?? this.isPickup,
  acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
  requiresAcceptanceFlag: requiresAcceptanceFlag ?? this.requiresAcceptanceFlag,
  paymentMethod: paymentMethod ?? this.paymentMethod,
  posProfile: posProfile ?? this.posProfile,
    );
  }

  // New getter for checking if invoice requires acceptance
  bool get requiresAcceptance {
    if (requiresAcceptanceFlag != null) {
      return requiresAcceptanceFlag!;
    }
    final status = (acceptanceStatus ?? '').toLowerCase();
    return status == 'pending' || status == '';
  }
  
  bool get isAccepted => (acceptanceStatus ?? '').toLowerCase() == 'accepted';

  // UI compatibility getters
  String get name => id;
  String get columnId => status.toLowerCase().replaceAll(' ', '_');
  String get date => postingDate;
  double get total => grandTotal;
  double get taxAmount => totalTaxesAndCharges;
  double get shippingIncomeDisplay => shippingIncome; // new helper
  double get shippingExpenseDisplay => shippingExpense; // new helper
  String get address => fullAddress;
  String get effectiveStatus => docStatus ?? status; // prefer real doc status
  int get itemsCount => items.length;
  String? get phone => customerPhone; // backward compatible alias if other code expects phone
  bool get pickup => isPickup;

  // Derived delivery helpers
  DateTime? get deliveryStartDateTime {
    try {
      if ((deliveryDate ?? '').isEmpty || (deliveryTimeFrom ?? '').isEmpty) return null;
      final date = DateTime.tryParse(deliveryDate!);
      if (date == null) return null;
      // Time could be 'HH:mm' or 'HH:mm:ss'
      final parts = deliveryTimeFrom!.split(":");
      final hh = int.parse(parts[0]);
      final mm = parts.length > 1 ? int.parse(parts[1]) : 0;
      final ss = parts.length > 2 ? int.parse(parts[2]) : 0;
      return DateTime(date.year, date.month, date.day, hh, mm, ss);
    } catch (_) {
      return null;
    }
  }

  Duration? get deliveryDurationParsed {
    try {
      if (deliveryDuration == null) return null;
      if (deliveryDuration is num) {
        final seconds = (deliveryDuration as num).toInt();
        return Duration(seconds: seconds);
      }
      final s = deliveryDuration.toString();
      if (s.contains(':')) {
        final p = s.split(':');
        final hh = int.parse(p[0]);
        final mm = p.length > 1 ? int.parse(p[1]) : 0;
        final ss = p.length > 2 ? int.parse(p[2]) : 0;
        return Duration(hours: hh, minutes: mm, seconds: ss);
      }
      final seconds = int.tryParse(s);
      if (seconds != null) return Duration(seconds: seconds);
      return null;
    } catch (_) {
      return null;
    }
  }

  String get deliveryDateTimeLabel {
    // Prefer preformatted label from backend
    if ((deliverySlotLabel ?? '').trim().isNotEmpty) return deliverySlotLabel!.trim();
    final start = deliveryStartDateTime;
    if (start == null) return '';
    final d = start;
    String dateStr;
    {
      final today = DateTime.now();
      final dt = DateTime(d.year, d.month, d.day);
      final t0 = DateTime(today.year, today.month, today.day);
      final diff = dt.difference(t0).inDays;
      if (diff == 0) {
        dateStr = 'Today';
      } else if (diff == -1) {
        dateStr = 'Yesterday';
      } else if (diff == 1) {
        dateStr = 'Tomorrow';
      }
      else {
        dateStr = "${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
      }
    }
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final dur = deliveryDurationParsed;
    if (dur != null && dur.inMinutes > 0) {
      final end = d.add(dur);
      final eh = end.hour.toString().padLeft(2, '0');
      final em = end.minute.toString().padLeft(2, '0');
      return "$dateStr $hh:$mm–$eh:$em";
    }
    return "$dateStr $hh:$mm";
  }

  String get postingDateHumanized {
    try {
      final p = DateTime.tryParse(postingDate);
      if (p == null) return postingDate;
      final today = DateTime.now();
      final pd = DateTime(p.year, p.month, p.day);
      final t0 = DateTime(today.year, today.month, today.day);
      final diff = pd.difference(t0).inDays;
      if (diff == 0) {
        return 'Today';
      }
      if (diff == -1) {
        return 'Yesterday';
      }
      if (diff == 1) {
        return 'Tomorrow';
      }
      return postingDate;
    } catch (_) {
      return postingDate;
    }
  }
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

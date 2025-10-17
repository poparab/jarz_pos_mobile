import 'dart:convert';

class InvoiceAlertItem {
  final String? itemCode;
  final String? itemName;
  final double quantity;

  const InvoiceAlertItem({
    this.itemCode,
    this.itemName,
    required this.quantity,
  });

  factory InvoiceAlertItem.fromMap(Map<String, dynamic> map) {
    return InvoiceAlertItem(
      itemCode: map['item_code']?.toString(),
      itemName: map['item_name']?.toString(),
      quantity: _parseDouble(map['qty']) ?? 0,
    );
  }
}

class InvoiceAlert {
  final String invoiceId;
  final String? customerName;
  final String posProfile;
  final double grandTotal;
  final double netTotal;
  final String? salesInvoiceState;
  final String acceptanceStatus;
  final bool requiresAcceptance;
  final String? deliveryDate;
  final String? deliveryTime;
  final String? itemSummary;
  final List<InvoiceAlertItem> items;
  final DateTime? timestamp;
  final Map<String, dynamic> raw;

  const InvoiceAlert({
    required this.invoiceId,
    required this.customerName,
    required this.posProfile,
    required this.grandTotal,
    required this.netTotal,
    required this.salesInvoiceState,
    required this.acceptanceStatus,
    required this.requiresAcceptance,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.itemSummary,
    required this.items,
    required this.timestamp,
    required this.raw,
  });

  bool get isAccepted => acceptanceStatus.toLowerCase() == 'accepted';

  String get displayTotal => grandTotal.toStringAsFixed(2);

  static InvoiceAlert fromDynamic(Map<String, dynamic> payload) {
    final raw = Map<String, dynamic>.from(payload);
    final invoiceId =
        raw['invoice_id']?.toString() ?? raw['name']?.toString() ?? '';
    final posProfile = raw['pos_profile']?.toString() ?? '';
    final acceptance =
        raw['acceptance_status']?.toString() ??
        raw['custom_acceptance_status']?.toString() ??
        'Pending';
    bool requires = _parseBool(raw['requires_acceptance']);
    if (raw['requires_acceptance'] == null) {
      requires = acceptance.toLowerCase() != 'accepted';
    }
    final timestamp = _parseDate(raw['timestamp']);
    final items = _parseItems(raw['items']);

    return InvoiceAlert(
      invoiceId: invoiceId,
      customerName:
          _optionalString(raw['customer_name']) ??
          _optionalString(raw['customer']),
      posProfile: posProfile,
      grandTotal: _parseDouble(raw['grand_total']) ?? 0,
      netTotal: _parseDouble(raw['net_total']) ?? 0,
      salesInvoiceState:
          raw['sales_invoice_state']?.toString() ?? raw['status']?.toString(),
      acceptanceStatus: acceptance,
      requiresAcceptance: requires,
      deliveryDate: _optionalString(raw['delivery_date']),
      deliveryTime: _optionalString(
        raw['delivery_time'] ?? raw['delivery_time_from'],
      ),
      itemSummary: _optionalString(raw['item_summary']),
      items: items,
      timestamp: timestamp,
      raw: raw,
    );
  }

  static InvoiceAlert fromFcmData(Map<String, dynamic> data) {
    final map = <String, dynamic>{};
    data.forEach((key, value) {
      map[key] = value;
    });

    if (map['items'] is String) {
      try {
        final parsed = jsonDecode(map['items'] as String);
        map['items'] = parsed;
      } catch (_) {}
    }

    final acceptance =
        map['acceptance_status'] ??
        map['custom_acceptance_status'] ??
        'Pending';
    final requiresRaw = map['requires_acceptance'];
    final requires = requiresRaw == null
        ? acceptance.toString().toLowerCase() != 'accepted'
        : _parseBool(requiresRaw);
    map['requires_acceptance'] = requires;
    return InvoiceAlert.fromDynamic(map);
  }

  InvoiceAlert copyWith({String? acceptanceStatus, bool? requiresAcceptance}) {
    return InvoiceAlert(
      invoiceId: invoiceId,
      customerName: customerName,
      posProfile: posProfile,
      grandTotal: grandTotal,
      netTotal: netTotal,
      salesInvoiceState: salesInvoiceState,
      acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
      requiresAcceptance: requiresAcceptance ?? this.requiresAcceptance,
      deliveryDate: deliveryDate,
      deliveryTime: deliveryTime,
      itemSummary: itemSummary,
      items: items,
      timestamp: timestamp,
      raw: raw,
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}

List<InvoiceAlertItem> _parseItems(dynamic raw) {
  if (raw == null) return const [];
  if (raw is List) {
    final items = <InvoiceAlertItem>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        items.add(InvoiceAlertItem.fromMap(entry));
      } else if (entry is Map) {
        items.add(InvoiceAlertItem.fromMap(Map<String, dynamic>.from(entry)));
      }
    }
    return items;
  }
  return const [];
}

String? _optionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

/// Customer deals: a special price for one B2B customer for a fixed period
/// (`jarz_pos.api.customer_deals`). Outside its dates the customer pays the
/// normal price again with nothing to undo — the server simply stops applying
/// the deal.
library;

double? _numOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _strOrNull(dynamic value) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty ? null : s;
}

DateTime _date(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

enum CustomerDealStatus { active, upcoming, expired, cancelled }

CustomerDealStatus _status(dynamic value) => switch (value?.toString()) {
  'active' => CustomerDealStatus.active,
  'upcoming' => CustomerDealStatus.upcoming,
  'cancelled' => CustomerDealStatus.cancelled,
  _ => CustomerDealStatus.expired,
};

/// One price of a deal: a whole category (e.g. every Large jar) or one item.
class CustomerDealLine {
  final String? itemGroup;
  final String? itemCode;
  final String label;
  final double rate;

  /// What the customer pays without the deal; null when nothing prices it.
  final double? normalRate;

  const CustomerDealLine({
    this.itemGroup,
    this.itemCode,
    required this.label,
    required this.rate,
    this.normalRate,
  });

  bool get isCategory => itemCode == null;

  factory CustomerDealLine.fromJson(Map<String, dynamic> json) {
    final code = _strOrNull(json['item_code']);
    final group = _strOrNull(json['item_group']);
    return CustomerDealLine(
      itemCode: code,
      itemGroup: code == null ? group : null,
      label: _strOrNull(json['label']) ?? code ?? group ?? '',
      rate: _numOrNull(json['rate']) ?? 0,
      normalRate: _numOrNull(json['normal_rate']),
    );
  }

  Map<String, dynamic> toPayload() => {
    if (itemCode != null) 'item_code': itemCode else 'item_group': itemGroup,
    'rate': rate,
  };
}

class CustomerDeal {
  final String name;
  final DateTime validFrom;
  final DateTime validUpto;
  final CustomerDealStatus status;
  final bool editable;

  /// A running deal that already priced a booked order: the server keeps its
  /// start and prices fixed from then on.
  final bool hasOrders;
  final String? notes;
  final String? createdBy;
  final List<CustomerDealLine> items;

  const CustomerDeal({
    required this.name,
    required this.validFrom,
    required this.validUpto,
    required this.status,
    required this.editable,
    this.hasOrders = false,
    this.notes,
    this.createdBy,
    this.items = const [],
  });

  bool get isLive =>
      status == CustomerDealStatus.active ||
      status == CustomerDealStatus.upcoming;

  factory CustomerDeal.fromJson(Map<String, dynamic> json) => CustomerDeal(
    name: json['name']?.toString() ?? '',
    validFrom: _date(json['valid_from']),
    validUpto: _date(json['valid_upto']),
    status: _status(json['status']),
    editable: json['editable'] == true,
    hasOrders: json['has_orders'] == true,
    notes: _strOrNull(json['notes']),
    createdBy: _strOrNull(json['created_by']),
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => CustomerDealLine.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

/// Something a new deal line can price, with its normal rate for this customer.
class DealTarget {
  final String? itemGroup;
  final String? itemCode;
  final String label;

  /// The category the item belongs to (items only), for grouping in the picker.
  final String? parentGroup;
  final double? normalRate;

  const DealTarget({
    this.itemGroup,
    this.itemCode,
    required this.label,
    this.parentGroup,
    this.normalRate,
  });

  bool get isCategory => itemCode == null;

  String get key => isCategory ? 'g:$itemGroup' : 'i:$itemCode';
}

class CustomerDeals {
  final String customer;
  final String customerName;
  final String? priceList;
  final bool canEdit;
  final List<CustomerDeal> deals;
  final List<DealTarget> categories;
  final List<DealTarget> items;

  const CustomerDeals({
    required this.customer,
    required this.customerName,
    this.priceList,
    this.canEdit = false,
    this.deals = const [],
    this.categories = const [],
    this.items = const [],
  });

  List<CustomerDeal> get live => deals.where((d) => d.isLive).toList();
  List<CustomerDeal> get history => deals.where((d) => !d.isLive).toList();

  factory CustomerDeals.fromJson(Map<String, dynamic> json) {
    final catalog = json['catalog'] is Map
        ? Map<String, dynamic>.from(json['catalog'] as Map)
        : const <String, dynamic>{};
    List<Map<String, dynamic>> rows(dynamic v) => (v as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return CustomerDeals(
      customer: json['customer']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      priceList: _strOrNull(json['price_list']),
      canEdit: json['can_edit'] == true,
      deals: rows(json['deals']).map(CustomerDeal.fromJson).toList(),
      categories: rows(catalog['categories'])
          .map(
            (r) => DealTarget(
              itemGroup: r['item_group']?.toString(),
              label: r['item_group']?.toString() ?? '',
              normalRate: _numOrNull(r['normal_rate']),
            ),
          )
          .toList(),
      items: rows(catalog['items'])
          .map(
            (r) => DealTarget(
              itemCode: r['item_code']?.toString(),
              label:
                  _strOrNull(r['item_name']) ??
                  r['item_code']?.toString() ??
                  '',
              parentGroup: _strOrNull(r['item_group']),
              normalRate: _numOrNull(r['normal_rate']),
            ),
          )
          .toList(),
    );
  }

  /// The normal rate of a line's target, from the catalog.
  double? normalRateFor({String? itemCode, String? itemGroup}) {
    if (itemCode != null) {
      for (final t in items) {
        if (t.itemCode == itemCode) return t.normalRate;
      }
      return null;
    }
    for (final t in categories) {
      if (t.itemGroup == itemGroup) return t.normalRate;
    }
    return null;
  }
}

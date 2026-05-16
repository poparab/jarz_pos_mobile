import 'dart:convert';

/// A local-only draft (in-progress order) that lives in Hive until checkout.
/// Never sent to the backend until [PosNotifier.checkout] is called.
class DraftCart {
  final String id;
  final String label;
  final List<Map<String, dynamic>> cartItems;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? salesPartner;
  final bool isPickup;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set when this draft is an amendment of a submitted invoice.
  /// Persisted so amendment context survives app restarts.
  final String? amendmentSourceInvoiceId;
  final double? amendmentSourceGrandTotal;

  const DraftCart({
    required this.id,
    required this.label,
    required this.cartItems,
    this.customer,
    this.salesPartner,
    required this.isPickup,
    required this.createdAt,
    required this.updatedAt,
    this.amendmentSourceInvoiceId,
    this.amendmentSourceGrandTotal,
  });

  DraftCart copyWith({
    String? label,
    List<Map<String, dynamic>>? cartItems,
    Map<String, dynamic>? customer,
    bool clearCustomer = false,
    Map<String, dynamic>? salesPartner,
    bool clearSalesPartner = false,
    bool? isPickup,
    DateTime? updatedAt,
    String? amendmentSourceInvoiceId,
    bool clearAmendmentContext = false,
    double? amendmentSourceGrandTotal,
  }) {
    return DraftCart(
      id: id,
      label: label ?? this.label,
      cartItems: cartItems ?? this.cartItems,
      customer: clearCustomer ? null : (customer ?? this.customer),
      salesPartner: clearSalesPartner ? null : (salesPartner ?? this.salesPartner),
      isPickup: isPickup ?? this.isPickup,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      amendmentSourceInvoiceId: clearAmendmentContext
          ? null
          : (amendmentSourceInvoiceId ?? this.amendmentSourceInvoiceId),
      amendmentSourceGrandTotal: clearAmendmentContext
          ? null
          : (amendmentSourceGrandTotal ?? this.amendmentSourceGrandTotal),
    );
  }

  /// Serialise to a Hive-compatible [Map] (all values are JSON-safe primitives).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'cart_items': jsonEncode(cartItems),
      'customer': customer != null ? jsonEncode(customer) : null,
      'sales_partner': salesPartner != null ? jsonEncode(salesPartner) : null,
      'is_pickup': isPickup,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'amendment_source_invoice_id': amendmentSourceInvoiceId,
      'amendment_source_grand_total': amendmentSourceGrandTotal,
    };
  }

  factory DraftCart.fromMap(Map<dynamic, dynamic> map) {
    List<Map<String, dynamic>> decodeItems(dynamic raw) {
      if (raw == null) return const [];
      try {
        final decoded = jsonDecode(raw as String) as List<dynamic>;
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    Map<String, dynamic>? decodeMap(dynamic raw) {
      if (raw == null) return null;
      try {
        return Map<String, dynamic>.from(jsonDecode(raw as String) as Map);
      } catch (_) {
        return null;
      }
    }

    DateTime parseDate(dynamic raw, DateTime fallback) {
      if (raw == null) return fallback;
      return DateTime.tryParse(raw.toString()) ?? fallback;
    }

    final now = DateTime.now();
    return DraftCart(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      cartItems: decodeItems(map['cart_items']),
      customer: decodeMap(map['customer']),
      salesPartner: decodeMap(map['sales_partner']),
      isPickup: (map['is_pickup'] as bool?) ?? false,
      createdAt: parseDate(map['created_at'], now),
      updatedAt: parseDate(map['updated_at'], now),
      amendmentSourceInvoiceId: map['amendment_source_invoice_id']?.toString(),
      amendmentSourceGrandTotal: map['amendment_source_grand_total'] != null
          ? double.tryParse(map['amendment_source_grand_total'].toString())
          : null,
    );
  }

  /// Auto-generate a label from cart state.
  /// Pattern: [customer name or 'Walk-in'] · [n] items · HH:mm
  static String buildLabel({
    Map<String, dynamic>? customer,
    required List<Map<String, dynamic>> cartItems,
    required DateTime at,
  }) {
    final customerName = customer?['customer_name']?.toString().trim() ?? '';
    final who = customerName.isNotEmpty ? customerName : 'Walk-in';
    final count = cartItems.fold<int>(0, (sum, ci) {
      final qty = (ci['quantity'] ?? 1);
      return sum + (qty is int ? qty : (qty as num).toInt());
    });
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    final period = at.hour < 12 ? 'AM' : 'PM';
    return '$who · $count item${count == 1 ? '' : 's'} · $h:$m $period';
  }
}

/// Lightweight summary for the chip bar (no cartItems payload).
class DraftCartSummary {
  final String id;
  final String label;
  final int itemCount;
  final DateTime updatedAt;

  const DraftCartSummary({
    required this.id,
    required this.label,
    required this.itemCount,
    required this.updatedAt,
  });

  factory DraftCartSummary.from(DraftCart draft) {
    return DraftCartSummary(
      id: draft.id,
      label: draft.label,
      itemCount: draft.cartItems.fold<int>(0, (sum, ci) {
        final qty = (ci['quantity'] ?? 1);
        return sum + (qty is int ? qty : (qty as num).toInt());
      }),
      updatedAt: draft.updatedAt,
    );
  }
}

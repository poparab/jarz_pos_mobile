/// How an order is identified to a human anywhere in the app.
///
/// Staff, customers and couriers all know an order by its WooCommerce number —
/// it is what the customer quotes on the phone and what is printed on the
/// receipt. The ERPNext Sales Invoice name (`ACC-SINV-2026-12345`) is an
/// internal accounting key that nobody outside the Desk uses.
///
/// So every user-facing surface renders [orderDisplayId]. The raw invoice name
/// is still what gets sent to the backend; only the label changes.
library;

/// Renders the identifier a human should see for an order.
///
/// [wooOrderId] wins when present. It arrives from the backend as an `int`, but
/// realtime/FCM payloads flatten everything to strings, so any scalar is
/// accepted and parsed. `woo_order_id` is an `Int` custom field on Sales
/// Invoice, which means a POS-native order reads back as `0` rather than null —
/// zero is therefore treated as "no Woo id", never rendered as `#0`.
///
/// The fallback is the invoice name with the constant `ACC-SINV-` prefix
/// stripped, which is all the prefix ever contributed to a person reading it.
String orderDisplayId(String? invoiceName, {Object? wooOrderId}) {
  final woo = normalizeWooOrderId(wooOrderId);
  if (woo != null) return '#$woo';

  final name = (invoiceName ?? '').trim();
  if (name.isEmpty) return '';

  const prefix = 'ACC-SINV-';
  return name.startsWith(prefix) ? name.substring(prefix.length) : name;
}

/// Coerces a backend `woo_order_id` into an id, or null when the order has none.
///
/// Accepts `int`, `num` and `String` because the same field reaches the app
/// through JSON (typed), websocket events (typed) and FCM data payloads (all
/// strings). Zero, empty and unparseable values all mean "not a Woo order".
int? normalizeWooOrderId(Object? value) {
  if (value == null) return null;
  if (value is int) return value == 0 ? null : value;
  if (value is num) {
    final asInt = value.toInt();
    return asInt == 0 ? null : asInt;
  }
  final parsed = int.tryParse(value.toString().trim());
  if (parsed == null || parsed == 0) return null;
  return parsed;
}

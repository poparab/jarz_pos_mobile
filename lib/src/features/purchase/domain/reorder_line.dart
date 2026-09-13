/// Turning a past purchase line back into a cart line.
///
/// Reorder promises "the same as before", but the Item may have changed since:
/// a UOM removed, a VAT template retired. Each of those used to be resolved in
/// a way that kept the purchase submittable yet wrong — right total, wrong
/// stock, or silently no VAT — so the decisions live here as a pure function
/// the tests can pin down.
library;

/// The cart line a past purchase line refills as.
class ReorderLine {
  final String uom;
  final double qty;
  final double rate;
  final String stockUom;
  final List<Map<String, dynamic>> uoms;
  final List<Map<String, dynamic>> prices;

  /// `null` means "no VAT".
  final String? itemTaxTemplate;

  /// The line's UOM is gone from the Item and nothing says what it held, so
  /// the quantity could not be restated in the stock UOM. It is left at zero
  /// for the buyer to enter. A zero line never reaches the server on its own —
  /// submit expansion drops it — so submit refuses it: see [linesWithoutQty].
  final bool needsQty;

  const ReorderLine({
    required this.uom,
    required this.qty,
    required this.rate,
    required this.stockUom,
    required this.uoms,
    required this.prices,
    required this.itemTaxTemplate,
    required this.needsQty,
  });
}

/// Build the cart line for [source], a row of the purchase history.
///
/// [detail] is the Item's current UOM and price list (`null` when the lookup
/// failed). [itemTaxTemplates] is the company's VAT template list, or `null`
/// when it has not loaded — which is not the same as an empty list.
ReorderLine reorderLineFrom(
  Map<String, dynamic> source, {
  Map<String, dynamic>? detail,
  List<Map<String, dynamic>>? itemTaxTemplates,
}) {
  final stockUom = (detail?['stock_uom'] ?? source['uom'] ?? '').toString();
  final sourceUom = (source['uom'] ?? stockUom).toString();
  var uom = sourceUom;
  // abs(): a return invoice stores negative quantities and rates.
  var qty = _num(source['qty']).abs();
  var rate = _num(source['rate']).abs();
  var needsQty = false;

  final uoms = _rows(detail?['uoms']);
  final prices = _rows(detail?['prices']);

  if (!uoms.any((u) => u['uom'] == sourceUom)) {
    if (detail != null && stockUom.isNotEmpty) {
      // The old UOM was removed from the Item. Offering it anyway would book
      // stock 1:1 with no error, so fall back to the stock UOM — and restate
      // the line in it. 5 x "Box of 12" at 120 is 60 units at 10; keeping 5 at
      // 120 leaves the total right while receiving a twelfth of the stock at
      // twelve times its valuation.
      uom = stockUom;
      // The line's own factor, stamped when it was bought. Older servers do
      // not send it, which reads as 0 — unknown, never "1:1".
      final factor =
          sourceUom == stockUom ? 1.0 : _num(source['conversion_factor']);
      if (factor > 0) {
        qty = _round(qty * factor);
        rate = _round(rate / factor);
      } else {
        final stockPrice = prices.firstWhere(
          (p) => p['uom'] == stockUom,
          orElse: () => const {},
        );
        qty = 0;
        rate = _num(stockPrice['rate']);
        needsQty = true;
      }
      if (!uoms.any((u) => u['uom'] == uom)) {
        uoms.add({'uom': uom, 'conversion_factor': 1});
      }
    } else {
      // Lookup failed: keep the line's own UOM as its only option —
      // DropdownButton asserts when its value is missing.
      uoms.add({'uom': uom, 'conversion_factor': 1});
    }
  }

  var template = (source['item_tax_template'] ?? '').toString();
  // A template no longer offered would show as "No VAT" yet still be sent, and
  // the server would reject the purchase with no visible cause. That check
  // needs the list: while it is unavailable the line keeps its own VAT, since
  // clearing it would send every refilled line out untaxed and lose the input
  // VAT without a word.
  if (template.isNotEmpty && itemTaxTemplates != null) {
    bool offered(String name) =>
        name.isNotEmpty && itemTaxTemplates.any((t) => t['name'] == name);
    if (!offered(template)) {
      // The line was taxed; a retired rate is replaced by the one the Item
      // carries today rather than silently becoming "No VAT".
      final current = (detail?['item_tax_template'] ?? '').toString();
      template = offered(current) ? current : '';
    }
  }

  return ReorderLine(
    uom: uom,
    qty: qty,
    rate: rate,
    stockUom: stockUom,
    uoms: uoms,
    prices: prices,
    itemTaxTemplate: template.isEmpty ? null : template,
    needsQty: needsQty,
  );
}

/// A load that shares one in-flight call and, after a failure, tries again on
/// the next [ensure] instead of remembering the failure.
class RetryingLoad<T> {
  RetryingLoad(this._load);

  final Future<T> Function() _load;
  Future<T>? _pending;
  T? _value;
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// The loaded value, or `null` if this attempt failed.
  Future<T?> ensure() async {
    if (_loaded) return _value;
    final pending = _pending ??= _load();
    try {
      final value = await pending;
      _value = value;
      _loaded = true;
      return value;
    } catch (_) {
      return null;
    } finally {
      if (identical(_pending, pending)) _pending = null;
    }
  }
}

List<Map<String, dynamic>> _rows(dynamic value) => ((value as List?) ?? const [])
    .whereType<Map>()
    .map((e) => Map<String, dynamic>.from(e))
    .toList();

double _num(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

/// Trims float noise (60.00000000001) without touching a real fraction.
double _round(double value) => (value * 1e6).roundToDouble() / 1e6;

/// Cart lines that would be submitted with no quantity.
///
/// Submit expands each line into invoice rows, and a line with nothing to buy
/// expands into none — the invoice is created without that item, short of the
/// supplier's bill and with no error. Submit refuses while this is non-empty.
List<Map<String, dynamic>> linesWithoutQty(List<Map<String, dynamic>> cart) =>
    cart.where((line) => !(_num(line['qty']) > 0)).toList();

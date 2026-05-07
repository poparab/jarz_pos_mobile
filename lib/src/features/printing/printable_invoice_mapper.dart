import '../../core/constants/business_constants.dart';
import '../kanban/models/kanban_models.dart';
import 'pos_printer_service.dart'
    if (dart.library.html) 'pos_printer_service_web.dart';

PrintableInvoice buildPrintableInvoiceFromCards({
  required InvoiceCard source,
  InvoiceCard? details,
  required String fallbackItemLabel,
  DateTime? now,
}) {
  final effective = _mergePrintableSource(source, details);
  final items = effective.items.isNotEmpty
      ? _buildPrintableItems(effective.items)
      : <PrintableInvoiceItem>[
          PrintableInvoiceItem(
            name: fallbackItemLabel,
            qty: 1,
            rate: effective.netTotal,
            amount: effective.netTotal,
          ),
        ];

  final isPaid = (effective.docStatus ?? '').toLowerCase() ==
          InvoiceStatus.paidLower ||
      effective.effectiveStatus.toLowerCase() == InvoiceStatus.paidLower;
  final rawOutstanding = effective.outstandingAmount > 0
      ? effective.outstandingAmount
      : (isPaid ? 0.0 : effective.total);
  final outstanding = rawOutstanding.clamp(0.0, effective.total).toDouble();
  final paid = (effective.total - outstanding).clamp(0.0, effective.total)
      .toDouble();

  return PrintableInvoice(
    id: effective.name,
    date: _parsePostingDate(effective.postingDate) ?? (now ?? DateTime.now()),
    customer: effective.customerName,
    customerAddress: effective.address.isNotEmpty ? effective.address : null,
    customerPhone: _trimToNull(effective.customerPhone),
    territory: _resolvePrintableTerritory(effective),
    deliveryDateTime:
        effective.deliveryStartDateTime ?? _parseLegacyDelivery(effective.requiredDeliveryDate),
    total: effective.total,
    paid: paid,
    outstanding: outstanding,
    shipping: effective.isPickup ? 0.0 : effective.shippingIncome,
    items: items,
    orderNo: _resolveOrderNo(effective),
    paymentMethod: _trimToNull(effective.paymentMethod ?? effective.actualPaymentMethod),
    orderDate: _formatPostingDate(effective.postingDate),
    deliveryTimeRange: _buildDeliveryTimeRange(effective),
    deliveryDateFormatted: _buildDeliveryDateFormatted(effective),
  );
}

InvoiceCard _mergePrintableSource(InvoiceCard source, InvoiceCard? details) {
  if (details == null) {
    return source;
  }

  return details.copyWith(
    fullAddress: _preferNonEmpty(details.fullAddress, source.fullAddress),
    customerPhone: _preferNonEmpty(details.customerPhone, source.customerPhone),
    territoryDisplay:
        _preferNonEmpty(details.territoryDisplay, source.territoryDisplay),
    subTerritoryDisplay: _preferNonEmpty(
      details.subTerritoryDisplay,
      source.subTerritoryDisplay,
    ),
    territoryNameAr:
        _preferNonEmpty(details.territoryNameAr, source.territoryNameAr),
    deliveryDate: _preferNonEmpty(details.deliveryDate, source.deliveryDate),
    deliveryTimeFrom:
        _preferNonEmpty(details.deliveryTimeFrom, source.deliveryTimeFrom),
    deliverySlotLabel:
        _preferNonEmpty(details.deliverySlotLabel, source.deliverySlotLabel),
    requiredDeliveryDate: _preferNonEmpty(
      details.requiredDeliveryDate,
      source.requiredDeliveryDate,
    ),
  );
}

List<PrintableInvoiceItem> _buildPrintableItems(List<InvoiceItem> items) {
  final childrenByParent = <String, List<InvoiceItem>>{};
  final parentKeys = <String>{};

  for (final item in items) {
    final parentKey = _bundleParentKey(item);
    if (item.isBundleParent && parentKey != null) {
      parentKeys.add(parentKey);
    }
  }

  for (final item in items) {
    final childKey = _bundleChildKey(item);
    if (item.isBundleChild && childKey != null) {
      childrenByParent.putIfAbsent(childKey, () => <InvoiceItem>[]).add(item);
    }
  }

  final printable = <PrintableInvoiceItem>[];
  final consumedChildren = <InvoiceItem>{};

  for (final item in items) {
    if (consumedChildren.contains(item)) {
      continue;
    }

    final childKey = _bundleChildKey(item);
    if (item.isBundleChild && childKey != null && parentKeys.contains(childKey)) {
      continue;
    }

    final parentKey = _bundleParentKey(item);
    if (item.isBundleParent && parentKey != null) {
      final bundleChildren = List<InvoiceItem>.from(
        childrenByParent[parentKey] ?? const <InvoiceItem>[],
      );
      consumedChildren.addAll(bundleChildren);
      final bundleAmount = item.amount > 0
          ? item.amount
          : bundleChildren.fold<double>(0.0, (sum, child) => sum + child.amount);
      final bundleRate = item.qty > 0
          ? (bundleAmount > 0 ? bundleAmount / item.qty : item.rate)
          : item.rate;

      printable.add(
        PrintableInvoiceItem(
          name: item.itemName,
          qty: item.qty,
          rate: bundleRate,
          amount: bundleAmount > 0 ? bundleAmount : item.amount,
          bold: true,
          showPricing: bundleAmount > 0 || item.amount > 0 || item.rate > 0,
        ),
      );

      for (final child in bundleChildren) {
        printable.add(
          PrintableInvoiceItem(
            name: child.itemName,
            qty: child.qty,
            rate: child.rate,
            amount: child.amount,
            showPricing: false,
            indentLevel: 1,
          ),
        );
      }
      continue;
    }

    printable.add(
      PrintableInvoiceItem(
        name: item.itemName,
        qty: item.qty,
        rate: item.rate,
        amount: item.amount,
      ),
    );
  }

  return printable;
}

String? _resolvePrintableTerritory(InvoiceCard invoice) {
  final candidate = _trimToNull(invoice.territoryNameAr) ??
      _trimToNull(invoice.subTerritoryDisplay) ??
      _trimToNull(invoice.territoryDisplay) ??
      (_looksInternalTerritoryCode(invoice.territory)
          ? null
          : _trimToNull(invoice.territory));

  if (candidate == null) {
    return null;
  }

  final address = _trimToNull(invoice.fullAddress);
  if (address != null && _normalizeComparable(address).contains(_normalizeComparable(candidate))) {
    return null;
  }

  return candidate;
}

String? _bundleParentKey(InvoiceItem item) {
  if (!item.isBundleParent) {
    return null;
  }

  return _trimToNull(item.bundleCode) ??
      _trimToNull(item.itemCode) ??
      _trimToNull(item.itemName);
}

String? _bundleChildKey(InvoiceItem item) {
  if (!item.isBundleChild) {
    return null;
  }

  return _trimToNull(item.parentBundle) ??
      _trimToNull(item.bundleCode) ??
      _trimToNull(item.itemCode) ??
      _trimToNull(item.itemName);
}

DateTime? _parseLegacyDelivery(String? text) {
  final normalized = _trimToNull(text);
  if (normalized == null) {
    return null;
  }

  return DateTime.tryParse(normalized);
}

String? _preferNonEmpty(String? primary, String? fallback) {
  return _trimToNull(primary) ?? _trimToNull(fallback);
}

String? _trimToNull(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

bool _looksInternalTerritoryCode(String value) {
  final normalized = value.trim();
  return normalized.isNotEmpty &&
      !normalized.contains(' ') &&
      RegExp(r'^[A-Z0-9_-]{5,}$').hasMatch(normalized);
}

String _normalizeComparable(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), '');
}

// ── New helpers for bitmap receipt fields ─────────────────────────────────────

String? _resolveOrderNo(InvoiceCard card) {
  final short = _trimToNull(card.invoiceIdShort);
  if (short != null) return short;
  // Fallback: last 5 alphanumeric chars of invoice name
  final cleaned = card.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (cleaned.length <= 5) return _trimToNull(cleaned);
  return cleaned.substring(cleaned.length - 5);
}

DateTime? _parsePostingDate(String? s) {
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
}

String? _formatPostingDate(String? s) {
  final d = _parsePostingDate(s);
  if (d == null) return null;
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

String? _buildDeliveryTimeRange(InvoiceCard card) {
  final start = card.deliveryStartDateTime;
  if (start == null) return null;
  final dur = card.deliveryDurationParsed;
  final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  if (dur == null || dur.inMinutes == 0) return startStr;
  final end = start.add(dur);
  final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '$startStr - $endStr';
}

String? _buildDeliveryDateFormatted(InvoiceCard card) {
  final start = card.deliveryStartDateTime;
  if (start == null) return null;
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final dayName = days[start.weekday - 1];
  final monthName = months[start.month - 1];
  final dateNum = start.day.toString().padLeft(2, '0');
  return '$dayName, $monthName $dateNum, ${start.year}';
}
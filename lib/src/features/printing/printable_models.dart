// What a receipt, statement or batch sheet is drawn from. One definition for
// mobile and web: both printer services export it, so a receipt built on one
// platform is the same type the shared canvas renderer takes on the other.

class PrintableInvoiceItem {
  final String name;
  final double qty;
  final double rate;
  final double amount;
  final bool showPricing;
  final int indentLevel;
  final bool bold;
  // Optional sub-line shown below the item name (e.g. "Size : Large")
  final String? description;
  PrintableInvoiceItem({
    required this.name,
    required this.qty,
    required this.rate,
    double? amount,
    this.showPricing = true,
    this.indentLevel = 0,
    this.bold = false,
    this.description,
  }) : amount = amount ?? qty * rate;
}

class PrintableInvoice {
  final String id;
  final DateTime date;
  final String customer;
  final String? customerAddress;
  final String? customerPhone;
  final String? territory;
  final DateTime? deliveryDateTime;
  final double
  total; // Grand total (ERPNext Sales Invoice grand_total) INCLUDING shipping income
  final double paid;
  final double outstanding;
  final double
  shipping; // Shipping income component (single source of truth from Sales Invoice); do NOT add again to total
  final List<PrintableInvoiceItem> items;
  // New fields for bitmap receipt renderer
  final String? orderNo;              // Short order number shown on receipt (WooCommerce ID or last-5 of invoice)
  final String? paymentMethod;        // Cash / Instapay / Mobile Wallet
  final String? orderDate;            // Posting date formatted as DD/MM/YYYY
  final String? deliveryTimeRange;    // e.g. "22:00 - 23:30"
  final String? deliveryDateFormatted; // e.g. "Wednesday, May 06, 2026"
  // True when outstanding moved to courier outstanding account but courier hasn't remitted yet.
  final bool hasUnsettledCourierTxn;
  PrintableInvoice({
    required this.id,
    required this.date,
    required this.customer,
    this.customerAddress,
    this.customerPhone,
    this.territory,
    this.deliveryDateTime,
    required this.total,
    required this.paid,
    required this.outstanding,
    this.shipping = 0.0,
    required this.items,
    this.orderNo,
    this.paymentMethod,
    this.orderDate,
    this.deliveryTimeRange,
    this.deliveryDateFormatted,
    this.hasUnsettledCourierTxn = false,
  });
}

/// One material line on a batch sheet.
class PrintableBatchComponent {
  final String name;
  final double qty;
  final String uom;
  const PrintableBatchComponent({
    required this.name,
    required this.qty,
    this.uom = '',
  });
}

/// The paper that goes on the bench with the batch.
///
/// Deliberately not an invoice: no customer, no money, no totals — a receipt
/// shaped like a bill is unreadable as a work instruction, and the bitmap
/// renderer is built entirely around the invoice layout.
class PrintableBatchSheet {
  final String workOrder;
  final String itemName;
  final String itemCode;
  final double plannedQty;
  final String uom;
  final String? bom;
  final DateTime? startedAt;
  final String? startedBy;

  /// The SOP version stamped on the Work Order when it started, printed so the
  /// paper on the bench can be tied back to the method it was made by.
  final String? sopVersion;
  final List<PrintableBatchComponent> components;
  final String? notes;

  const PrintableBatchSheet({
    required this.workOrder,
    required this.itemName,
    this.itemCode = '',
    required this.plannedQty,
    this.uom = '',
    this.bom,
    this.startedAt,
    this.startedBy,
    this.sopVersion,
    this.components = const [],
    this.notes,
  });
}

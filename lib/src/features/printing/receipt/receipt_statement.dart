// A consolidated statement: several unpaid orders of one customer, sent as
// one message or one image instead of a receipt per order.
import '../pos_printer_service.dart'
    if (dart.library.html) '../pos_printer_service_web.dart';
import 'receipt_branding.dart';
import 'receipt_share.dart';

/// One order on a statement, with what is still owed on it.
///
/// [outstanding] is passed in rather than read off [invoice] so the statement
/// states the credit ledger's figure — the same number the account screen
/// shows next to the order — not a second derivation of it.
class StatementEntry {
  final PrintableInvoice invoice;
  final double outstanding;

  const StatementEntry({required this.invoice, required this.outstanding});

  double get paid => (invoice.total - outstanding).clamp(0.0, invoice.total).toDouble();

  /// What the listed lines and shipping come to above the order's total —
  /// an order or promo discount, which has no line of its own. Without it a
  /// discounted order's lines add up to more than the total printed under
  /// them. Zero when they agree (or fall short, e.g. a rounding cent).
  double get discount {
    final lines = invoice.items.where((i) => i.showPricing).fold(0.0, (sum, i) => sum + i.amount);
    final shipping = invoice.shipping > 0 && invoice.shipping <= invoice.total ? invoice.shipping : 0.0;
    final over = lines + shipping - invoice.total;
    return over > 0.005 ? over : 0.0;
  }
}

class PrintableStatement {
  final String customer;
  final DateTime date;
  final List<StatementEntry> entries;

  const PrintableStatement({
    required this.customer,
    required this.date,
    required this.entries,
  });

  double get totalDue => entries.fold(0.0, (sum, e) => sum + e.outstanding);

  String get dateLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// Title printed on the statement, text and image alike.
const statementTitle = 'ACCOUNT STATEMENT';

/// The statement as one WhatsApp message: every chosen order with its lines,
/// what it came to, what was paid and what is due, then the total due.
///
/// English and EGP like the receipts it consolidates; `*…*` is WhatsApp bold.
String buildStatementShareText(PrintableStatement st, ReceiptBranding branding) {
  final sb = StringBuffer();
  sb.writeln('*$statementTitle*');
  if (st.customer.isNotEmpty) sb.writeln(st.customer);
  sb.writeln('Date: ${st.dateLabel}');

  for (final entry in st.entries) {
    final inv = entry.invoice;
    sb.writeln();
    final date = (inv.orderDate ?? '').isNotEmpty ? ' · ${inv.orderDate}' : '';
    sb.writeln('*Order #${receiptOrderLabel(inv)}*$date');
    for (final item in inv.items) {
      if (!item.showPricing) {
        sb.writeln('   - ${receiptQty(item.qty)} × ${item.name}');
        continue;
      }
      sb.writeln('${receiptQty(item.qty)} × ${item.name} — ${receiptMoney(item.amount)}');
    }
    if (inv.shipping > 0 && inv.shipping <= inv.total) {
      sb.writeln('Shipping: ${receiptMoney(inv.shipping)}');
    }
    if (entry.discount > 0) sb.writeln('Discount: -${receiptMoney(entry.discount)}');
    sb.writeln('Order total: ${receiptMoney(inv.total)}');
    if (entry.paid > 0.005) sb.writeln('Paid: ${receiptMoney(entry.paid)}');
    sb.writeln('Due: ${receiptMoney(entry.outstanding)}');
  }

  sb.writeln();
  final count = st.entries.length;
  sb.writeln('*Total due: ${receiptMoney(st.totalDue)}*');
  sb.writeln('$count ${count == 1 ? 'order' : 'orders'}');

  final footer = [
    branding.footer,
    if (branding.phone.isNotEmpty) 'Call us ${branding.phone}',
    branding.website,
  ].where((s) => s.trim().isNotEmpty).toList();
  if (footer.isNotEmpty) {
    sb.writeln();
    footer.forEach(sb.writeln);
  }
  return sb.toString().trimRight();
}

/// Several individual receipts in one WhatsApp message.
///
/// wa.me opens exactly one composed message, so "one receipt each" on
/// WhatsApp means the receipts one after another, divided. The share sheet is
/// where they go as separate images.
String buildReceiptsBundleText(List<PrintableInvoice> invoices, ReceiptBranding branding) {
  return invoices.map((inv) => buildReceiptShareText(inv, branding)).join('\n\n— — — — —\n\n');
}

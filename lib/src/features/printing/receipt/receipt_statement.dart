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

  /// The shop branch (delivery door) the order went to; '' when unknown.
  final String branch;

  const StatementEntry({required this.invoice, required this.outstanding, this.branch = ''});

  /// When the order was delivered, as DD/MM/YYYY: the date the shop knows
  /// the order by. The posting date stands in when there is no slot.
  String get dateLabel {
    final d = invoice.deliveryDateTime;
    if (d == null) return invoice.orderDate ?? '';
    return _ddmmyyyy(d);
  }

  /// Sort key for [dateLabel]: delivery first, posting as the fallback.
  DateTime get sortDate => invoice.deliveryDateTime ?? invoice.date;

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

  String get dateLabel => _ddmmyyyy(date);

  /// The entries under their shop branches, each section oldest delivery
  /// first, sections in the order their oldest order appears. A single
  /// section with an empty branch when no entry names one — a shop with one
  /// door, or a server too old to say — and the statement reads as before.
  List<StatementSection> get sections {
    final byBranch = <String, List<StatementEntry>>{};
    for (final e in entries) {
      byBranch.putIfAbsent(e.branch.trim(), () => []).add(e);
    }
    if (byBranch.length == 1 && byBranch.keys.first.isEmpty) {
      return [StatementSection('', entries)];
    }
    final out = [
      for (final kv in byBranch.entries)
        StatementSection(kv.key, [...kv.value]..sort((a, b) => a.sortDate.compareTo(b.sortDate))),
    ];
    // Orders whose door is unknown go last, under their own heading.
    out.sort((a, b) {
      if (a.branch.isEmpty != b.branch.isEmpty) return a.branch.isEmpty ? 1 : -1;
      return a.entries.first.sortDate.compareTo(b.entries.first.sortDate);
    });
    return out;
  }
}

/// One shop branch's orders on a statement. [branch] is '' for orders whose
/// branch is unknown.
class StatementSection {
  final String branch;
  final List<StatementEntry> entries;

  const StatementSection(this.branch, this.entries);

  double get totalDue => entries.fold(0.0, (sum, e) => sum + e.outstanding);

  /// The heading printed over the section.
  String get heading => branch.isEmpty ? statementOtherBranchHeading : 'Branch: $branch';
}

String _ddmmyyyy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Heading over orders whose branch could not be told.
const statementOtherBranchHeading = 'Branch: not recorded';

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

  final sections = st.sections;
  final branched = sections.first.branch.isNotEmpty || sections.length > 1;
  for (final section in sections) {
    if (branched) {
      sb.writeln();
      sb.writeln('*━━ ${section.heading} ━━*');
    }
    for (final entry in section.entries) {
      _writeStatementEntry(sb, entry, branch: section.branch);
    }
    if (branched) {
      sb.writeln();
      sb.writeln('*${section.branch.isEmpty ? 'Due' : '${section.branch} due'}: ${receiptMoney(section.totalDue)}*');
    }
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

/// One order on the statement text; [branch] is repeated on the order so a
/// forwarded message still says which door it was delivered to.
void _writeStatementEntry(StringBuffer sb, StatementEntry entry, {required String branch}) {
  final inv = entry.invoice;
  sb.writeln();
  final date = entry.dateLabel.isNotEmpty ? ' · ${entry.dateLabel}' : '';
  sb.writeln('*Order #${receiptOrderLabel(inv)}*$date');
  if (branch.isNotEmpty) sb.writeln('Branch: $branch');
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

/// Several individual receipts in one WhatsApp message.
///
/// wa.me opens exactly one composed message, so "one receipt each" on
/// WhatsApp means the receipts one after another, divided. The share sheet is
/// where they go as separate images.
String buildReceiptsBundleText(List<PrintableInvoice> invoices, ReceiptBranding branding) {
  return invoices.map((inv) => buildReceiptShareText(inv, branding)).join('\n\n— — — — —\n\n');
}

// Sending a receipt to the customer: the text that goes on WhatsApp and the
// wa.me link that carries it. Pure Dart, identical on mobile and web.
import '../pos_printer_service.dart'
    if (dart.library.html) '../pos_printer_service_web.dart';
import 'receipt_branding.dart';

/// Digits-only international number that `https://wa.me/<msisdn>` needs.
///
/// Port of the backend's `jarz_pos.utils.phone.whatsapp_msisdn`: wa.me wants
/// the country code with no `+`, no trunk zero and no separators, and opens a
/// "not on WhatsApp" dead end for anything else, while customers are stored
/// as `01…`, `+201…`, `201…`, `00201…` or ten digits with the zero dropped.
/// Non-Egyptian numbers pass through digit-stripped: a guessed country code
/// would open a chat with a different real person.
String whatsappMsisdn(String? phone) {
  var digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('00')) digits = digits.substring(2);
  // "+20 0…": country code typed in front of the trunk zero.
  if (digits.startsWith('200') && digits.length == 13) return '20${digits.substring(3)}';
  if (digits.startsWith('0') && digits.length == 11) return '20${digits.substring(1)}';
  if (digits.startsWith('20') && digits.length == 12) return digits;
  if (digits.length == 10 && digits.startsWith('1')) return '20$digits';
  return digits;
}

/// `wa.me` link that opens the customer's chat with [text] composed.
///
/// Without a usable number it still opens WhatsApp with the message ready and
/// lets the cashier pick the chat.
Uri whatsappReceiptUri(String? phone, String text) {
  final msisdn = whatsappMsisdn(phone);
  return Uri.parse(
    'https://wa.me/$msisdn?text=${Uri.encodeComponent(text)}',
  );
}

/// One-line caption that travels with the receipt image on the share sheet.
String receiptShareCaption(PrintableInvoice inv, ReceiptBranding branding) {
  final order = receiptOrderLabel(inv);
  return '${branding.header} — Order #$order';
}

/// The receipt as a WhatsApp message.
///
/// Customer-facing, so it follows the paper receipt rather than the cashier's
/// UI language: English, EGP, and the same PAID/UNPAID rule the printer uses
/// (outstanding at zero). `*…*` is WhatsApp bold.
String buildReceiptShareText(PrintableInvoice inv, ReceiptBranding branding) {
  final sb = StringBuffer();
  final isPaid = inv.outstanding <= 0.0001;

  sb.writeln('*${branding.header}*');
  sb.writeln('Order #${receiptOrderLabel(inv)}');
  if ((inv.orderDate ?? '').isNotEmpty) sb.writeln('Order date: ${inv.orderDate}');
  final deliveryDate = inv.deliveryDateFormatted ?? '';
  final deliveryTime = inv.deliveryTimeRange ?? '';
  if (deliveryDate.isNotEmpty || deliveryTime.isNotEmpty) {
    sb.writeln('Delivery: ${[deliveryDate, deliveryTime].where((s) => s.isNotEmpty).join(', ')}');
  }

  sb.writeln();
  if (inv.customer.isNotEmpty) sb.writeln(inv.customer);
  if ((inv.customerAddress ?? '').isNotEmpty) sb.writeln(inv.customerAddress);

  sb.writeln();
  for (final item in inv.items) {
    if (!item.showPricing) {
      // Bundle contents: listed under their bundle, no money of their own.
      final indent = '   ' * (item.indentLevel > 0 ? item.indentLevel : 1);
      sb.writeln('$indent- ${receiptQty(item.qty)} × ${item.name}');
      continue;
    }
    sb.writeln('${receiptQty(item.qty)} × ${item.name} — ${receiptMoney(item.amount)}');
    if ((item.description ?? '').isNotEmpty) sb.writeln('   ${item.description}');
  }

  sb.writeln();
  final grand = inv.total;
  if (inv.shipping > 0 && inv.shipping <= grand) {
    sb.writeln('Subtotal: ${receiptMoney(grand - inv.shipping)}');
    sb.writeln('Shipping: ${receiptMoney(inv.shipping)}');
  }
  sb.writeln('*Total: ${receiptMoney(grand)}*');
  if ((inv.paymentMethod ?? '').isNotEmpty) sb.writeln('Payment method: ${inv.paymentMethod}');
  if (isPaid) {
    sb.writeln('Status: PAID');
  } else {
    sb.writeln('Status: UNPAID');
    if (inv.outstanding < grand - 0.0001) sb.writeln('Amount due: ${receiptMoney(inv.outstanding)}');
  }

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

/// Order number the customer knows the order by; the invoice id otherwise.
String receiptOrderLabel(PrintableInvoice inv) =>
    (inv.orderNo ?? '').trim().isNotEmpty ? inv.orderNo!.trim() : inv.id;

String receiptMoney(double v) => 'EGP ${v.toStringAsFixed(2)}';

String receiptQty(double qty) {
  if ((qty - qty.round()).abs() < 0.0001) return qty.round().toString();
  return qty.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

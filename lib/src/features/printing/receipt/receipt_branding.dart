/// The shop lines a receipt carries: printed on paper, and repeated in the
/// text that goes to a customer on WhatsApp.
///
/// Platform-neutral on purpose — both `PosPrinterService` implementations
/// (mobile and the web stub) return it, and neither can import the other.
class ReceiptBranding {
  final String header;
  final String footer;
  final String phone;
  final String website;

  const ReceiptBranding({
    required this.header,
    required this.footer,
    required this.phone,
    required this.website,
  });

  /// What the receipt says when `get_receipt_config` cannot be reached.
  /// Mirrors the mobile service's own fallbacks.
  const ReceiptBranding.defaults()
      : header = 'ORDER RECEIPT',
        footer = 'Thank you for Your Order',
        phone = '01061332266',
        website = 'www.orderjarz.com';
}

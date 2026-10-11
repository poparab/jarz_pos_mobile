// The wa.me links a follow-up opens. Pure Dart; reuses the receipt feature's
// port of the backend's `whatsapp_msisdn` instead of a second normaliser.
import '../../printing/receipt/receipt_share.dart';
import 'models/followup_models.dart';

/// The number a follow-up's WhatsApp chat opens on: the server's
/// `whatsapp_msisdn` when it sent one, else the client-side port applied to
/// `phone`. Empty when neither yields digits — the button is then disabled.
String followupMsisdn(FollowupRow row) {
  final fromServer = whatsappMsisdn(row.whatsappMsisdn);
  if (fromServer.isNotEmpty) return fromServer;
  return whatsappMsisdn(row.phone);
}

/// `https://wa.me/<msisdn>?text=<text>` for [msisdn], or null without one.
///
/// A follow-up always targets one customer, so unlike the receipt link this
/// never opens WhatsApp without a number (that would let the sender message
/// the wrong chat).
Uri? followupWhatsappUriFor(String msisdn, String text) {
  final digits = msisdn.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  return Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(text)}');
}

/// The wa.me link carrying the row's pre-rendered `message_text`.
Uri? followupWhatsappUri(FollowupRow row) =>
    followupWhatsappUriFor(followupMsisdn(row), row.messageText);

/// Customer-facing apology that carries [code]. Arabic on purpose: it goes to
/// the customer (like the backend-rendered `message_text`), not the UI, so it
/// does not follow the sender's app language.
String followupApologyText(String code) =>
    'إحنا آسفين جدًا على التجربة دي. '
    'ده كود اعتذار ليك تستخدمه في طلبك الجاي: $code';

/// `tel:` link for [phone], or null when it has no dialable digits.
Uri? followupTelUri(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleaned.replaceAll('+', '').isEmpty) return null;
  return Uri(scheme: 'tel', path: cleaned);
}

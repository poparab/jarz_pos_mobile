import '../data/tracking_link.dart';

/// The WhatsApp / share-sheet message for a tracking link.
///
/// Customer-facing and bilingual (Arabic first, then English) whatever the
/// cashier's UI language is, like the receipt text. The delivery-code lines are
/// added only when the server says the code is required — an unused code in the
/// message would only confuse the customer.
String buildTrackingShareText(TrackingLink link) {
  final sb = StringBuffer()
    ..writeln('تابع طلبك من جارز لحظة بلحظة:')
    ..writeln('Follow your Jarz order live:')
    ..writeln(link.url);
  if (link.hasCodeToShare) {
    final code = link.deliveryCode!;
    sb
      ..writeln()
      ..writeln('كود الاستلام: $code (أعطه للمندوب عند وصول الطلب)')
      ..writeln('Delivery code: $code (give it to the courier when your order arrives)');
  }
  return sb.toString().trimRight();
}

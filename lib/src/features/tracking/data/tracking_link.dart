/// Reply of `jarz_pos.api.tracking.get_tracking_link(invoice_id)`:
/// `{url, delivery_code, code_required, customer_phone}`.
///
/// Hand-written and tolerant, like the rest of the geo/leads models: a field
/// the server omits degrades to "not there" rather than throwing.
class TrackingLink {
  const TrackingLink({
    required this.url,
    this.deliveryCode,
    this.codeRequired = false,
    this.customerPhone,
  });

  /// The customer-facing public tracking page.
  final String url;

  /// 4-digit code the customer gives the courier. The server returns it even
  /// when the setting is off; only share it when [codeRequired] is true.
  final String? deliveryCode;

  /// `require_delivery_code` is on: the courier cannot close the stop without it.
  final bool codeRequired;

  final String? customerPhone;

  /// True when the code is both demanded and actually present.
  bool get hasCodeToShare =>
      codeRequired && deliveryCode != null && deliveryCode!.isNotEmpty;

  factory TrackingLink.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final s = value?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    final required = json['code_required'];
    return TrackingLink(
      url: text(json['url']) ?? '',
      deliveryCode: text(json['delivery_code']),
      codeRequired:
          required == true || required == 1 || required == '1' || required == 'true',
      customerPhone: text(json['customer_phone']),
    );
  }
}

/// One candidate customer inside a duplicate-phone group, from the
/// `candidates` array of `customer_dedupe.review_report`. Flat, mobile-ready
/// shape — see that function's docstring for the exact contract.
class WooDuplicateCandidate {
  final String name;
  final String customerName;
  final String phone;
  final String email;
  final String created;
  final bool disabled;
  final String wooCustomerId;
  final int invoiceCount;
  final int submittedInvoiceCount;
  final double revenue;

  const WooDuplicateCandidate({
    required this.name,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.created,
    required this.disabled,
    required this.wooCustomerId,
    required this.invoiceCount,
    required this.submittedInvoiceCount,
    required this.revenue,
  });

  factory WooDuplicateCandidate.fromJson(Map<String, dynamic> json) {
    return WooDuplicateCandidate(
      name: (json['name'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      created: (json['created'] ?? '').toString(),
      disabled: json['disabled'] == 1 || json['disabled'] == true,
      wooCustomerId: (json['woo_customer_id'] ?? '').toString(),
      invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
      submittedInvoiceCount: (json['submitted_invoice_count'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// One duplicate-phone group the dedupe autopilot refused to auto-merge, from
/// `customer_dedupe.review_report`. READ-ONLY on mobile: the merge itself is
/// System-Manager-only and deliberately not callable from this app — this
/// model exists so a human can triage which candidate looks real.
class WooDuplicateGroup {
  final String groupId;
  final String phone;
  final int size;
  final String reason;
  final List<WooDuplicateCandidate> candidates;

  const WooDuplicateGroup({
    required this.groupId,
    required this.phone,
    required this.size,
    required this.reason,
    required this.candidates,
  });

  factory WooDuplicateGroup.fromJson(Map<String, dynamic> json) {
    final rawCandidates = json['candidates'];
    return WooDuplicateGroup(
      groupId: (json['group_id'] ?? json['phone'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      size: (json['size'] as num?)?.toInt() ?? 0,
      reason: (json['reason'] ?? '').toString(),
      candidates: rawCandidates is List
          ? rawCandidates
              .whereType<Map>()
              .map((e) => WooDuplicateCandidate.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

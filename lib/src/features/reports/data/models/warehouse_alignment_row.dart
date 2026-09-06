import '../../../../core/utils/order_display_id.dart';

/// One submitted Sales Invoice whose item warehouses disagree with its
/// branch's expected warehouse — a row from
/// `jarz_pos.api.manager.get_invoice_warehouse_alignment_report`.
///
/// This drift is upstream of the recurring negative-bin problem that keeps
/// forcing branch stock recounts. The report — and this screen — are
/// read-only: the repair endpoint stayed behind a stricter admin gate on
/// purpose and must never be called from mobile.
class WarehouseAlignmentRow {
  final String name;
  final String? company;
  final String? customer;
  final String? postingDate;
  final double amount;
  final String? operationalProfile;
  final String? targetWarehouse;

  /// Deduped list of the warehouse(s) the invoice's items actually posted
  /// against. Empty when the backend did not report a mismatch detail even
  /// though the row is in this (already-filtered) list.
  final List<String> actualWarehouses;

  const WarehouseAlignmentRow({
    required this.name,
    this.company,
    this.customer,
    this.postingDate,
    required this.amount,
    this.operationalProfile,
    this.targetWarehouse,
    this.actualWarehouses = const [],
  });

  factory WarehouseAlignmentRow.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0.0;
    String? toStr(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final rawActual = json['actual_warehouses'];
    final actual = <String>[];
    if (rawActual is List) {
      for (final v in rawActual) {
        final s = v?.toString().trim();
        if (s != null && s.isNotEmpty && !actual.contains(s)) actual.add(s);
      }
    } else {
      final single = toStr(rawActual);
      if (single != null) actual.add(single);
    }

    return WarehouseAlignmentRow(
      name: (json['name'] ?? '').toString(),
      company: toStr(json['company']),
      customer: toStr(json['customer']),
      postingDate: toStr(json['posting_date']),
      amount: toDouble(json['amount']),
      operationalProfile: toStr(json['operational_profile']),
      targetWarehouse: toStr(json['target_warehouse']),
      actualWarehouses: actual,
    );
  }

  /// Short, human-facing id for this invoice (the internal
  /// `ACC-SINV-...` prefix stripped).
  String get displayId => orderDisplayId(name);
}

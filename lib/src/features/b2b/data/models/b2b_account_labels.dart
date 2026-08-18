/// Label-stock summary carried on the B2B account payload
/// (`jarz_pos.api.crm.get_account` → `labels`).
///
/// Deliberately NOT part of the Freezed models in `b2b_models.dart`: the key is
/// nullable, tolerant parsing matters more than codegen, and keeping it out of
/// the generated classes means no `.freezed.dart` churn. The repository parses
/// it off the raw payload and hands it over next to the account.
library;

import 'b2b_models.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}

String _toStr(dynamic value) => value?.toString() ?? '';

/// One flavour's label status line on the account screen.
class B2bLabelFlavour {
  /// The `Jarz Customer Label` name — the tap-through key to `/labels/detail`.
  final String label;
  final String title;
  final String size;
  final int onHandQty;

  /// Raw server status text ("Out of Stock", "Reorder Now", ...). The account
  /// screen renders it through the labels feature's own status chip.
  final String status;

  const B2bLabelFlavour({
    required this.label,
    required this.title,
    required this.size,
    required this.onHandQty,
    required this.status,
  });

  factory B2bLabelFlavour.fromJson(Map<String, dynamic> json) =>
      B2bLabelFlavour(
        label: _toStr(json['label']),
        title: _toStr(json['title']).isEmpty
            ? _toStr(json['label'])
            : _toStr(json['title']),
        size: _toStr(json['size']),
        onHandQty: _toInt(json['on_hand_qty']),
        status: _toStr(json['status']),
      );
}

/// The account's label position: totals plus a row per flavour.
class B2bAccountLabels {
  final int total;
  final int needsAttention;
  final int outOfStock;
  final int reorderNow;
  final List<B2bLabelFlavour> flavours;

  const B2bAccountLabels({
    required this.total,
    required this.needsAttention,
    required this.outOfStock,
    required this.reorderNow,
    required this.flavours,
  });

  /// Null when the payload carries no usable `labels` key — an older backend,
  /// a null value, or junk all read as "labels unknown", never as a crash.
  static B2bAccountLabels? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return B2bAccountLabels(
      total: _toInt(json['total']),
      needsAttention: _toInt(json['needs_attention']),
      outOfStock: _toInt(json['out_of_stock']),
      reorderNow: _toInt(json['reorder_now']),
      flavours: (json['flavours'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => B2bLabelFlavour.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  bool get isEmpty => total == 0 && flavours.isEmpty;
}

/// What `getAccount` returns: the Freezed account plus the hand-parsed label
/// summary riding alongside it.
class B2bAccountDetail {
  final B2bAccount account;
  final B2bAccountLabels? labels;

  const B2bAccountDetail({required this.account, this.labels});
}

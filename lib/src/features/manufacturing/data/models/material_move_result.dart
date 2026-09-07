/// What came back from moving a short component into its recipe's warehouse.
class MaterialMoveResult {
  const MaterialMoveResult({
    this.stockEntry = '',
    this.itemCode = '',
    this.qty = 0,
    this.uom = '',
    this.fromWarehouse = '',
    this.toWarehouse = '',
    this.availableAtTarget = 0,
    this.availableAtSource = 0,
  });

  factory MaterialMoveResult.fromJson(Map<String, dynamic> json) =>
      MaterialMoveResult(
        stockEntry: json['stock_entry']?.toString() ?? '',
        itemCode: json['item_code']?.toString() ?? '',
        qty: (json['qty'] as num?)?.toDouble() ?? 0,
        uom: json['uom']?.toString() ?? '',
        fromWarehouse: json['from_warehouse']?.toString() ?? '',
        toWarehouse: json['to_warehouse']?.toString() ?? '',
        availableAtTarget: (json['available_at_target'] as num?)?.toDouble() ?? 0,
        availableAtSource: (json['available_at_source'] as num?)?.toDouble() ?? 0,
      );

  final String stockEntry;
  final String itemCode;
  final double qty;
  final String uom;
  final String fromWarehouse;
  final String toWarehouse;

  /// Stock in the recipe's warehouse after the move — the number that decides
  /// whether the batch can now start, so it is reported rather than recomputed.
  final double availableAtTarget;
  final double availableAtSource;
}

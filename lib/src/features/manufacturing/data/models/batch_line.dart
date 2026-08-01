// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'bom_details.dart';

part 'batch_line.freezed.dart';
part 'batch_line.g.dart';

/// One item queued for production.
///
/// Deliberately holds no `TextEditingController` and no `FocusNode`: those live
/// in the card widget and sync from this model in `didUpdateWidget`. Keeping
/// them out is what removes the old two-way re-entrancy guards and the
/// controller leak when a line was removed mid-session.
@freezed
class BatchLine with _$BatchLine {
  const factory BatchLine({
    @JsonKey(name: 'item_code') required String itemCode,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'bom_name') required String bomName,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,

    /// Finished units produced by one run of this BOM.
    @JsonKey(name: 'bom_qty_yield') @Default(1.0) double bomQtyYield,

    /// How many BOM runs to queue. Fractional is allowed — some BOMs are
    /// weight-based and half a batch is a real thing to make.
    @Default(1.0) double batches,
    @Default(<BomComponent>[]) List<BomComponent> components,
  }) = _BatchLine;

  factory BatchLine.fromJson(Map<String, dynamic> json) =>
      _$BatchLineFromJson(json);

  /// Builds a line from a fetched BOM, defaulting to a single batch.
  factory BatchLine.fromBom(BomDetails bom, {double batches = 1.0}) => BatchLine(
        itemCode: bom.itemCode,
        itemName: bom.itemName,
        bomName: bom.defaultBom,
        stockUom: bom.stockUom,
        bomQtyYield: bom.bomQty,
        batches: batches,
        components: bom.components,
      );

  const BatchLine._();

  /// Finished units this line will produce. This is the quantity the backend
  /// receives as `item_qty`.
  double get units => batches * bomQtyYield;

  BatchLine withBatches(double value) =>
      copyWith(batches: value < 0 ? 0 : value);

  /// Sets the line by finished units instead of batch count.
  BatchLine withUnits(double value) {
    if (bomQtyYield <= 0) return copyWith(batches: 0);
    return copyWith(batches: (value < 0 ? 0 : value) / bomQtyYield);
  }

  /// Material requirement for this line at its current batch count.
  double requiredQtyOf(BomComponent component) =>
      component.totalForBatches(batches);
}

/// The whole batch: what to make, and the single date it posts on.
///
/// One date for the run replaces the per-line clocks — for a team making one
/// run a day, a picker per row was ceremony repeated per line.
@freezed
class ProductionBasket with _$ProductionBasket {
  const factory ProductionBasket({
    @Default(<BatchLine>[]) List<BatchLine> lines,
    @JsonKey(name: 'posting_date') DateTime? postingDate,
  }) = _ProductionBasket;

  factory ProductionBasket.fromJson(Map<String, dynamic> json) =>
      _$ProductionBasketFromJson(json);

  const ProductionBasket._();

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;

  /// Lines worth submitting — a zeroed line is a leftover, not an instruction.
  List<BatchLine> get positiveLines =>
      lines.where((l) => l.units > 0).toList(growable: false);

  double get totalUnits =>
      positiveLines.fold(0.0, (sum, l) => sum + l.units);

  double get totalBatches =>
      positiveLines.fold(0.0, (sum, l) => sum + l.batches);

  int indexOfItem(String itemCode) =>
      lines.indexWhere((l) => l.itemCode == itemCode);

  /// Payload shape shared by `submit_work_orders` and
  /// `get_basket_material_rollup`.
  List<Map<String, dynamic>> toApiLines({String? scheduledAt}) => [
        for (final line in positiveLines)
          {
            'item_code': line.itemCode,
            'bom_name': line.bomName,
            'item_qty': line.units,
            if (scheduledAt != null) 'scheduled_at': scheduledAt,
          }
      ];
}

/// Outcome of a "Fill the day" bulk add, so the UI can say what it skipped
/// instead of silently adding less than the board suggested.
class FillTheDayResult {
  const FillTheDayResult({
    required this.itemsAdded,
    required this.batchesAdded,
    required this.skippedNoMaterials,
    required this.cappedByMaterials,
  });

  final int itemsAdded;
  final double batchesAdded;

  /// Actionable items the warehouse cannot start at all.
  final int skippedNoMaterials;

  /// Items added at less than the suggested quantity.
  final int cappedByMaterials;

  bool get addedNothing => itemsAdded == 0;
}

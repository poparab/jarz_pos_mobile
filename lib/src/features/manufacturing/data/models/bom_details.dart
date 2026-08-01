// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bom_details.freezed.dart';
part 'bom_details.g.dart';

/// One row of `list_default_bom_items` — the manual search path, kept for
/// items the Plan tab has no suggestion for (new products, one-offs).
@freezed
class BomItemSummary with _$BomItemSummary {
  const factory BomItemSummary({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @JsonKey(name: 'default_bom') @Default('') String defaultBom,
    @JsonKey(name: 'bom_qty') @Default(1.0) double bomQty,
  }) = _BomItemSummary;

  factory BomItemSummary.fromJson(Map<String, dynamic> json) =>
      _$BomItemSummaryFromJson(json);
}

/// Payload of `get_bom_details` — one BOM and the materials it consumes.
@freezed
class BomDetails with _$BomDetails {
  const factory BomDetails({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @JsonKey(name: 'default_bom') @Default('') String defaultBom,

    /// Finished units produced by one run of this BOM.
    @JsonKey(name: 'bom_qty') @Default(1.0) double bomQty,
    @Default(<BomComponent>[]) List<BomComponent> components,
  }) = _BomDetails;

  factory BomDetails.fromJson(Map<String, dynamic> json) =>
      _$BomDetailsFromJson(json);
}

@freezed
class BomComponent with _$BomComponent {
  const factory BomComponent({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @Default('') String uom,

    /// Quantity consumed by exactly one BOM run.
    @JsonKey(name: 'qty_per_bom') @Default(0.0) double qtyPerBom,
    @JsonKey(name: 'available_qty') double? availableQty,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
  }) = _BomComponent;

  factory BomComponent.fromJson(Map<String, dynamic> json) =>
      _$BomComponentFromJson(json);

  const BomComponent._();

  double totalForBatches(double batches) => qtyPerBom * batches;
}

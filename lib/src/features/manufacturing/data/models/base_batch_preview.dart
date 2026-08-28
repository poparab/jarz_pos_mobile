// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/base_batch_math.dart';

part 'base_batch_preview.freezed.dart';
part 'base_batch_preview.g.dart';

/// Payload of `subassembly.preview_base_batch`: what one submission of N
/// batches would consume, before anybody commits to it.
@freezed
class BaseBatchPreview with _$BaseBatchPreview {
  const factory BaseBatchPreview({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'bom_name') @Default('') String bomName,
    @Default('') String company,
    @Default(0.0) double batches,
    @JsonKey(name: 'batch_yield') @Default(1.0) double batchYield,

    /// `batches * batch_yield`, computed server-side. This is what goes to
    /// `start_production_batch` — the client only recomputes it when a preview
    /// could not be fetched at all.
    @JsonKey(name: 'item_qty') @Default(0.0) double itemQty,
    @JsonKey(name: 'stock_uom') @Default('') String stockUom,
    @Default(<BasePreviewComponent>[]) List<BasePreviewComponent> components,
    @JsonKey(name: 'has_shortage') @Default(false) bool hasShortage,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,

    /// False when the chosen figure is off the mixer's published run grid.
    /// A warning, never a block.
    @JsonKey(name: 'run_size_ok') @Default(true) bool runSizeOk,
    @JsonKey(name: 'run_sizes') List<double>? runSizes,
    @JsonKey(name: 'has_sop') @Default(false) bool hasSop,
  }) = _BaseBatchPreview;

  factory BaseBatchPreview.fromJson(Map<String, dynamic> json) =>
      _$BaseBatchPreviewFromJson(json);

  const BaseBatchPreview._();

  /// The component that actually stops the run: the one furthest from covering
  /// its requirement, not merely the first short line in BOM order.
  ///
  /// Naming the worst offender is what turns a red wall into an instruction.
  BasePreviewComponent? get worstShortage {
    BasePreviewComponent? worst;
    var worstRatio = double.infinity;
    for (final component in components) {
      if (!component.isShort) continue;
      final ratio = component.requiredQty <= 0
          ? 0.0
          : component.availableQty / component.requiredQty;
      if (worst == null || ratio < worstRatio) {
        worst = component;
        worstRatio = ratio;
      }
    }
    return worst;
  }

  /// The largest half-batch run these materials can cover.
  ///
  /// Derived from the preview rather than the list endpoint's
  /// `can_make_now_batches` because that figure is whole batches, and this tab
  /// trades in halves — offering "2 batches" when 2.5 are possible sends the
  /// operator back to the mixer for a second run they did not need.
  double get achievableBatches => achievableBatchesFor(
        batches,
        [
          for (final component in components)
            (component.requiredQty, component.availableQty),
        ],
      );
}

/// One BOM line, scaled to the previewed batch count.
@freezed
class BasePreviewComponent with _$BasePreviewComponent {
  const factory BasePreviewComponent({
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    @Default('') String uom,

    /// For the whole run, not per batch.
    @JsonKey(name: 'required_qty') @Default(0.0) double requiredQty,
    @JsonKey(name: 'available_qty') @Default(0.0) double availableQty,
    @Default(0.0) double shortfall,
    @JsonKey(name: 'source_warehouse') String? sourceWarehouse,
  }) = _BasePreviewComponent;

  factory BasePreviewComponent.fromJson(Map<String, dynamic> json) =>
      _$BasePreviewComponentFromJson(json);

  const BasePreviewComponent._();

  bool get isShort => shortfall > 0;

  String get displayName => itemName.isEmpty ? itemCode : itemName;
}

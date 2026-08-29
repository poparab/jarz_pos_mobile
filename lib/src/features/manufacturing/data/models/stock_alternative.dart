// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_alternative.freezed.dart';
part 'stock_alternative.g.dart';

/// One warehouse, other than the recipe line's source, that is holding the
/// material the run is short of.
///
/// A shortage is always measured in the BOM line's own source warehouse, so an
/// item bought into the wrong store reads as "nothing in stock" and sends the
/// operator off to buy more of something the company already owns. Naming the
/// store turns that into a transfer request.
@freezed
class StockAlternative with _$StockAlternative {
  const factory StockAlternative({
    @Default('') String warehouse,
    @JsonKey(name: 'available_qty') @Default(0.0) double availableQty,
  }) = _StockAlternative;

  factory StockAlternative.fromJson(Map<String, dynamic> json) =>
      _$StockAlternativeFromJson(json);
}

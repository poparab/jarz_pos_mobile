// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sop.freezed.dart';
part 'sop.g.dart';

/// How a step's duration scales with the batch.
abstract final class SopScaling {
  static const fixed = 'Fixed';
  static const perBatch = 'Per Batch';
  static const perUnit = 'Per Unit';
}

/// What the operator must record at a step.
abstract final class SopCapture {
  static const none = 'None';
  static const number = 'Number';
  static const photo = 'Photo';
  static const temperature = 'Temperature';
}

/// Payload of `get_sop_for_item` / `get_sop_for_work_order`, already scaled
/// server-side for the requested batch count.
@freezed
class SopDocument with _$SopDocument {
  const factory SopDocument({
    @JsonKey(name: 'has_sop') @Default(false) bool hasSop,

    /// SOP document name. Empty when [hasSop] is false — most items have none,
    /// and that is a normal answer rather than an error.
    @Default('') String sop,
    @Default(1) int version,
    @JsonKey(name: 'item_code') @Default('') String itemCode,
    @JsonKey(name: 'item_name') @Default('') String itemName,
    String? bom,
    @JsonKey(name: 'yield_percent') @Default(100.0) double yieldPercent,
    @JsonKey(name: 'prep_time_mins') @Default(0) int prepTimeMins,
    String? equipment,
    @Default(1.0) double batches,
    @Default(0.0) double units,
    @JsonKey(name: 'total_duration_mins') @Default(0.0) double totalDurationMins,
    @Default(<SopStep>[]) List<SopStep> steps,

    /// Tokens the server could not resolve, e.g. a misspelled item code. Shown
    /// prominently rather than swallowed — a broken token in an instruction is
    /// otherwise invisible until somebody makes the wrong thing.
    @JsonKey(name: 'unresolved_tokens')
    @Default(<String>[])
    List<String> unresolvedTokens,
  }) = _SopDocument;

  factory SopDocument.fromJson(Map<String, dynamic> json) =>
      _$SopDocumentFromJson(json);

  const SopDocument._();

  bool get isEmpty => !hasSop || steps.isEmpty;
  bool get hasUnresolvedTokens => unresolvedTokens.isNotEmpty;

  /// "SOP-0001#2" — the exact string stamped on a Work Order at start.
  String get versionTag => sop.isEmpty ? '' : '$sop#$version';
}

@freezed
class SopStep with _$SopStep {
  const factory SopStep({
    @JsonKey(name: 'step_no') @Default(0) int stepNo,
    @Default('') String title,

    /// Plain text with `{{item:CODE}}` tokens already substituted at the
    /// requested batch count. Rendered instead of the HTML so the app needs no
    /// HTML package.
    @JsonKey(name: 'instruction_text') @Default('') String instructionText,
    @JsonKey(name: 'instruction_html') @Default('') String instructionHtml,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'duration_mins') @Default(0.0) double durationMins,
    @JsonKey(name: 'scaling_mode') @Default(SopScaling.fixed) String scalingMode,
    @JsonKey(name: 'requires_confirmation') @Default(true) bool requiresConfirmation,
    @JsonKey(name: 'capture_type') @Default(SopCapture.none) String captureType,
    @JsonKey(name: 'capture_label') String? captureLabel,
    @JsonKey(name: 'capture_min') double? captureMin,
    @JsonKey(name: 'capture_max') double? captureMax,
  }) = _SopStep;

  factory SopStep.fromJson(Map<String, dynamic> json) =>
      _$SopStepFromJson(json);

  const SopStep._();

  bool get needsCapture => captureType != SopCapture.none;
  bool get isPhotoCapture => captureType == SopCapture.photo;
  bool get isNumericCapture =>
      captureType == SopCapture.number || captureType == SopCapture.temperature;

  /// Whether [value] falls inside the configured range.
  bool isInRange(double value) {
    if (captureMin != null && value < captureMin!) return false;
    if (captureMax != null && value > captureMax!) return false;
    return true;
  }

  /// A step cannot be left until it is confirmed and its capture recorded.
  bool isSatisfied({required bool confirmed, required bool captured}) {
    if (requiresConfirmation && !confirmed) return false;
    if (needsCapture && !captured) return false;
    return true;
  }
}

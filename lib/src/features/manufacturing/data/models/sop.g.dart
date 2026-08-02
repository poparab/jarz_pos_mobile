// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SopDocumentImpl _$$SopDocumentImplFromJson(Map<String, dynamic> json) =>
    _$SopDocumentImpl(
      hasSop: json['has_sop'] as bool? ?? false,
      sop: json['sop'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      bom: json['bom'] as String?,
      yieldPercent: (json['yield_percent'] as num?)?.toDouble() ?? 100.0,
      prepTimeMins: (json['prep_time_mins'] as num?)?.toInt() ?? 0,
      equipment: json['equipment'] as String?,
      batches: (json['batches'] as num?)?.toDouble() ?? 1.0,
      units: (json['units'] as num?)?.toDouble() ?? 0.0,
      totalDurationMins:
          (json['total_duration_mins'] as num?)?.toDouble() ?? 0.0,
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => SopStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SopStep>[],
      unresolvedTokens:
          (json['unresolved_tokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$SopDocumentImplToJson(_$SopDocumentImpl instance) =>
    <String, dynamic>{
      'has_sop': instance.hasSop,
      'sop': instance.sop,
      'version': instance.version,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'bom': instance.bom,
      'yield_percent': instance.yieldPercent,
      'prep_time_mins': instance.prepTimeMins,
      'equipment': instance.equipment,
      'batches': instance.batches,
      'units': instance.units,
      'total_duration_mins': instance.totalDurationMins,
      'steps': instance.steps,
      'unresolved_tokens': instance.unresolvedTokens,
    };

_$SopStepImpl _$$SopStepImplFromJson(Map<String, dynamic> json) =>
    _$SopStepImpl(
      stepNo: (json['step_no'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      instructionText: json['instruction_text'] as String? ?? '',
      instructionHtml: json['instruction_html'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      durationMins: (json['duration_mins'] as num?)?.toDouble() ?? 0.0,
      scalingMode: json['scaling_mode'] as String? ?? SopScaling.fixed,
      requiresConfirmation: json['requires_confirmation'] as bool? ?? true,
      captureType: json['capture_type'] as String? ?? SopCapture.none,
      captureLabel: json['capture_label'] as String?,
      captureMin: (json['capture_min'] as num?)?.toDouble(),
      captureMax: (json['capture_max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SopStepImplToJson(_$SopStepImpl instance) =>
    <String, dynamic>{
      'step_no': instance.stepNo,
      'title': instance.title,
      'instruction_text': instance.instructionText,
      'instruction_html': instance.instructionHtml,
      'image_url': instance.imageUrl,
      'duration_mins': instance.durationMins,
      'scaling_mode': instance.scalingMode,
      'requires_confirmation': instance.requiresConfirmation,
      'capture_type': instance.captureType,
      'capture_label': instance.captureLabel,
      'capture_min': instance.captureMin,
      'capture_max': instance.captureMax,
    };

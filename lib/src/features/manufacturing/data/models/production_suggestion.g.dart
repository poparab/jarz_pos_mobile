// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductionSuggestionsPageImpl _$$ProductionSuggestionsPageImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionSuggestionsPageImpl(
  generatedOn: json['generated_on'] as String?,
  company: json['company'] as String? ?? '',
  season: json['season'] == null
      ? const ProductionSeason()
      : ProductionSeason.fromJson(json['season'] as Map<String, dynamic>),
  defaultTargetDays: (json['default_target_days'] as num?)?.toInt() ?? 7,
  thresholds: json['thresholds'] == null
      ? const ProductionThresholds()
      : ProductionThresholds.fromJson(
          json['thresholds'] as Map<String, dynamic>,
        ),
  velocityUpdatedOn: json['velocity_updated_on'] as String?,
  capacityIncluded: json['capacity_included'] as bool? ?? true,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ProductionSuggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProductionSuggestion>[],
  summary: json['summary'] == null
      ? const ProductionSummary()
      : ProductionSummary.fromJson(json['summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProductionSuggestionsPageImplToJson(
  _$ProductionSuggestionsPageImpl instance,
) => <String, dynamic>{
  'generated_on': instance.generatedOn,
  'company': instance.company,
  'season': instance.season,
  'default_target_days': instance.defaultTargetDays,
  'thresholds': instance.thresholds,
  'velocity_updated_on': instance.velocityUpdatedOn,
  'capacity_included': instance.capacityIncluded,
  'items': instance.items,
  'summary': instance.summary,
};

_$ProductionSeasonImpl _$$ProductionSeasonImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionSeasonImpl(
  name: json['name'] as String?,
  multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$$ProductionSeasonImplToJson(
  _$ProductionSeasonImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'multiplier': instance.multiplier,
};

_$ProductionThresholdsImpl _$$ProductionThresholdsImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionThresholdsImpl(
  criticalDays: (json['critical_days'] as num?)?.toInt() ?? 5,
  watchDays: (json['watch_days'] as num?)?.toInt() ?? 14,
  overstockDays: (json['overstock_days'] as num?)?.toInt() ?? 90,
);

Map<String, dynamic> _$$ProductionThresholdsImplToJson(
  _$ProductionThresholdsImpl instance,
) => <String, dynamic>{
  'critical_days': instance.criticalDays,
  'watch_days': instance.watchDays,
  'overstock_days': instance.overstockDays,
};

_$ProductionSummaryImpl _$$ProductionSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionSummaryImpl(
  critical: (json['critical'] as num?)?.toInt() ?? 0,
  low: (json['low'] as num?)?.toInt() ?? 0,
  ok: (json['ok'] as num?)?.toInt() ?? 0,
  overstocked: (json['overstocked'] as num?)?.toInt() ?? 0,
  noVelocity: (json['no_velocity'] as num?)?.toInt() ?? 0,
  totalSuggestedBatches:
      (json['total_suggested_batches'] as num?)?.toInt() ?? 0,
  cappedByMaterials: (json['capped_by_materials'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ProductionSummaryImplToJson(
  _$ProductionSummaryImpl instance,
) => <String, dynamic>{
  'critical': instance.critical,
  'low': instance.low,
  'ok': instance.ok,
  'overstocked': instance.overstocked,
  'no_velocity': instance.noVelocity,
  'total_suggested_batches': instance.totalSuggestedBatches,
  'capped_by_materials': instance.cappedByMaterials,
};

_$ProductionSuggestionImpl _$$ProductionSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionSuggestionImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  itemGroup: json['item_group'] as String?,
  stockUom: json['stock_uom'] as String? ?? '',
  defaultBom: json['default_bom'] as String? ?? '',
  bomQty: (json['bom_qty'] as num?)?.toDouble() ?? 1.0,
  company: json['company'] as String?,
  onHand: (json['on_hand'] as num?)?.toDouble() ?? 0.0,
  velocity30d: (json['velocity_30d'] as num?)?.toDouble() ?? 0.0,
  velocity60d: (json['velocity_60d'] as num?)?.toDouble() ?? 0.0,
  velocityTrend: json['velocity_trend'] as String?,
  seasonMultiplier: (json['season_multiplier'] as num?)?.toDouble() ?? 1.0,
  effectiveVelocity: (json['effective_velocity'] as num?)?.toDouble() ?? 0.0,
  targetDays: (json['target_days'] as num?)?.toInt() ?? 7,
  targetDaysSource: json['target_days_source'] as String? ?? 'default',
  daysOfCover: (json['days_of_cover'] as num?)?.toDouble(),
  status: json['status'] as String? ?? ProductionStatus.ok,
  stockIsNegative: json['stock_is_negative'] as bool? ?? false,
  suggestedBatches: (json['suggested_batches'] as num?)?.toInt() ?? 0,
  suggestedUnits: (json['suggested_units'] as num?)?.toDouble() ?? 0.0,
  canMakeNowBatches: (json['can_make_now_batches'] as num?)?.toInt(),
  limitingComponent: json['limiting_component'] == null
      ? null
      : LimitingComponent.fromJson(
          json['limiting_component'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$ProductionSuggestionImplToJson(
  _$ProductionSuggestionImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'item_group': instance.itemGroup,
  'stock_uom': instance.stockUom,
  'default_bom': instance.defaultBom,
  'bom_qty': instance.bomQty,
  'company': instance.company,
  'on_hand': instance.onHand,
  'velocity_30d': instance.velocity30d,
  'velocity_60d': instance.velocity60d,
  'velocity_trend': instance.velocityTrend,
  'season_multiplier': instance.seasonMultiplier,
  'effective_velocity': instance.effectiveVelocity,
  'target_days': instance.targetDays,
  'target_days_source': instance.targetDaysSource,
  'days_of_cover': instance.daysOfCover,
  'status': instance.status,
  'stock_is_negative': instance.stockIsNegative,
  'suggested_batches': instance.suggestedBatches,
  'suggested_units': instance.suggestedUnits,
  'can_make_now_batches': instance.canMakeNowBatches,
  'limiting_component': instance.limitingComponent,
};

_$LimitingComponentImpl _$$LimitingComponentImplFromJson(
  Map<String, dynamic> json,
) => _$LimitingComponentImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  uom: json['uom'] as String? ?? '',
  sourceWarehouse: json['source_warehouse'] as String?,
  requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0.0,
  availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0.0,
  reason: json['reason'] as String? ?? 'insufficient_stock',
  availableElsewhere: (json['available_elsewhere'] as num?)?.toDouble(),
  alternatives: (json['alternatives'] as List<dynamic>?)
      ?.map((e) => StockAlternative.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$LimitingComponentImplToJson(
  _$LimitingComponentImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'uom': instance.uom,
  'source_warehouse': instance.sourceWarehouse,
  'required_qty': instance.requiredQty,
  'available_qty': instance.availableQty,
  'reason': instance.reason,
  'available_elsewhere': instance.availableElsewhere,
  'alternatives': instance.alternatives,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaseItemsPageImpl _$$BaseItemsPageImplFromJson(Map<String, dynamic> json) =>
    _$BaseItemsPageImpl(
      company: json['company'] as String? ?? '',
      generatedOn: json['generated_on'] as String?,
      demandSource: json['demand_source'] as String? ?? BaseDemandSource.none,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => BaseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BaseItem>[],
      summary: json['summary'] == null
          ? const BaseItemsSummary()
          : BaseItemsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      coverIncluded: json['cover_included'] as bool? ?? false,
      season: json['season'] == null
          ? const ProductionSeason()
          : ProductionSeason.fromJson(json['season'] as Map<String, dynamic>),
      defaultTargetDays: (json['default_target_days'] as num?)?.toInt() ?? 7,
      thresholds: json['thresholds'] == null
          ? const ProductionThresholds()
          : ProductionThresholds.fromJson(
              json['thresholds'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$BaseItemsPageImplToJson(_$BaseItemsPageImpl instance) =>
    <String, dynamic>{
      'company': instance.company,
      'generated_on': instance.generatedOn,
      'demand_source': instance.demandSource,
      'items': instance.items,
      'summary': instance.summary,
      'cover_included': instance.coverIncluded,
      'season': instance.season,
      'default_target_days': instance.defaultTargetDays,
      'thresholds': instance.thresholds,
    };

_$BaseItemsSummaryImpl _$$BaseItemsSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$BaseItemsSummaryImpl(
  total: (json['total'] as num?)?.toInt() ?? 0,
  shortOfDemand: (json['short_of_demand'] as num?)?.toInt() ?? 0,
  blockedByMaterials: (json['blocked_by_materials'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$BaseItemsSummaryImplToJson(
  _$BaseItemsSummaryImpl instance,
) => <String, dynamic>{
  'total': instance.total,
  'short_of_demand': instance.shortOfDemand,
  'blocked_by_materials': instance.blockedByMaterials,
};

_$BaseItemImpl _$$BaseItemImplFromJson(Map<String, dynamic> json) =>
    _$BaseItemImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      itemGroup: json['item_group'] as String?,
      stockUom: json['stock_uom'] as String? ?? '',
      defaultBom: json['default_bom'] as String? ?? '',
      batchYield: (json['batch_yield'] as num?)?.toDouble() ?? 1.0,
      onHand: (json['on_hand'] as num?)?.toDouble() ?? 0.0,
      stockIsNegative: json['stock_is_negative'] as bool? ?? false,
      batchesOnHand: (json['batches_on_hand'] as num?)?.toDouble() ?? 0.0,
      canMakeNowBatches: (json['can_make_now_batches'] as num?)?.toInt(),
      limitingComponent: json['limiting_component'] == null
          ? null
          : BaseLimitingComponent.fromJson(
              json['limiting_component'] as Map<String, dynamic>,
            ),
      runSizes: (json['run_sizes'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      entryMode: json['entry_mode'] as String? ?? kBaseEntryBatch,
      batchUnit: json['batch_unit'] == null
          ? null
          : BaseBatchUnit.fromJson(json['batch_unit'] as Map<String, dynamic>),
      jarConsumers:
          (json['jar_consumers'] as List<dynamic>?)
              ?.map((e) => BaseJarConsumer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BaseJarConsumer>[],
      hasSop: json['has_sop'] as bool? ?? false,
      sopTotalDurationMins: (json['sop_total_duration_mins'] as num?)
          ?.toDouble(),
      demand: json['demand'] == null
          ? null
          : BaseDemand.fromJson(json['demand'] as Map<String, dynamic>),
      consumptionPerDay: (json['consumption_per_day'] as num?)?.toDouble(),
      daysOfCover: (json['days_of_cover'] as num?)?.toDouble(),
      targetDays: (json['target_days'] as num?)?.toInt() ?? 7,
      targetDaysSource: json['target_days_source'] as String? ?? 'default',
      status: json['status'] as String?,
      suggestedQty: (json['suggested_qty'] as num?)?.toDouble() ?? 0.0,
      suggestedBatches: (json['suggested_batches'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BaseItemImplToJson(_$BaseItemImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'item_group': instance.itemGroup,
      'stock_uom': instance.stockUom,
      'default_bom': instance.defaultBom,
      'batch_yield': instance.batchYield,
      'on_hand': instance.onHand,
      'stock_is_negative': instance.stockIsNegative,
      'batches_on_hand': instance.batchesOnHand,
      'can_make_now_batches': instance.canMakeNowBatches,
      'limiting_component': instance.limitingComponent,
      'run_sizes': instance.runSizes,
      'entry_mode': instance.entryMode,
      'batch_unit': instance.batchUnit,
      'jar_consumers': instance.jarConsumers,
      'has_sop': instance.hasSop,
      'sop_total_duration_mins': instance.sopTotalDurationMins,
      'demand': instance.demand,
      'consumption_per_day': instance.consumptionPerDay,
      'days_of_cover': instance.daysOfCover,
      'target_days': instance.targetDays,
      'target_days_source': instance.targetDaysSource,
      'status': instance.status,
      'suggested_qty': instance.suggestedQty,
      'suggested_batches': instance.suggestedBatches,
    };

_$BaseBatchUnitImpl _$$BaseBatchUnitImplFromJson(Map<String, dynamic> json) =>
    _$BaseBatchUnitImpl(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      uom: json['uom'] as String? ?? '',
      qtyPerBatch: (json['qty_per_batch'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$BaseBatchUnitImplToJson(_$BaseBatchUnitImpl instance) =>
    <String, dynamic>{
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'uom': instance.uom,
      'qty_per_batch': instance.qtyPerBatch,
    };

_$BaseJarConsumerImpl _$$BaseJarConsumerImplFromJson(
  Map<String, dynamic> json,
) => _$BaseJarConsumerImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  qtyPerJar: (json['qty_per_jar'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$BaseJarConsumerImplToJson(
  _$BaseJarConsumerImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'qty_per_jar': instance.qtyPerJar,
};

_$BaseDemandImpl _$$BaseDemandImplFromJson(Map<String, dynamic> json) =>
    _$BaseDemandImpl(
      qtyRequired: (json['qty_required'] as num?)?.toDouble() ?? 0.0,
      batchesRequired: (json['batches_required'] as num?)?.toDouble() ?? 0.0,
      shortfallBatches: (json['shortfall_batches'] as num?)?.toDouble() ?? 0.0,
      driver: json['driver'] as String? ?? '',
    );

Map<String, dynamic> _$$BaseDemandImplToJson(_$BaseDemandImpl instance) =>
    <String, dynamic>{
      'qty_required': instance.qtyRequired,
      'batches_required': instance.batchesRequired,
      'shortfall_batches': instance.shortfallBatches,
      'driver': instance.driver,
    };

_$BaseLimitingComponentImpl _$$BaseLimitingComponentImplFromJson(
  Map<String, dynamic> json,
) => _$BaseLimitingComponentImpl(
  itemCode: json['item_code'] as String? ?? '',
  itemName: json['item_name'] as String? ?? '',
  availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0.0,
  requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0.0,
  isMissingWarehouse: json['is_missing_warehouse'] as bool? ?? false,
  availableElsewhere: (json['available_elsewhere'] as num?)?.toDouble(),
  alternatives: (json['alternatives'] as List<dynamic>?)
      ?.map((e) => StockAlternative.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$BaseLimitingComponentImplToJson(
  _$BaseLimitingComponentImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'available_qty': instance.availableQty,
  'required_qty': instance.requiredQty,
  'is_missing_warehouse': instance.isMissingWarehouse,
  'available_elsewhere': instance.availableElsewhere,
  'alternatives': instance.alternatives,
};

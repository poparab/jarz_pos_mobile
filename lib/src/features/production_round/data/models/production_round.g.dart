// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductionRoundItemBranchImpl _$$ProductionRoundItemBranchImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundItemBranchImpl(
  warehouse: json['warehouse'] == null ? '' : _readString(json['warehouse']),
  label: json['label'] == null ? '' : _readString(json['label']),
  weeklySales: json['weekly_sales'] == null
      ? 0.0
      : _readNum(json['weekly_sales']),
  par: json['par'] == null ? 0.0 : _readNum(json['par']),
  onHand: json['on_hand'] == null ? 0.0 : _readNum(json['on_hand']),
  fill: json['fill'] == null ? 0.0 : _readNum(json['fill']),
  daysOfCover: _readNumOrNull(json['days_of_cover']),
  belowBackup: json['below_backup'] == null
      ? false
      : _readFlag(json['below_backup']),
  stockIsNegative: json['stock_is_negative'] == null
      ? false
      : _readFlag(json['stock_is_negative']),
);

Map<String, dynamic> _$$ProductionRoundItemBranchImplToJson(
  _$ProductionRoundItemBranchImpl instance,
) => <String, dynamic>{
  'warehouse': instance.warehouse,
  'label': instance.label,
  'weekly_sales': instance.weeklySales,
  'par': instance.par,
  'on_hand': instance.onHand,
  'fill': instance.fill,
  'days_of_cover': instance.daysOfCover,
  'below_backup': instance.belowBackup,
  'stock_is_negative': instance.stockIsNegative,
};

_$ProductionRoundItemImpl _$$ProductionRoundItemImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundItemImpl(
  itemCode: json['item_code'] == null ? '' : _readString(json['item_code']),
  itemName: json['item_name'] == null ? '' : _readString(json['item_name']),
  flavour: json['flavour'] == null ? '' : _readString(json['flavour']),
  size: json['size'] == null ? '' : _readString(json['size']),
  batchSize: json['batch_size'] == null ? 0.0 : _readNum(json['batch_size']),
  weeklySales: json['weekly_sales'] == null
      ? 0.0
      : _readNum(json['weekly_sales']),
  factoryOnHand: json['factory_on_hand'] == null
      ? 0.0
      : _readNum(json['factory_on_hand']),
  totalFill: json['total_fill'] == null ? 0.0 : _readNum(json['total_fill']),
  netNeed: json['net_need'] == null ? 0.0 : _readNum(json['net_need']),
  batches: json['batches'] == null ? 0.0 : _readNum(json['batches']),
  jars: json['jars'] == null ? 0.0 : _readNum(json['jars']),
  rawStatus: json['status'] == null ? 'covered' : _readString(json['status']),
  blockedBy: json['blocked_by'] == null
      ? const <String>[]
      : _readStringList(json['blocked_by']),
  branches: json['branches'] == null
      ? const <ProductionRoundItemBranch>[]
      : _readItemBranches(json['branches']),
);

Map<String, dynamic> _$$ProductionRoundItemImplToJson(
  _$ProductionRoundItemImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'flavour': instance.flavour,
  'size': instance.size,
  'batch_size': instance.batchSize,
  'weekly_sales': instance.weeklySales,
  'factory_on_hand': instance.factoryOnHand,
  'total_fill': instance.totalFill,
  'net_need': instance.netNeed,
  'batches': instance.batches,
  'jars': instance.jars,
  'status': instance.rawStatus,
  'blocked_by': instance.blockedBy,
  'branches': instance.branches,
};

_$ProductionRoundPrepImpl _$$ProductionRoundPrepImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundPrepImpl(
  itemCode: json['item_code'] == null ? '' : _readString(json['item_code']),
  itemName: json['item_name'] == null ? '' : _readString(json['item_name']),
  uom: json['uom'] == null ? '' : _readString(json['uom']),
  required: json['required'] == null ? 0.0 : _readNum(json['required']),
  onHand: json['on_hand'] == null ? 0.0 : _readNum(json['on_hand']),
  toMake: json['to_make'] == null ? 0.0 : _readNum(json['to_make']),
  batchYield: json['batch_yield'] == null ? 0.0 : _readNum(json['batch_yield']),
  batches: json['batches'] == null ? 0.0 : _readNum(json['batches']),
  madeFresh: json['made_fresh'] == null ? false : _readFlag(json['made_fresh']),
);

Map<String, dynamic> _$$ProductionRoundPrepImplToJson(
  _$ProductionRoundPrepImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'uom': instance.uom,
  'required': instance.required,
  'on_hand': instance.onHand,
  'to_make': instance.toMake,
  'batch_yield': instance.batchYield,
  'batches': instance.batches,
  'made_fresh': instance.madeFresh,
};

_$ProductionRoundMaterialImpl _$$ProductionRoundMaterialImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundMaterialImpl(
  itemCode: json['item_code'] == null ? '' : _readString(json['item_code']),
  itemName: json['item_name'] == null ? '' : _readString(json['item_name']),
  itemGroup: json['item_group'] == null ? '' : _readString(json['item_group']),
  uom: json['uom'] == null ? '' : _readString(json['uom']),
  required: json['required'] == null ? 0.0 : _readNum(json['required']),
  onHand: json['on_hand'] == null ? 0.0 : _readNum(json['on_hand']),
  alternativeOnHand: json['alternative_on_hand'] == null
      ? 0.0
      : _readNum(json['alternative_on_hand']),
  missing: json['missing'] == null ? 0.0 : _readNum(json['missing']),
  usedBy: json['used_by'] == null
      ? const <String>[]
      : _readStringList(json['used_by']),
);

Map<String, dynamic> _$$ProductionRoundMaterialImplToJson(
  _$ProductionRoundMaterialImpl instance,
) => <String, dynamic>{
  'item_code': instance.itemCode,
  'item_name': instance.itemName,
  'item_group': instance.itemGroup,
  'uom': instance.uom,
  'required': instance.required,
  'on_hand': instance.onHand,
  'alternative_on_hand': instance.alternativeOnHand,
  'missing': instance.missing,
  'used_by': instance.usedBy,
};

_$ProductionRoundBranchImpl _$$ProductionRoundBranchImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundBranchImpl(
  warehouse: json['warehouse'] == null ? '' : _readString(json['warehouse']),
  label: json['label'] == null ? '' : _readString(json['label']),
  weeklySales: json['weekly_sales'] == null
      ? 0.0
      : _readNum(json['weekly_sales']),
  parTotal: json['par_total'] == null ? 0.0 : _readNum(json['par_total']),
  onHandTotal: json['on_hand_total'] == null
      ? 0.0
      : _readNum(json['on_hand_total']),
  fillTotal: json['fill_total'] == null ? 0.0 : _readNum(json['fill_total']),
  belowBackupCount: json['below_backup_count'] == null
      ? 0
      : _readInt(json['below_backup_count']),
);

Map<String, dynamic> _$$ProductionRoundBranchImplToJson(
  _$ProductionRoundBranchImpl instance,
) => <String, dynamic>{
  'warehouse': instance.warehouse,
  'label': instance.label,
  'weekly_sales': instance.weeklySales,
  'par_total': instance.parTotal,
  'on_hand_total': instance.onHandTotal,
  'fill_total': instance.fillTotal,
  'below_backup_count': instance.belowBackupCount,
};

_$ProductionRoundSummaryImpl _$$ProductionRoundSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundSummaryImpl(
  batches: json['batches'] == null
      ? const <String, double>{}
      : _readNumMap(json['batches']),
  jars: json['jars'] == null
      ? const <String, double>{}
      : _readNumMap(json['jars']),
  jarsTotal: json['jars_total'] == null ? 0.0 : _readNum(json['jars_total']),
  itemsToMake: json['items_to_make'] == null
      ? 0
      : _readInt(json['items_to_make']),
  neededNowCount: json['needed_now_count'] == null
      ? 0
      : _readInt(json['needed_now_count']),
  missingCount: json['missing_count'] == null
      ? 0
      : _readInt(json['missing_count']),
  blockedCount: json['blocked_count'] == null
      ? 0
      : _readInt(json['blocked_count']),
);

Map<String, dynamic> _$$ProductionRoundSummaryImplToJson(
  _$ProductionRoundSummaryImpl instance,
) => <String, dynamic>{
  'batches': instance.batches,
  'jars': instance.jars,
  'jars_total': instance.jarsTotal,
  'items_to_make': instance.itemsToMake,
  'needed_now_count': instance.neededNowCount,
  'missing_count': instance.missingCount,
  'blocked_count': instance.blockedCount,
};

_$ProductionRoundImpl _$$ProductionRoundImplFromJson(
  Map<String, dynamic> json,
) => _$ProductionRoundImpl(
  generatedOn: json['generated_on'] == null
      ? ''
      : _readString(json['generated_on']),
  company: json['company'] == null ? '' : _readString(json['company']),
  sourceWarehouse: json['source_warehouse'] == null
      ? ''
      : _readString(json['source_warehouse']),
  cycleDays: json['cycle_days'] == null ? 0 : _readInt(json['cycle_days']),
  backupDays: json['backup_days'] == null ? 0 : _readInt(json['backup_days']),
  coverDays: json['cover_days'] == null ? 0 : _readInt(json['cover_days']),
  salesWeeks: json['sales_weeks'] == null ? 0 : _readInt(json['sales_weeks']),
  salesFrom: json['sales_from'] == null ? '' : _readString(json['sales_from']),
  salesTo: json['sales_to'] == null ? '' : _readString(json['sales_to']),
  batchSizes: json['batch_sizes'] == null
      ? const <String, double>{}
      : _readNumMap(json['batch_sizes']),
  summary: json['summary'] == null
      ? const ProductionRoundSummary()
      : ProductionRoundSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  branches: json['branches'] == null
      ? const <ProductionRoundBranch>[]
      : _readBranches(json['branches']),
  items: json['items'] == null
      ? const <ProductionRoundItem>[]
      : _readItems(json['items']),
  prep: json['prep'] == null
      ? const <ProductionRoundPrep>[]
      : _readPrep(json['prep']),
  materials: json['materials'] == null
      ? const <ProductionRoundMaterial>[]
      : _readMaterials(json['materials']),
  notices: json['notices'] == null
      ? const <String>[]
      : _readStringList(json['notices']),
);

Map<String, dynamic> _$$ProductionRoundImplToJson(
  _$ProductionRoundImpl instance,
) => <String, dynamic>{
  'generated_on': instance.generatedOn,
  'company': instance.company,
  'source_warehouse': instance.sourceWarehouse,
  'cycle_days': instance.cycleDays,
  'backup_days': instance.backupDays,
  'cover_days': instance.coverDays,
  'sales_weeks': instance.salesWeeks,
  'sales_from': instance.salesFrom,
  'sales_to': instance.salesTo,
  'batch_sizes': instance.batchSizes,
  'summary': instance.summary,
  'branches': instance.branches,
  'items': instance.items,
  'prep': instance.prep,
  'materials': instance.materials,
  'notices': instance.notices,
};

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'production_round.freezed.dart';
part 'production_round.g.dart';

/// Why an item is (or is not) on this round's list.
enum ProductionRoundStatus {
  /// At least one branch is already below its backup days — make it first.
  now,

  /// Below the round target, but nobody is at risk yet.
  round,

  /// Branches plus the factory already hold the whole target.
  covered,

  /// No branch sold it in the sales window, so there is no rate to plan by.
  noSales;

  static ProductionRoundStatus parse(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'now':
        return ProductionRoundStatus.now;
      case 'round':
        return ProductionRoundStatus.round;
      case 'no_sales':
        return ProductionRoundStatus.noSales;
      default:
        return ProductionRoundStatus.covered;
    }
  }
}

/// One branch's share of one jar.
@freezed
class ProductionRoundItemBranch with _$ProductionRoundItemBranch {
  const factory ProductionRoundItemBranch({
    @JsonKey(fromJson: _readString) @Default('') String warehouse,
    @JsonKey(fromJson: _readString) @Default('') String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum)
    @Default(0.0)
    double weeklySales,

    /// The branch's target holding: its weekly rate over the full cover.
    @JsonKey(fromJson: _readNum) @Default(0.0) double par,
    @JsonKey(name: 'on_hand', fromJson: _readNum) @Default(0.0) double onHand,
    @JsonKey(fromJson: _readNum) @Default(0.0) double fill,

    /// Null when the branch never sold the item — distinct from zero, which
    /// means "sells, and has run out".
    @JsonKey(name: 'days_of_cover', fromJson: _readNumOrNull)
    double? daysOfCover,
    @JsonKey(name: 'below_backup', fromJson: _readFlag)
    @Default(false)
    bool belowBackup,
    @JsonKey(name: 'stock_is_negative', fromJson: _readFlag)
    @Default(false)
    bool stockIsNegative,
  }) = _ProductionRoundItemBranch;

  factory ProductionRoundItemBranch.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundItemBranchFromJson(json);

  const ProductionRoundItemBranch._();

  String get displayName => label.trim().isEmpty ? warehouse : label;
}

/// One jar (flavour × size) and how much of it this round should make.
@freezed
class ProductionRoundItem with _$ProductionRoundItem {
  const factory ProductionRoundItem({
    @JsonKey(name: 'item_code', fromJson: _readString)
    @Default('')
    String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString)
    @Default('')
    String itemName,
    @JsonKey(fromJson: _readString) @Default('') String flavour,
    @JsonKey(fromJson: _readString) @Default('') String size,
    @JsonKey(name: 'batch_size', fromJson: _readNum)
    @Default(0.0)
    double batchSize,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum)
    @Default(0.0)
    double weeklySales,
    @JsonKey(name: 'factory_on_hand', fromJson: _readNum)
    @Default(0.0)
    double factoryOnHand,
    @JsonKey(name: 'total_fill', fromJson: _readNum)
    @Default(0.0)
    double totalFill,
    @JsonKey(name: 'net_need', fromJson: _readNum) @Default(0.0) double netNeed,
    @JsonKey(fromJson: _readNum) @Default(0.0) double batches,
    @JsonKey(fromJson: _readNum) @Default(0.0) double jars,
    @JsonKey(name: 'status', fromJson: _readString)
    @Default('covered')
    String rawStatus,

    /// Missing material item codes this jar consumes.
    @JsonKey(name: 'blocked_by', fromJson: _readStringList)
    @Default(<String>[])
    List<String> blockedBy,
    @JsonKey(fromJson: _readItemBranches)
    @Default(<ProductionRoundItemBranch>[])
    List<ProductionRoundItemBranch> branches,
  }) = _ProductionRoundItem;

  factory ProductionRoundItem.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundItemFromJson(json);

  const ProductionRoundItem._();

  ProductionRoundStatus get status => ProductionRoundStatus.parse(rawStatus);

  bool get isToMake => batches > 0;

  bool get isBlocked => blockedBy.isNotEmpty;

  /// The row title inside a size section: the flavour alone reads cleaner
  /// than "Blueberry Large" under a "Large" heading.
  String get displayName {
    if (flavour.trim().isNotEmpty) return flavour.trim();
    if (itemName.trim().isNotEmpty) return itemName.trim();
    return itemCode;
  }

  String get fullName => itemName.trim().isEmpty ? itemCode : itemName.trim();
}

/// A sub-assembly (base, mix) that has to exist before the jars can be made.
@freezed
class ProductionRoundPrep with _$ProductionRoundPrep {
  const factory ProductionRoundPrep({
    @JsonKey(name: 'item_code', fromJson: _readString)
    @Default('')
    String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString)
    @Default('')
    String itemName,
    @JsonKey(fromJson: _readString) @Default('') String uom,
    @JsonKey(fromJson: _readNum) @Default(0.0) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) @Default(0.0) double onHand,
    @JsonKey(name: 'to_make', fromJson: _readNum) @Default(0.0) double toMake,
    @JsonKey(name: 'batch_yield', fromJson: _readNum)
    @Default(0.0)
    double batchYield,
    @JsonKey(fromJson: _readNum) @Default(0.0) double batches,

    /// A phantom mix: never stored, made fresh inside the jar batch.
    @JsonKey(name: 'made_fresh', fromJson: _readFlag)
    @Default(false)
    bool madeFresh,
  }) = _ProductionRoundPrep;

  factory ProductionRoundPrep.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundPrepFromJson(json);

  const ProductionRoundPrep._();

  bool get isToDo => toMake > 0 || madeFresh;

  String get displayName => itemName.trim().isEmpty ? itemCode : itemName;
}

/// A raw material, packaging or label the round consumes.
@freezed
class ProductionRoundMaterial with _$ProductionRoundMaterial {
  const factory ProductionRoundMaterial({
    @JsonKey(name: 'item_code', fromJson: _readString)
    @Default('')
    String itemCode,
    @JsonKey(name: 'item_name', fromJson: _readString)
    @Default('')
    String itemName,
    @JsonKey(name: 'item_group', fromJson: _readString)
    @Default('')
    String itemGroup,
    @JsonKey(fromJson: _readString) @Default('') String uom,
    @JsonKey(fromJson: _readNum) @Default(0.0) double required,
    @JsonKey(name: 'on_hand', fromJson: _readNum) @Default(0.0) double onHand,
    @JsonKey(name: 'alternative_on_hand', fromJson: _readNum)
    @Default(0.0)
    double alternativeOnHand,
    @JsonKey(fromJson: _readNum) @Default(0.0) double missing,
    @JsonKey(name: 'used_by', fromJson: _readStringList)
    @Default(<String>[])
    List<String> usedBy,
  }) = _ProductionRoundMaterial;

  factory ProductionRoundMaterial.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundMaterialFromJson(json);

  const ProductionRoundMaterial._();

  bool get isMissing => missing > 0;

  String get displayName => itemName.trim().isEmpty ? itemCode : itemName;

  /// How much of the need is covered, 0..1 — own stock plus what an
  /// alternative lends, so a row with nothing missing never reads short.
  double get coverage {
    if (this.required <= 0 || missing <= 0) return 1;
    final have = (onHand < 0 ? 0 : onHand) + alternativeOnHand;
    return (have / this.required).clamp(0.0, 1.0).toDouble();
  }
}

/// One selling branch, summed over every jar.
@freezed
class ProductionRoundBranch with _$ProductionRoundBranch {
  const factory ProductionRoundBranch({
    @JsonKey(fromJson: _readString) @Default('') String warehouse,
    @JsonKey(fromJson: _readString) @Default('') String label,
    @JsonKey(name: 'weekly_sales', fromJson: _readNum)
    @Default(0.0)
    double weeklySales,
    @JsonKey(name: 'par_total', fromJson: _readNum)
    @Default(0.0)
    double parTotal,
    @JsonKey(name: 'on_hand_total', fromJson: _readNum)
    @Default(0.0)
    double onHandTotal,
    @JsonKey(name: 'fill_total', fromJson: _readNum)
    @Default(0.0)
    double fillTotal,
    @JsonKey(name: 'below_backup_count', fromJson: _readInt)
    @Default(0)
    int belowBackupCount,
  }) = _ProductionRoundBranch;

  factory ProductionRoundBranch.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundBranchFromJson(json);

  const ProductionRoundBranch._();

  String get displayName => label.trim().isEmpty ? warehouse : label;
}

/// The round's headline counts.
@freezed
class ProductionRoundSummary with _$ProductionRoundSummary {
  const factory ProductionRoundSummary({
    /// Batches per size group (`Medium`, `Large`), multiples of 0.25.
    @JsonKey(fromJson: _readNumMap)
    @Default(<String, double>{})
    Map<String, double> batches,
    @JsonKey(fromJson: _readNumMap)
    @Default(<String, double>{})
    Map<String, double> jars,
    @JsonKey(name: 'jars_total', fromJson: _readNum)
    @Default(0.0)
    double jarsTotal,
    @JsonKey(name: 'items_to_make', fromJson: _readInt)
    @Default(0)
    int itemsToMake,
    @JsonKey(name: 'needed_now_count', fromJson: _readInt)
    @Default(0)
    int neededNowCount,
    @JsonKey(name: 'missing_count', fromJson: _readInt)
    @Default(0)
    int missingCount,

    /// Jar ITEMS (flavour × size) to make that use a missing material — a
    /// count of rows, not of jars.
    @JsonKey(name: 'blocked_count', fromJson: _readInt)
    @Default(0)
    int blockedCount,
  }) = _ProductionRoundSummary;

  factory ProductionRoundSummary.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundSummaryFromJson(json);
}

/// The whole answer to "what should the factory make this round".
@freezed
class ProductionRound with _$ProductionRound {
  const factory ProductionRound({
    @JsonKey(name: 'generated_on', fromJson: _readString)
    @Default('')
    String generatedOn,
    @JsonKey(fromJson: _readString) @Default('') String company,
    @JsonKey(name: 'source_warehouse', fromJson: _readString)
    @Default('')
    String sourceWarehouse,
    @JsonKey(name: 'cycle_days', fromJson: _readInt) @Default(0) int cycleDays,
    @JsonKey(name: 'backup_days', fromJson: _readInt)
    @Default(0)
    int backupDays,
    @JsonKey(name: 'cover_days', fromJson: _readInt) @Default(0) int coverDays,
    @JsonKey(name: 'sales_weeks', fromJson: _readInt)
    @Default(0)
    int salesWeeks,
    @JsonKey(name: 'sales_from', fromJson: _readString)
    @Default('')
    String salesFrom,
    @JsonKey(name: 'sales_to', fromJson: _readString)
    @Default('')
    String salesTo,
    @JsonKey(name: 'batch_sizes', fromJson: _readNumMap)
    @Default(<String, double>{})
    Map<String, double> batchSizes,
    @Default(ProductionRoundSummary()) ProductionRoundSummary summary,
    @JsonKey(fromJson: _readBranches)
    @Default(<ProductionRoundBranch>[])
    List<ProductionRoundBranch> branches,
    @JsonKey(fromJson: _readItems)
    @Default(<ProductionRoundItem>[])
    List<ProductionRoundItem> items,
    @JsonKey(fromJson: _readPrep)
    @Default(<ProductionRoundPrep>[])
    List<ProductionRoundPrep> prep,
    @JsonKey(fromJson: _readMaterials)
    @Default(<ProductionRoundMaterial>[])
    List<ProductionRoundMaterial> materials,
    @JsonKey(fromJson: _readStringList)
    @Default(<String>[])
    List<String> notices,
  }) = _ProductionRound;

  factory ProductionRound.fromJson(Map<String, dynamic> json) =>
      _$ProductionRoundFromJson(json);

  const ProductionRound._();

  /// Size groups in display order: Small, Medium, Large, then anything else
  /// the server adds, alphabetically. Drawn from the summary and the items so
  /// a size never disappears because one side of the payload omitted it.
  List<String> get sizes {
    final all = <String>{
      ...summary.batches.keys,
      ...summary.jars.keys,
      for (final item in items)
        if (item.size.trim().isNotEmpty) item.size.trim(),
    };
    const preferred = ['Small', 'Medium', 'Large'];
    final rest = all.where((s) => !preferred.contains(s)).toList()..sort();
    return [
      for (final s in preferred)
        if (all.contains(s)) s,
      ...rest,
    ];
  }

  List<ProductionRoundItem> itemsOfSize(String size) =>
      items.where((i) => i.size.trim() == size).toList();

  /// Prep rows that actually ask for work this round.
  List<ProductionRoundPrep> get prepToDo =>
      prep.where((p) => p.isToDo).toList();

  List<ProductionRoundMaterial> get missingMaterials =>
      materials.where((m) => m.isMissing).toList();

  ProductionRoundMaterial? materialFor(String itemCode) {
    for (final material in materials) {
      if (material.itemCode == itemCode) return material;
    }
    return null;
  }

  /// `generated_on` as a local wall-clock time, or null when unparseable.
  DateTime? get generatedAt => DateTime.tryParse(generatedOn.trim());
}

// ── Lenient readers ────────────────────────────────────────────────────────
// The contract promises numbers and lists, but one malformed field must not
// blank the whole screen: every reader below falls back instead of throwing.

double _readNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0.0;
  return 0.0;
}

double? _readNumOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

int _readInt(dynamic value) => _readNum(value).round();

String _readString(dynamic value) => value == null ? '' : value.toString();

bool _readFlag(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
  return false;
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty) entry.toString(),
  ];
}

Map<String, double> _readNumMap(dynamic value) {
  if (value is! Map) return const <String, double>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): _readNum(entry.value),
  };
}

List<T> _readList<T>(dynamic value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) return <T>[];
  return [
    for (final entry in value)
      if (entry is Map) parse(Map<String, dynamic>.from(entry)),
  ];
}

List<ProductionRoundItemBranch> _readItemBranches(dynamic value) =>
    _readList(value, ProductionRoundItemBranch.fromJson);

List<ProductionRoundBranch> _readBranches(dynamic value) =>
    _readList(value, ProductionRoundBranch.fromJson);

List<ProductionRoundItem> _readItems(dynamic value) =>
    _readList(value, ProductionRoundItem.fromJson);

List<ProductionRoundPrep> _readPrep(dynamic value) =>
    _readList(value, ProductionRoundPrep.fromJson);

List<ProductionRoundMaterial> _readMaterials(dynamic value) =>
    _readList(value, ProductionRoundMaterial.fromJson);

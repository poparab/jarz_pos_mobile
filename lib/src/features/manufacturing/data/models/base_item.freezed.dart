// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BaseItemsPage _$BaseItemsPageFromJson(Map<String, dynamic> json) {
  return _BaseItemsPage.fromJson(json);
}

/// @nodoc
mixin _$BaseItemsPage {
  String get company => throw _privateConstructorUsedError;
  @JsonKey(name: 'generated_on')
  String? get generatedOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'demand_source')
  String get demandSource => throw _privateConstructorUsedError;
  List<BaseItem> get items => throw _privateConstructorUsedError;
  BaseItemsSummary get summary => throw _privateConstructorUsedError;

  /// Serializes this BaseItemsPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseItemsPageCopyWith<BaseItemsPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseItemsPageCopyWith<$Res> {
  factory $BaseItemsPageCopyWith(
    BaseItemsPage value,
    $Res Function(BaseItemsPage) then,
  ) = _$BaseItemsPageCopyWithImpl<$Res, BaseItemsPage>;
  @useResult
  $Res call({
    String company,
    @JsonKey(name: 'generated_on') String? generatedOn,
    @JsonKey(name: 'demand_source') String demandSource,
    List<BaseItem> items,
    BaseItemsSummary summary,
  });

  $BaseItemsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$BaseItemsPageCopyWithImpl<$Res, $Val extends BaseItemsPage>
    implements $BaseItemsPageCopyWith<$Res> {
  _$BaseItemsPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? generatedOn = freezed,
    Object? demandSource = null,
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(
      _value.copyWith(
            company: null == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String,
            generatedOn: freezed == generatedOn
                ? _value.generatedOn
                : generatedOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            demandSource: null == demandSource
                ? _value.demandSource
                : demandSource // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<BaseItem>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as BaseItemsSummary,
          )
          as $Val,
    );
  }

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BaseItemsSummaryCopyWith<$Res> get summary {
    return $BaseItemsSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BaseItemsPageImplCopyWith<$Res>
    implements $BaseItemsPageCopyWith<$Res> {
  factory _$$BaseItemsPageImplCopyWith(
    _$BaseItemsPageImpl value,
    $Res Function(_$BaseItemsPageImpl) then,
  ) = __$$BaseItemsPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String company,
    @JsonKey(name: 'generated_on') String? generatedOn,
    @JsonKey(name: 'demand_source') String demandSource,
    List<BaseItem> items,
    BaseItemsSummary summary,
  });

  @override
  $BaseItemsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$BaseItemsPageImplCopyWithImpl<$Res>
    extends _$BaseItemsPageCopyWithImpl<$Res, _$BaseItemsPageImpl>
    implements _$$BaseItemsPageImplCopyWith<$Res> {
  __$$BaseItemsPageImplCopyWithImpl(
    _$BaseItemsPageImpl _value,
    $Res Function(_$BaseItemsPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? generatedOn = freezed,
    Object? demandSource = null,
    Object? items = null,
    Object? summary = null,
  }) {
    return _then(
      _$BaseItemsPageImpl(
        company: null == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String,
        generatedOn: freezed == generatedOn
            ? _value.generatedOn
            : generatedOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        demandSource: null == demandSource
            ? _value.demandSource
            : demandSource // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<BaseItem>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as BaseItemsSummary,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseItemsPageImpl extends _BaseItemsPage {
  const _$BaseItemsPageImpl({
    this.company = '',
    @JsonKey(name: 'generated_on') this.generatedOn,
    @JsonKey(name: 'demand_source') this.demandSource = BaseDemandSource.none,
    final List<BaseItem> items = const <BaseItem>[],
    this.summary = const BaseItemsSummary(),
  }) : _items = items,
       super._();

  factory _$BaseItemsPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseItemsPageImplFromJson(json);

  @override
  @JsonKey()
  final String company;
  @override
  @JsonKey(name: 'generated_on')
  final String? generatedOn;
  @override
  @JsonKey(name: 'demand_source')
  final String demandSource;
  final List<BaseItem> _items;
  @override
  @JsonKey()
  List<BaseItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final BaseItemsSummary summary;

  @override
  String toString() {
    return 'BaseItemsPage(company: $company, generatedOn: $generatedOn, demandSource: $demandSource, items: $items, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseItemsPageImpl &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.generatedOn, generatedOn) ||
                other.generatedOn == generatedOn) &&
            (identical(other.demandSource, demandSource) ||
                other.demandSource == demandSource) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    company,
    generatedOn,
    demandSource,
    const DeepCollectionEquality().hash(_items),
    summary,
  );

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseItemsPageImplCopyWith<_$BaseItemsPageImpl> get copyWith =>
      __$$BaseItemsPageImplCopyWithImpl<_$BaseItemsPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseItemsPageImplToJson(this);
  }
}

abstract class _BaseItemsPage extends BaseItemsPage {
  const factory _BaseItemsPage({
    final String company,
    @JsonKey(name: 'generated_on') final String? generatedOn,
    @JsonKey(name: 'demand_source') final String demandSource,
    final List<BaseItem> items,
    final BaseItemsSummary summary,
  }) = _$BaseItemsPageImpl;
  const _BaseItemsPage._() : super._();

  factory _BaseItemsPage.fromJson(Map<String, dynamic> json) =
      _$BaseItemsPageImpl.fromJson;

  @override
  String get company;
  @override
  @JsonKey(name: 'generated_on')
  String? get generatedOn;
  @override
  @JsonKey(name: 'demand_source')
  String get demandSource;
  @override
  List<BaseItem> get items;
  @override
  BaseItemsSummary get summary;

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseItemsPageImplCopyWith<_$BaseItemsPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseItemsSummary _$BaseItemsSummaryFromJson(Map<String, dynamic> json) {
  return _BaseItemsSummary.fromJson(json);
}

/// @nodoc
mixin _$BaseItemsSummary {
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'short_of_demand')
  int get shortOfDemand => throw _privateConstructorUsedError;
  @JsonKey(name: 'blocked_by_materials')
  int get blockedByMaterials => throw _privateConstructorUsedError;

  /// Serializes this BaseItemsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseItemsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseItemsSummaryCopyWith<BaseItemsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseItemsSummaryCopyWith<$Res> {
  factory $BaseItemsSummaryCopyWith(
    BaseItemsSummary value,
    $Res Function(BaseItemsSummary) then,
  ) = _$BaseItemsSummaryCopyWithImpl<$Res, BaseItemsSummary>;
  @useResult
  $Res call({
    int total,
    @JsonKey(name: 'short_of_demand') int shortOfDemand,
    @JsonKey(name: 'blocked_by_materials') int blockedByMaterials,
  });
}

/// @nodoc
class _$BaseItemsSummaryCopyWithImpl<$Res, $Val extends BaseItemsSummary>
    implements $BaseItemsSummaryCopyWith<$Res> {
  _$BaseItemsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseItemsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? shortOfDemand = null,
    Object? blockedByMaterials = null,
  }) {
    return _then(
      _value.copyWith(
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            shortOfDemand: null == shortOfDemand
                ? _value.shortOfDemand
                : shortOfDemand // ignore: cast_nullable_to_non_nullable
                      as int,
            blockedByMaterials: null == blockedByMaterials
                ? _value.blockedByMaterials
                : blockedByMaterials // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseItemsSummaryImplCopyWith<$Res>
    implements $BaseItemsSummaryCopyWith<$Res> {
  factory _$$BaseItemsSummaryImplCopyWith(
    _$BaseItemsSummaryImpl value,
    $Res Function(_$BaseItemsSummaryImpl) then,
  ) = __$$BaseItemsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int total,
    @JsonKey(name: 'short_of_demand') int shortOfDemand,
    @JsonKey(name: 'blocked_by_materials') int blockedByMaterials,
  });
}

/// @nodoc
class __$$BaseItemsSummaryImplCopyWithImpl<$Res>
    extends _$BaseItemsSummaryCopyWithImpl<$Res, _$BaseItemsSummaryImpl>
    implements _$$BaseItemsSummaryImplCopyWith<$Res> {
  __$$BaseItemsSummaryImplCopyWithImpl(
    _$BaseItemsSummaryImpl _value,
    $Res Function(_$BaseItemsSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseItemsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? shortOfDemand = null,
    Object? blockedByMaterials = null,
  }) {
    return _then(
      _$BaseItemsSummaryImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        shortOfDemand: null == shortOfDemand
            ? _value.shortOfDemand
            : shortOfDemand // ignore: cast_nullable_to_non_nullable
                  as int,
        blockedByMaterials: null == blockedByMaterials
            ? _value.blockedByMaterials
            : blockedByMaterials // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseItemsSummaryImpl implements _BaseItemsSummary {
  const _$BaseItemsSummaryImpl({
    this.total = 0,
    @JsonKey(name: 'short_of_demand') this.shortOfDemand = 0,
    @JsonKey(name: 'blocked_by_materials') this.blockedByMaterials = 0,
  });

  factory _$BaseItemsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseItemsSummaryImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey(name: 'short_of_demand')
  final int shortOfDemand;
  @override
  @JsonKey(name: 'blocked_by_materials')
  final int blockedByMaterials;

  @override
  String toString() {
    return 'BaseItemsSummary(total: $total, shortOfDemand: $shortOfDemand, blockedByMaterials: $blockedByMaterials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseItemsSummaryImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.shortOfDemand, shortOfDemand) ||
                other.shortOfDemand == shortOfDemand) &&
            (identical(other.blockedByMaterials, blockedByMaterials) ||
                other.blockedByMaterials == blockedByMaterials));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, total, shortOfDemand, blockedByMaterials);

  /// Create a copy of BaseItemsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseItemsSummaryImplCopyWith<_$BaseItemsSummaryImpl> get copyWith =>
      __$$BaseItemsSummaryImplCopyWithImpl<_$BaseItemsSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseItemsSummaryImplToJson(this);
  }
}

abstract class _BaseItemsSummary implements BaseItemsSummary {
  const factory _BaseItemsSummary({
    final int total,
    @JsonKey(name: 'short_of_demand') final int shortOfDemand,
    @JsonKey(name: 'blocked_by_materials') final int blockedByMaterials,
  }) = _$BaseItemsSummaryImpl;

  factory _BaseItemsSummary.fromJson(Map<String, dynamic> json) =
      _$BaseItemsSummaryImpl.fromJson;

  @override
  int get total;
  @override
  @JsonKey(name: 'short_of_demand')
  int get shortOfDemand;
  @override
  @JsonKey(name: 'blocked_by_materials')
  int get blockedByMaterials;

  /// Create a copy of BaseItemsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseItemsSummaryImplCopyWith<_$BaseItemsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseItem _$BaseItemFromJson(Map<String, dynamic> json) {
  return _BaseItem.fromJson(json);
}

/// @nodoc
mixin _$BaseItem {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_group')
  String? get itemGroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_uom')
  String get stockUom => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_bom')
  String get defaultBom => throw _privateConstructorUsedError;

  /// What ONE batch produces, in [stockUom].
  @JsonKey(name: 'batch_yield')
  double get batchYield => throw _privateConstructorUsedError;

  /// May be negative — a base with a negative Bin almost always means a run
  /// was consumed without ever being recorded as produced.
  @JsonKey(name: 'on_hand')
  double get onHand => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_is_negative')
  bool get stockIsNegative => throw _privateConstructorUsedError;
  @JsonKey(name: 'batches_on_hand')
  double get batchesOnHand => throw _privateConstructorUsedError;

  /// Null when the server skipped the capacity check.
  @JsonKey(name: 'can_make_now_batches')
  int? get canMakeNowBatches => throw _privateConstructorUsedError;
  @JsonKey(name: 'limiting_component')
  BaseLimitingComponent? get limitingComponent =>
      throw _privateConstructorUsedError;

  /// The run sizes the mixer actually supports, when the backend publishes
  /// them. Advisory only: an off-grid figure warns, it never blocks.
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_sop')
  bool get hasSop => throw _privateConstructorUsedError;
  @JsonKey(name: 'sop_total_duration_mins')
  double? get sopTotalDurationMins => throw _privateConstructorUsedError;
  BaseDemand? get demand => throw _privateConstructorUsedError;

  /// Serializes this BaseItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseItemCopyWith<BaseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseItemCopyWith<$Res> {
  factory $BaseItemCopyWith(BaseItem value, $Res Function(BaseItem) then) =
      _$BaseItemCopyWithImpl<$Res, BaseItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'batch_yield') double batchYield,
    @JsonKey(name: 'on_hand') double onHand,
    @JsonKey(name: 'stock_is_negative') bool stockIsNegative,
    @JsonKey(name: 'batches_on_hand') double batchesOnHand,
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component')
    BaseLimitingComponent? limitingComponent,
    @JsonKey(name: 'run_sizes') List<double>? runSizes,
    @JsonKey(name: 'has_sop') bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,
  });

  $BaseLimitingComponentCopyWith<$Res>? get limitingComponent;
  $BaseDemandCopyWith<$Res>? get demand;
}

/// @nodoc
class _$BaseItemCopyWithImpl<$Res, $Val extends BaseItem>
    implements $BaseItemCopyWith<$Res> {
  _$BaseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = freezed,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? batchYield = null,
    Object? onHand = null,
    Object? stockIsNegative = null,
    Object? batchesOnHand = null,
    Object? canMakeNowBatches = freezed,
    Object? limitingComponent = freezed,
    Object? runSizes = freezed,
    Object? hasSop = null,
    Object? sopTotalDurationMins = freezed,
    Object? demand = freezed,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            itemGroup: freezed == itemGroup
                ? _value.itemGroup
                : itemGroup // ignore: cast_nullable_to_non_nullable
                      as String?,
            stockUom: null == stockUom
                ? _value.stockUom
                : stockUom // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultBom: null == defaultBom
                ? _value.defaultBom
                : defaultBom // ignore: cast_nullable_to_non_nullable
                      as String,
            batchYield: null == batchYield
                ? _value.batchYield
                : batchYield // ignore: cast_nullable_to_non_nullable
                      as double,
            onHand: null == onHand
                ? _value.onHand
                : onHand // ignore: cast_nullable_to_non_nullable
                      as double,
            stockIsNegative: null == stockIsNegative
                ? _value.stockIsNegative
                : stockIsNegative // ignore: cast_nullable_to_non_nullable
                      as bool,
            batchesOnHand: null == batchesOnHand
                ? _value.batchesOnHand
                : batchesOnHand // ignore: cast_nullable_to_non_nullable
                      as double,
            canMakeNowBatches: freezed == canMakeNowBatches
                ? _value.canMakeNowBatches
                : canMakeNowBatches // ignore: cast_nullable_to_non_nullable
                      as int?,
            limitingComponent: freezed == limitingComponent
                ? _value.limitingComponent
                : limitingComponent // ignore: cast_nullable_to_non_nullable
                      as BaseLimitingComponent?,
            runSizes: freezed == runSizes
                ? _value.runSizes
                : runSizes // ignore: cast_nullable_to_non_nullable
                      as List<double>?,
            hasSop: null == hasSop
                ? _value.hasSop
                : hasSop // ignore: cast_nullable_to_non_nullable
                      as bool,
            sopTotalDurationMins: freezed == sopTotalDurationMins
                ? _value.sopTotalDurationMins
                : sopTotalDurationMins // ignore: cast_nullable_to_non_nullable
                      as double?,
            demand: freezed == demand
                ? _value.demand
                : demand // ignore: cast_nullable_to_non_nullable
                      as BaseDemand?,
          )
          as $Val,
    );
  }

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BaseLimitingComponentCopyWith<$Res>? get limitingComponent {
    if (_value.limitingComponent == null) {
      return null;
    }

    return $BaseLimitingComponentCopyWith<$Res>(_value.limitingComponent!, (
      value,
    ) {
      return _then(_value.copyWith(limitingComponent: value) as $Val);
    });
  }

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BaseDemandCopyWith<$Res>? get demand {
    if (_value.demand == null) {
      return null;
    }

    return $BaseDemandCopyWith<$Res>(_value.demand!, (value) {
      return _then(_value.copyWith(demand: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BaseItemImplCopyWith<$Res>
    implements $BaseItemCopyWith<$Res> {
  factory _$$BaseItemImplCopyWith(
    _$BaseItemImpl value,
    $Res Function(_$BaseItemImpl) then,
  ) = __$$BaseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'item_group') String? itemGroup,
    @JsonKey(name: 'stock_uom') String stockUom,
    @JsonKey(name: 'default_bom') String defaultBom,
    @JsonKey(name: 'batch_yield') double batchYield,
    @JsonKey(name: 'on_hand') double onHand,
    @JsonKey(name: 'stock_is_negative') bool stockIsNegative,
    @JsonKey(name: 'batches_on_hand') double batchesOnHand,
    @JsonKey(name: 'can_make_now_batches') int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component')
    BaseLimitingComponent? limitingComponent,
    @JsonKey(name: 'run_sizes') List<double>? runSizes,
    @JsonKey(name: 'has_sop') bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,
  });

  @override
  $BaseLimitingComponentCopyWith<$Res>? get limitingComponent;
  @override
  $BaseDemandCopyWith<$Res>? get demand;
}

/// @nodoc
class __$$BaseItemImplCopyWithImpl<$Res>
    extends _$BaseItemCopyWithImpl<$Res, _$BaseItemImpl>
    implements _$$BaseItemImplCopyWith<$Res> {
  __$$BaseItemImplCopyWithImpl(
    _$BaseItemImpl _value,
    $Res Function(_$BaseItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemGroup = freezed,
    Object? stockUom = null,
    Object? defaultBom = null,
    Object? batchYield = null,
    Object? onHand = null,
    Object? stockIsNegative = null,
    Object? batchesOnHand = null,
    Object? canMakeNowBatches = freezed,
    Object? limitingComponent = freezed,
    Object? runSizes = freezed,
    Object? hasSop = null,
    Object? sopTotalDurationMins = freezed,
    Object? demand = freezed,
  }) {
    return _then(
      _$BaseItemImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        itemGroup: freezed == itemGroup
            ? _value.itemGroup
            : itemGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        stockUom: null == stockUom
            ? _value.stockUom
            : stockUom // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultBom: null == defaultBom
            ? _value.defaultBom
            : defaultBom // ignore: cast_nullable_to_non_nullable
                  as String,
        batchYield: null == batchYield
            ? _value.batchYield
            : batchYield // ignore: cast_nullable_to_non_nullable
                  as double,
        onHand: null == onHand
            ? _value.onHand
            : onHand // ignore: cast_nullable_to_non_nullable
                  as double,
        stockIsNegative: null == stockIsNegative
            ? _value.stockIsNegative
            : stockIsNegative // ignore: cast_nullable_to_non_nullable
                  as bool,
        batchesOnHand: null == batchesOnHand
            ? _value.batchesOnHand
            : batchesOnHand // ignore: cast_nullable_to_non_nullable
                  as double,
        canMakeNowBatches: freezed == canMakeNowBatches
            ? _value.canMakeNowBatches
            : canMakeNowBatches // ignore: cast_nullable_to_non_nullable
                  as int?,
        limitingComponent: freezed == limitingComponent
            ? _value.limitingComponent
            : limitingComponent // ignore: cast_nullable_to_non_nullable
                  as BaseLimitingComponent?,
        runSizes: freezed == runSizes
            ? _value._runSizes
            : runSizes // ignore: cast_nullable_to_non_nullable
                  as List<double>?,
        hasSop: null == hasSop
            ? _value.hasSop
            : hasSop // ignore: cast_nullable_to_non_nullable
                  as bool,
        sopTotalDurationMins: freezed == sopTotalDurationMins
            ? _value.sopTotalDurationMins
            : sopTotalDurationMins // ignore: cast_nullable_to_non_nullable
                  as double?,
        demand: freezed == demand
            ? _value.demand
            : demand // ignore: cast_nullable_to_non_nullable
                  as BaseDemand?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseItemImpl extends _BaseItem {
  const _$BaseItemImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'item_group') this.itemGroup,
    @JsonKey(name: 'stock_uom') this.stockUom = '',
    @JsonKey(name: 'default_bom') this.defaultBom = '',
    @JsonKey(name: 'batch_yield') this.batchYield = 1.0,
    @JsonKey(name: 'on_hand') this.onHand = 0.0,
    @JsonKey(name: 'stock_is_negative') this.stockIsNegative = false,
    @JsonKey(name: 'batches_on_hand') this.batchesOnHand = 0.0,
    @JsonKey(name: 'can_make_now_batches') this.canMakeNowBatches,
    @JsonKey(name: 'limiting_component') this.limitingComponent,
    @JsonKey(name: 'run_sizes') final List<double>? runSizes,
    @JsonKey(name: 'has_sop') this.hasSop = false,
    @JsonKey(name: 'sop_total_duration_mins') this.sopTotalDurationMins,
    this.demand,
  }) : _runSizes = runSizes,
       super._();

  factory _$BaseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseItemImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'item_group')
  final String? itemGroup;
  @override
  @JsonKey(name: 'stock_uom')
  final String stockUom;
  @override
  @JsonKey(name: 'default_bom')
  final String defaultBom;

  /// What ONE batch produces, in [stockUom].
  @override
  @JsonKey(name: 'batch_yield')
  final double batchYield;

  /// May be negative — a base with a negative Bin almost always means a run
  /// was consumed without ever being recorded as produced.
  @override
  @JsonKey(name: 'on_hand')
  final double onHand;
  @override
  @JsonKey(name: 'stock_is_negative')
  final bool stockIsNegative;
  @override
  @JsonKey(name: 'batches_on_hand')
  final double batchesOnHand;

  /// Null when the server skipped the capacity check.
  @override
  @JsonKey(name: 'can_make_now_batches')
  final int? canMakeNowBatches;
  @override
  @JsonKey(name: 'limiting_component')
  final BaseLimitingComponent? limitingComponent;

  /// The run sizes the mixer actually supports, when the backend publishes
  /// them. Advisory only: an off-grid figure warns, it never blocks.
  final List<double>? _runSizes;

  /// The run sizes the mixer actually supports, when the backend publishes
  /// them. Advisory only: an off-grid figure warns, it never blocks.
  @override
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes {
    final value = _runSizes;
    if (value == null) return null;
    if (_runSizes is EqualUnmodifiableListView) return _runSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'has_sop')
  final bool hasSop;
  @override
  @JsonKey(name: 'sop_total_duration_mins')
  final double? sopTotalDurationMins;
  @override
  final BaseDemand? demand;

  @override
  String toString() {
    return 'BaseItem(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, stockUom: $stockUom, defaultBom: $defaultBom, batchYield: $batchYield, onHand: $onHand, stockIsNegative: $stockIsNegative, batchesOnHand: $batchesOnHand, canMakeNowBatches: $canMakeNowBatches, limitingComponent: $limitingComponent, runSizes: $runSizes, hasSop: $hasSop, sopTotalDurationMins: $sopTotalDurationMins, demand: $demand)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseItemImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemGroup, itemGroup) ||
                other.itemGroup == itemGroup) &&
            (identical(other.stockUom, stockUom) ||
                other.stockUom == stockUom) &&
            (identical(other.defaultBom, defaultBom) ||
                other.defaultBom == defaultBom) &&
            (identical(other.batchYield, batchYield) ||
                other.batchYield == batchYield) &&
            (identical(other.onHand, onHand) || other.onHand == onHand) &&
            (identical(other.stockIsNegative, stockIsNegative) ||
                other.stockIsNegative == stockIsNegative) &&
            (identical(other.batchesOnHand, batchesOnHand) ||
                other.batchesOnHand == batchesOnHand) &&
            (identical(other.canMakeNowBatches, canMakeNowBatches) ||
                other.canMakeNowBatches == canMakeNowBatches) &&
            (identical(other.limitingComponent, limitingComponent) ||
                other.limitingComponent == limitingComponent) &&
            const DeepCollectionEquality().equals(other._runSizes, _runSizes) &&
            (identical(other.hasSop, hasSop) || other.hasSop == hasSop) &&
            (identical(other.sopTotalDurationMins, sopTotalDurationMins) ||
                other.sopTotalDurationMins == sopTotalDurationMins) &&
            (identical(other.demand, demand) || other.demand == demand));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    itemGroup,
    stockUom,
    defaultBom,
    batchYield,
    onHand,
    stockIsNegative,
    batchesOnHand,
    canMakeNowBatches,
    limitingComponent,
    const DeepCollectionEquality().hash(_runSizes),
    hasSop,
    sopTotalDurationMins,
    demand,
  );

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseItemImplCopyWith<_$BaseItemImpl> get copyWith =>
      __$$BaseItemImplCopyWithImpl<_$BaseItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseItemImplToJson(this);
  }
}

abstract class _BaseItem extends BaseItem {
  const factory _BaseItem({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'item_group') final String? itemGroup,
    @JsonKey(name: 'stock_uom') final String stockUom,
    @JsonKey(name: 'default_bom') final String defaultBom,
    @JsonKey(name: 'batch_yield') final double batchYield,
    @JsonKey(name: 'on_hand') final double onHand,
    @JsonKey(name: 'stock_is_negative') final bool stockIsNegative,
    @JsonKey(name: 'batches_on_hand') final double batchesOnHand,
    @JsonKey(name: 'can_make_now_batches') final int? canMakeNowBatches,
    @JsonKey(name: 'limiting_component')
    final BaseLimitingComponent? limitingComponent,
    @JsonKey(name: 'run_sizes') final List<double>? runSizes,
    @JsonKey(name: 'has_sop') final bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins')
    final double? sopTotalDurationMins,
    final BaseDemand? demand,
  }) = _$BaseItemImpl;
  const _BaseItem._() : super._();

  factory _BaseItem.fromJson(Map<String, dynamic> json) =
      _$BaseItemImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'item_group')
  String? get itemGroup;
  @override
  @JsonKey(name: 'stock_uom')
  String get stockUom;
  @override
  @JsonKey(name: 'default_bom')
  String get defaultBom;

  /// What ONE batch produces, in [stockUom].
  @override
  @JsonKey(name: 'batch_yield')
  double get batchYield;

  /// May be negative — a base with a negative Bin almost always means a run
  /// was consumed without ever being recorded as produced.
  @override
  @JsonKey(name: 'on_hand')
  double get onHand;
  @override
  @JsonKey(name: 'stock_is_negative')
  bool get stockIsNegative;
  @override
  @JsonKey(name: 'batches_on_hand')
  double get batchesOnHand;

  /// Null when the server skipped the capacity check.
  @override
  @JsonKey(name: 'can_make_now_batches')
  int? get canMakeNowBatches;
  @override
  @JsonKey(name: 'limiting_component')
  BaseLimitingComponent? get limitingComponent;

  /// The run sizes the mixer actually supports, when the backend publishes
  /// them. Advisory only: an off-grid figure warns, it never blocks.
  @override
  @JsonKey(name: 'run_sizes')
  List<double>? get runSizes;
  @override
  @JsonKey(name: 'has_sop')
  bool get hasSop;
  @override
  @JsonKey(name: 'sop_total_duration_mins')
  double? get sopTotalDurationMins;
  @override
  BaseDemand? get demand;

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseItemImplCopyWith<_$BaseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseDemand _$BaseDemandFromJson(Map<String, dynamic> json) {
  return _BaseDemand.fromJson(json);
}

/// @nodoc
mixin _$BaseDemand {
  @JsonKey(name: 'qty_required')
  double get qtyRequired => throw _privateConstructorUsedError;
  @JsonKey(name: 'batches_required')
  double get batchesRequired => throw _privateConstructorUsedError;
  @JsonKey(name: 'shortfall_batches')
  double get shortfallBatches => throw _privateConstructorUsedError;

  /// Free text naming what generated the demand ("today's plan", a plan name,
  /// "sales suggestions"). Rendered verbatim when present.
  String get driver => throw _privateConstructorUsedError;

  /// Serializes this BaseDemand to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseDemand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseDemandCopyWith<BaseDemand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseDemandCopyWith<$Res> {
  factory $BaseDemandCopyWith(
    BaseDemand value,
    $Res Function(BaseDemand) then,
  ) = _$BaseDemandCopyWithImpl<$Res, BaseDemand>;
  @useResult
  $Res call({
    @JsonKey(name: 'qty_required') double qtyRequired,
    @JsonKey(name: 'batches_required') double batchesRequired,
    @JsonKey(name: 'shortfall_batches') double shortfallBatches,
    String driver,
  });
}

/// @nodoc
class _$BaseDemandCopyWithImpl<$Res, $Val extends BaseDemand>
    implements $BaseDemandCopyWith<$Res> {
  _$BaseDemandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseDemand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qtyRequired = null,
    Object? batchesRequired = null,
    Object? shortfallBatches = null,
    Object? driver = null,
  }) {
    return _then(
      _value.copyWith(
            qtyRequired: null == qtyRequired
                ? _value.qtyRequired
                : qtyRequired // ignore: cast_nullable_to_non_nullable
                      as double,
            batchesRequired: null == batchesRequired
                ? _value.batchesRequired
                : batchesRequired // ignore: cast_nullable_to_non_nullable
                      as double,
            shortfallBatches: null == shortfallBatches
                ? _value.shortfallBatches
                : shortfallBatches // ignore: cast_nullable_to_non_nullable
                      as double,
            driver: null == driver
                ? _value.driver
                : driver // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseDemandImplCopyWith<$Res>
    implements $BaseDemandCopyWith<$Res> {
  factory _$$BaseDemandImplCopyWith(
    _$BaseDemandImpl value,
    $Res Function(_$BaseDemandImpl) then,
  ) = __$$BaseDemandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'qty_required') double qtyRequired,
    @JsonKey(name: 'batches_required') double batchesRequired,
    @JsonKey(name: 'shortfall_batches') double shortfallBatches,
    String driver,
  });
}

/// @nodoc
class __$$BaseDemandImplCopyWithImpl<$Res>
    extends _$BaseDemandCopyWithImpl<$Res, _$BaseDemandImpl>
    implements _$$BaseDemandImplCopyWith<$Res> {
  __$$BaseDemandImplCopyWithImpl(
    _$BaseDemandImpl _value,
    $Res Function(_$BaseDemandImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseDemand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qtyRequired = null,
    Object? batchesRequired = null,
    Object? shortfallBatches = null,
    Object? driver = null,
  }) {
    return _then(
      _$BaseDemandImpl(
        qtyRequired: null == qtyRequired
            ? _value.qtyRequired
            : qtyRequired // ignore: cast_nullable_to_non_nullable
                  as double,
        batchesRequired: null == batchesRequired
            ? _value.batchesRequired
            : batchesRequired // ignore: cast_nullable_to_non_nullable
                  as double,
        shortfallBatches: null == shortfallBatches
            ? _value.shortfallBatches
            : shortfallBatches // ignore: cast_nullable_to_non_nullable
                  as double,
        driver: null == driver
            ? _value.driver
            : driver // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseDemandImpl extends _BaseDemand {
  const _$BaseDemandImpl({
    @JsonKey(name: 'qty_required') this.qtyRequired = 0.0,
    @JsonKey(name: 'batches_required') this.batchesRequired = 0.0,
    @JsonKey(name: 'shortfall_batches') this.shortfallBatches = 0.0,
    this.driver = '',
  }) : super._();

  factory _$BaseDemandImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseDemandImplFromJson(json);

  @override
  @JsonKey(name: 'qty_required')
  final double qtyRequired;
  @override
  @JsonKey(name: 'batches_required')
  final double batchesRequired;
  @override
  @JsonKey(name: 'shortfall_batches')
  final double shortfallBatches;

  /// Free text naming what generated the demand ("today's plan", a plan name,
  /// "sales suggestions"). Rendered verbatim when present.
  @override
  @JsonKey()
  final String driver;

  @override
  String toString() {
    return 'BaseDemand(qtyRequired: $qtyRequired, batchesRequired: $batchesRequired, shortfallBatches: $shortfallBatches, driver: $driver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseDemandImpl &&
            (identical(other.qtyRequired, qtyRequired) ||
                other.qtyRequired == qtyRequired) &&
            (identical(other.batchesRequired, batchesRequired) ||
                other.batchesRequired == batchesRequired) &&
            (identical(other.shortfallBatches, shortfallBatches) ||
                other.shortfallBatches == shortfallBatches) &&
            (identical(other.driver, driver) || other.driver == driver));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    qtyRequired,
    batchesRequired,
    shortfallBatches,
    driver,
  );

  /// Create a copy of BaseDemand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseDemandImplCopyWith<_$BaseDemandImpl> get copyWith =>
      __$$BaseDemandImplCopyWithImpl<_$BaseDemandImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseDemandImplToJson(this);
  }
}

abstract class _BaseDemand extends BaseDemand {
  const factory _BaseDemand({
    @JsonKey(name: 'qty_required') final double qtyRequired,
    @JsonKey(name: 'batches_required') final double batchesRequired,
    @JsonKey(name: 'shortfall_batches') final double shortfallBatches,
    final String driver,
  }) = _$BaseDemandImpl;
  const _BaseDemand._() : super._();

  factory _BaseDemand.fromJson(Map<String, dynamic> json) =
      _$BaseDemandImpl.fromJson;

  @override
  @JsonKey(name: 'qty_required')
  double get qtyRequired;
  @override
  @JsonKey(name: 'batches_required')
  double get batchesRequired;
  @override
  @JsonKey(name: 'shortfall_batches')
  double get shortfallBatches;

  /// Free text naming what generated the demand ("today's plan", a plan name,
  /// "sales suggestions"). Rendered verbatim when present.
  @override
  String get driver;

  /// Create a copy of BaseDemand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseDemandImplCopyWith<_$BaseDemandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseLimitingComponent _$BaseLimitingComponentFromJson(
  Map<String, dynamic> json,
) {
  return _BaseLimitingComponent.fromJson(json);
}

/// @nodoc
mixin _$BaseLimitingComponent {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_qty')
  double get availableQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_qty')
  double get requiredQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_missing_warehouse')
  bool get isMissingWarehouse => throw _privateConstructorUsedError;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @JsonKey(name: 'available_elsewhere')
  double? get availableElsewhere => throw _privateConstructorUsedError;
  List<StockAlternative>? get alternatives =>
      throw _privateConstructorUsedError;

  /// Serializes this BaseLimitingComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseLimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseLimitingComponentCopyWith<BaseLimitingComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseLimitingComponentCopyWith<$Res> {
  factory $BaseLimitingComponentCopyWith(
    BaseLimitingComponent value,
    $Res Function(BaseLimitingComponent) then,
  ) = _$BaseLimitingComponentCopyWithImpl<$Res, BaseLimitingComponent>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'available_qty') double availableQty,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'is_missing_warehouse') bool isMissingWarehouse,
    @JsonKey(name: 'available_elsewhere') double? availableElsewhere,
    List<StockAlternative>? alternatives,
  });
}

/// @nodoc
class _$BaseLimitingComponentCopyWithImpl<
  $Res,
  $Val extends BaseLimitingComponent
>
    implements $BaseLimitingComponentCopyWith<$Res> {
  _$BaseLimitingComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseLimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? availableQty = null,
    Object? requiredQty = null,
    Object? isMissingWarehouse = null,
    Object? availableElsewhere = freezed,
    Object? alternatives = freezed,
  }) {
    return _then(
      _value.copyWith(
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            availableQty: null == availableQty
                ? _value.availableQty
                : availableQty // ignore: cast_nullable_to_non_nullable
                      as double,
            requiredQty: null == requiredQty
                ? _value.requiredQty
                : requiredQty // ignore: cast_nullable_to_non_nullable
                      as double,
            isMissingWarehouse: null == isMissingWarehouse
                ? _value.isMissingWarehouse
                : isMissingWarehouse // ignore: cast_nullable_to_non_nullable
                      as bool,
            availableElsewhere: freezed == availableElsewhere
                ? _value.availableElsewhere
                : availableElsewhere // ignore: cast_nullable_to_non_nullable
                      as double?,
            alternatives: freezed == alternatives
                ? _value.alternatives
                : alternatives // ignore: cast_nullable_to_non_nullable
                      as List<StockAlternative>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseLimitingComponentImplCopyWith<$Res>
    implements $BaseLimitingComponentCopyWith<$Res> {
  factory _$$BaseLimitingComponentImplCopyWith(
    _$BaseLimitingComponentImpl value,
    $Res Function(_$BaseLimitingComponentImpl) then,
  ) = __$$BaseLimitingComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'available_qty') double availableQty,
    @JsonKey(name: 'required_qty') double requiredQty,
    @JsonKey(name: 'is_missing_warehouse') bool isMissingWarehouse,
    @JsonKey(name: 'available_elsewhere') double? availableElsewhere,
    List<StockAlternative>? alternatives,
  });
}

/// @nodoc
class __$$BaseLimitingComponentImplCopyWithImpl<$Res>
    extends
        _$BaseLimitingComponentCopyWithImpl<$Res, _$BaseLimitingComponentImpl>
    implements _$$BaseLimitingComponentImplCopyWith<$Res> {
  __$$BaseLimitingComponentImplCopyWithImpl(
    _$BaseLimitingComponentImpl _value,
    $Res Function(_$BaseLimitingComponentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseLimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? availableQty = null,
    Object? requiredQty = null,
    Object? isMissingWarehouse = null,
    Object? availableElsewhere = freezed,
    Object? alternatives = freezed,
  }) {
    return _then(
      _$BaseLimitingComponentImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        availableQty: null == availableQty
            ? _value.availableQty
            : availableQty // ignore: cast_nullable_to_non_nullable
                  as double,
        requiredQty: null == requiredQty
            ? _value.requiredQty
            : requiredQty // ignore: cast_nullable_to_non_nullable
                  as double,
        isMissingWarehouse: null == isMissingWarehouse
            ? _value.isMissingWarehouse
            : isMissingWarehouse // ignore: cast_nullable_to_non_nullable
                  as bool,
        availableElsewhere: freezed == availableElsewhere
            ? _value.availableElsewhere
            : availableElsewhere // ignore: cast_nullable_to_non_nullable
                  as double?,
        alternatives: freezed == alternatives
            ? _value._alternatives
            : alternatives // ignore: cast_nullable_to_non_nullable
                  as List<StockAlternative>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseLimitingComponentImpl extends _BaseLimitingComponent {
  const _$BaseLimitingComponentImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'available_qty') this.availableQty = 0.0,
    @JsonKey(name: 'required_qty') this.requiredQty = 0.0,
    @JsonKey(name: 'is_missing_warehouse') this.isMissingWarehouse = false,
    @JsonKey(name: 'available_elsewhere') this.availableElsewhere,
    final List<StockAlternative>? alternatives,
  }) : _alternatives = alternatives,
       super._();

  factory _$BaseLimitingComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseLimitingComponentImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey(name: 'available_qty')
  final double availableQty;
  @override
  @JsonKey(name: 'required_qty')
  final double requiredQty;
  @override
  @JsonKey(name: 'is_missing_warehouse')
  final bool isMissingWarehouse;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @override
  @JsonKey(name: 'available_elsewhere')
  final double? availableElsewhere;
  final List<StockAlternative>? _alternatives;
  @override
  List<StockAlternative>? get alternatives {
    final value = _alternatives;
    if (value == null) return null;
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'BaseLimitingComponent(itemCode: $itemCode, itemName: $itemName, availableQty: $availableQty, requiredQty: $requiredQty, isMissingWarehouse: $isMissingWarehouse, availableElsewhere: $availableElsewhere, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseLimitingComponentImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.availableQty, availableQty) ||
                other.availableQty == availableQty) &&
            (identical(other.requiredQty, requiredQty) ||
                other.requiredQty == requiredQty) &&
            (identical(other.isMissingWarehouse, isMissingWarehouse) ||
                other.isMissingWarehouse == isMissingWarehouse) &&
            (identical(other.availableElsewhere, availableElsewhere) ||
                other.availableElsewhere == availableElsewhere) &&
            const DeepCollectionEquality().equals(
              other._alternatives,
              _alternatives,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemCode,
    itemName,
    availableQty,
    requiredQty,
    isMissingWarehouse,
    availableElsewhere,
    const DeepCollectionEquality().hash(_alternatives),
  );

  /// Create a copy of BaseLimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseLimitingComponentImplCopyWith<_$BaseLimitingComponentImpl>
  get copyWith =>
      __$$BaseLimitingComponentImplCopyWithImpl<_$BaseLimitingComponentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseLimitingComponentImplToJson(this);
  }
}

abstract class _BaseLimitingComponent extends BaseLimitingComponent {
  const factory _BaseLimitingComponent({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'available_qty') final double availableQty,
    @JsonKey(name: 'required_qty') final double requiredQty,
    @JsonKey(name: 'is_missing_warehouse') final bool isMissingWarehouse,
    @JsonKey(name: 'available_elsewhere') final double? availableElsewhere,
    final List<StockAlternative>? alternatives,
  }) = _$BaseLimitingComponentImpl;
  const _BaseLimitingComponent._() : super._();

  factory _BaseLimitingComponent.fromJson(Map<String, dynamic> json) =
      _$BaseLimitingComponentImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  @JsonKey(name: 'available_qty')
  double get availableQty;
  @override
  @JsonKey(name: 'required_qty')
  double get requiredQty;
  @override
  @JsonKey(name: 'is_missing_warehouse')
  bool get isMissingWarehouse;

  /// Where else this material is sitting, when the backend looked.
  ///
  /// Null means nobody looked — deliberately distinct from `0.0` with an
  /// empty [alternatives] list, which means the lookup ran and there is none
  /// of it anywhere in the company.
  @override
  @JsonKey(name: 'available_elsewhere')
  double? get availableElsewhere;
  @override
  List<StockAlternative>? get alternatives;

  /// Create a copy of BaseLimitingComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseLimitingComponentImplCopyWith<_$BaseLimitingComponentImpl>
  get copyWith => throw _privateConstructorUsedError;
}

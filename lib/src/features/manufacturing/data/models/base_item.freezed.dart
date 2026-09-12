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

  /// Whether this server worked out how fast the freezer empties.
  ///
  /// False on an older backend, and false when the roll-up was skipped: every
  /// per-item cover field is then absent rather than zero, and the card shows
  /// none of them instead of printing a confident nought.
  @JsonKey(name: 'cover_included')
  bool get coverIncluded => throw _privateConstructorUsedError;

  /// The same season and thresholds the jar board applies, so a base and a
  /// jar are ranked by one rule rather than two.
  ProductionSeason get season => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_target_days')
  int get defaultTargetDays => throw _privateConstructorUsedError;
  ProductionThresholds get thresholds => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'cover_included') bool coverIncluded,
    ProductionSeason season,
    @JsonKey(name: 'default_target_days') int defaultTargetDays,
    ProductionThresholds thresholds,
  });

  $BaseItemsSummaryCopyWith<$Res> get summary;
  $ProductionSeasonCopyWith<$Res> get season;
  $ProductionThresholdsCopyWith<$Res> get thresholds;
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
    Object? coverIncluded = null,
    Object? season = null,
    Object? defaultTargetDays = null,
    Object? thresholds = null,
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
            coverIncluded: null == coverIncluded
                ? _value.coverIncluded
                : coverIncluded // ignore: cast_nullable_to_non_nullable
                      as bool,
            season: null == season
                ? _value.season
                : season // ignore: cast_nullable_to_non_nullable
                      as ProductionSeason,
            defaultTargetDays: null == defaultTargetDays
                ? _value.defaultTargetDays
                : defaultTargetDays // ignore: cast_nullable_to_non_nullable
                      as int,
            thresholds: null == thresholds
                ? _value.thresholds
                : thresholds // ignore: cast_nullable_to_non_nullable
                      as ProductionThresholds,
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

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionSeasonCopyWith<$Res> get season {
    return $ProductionSeasonCopyWith<$Res>(_value.season, (value) {
      return _then(_value.copyWith(season: value) as $Val);
    });
  }

  /// Create a copy of BaseItemsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductionThresholdsCopyWith<$Res> get thresholds {
    return $ProductionThresholdsCopyWith<$Res>(_value.thresholds, (value) {
      return _then(_value.copyWith(thresholds: value) as $Val);
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
    @JsonKey(name: 'cover_included') bool coverIncluded,
    ProductionSeason season,
    @JsonKey(name: 'default_target_days') int defaultTargetDays,
    ProductionThresholds thresholds,
  });

  @override
  $BaseItemsSummaryCopyWith<$Res> get summary;
  @override
  $ProductionSeasonCopyWith<$Res> get season;
  @override
  $ProductionThresholdsCopyWith<$Res> get thresholds;
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
    Object? coverIncluded = null,
    Object? season = null,
    Object? defaultTargetDays = null,
    Object? thresholds = null,
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
        coverIncluded: null == coverIncluded
            ? _value.coverIncluded
            : coverIncluded // ignore: cast_nullable_to_non_nullable
                  as bool,
        season: null == season
            ? _value.season
            : season // ignore: cast_nullable_to_non_nullable
                  as ProductionSeason,
        defaultTargetDays: null == defaultTargetDays
            ? _value.defaultTargetDays
            : defaultTargetDays // ignore: cast_nullable_to_non_nullable
                  as int,
        thresholds: null == thresholds
            ? _value.thresholds
            : thresholds // ignore: cast_nullable_to_non_nullable
                  as ProductionThresholds,
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
    @JsonKey(name: 'cover_included') this.coverIncluded = false,
    this.season = const ProductionSeason(),
    @JsonKey(name: 'default_target_days') this.defaultTargetDays = 7,
    this.thresholds = const ProductionThresholds(),
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

  /// Whether this server worked out how fast the freezer empties.
  ///
  /// False on an older backend, and false when the roll-up was skipped: every
  /// per-item cover field is then absent rather than zero, and the card shows
  /// none of them instead of printing a confident nought.
  @override
  @JsonKey(name: 'cover_included')
  final bool coverIncluded;

  /// The same season and thresholds the jar board applies, so a base and a
  /// jar are ranked by one rule rather than two.
  @override
  @JsonKey()
  final ProductionSeason season;
  @override
  @JsonKey(name: 'default_target_days')
  final int defaultTargetDays;
  @override
  @JsonKey()
  final ProductionThresholds thresholds;

  @override
  String toString() {
    return 'BaseItemsPage(company: $company, generatedOn: $generatedOn, demandSource: $demandSource, items: $items, summary: $summary, coverIncluded: $coverIncluded, season: $season, defaultTargetDays: $defaultTargetDays, thresholds: $thresholds)';
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
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.coverIncluded, coverIncluded) ||
                other.coverIncluded == coverIncluded) &&
            (identical(other.season, season) || other.season == season) &&
            (identical(other.defaultTargetDays, defaultTargetDays) ||
                other.defaultTargetDays == defaultTargetDays) &&
            (identical(other.thresholds, thresholds) ||
                other.thresholds == thresholds));
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
    coverIncluded,
    season,
    defaultTargetDays,
    thresholds,
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
    @JsonKey(name: 'cover_included') final bool coverIncluded,
    final ProductionSeason season,
    @JsonKey(name: 'default_target_days') final int defaultTargetDays,
    final ProductionThresholds thresholds,
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

  /// Whether this server worked out how fast the freezer empties.
  ///
  /// False on an older backend, and false when the roll-up was skipped: every
  /// per-item cover field is then absent rather than zero, and the card shows
  /// none of them instead of printing a confident nought.
  @override
  @JsonKey(name: 'cover_included')
  bool get coverIncluded;

  /// The same season and thresholds the jar board applies, so a base and a
  /// jar are ranked by one rule rather than two.
  @override
  ProductionSeason get season;
  @override
  @JsonKey(name: 'default_target_days')
  int get defaultTargetDays;
  @override
  ProductionThresholds get thresholds;

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

  /// How the floor actually measures a run of this base.
  ///
  /// `batch` — the recipe contains something countable (30 eggs), so a run
  /// is a whole or half batch and the quantity follows from it.
  /// `quantity` — every ingredient is weighed, so any amount is makeable and
  /// batches are a fiction the screen should not impose.
  ///
  /// Defaults to `batch` so a server that predates this field behaves exactly
  /// as it did: every base was a batch before the distinction existed.
  @JsonKey(name: 'entry_mode')
  String get entryMode => throw _privateConstructorUsedError;

  /// The countable ingredient one batch is measured by — eggs, for every
  /// cake in this catalogue.
  ///
  /// Null for anything weighed rather than counted, which is what makes
  /// [entryMode] `quantity`. The two always agree; [entryMode] is published
  /// separately so the client never has to re-derive the rule.
  @JsonKey(name: 'batch_unit')
  BaseBatchUnit? get batchUnit => throw _privateConstructorUsedError;

  /// The jars whose own recipe draws on this base, with what each one takes.
  ///
  /// Empty — never null — when nothing consumes it. Sorted smallest-per-jar
  /// first by the server, which puts Medium before Large.
  @JsonKey(name: 'jar_consumers')
  List<BaseJarConsumer> get jarConsumers => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_sop')
  bool get hasSop => throw _privateConstructorUsedError;
  @JsonKey(name: 'sop_total_duration_mins')
  double? get sopTotalDurationMins => throw _privateConstructorUsedError;
  BaseDemand? get demand => throw _privateConstructorUsedError;

  /// How much of this base the jars downstream actually eat per day, in
  /// [stockUom].
  ///
  /// **Null is NO SIGNAL** — nothing consumed it in the window, or the server
  /// did not look. Deliberately not `0.0`, which is a claim ("it never
  /// moves") and would make every cover figure derived from it infinite.
  @JsonKey(name: 'consumption_per_day')
  double? get consumptionPerDay => throw _privateConstructorUsedError;

  /// Days the freezer lasts at [consumptionPerDay]. Null for the same reason.
  @JsonKey(name: 'days_of_cover')
  double? get daysOfCover => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_days')
  int get targetDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_days_source')
  String get targetDaysSource => throw _privateConstructorUsedError;

  /// `critical|low|ok|overstocked|no_velocity`, the same vocabulary the jar
  /// board uses — so [ProductionStatusChip] can render a base and a jar
  /// identically.
  ///
  /// Null means this server does not compute cover for bases at all, which is
  /// distinct from `no_velocity` (it looked, and nothing consumes this base).
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_qty')
  double get suggestedQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_batches')
  int get suggestedBatches => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'entry_mode') String entryMode,
    @JsonKey(name: 'batch_unit') BaseBatchUnit? batchUnit,
    @JsonKey(name: 'jar_consumers') List<BaseJarConsumer> jarConsumers,
    @JsonKey(name: 'has_sop') bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,
    @JsonKey(name: 'consumption_per_day') double? consumptionPerDay,
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    @JsonKey(name: 'target_days') int targetDays,
    @JsonKey(name: 'target_days_source') String targetDaysSource,
    String? status,
    @JsonKey(name: 'suggested_qty') double suggestedQty,
    @JsonKey(name: 'suggested_batches') int suggestedBatches,
  });

  $BaseLimitingComponentCopyWith<$Res>? get limitingComponent;
  $BaseBatchUnitCopyWith<$Res>? get batchUnit;
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
    Object? entryMode = null,
    Object? batchUnit = freezed,
    Object? jarConsumers = null,
    Object? hasSop = null,
    Object? sopTotalDurationMins = freezed,
    Object? demand = freezed,
    Object? consumptionPerDay = freezed,
    Object? daysOfCover = freezed,
    Object? targetDays = null,
    Object? targetDaysSource = null,
    Object? status = freezed,
    Object? suggestedQty = null,
    Object? suggestedBatches = null,
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
            entryMode: null == entryMode
                ? _value.entryMode
                : entryMode // ignore: cast_nullable_to_non_nullable
                      as String,
            batchUnit: freezed == batchUnit
                ? _value.batchUnit
                : batchUnit // ignore: cast_nullable_to_non_nullable
                      as BaseBatchUnit?,
            jarConsumers: null == jarConsumers
                ? _value.jarConsumers
                : jarConsumers // ignore: cast_nullable_to_non_nullable
                      as List<BaseJarConsumer>,
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
            consumptionPerDay: freezed == consumptionPerDay
                ? _value.consumptionPerDay
                : consumptionPerDay // ignore: cast_nullable_to_non_nullable
                      as double?,
            daysOfCover: freezed == daysOfCover
                ? _value.daysOfCover
                : daysOfCover // ignore: cast_nullable_to_non_nullable
                      as double?,
            targetDays: null == targetDays
                ? _value.targetDays
                : targetDays // ignore: cast_nullable_to_non_nullable
                      as int,
            targetDaysSource: null == targetDaysSource
                ? _value.targetDaysSource
                : targetDaysSource // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            suggestedQty: null == suggestedQty
                ? _value.suggestedQty
                : suggestedQty // ignore: cast_nullable_to_non_nullable
                      as double,
            suggestedBatches: null == suggestedBatches
                ? _value.suggestedBatches
                : suggestedBatches // ignore: cast_nullable_to_non_nullable
                      as int,
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
  $BaseBatchUnitCopyWith<$Res>? get batchUnit {
    if (_value.batchUnit == null) {
      return null;
    }

    return $BaseBatchUnitCopyWith<$Res>(_value.batchUnit!, (value) {
      return _then(_value.copyWith(batchUnit: value) as $Val);
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
    @JsonKey(name: 'entry_mode') String entryMode,
    @JsonKey(name: 'batch_unit') BaseBatchUnit? batchUnit,
    @JsonKey(name: 'jar_consumers') List<BaseJarConsumer> jarConsumers,
    @JsonKey(name: 'has_sop') bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins') double? sopTotalDurationMins,
    BaseDemand? demand,
    @JsonKey(name: 'consumption_per_day') double? consumptionPerDay,
    @JsonKey(name: 'days_of_cover') double? daysOfCover,
    @JsonKey(name: 'target_days') int targetDays,
    @JsonKey(name: 'target_days_source') String targetDaysSource,
    String? status,
    @JsonKey(name: 'suggested_qty') double suggestedQty,
    @JsonKey(name: 'suggested_batches') int suggestedBatches,
  });

  @override
  $BaseLimitingComponentCopyWith<$Res>? get limitingComponent;
  @override
  $BaseBatchUnitCopyWith<$Res>? get batchUnit;
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
    Object? entryMode = null,
    Object? batchUnit = freezed,
    Object? jarConsumers = null,
    Object? hasSop = null,
    Object? sopTotalDurationMins = freezed,
    Object? demand = freezed,
    Object? consumptionPerDay = freezed,
    Object? daysOfCover = freezed,
    Object? targetDays = null,
    Object? targetDaysSource = null,
    Object? status = freezed,
    Object? suggestedQty = null,
    Object? suggestedBatches = null,
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
        entryMode: null == entryMode
            ? _value.entryMode
            : entryMode // ignore: cast_nullable_to_non_nullable
                  as String,
        batchUnit: freezed == batchUnit
            ? _value.batchUnit
            : batchUnit // ignore: cast_nullable_to_non_nullable
                  as BaseBatchUnit?,
        jarConsumers: null == jarConsumers
            ? _value._jarConsumers
            : jarConsumers // ignore: cast_nullable_to_non_nullable
                  as List<BaseJarConsumer>,
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
        consumptionPerDay: freezed == consumptionPerDay
            ? _value.consumptionPerDay
            : consumptionPerDay // ignore: cast_nullable_to_non_nullable
                  as double?,
        daysOfCover: freezed == daysOfCover
            ? _value.daysOfCover
            : daysOfCover // ignore: cast_nullable_to_non_nullable
                  as double?,
        targetDays: null == targetDays
            ? _value.targetDays
            : targetDays // ignore: cast_nullable_to_non_nullable
                  as int,
        targetDaysSource: null == targetDaysSource
            ? _value.targetDaysSource
            : targetDaysSource // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        suggestedQty: null == suggestedQty
            ? _value.suggestedQty
            : suggestedQty // ignore: cast_nullable_to_non_nullable
                  as double,
        suggestedBatches: null == suggestedBatches
            ? _value.suggestedBatches
            : suggestedBatches // ignore: cast_nullable_to_non_nullable
                  as int,
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
    @JsonKey(name: 'entry_mode') this.entryMode = kBaseEntryBatch,
    @JsonKey(name: 'batch_unit') this.batchUnit,
    @JsonKey(name: 'jar_consumers')
    final List<BaseJarConsumer> jarConsumers = const <BaseJarConsumer>[],
    @JsonKey(name: 'has_sop') this.hasSop = false,
    @JsonKey(name: 'sop_total_duration_mins') this.sopTotalDurationMins,
    this.demand,
    @JsonKey(name: 'consumption_per_day') this.consumptionPerDay,
    @JsonKey(name: 'days_of_cover') this.daysOfCover,
    @JsonKey(name: 'target_days') this.targetDays = 7,
    @JsonKey(name: 'target_days_source') this.targetDaysSource = 'default',
    this.status,
    @JsonKey(name: 'suggested_qty') this.suggestedQty = 0.0,
    @JsonKey(name: 'suggested_batches') this.suggestedBatches = 0,
  }) : _runSizes = runSizes,
       _jarConsumers = jarConsumers,
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

  /// How the floor actually measures a run of this base.
  ///
  /// `batch` — the recipe contains something countable (30 eggs), so a run
  /// is a whole or half batch and the quantity follows from it.
  /// `quantity` — every ingredient is weighed, so any amount is makeable and
  /// batches are a fiction the screen should not impose.
  ///
  /// Defaults to `batch` so a server that predates this field behaves exactly
  /// as it did: every base was a batch before the distinction existed.
  @override
  @JsonKey(name: 'entry_mode')
  final String entryMode;

  /// The countable ingredient one batch is measured by — eggs, for every
  /// cake in this catalogue.
  ///
  /// Null for anything weighed rather than counted, which is what makes
  /// [entryMode] `quantity`. The two always agree; [entryMode] is published
  /// separately so the client never has to re-derive the rule.
  @override
  @JsonKey(name: 'batch_unit')
  final BaseBatchUnit? batchUnit;

  /// The jars whose own recipe draws on this base, with what each one takes.
  ///
  /// Empty — never null — when nothing consumes it. Sorted smallest-per-jar
  /// first by the server, which puts Medium before Large.
  final List<BaseJarConsumer> _jarConsumers;

  /// The jars whose own recipe draws on this base, with what each one takes.
  ///
  /// Empty — never null — when nothing consumes it. Sorted smallest-per-jar
  /// first by the server, which puts Medium before Large.
  @override
  @JsonKey(name: 'jar_consumers')
  List<BaseJarConsumer> get jarConsumers {
    if (_jarConsumers is EqualUnmodifiableListView) return _jarConsumers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jarConsumers);
  }

  @override
  @JsonKey(name: 'has_sop')
  final bool hasSop;
  @override
  @JsonKey(name: 'sop_total_duration_mins')
  final double? sopTotalDurationMins;
  @override
  final BaseDemand? demand;

  /// How much of this base the jars downstream actually eat per day, in
  /// [stockUom].
  ///
  /// **Null is NO SIGNAL** — nothing consumed it in the window, or the server
  /// did not look. Deliberately not `0.0`, which is a claim ("it never
  /// moves") and would make every cover figure derived from it infinite.
  @override
  @JsonKey(name: 'consumption_per_day')
  final double? consumptionPerDay;

  /// Days the freezer lasts at [consumptionPerDay]. Null for the same reason.
  @override
  @JsonKey(name: 'days_of_cover')
  final double? daysOfCover;
  @override
  @JsonKey(name: 'target_days')
  final int targetDays;
  @override
  @JsonKey(name: 'target_days_source')
  final String targetDaysSource;

  /// `critical|low|ok|overstocked|no_velocity`, the same vocabulary the jar
  /// board uses — so [ProductionStatusChip] can render a base and a jar
  /// identically.
  ///
  /// Null means this server does not compute cover for bases at all, which is
  /// distinct from `no_velocity` (it looked, and nothing consumes this base).
  @override
  final String? status;
  @override
  @JsonKey(name: 'suggested_qty')
  final double suggestedQty;
  @override
  @JsonKey(name: 'suggested_batches')
  final int suggestedBatches;

  @override
  String toString() {
    return 'BaseItem(itemCode: $itemCode, itemName: $itemName, itemGroup: $itemGroup, stockUom: $stockUom, defaultBom: $defaultBom, batchYield: $batchYield, onHand: $onHand, stockIsNegative: $stockIsNegative, batchesOnHand: $batchesOnHand, canMakeNowBatches: $canMakeNowBatches, limitingComponent: $limitingComponent, runSizes: $runSizes, entryMode: $entryMode, batchUnit: $batchUnit, jarConsumers: $jarConsumers, hasSop: $hasSop, sopTotalDurationMins: $sopTotalDurationMins, demand: $demand, consumptionPerDay: $consumptionPerDay, daysOfCover: $daysOfCover, targetDays: $targetDays, targetDaysSource: $targetDaysSource, status: $status, suggestedQty: $suggestedQty, suggestedBatches: $suggestedBatches)';
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
            (identical(other.entryMode, entryMode) ||
                other.entryMode == entryMode) &&
            (identical(other.batchUnit, batchUnit) ||
                other.batchUnit == batchUnit) &&
            const DeepCollectionEquality().equals(
              other._jarConsumers,
              _jarConsumers,
            ) &&
            (identical(other.hasSop, hasSop) || other.hasSop == hasSop) &&
            (identical(other.sopTotalDurationMins, sopTotalDurationMins) ||
                other.sopTotalDurationMins == sopTotalDurationMins) &&
            (identical(other.demand, demand) || other.demand == demand) &&
            (identical(other.consumptionPerDay, consumptionPerDay) ||
                other.consumptionPerDay == consumptionPerDay) &&
            (identical(other.daysOfCover, daysOfCover) ||
                other.daysOfCover == daysOfCover) &&
            (identical(other.targetDays, targetDays) ||
                other.targetDays == targetDays) &&
            (identical(other.targetDaysSource, targetDaysSource) ||
                other.targetDaysSource == targetDaysSource) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.suggestedQty, suggestedQty) ||
                other.suggestedQty == suggestedQty) &&
            (identical(other.suggestedBatches, suggestedBatches) ||
                other.suggestedBatches == suggestedBatches));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
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
    entryMode,
    batchUnit,
    const DeepCollectionEquality().hash(_jarConsumers),
    hasSop,
    sopTotalDurationMins,
    demand,
    consumptionPerDay,
    daysOfCover,
    targetDays,
    targetDaysSource,
    status,
    suggestedQty,
    suggestedBatches,
  ]);

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
    @JsonKey(name: 'entry_mode') final String entryMode,
    @JsonKey(name: 'batch_unit') final BaseBatchUnit? batchUnit,
    @JsonKey(name: 'jar_consumers') final List<BaseJarConsumer> jarConsumers,
    @JsonKey(name: 'has_sop') final bool hasSop,
    @JsonKey(name: 'sop_total_duration_mins')
    final double? sopTotalDurationMins,
    final BaseDemand? demand,
    @JsonKey(name: 'consumption_per_day') final double? consumptionPerDay,
    @JsonKey(name: 'days_of_cover') final double? daysOfCover,
    @JsonKey(name: 'target_days') final int targetDays,
    @JsonKey(name: 'target_days_source') final String targetDaysSource,
    final String? status,
    @JsonKey(name: 'suggested_qty') final double suggestedQty,
    @JsonKey(name: 'suggested_batches') final int suggestedBatches,
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

  /// How the floor actually measures a run of this base.
  ///
  /// `batch` — the recipe contains something countable (30 eggs), so a run
  /// is a whole or half batch and the quantity follows from it.
  /// `quantity` — every ingredient is weighed, so any amount is makeable and
  /// batches are a fiction the screen should not impose.
  ///
  /// Defaults to `batch` so a server that predates this field behaves exactly
  /// as it did: every base was a batch before the distinction existed.
  @override
  @JsonKey(name: 'entry_mode')
  String get entryMode;

  /// The countable ingredient one batch is measured by — eggs, for every
  /// cake in this catalogue.
  ///
  /// Null for anything weighed rather than counted, which is what makes
  /// [entryMode] `quantity`. The two always agree; [entryMode] is published
  /// separately so the client never has to re-derive the rule.
  @override
  @JsonKey(name: 'batch_unit')
  BaseBatchUnit? get batchUnit;

  /// The jars whose own recipe draws on this base, with what each one takes.
  ///
  /// Empty — never null — when nothing consumes it. Sorted smallest-per-jar
  /// first by the server, which puts Medium before Large.
  @override
  @JsonKey(name: 'jar_consumers')
  List<BaseJarConsumer> get jarConsumers;
  @override
  @JsonKey(name: 'has_sop')
  bool get hasSop;
  @override
  @JsonKey(name: 'sop_total_duration_mins')
  double? get sopTotalDurationMins;
  @override
  BaseDemand? get demand;

  /// How much of this base the jars downstream actually eat per day, in
  /// [stockUom].
  ///
  /// **Null is NO SIGNAL** — nothing consumed it in the window, or the server
  /// did not look. Deliberately not `0.0`, which is a claim ("it never
  /// moves") and would make every cover figure derived from it infinite.
  @override
  @JsonKey(name: 'consumption_per_day')
  double? get consumptionPerDay;

  /// Days the freezer lasts at [consumptionPerDay]. Null for the same reason.
  @override
  @JsonKey(name: 'days_of_cover')
  double? get daysOfCover;
  @override
  @JsonKey(name: 'target_days')
  int get targetDays;
  @override
  @JsonKey(name: 'target_days_source')
  String get targetDaysSource;

  /// `critical|low|ok|overstocked|no_velocity`, the same vocabulary the jar
  /// board uses — so [ProductionStatusChip] can render a base and a jar
  /// identically.
  ///
  /// Null means this server does not compute cover for bases at all, which is
  /// distinct from `no_velocity` (it looked, and nothing consumes this base).
  @override
  String? get status;
  @override
  @JsonKey(name: 'suggested_qty')
  double get suggestedQty;
  @override
  @JsonKey(name: 'suggested_batches')
  int get suggestedBatches;

  /// Create a copy of BaseItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseItemImplCopyWith<_$BaseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseBatchUnit _$BaseBatchUnitFromJson(Map<String, dynamic> json) {
  return _BaseBatchUnit.fromJson(json);
}

/// @nodoc
mixin _$BaseBatchUnit {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;

  /// How many of it one batch takes.
  @JsonKey(name: 'qty_per_batch')
  double get qtyPerBatch => throw _privateConstructorUsedError;

  /// Serializes this BaseBatchUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseBatchUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseBatchUnitCopyWith<BaseBatchUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseBatchUnitCopyWith<$Res> {
  factory $BaseBatchUnitCopyWith(
    BaseBatchUnit value,
    $Res Function(BaseBatchUnit) then,
  ) = _$BaseBatchUnitCopyWithImpl<$Res, BaseBatchUnit>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'qty_per_batch') double qtyPerBatch,
  });
}

/// @nodoc
class _$BaseBatchUnitCopyWithImpl<$Res, $Val extends BaseBatchUnit>
    implements $BaseBatchUnitCopyWith<$Res> {
  _$BaseBatchUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseBatchUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? qtyPerBatch = null,
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
            uom: null == uom
                ? _value.uom
                : uom // ignore: cast_nullable_to_non_nullable
                      as String,
            qtyPerBatch: null == qtyPerBatch
                ? _value.qtyPerBatch
                : qtyPerBatch // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseBatchUnitImplCopyWith<$Res>
    implements $BaseBatchUnitCopyWith<$Res> {
  factory _$$BaseBatchUnitImplCopyWith(
    _$BaseBatchUnitImpl value,
    $Res Function(_$BaseBatchUnitImpl) then,
  ) = __$$BaseBatchUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String uom,
    @JsonKey(name: 'qty_per_batch') double qtyPerBatch,
  });
}

/// @nodoc
class __$$BaseBatchUnitImplCopyWithImpl<$Res>
    extends _$BaseBatchUnitCopyWithImpl<$Res, _$BaseBatchUnitImpl>
    implements _$$BaseBatchUnitImplCopyWith<$Res> {
  __$$BaseBatchUnitImplCopyWithImpl(
    _$BaseBatchUnitImpl _value,
    $Res Function(_$BaseBatchUnitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseBatchUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? qtyPerBatch = null,
  }) {
    return _then(
      _$BaseBatchUnitImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        uom: null == uom
            ? _value.uom
            : uom // ignore: cast_nullable_to_non_nullable
                  as String,
        qtyPerBatch: null == qtyPerBatch
            ? _value.qtyPerBatch
            : qtyPerBatch // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseBatchUnitImpl extends _BaseBatchUnit {
  const _$BaseBatchUnitImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.uom = '',
    @JsonKey(name: 'qty_per_batch') this.qtyPerBatch = 0.0,
  }) : super._();

  factory _$BaseBatchUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseBatchUnitImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  @JsonKey()
  final String uom;

  /// How many of it one batch takes.
  @override
  @JsonKey(name: 'qty_per_batch')
  final double qtyPerBatch;

  @override
  String toString() {
    return 'BaseBatchUnit(itemCode: $itemCode, itemName: $itemName, uom: $uom, qtyPerBatch: $qtyPerBatch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseBatchUnitImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.qtyPerBatch, qtyPerBatch) ||
                other.qtyPerBatch == qtyPerBatch));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemCode, itemName, uom, qtyPerBatch);

  /// Create a copy of BaseBatchUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseBatchUnitImplCopyWith<_$BaseBatchUnitImpl> get copyWith =>
      __$$BaseBatchUnitImplCopyWithImpl<_$BaseBatchUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseBatchUnitImplToJson(this);
  }
}

abstract class _BaseBatchUnit extends BaseBatchUnit {
  const factory _BaseBatchUnit({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String uom,
    @JsonKey(name: 'qty_per_batch') final double qtyPerBatch,
  }) = _$BaseBatchUnitImpl;
  const _BaseBatchUnit._() : super._();

  factory _BaseBatchUnit.fromJson(Map<String, dynamic> json) =
      _$BaseBatchUnitImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String get uom;

  /// How many of it one batch takes.
  @override
  @JsonKey(name: 'qty_per_batch')
  double get qtyPerBatch;

  /// Create a copy of BaseBatchUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseBatchUnitImplCopyWith<_$BaseBatchUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BaseJarConsumer _$BaseJarConsumerFromJson(Map<String, dynamic> json) {
  return _BaseJarConsumer.fromJson(json);
}

/// @nodoc
mixin _$BaseJarConsumer {
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;

  /// In the BASE's stock UOM, per one jar.
  @JsonKey(name: 'qty_per_jar')
  double get qtyPerJar => throw _privateConstructorUsedError;

  /// Serializes this BaseJarConsumer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BaseJarConsumer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BaseJarConsumerCopyWith<BaseJarConsumer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseJarConsumerCopyWith<$Res> {
  factory $BaseJarConsumerCopyWith(
    BaseJarConsumer value,
    $Res Function(BaseJarConsumer) then,
  ) = _$BaseJarConsumerCopyWithImpl<$Res, BaseJarConsumer>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'qty_per_jar') double qtyPerJar,
  });
}

/// @nodoc
class _$BaseJarConsumerCopyWithImpl<$Res, $Val extends BaseJarConsumer>
    implements $BaseJarConsumerCopyWith<$Res> {
  _$BaseJarConsumerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BaseJarConsumer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? qtyPerJar = null,
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
            qtyPerJar: null == qtyPerJar
                ? _value.qtyPerJar
                : qtyPerJar // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BaseJarConsumerImplCopyWith<$Res>
    implements $BaseJarConsumerCopyWith<$Res> {
  factory _$$BaseJarConsumerImplCopyWith(
    _$BaseJarConsumerImpl value,
    $Res Function(_$BaseJarConsumerImpl) then,
  ) = __$$BaseJarConsumerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'qty_per_jar') double qtyPerJar,
  });
}

/// @nodoc
class __$$BaseJarConsumerImplCopyWithImpl<$Res>
    extends _$BaseJarConsumerCopyWithImpl<$Res, _$BaseJarConsumerImpl>
    implements _$$BaseJarConsumerImplCopyWith<$Res> {
  __$$BaseJarConsumerImplCopyWithImpl(
    _$BaseJarConsumerImpl _value,
    $Res Function(_$BaseJarConsumerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BaseJarConsumer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemCode = null,
    Object? itemName = null,
    Object? qtyPerJar = null,
  }) {
    return _then(
      _$BaseJarConsumerImpl(
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        qtyPerJar: null == qtyPerJar
            ? _value.qtyPerJar
            : qtyPerJar // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BaseJarConsumerImpl extends _BaseJarConsumer {
  const _$BaseJarConsumerImpl({
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    @JsonKey(name: 'qty_per_jar') this.qtyPerJar = 0.0,
  }) : super._();

  factory _$BaseJarConsumerImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseJarConsumerImplFromJson(json);

  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;

  /// In the BASE's stock UOM, per one jar.
  @override
  @JsonKey(name: 'qty_per_jar')
  final double qtyPerJar;

  @override
  String toString() {
    return 'BaseJarConsumer(itemCode: $itemCode, itemName: $itemName, qtyPerJar: $qtyPerJar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseJarConsumerImpl &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.qtyPerJar, qtyPerJar) ||
                other.qtyPerJar == qtyPerJar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemCode, itemName, qtyPerJar);

  /// Create a copy of BaseJarConsumer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseJarConsumerImplCopyWith<_$BaseJarConsumerImpl> get copyWith =>
      __$$BaseJarConsumerImplCopyWithImpl<_$BaseJarConsumerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseJarConsumerImplToJson(this);
  }
}

abstract class _BaseJarConsumer extends BaseJarConsumer {
  const factory _BaseJarConsumer({
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    @JsonKey(name: 'qty_per_jar') final double qtyPerJar,
  }) = _$BaseJarConsumerImpl;
  const _BaseJarConsumer._() : super._();

  factory _BaseJarConsumer.fromJson(Map<String, dynamic> json) =
      _$BaseJarConsumerImpl.fromJson;

  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;

  /// In the BASE's stock UOM, per one jar.
  @override
  @JsonKey(name: 'qty_per_jar')
  double get qtyPerJar;

  /// Create a copy of BaseJarConsumer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BaseJarConsumerImplCopyWith<_$BaseJarConsumerImpl> get copyWith =>
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

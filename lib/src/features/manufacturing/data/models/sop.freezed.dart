// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SopDocument _$SopDocumentFromJson(Map<String, dynamic> json) {
  return _SopDocument.fromJson(json);
}

/// @nodoc
mixin _$SopDocument {
  @JsonKey(name: 'has_sop')
  bool get hasSop => throw _privateConstructorUsedError;

  /// SOP document name. Empty when [hasSop] is false — most items have none,
  /// and that is a normal answer rather than an error.
  String get sop => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_code')
  String get itemCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_name')
  String get itemName => throw _privateConstructorUsedError;
  String? get bom => throw _privateConstructorUsedError;
  @JsonKey(name: 'yield_percent')
  double get yieldPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'prep_time_mins')
  int get prepTimeMins => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;
  double get batches => throw _privateConstructorUsedError;
  double get units => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_duration_mins')
  double get totalDurationMins => throw _privateConstructorUsedError;
  List<SopStep> get steps => throw _privateConstructorUsedError;

  /// Tokens the server could not resolve, e.g. a misspelled item code. Shown
  /// prominently rather than swallowed — a broken token in an instruction is
  /// otherwise invisible until somebody makes the wrong thing.
  @JsonKey(name: 'unresolved_tokens')
  List<String> get unresolvedTokens => throw _privateConstructorUsedError;

  /// Serializes this SopDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SopDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SopDocumentCopyWith<SopDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SopDocumentCopyWith<$Res> {
  factory $SopDocumentCopyWith(
    SopDocument value,
    $Res Function(SopDocument) then,
  ) = _$SopDocumentCopyWithImpl<$Res, SopDocument>;
  @useResult
  $Res call({
    @JsonKey(name: 'has_sop') bool hasSop,
    String sop,
    int version,
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String? bom,
    @JsonKey(name: 'yield_percent') double yieldPercent,
    @JsonKey(name: 'prep_time_mins') int prepTimeMins,
    String? equipment,
    double batches,
    double units,
    @JsonKey(name: 'total_duration_mins') double totalDurationMins,
    List<SopStep> steps,
    @JsonKey(name: 'unresolved_tokens') List<String> unresolvedTokens,
  });
}

/// @nodoc
class _$SopDocumentCopyWithImpl<$Res, $Val extends SopDocument>
    implements $SopDocumentCopyWith<$Res> {
  _$SopDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SopDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasSop = null,
    Object? sop = null,
    Object? version = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? bom = freezed,
    Object? yieldPercent = null,
    Object? prepTimeMins = null,
    Object? equipment = freezed,
    Object? batches = null,
    Object? units = null,
    Object? totalDurationMins = null,
    Object? steps = null,
    Object? unresolvedTokens = null,
  }) {
    return _then(
      _value.copyWith(
            hasSop: null == hasSop
                ? _value.hasSop
                : hasSop // ignore: cast_nullable_to_non_nullable
                      as bool,
            sop: null == sop
                ? _value.sop
                : sop // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            itemCode: null == itemCode
                ? _value.itemCode
                : itemCode // ignore: cast_nullable_to_non_nullable
                      as String,
            itemName: null == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                      as String,
            bom: freezed == bom
                ? _value.bom
                : bom // ignore: cast_nullable_to_non_nullable
                      as String?,
            yieldPercent: null == yieldPercent
                ? _value.yieldPercent
                : yieldPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            prepTimeMins: null == prepTimeMins
                ? _value.prepTimeMins
                : prepTimeMins // ignore: cast_nullable_to_non_nullable
                      as int,
            equipment: freezed == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as String?,
            batches: null == batches
                ? _value.batches
                : batches // ignore: cast_nullable_to_non_nullable
                      as double,
            units: null == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDurationMins: null == totalDurationMins
                ? _value.totalDurationMins
                : totalDurationMins // ignore: cast_nullable_to_non_nullable
                      as double,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<SopStep>,
            unresolvedTokens: null == unresolvedTokens
                ? _value.unresolvedTokens
                : unresolvedTokens // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SopDocumentImplCopyWith<$Res>
    implements $SopDocumentCopyWith<$Res> {
  factory _$$SopDocumentImplCopyWith(
    _$SopDocumentImpl value,
    $Res Function(_$SopDocumentImpl) then,
  ) = __$$SopDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'has_sop') bool hasSop,
    String sop,
    int version,
    @JsonKey(name: 'item_code') String itemCode,
    @JsonKey(name: 'item_name') String itemName,
    String? bom,
    @JsonKey(name: 'yield_percent') double yieldPercent,
    @JsonKey(name: 'prep_time_mins') int prepTimeMins,
    String? equipment,
    double batches,
    double units,
    @JsonKey(name: 'total_duration_mins') double totalDurationMins,
    List<SopStep> steps,
    @JsonKey(name: 'unresolved_tokens') List<String> unresolvedTokens,
  });
}

/// @nodoc
class __$$SopDocumentImplCopyWithImpl<$Res>
    extends _$SopDocumentCopyWithImpl<$Res, _$SopDocumentImpl>
    implements _$$SopDocumentImplCopyWith<$Res> {
  __$$SopDocumentImplCopyWithImpl(
    _$SopDocumentImpl _value,
    $Res Function(_$SopDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SopDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasSop = null,
    Object? sop = null,
    Object? version = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? bom = freezed,
    Object? yieldPercent = null,
    Object? prepTimeMins = null,
    Object? equipment = freezed,
    Object? batches = null,
    Object? units = null,
    Object? totalDurationMins = null,
    Object? steps = null,
    Object? unresolvedTokens = null,
  }) {
    return _then(
      _$SopDocumentImpl(
        hasSop: null == hasSop
            ? _value.hasSop
            : hasSop // ignore: cast_nullable_to_non_nullable
                  as bool,
        sop: null == sop
            ? _value.sop
            : sop // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        itemCode: null == itemCode
            ? _value.itemCode
            : itemCode // ignore: cast_nullable_to_non_nullable
                  as String,
        itemName: null == itemName
            ? _value.itemName
            : itemName // ignore: cast_nullable_to_non_nullable
                  as String,
        bom: freezed == bom
            ? _value.bom
            : bom // ignore: cast_nullable_to_non_nullable
                  as String?,
        yieldPercent: null == yieldPercent
            ? _value.yieldPercent
            : yieldPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        prepTimeMins: null == prepTimeMins
            ? _value.prepTimeMins
            : prepTimeMins // ignore: cast_nullable_to_non_nullable
                  as int,
        equipment: freezed == equipment
            ? _value.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as String?,
        batches: null == batches
            ? _value.batches
            : batches // ignore: cast_nullable_to_non_nullable
                  as double,
        units: null == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDurationMins: null == totalDurationMins
            ? _value.totalDurationMins
            : totalDurationMins // ignore: cast_nullable_to_non_nullable
                  as double,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<SopStep>,
        unresolvedTokens: null == unresolvedTokens
            ? _value._unresolvedTokens
            : unresolvedTokens // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SopDocumentImpl extends _SopDocument {
  const _$SopDocumentImpl({
    @JsonKey(name: 'has_sop') this.hasSop = false,
    this.sop = '',
    this.version = 1,
    @JsonKey(name: 'item_code') this.itemCode = '',
    @JsonKey(name: 'item_name') this.itemName = '',
    this.bom,
    @JsonKey(name: 'yield_percent') this.yieldPercent = 100.0,
    @JsonKey(name: 'prep_time_mins') this.prepTimeMins = 0,
    this.equipment,
    this.batches = 1.0,
    this.units = 0.0,
    @JsonKey(name: 'total_duration_mins') this.totalDurationMins = 0.0,
    final List<SopStep> steps = const <SopStep>[],
    @JsonKey(name: 'unresolved_tokens')
    final List<String> unresolvedTokens = const <String>[],
  }) : _steps = steps,
       _unresolvedTokens = unresolvedTokens,
       super._();

  factory _$SopDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SopDocumentImplFromJson(json);

  @override
  @JsonKey(name: 'has_sop')
  final bool hasSop;

  /// SOP document name. Empty when [hasSop] is false — most items have none,
  /// and that is a normal answer rather than an error.
  @override
  @JsonKey()
  final String sop;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey(name: 'item_code')
  final String itemCode;
  @override
  @JsonKey(name: 'item_name')
  final String itemName;
  @override
  final String? bom;
  @override
  @JsonKey(name: 'yield_percent')
  final double yieldPercent;
  @override
  @JsonKey(name: 'prep_time_mins')
  final int prepTimeMins;
  @override
  final String? equipment;
  @override
  @JsonKey()
  final double batches;
  @override
  @JsonKey()
  final double units;
  @override
  @JsonKey(name: 'total_duration_mins')
  final double totalDurationMins;
  final List<SopStep> _steps;
  @override
  @JsonKey()
  List<SopStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  /// Tokens the server could not resolve, e.g. a misspelled item code. Shown
  /// prominently rather than swallowed — a broken token in an instruction is
  /// otherwise invisible until somebody makes the wrong thing.
  final List<String> _unresolvedTokens;

  /// Tokens the server could not resolve, e.g. a misspelled item code. Shown
  /// prominently rather than swallowed — a broken token in an instruction is
  /// otherwise invisible until somebody makes the wrong thing.
  @override
  @JsonKey(name: 'unresolved_tokens')
  List<String> get unresolvedTokens {
    if (_unresolvedTokens is EqualUnmodifiableListView)
      return _unresolvedTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unresolvedTokens);
  }

  @override
  String toString() {
    return 'SopDocument(hasSop: $hasSop, sop: $sop, version: $version, itemCode: $itemCode, itemName: $itemName, bom: $bom, yieldPercent: $yieldPercent, prepTimeMins: $prepTimeMins, equipment: $equipment, batches: $batches, units: $units, totalDurationMins: $totalDurationMins, steps: $steps, unresolvedTokens: $unresolvedTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SopDocumentImpl &&
            (identical(other.hasSop, hasSop) || other.hasSop == hasSop) &&
            (identical(other.sop, sop) || other.sop == sop) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.bom, bom) || other.bom == bom) &&
            (identical(other.yieldPercent, yieldPercent) ||
                other.yieldPercent == yieldPercent) &&
            (identical(other.prepTimeMins, prepTimeMins) ||
                other.prepTimeMins == prepTimeMins) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.batches, batches) || other.batches == batches) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.totalDurationMins, totalDurationMins) ||
                other.totalDurationMins == totalDurationMins) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality().equals(
              other._unresolvedTokens,
              _unresolvedTokens,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasSop,
    sop,
    version,
    itemCode,
    itemName,
    bom,
    yieldPercent,
    prepTimeMins,
    equipment,
    batches,
    units,
    totalDurationMins,
    const DeepCollectionEquality().hash(_steps),
    const DeepCollectionEquality().hash(_unresolvedTokens),
  );

  /// Create a copy of SopDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SopDocumentImplCopyWith<_$SopDocumentImpl> get copyWith =>
      __$$SopDocumentImplCopyWithImpl<_$SopDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SopDocumentImplToJson(this);
  }
}

abstract class _SopDocument extends SopDocument {
  const factory _SopDocument({
    @JsonKey(name: 'has_sop') final bool hasSop,
    final String sop,
    final int version,
    @JsonKey(name: 'item_code') final String itemCode,
    @JsonKey(name: 'item_name') final String itemName,
    final String? bom,
    @JsonKey(name: 'yield_percent') final double yieldPercent,
    @JsonKey(name: 'prep_time_mins') final int prepTimeMins,
    final String? equipment,
    final double batches,
    final double units,
    @JsonKey(name: 'total_duration_mins') final double totalDurationMins,
    final List<SopStep> steps,
    @JsonKey(name: 'unresolved_tokens') final List<String> unresolvedTokens,
  }) = _$SopDocumentImpl;
  const _SopDocument._() : super._();

  factory _SopDocument.fromJson(Map<String, dynamic> json) =
      _$SopDocumentImpl.fromJson;

  @override
  @JsonKey(name: 'has_sop')
  bool get hasSop;

  /// SOP document name. Empty when [hasSop] is false — most items have none,
  /// and that is a normal answer rather than an error.
  @override
  String get sop;
  @override
  int get version;
  @override
  @JsonKey(name: 'item_code')
  String get itemCode;
  @override
  @JsonKey(name: 'item_name')
  String get itemName;
  @override
  String? get bom;
  @override
  @JsonKey(name: 'yield_percent')
  double get yieldPercent;
  @override
  @JsonKey(name: 'prep_time_mins')
  int get prepTimeMins;
  @override
  String? get equipment;
  @override
  double get batches;
  @override
  double get units;
  @override
  @JsonKey(name: 'total_duration_mins')
  double get totalDurationMins;
  @override
  List<SopStep> get steps;

  /// Tokens the server could not resolve, e.g. a misspelled item code. Shown
  /// prominently rather than swallowed — a broken token in an instruction is
  /// otherwise invisible until somebody makes the wrong thing.
  @override
  @JsonKey(name: 'unresolved_tokens')
  List<String> get unresolvedTokens;

  /// Create a copy of SopDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SopDocumentImplCopyWith<_$SopDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SopStep _$SopStepFromJson(Map<String, dynamic> json) {
  return _SopStep.fromJson(json);
}

/// @nodoc
mixin _$SopStep {
  @JsonKey(name: 'step_no')
  int get stepNo => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Plain text with `{{item:CODE}}` tokens already substituted at the
  /// requested batch count. Rendered instead of the HTML so the app needs no
  /// HTML package.
  @JsonKey(name: 'instruction_text')
  String get instructionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'instruction_html')
  String get instructionHtml => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_mins')
  double get durationMins => throw _privateConstructorUsedError;
  @JsonKey(name: 'scaling_mode')
  String get scalingMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_confirmation')
  bool get requiresConfirmation => throw _privateConstructorUsedError;
  @JsonKey(name: 'capture_type')
  String get captureType => throw _privateConstructorUsedError;
  @JsonKey(name: 'capture_label')
  String? get captureLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'capture_min')
  double? get captureMin => throw _privateConstructorUsedError;
  @JsonKey(name: 'capture_max')
  double? get captureMax => throw _privateConstructorUsedError;

  /// Serializes this SopStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SopStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SopStepCopyWith<SopStep> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SopStepCopyWith<$Res> {
  factory $SopStepCopyWith(SopStep value, $Res Function(SopStep) then) =
      _$SopStepCopyWithImpl<$Res, SopStep>;
  @useResult
  $Res call({
    @JsonKey(name: 'step_no') int stepNo,
    String title,
    @JsonKey(name: 'instruction_text') String instructionText,
    @JsonKey(name: 'instruction_html') String instructionHtml,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'duration_mins') double durationMins,
    @JsonKey(name: 'scaling_mode') String scalingMode,
    @JsonKey(name: 'requires_confirmation') bool requiresConfirmation,
    @JsonKey(name: 'capture_type') String captureType,
    @JsonKey(name: 'capture_label') String? captureLabel,
    @JsonKey(name: 'capture_min') double? captureMin,
    @JsonKey(name: 'capture_max') double? captureMax,
  });
}

/// @nodoc
class _$SopStepCopyWithImpl<$Res, $Val extends SopStep>
    implements $SopStepCopyWith<$Res> {
  _$SopStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SopStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stepNo = null,
    Object? title = null,
    Object? instructionText = null,
    Object? instructionHtml = null,
    Object? imageUrl = freezed,
    Object? durationMins = null,
    Object? scalingMode = null,
    Object? requiresConfirmation = null,
    Object? captureType = null,
    Object? captureLabel = freezed,
    Object? captureMin = freezed,
    Object? captureMax = freezed,
  }) {
    return _then(
      _value.copyWith(
            stepNo: null == stepNo
                ? _value.stepNo
                : stepNo // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            instructionText: null == instructionText
                ? _value.instructionText
                : instructionText // ignore: cast_nullable_to_non_nullable
                      as String,
            instructionHtml: null == instructionHtml
                ? _value.instructionHtml
                : instructionHtml // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationMins: null == durationMins
                ? _value.durationMins
                : durationMins // ignore: cast_nullable_to_non_nullable
                      as double,
            scalingMode: null == scalingMode
                ? _value.scalingMode
                : scalingMode // ignore: cast_nullable_to_non_nullable
                      as String,
            requiresConfirmation: null == requiresConfirmation
                ? _value.requiresConfirmation
                : requiresConfirmation // ignore: cast_nullable_to_non_nullable
                      as bool,
            captureType: null == captureType
                ? _value.captureType
                : captureType // ignore: cast_nullable_to_non_nullable
                      as String,
            captureLabel: freezed == captureLabel
                ? _value.captureLabel
                : captureLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            captureMin: freezed == captureMin
                ? _value.captureMin
                : captureMin // ignore: cast_nullable_to_non_nullable
                      as double?,
            captureMax: freezed == captureMax
                ? _value.captureMax
                : captureMax // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SopStepImplCopyWith<$Res> implements $SopStepCopyWith<$Res> {
  factory _$$SopStepImplCopyWith(
    _$SopStepImpl value,
    $Res Function(_$SopStepImpl) then,
  ) = __$$SopStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'step_no') int stepNo,
    String title,
    @JsonKey(name: 'instruction_text') String instructionText,
    @JsonKey(name: 'instruction_html') String instructionHtml,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'duration_mins') double durationMins,
    @JsonKey(name: 'scaling_mode') String scalingMode,
    @JsonKey(name: 'requires_confirmation') bool requiresConfirmation,
    @JsonKey(name: 'capture_type') String captureType,
    @JsonKey(name: 'capture_label') String? captureLabel,
    @JsonKey(name: 'capture_min') double? captureMin,
    @JsonKey(name: 'capture_max') double? captureMax,
  });
}

/// @nodoc
class __$$SopStepImplCopyWithImpl<$Res>
    extends _$SopStepCopyWithImpl<$Res, _$SopStepImpl>
    implements _$$SopStepImplCopyWith<$Res> {
  __$$SopStepImplCopyWithImpl(
    _$SopStepImpl _value,
    $Res Function(_$SopStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SopStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stepNo = null,
    Object? title = null,
    Object? instructionText = null,
    Object? instructionHtml = null,
    Object? imageUrl = freezed,
    Object? durationMins = null,
    Object? scalingMode = null,
    Object? requiresConfirmation = null,
    Object? captureType = null,
    Object? captureLabel = freezed,
    Object? captureMin = freezed,
    Object? captureMax = freezed,
  }) {
    return _then(
      _$SopStepImpl(
        stepNo: null == stepNo
            ? _value.stepNo
            : stepNo // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        instructionText: null == instructionText
            ? _value.instructionText
            : instructionText // ignore: cast_nullable_to_non_nullable
                  as String,
        instructionHtml: null == instructionHtml
            ? _value.instructionHtml
            : instructionHtml // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationMins: null == durationMins
            ? _value.durationMins
            : durationMins // ignore: cast_nullable_to_non_nullable
                  as double,
        scalingMode: null == scalingMode
            ? _value.scalingMode
            : scalingMode // ignore: cast_nullable_to_non_nullable
                  as String,
        requiresConfirmation: null == requiresConfirmation
            ? _value.requiresConfirmation
            : requiresConfirmation // ignore: cast_nullable_to_non_nullable
                  as bool,
        captureType: null == captureType
            ? _value.captureType
            : captureType // ignore: cast_nullable_to_non_nullable
                  as String,
        captureLabel: freezed == captureLabel
            ? _value.captureLabel
            : captureLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        captureMin: freezed == captureMin
            ? _value.captureMin
            : captureMin // ignore: cast_nullable_to_non_nullable
                  as double?,
        captureMax: freezed == captureMax
            ? _value.captureMax
            : captureMax // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SopStepImpl extends _SopStep {
  const _$SopStepImpl({
    @JsonKey(name: 'step_no') this.stepNo = 0,
    this.title = '',
    @JsonKey(name: 'instruction_text') this.instructionText = '',
    @JsonKey(name: 'instruction_html') this.instructionHtml = '',
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'duration_mins') this.durationMins = 0.0,
    @JsonKey(name: 'scaling_mode') this.scalingMode = SopScaling.fixed,
    @JsonKey(name: 'requires_confirmation') this.requiresConfirmation = true,
    @JsonKey(name: 'capture_type') this.captureType = SopCapture.none,
    @JsonKey(name: 'capture_label') this.captureLabel,
    @JsonKey(name: 'capture_min') this.captureMin,
    @JsonKey(name: 'capture_max') this.captureMax,
  }) : super._();

  factory _$SopStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$SopStepImplFromJson(json);

  @override
  @JsonKey(name: 'step_no')
  final int stepNo;
  @override
  @JsonKey()
  final String title;

  /// Plain text with `{{item:CODE}}` tokens already substituted at the
  /// requested batch count. Rendered instead of the HTML so the app needs no
  /// HTML package.
  @override
  @JsonKey(name: 'instruction_text')
  final String instructionText;
  @override
  @JsonKey(name: 'instruction_html')
  final String instructionHtml;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'duration_mins')
  final double durationMins;
  @override
  @JsonKey(name: 'scaling_mode')
  final String scalingMode;
  @override
  @JsonKey(name: 'requires_confirmation')
  final bool requiresConfirmation;
  @override
  @JsonKey(name: 'capture_type')
  final String captureType;
  @override
  @JsonKey(name: 'capture_label')
  final String? captureLabel;
  @override
  @JsonKey(name: 'capture_min')
  final double? captureMin;
  @override
  @JsonKey(name: 'capture_max')
  final double? captureMax;

  @override
  String toString() {
    return 'SopStep(stepNo: $stepNo, title: $title, instructionText: $instructionText, instructionHtml: $instructionHtml, imageUrl: $imageUrl, durationMins: $durationMins, scalingMode: $scalingMode, requiresConfirmation: $requiresConfirmation, captureType: $captureType, captureLabel: $captureLabel, captureMin: $captureMin, captureMax: $captureMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SopStepImpl &&
            (identical(other.stepNo, stepNo) || other.stepNo == stepNo) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.instructionText, instructionText) ||
                other.instructionText == instructionText) &&
            (identical(other.instructionHtml, instructionHtml) ||
                other.instructionHtml == instructionHtml) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.durationMins, durationMins) ||
                other.durationMins == durationMins) &&
            (identical(other.scalingMode, scalingMode) ||
                other.scalingMode == scalingMode) &&
            (identical(other.requiresConfirmation, requiresConfirmation) ||
                other.requiresConfirmation == requiresConfirmation) &&
            (identical(other.captureType, captureType) ||
                other.captureType == captureType) &&
            (identical(other.captureLabel, captureLabel) ||
                other.captureLabel == captureLabel) &&
            (identical(other.captureMin, captureMin) ||
                other.captureMin == captureMin) &&
            (identical(other.captureMax, captureMax) ||
                other.captureMax == captureMax));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stepNo,
    title,
    instructionText,
    instructionHtml,
    imageUrl,
    durationMins,
    scalingMode,
    requiresConfirmation,
    captureType,
    captureLabel,
    captureMin,
    captureMax,
  );

  /// Create a copy of SopStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SopStepImplCopyWith<_$SopStepImpl> get copyWith =>
      __$$SopStepImplCopyWithImpl<_$SopStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SopStepImplToJson(this);
  }
}

abstract class _SopStep extends SopStep {
  const factory _SopStep({
    @JsonKey(name: 'step_no') final int stepNo,
    final String title,
    @JsonKey(name: 'instruction_text') final String instructionText,
    @JsonKey(name: 'instruction_html') final String instructionHtml,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'duration_mins') final double durationMins,
    @JsonKey(name: 'scaling_mode') final String scalingMode,
    @JsonKey(name: 'requires_confirmation') final bool requiresConfirmation,
    @JsonKey(name: 'capture_type') final String captureType,
    @JsonKey(name: 'capture_label') final String? captureLabel,
    @JsonKey(name: 'capture_min') final double? captureMin,
    @JsonKey(name: 'capture_max') final double? captureMax,
  }) = _$SopStepImpl;
  const _SopStep._() : super._();

  factory _SopStep.fromJson(Map<String, dynamic> json) = _$SopStepImpl.fromJson;

  @override
  @JsonKey(name: 'step_no')
  int get stepNo;
  @override
  String get title;

  /// Plain text with `{{item:CODE}}` tokens already substituted at the
  /// requested batch count. Rendered instead of the HTML so the app needs no
  /// HTML package.
  @override
  @JsonKey(name: 'instruction_text')
  String get instructionText;
  @override
  @JsonKey(name: 'instruction_html')
  String get instructionHtml;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'duration_mins')
  double get durationMins;
  @override
  @JsonKey(name: 'scaling_mode')
  String get scalingMode;
  @override
  @JsonKey(name: 'requires_confirmation')
  bool get requiresConfirmation;
  @override
  @JsonKey(name: 'capture_type')
  String get captureType;
  @override
  @JsonKey(name: 'capture_label')
  String? get captureLabel;
  @override
  @JsonKey(name: 'capture_min')
  double? get captureMin;
  @override
  @JsonKey(name: 'capture_max')
  double? get captureMax;

  /// Create a copy of SopStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SopStepImplCopyWith<_$SopStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

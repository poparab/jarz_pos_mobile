// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'b2b_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

B2bCard _$B2bCardFromJson(Map<String, dynamic> json) {
  return _B2bCard.fromJson(json);
}

/// @nodoc
mixin _$B2bCard {
  String get doctype => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;
  String? get owner => throw _privateConstructorUsedError;
  @JsonKey(name: 'lead_score')
  int? get leadScore => throw _privateConstructorUsedError;
  String? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_activity')
  String? get lastActivity => throw _privateConstructorUsedError; // How many of this account's labels need printing (0 when none / when the
  // backend predates the labels feature — absent keys default here).
  @JsonKey(name: 'label_alert')
  int get labelAlert => throw _privateConstructorUsedError; // ── Journey diary summary ──────────────────────────────────────────
  // Folded in by `crm.get_b2b_pipeline` so the board shows when a prospect
  // was last visited and what is due, without a request per card.
  @JsonKey(name: 'journey_count')
  int get journeyCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_date')
  String? get lastJourneyDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_type')
  String? get lastJourneyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_note')
  String? get lastJourneyNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_journey_contact')
  String? get lastJourneyContact => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action')
  String? get nextAction => throw _privateConstructorUsedError;

  /// Serializes this B2bCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bCardCopyWith<B2bCard> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bCardCopyWith<$Res> {
  factory $B2bCardCopyWith(B2bCard value, $Res Function(B2bCard) then) =
      _$B2bCardCopyWithImpl<$Res, B2bCard>;
  @useResult
  $Res call({
    String doctype,
    String name,
    String title,
    String stage,
    String? owner,
    @JsonKey(name: 'lead_score') int? leadScore,
    String? customer,
    @JsonKey(name: 'last_activity') String? lastActivity,
    @JsonKey(name: 'label_alert') int labelAlert,
    @JsonKey(name: 'journey_count') int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
  });
}

/// @nodoc
class _$B2bCardCopyWithImpl<$Res, $Val extends B2bCard>
    implements $B2bCardCopyWith<$Res> {
  _$B2bCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = null,
    Object? stage = null,
    Object? owner = freezed,
    Object? leadScore = freezed,
    Object? customer = freezed,
    Object? lastActivity = freezed,
    Object? labelAlert = null,
    Object? journeyCount = null,
    Object? lastJourneyDate = freezed,
    Object? lastJourneyType = freezed,
    Object? lastJourneyNote = freezed,
    Object? lastJourneyContact = freezed,
    Object? nextActionDate = freezed,
    Object? nextAction = freezed,
  }) {
    return _then(
      _value.copyWith(
            doctype: null == doctype
                ? _value.doctype
                : doctype // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as String,
            owner: freezed == owner
                ? _value.owner
                : owner // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadScore: freezed == leadScore
                ? _value.leadScore
                : leadScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastActivity: freezed == lastActivity
                ? _value.lastActivity
                : lastActivity // ignore: cast_nullable_to_non_nullable
                      as String?,
            labelAlert: null == labelAlert
                ? _value.labelAlert
                : labelAlert // ignore: cast_nullable_to_non_nullable
                      as int,
            journeyCount: null == journeyCount
                ? _value.journeyCount
                : journeyCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastJourneyDate: freezed == lastJourneyDate
                ? _value.lastJourneyDate
                : lastJourneyDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyType: freezed == lastJourneyType
                ? _value.lastJourneyType
                : lastJourneyType // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyNote: freezed == lastJourneyNote
                ? _value.lastJourneyNote
                : lastJourneyNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastJourneyContact: freezed == lastJourneyContact
                ? _value.lastJourneyContact
                : lastJourneyContact // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextActionDate: freezed == nextActionDate
                ? _value.nextActionDate
                : nextActionDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextAction: freezed == nextAction
                ? _value.nextAction
                : nextAction // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bCardImplCopyWith<$Res> implements $B2bCardCopyWith<$Res> {
  factory _$$B2bCardImplCopyWith(
    _$B2bCardImpl value,
    $Res Function(_$B2bCardImpl) then,
  ) = __$$B2bCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String doctype,
    String name,
    String title,
    String stage,
    String? owner,
    @JsonKey(name: 'lead_score') int? leadScore,
    String? customer,
    @JsonKey(name: 'last_activity') String? lastActivity,
    @JsonKey(name: 'label_alert') int labelAlert,
    @JsonKey(name: 'journey_count') int journeyCount,
    @JsonKey(name: 'last_journey_date') String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    @JsonKey(name: 'next_action') String? nextAction,
  });
}

/// @nodoc
class __$$B2bCardImplCopyWithImpl<$Res>
    extends _$B2bCardCopyWithImpl<$Res, _$B2bCardImpl>
    implements _$$B2bCardImplCopyWith<$Res> {
  __$$B2bCardImplCopyWithImpl(
    _$B2bCardImpl _value,
    $Res Function(_$B2bCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = null,
    Object? stage = null,
    Object? owner = freezed,
    Object? leadScore = freezed,
    Object? customer = freezed,
    Object? lastActivity = freezed,
    Object? labelAlert = null,
    Object? journeyCount = null,
    Object? lastJourneyDate = freezed,
    Object? lastJourneyType = freezed,
    Object? lastJourneyNote = freezed,
    Object? lastJourneyContact = freezed,
    Object? nextActionDate = freezed,
    Object? nextAction = freezed,
  }) {
    return _then(
      _$B2bCardImpl(
        doctype: null == doctype
            ? _value.doctype
            : doctype // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String,
        owner: freezed == owner
            ? _value.owner
            : owner // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadScore: freezed == leadScore
            ? _value.leadScore
            : leadScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastActivity: freezed == lastActivity
            ? _value.lastActivity
            : lastActivity // ignore: cast_nullable_to_non_nullable
                  as String?,
        labelAlert: null == labelAlert
            ? _value.labelAlert
            : labelAlert // ignore: cast_nullable_to_non_nullable
                  as int,
        journeyCount: null == journeyCount
            ? _value.journeyCount
            : journeyCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastJourneyDate: freezed == lastJourneyDate
            ? _value.lastJourneyDate
            : lastJourneyDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyType: freezed == lastJourneyType
            ? _value.lastJourneyType
            : lastJourneyType // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyNote: freezed == lastJourneyNote
            ? _value.lastJourneyNote
            : lastJourneyNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastJourneyContact: freezed == lastJourneyContact
            ? _value.lastJourneyContact
            : lastJourneyContact // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextActionDate: freezed == nextActionDate
            ? _value.nextActionDate
            : nextActionDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextAction: freezed == nextAction
            ? _value.nextAction
            : nextAction // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bCardImpl extends _B2bCard {
  const _$B2bCardImpl({
    required this.doctype,
    required this.name,
    required this.title,
    this.stage = 'Lead',
    this.owner,
    @JsonKey(name: 'lead_score') this.leadScore,
    this.customer,
    @JsonKey(name: 'last_activity') this.lastActivity,
    @JsonKey(name: 'label_alert') this.labelAlert = 0,
    @JsonKey(name: 'journey_count') this.journeyCount = 0,
    @JsonKey(name: 'last_journey_date') this.lastJourneyDate,
    @JsonKey(name: 'last_journey_type') this.lastJourneyType,
    @JsonKey(name: 'last_journey_note') this.lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') this.lastJourneyContact,
    @JsonKey(name: 'next_action_date') this.nextActionDate,
    @JsonKey(name: 'next_action') this.nextAction,
  }) : super._();

  factory _$B2bCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bCardImplFromJson(json);

  @override
  final String doctype;
  @override
  final String name;
  @override
  final String title;
  @override
  @JsonKey()
  final String stage;
  @override
  final String? owner;
  @override
  @JsonKey(name: 'lead_score')
  final int? leadScore;
  @override
  final String? customer;
  @override
  @JsonKey(name: 'last_activity')
  final String? lastActivity;
  // How many of this account's labels need printing (0 when none / when the
  // backend predates the labels feature — absent keys default here).
  @override
  @JsonKey(name: 'label_alert')
  final int labelAlert;
  // ── Journey diary summary ──────────────────────────────────────────
  // Folded in by `crm.get_b2b_pipeline` so the board shows when a prospect
  // was last visited and what is due, without a request per card.
  @override
  @JsonKey(name: 'journey_count')
  final int journeyCount;
  @override
  @JsonKey(name: 'last_journey_date')
  final String? lastJourneyDate;
  @override
  @JsonKey(name: 'last_journey_type')
  final String? lastJourneyType;
  @override
  @JsonKey(name: 'last_journey_note')
  final String? lastJourneyNote;
  @override
  @JsonKey(name: 'last_journey_contact')
  final String? lastJourneyContact;
  @override
  @JsonKey(name: 'next_action_date')
  final String? nextActionDate;
  @override
  @JsonKey(name: 'next_action')
  final String? nextAction;

  @override
  String toString() {
    return 'B2bCard(doctype: $doctype, name: $name, title: $title, stage: $stage, owner: $owner, leadScore: $leadScore, customer: $customer, lastActivity: $lastActivity, labelAlert: $labelAlert, journeyCount: $journeyCount, lastJourneyDate: $lastJourneyDate, lastJourneyType: $lastJourneyType, lastJourneyNote: $lastJourneyNote, lastJourneyContact: $lastJourneyContact, nextActionDate: $nextActionDate, nextAction: $nextAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bCardImpl &&
            (identical(other.doctype, doctype) || other.doctype == doctype) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.leadScore, leadScore) ||
                other.leadScore == leadScore) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.labelAlert, labelAlert) ||
                other.labelAlert == labelAlert) &&
            (identical(other.journeyCount, journeyCount) ||
                other.journeyCount == journeyCount) &&
            (identical(other.lastJourneyDate, lastJourneyDate) ||
                other.lastJourneyDate == lastJourneyDate) &&
            (identical(other.lastJourneyType, lastJourneyType) ||
                other.lastJourneyType == lastJourneyType) &&
            (identical(other.lastJourneyNote, lastJourneyNote) ||
                other.lastJourneyNote == lastJourneyNote) &&
            (identical(other.lastJourneyContact, lastJourneyContact) ||
                other.lastJourneyContact == lastJourneyContact) &&
            (identical(other.nextActionDate, nextActionDate) ||
                other.nextActionDate == nextActionDate) &&
            (identical(other.nextAction, nextAction) ||
                other.nextAction == nextAction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    doctype,
    name,
    title,
    stage,
    owner,
    leadScore,
    customer,
    lastActivity,
    labelAlert,
    journeyCount,
    lastJourneyDate,
    lastJourneyType,
    lastJourneyNote,
    lastJourneyContact,
    nextActionDate,
    nextAction,
  );

  /// Create a copy of B2bCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bCardImplCopyWith<_$B2bCardImpl> get copyWith =>
      __$$B2bCardImplCopyWithImpl<_$B2bCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bCardImplToJson(this);
  }
}

abstract class _B2bCard extends B2bCard {
  const factory _B2bCard({
    required final String doctype,
    required final String name,
    required final String title,
    final String stage,
    final String? owner,
    @JsonKey(name: 'lead_score') final int? leadScore,
    final String? customer,
    @JsonKey(name: 'last_activity') final String? lastActivity,
    @JsonKey(name: 'label_alert') final int labelAlert,
    @JsonKey(name: 'journey_count') final int journeyCount,
    @JsonKey(name: 'last_journey_date') final String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') final String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') final String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') final String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') final String? nextActionDate,
    @JsonKey(name: 'next_action') final String? nextAction,
  }) = _$B2bCardImpl;
  const _B2bCard._() : super._();

  factory _B2bCard.fromJson(Map<String, dynamic> json) = _$B2bCardImpl.fromJson;

  @override
  String get doctype;
  @override
  String get name;
  @override
  String get title;
  @override
  String get stage;
  @override
  String? get owner;
  @override
  @JsonKey(name: 'lead_score')
  int? get leadScore;
  @override
  String? get customer;
  @override
  @JsonKey(name: 'last_activity')
  String? get lastActivity; // How many of this account's labels need printing (0 when none / when the
  // backend predates the labels feature — absent keys default here).
  @override
  @JsonKey(name: 'label_alert')
  int get labelAlert; // ── Journey diary summary ──────────────────────────────────────────
  // Folded in by `crm.get_b2b_pipeline` so the board shows when a prospect
  // was last visited and what is due, without a request per card.
  @override
  @JsonKey(name: 'journey_count')
  int get journeyCount;
  @override
  @JsonKey(name: 'last_journey_date')
  String? get lastJourneyDate;
  @override
  @JsonKey(name: 'last_journey_type')
  String? get lastJourneyType;
  @override
  @JsonKey(name: 'last_journey_note')
  String? get lastJourneyNote;
  @override
  @JsonKey(name: 'last_journey_contact')
  String? get lastJourneyContact;
  @override
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate;
  @override
  @JsonKey(name: 'next_action')
  String? get nextAction;

  /// Create a copy of B2bCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bCardImplCopyWith<_$B2bCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$B2bPipeline {
  List<String> get stages => throw _privateConstructorUsedError;
  Map<String, List<B2bCard>> get columns => throw _privateConstructorUsedError;

  /// Create a copy of B2bPipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bPipelineCopyWith<B2bPipeline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bPipelineCopyWith<$Res> {
  factory $B2bPipelineCopyWith(
    B2bPipeline value,
    $Res Function(B2bPipeline) then,
  ) = _$B2bPipelineCopyWithImpl<$Res, B2bPipeline>;
  @useResult
  $Res call({List<String> stages, Map<String, List<B2bCard>> columns});
}

/// @nodoc
class _$B2bPipelineCopyWithImpl<$Res, $Val extends B2bPipeline>
    implements $B2bPipelineCopyWith<$Res> {
  _$B2bPipelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bPipeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stages = null, Object? columns = null}) {
    return _then(
      _value.copyWith(
            stages: null == stages
                ? _value.stages
                : stages // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            columns: null == columns
                ? _value.columns
                : columns // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<B2bCard>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bPipelineImplCopyWith<$Res>
    implements $B2bPipelineCopyWith<$Res> {
  factory _$$B2bPipelineImplCopyWith(
    _$B2bPipelineImpl value,
    $Res Function(_$B2bPipelineImpl) then,
  ) = __$$B2bPipelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> stages, Map<String, List<B2bCard>> columns});
}

/// @nodoc
class __$$B2bPipelineImplCopyWithImpl<$Res>
    extends _$B2bPipelineCopyWithImpl<$Res, _$B2bPipelineImpl>
    implements _$$B2bPipelineImplCopyWith<$Res> {
  __$$B2bPipelineImplCopyWithImpl(
    _$B2bPipelineImpl _value,
    $Res Function(_$B2bPipelineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bPipeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stages = null, Object? columns = null}) {
    return _then(
      _$B2bPipelineImpl(
        stages: null == stages
            ? _value._stages
            : stages // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        columns: null == columns
            ? _value._columns
            : columns // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<B2bCard>>,
      ),
    );
  }
}

/// @nodoc

class _$B2bPipelineImpl implements _B2bPipeline {
  const _$B2bPipelineImpl({
    required final List<String> stages,
    required final Map<String, List<B2bCard>> columns,
  }) : _stages = stages,
       _columns = columns;

  final List<String> _stages;
  @override
  List<String> get stages {
    if (_stages is EqualUnmodifiableListView) return _stages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stages);
  }

  final Map<String, List<B2bCard>> _columns;
  @override
  Map<String, List<B2bCard>> get columns {
    if (_columns is EqualUnmodifiableMapView) return _columns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_columns);
  }

  @override
  String toString() {
    return 'B2bPipeline(stages: $stages, columns: $columns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bPipelineImpl &&
            const DeepCollectionEquality().equals(other._stages, _stages) &&
            const DeepCollectionEquality().equals(other._columns, _columns));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_stages),
    const DeepCollectionEquality().hash(_columns),
  );

  /// Create a copy of B2bPipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bPipelineImplCopyWith<_$B2bPipelineImpl> get copyWith =>
      __$$B2bPipelineImplCopyWithImpl<_$B2bPipelineImpl>(this, _$identity);
}

abstract class _B2bPipeline implements B2bPipeline {
  const factory _B2bPipeline({
    required final List<String> stages,
    required final Map<String, List<B2bCard>> columns,
  }) = _$B2bPipelineImpl;

  @override
  List<String> get stages;
  @override
  Map<String, List<B2bCard>> get columns;

  /// Create a copy of B2bPipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bPipelineImplCopyWith<_$B2bPipelineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bContact _$B2bContactFromJson(Map<String, dynamic> json) {
  return _B2bContact.fromJson(json);
}

/// @nodoc
mixin _$B2bContact {
  @JsonKey(name: 'mobile_no')
  String? get mobileNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_id')
  String? get emailId => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this B2bContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bContactCopyWith<B2bContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bContactCopyWith<$Res> {
  factory $B2bContactCopyWith(
    B2bContact value,
    $Res Function(B2bContact) then,
  ) = _$B2bContactCopyWithImpl<$Res, B2bContact>;
  @useResult
  $Res call({
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
    String? phone,
  });
}

/// @nodoc
class _$B2bContactCopyWithImpl<$Res, $Val extends B2bContact>
    implements $B2bContactCopyWith<$Res> {
  _$B2bContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mobileNo = freezed,
    Object? emailId = freezed,
    Object? phone = freezed,
  }) {
    return _then(
      _value.copyWith(
            mobileNo: freezed == mobileNo
                ? _value.mobileNo
                : mobileNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailId: freezed == emailId
                ? _value.emailId
                : emailId // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bContactImplCopyWith<$Res>
    implements $B2bContactCopyWith<$Res> {
  factory _$$B2bContactImplCopyWith(
    _$B2bContactImpl value,
    $Res Function(_$B2bContactImpl) then,
  ) = __$$B2bContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'mobile_no') String? mobileNo,
    @JsonKey(name: 'email_id') String? emailId,
    String? phone,
  });
}

/// @nodoc
class __$$B2bContactImplCopyWithImpl<$Res>
    extends _$B2bContactCopyWithImpl<$Res, _$B2bContactImpl>
    implements _$$B2bContactImplCopyWith<$Res> {
  __$$B2bContactImplCopyWithImpl(
    _$B2bContactImpl _value,
    $Res Function(_$B2bContactImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mobileNo = freezed,
    Object? emailId = freezed,
    Object? phone = freezed,
  }) {
    return _then(
      _$B2bContactImpl(
        mobileNo: freezed == mobileNo
            ? _value.mobileNo
            : mobileNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailId: freezed == emailId
            ? _value.emailId
            : emailId // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bContactImpl implements _B2bContact {
  const _$B2bContactImpl({
    @JsonKey(name: 'mobile_no') this.mobileNo,
    @JsonKey(name: 'email_id') this.emailId,
    this.phone,
  });

  factory _$B2bContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bContactImplFromJson(json);

  @override
  @JsonKey(name: 'mobile_no')
  final String? mobileNo;
  @override
  @JsonKey(name: 'email_id')
  final String? emailId;
  @override
  final String? phone;

  @override
  String toString() {
    return 'B2bContact(mobileNo: $mobileNo, emailId: $emailId, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bContactImpl &&
            (identical(other.mobileNo, mobileNo) ||
                other.mobileNo == mobileNo) &&
            (identical(other.emailId, emailId) || other.emailId == emailId) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mobileNo, emailId, phone);

  /// Create a copy of B2bContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bContactImplCopyWith<_$B2bContactImpl> get copyWith =>
      __$$B2bContactImplCopyWithImpl<_$B2bContactImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bContactImplToJson(this);
  }
}

abstract class _B2bContact implements B2bContact {
  const factory _B2bContact({
    @JsonKey(name: 'mobile_no') final String? mobileNo,
    @JsonKey(name: 'email_id') final String? emailId,
    final String? phone,
  }) = _$B2bContactImpl;

  factory _B2bContact.fromJson(Map<String, dynamic> json) =
      _$B2bContactImpl.fromJson;

  @override
  @JsonKey(name: 'mobile_no')
  String? get mobileNo;
  @override
  @JsonKey(name: 'email_id')
  String? get emailId;
  @override
  String? get phone;

  /// Create a copy of B2bContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bContactImplCopyWith<_$B2bContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bRecentInvoice _$B2bRecentInvoiceFromJson(Map<String, dynamic> json) {
  return _B2bRecentInvoice.fromJson(json);
}

/// @nodoc
mixin _$B2bRecentInvoice {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'woo_order_id')
  @_NullableIntConverter()
  int? get wooOrderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'posting_date')
  String? get postingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'grand_total')
  @_NullableDoubleConverter()
  double? get grandTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'outstanding_amount')
  @_NullableDoubleConverter()
  double? get outstandingAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_order_purpose')
  String? get orderPurpose => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_payment_method')
  @_NullableStringConverter()
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_return')
  @_BoolConverter()
  bool get isReturn => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_address')
  @_NullableStringConverter()
  String? get branchAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName => throw _privateConstructorUsedError;

  /// Serializes this B2bRecentInvoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bRecentInvoiceCopyWith<B2bRecentInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bRecentInvoiceCopyWith<$Res> {
  factory $B2bRecentInvoiceCopyWith(
    B2bRecentInvoice value,
    $Res Function(B2bRecentInvoice) then,
  ) = _$B2bRecentInvoiceCopyWithImpl<$Res, B2bRecentInvoice>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'woo_order_id') @_NullableIntConverter() int? wooOrderId,
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total')
    @_NullableDoubleConverter()
    double? grandTotal,
    @JsonKey(name: 'outstanding_amount')
    @_NullableDoubleConverter()
    double? outstandingAmount,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    @JsonKey(name: 'custom_payment_method')
    @_NullableStringConverter()
    String? paymentMethod,
    String? status,
    @JsonKey(name: 'is_return') @_BoolConverter() bool isReturn,
    @JsonKey(name: 'branch_address')
    @_NullableStringConverter()
    String? branchAddress,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
  });
}

/// @nodoc
class _$B2bRecentInvoiceCopyWithImpl<$Res, $Val extends B2bRecentInvoice>
    implements $B2bRecentInvoiceCopyWith<$Res> {
  _$B2bRecentInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? wooOrderId = freezed,
    Object? postingDate = freezed,
    Object? grandTotal = freezed,
    Object? outstandingAmount = freezed,
    Object? orderPurpose = freezed,
    Object? paymentMethod = freezed,
    Object? status = freezed,
    Object? isReturn = null,
    Object? branchAddress = freezed,
    Object? branchName = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            wooOrderId: freezed == wooOrderId
                ? _value.wooOrderId
                : wooOrderId // ignore: cast_nullable_to_non_nullable
                      as int?,
            postingDate: freezed == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            grandTotal: freezed == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double?,
            outstandingAmount: freezed == outstandingAmount
                ? _value.outstandingAmount
                : outstandingAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            orderPurpose: freezed == orderPurpose
                ? _value.orderPurpose
                : orderPurpose // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            isReturn: null == isReturn
                ? _value.isReturn
                : isReturn // ignore: cast_nullable_to_non_nullable
                      as bool,
            branchAddress: freezed == branchAddress
                ? _value.branchAddress
                : branchAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchName: freezed == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bRecentInvoiceImplCopyWith<$Res>
    implements $B2bRecentInvoiceCopyWith<$Res> {
  factory _$$B2bRecentInvoiceImplCopyWith(
    _$B2bRecentInvoiceImpl value,
    $Res Function(_$B2bRecentInvoiceImpl) then,
  ) = __$$B2bRecentInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'woo_order_id') @_NullableIntConverter() int? wooOrderId,
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total')
    @_NullableDoubleConverter()
    double? grandTotal,
    @JsonKey(name: 'outstanding_amount')
    @_NullableDoubleConverter()
    double? outstandingAmount,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    @JsonKey(name: 'custom_payment_method')
    @_NullableStringConverter()
    String? paymentMethod,
    String? status,
    @JsonKey(name: 'is_return') @_BoolConverter() bool isReturn,
    @JsonKey(name: 'branch_address')
    @_NullableStringConverter()
    String? branchAddress,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
  });
}

/// @nodoc
class __$$B2bRecentInvoiceImplCopyWithImpl<$Res>
    extends _$B2bRecentInvoiceCopyWithImpl<$Res, _$B2bRecentInvoiceImpl>
    implements _$$B2bRecentInvoiceImplCopyWith<$Res> {
  __$$B2bRecentInvoiceImplCopyWithImpl(
    _$B2bRecentInvoiceImpl _value,
    $Res Function(_$B2bRecentInvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? wooOrderId = freezed,
    Object? postingDate = freezed,
    Object? grandTotal = freezed,
    Object? outstandingAmount = freezed,
    Object? orderPurpose = freezed,
    Object? paymentMethod = freezed,
    Object? status = freezed,
    Object? isReturn = null,
    Object? branchAddress = freezed,
    Object? branchName = freezed,
  }) {
    return _then(
      _$B2bRecentInvoiceImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        wooOrderId: freezed == wooOrderId
            ? _value.wooOrderId
            : wooOrderId // ignore: cast_nullable_to_non_nullable
                  as int?,
        postingDate: freezed == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        grandTotal: freezed == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double?,
        outstandingAmount: freezed == outstandingAmount
            ? _value.outstandingAmount
            : outstandingAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        orderPurpose: freezed == orderPurpose
            ? _value.orderPurpose
            : orderPurpose // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        isReturn: null == isReturn
            ? _value.isReturn
            : isReturn // ignore: cast_nullable_to_non_nullable
                  as bool,
        branchAddress: freezed == branchAddress
            ? _value.branchAddress
            : branchAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchName: freezed == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bRecentInvoiceImpl extends _B2bRecentInvoice {
  const _$B2bRecentInvoiceImpl({
    required this.name,
    @JsonKey(name: 'woo_order_id') @_NullableIntConverter() this.wooOrderId,
    @JsonKey(name: 'posting_date') this.postingDate,
    @JsonKey(name: 'grand_total') @_NullableDoubleConverter() this.grandTotal,
    @JsonKey(name: 'outstanding_amount')
    @_NullableDoubleConverter()
    this.outstandingAmount,
    @JsonKey(name: 'custom_order_purpose') this.orderPurpose,
    @JsonKey(name: 'custom_payment_method')
    @_NullableStringConverter()
    this.paymentMethod,
    this.status,
    @JsonKey(name: 'is_return') @_BoolConverter() this.isReturn = false,
    @JsonKey(name: 'branch_address')
    @_NullableStringConverter()
    this.branchAddress,
    @JsonKey(name: 'branch_name') @_NullableStringConverter() this.branchName,
  }) : super._();

  factory _$B2bRecentInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bRecentInvoiceImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'woo_order_id')
  @_NullableIntConverter()
  final int? wooOrderId;
  @override
  @JsonKey(name: 'posting_date')
  final String? postingDate;
  @override
  @JsonKey(name: 'grand_total')
  @_NullableDoubleConverter()
  final double? grandTotal;
  @override
  @JsonKey(name: 'outstanding_amount')
  @_NullableDoubleConverter()
  final double? outstandingAmount;
  @override
  @JsonKey(name: 'custom_order_purpose')
  final String? orderPurpose;
  @override
  @JsonKey(name: 'custom_payment_method')
  @_NullableStringConverter()
  final String? paymentMethod;
  @override
  final String? status;
  @override
  @JsonKey(name: 'is_return')
  @_BoolConverter()
  final bool isReturn;
  @override
  @JsonKey(name: 'branch_address')
  @_NullableStringConverter()
  final String? branchAddress;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  final String? branchName;

  @override
  String toString() {
    return 'B2bRecentInvoice(name: $name, wooOrderId: $wooOrderId, postingDate: $postingDate, grandTotal: $grandTotal, outstandingAmount: $outstandingAmount, orderPurpose: $orderPurpose, paymentMethod: $paymentMethod, status: $status, isReturn: $isReturn, branchAddress: $branchAddress, branchName: $branchName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bRecentInvoiceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.wooOrderId, wooOrderId) ||
                other.wooOrderId == wooOrderId) &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount) &&
            (identical(other.orderPurpose, orderPurpose) ||
                other.orderPurpose == orderPurpose) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isReturn, isReturn) ||
                other.isReturn == isReturn) &&
            (identical(other.branchAddress, branchAddress) ||
                other.branchAddress == branchAddress) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    wooOrderId,
    postingDate,
    grandTotal,
    outstandingAmount,
    orderPurpose,
    paymentMethod,
    status,
    isReturn,
    branchAddress,
    branchName,
  );

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bRecentInvoiceImplCopyWith<_$B2bRecentInvoiceImpl> get copyWith =>
      __$$B2bRecentInvoiceImplCopyWithImpl<_$B2bRecentInvoiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bRecentInvoiceImplToJson(this);
  }
}

abstract class _B2bRecentInvoice extends B2bRecentInvoice {
  const factory _B2bRecentInvoice({
    required final String name,
    @JsonKey(name: 'woo_order_id')
    @_NullableIntConverter()
    final int? wooOrderId,
    @JsonKey(name: 'posting_date') final String? postingDate,
    @JsonKey(name: 'grand_total')
    @_NullableDoubleConverter()
    final double? grandTotal,
    @JsonKey(name: 'outstanding_amount')
    @_NullableDoubleConverter()
    final double? outstandingAmount,
    @JsonKey(name: 'custom_order_purpose') final String? orderPurpose,
    @JsonKey(name: 'custom_payment_method')
    @_NullableStringConverter()
    final String? paymentMethod,
    final String? status,
    @JsonKey(name: 'is_return') @_BoolConverter() final bool isReturn,
    @JsonKey(name: 'branch_address')
    @_NullableStringConverter()
    final String? branchAddress,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    final String? branchName,
  }) = _$B2bRecentInvoiceImpl;
  const _B2bRecentInvoice._() : super._();

  factory _B2bRecentInvoice.fromJson(Map<String, dynamic> json) =
      _$B2bRecentInvoiceImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'woo_order_id')
  @_NullableIntConverter()
  int? get wooOrderId;
  @override
  @JsonKey(name: 'posting_date')
  String? get postingDate;
  @override
  @JsonKey(name: 'grand_total')
  @_NullableDoubleConverter()
  double? get grandTotal;
  @override
  @JsonKey(name: 'outstanding_amount')
  @_NullableDoubleConverter()
  double? get outstandingAmount;
  @override
  @JsonKey(name: 'custom_order_purpose')
  String? get orderPurpose;
  @override
  @JsonKey(name: 'custom_payment_method')
  @_NullableStringConverter()
  String? get paymentMethod;
  @override
  String? get status;
  @override
  @JsonKey(name: 'is_return')
  @_BoolConverter()
  bool get isReturn;
  @override
  @JsonKey(name: 'branch_address')
  @_NullableStringConverter()
  String? get branchAddress;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName;

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bRecentInvoiceImplCopyWith<_$B2bRecentInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bBranchStats _$B2bBranchStatsFromJson(Map<String, dynamic> json) {
  return _B2bBranchStats.fromJson(json);
}

/// @nodoc
mixin _$B2bBranchStats {
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled => throw _privateConstructorUsedError;
  @_DoubleConverter()
  double get outstanding => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  String? get lastOrderDate => throw _privateConstructorUsedError;

  /// Serializes this B2bBranchStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bBranchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bBranchStatsCopyWith<B2bBranchStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bBranchStatsCopyWith<$Res> {
  factory $B2bBranchStatsCopyWith(
    B2bBranchStats value,
    $Res Function(B2bBranchStats) then,
  ) = _$B2bBranchStatsCopyWithImpl<$Res, B2bBranchStats>;
  @useResult
  $Res call({
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,
  });
}

/// @nodoc
class _$B2bBranchStatsCopyWithImpl<$Res, $Val extends B2bBranchStats>
    implements $B2bBranchStatsCopyWith<$Res> {
  _$B2bBranchStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bBranchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? lastOrderDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            invoiceCount: null == invoiceCount
                ? _value.invoiceCount
                : invoiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBilled: null == totalBilled
                ? _value.totalBilled
                : totalBilled // ignore: cast_nullable_to_non_nullable
                      as double,
            outstanding: null == outstanding
                ? _value.outstanding
                : outstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            lastOrderDate: freezed == lastOrderDate
                ? _value.lastOrderDate
                : lastOrderDate // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bBranchStatsImplCopyWith<$Res>
    implements $B2bBranchStatsCopyWith<$Res> {
  factory _$$B2bBranchStatsImplCopyWith(
    _$B2bBranchStatsImpl value,
    $Res Function(_$B2bBranchStatsImpl) then,
  ) = __$$B2bBranchStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,
  });
}

/// @nodoc
class __$$B2bBranchStatsImplCopyWithImpl<$Res>
    extends _$B2bBranchStatsCopyWithImpl<$Res, _$B2bBranchStatsImpl>
    implements _$$B2bBranchStatsImplCopyWith<$Res> {
  __$$B2bBranchStatsImplCopyWithImpl(
    _$B2bBranchStatsImpl _value,
    $Res Function(_$B2bBranchStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bBranchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? lastOrderDate = freezed,
  }) {
    return _then(
      _$B2bBranchStatsImpl(
        invoiceCount: null == invoiceCount
            ? _value.invoiceCount
            : invoiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBilled: null == totalBilled
            ? _value.totalBilled
            : totalBilled // ignore: cast_nullable_to_non_nullable
                  as double,
        outstanding: null == outstanding
            ? _value.outstanding
            : outstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        lastOrderDate: freezed == lastOrderDate
            ? _value.lastOrderDate
            : lastOrderDate // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bBranchStatsImpl implements _B2bBranchStats {
  const _$B2bBranchStatsImpl({
    @JsonKey(name: 'invoice_count') @_IntConverter() this.invoiceCount = 0,
    @JsonKey(name: 'total_billed') @_DoubleConverter() this.totalBilled = 0.0,
    @_DoubleConverter() this.outstanding = 0.0,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    this.lastOrderDate,
  });

  factory _$B2bBranchStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bBranchStatsImplFromJson(json);

  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  final int invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  final double totalBilled;
  @override
  @JsonKey()
  @_DoubleConverter()
  final double outstanding;
  @override
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  final String? lastOrderDate;

  @override
  String toString() {
    return 'B2bBranchStats(invoiceCount: $invoiceCount, totalBilled: $totalBilled, outstanding: $outstanding, lastOrderDate: $lastOrderDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bBranchStatsImpl &&
            (identical(other.invoiceCount, invoiceCount) ||
                other.invoiceCount == invoiceCount) &&
            (identical(other.totalBilled, totalBilled) ||
                other.totalBilled == totalBilled) &&
            (identical(other.outstanding, outstanding) ||
                other.outstanding == outstanding) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    invoiceCount,
    totalBilled,
    outstanding,
    lastOrderDate,
  );

  /// Create a copy of B2bBranchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bBranchStatsImplCopyWith<_$B2bBranchStatsImpl> get copyWith =>
      __$$B2bBranchStatsImplCopyWithImpl<_$B2bBranchStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bBranchStatsImplToJson(this);
  }
}

abstract class _B2bBranchStats implements B2bBranchStats {
  const factory _B2bBranchStats({
    @JsonKey(name: 'invoice_count') @_IntConverter() final int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() final double totalBilled,
    @_DoubleConverter() final double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    final String? lastOrderDate,
  }) = _$B2bBranchStatsImpl;

  factory _B2bBranchStats.fromJson(Map<String, dynamic> json) =
      _$B2bBranchStatsImpl.fromJson;

  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled;
  @override
  @_DoubleConverter()
  double get outstanding;
  @override
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  String? get lastOrderDate;

  /// Create a copy of B2bBranchStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bBranchStatsImplCopyWith<_$B2bBranchStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bMapsInfo _$B2bMapsInfoFromJson(Map<String, dynamic> json) {
  return _B2bMapsInfo.fromJson(json);
}

/// @nodoc
mixin _$B2bMapsInfo {
  /// The Lead branch-table row id the link endpoint is keyed on.
  @_NullableStringConverter()
  String? get row => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get area => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get region => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get governorate => throw _privateConstructorUsedError;
  @_NullableDoubleConverter()
  double? get rating => throw _privateConstructorUsedError;
  @_NullableIntConverter()
  int? get reviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'maps_url')
  @_NullableStringConverter()
  String? get mapsUrl => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get phone => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get address => throw _privateConstructorUsedError;
  @_NullableDoubleConverter()
  double? get latitude => throw _privateConstructorUsedError;
  @_NullableDoubleConverter()
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'on_talabat')
  @_BoolConverter()
  bool get onTalabat => throw _privateConstructorUsedError;

  /// Serializes this B2bMapsInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMapsInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMapsInfoCopyWith<B2bMapsInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMapsInfoCopyWith<$Res> {
  factory $B2bMapsInfoCopyWith(
    B2bMapsInfo value,
    $Res Function(B2bMapsInfo) then,
  ) = _$B2bMapsInfoCopyWithImpl<$Res, B2bMapsInfo>;
  @useResult
  $Res call({
    @_NullableStringConverter() String? row,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @_NullableStringConverter() String? area,
    @_NullableStringConverter() String? region,
    @_NullableStringConverter() String? governorate,
    @_NullableDoubleConverter() double? rating,
    @_NullableIntConverter() int? reviews,
    @JsonKey(name: 'maps_url') @_NullableStringConverter() String? mapsUrl,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? address,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'on_talabat') @_BoolConverter() bool onTalabat,
  });
}

/// @nodoc
class _$B2bMapsInfoCopyWithImpl<$Res, $Val extends B2bMapsInfo>
    implements $B2bMapsInfoCopyWith<$Res> {
  _$B2bMapsInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMapsInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = freezed,
    Object? branchName = freezed,
    Object? area = freezed,
    Object? region = freezed,
    Object? governorate = freezed,
    Object? rating = freezed,
    Object? reviews = freezed,
    Object? mapsUrl = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? onTalabat = null,
  }) {
    return _then(
      _value.copyWith(
            row: freezed == row
                ? _value.row
                : row // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchName: freezed == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String?,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            governorate: freezed == governorate
                ? _value.governorate
                : governorate // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            reviews: freezed == reviews
                ? _value.reviews
                : reviews // ignore: cast_nullable_to_non_nullable
                      as int?,
            mapsUrl: freezed == mapsUrl
                ? _value.mapsUrl
                : mapsUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            onTalabat: null == onTalabat
                ? _value.onTalabat
                : onTalabat // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bMapsInfoImplCopyWith<$Res>
    implements $B2bMapsInfoCopyWith<$Res> {
  factory _$$B2bMapsInfoImplCopyWith(
    _$B2bMapsInfoImpl value,
    $Res Function(_$B2bMapsInfoImpl) then,
  ) = __$$B2bMapsInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_NullableStringConverter() String? row,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @_NullableStringConverter() String? area,
    @_NullableStringConverter() String? region,
    @_NullableStringConverter() String? governorate,
    @_NullableDoubleConverter() double? rating,
    @_NullableIntConverter() int? reviews,
    @JsonKey(name: 'maps_url') @_NullableStringConverter() String? mapsUrl,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? address,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'on_talabat') @_BoolConverter() bool onTalabat,
  });
}

/// @nodoc
class __$$B2bMapsInfoImplCopyWithImpl<$Res>
    extends _$B2bMapsInfoCopyWithImpl<$Res, _$B2bMapsInfoImpl>
    implements _$$B2bMapsInfoImplCopyWith<$Res> {
  __$$B2bMapsInfoImplCopyWithImpl(
    _$B2bMapsInfoImpl _value,
    $Res Function(_$B2bMapsInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMapsInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = freezed,
    Object? branchName = freezed,
    Object? area = freezed,
    Object? region = freezed,
    Object? governorate = freezed,
    Object? rating = freezed,
    Object? reviews = freezed,
    Object? mapsUrl = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? onTalabat = null,
  }) {
    return _then(
      _$B2bMapsInfoImpl(
        row: freezed == row
            ? _value.row
            : row // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchName: freezed == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String?,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        governorate: freezed == governorate
            ? _value.governorate
            : governorate // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        reviews: freezed == reviews
            ? _value.reviews
            : reviews // ignore: cast_nullable_to_non_nullable
                  as int?,
        mapsUrl: freezed == mapsUrl
            ? _value.mapsUrl
            : mapsUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        onTalabat: null == onTalabat
            ? _value.onTalabat
            : onTalabat // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMapsInfoImpl extends _B2bMapsInfo {
  const _$B2bMapsInfoImpl({
    @_NullableStringConverter() this.row,
    @JsonKey(name: 'branch_name') @_NullableStringConverter() this.branchName,
    @_NullableStringConverter() this.area,
    @_NullableStringConverter() this.region,
    @_NullableStringConverter() this.governorate,
    @_NullableDoubleConverter() this.rating,
    @_NullableIntConverter() this.reviews,
    @JsonKey(name: 'maps_url') @_NullableStringConverter() this.mapsUrl,
    @_NullableStringConverter() this.phone,
    @_NullableStringConverter() this.address,
    @_NullableDoubleConverter() this.latitude,
    @_NullableDoubleConverter() this.longitude,
    @JsonKey(name: 'on_talabat') @_BoolConverter() this.onTalabat = false,
  }) : super._();

  factory _$B2bMapsInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMapsInfoImplFromJson(json);

  /// The Lead branch-table row id the link endpoint is keyed on.
  @override
  @_NullableStringConverter()
  final String? row;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  final String? branchName;
  @override
  @_NullableStringConverter()
  final String? area;
  @override
  @_NullableStringConverter()
  final String? region;
  @override
  @_NullableStringConverter()
  final String? governorate;
  @override
  @_NullableDoubleConverter()
  final double? rating;
  @override
  @_NullableIntConverter()
  final int? reviews;
  @override
  @JsonKey(name: 'maps_url')
  @_NullableStringConverter()
  final String? mapsUrl;
  @override
  @_NullableStringConverter()
  final String? phone;
  @override
  @_NullableStringConverter()
  final String? address;
  @override
  @_NullableDoubleConverter()
  final double? latitude;
  @override
  @_NullableDoubleConverter()
  final double? longitude;
  @override
  @JsonKey(name: 'on_talabat')
  @_BoolConverter()
  final bool onTalabat;

  @override
  String toString() {
    return 'B2bMapsInfo(row: $row, branchName: $branchName, area: $area, region: $region, governorate: $governorate, rating: $rating, reviews: $reviews, mapsUrl: $mapsUrl, phone: $phone, address: $address, latitude: $latitude, longitude: $longitude, onTalabat: $onTalabat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMapsInfoImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.governorate, governorate) ||
                other.governorate == governorate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviews, reviews) || other.reviews == reviews) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.onTalabat, onTalabat) ||
                other.onTalabat == onTalabat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    row,
    branchName,
    area,
    region,
    governorate,
    rating,
    reviews,
    mapsUrl,
    phone,
    address,
    latitude,
    longitude,
    onTalabat,
  );

  /// Create a copy of B2bMapsInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMapsInfoImplCopyWith<_$B2bMapsInfoImpl> get copyWith =>
      __$$B2bMapsInfoImplCopyWithImpl<_$B2bMapsInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMapsInfoImplToJson(this);
  }
}

abstract class _B2bMapsInfo extends B2bMapsInfo {
  const factory _B2bMapsInfo({
    @_NullableStringConverter() final String? row,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    final String? branchName,
    @_NullableStringConverter() final String? area,
    @_NullableStringConverter() final String? region,
    @_NullableStringConverter() final String? governorate,
    @_NullableDoubleConverter() final double? rating,
    @_NullableIntConverter() final int? reviews,
    @JsonKey(name: 'maps_url')
    @_NullableStringConverter()
    final String? mapsUrl,
    @_NullableStringConverter() final String? phone,
    @_NullableStringConverter() final String? address,
    @_NullableDoubleConverter() final double? latitude,
    @_NullableDoubleConverter() final double? longitude,
    @JsonKey(name: 'on_talabat') @_BoolConverter() final bool onTalabat,
  }) = _$B2bMapsInfoImpl;
  const _B2bMapsInfo._() : super._();

  factory _B2bMapsInfo.fromJson(Map<String, dynamic> json) =
      _$B2bMapsInfoImpl.fromJson;

  /// The Lead branch-table row id the link endpoint is keyed on.
  @override
  @_NullableStringConverter()
  String? get row;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName;
  @override
  @_NullableStringConverter()
  String? get area;
  @override
  @_NullableStringConverter()
  String? get region;
  @override
  @_NullableStringConverter()
  String? get governorate;
  @override
  @_NullableDoubleConverter()
  double? get rating;
  @override
  @_NullableIntConverter()
  int? get reviews;
  @override
  @JsonKey(name: 'maps_url')
  @_NullableStringConverter()
  String? get mapsUrl;
  @override
  @_NullableStringConverter()
  String? get phone;
  @override
  @_NullableStringConverter()
  String? get address;
  @override
  @_NullableDoubleConverter()
  double? get latitude;
  @override
  @_NullableDoubleConverter()
  double? get longitude;
  @override
  @JsonKey(name: 'on_talabat')
  @_BoolConverter()
  bool get onTalabat;

  /// Create a copy of B2bMapsInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMapsInfoImplCopyWith<_$B2bMapsInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bBranch _$B2bBranchFromJson(Map<String, dynamic> json) {
  return _B2bBranch.fromJson(json);
}

/// @nodoc
mixin _$B2bBranch {
  @JsonKey(name: 'address_name')
  @_NullableStringConverter()
  String? get addressName => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_line1')
  @_NullableStringConverter()
  String? get addressLine1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_line2')
  @_NullableStringConverter()
  String? get addressLine2 => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get city => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get phone => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get territory => throw _privateConstructorUsedError;
  @JsonKey(name: 'territory_missing')
  @_BoolConverter()
  bool get territoryMissing => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary_address')
  @_BoolConverter()
  bool get isPrimaryAddress => throw _privateConstructorUsedError;
  @_NullableDoubleConverter()
  double? get latitude => throw _privateConstructorUsedError;
  @_NullableDoubleConverter()
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_address_names')
  @_StringListConverter()
  List<String> get memberAddressNames => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled => throw _privateConstructorUsedError;
  @_DoubleConverter()
  double get outstanding => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  String? get lastOrderDate => throw _privateConstructorUsedError;

  /// `"address"` (a delivery branch) or `"maps"` (Google Maps only).
  @_BranchSourceConverter()
  String get source => throw _privateConstructorUsedError;

  /// The Google Maps listing for this door, when one is known.
  @_MapsInfoConverter()
  B2bMapsInfo? get maps => throw _privateConstructorUsedError;

  /// How [maps] got attached to a delivery branch: `"linked"` (a rep chose
  /// it) or `"auto"` (matched by name / pin). Null for maps-only entries.
  @JsonKey(name: 'maps_match')
  @_NullableStringConverter()
  String? get mapsMatch => throw _privateConstructorUsedError;

  /// Serializes this B2bBranch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bBranchCopyWith<B2bBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bBranchCopyWith<$Res> {
  factory $B2bBranchCopyWith(B2bBranch value, $Res Function(B2bBranch) then) =
      _$B2bBranchCopyWithImpl<$Res, B2bBranch>;
  @useResult
  $Res call({
    @JsonKey(name: 'address_name')
    @_NullableStringConverter()
    String? addressName,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @JsonKey(name: 'address_line1')
    @_NullableStringConverter()
    String? addressLine1,
    @JsonKey(name: 'address_line2')
    @_NullableStringConverter()
    String? addressLine2,
    @_NullableStringConverter() String? city,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? territory,
    @JsonKey(name: 'territory_missing') @_BoolConverter() bool territoryMissing,
    @JsonKey(name: 'is_primary_address')
    @_BoolConverter()
    bool isPrimaryAddress,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'member_address_names')
    @_StringListConverter()
    List<String> memberAddressNames,
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,
    @_BranchSourceConverter() String source,
    @_MapsInfoConverter() B2bMapsInfo? maps,
    @JsonKey(name: 'maps_match') @_NullableStringConverter() String? mapsMatch,
  });

  $B2bMapsInfoCopyWith<$Res>? get maps;
}

/// @nodoc
class _$B2bBranchCopyWithImpl<$Res, $Val extends B2bBranch>
    implements $B2bBranchCopyWith<$Res> {
  _$B2bBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressName = freezed,
    Object? branchName = freezed,
    Object? addressLine1 = freezed,
    Object? addressLine2 = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? territory = freezed,
    Object? territoryMissing = null,
    Object? isPrimaryAddress = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? memberAddressNames = null,
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? lastOrderDate = freezed,
    Object? source = null,
    Object? maps = freezed,
    Object? mapsMatch = freezed,
  }) {
    return _then(
      _value.copyWith(
            addressName: freezed == addressName
                ? _value.addressName
                : addressName // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchName: freezed == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            addressLine1: freezed == addressLine1
                ? _value.addressLine1
                : addressLine1 // ignore: cast_nullable_to_non_nullable
                      as String?,
            addressLine2: freezed == addressLine2
                ? _value.addressLine2
                : addressLine2 // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            territory: freezed == territory
                ? _value.territory
                : territory // ignore: cast_nullable_to_non_nullable
                      as String?,
            territoryMissing: null == territoryMissing
                ? _value.territoryMissing
                : territoryMissing // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPrimaryAddress: null == isPrimaryAddress
                ? _value.isPrimaryAddress
                : isPrimaryAddress // ignore: cast_nullable_to_non_nullable
                      as bool,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            memberAddressNames: null == memberAddressNames
                ? _value.memberAddressNames
                : memberAddressNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            invoiceCount: null == invoiceCount
                ? _value.invoiceCount
                : invoiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBilled: null == totalBilled
                ? _value.totalBilled
                : totalBilled // ignore: cast_nullable_to_non_nullable
                      as double,
            outstanding: null == outstanding
                ? _value.outstanding
                : outstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            lastOrderDate: freezed == lastOrderDate
                ? _value.lastOrderDate
                : lastOrderDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            maps: freezed == maps
                ? _value.maps
                : maps // ignore: cast_nullable_to_non_nullable
                      as B2bMapsInfo?,
            mapsMatch: freezed == mapsMatch
                ? _value.mapsMatch
                : mapsMatch // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMapsInfoCopyWith<$Res>? get maps {
    if (_value.maps == null) {
      return null;
    }

    return $B2bMapsInfoCopyWith<$Res>(_value.maps!, (value) {
      return _then(_value.copyWith(maps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$B2bBranchImplCopyWith<$Res>
    implements $B2bBranchCopyWith<$Res> {
  factory _$$B2bBranchImplCopyWith(
    _$B2bBranchImpl value,
    $Res Function(_$B2bBranchImpl) then,
  ) = __$$B2bBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'address_name')
    @_NullableStringConverter()
    String? addressName,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    String? branchName,
    @JsonKey(name: 'address_line1')
    @_NullableStringConverter()
    String? addressLine1,
    @JsonKey(name: 'address_line2')
    @_NullableStringConverter()
    String? addressLine2,
    @_NullableStringConverter() String? city,
    @_NullableStringConverter() String? phone,
    @_NullableStringConverter() String? territory,
    @JsonKey(name: 'territory_missing') @_BoolConverter() bool territoryMissing,
    @JsonKey(name: 'is_primary_address')
    @_BoolConverter()
    bool isPrimaryAddress,
    @_NullableDoubleConverter() double? latitude,
    @_NullableDoubleConverter() double? longitude,
    @JsonKey(name: 'member_address_names')
    @_StringListConverter()
    List<String> memberAddressNames,
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    String? lastOrderDate,
    @_BranchSourceConverter() String source,
    @_MapsInfoConverter() B2bMapsInfo? maps,
    @JsonKey(name: 'maps_match') @_NullableStringConverter() String? mapsMatch,
  });

  @override
  $B2bMapsInfoCopyWith<$Res>? get maps;
}

/// @nodoc
class __$$B2bBranchImplCopyWithImpl<$Res>
    extends _$B2bBranchCopyWithImpl<$Res, _$B2bBranchImpl>
    implements _$$B2bBranchImplCopyWith<$Res> {
  __$$B2bBranchImplCopyWithImpl(
    _$B2bBranchImpl _value,
    $Res Function(_$B2bBranchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressName = freezed,
    Object? branchName = freezed,
    Object? addressLine1 = freezed,
    Object? addressLine2 = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? territory = freezed,
    Object? territoryMissing = null,
    Object? isPrimaryAddress = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? memberAddressNames = null,
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? lastOrderDate = freezed,
    Object? source = null,
    Object? maps = freezed,
    Object? mapsMatch = freezed,
  }) {
    return _then(
      _$B2bBranchImpl(
        addressName: freezed == addressName
            ? _value.addressName
            : addressName // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchName: freezed == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        addressLine1: freezed == addressLine1
            ? _value.addressLine1
            : addressLine1 // ignore: cast_nullable_to_non_nullable
                  as String?,
        addressLine2: freezed == addressLine2
            ? _value.addressLine2
            : addressLine2 // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        territory: freezed == territory
            ? _value.territory
            : territory // ignore: cast_nullable_to_non_nullable
                  as String?,
        territoryMissing: null == territoryMissing
            ? _value.territoryMissing
            : territoryMissing // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPrimaryAddress: null == isPrimaryAddress
            ? _value.isPrimaryAddress
            : isPrimaryAddress // ignore: cast_nullable_to_non_nullable
                  as bool,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        memberAddressNames: null == memberAddressNames
            ? _value._memberAddressNames
            : memberAddressNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        invoiceCount: null == invoiceCount
            ? _value.invoiceCount
            : invoiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBilled: null == totalBilled
            ? _value.totalBilled
            : totalBilled // ignore: cast_nullable_to_non_nullable
                  as double,
        outstanding: null == outstanding
            ? _value.outstanding
            : outstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        lastOrderDate: freezed == lastOrderDate
            ? _value.lastOrderDate
            : lastOrderDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        maps: freezed == maps
            ? _value.maps
            : maps // ignore: cast_nullable_to_non_nullable
                  as B2bMapsInfo?,
        mapsMatch: freezed == mapsMatch
            ? _value.mapsMatch
            : mapsMatch // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bBranchImpl extends _B2bBranch {
  const _$B2bBranchImpl({
    @JsonKey(name: 'address_name') @_NullableStringConverter() this.addressName,
    @JsonKey(name: 'branch_name') @_NullableStringConverter() this.branchName,
    @JsonKey(name: 'address_line1')
    @_NullableStringConverter()
    this.addressLine1,
    @JsonKey(name: 'address_line2')
    @_NullableStringConverter()
    this.addressLine2,
    @_NullableStringConverter() this.city,
    @_NullableStringConverter() this.phone,
    @_NullableStringConverter() this.territory,
    @JsonKey(name: 'territory_missing')
    @_BoolConverter()
    this.territoryMissing = false,
    @JsonKey(name: 'is_primary_address')
    @_BoolConverter()
    this.isPrimaryAddress = false,
    @_NullableDoubleConverter() this.latitude,
    @_NullableDoubleConverter() this.longitude,
    @JsonKey(name: 'member_address_names')
    @_StringListConverter()
    final List<String> memberAddressNames = const <String>[],
    @JsonKey(name: 'invoice_count') @_IntConverter() this.invoiceCount = 0,
    @JsonKey(name: 'total_billed') @_DoubleConverter() this.totalBilled = 0.0,
    @_DoubleConverter() this.outstanding = 0.0,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    this.lastOrderDate,
    @_BranchSourceConverter() this.source = 'address',
    @_MapsInfoConverter() this.maps,
    @JsonKey(name: 'maps_match') @_NullableStringConverter() this.mapsMatch,
  }) : _memberAddressNames = memberAddressNames,
       super._();

  factory _$B2bBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bBranchImplFromJson(json);

  @override
  @JsonKey(name: 'address_name')
  @_NullableStringConverter()
  final String? addressName;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  final String? branchName;
  @override
  @JsonKey(name: 'address_line1')
  @_NullableStringConverter()
  final String? addressLine1;
  @override
  @JsonKey(name: 'address_line2')
  @_NullableStringConverter()
  final String? addressLine2;
  @override
  @_NullableStringConverter()
  final String? city;
  @override
  @_NullableStringConverter()
  final String? phone;
  @override
  @_NullableStringConverter()
  final String? territory;
  @override
  @JsonKey(name: 'territory_missing')
  @_BoolConverter()
  final bool territoryMissing;
  @override
  @JsonKey(name: 'is_primary_address')
  @_BoolConverter()
  final bool isPrimaryAddress;
  @override
  @_NullableDoubleConverter()
  final double? latitude;
  @override
  @_NullableDoubleConverter()
  final double? longitude;
  final List<String> _memberAddressNames;
  @override
  @JsonKey(name: 'member_address_names')
  @_StringListConverter()
  List<String> get memberAddressNames {
    if (_memberAddressNames is EqualUnmodifiableListView)
      return _memberAddressNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberAddressNames);
  }

  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  final int invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  final double totalBilled;
  @override
  @JsonKey()
  @_DoubleConverter()
  final double outstanding;
  @override
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  final String? lastOrderDate;

  /// `"address"` (a delivery branch) or `"maps"` (Google Maps only).
  @override
  @JsonKey()
  @_BranchSourceConverter()
  final String source;

  /// The Google Maps listing for this door, when one is known.
  @override
  @_MapsInfoConverter()
  final B2bMapsInfo? maps;

  /// How [maps] got attached to a delivery branch: `"linked"` (a rep chose
  /// it) or `"auto"` (matched by name / pin). Null for maps-only entries.
  @override
  @JsonKey(name: 'maps_match')
  @_NullableStringConverter()
  final String? mapsMatch;

  @override
  String toString() {
    return 'B2bBranch(addressName: $addressName, branchName: $branchName, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, phone: $phone, territory: $territory, territoryMissing: $territoryMissing, isPrimaryAddress: $isPrimaryAddress, latitude: $latitude, longitude: $longitude, memberAddressNames: $memberAddressNames, invoiceCount: $invoiceCount, totalBilled: $totalBilled, outstanding: $outstanding, lastOrderDate: $lastOrderDate, source: $source, maps: $maps, mapsMatch: $mapsMatch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bBranchImpl &&
            (identical(other.addressName, addressName) ||
                other.addressName == addressName) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.addressLine2, addressLine2) ||
                other.addressLine2 == addressLine2) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.territory, territory) ||
                other.territory == territory) &&
            (identical(other.territoryMissing, territoryMissing) ||
                other.territoryMissing == territoryMissing) &&
            (identical(other.isPrimaryAddress, isPrimaryAddress) ||
                other.isPrimaryAddress == isPrimaryAddress) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(
              other._memberAddressNames,
              _memberAddressNames,
            ) &&
            (identical(other.invoiceCount, invoiceCount) ||
                other.invoiceCount == invoiceCount) &&
            (identical(other.totalBilled, totalBilled) ||
                other.totalBilled == totalBilled) &&
            (identical(other.outstanding, outstanding) ||
                other.outstanding == outstanding) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.maps, maps) || other.maps == maps) &&
            (identical(other.mapsMatch, mapsMatch) ||
                other.mapsMatch == mapsMatch));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    addressName,
    branchName,
    addressLine1,
    addressLine2,
    city,
    phone,
    territory,
    territoryMissing,
    isPrimaryAddress,
    latitude,
    longitude,
    const DeepCollectionEquality().hash(_memberAddressNames),
    invoiceCount,
    totalBilled,
    outstanding,
    lastOrderDate,
    source,
    maps,
    mapsMatch,
  ]);

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bBranchImplCopyWith<_$B2bBranchImpl> get copyWith =>
      __$$B2bBranchImplCopyWithImpl<_$B2bBranchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bBranchImplToJson(this);
  }
}

abstract class _B2bBranch extends B2bBranch {
  const factory _B2bBranch({
    @JsonKey(name: 'address_name')
    @_NullableStringConverter()
    final String? addressName,
    @JsonKey(name: 'branch_name')
    @_NullableStringConverter()
    final String? branchName,
    @JsonKey(name: 'address_line1')
    @_NullableStringConverter()
    final String? addressLine1,
    @JsonKey(name: 'address_line2')
    @_NullableStringConverter()
    final String? addressLine2,
    @_NullableStringConverter() final String? city,
    @_NullableStringConverter() final String? phone,
    @_NullableStringConverter() final String? territory,
    @JsonKey(name: 'territory_missing')
    @_BoolConverter()
    final bool territoryMissing,
    @JsonKey(name: 'is_primary_address')
    @_BoolConverter()
    final bool isPrimaryAddress,
    @_NullableDoubleConverter() final double? latitude,
    @_NullableDoubleConverter() final double? longitude,
    @JsonKey(name: 'member_address_names')
    @_StringListConverter()
    final List<String> memberAddressNames,
    @JsonKey(name: 'invoice_count') @_IntConverter() final int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() final double totalBilled,
    @_DoubleConverter() final double outstanding,
    @JsonKey(name: 'last_order_date')
    @_NullableStringConverter()
    final String? lastOrderDate,
    @_BranchSourceConverter() final String source,
    @_MapsInfoConverter() final B2bMapsInfo? maps,
    @JsonKey(name: 'maps_match')
    @_NullableStringConverter()
    final String? mapsMatch,
  }) = _$B2bBranchImpl;
  const _B2bBranch._() : super._();

  factory _B2bBranch.fromJson(Map<String, dynamic> json) =
      _$B2bBranchImpl.fromJson;

  @override
  @JsonKey(name: 'address_name')
  @_NullableStringConverter()
  String? get addressName;
  @override
  @JsonKey(name: 'branch_name')
  @_NullableStringConverter()
  String? get branchName;
  @override
  @JsonKey(name: 'address_line1')
  @_NullableStringConverter()
  String? get addressLine1;
  @override
  @JsonKey(name: 'address_line2')
  @_NullableStringConverter()
  String? get addressLine2;
  @override
  @_NullableStringConverter()
  String? get city;
  @override
  @_NullableStringConverter()
  String? get phone;
  @override
  @_NullableStringConverter()
  String? get territory;
  @override
  @JsonKey(name: 'territory_missing')
  @_BoolConverter()
  bool get territoryMissing;
  @override
  @JsonKey(name: 'is_primary_address')
  @_BoolConverter()
  bool get isPrimaryAddress;
  @override
  @_NullableDoubleConverter()
  double? get latitude;
  @override
  @_NullableDoubleConverter()
  double? get longitude;
  @override
  @JsonKey(name: 'member_address_names')
  @_StringListConverter()
  List<String> get memberAddressNames;
  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled;
  @override
  @_DoubleConverter()
  double get outstanding;
  @override
  @JsonKey(name: 'last_order_date')
  @_NullableStringConverter()
  String? get lastOrderDate;

  /// `"address"` (a delivery branch) or `"maps"` (Google Maps only).
  @override
  @_BranchSourceConverter()
  String get source;

  /// The Google Maps listing for this door, when one is known.
  @override
  @_MapsInfoConverter()
  B2bMapsInfo? get maps;

  /// How [maps] got attached to a delivery branch: `"linked"` (a rep chose
  /// it) or `"auto"` (matched by name / pin). Null for maps-only entries.
  @override
  @JsonKey(name: 'maps_match')
  @_NullableStringConverter()
  String? get mapsMatch;

  /// Create a copy of B2bBranch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bBranchImplCopyWith<_$B2bBranchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bAccountInvoices _$B2bAccountInvoicesFromJson(Map<String, dynamic> json) {
  return _B2bAccountInvoices.fromJson(json);
}

/// @nodoc
mixin _$B2bAccountInvoices {
  @_NullableStringConverter()
  String? get customer => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get branch => throw _privateConstructorUsedError;
  List<B2bRecentInvoice> get invoices => throw _privateConstructorUsedError;
  B2bBranchStats get summary => throw _privateConstructorUsedError;
  @_BoolConverter()
  bool get truncated => throw _privateConstructorUsedError;

  /// Serializes this B2bAccountInvoices to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bAccountInvoicesCopyWith<B2bAccountInvoices> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bAccountInvoicesCopyWith<$Res> {
  factory $B2bAccountInvoicesCopyWith(
    B2bAccountInvoices value,
    $Res Function(B2bAccountInvoices) then,
  ) = _$B2bAccountInvoicesCopyWithImpl<$Res, B2bAccountInvoices>;
  @useResult
  $Res call({
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? branch,
    List<B2bRecentInvoice> invoices,
    B2bBranchStats summary,
    @_BoolConverter() bool truncated,
  });

  $B2bBranchStatsCopyWith<$Res> get summary;
}

/// @nodoc
class _$B2bAccountInvoicesCopyWithImpl<$Res, $Val extends B2bAccountInvoices>
    implements $B2bAccountInvoicesCopyWith<$Res> {
  _$B2bAccountInvoicesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = freezed,
    Object? branch = freezed,
    Object? invoices = null,
    Object? summary = null,
    Object? truncated = null,
  }) {
    return _then(
      _value.copyWith(
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String?,
            branch: freezed == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoices: null == invoices
                ? _value.invoices
                : invoices // ignore: cast_nullable_to_non_nullable
                      as List<B2bRecentInvoice>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as B2bBranchStats,
            truncated: null == truncated
                ? _value.truncated
                : truncated // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bBranchStatsCopyWith<$Res> get summary {
    return $B2bBranchStatsCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$B2bAccountInvoicesImplCopyWith<$Res>
    implements $B2bAccountInvoicesCopyWith<$Res> {
  factory _$$B2bAccountInvoicesImplCopyWith(
    _$B2bAccountInvoicesImpl value,
    $Res Function(_$B2bAccountInvoicesImpl) then,
  ) = __$$B2bAccountInvoicesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? branch,
    List<B2bRecentInvoice> invoices,
    B2bBranchStats summary,
    @_BoolConverter() bool truncated,
  });

  @override
  $B2bBranchStatsCopyWith<$Res> get summary;
}

/// @nodoc
class __$$B2bAccountInvoicesImplCopyWithImpl<$Res>
    extends _$B2bAccountInvoicesCopyWithImpl<$Res, _$B2bAccountInvoicesImpl>
    implements _$$B2bAccountInvoicesImplCopyWith<$Res> {
  __$$B2bAccountInvoicesImplCopyWithImpl(
    _$B2bAccountInvoicesImpl _value,
    $Res Function(_$B2bAccountInvoicesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = freezed,
    Object? branch = freezed,
    Object? invoices = null,
    Object? summary = null,
    Object? truncated = null,
  }) {
    return _then(
      _$B2bAccountInvoicesImpl(
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String?,
        branch: freezed == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoices: null == invoices
            ? _value._invoices
            : invoices // ignore: cast_nullable_to_non_nullable
                  as List<B2bRecentInvoice>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as B2bBranchStats,
        truncated: null == truncated
            ? _value.truncated
            : truncated // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bAccountInvoicesImpl implements _B2bAccountInvoices {
  const _$B2bAccountInvoicesImpl({
    @_NullableStringConverter() this.customer,
    @_NullableStringConverter() this.branch,
    final List<B2bRecentInvoice> invoices = const <B2bRecentInvoice>[],
    this.summary = const B2bBranchStats(),
    @_BoolConverter() this.truncated = false,
  }) : _invoices = invoices;

  factory _$B2bAccountInvoicesImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bAccountInvoicesImplFromJson(json);

  @override
  @_NullableStringConverter()
  final String? customer;
  @override
  @_NullableStringConverter()
  final String? branch;
  final List<B2bRecentInvoice> _invoices;
  @override
  @JsonKey()
  List<B2bRecentInvoice> get invoices {
    if (_invoices is EqualUnmodifiableListView) return _invoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invoices);
  }

  @override
  @JsonKey()
  final B2bBranchStats summary;
  @override
  @JsonKey()
  @_BoolConverter()
  final bool truncated;

  @override
  String toString() {
    return 'B2bAccountInvoices(customer: $customer, branch: $branch, invoices: $invoices, summary: $summary, truncated: $truncated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bAccountInvoicesImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            const DeepCollectionEquality().equals(other._invoices, _invoices) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.truncated, truncated) ||
                other.truncated == truncated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    branch,
    const DeepCollectionEquality().hash(_invoices),
    summary,
    truncated,
  );

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bAccountInvoicesImplCopyWith<_$B2bAccountInvoicesImpl> get copyWith =>
      __$$B2bAccountInvoicesImplCopyWithImpl<_$B2bAccountInvoicesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bAccountInvoicesImplToJson(this);
  }
}

abstract class _B2bAccountInvoices implements B2bAccountInvoices {
  const factory _B2bAccountInvoices({
    @_NullableStringConverter() final String? customer,
    @_NullableStringConverter() final String? branch,
    final List<B2bRecentInvoice> invoices,
    final B2bBranchStats summary,
    @_BoolConverter() final bool truncated,
  }) = _$B2bAccountInvoicesImpl;

  factory _B2bAccountInvoices.fromJson(Map<String, dynamic> json) =
      _$B2bAccountInvoicesImpl.fromJson;

  @override
  @_NullableStringConverter()
  String? get customer;
  @override
  @_NullableStringConverter()
  String? get branch;
  @override
  List<B2bRecentInvoice> get invoices;
  @override
  B2bBranchStats get summary;
  @override
  @_BoolConverter()
  bool get truncated;

  /// Create a copy of B2bAccountInvoices
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bAccountInvoicesImplCopyWith<_$B2bAccountInvoicesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bMergeCandidate _$B2bMergeCandidateFromJson(Map<String, dynamic> json) {
  return _B2bMergeCandidate.fromJson(json);
}

/// @nodoc
mixin _$B2bMergeCandidate {
  String get doctype => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get title => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get customer => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get stage => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get area => throw _privateConstructorUsedError;
  @JsonKey(name: 'mobile_no')
  @_NullableStringConverter()
  String? get mobileNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_count')
  @_IntConverter()
  int get branchCount => throw _privateConstructorUsedError;

  /// Serializes this B2bMergeCandidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMergeCandidateCopyWith<B2bMergeCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMergeCandidateCopyWith<$Res> {
  factory $B2bMergeCandidateCopyWith(
    B2bMergeCandidate value,
    $Res Function(B2bMergeCandidate) then,
  ) = _$B2bMergeCandidateCopyWithImpl<$Res, B2bMergeCandidate>;
  @useResult
  $Res call({
    String doctype,
    String name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? stage,
    @_NullableStringConverter() String? area,
    @JsonKey(name: 'mobile_no') @_NullableStringConverter() String? mobileNo,
    @JsonKey(name: 'branch_count') @_IntConverter() int branchCount,
  });
}

/// @nodoc
class _$B2bMergeCandidateCopyWithImpl<$Res, $Val extends B2bMergeCandidate>
    implements $B2bMergeCandidateCopyWith<$Res> {
  _$B2bMergeCandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = freezed,
    Object? customer = freezed,
    Object? stage = freezed,
    Object? area = freezed,
    Object? mobileNo = freezed,
    Object? branchCount = null,
  }) {
    return _then(
      _value.copyWith(
            doctype: null == doctype
                ? _value.doctype
                : doctype // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String?,
            stage: freezed == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as String?,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String?,
            mobileNo: freezed == mobileNo
                ? _value.mobileNo
                : mobileNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchCount: null == branchCount
                ? _value.branchCount
                : branchCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bMergeCandidateImplCopyWith<$Res>
    implements $B2bMergeCandidateCopyWith<$Res> {
  factory _$$B2bMergeCandidateImplCopyWith(
    _$B2bMergeCandidateImpl value,
    $Res Function(_$B2bMergeCandidateImpl) then,
  ) = __$$B2bMergeCandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String doctype,
    String name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? customer,
    @_NullableStringConverter() String? stage,
    @_NullableStringConverter() String? area,
    @JsonKey(name: 'mobile_no') @_NullableStringConverter() String? mobileNo,
    @JsonKey(name: 'branch_count') @_IntConverter() int branchCount,
  });
}

/// @nodoc
class __$$B2bMergeCandidateImplCopyWithImpl<$Res>
    extends _$B2bMergeCandidateCopyWithImpl<$Res, _$B2bMergeCandidateImpl>
    implements _$$B2bMergeCandidateImplCopyWith<$Res> {
  __$$B2bMergeCandidateImplCopyWithImpl(
    _$B2bMergeCandidateImpl _value,
    $Res Function(_$B2bMergeCandidateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = freezed,
    Object? customer = freezed,
    Object? stage = freezed,
    Object? area = freezed,
    Object? mobileNo = freezed,
    Object? branchCount = null,
  }) {
    return _then(
      _$B2bMergeCandidateImpl(
        doctype: null == doctype
            ? _value.doctype
            : doctype // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String?,
        stage: freezed == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String?,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String?,
        mobileNo: freezed == mobileNo
            ? _value.mobileNo
            : mobileNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchCount: null == branchCount
            ? _value.branchCount
            : branchCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMergeCandidateImpl extends _B2bMergeCandidate {
  const _$B2bMergeCandidateImpl({
    this.doctype = 'Lead',
    required this.name,
    @_NullableStringConverter() this.title,
    @_NullableStringConverter() this.customer,
    @_NullableStringConverter() this.stage,
    @_NullableStringConverter() this.area,
    @JsonKey(name: 'mobile_no') @_NullableStringConverter() this.mobileNo,
    @JsonKey(name: 'branch_count') @_IntConverter() this.branchCount = 0,
  }) : super._();

  factory _$B2bMergeCandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMergeCandidateImplFromJson(json);

  @override
  @JsonKey()
  final String doctype;
  @override
  final String name;
  @override
  @_NullableStringConverter()
  final String? title;
  @override
  @_NullableStringConverter()
  final String? customer;
  @override
  @_NullableStringConverter()
  final String? stage;
  @override
  @_NullableStringConverter()
  final String? area;
  @override
  @JsonKey(name: 'mobile_no')
  @_NullableStringConverter()
  final String? mobileNo;
  @override
  @JsonKey(name: 'branch_count')
  @_IntConverter()
  final int branchCount;

  @override
  String toString() {
    return 'B2bMergeCandidate(doctype: $doctype, name: $name, title: $title, customer: $customer, stage: $stage, area: $area, mobileNo: $mobileNo, branchCount: $branchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMergeCandidateImpl &&
            (identical(other.doctype, doctype) || other.doctype == doctype) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.mobileNo, mobileNo) ||
                other.mobileNo == mobileNo) &&
            (identical(other.branchCount, branchCount) ||
                other.branchCount == branchCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    doctype,
    name,
    title,
    customer,
    stage,
    area,
    mobileNo,
    branchCount,
  );

  /// Create a copy of B2bMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMergeCandidateImplCopyWith<_$B2bMergeCandidateImpl> get copyWith =>
      __$$B2bMergeCandidateImplCopyWithImpl<_$B2bMergeCandidateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMergeCandidateImplToJson(this);
  }
}

abstract class _B2bMergeCandidate extends B2bMergeCandidate {
  const factory _B2bMergeCandidate({
    final String doctype,
    required final String name,
    @_NullableStringConverter() final String? title,
    @_NullableStringConverter() final String? customer,
    @_NullableStringConverter() final String? stage,
    @_NullableStringConverter() final String? area,
    @JsonKey(name: 'mobile_no')
    @_NullableStringConverter()
    final String? mobileNo,
    @JsonKey(name: 'branch_count') @_IntConverter() final int branchCount,
  }) = _$B2bMergeCandidateImpl;
  const _B2bMergeCandidate._() : super._();

  factory _B2bMergeCandidate.fromJson(Map<String, dynamic> json) =
      _$B2bMergeCandidateImpl.fromJson;

  @override
  String get doctype;
  @override
  String get name;
  @override
  @_NullableStringConverter()
  String? get title;
  @override
  @_NullableStringConverter()
  String? get customer;
  @override
  @_NullableStringConverter()
  String? get stage;
  @override
  @_NullableStringConverter()
  String? get area;
  @override
  @JsonKey(name: 'mobile_no')
  @_NullableStringConverter()
  String? get mobileNo;
  @override
  @JsonKey(name: 'branch_count')
  @_IntConverter()
  int get branchCount;

  /// Create a copy of B2bMergeCandidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMergeCandidateImplCopyWith<_$B2bMergeCandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bMergeParty _$B2bMergePartyFromJson(Map<String, dynamic> json) {
  return _B2bMergeParty.fromJson(json);
}

/// @nodoc
mixin _$B2bMergeParty {
  @_NullableStringConverter()
  String? get doctype => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get name => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get title => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get lead => throw _privateConstructorUsedError;
  @_NullableStringConverter()
  String? get customer => throw _privateConstructorUsedError;

  /// Serializes this B2bMergeParty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMergeParty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMergePartyCopyWith<B2bMergeParty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMergePartyCopyWith<$Res> {
  factory $B2bMergePartyCopyWith(
    B2bMergeParty value,
    $Res Function(B2bMergeParty) then,
  ) = _$B2bMergePartyCopyWithImpl<$Res, B2bMergeParty>;
  @useResult
  $Res call({
    @_NullableStringConverter() String? doctype,
    @_NullableStringConverter() String? name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? lead,
    @_NullableStringConverter() String? customer,
  });
}

/// @nodoc
class _$B2bMergePartyCopyWithImpl<$Res, $Val extends B2bMergeParty>
    implements $B2bMergePartyCopyWith<$Res> {
  _$B2bMergePartyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMergeParty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = freezed,
    Object? name = freezed,
    Object? title = freezed,
    Object? lead = freezed,
    Object? customer = freezed,
  }) {
    return _then(
      _value.copyWith(
            doctype: freezed == doctype
                ? _value.doctype
                : doctype // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            lead: freezed == lead
                ? _value.lead
                : lead // ignore: cast_nullable_to_non_nullable
                      as String?,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bMergePartyImplCopyWith<$Res>
    implements $B2bMergePartyCopyWith<$Res> {
  factory _$$B2bMergePartyImplCopyWith(
    _$B2bMergePartyImpl value,
    $Res Function(_$B2bMergePartyImpl) then,
  ) = __$$B2bMergePartyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_NullableStringConverter() String? doctype,
    @_NullableStringConverter() String? name,
    @_NullableStringConverter() String? title,
    @_NullableStringConverter() String? lead,
    @_NullableStringConverter() String? customer,
  });
}

/// @nodoc
class __$$B2bMergePartyImplCopyWithImpl<$Res>
    extends _$B2bMergePartyCopyWithImpl<$Res, _$B2bMergePartyImpl>
    implements _$$B2bMergePartyImplCopyWith<$Res> {
  __$$B2bMergePartyImplCopyWithImpl(
    _$B2bMergePartyImpl _value,
    $Res Function(_$B2bMergePartyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMergeParty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = freezed,
    Object? name = freezed,
    Object? title = freezed,
    Object? lead = freezed,
    Object? customer = freezed,
  }) {
    return _then(
      _$B2bMergePartyImpl(
        doctype: freezed == doctype
            ? _value.doctype
            : doctype // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        lead: freezed == lead
            ? _value.lead
            : lead // ignore: cast_nullable_to_non_nullable
                  as String?,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMergePartyImpl extends _B2bMergeParty {
  const _$B2bMergePartyImpl({
    @_NullableStringConverter() this.doctype,
    @_NullableStringConverter() this.name,
    @_NullableStringConverter() this.title,
    @_NullableStringConverter() this.lead,
    @_NullableStringConverter() this.customer,
  }) : super._();

  factory _$B2bMergePartyImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMergePartyImplFromJson(json);

  @override
  @_NullableStringConverter()
  final String? doctype;
  @override
  @_NullableStringConverter()
  final String? name;
  @override
  @_NullableStringConverter()
  final String? title;
  @override
  @_NullableStringConverter()
  final String? lead;
  @override
  @_NullableStringConverter()
  final String? customer;

  @override
  String toString() {
    return 'B2bMergeParty(doctype: $doctype, name: $name, title: $title, lead: $lead, customer: $customer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMergePartyImpl &&
            (identical(other.doctype, doctype) || other.doctype == doctype) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lead, lead) || other.lead == lead) &&
            (identical(other.customer, customer) ||
                other.customer == customer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, doctype, name, title, lead, customer);

  /// Create a copy of B2bMergeParty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMergePartyImplCopyWith<_$B2bMergePartyImpl> get copyWith =>
      __$$B2bMergePartyImplCopyWithImpl<_$B2bMergePartyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMergePartyImplToJson(this);
  }
}

abstract class _B2bMergeParty extends B2bMergeParty {
  const factory _B2bMergeParty({
    @_NullableStringConverter() final String? doctype,
    @_NullableStringConverter() final String? name,
    @_NullableStringConverter() final String? title,
    @_NullableStringConverter() final String? lead,
    @_NullableStringConverter() final String? customer,
  }) = _$B2bMergePartyImpl;
  const _B2bMergeParty._() : super._();

  factory _B2bMergeParty.fromJson(Map<String, dynamic> json) =
      _$B2bMergePartyImpl.fromJson;

  @override
  @_NullableStringConverter()
  String? get doctype;
  @override
  @_NullableStringConverter()
  String? get name;
  @override
  @_NullableStringConverter()
  String? get title;
  @override
  @_NullableStringConverter()
  String? get lead;
  @override
  @_NullableStringConverter()
  String? get customer;

  /// Create a copy of B2bMergeParty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMergePartyImplCopyWith<_$B2bMergePartyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bMergePlan _$B2bMergePlanFromJson(Map<String, dynamic> json) {
  return _B2bMergePlan.fromJson(json);
}

/// @nodoc
mixin _$B2bMergePlan {
  @JsonKey(name: 'customer_action')
  @_NullableStringConverter()
  String? get customerAction => throw _privateConstructorUsedError;
  @JsonKey(name: 'lead_action')
  @_NullableStringConverter()
  String? get leadAction => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_manager')
  @_BoolConverter()
  bool get requiresManager => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_customer')
  @_NullableStringConverter()
  String? get finalCustomer => throw _privateConstructorUsedError;

  /// Serializes this B2bMergePlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMergePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMergePlanCopyWith<B2bMergePlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMergePlanCopyWith<$Res> {
  factory $B2bMergePlanCopyWith(
    B2bMergePlan value,
    $Res Function(B2bMergePlan) then,
  ) = _$B2bMergePlanCopyWithImpl<$Res, B2bMergePlan>;
  @useResult
  $Res call({
    @JsonKey(name: 'customer_action')
    @_NullableStringConverter()
    String? customerAction,
    @JsonKey(name: 'lead_action')
    @_NullableStringConverter()
    String? leadAction,
    @JsonKey(name: 'requires_manager') @_BoolConverter() bool requiresManager,
    @JsonKey(name: 'final_customer')
    @_NullableStringConverter()
    String? finalCustomer,
  });
}

/// @nodoc
class _$B2bMergePlanCopyWithImpl<$Res, $Val extends B2bMergePlan>
    implements $B2bMergePlanCopyWith<$Res> {
  _$B2bMergePlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMergePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerAction = freezed,
    Object? leadAction = freezed,
    Object? requiresManager = null,
    Object? finalCustomer = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerAction: freezed == customerAction
                ? _value.customerAction
                : customerAction // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadAction: freezed == leadAction
                ? _value.leadAction
                : leadAction // ignore: cast_nullable_to_non_nullable
                      as String?,
            requiresManager: null == requiresManager
                ? _value.requiresManager
                : requiresManager // ignore: cast_nullable_to_non_nullable
                      as bool,
            finalCustomer: freezed == finalCustomer
                ? _value.finalCustomer
                : finalCustomer // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bMergePlanImplCopyWith<$Res>
    implements $B2bMergePlanCopyWith<$Res> {
  factory _$$B2bMergePlanImplCopyWith(
    _$B2bMergePlanImpl value,
    $Res Function(_$B2bMergePlanImpl) then,
  ) = __$$B2bMergePlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'customer_action')
    @_NullableStringConverter()
    String? customerAction,
    @JsonKey(name: 'lead_action')
    @_NullableStringConverter()
    String? leadAction,
    @JsonKey(name: 'requires_manager') @_BoolConverter() bool requiresManager,
    @JsonKey(name: 'final_customer')
    @_NullableStringConverter()
    String? finalCustomer,
  });
}

/// @nodoc
class __$$B2bMergePlanImplCopyWithImpl<$Res>
    extends _$B2bMergePlanCopyWithImpl<$Res, _$B2bMergePlanImpl>
    implements _$$B2bMergePlanImplCopyWith<$Res> {
  __$$B2bMergePlanImplCopyWithImpl(
    _$B2bMergePlanImpl _value,
    $Res Function(_$B2bMergePlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMergePlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerAction = freezed,
    Object? leadAction = freezed,
    Object? requiresManager = null,
    Object? finalCustomer = freezed,
  }) {
    return _then(
      _$B2bMergePlanImpl(
        customerAction: freezed == customerAction
            ? _value.customerAction
            : customerAction // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadAction: freezed == leadAction
            ? _value.leadAction
            : leadAction // ignore: cast_nullable_to_non_nullable
                  as String?,
        requiresManager: null == requiresManager
            ? _value.requiresManager
            : requiresManager // ignore: cast_nullable_to_non_nullable
                  as bool,
        finalCustomer: freezed == finalCustomer
            ? _value.finalCustomer
            : finalCustomer // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMergePlanImpl implements _B2bMergePlan {
  const _$B2bMergePlanImpl({
    @JsonKey(name: 'customer_action')
    @_NullableStringConverter()
    this.customerAction,
    @JsonKey(name: 'lead_action') @_NullableStringConverter() this.leadAction,
    @JsonKey(name: 'requires_manager')
    @_BoolConverter()
    this.requiresManager = false,
    @JsonKey(name: 'final_customer')
    @_NullableStringConverter()
    this.finalCustomer,
  });

  factory _$B2bMergePlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMergePlanImplFromJson(json);

  @override
  @JsonKey(name: 'customer_action')
  @_NullableStringConverter()
  final String? customerAction;
  @override
  @JsonKey(name: 'lead_action')
  @_NullableStringConverter()
  final String? leadAction;
  @override
  @JsonKey(name: 'requires_manager')
  @_BoolConverter()
  final bool requiresManager;
  @override
  @JsonKey(name: 'final_customer')
  @_NullableStringConverter()
  final String? finalCustomer;

  @override
  String toString() {
    return 'B2bMergePlan(customerAction: $customerAction, leadAction: $leadAction, requiresManager: $requiresManager, finalCustomer: $finalCustomer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMergePlanImpl &&
            (identical(other.customerAction, customerAction) ||
                other.customerAction == customerAction) &&
            (identical(other.leadAction, leadAction) ||
                other.leadAction == leadAction) &&
            (identical(other.requiresManager, requiresManager) ||
                other.requiresManager == requiresManager) &&
            (identical(other.finalCustomer, finalCustomer) ||
                other.finalCustomer == finalCustomer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerAction,
    leadAction,
    requiresManager,
    finalCustomer,
  );

  /// Create a copy of B2bMergePlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMergePlanImplCopyWith<_$B2bMergePlanImpl> get copyWith =>
      __$$B2bMergePlanImplCopyWithImpl<_$B2bMergePlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMergePlanImplToJson(this);
  }
}

abstract class _B2bMergePlan implements B2bMergePlan {
  const factory _B2bMergePlan({
    @JsonKey(name: 'customer_action')
    @_NullableStringConverter()
    final String? customerAction,
    @JsonKey(name: 'lead_action')
    @_NullableStringConverter()
    final String? leadAction,
    @JsonKey(name: 'requires_manager')
    @_BoolConverter()
    final bool requiresManager,
    @JsonKey(name: 'final_customer')
    @_NullableStringConverter()
    final String? finalCustomer,
  }) = _$B2bMergePlanImpl;

  factory _B2bMergePlan.fromJson(Map<String, dynamic> json) =
      _$B2bMergePlanImpl.fromJson;

  @override
  @JsonKey(name: 'customer_action')
  @_NullableStringConverter()
  String? get customerAction;
  @override
  @JsonKey(name: 'lead_action')
  @_NullableStringConverter()
  String? get leadAction;
  @override
  @JsonKey(name: 'requires_manager')
  @_BoolConverter()
  bool get requiresManager;
  @override
  @JsonKey(name: 'final_customer')
  @_NullableStringConverter()
  String? get finalCustomer;

  /// Create a copy of B2bMergePlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMergePlanImplCopyWith<_$B2bMergePlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bMergeCustomerSummary _$B2bMergeCustomerSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _B2bMergeCustomerSummary.fromJson(json);
}

/// @nodoc
mixin _$B2bMergeCustomerSummary {
  @_NullableStringConverter()
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  @_NullableStringConverter()
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled => throw _privateConstructorUsedError;
  @_DoubleConverter()
  double get outstanding => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_count')
  @_IntConverter()
  int get addressCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'credit_allowed')
  @_BoolConverter()
  bool get creditAllowed => throw _privateConstructorUsedError;

  /// Serializes this B2bMergeCustomerSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMergeCustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMergeCustomerSummaryCopyWith<B2bMergeCustomerSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMergeCustomerSummaryCopyWith<$Res> {
  factory $B2bMergeCustomerSummaryCopyWith(
    B2bMergeCustomerSummary value,
    $Res Function(B2bMergeCustomerSummary) then,
  ) = _$B2bMergeCustomerSummaryCopyWithImpl<$Res, B2bMergeCustomerSummary>;
  @useResult
  $Res call({
    @_NullableStringConverter() String? name,
    @JsonKey(name: 'customer_name')
    @_NullableStringConverter()
    String? customerName,
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'address_count') @_IntConverter() int addressCount,
    @JsonKey(name: 'credit_allowed') @_BoolConverter() bool creditAllowed,
  });
}

/// @nodoc
class _$B2bMergeCustomerSummaryCopyWithImpl<
  $Res,
  $Val extends B2bMergeCustomerSummary
>
    implements $B2bMergeCustomerSummaryCopyWith<$Res> {
  _$B2bMergeCustomerSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMergeCustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? customerName = freezed,
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? addressCount = null,
    Object? creditAllowed = null,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceCount: null == invoiceCount
                ? _value.invoiceCount
                : invoiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBilled: null == totalBilled
                ? _value.totalBilled
                : totalBilled // ignore: cast_nullable_to_non_nullable
                      as double,
            outstanding: null == outstanding
                ? _value.outstanding
                : outstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            addressCount: null == addressCount
                ? _value.addressCount
                : addressCount // ignore: cast_nullable_to_non_nullable
                      as int,
            creditAllowed: null == creditAllowed
                ? _value.creditAllowed
                : creditAllowed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bMergeCustomerSummaryImplCopyWith<$Res>
    implements $B2bMergeCustomerSummaryCopyWith<$Res> {
  factory _$$B2bMergeCustomerSummaryImplCopyWith(
    _$B2bMergeCustomerSummaryImpl value,
    $Res Function(_$B2bMergeCustomerSummaryImpl) then,
  ) = __$$B2bMergeCustomerSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_NullableStringConverter() String? name,
    @JsonKey(name: 'customer_name')
    @_NullableStringConverter()
    String? customerName,
    @JsonKey(name: 'invoice_count') @_IntConverter() int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() double totalBilled,
    @_DoubleConverter() double outstanding,
    @JsonKey(name: 'address_count') @_IntConverter() int addressCount,
    @JsonKey(name: 'credit_allowed') @_BoolConverter() bool creditAllowed,
  });
}

/// @nodoc
class __$$B2bMergeCustomerSummaryImplCopyWithImpl<$Res>
    extends
        _$B2bMergeCustomerSummaryCopyWithImpl<
          $Res,
          _$B2bMergeCustomerSummaryImpl
        >
    implements _$$B2bMergeCustomerSummaryImplCopyWith<$Res> {
  __$$B2bMergeCustomerSummaryImplCopyWithImpl(
    _$B2bMergeCustomerSummaryImpl _value,
    $Res Function(_$B2bMergeCustomerSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMergeCustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? customerName = freezed,
    Object? invoiceCount = null,
    Object? totalBilled = null,
    Object? outstanding = null,
    Object? addressCount = null,
    Object? creditAllowed = null,
  }) {
    return _then(
      _$B2bMergeCustomerSummaryImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceCount: null == invoiceCount
            ? _value.invoiceCount
            : invoiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBilled: null == totalBilled
            ? _value.totalBilled
            : totalBilled // ignore: cast_nullable_to_non_nullable
                  as double,
        outstanding: null == outstanding
            ? _value.outstanding
            : outstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        addressCount: null == addressCount
            ? _value.addressCount
            : addressCount // ignore: cast_nullable_to_non_nullable
                  as int,
        creditAllowed: null == creditAllowed
            ? _value.creditAllowed
            : creditAllowed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMergeCustomerSummaryImpl implements _B2bMergeCustomerSummary {
  const _$B2bMergeCustomerSummaryImpl({
    @_NullableStringConverter() this.name,
    @JsonKey(name: 'customer_name')
    @_NullableStringConverter()
    this.customerName,
    @JsonKey(name: 'invoice_count') @_IntConverter() this.invoiceCount = 0,
    @JsonKey(name: 'total_billed') @_DoubleConverter() this.totalBilled = 0.0,
    @_DoubleConverter() this.outstanding = 0.0,
    @JsonKey(name: 'address_count') @_IntConverter() this.addressCount = 0,
    @JsonKey(name: 'credit_allowed')
    @_BoolConverter()
    this.creditAllowed = false,
  });

  factory _$B2bMergeCustomerSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMergeCustomerSummaryImplFromJson(json);

  @override
  @_NullableStringConverter()
  final String? name;
  @override
  @JsonKey(name: 'customer_name')
  @_NullableStringConverter()
  final String? customerName;
  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  final int invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  final double totalBilled;
  @override
  @JsonKey()
  @_DoubleConverter()
  final double outstanding;
  @override
  @JsonKey(name: 'address_count')
  @_IntConverter()
  final int addressCount;
  @override
  @JsonKey(name: 'credit_allowed')
  @_BoolConverter()
  final bool creditAllowed;

  @override
  String toString() {
    return 'B2bMergeCustomerSummary(name: $name, customerName: $customerName, invoiceCount: $invoiceCount, totalBilled: $totalBilled, outstanding: $outstanding, addressCount: $addressCount, creditAllowed: $creditAllowed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMergeCustomerSummaryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.invoiceCount, invoiceCount) ||
                other.invoiceCount == invoiceCount) &&
            (identical(other.totalBilled, totalBilled) ||
                other.totalBilled == totalBilled) &&
            (identical(other.outstanding, outstanding) ||
                other.outstanding == outstanding) &&
            (identical(other.addressCount, addressCount) ||
                other.addressCount == addressCount) &&
            (identical(other.creditAllowed, creditAllowed) ||
                other.creditAllowed == creditAllowed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    customerName,
    invoiceCount,
    totalBilled,
    outstanding,
    addressCount,
    creditAllowed,
  );

  /// Create a copy of B2bMergeCustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMergeCustomerSummaryImplCopyWith<_$B2bMergeCustomerSummaryImpl>
  get copyWith =>
      __$$B2bMergeCustomerSummaryImplCopyWithImpl<
        _$B2bMergeCustomerSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMergeCustomerSummaryImplToJson(this);
  }
}

abstract class _B2bMergeCustomerSummary implements B2bMergeCustomerSummary {
  const factory _B2bMergeCustomerSummary({
    @_NullableStringConverter() final String? name,
    @JsonKey(name: 'customer_name')
    @_NullableStringConverter()
    final String? customerName,
    @JsonKey(name: 'invoice_count') @_IntConverter() final int invoiceCount,
    @JsonKey(name: 'total_billed') @_DoubleConverter() final double totalBilled,
    @_DoubleConverter() final double outstanding,
    @JsonKey(name: 'address_count') @_IntConverter() final int addressCount,
    @JsonKey(name: 'credit_allowed') @_BoolConverter() final bool creditAllowed,
  }) = _$B2bMergeCustomerSummaryImpl;

  factory _B2bMergeCustomerSummary.fromJson(Map<String, dynamic> json) =
      _$B2bMergeCustomerSummaryImpl.fromJson;

  @override
  @_NullableStringConverter()
  String? get name;
  @override
  @JsonKey(name: 'customer_name')
  @_NullableStringConverter()
  String? get customerName;
  @override
  @JsonKey(name: 'invoice_count')
  @_IntConverter()
  int get invoiceCount;
  @override
  @JsonKey(name: 'total_billed')
  @_DoubleConverter()
  double get totalBilled;
  @override
  @_DoubleConverter()
  double get outstanding;
  @override
  @JsonKey(name: 'address_count')
  @_IntConverter()
  int get addressCount;
  @override
  @JsonKey(name: 'credit_allowed')
  @_BoolConverter()
  bool get creditAllowed;

  /// Create a copy of B2bMergeCustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMergeCustomerSummaryImplCopyWith<_$B2bMergeCustomerSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

B2bMergePreview _$B2bMergePreviewFromJson(Map<String, dynamic> json) {
  return _B2bMergePreview.fromJson(json);
}

/// @nodoc
mixin _$B2bMergePreview {
  B2bMergeParty get source => throw _privateConstructorUsedError;
  B2bMergeParty get target => throw _privateConstructorUsedError;
  B2bMergePlan get plan => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_customer')
  B2bMergeCustomerSummary? get sourceCustomer =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'target_customer')
  B2bMergeCustomerSummary? get targetCustomer =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'can_execute')
  @_BoolConverter()
  bool get canExecute => throw _privateConstructorUsedError;
  @_StringListConverter()
  List<String> get warnings => throw _privateConstructorUsedError;

  /// Server-written sentences explaining why the merge cannot run at all
  /// (not a permission issue). Non-empty implies `can_execute == false`.
  @_StringListConverter()
  List<String> get blockers => throw _privateConstructorUsedError;

  /// Serializes this B2bMergePreview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bMergePreviewCopyWith<B2bMergePreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bMergePreviewCopyWith<$Res> {
  factory $B2bMergePreviewCopyWith(
    B2bMergePreview value,
    $Res Function(B2bMergePreview) then,
  ) = _$B2bMergePreviewCopyWithImpl<$Res, B2bMergePreview>;
  @useResult
  $Res call({
    B2bMergeParty source,
    B2bMergeParty target,
    B2bMergePlan plan,
    @JsonKey(name: 'source_customer') B2bMergeCustomerSummary? sourceCustomer,
    @JsonKey(name: 'target_customer') B2bMergeCustomerSummary? targetCustomer,
    @JsonKey(name: 'can_execute') @_BoolConverter() bool canExecute,
    @_StringListConverter() List<String> warnings,
    @_StringListConverter() List<String> blockers,
  });

  $B2bMergePartyCopyWith<$Res> get source;
  $B2bMergePartyCopyWith<$Res> get target;
  $B2bMergePlanCopyWith<$Res> get plan;
  $B2bMergeCustomerSummaryCopyWith<$Res>? get sourceCustomer;
  $B2bMergeCustomerSummaryCopyWith<$Res>? get targetCustomer;
}

/// @nodoc
class _$B2bMergePreviewCopyWithImpl<$Res, $Val extends B2bMergePreview>
    implements $B2bMergePreviewCopyWith<$Res> {
  _$B2bMergePreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? plan = null,
    Object? sourceCustomer = freezed,
    Object? targetCustomer = freezed,
    Object? canExecute = null,
    Object? warnings = null,
    Object? blockers = null,
  }) {
    return _then(
      _value.copyWith(
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as B2bMergeParty,
            target: null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as B2bMergeParty,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as B2bMergePlan,
            sourceCustomer: freezed == sourceCustomer
                ? _value.sourceCustomer
                : sourceCustomer // ignore: cast_nullable_to_non_nullable
                      as B2bMergeCustomerSummary?,
            targetCustomer: freezed == targetCustomer
                ? _value.targetCustomer
                : targetCustomer // ignore: cast_nullable_to_non_nullable
                      as B2bMergeCustomerSummary?,
            canExecute: null == canExecute
                ? _value.canExecute
                : canExecute // ignore: cast_nullable_to_non_nullable
                      as bool,
            warnings: null == warnings
                ? _value.warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            blockers: null == blockers
                ? _value.blockers
                : blockers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMergePartyCopyWith<$Res> get source {
    return $B2bMergePartyCopyWith<$Res>(_value.source, (value) {
      return _then(_value.copyWith(source: value) as $Val);
    });
  }

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMergePartyCopyWith<$Res> get target {
    return $B2bMergePartyCopyWith<$Res>(_value.target, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMergePlanCopyWith<$Res> get plan {
    return $B2bMergePlanCopyWith<$Res>(_value.plan, (value) {
      return _then(_value.copyWith(plan: value) as $Val);
    });
  }

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMergeCustomerSummaryCopyWith<$Res>? get sourceCustomer {
    if (_value.sourceCustomer == null) {
      return null;
    }

    return $B2bMergeCustomerSummaryCopyWith<$Res>(_value.sourceCustomer!, (
      value,
    ) {
      return _then(_value.copyWith(sourceCustomer: value) as $Val);
    });
  }

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bMergeCustomerSummaryCopyWith<$Res>? get targetCustomer {
    if (_value.targetCustomer == null) {
      return null;
    }

    return $B2bMergeCustomerSummaryCopyWith<$Res>(_value.targetCustomer!, (
      value,
    ) {
      return _then(_value.copyWith(targetCustomer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$B2bMergePreviewImplCopyWith<$Res>
    implements $B2bMergePreviewCopyWith<$Res> {
  factory _$$B2bMergePreviewImplCopyWith(
    _$B2bMergePreviewImpl value,
    $Res Function(_$B2bMergePreviewImpl) then,
  ) = __$$B2bMergePreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    B2bMergeParty source,
    B2bMergeParty target,
    B2bMergePlan plan,
    @JsonKey(name: 'source_customer') B2bMergeCustomerSummary? sourceCustomer,
    @JsonKey(name: 'target_customer') B2bMergeCustomerSummary? targetCustomer,
    @JsonKey(name: 'can_execute') @_BoolConverter() bool canExecute,
    @_StringListConverter() List<String> warnings,
    @_StringListConverter() List<String> blockers,
  });

  @override
  $B2bMergePartyCopyWith<$Res> get source;
  @override
  $B2bMergePartyCopyWith<$Res> get target;
  @override
  $B2bMergePlanCopyWith<$Res> get plan;
  @override
  $B2bMergeCustomerSummaryCopyWith<$Res>? get sourceCustomer;
  @override
  $B2bMergeCustomerSummaryCopyWith<$Res>? get targetCustomer;
}

/// @nodoc
class __$$B2bMergePreviewImplCopyWithImpl<$Res>
    extends _$B2bMergePreviewCopyWithImpl<$Res, _$B2bMergePreviewImpl>
    implements _$$B2bMergePreviewImplCopyWith<$Res> {
  __$$B2bMergePreviewImplCopyWithImpl(
    _$B2bMergePreviewImpl _value,
    $Res Function(_$B2bMergePreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? target = null,
    Object? plan = null,
    Object? sourceCustomer = freezed,
    Object? targetCustomer = freezed,
    Object? canExecute = null,
    Object? warnings = null,
    Object? blockers = null,
  }) {
    return _then(
      _$B2bMergePreviewImpl(
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as B2bMergeParty,
        target: null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as B2bMergeParty,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as B2bMergePlan,
        sourceCustomer: freezed == sourceCustomer
            ? _value.sourceCustomer
            : sourceCustomer // ignore: cast_nullable_to_non_nullable
                  as B2bMergeCustomerSummary?,
        targetCustomer: freezed == targetCustomer
            ? _value.targetCustomer
            : targetCustomer // ignore: cast_nullable_to_non_nullable
                  as B2bMergeCustomerSummary?,
        canExecute: null == canExecute
            ? _value.canExecute
            : canExecute // ignore: cast_nullable_to_non_nullable
                  as bool,
        warnings: null == warnings
            ? _value._warnings
            : warnings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        blockers: null == blockers
            ? _value._blockers
            : blockers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bMergePreviewImpl implements _B2bMergePreview {
  const _$B2bMergePreviewImpl({
    this.source = const B2bMergeParty(),
    this.target = const B2bMergeParty(),
    this.plan = const B2bMergePlan(),
    @JsonKey(name: 'source_customer') this.sourceCustomer,
    @JsonKey(name: 'target_customer') this.targetCustomer,
    @JsonKey(name: 'can_execute') @_BoolConverter() this.canExecute = false,
    @_StringListConverter() final List<String> warnings = const <String>[],
    @_StringListConverter() final List<String> blockers = const <String>[],
  }) : _warnings = warnings,
       _blockers = blockers;

  factory _$B2bMergePreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bMergePreviewImplFromJson(json);

  @override
  @JsonKey()
  final B2bMergeParty source;
  @override
  @JsonKey()
  final B2bMergeParty target;
  @override
  @JsonKey()
  final B2bMergePlan plan;
  @override
  @JsonKey(name: 'source_customer')
  final B2bMergeCustomerSummary? sourceCustomer;
  @override
  @JsonKey(name: 'target_customer')
  final B2bMergeCustomerSummary? targetCustomer;
  @override
  @JsonKey(name: 'can_execute')
  @_BoolConverter()
  final bool canExecute;
  final List<String> _warnings;
  @override
  @JsonKey()
  @_StringListConverter()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  /// Server-written sentences explaining why the merge cannot run at all
  /// (not a permission issue). Non-empty implies `can_execute == false`.
  final List<String> _blockers;

  /// Server-written sentences explaining why the merge cannot run at all
  /// (not a permission issue). Non-empty implies `can_execute == false`.
  @override
  @JsonKey()
  @_StringListConverter()
  List<String> get blockers {
    if (_blockers is EqualUnmodifiableListView) return _blockers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockers);
  }

  @override
  String toString() {
    return 'B2bMergePreview(source: $source, target: $target, plan: $plan, sourceCustomer: $sourceCustomer, targetCustomer: $targetCustomer, canExecute: $canExecute, warnings: $warnings, blockers: $blockers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bMergePreviewImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.sourceCustomer, sourceCustomer) ||
                other.sourceCustomer == sourceCustomer) &&
            (identical(other.targetCustomer, targetCustomer) ||
                other.targetCustomer == targetCustomer) &&
            (identical(other.canExecute, canExecute) ||
                other.canExecute == canExecute) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            const DeepCollectionEquality().equals(other._blockers, _blockers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    source,
    target,
    plan,
    sourceCustomer,
    targetCustomer,
    canExecute,
    const DeepCollectionEquality().hash(_warnings),
    const DeepCollectionEquality().hash(_blockers),
  );

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bMergePreviewImplCopyWith<_$B2bMergePreviewImpl> get copyWith =>
      __$$B2bMergePreviewImplCopyWithImpl<_$B2bMergePreviewImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bMergePreviewImplToJson(this);
  }
}

abstract class _B2bMergePreview implements B2bMergePreview {
  const factory _B2bMergePreview({
    final B2bMergeParty source,
    final B2bMergeParty target,
    final B2bMergePlan plan,
    @JsonKey(name: 'source_customer')
    final B2bMergeCustomerSummary? sourceCustomer,
    @JsonKey(name: 'target_customer')
    final B2bMergeCustomerSummary? targetCustomer,
    @JsonKey(name: 'can_execute') @_BoolConverter() final bool canExecute,
    @_StringListConverter() final List<String> warnings,
    @_StringListConverter() final List<String> blockers,
  }) = _$B2bMergePreviewImpl;

  factory _B2bMergePreview.fromJson(Map<String, dynamic> json) =
      _$B2bMergePreviewImpl.fromJson;

  @override
  B2bMergeParty get source;
  @override
  B2bMergeParty get target;
  @override
  B2bMergePlan get plan;
  @override
  @JsonKey(name: 'source_customer')
  B2bMergeCustomerSummary? get sourceCustomer;
  @override
  @JsonKey(name: 'target_customer')
  B2bMergeCustomerSummary? get targetCustomer;
  @override
  @JsonKey(name: 'can_execute')
  @_BoolConverter()
  bool get canExecute;
  @override
  @_StringListConverter()
  List<String> get warnings;

  /// Server-written sentences explaining why the merge cannot run at all
  /// (not a permission issue). Non-empty implies `can_execute == false`.
  @override
  @_StringListConverter()
  List<String> get blockers;

  /// Create a copy of B2bMergePreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bMergePreviewImplCopyWith<_$B2bMergePreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bTodo _$B2bTodoFromJson(Map<String, dynamic> json) {
  return _B2bTodo.fromJson(json);
}

/// @nodoc
mixin _$B2bTodo {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  /// Serializes this B2bTodo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bTodo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bTodoCopyWith<B2bTodo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bTodoCopyWith<$Res> {
  factory $B2bTodoCopyWith(B2bTodo value, $Res Function(B2bTodo) then) =
      _$B2bTodoCopyWithImpl<$Res, B2bTodo>;
  @useResult
  $Res call({String name, String? description, String? date});
}

/// @nodoc
class _$B2bTodoCopyWithImpl<$Res, $Val extends B2bTodo>
    implements $B2bTodoCopyWith<$Res> {
  _$B2bTodoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bTodo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bTodoImplCopyWith<$Res> implements $B2bTodoCopyWith<$Res> {
  factory _$$B2bTodoImplCopyWith(
    _$B2bTodoImpl value,
    $Res Function(_$B2bTodoImpl) then,
  ) = __$$B2bTodoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? description, String? date});
}

/// @nodoc
class __$$B2bTodoImplCopyWithImpl<$Res>
    extends _$B2bTodoCopyWithImpl<$Res, _$B2bTodoImpl>
    implements _$$B2bTodoImplCopyWith<$Res> {
  __$$B2bTodoImplCopyWithImpl(
    _$B2bTodoImpl _value,
    $Res Function(_$B2bTodoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bTodo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _$B2bTodoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bTodoImpl implements _B2bTodo {
  const _$B2bTodoImpl({required this.name, this.description, this.date});

  factory _$B2bTodoImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bTodoImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  final String? date;

  @override
  String toString() {
    return 'B2bTodo(name: $name, description: $description, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bTodoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, date);

  /// Create a copy of B2bTodo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bTodoImplCopyWith<_$B2bTodoImpl> get copyWith =>
      __$$B2bTodoImplCopyWithImpl<_$B2bTodoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bTodoImplToJson(this);
  }
}

abstract class _B2bTodo implements B2bTodo {
  const factory _B2bTodo({
    required final String name,
    final String? description,
    final String? date,
  }) = _$B2bTodoImpl;

  factory _B2bTodo.fromJson(Map<String, dynamic> json) = _$B2bTodoImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  String? get date;

  /// Create a copy of B2bTodo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bTodoImplCopyWith<_$B2bTodoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bAccount _$B2bAccountFromJson(Map<String, dynamic> json) {
  return _B2bAccount.fromJson(json);
}

/// @nodoc
mixin _$B2bAccount {
  String get doctype => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;
  String? get owner => throw _privateConstructorUsedError;
  B2bContact get contact => throw _privateConstructorUsedError;
  String? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'predicted_next_order')
  String? get predictedNextOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_order_cycle_days')
  double? get avgOrderCycleDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_invoices')
  List<B2bRecentInvoice> get recentInvoices =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'open_todos')
  List<B2bTodo> get openTodos => throw _privateConstructorUsedError;

  /// Every door of the shop, once each: the linked Customer's branches
  /// (named shipping Addresses, with their own invoice totals and any matched
  /// Google Maps listing) first, then the Lead's Google Maps branches that
  /// are not delivery branches yet. Empty on an older server.
  List<B2bBranch> get branches => throw _privateConstructorUsedError;

  /// Totals for the invoices that match no branch; null when there are none.
  @JsonKey(name: 'unassigned_invoices')
  B2bBranchStats? get unassignedInvoices => throw _privateConstructorUsedError;

  /// The Lead whose Google Maps branches were folded into [branches] (the
  /// account itself for a Lead, the linked Lead for a Customer). Null when
  /// there is none or on an older server.
  @JsonKey(name: 'branch_lead')
  String? get branchLead => throw _privateConstructorUsedError;

  /// The rep's dated field diary for this account, newest touch first. The
  /// account screen renders it through the shared journey timeline, which
  /// also owns the live (re-fetched) copy — this is the load-time snapshot.
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes => throw _privateConstructorUsedError;

  /// Serializes this B2bAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bAccountCopyWith<B2bAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bAccountCopyWith<$Res> {
  factory $B2bAccountCopyWith(
    B2bAccount value,
    $Res Function(B2bAccount) then,
  ) = _$B2bAccountCopyWithImpl<$Res, B2bAccount>;
  @useResult
  $Res call({
    String doctype,
    String name,
    String title,
    String stage,
    String? owner,
    B2bContact contact,
    String? customer,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices') List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') List<B2bTodo> openTodos,
    List<B2bBranch> branches,
    @JsonKey(name: 'unassigned_invoices') B2bBranchStats? unassignedInvoices,
    @JsonKey(name: 'branch_lead') String? branchLead,
    @JsonKey(name: 'journey_notes') List<JourneyNote> journeyNotes,
  });

  $B2bContactCopyWith<$Res> get contact;
  $B2bBranchStatsCopyWith<$Res>? get unassignedInvoices;
}

/// @nodoc
class _$B2bAccountCopyWithImpl<$Res, $Val extends B2bAccount>
    implements $B2bAccountCopyWith<$Res> {
  _$B2bAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = null,
    Object? stage = null,
    Object? owner = freezed,
    Object? contact = null,
    Object? customer = freezed,
    Object? predictedNextOrder = freezed,
    Object? avgOrderCycleDays = freezed,
    Object? recentInvoices = null,
    Object? openTodos = null,
    Object? branches = null,
    Object? unassignedInvoices = freezed,
    Object? branchLead = freezed,
    Object? journeyNotes = null,
  }) {
    return _then(
      _value.copyWith(
            doctype: null == doctype
                ? _value.doctype
                : doctype // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as String,
            owner: freezed == owner
                ? _value.owner
                : owner // ignore: cast_nullable_to_non_nullable
                      as String?,
            contact: null == contact
                ? _value.contact
                : contact // ignore: cast_nullable_to_non_nullable
                      as B2bContact,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String?,
            predictedNextOrder: freezed == predictedNextOrder
                ? _value.predictedNextOrder
                : predictedNextOrder // ignore: cast_nullable_to_non_nullable
                      as String?,
            avgOrderCycleDays: freezed == avgOrderCycleDays
                ? _value.avgOrderCycleDays
                : avgOrderCycleDays // ignore: cast_nullable_to_non_nullable
                      as double?,
            recentInvoices: null == recentInvoices
                ? _value.recentInvoices
                : recentInvoices // ignore: cast_nullable_to_non_nullable
                      as List<B2bRecentInvoice>,
            openTodos: null == openTodos
                ? _value.openTodos
                : openTodos // ignore: cast_nullable_to_non_nullable
                      as List<B2bTodo>,
            branches: null == branches
                ? _value.branches
                : branches // ignore: cast_nullable_to_non_nullable
                      as List<B2bBranch>,
            unassignedInvoices: freezed == unassignedInvoices
                ? _value.unassignedInvoices
                : unassignedInvoices // ignore: cast_nullable_to_non_nullable
                      as B2bBranchStats?,
            branchLead: freezed == branchLead
                ? _value.branchLead
                : branchLead // ignore: cast_nullable_to_non_nullable
                      as String?,
            journeyNotes: null == journeyNotes
                ? _value.journeyNotes
                : journeyNotes // ignore: cast_nullable_to_non_nullable
                      as List<JourneyNote>,
          )
          as $Val,
    );
  }

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bContactCopyWith<$Res> get contact {
    return $B2bContactCopyWith<$Res>(_value.contact, (value) {
      return _then(_value.copyWith(contact: value) as $Val);
    });
  }

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $B2bBranchStatsCopyWith<$Res>? get unassignedInvoices {
    if (_value.unassignedInvoices == null) {
      return null;
    }

    return $B2bBranchStatsCopyWith<$Res>(_value.unassignedInvoices!, (value) {
      return _then(_value.copyWith(unassignedInvoices: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$B2bAccountImplCopyWith<$Res>
    implements $B2bAccountCopyWith<$Res> {
  factory _$$B2bAccountImplCopyWith(
    _$B2bAccountImpl value,
    $Res Function(_$B2bAccountImpl) then,
  ) = __$$B2bAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String doctype,
    String name,
    String title,
    String stage,
    String? owner,
    B2bContact contact,
    String? customer,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices') List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') List<B2bTodo> openTodos,
    List<B2bBranch> branches,
    @JsonKey(name: 'unassigned_invoices') B2bBranchStats? unassignedInvoices,
    @JsonKey(name: 'branch_lead') String? branchLead,
    @JsonKey(name: 'journey_notes') List<JourneyNote> journeyNotes,
  });

  @override
  $B2bContactCopyWith<$Res> get contact;
  @override
  $B2bBranchStatsCopyWith<$Res>? get unassignedInvoices;
}

/// @nodoc
class __$$B2bAccountImplCopyWithImpl<$Res>
    extends _$B2bAccountCopyWithImpl<$Res, _$B2bAccountImpl>
    implements _$$B2bAccountImplCopyWith<$Res> {
  __$$B2bAccountImplCopyWithImpl(
    _$B2bAccountImpl _value,
    $Res Function(_$B2bAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctype = null,
    Object? name = null,
    Object? title = null,
    Object? stage = null,
    Object? owner = freezed,
    Object? contact = null,
    Object? customer = freezed,
    Object? predictedNextOrder = freezed,
    Object? avgOrderCycleDays = freezed,
    Object? recentInvoices = null,
    Object? openTodos = null,
    Object? branches = null,
    Object? unassignedInvoices = freezed,
    Object? branchLead = freezed,
    Object? journeyNotes = null,
  }) {
    return _then(
      _$B2bAccountImpl(
        doctype: null == doctype
            ? _value.doctype
            : doctype // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String,
        owner: freezed == owner
            ? _value.owner
            : owner // ignore: cast_nullable_to_non_nullable
                  as String?,
        contact: null == contact
            ? _value.contact
            : contact // ignore: cast_nullable_to_non_nullable
                  as B2bContact,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String?,
        predictedNextOrder: freezed == predictedNextOrder
            ? _value.predictedNextOrder
            : predictedNextOrder // ignore: cast_nullable_to_non_nullable
                  as String?,
        avgOrderCycleDays: freezed == avgOrderCycleDays
            ? _value.avgOrderCycleDays
            : avgOrderCycleDays // ignore: cast_nullable_to_non_nullable
                  as double?,
        recentInvoices: null == recentInvoices
            ? _value._recentInvoices
            : recentInvoices // ignore: cast_nullable_to_non_nullable
                  as List<B2bRecentInvoice>,
        openTodos: null == openTodos
            ? _value._openTodos
            : openTodos // ignore: cast_nullable_to_non_nullable
                  as List<B2bTodo>,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<B2bBranch>,
        unassignedInvoices: freezed == unassignedInvoices
            ? _value.unassignedInvoices
            : unassignedInvoices // ignore: cast_nullable_to_non_nullable
                  as B2bBranchStats?,
        branchLead: freezed == branchLead
            ? _value.branchLead
            : branchLead // ignore: cast_nullable_to_non_nullable
                  as String?,
        journeyNotes: null == journeyNotes
            ? _value._journeyNotes
            : journeyNotes // ignore: cast_nullable_to_non_nullable
                  as List<JourneyNote>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bAccountImpl extends _B2bAccount {
  const _$B2bAccountImpl({
    required this.doctype,
    required this.name,
    required this.title,
    this.stage = 'Customer',
    this.owner,
    this.contact = const B2bContact(),
    this.customer,
    @JsonKey(name: 'predicted_next_order') this.predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') this.avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    final List<B2bRecentInvoice> recentInvoices = const <B2bRecentInvoice>[],
    @JsonKey(name: 'open_todos')
    final List<B2bTodo> openTodos = const <B2bTodo>[],
    final List<B2bBranch> branches = const <B2bBranch>[],
    @JsonKey(name: 'unassigned_invoices') this.unassignedInvoices,
    @JsonKey(name: 'branch_lead') this.branchLead,
    @JsonKey(name: 'journey_notes')
    final List<JourneyNote> journeyNotes = const <JourneyNote>[],
  }) : _recentInvoices = recentInvoices,
       _openTodos = openTodos,
       _branches = branches,
       _journeyNotes = journeyNotes,
       super._();

  factory _$B2bAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bAccountImplFromJson(json);

  @override
  final String doctype;
  @override
  final String name;
  @override
  final String title;
  @override
  @JsonKey()
  final String stage;
  @override
  final String? owner;
  @override
  @JsonKey()
  final B2bContact contact;
  @override
  final String? customer;
  @override
  @JsonKey(name: 'predicted_next_order')
  final String? predictedNextOrder;
  @override
  @JsonKey(name: 'avg_order_cycle_days')
  final double? avgOrderCycleDays;
  final List<B2bRecentInvoice> _recentInvoices;
  @override
  @JsonKey(name: 'recent_invoices')
  List<B2bRecentInvoice> get recentInvoices {
    if (_recentInvoices is EqualUnmodifiableListView) return _recentInvoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentInvoices);
  }

  final List<B2bTodo> _openTodos;
  @override
  @JsonKey(name: 'open_todos')
  List<B2bTodo> get openTodos {
    if (_openTodos is EqualUnmodifiableListView) return _openTodos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openTodos);
  }

  /// Every door of the shop, once each: the linked Customer's branches
  /// (named shipping Addresses, with their own invoice totals and any matched
  /// Google Maps listing) first, then the Lead's Google Maps branches that
  /// are not delivery branches yet. Empty on an older server.
  final List<B2bBranch> _branches;

  /// Every door of the shop, once each: the linked Customer's branches
  /// (named shipping Addresses, with their own invoice totals and any matched
  /// Google Maps listing) first, then the Lead's Google Maps branches that
  /// are not delivery branches yet. Empty on an older server.
  @override
  @JsonKey()
  List<B2bBranch> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  /// Totals for the invoices that match no branch; null when there are none.
  @override
  @JsonKey(name: 'unassigned_invoices')
  final B2bBranchStats? unassignedInvoices;

  /// The Lead whose Google Maps branches were folded into [branches] (the
  /// account itself for a Lead, the linked Lead for a Customer). Null when
  /// there is none or on an older server.
  @override
  @JsonKey(name: 'branch_lead')
  final String? branchLead;

  /// The rep's dated field diary for this account, newest touch first. The
  /// account screen renders it through the shared journey timeline, which
  /// also owns the live (re-fetched) copy — this is the load-time snapshot.
  final List<JourneyNote> _journeyNotes;

  /// The rep's dated field diary for this account, newest touch first. The
  /// account screen renders it through the shared journey timeline, which
  /// also owns the live (re-fetched) copy — this is the load-time snapshot.
  @override
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes {
    if (_journeyNotes is EqualUnmodifiableListView) return _journeyNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_journeyNotes);
  }

  @override
  String toString() {
    return 'B2bAccount(doctype: $doctype, name: $name, title: $title, stage: $stage, owner: $owner, contact: $contact, customer: $customer, predictedNextOrder: $predictedNextOrder, avgOrderCycleDays: $avgOrderCycleDays, recentInvoices: $recentInvoices, openTodos: $openTodos, branches: $branches, unassignedInvoices: $unassignedInvoices, branchLead: $branchLead, journeyNotes: $journeyNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bAccountImpl &&
            (identical(other.doctype, doctype) || other.doctype == doctype) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.predictedNextOrder, predictedNextOrder) ||
                other.predictedNextOrder == predictedNextOrder) &&
            (identical(other.avgOrderCycleDays, avgOrderCycleDays) ||
                other.avgOrderCycleDays == avgOrderCycleDays) &&
            const DeepCollectionEquality().equals(
              other._recentInvoices,
              _recentInvoices,
            ) &&
            const DeepCollectionEquality().equals(
              other._openTodos,
              _openTodos,
            ) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            (identical(other.unassignedInvoices, unassignedInvoices) ||
                other.unassignedInvoices == unassignedInvoices) &&
            (identical(other.branchLead, branchLead) ||
                other.branchLead == branchLead) &&
            const DeepCollectionEquality().equals(
              other._journeyNotes,
              _journeyNotes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    doctype,
    name,
    title,
    stage,
    owner,
    contact,
    customer,
    predictedNextOrder,
    avgOrderCycleDays,
    const DeepCollectionEquality().hash(_recentInvoices),
    const DeepCollectionEquality().hash(_openTodos),
    const DeepCollectionEquality().hash(_branches),
    unassignedInvoices,
    branchLead,
    const DeepCollectionEquality().hash(_journeyNotes),
  );

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bAccountImplCopyWith<_$B2bAccountImpl> get copyWith =>
      __$$B2bAccountImplCopyWithImpl<_$B2bAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bAccountImplToJson(this);
  }
}

abstract class _B2bAccount extends B2bAccount {
  const factory _B2bAccount({
    required final String doctype,
    required final String name,
    required final String title,
    final String stage,
    final String? owner,
    final B2bContact contact,
    final String? customer,
    @JsonKey(name: 'predicted_next_order') final String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') final double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    final List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') final List<B2bTodo> openTodos,
    final List<B2bBranch> branches,
    @JsonKey(name: 'unassigned_invoices')
    final B2bBranchStats? unassignedInvoices,
    @JsonKey(name: 'branch_lead') final String? branchLead,
    @JsonKey(name: 'journey_notes') final List<JourneyNote> journeyNotes,
  }) = _$B2bAccountImpl;
  const _B2bAccount._() : super._();

  factory _B2bAccount.fromJson(Map<String, dynamic> json) =
      _$B2bAccountImpl.fromJson;

  @override
  String get doctype;
  @override
  String get name;
  @override
  String get title;
  @override
  String get stage;
  @override
  String? get owner;
  @override
  B2bContact get contact;
  @override
  String? get customer;
  @override
  @JsonKey(name: 'predicted_next_order')
  String? get predictedNextOrder;
  @override
  @JsonKey(name: 'avg_order_cycle_days')
  double? get avgOrderCycleDays;
  @override
  @JsonKey(name: 'recent_invoices')
  List<B2bRecentInvoice> get recentInvoices;
  @override
  @JsonKey(name: 'open_todos')
  List<B2bTodo> get openTodos;

  /// Every door of the shop, once each: the linked Customer's branches
  /// (named shipping Addresses, with their own invoice totals and any matched
  /// Google Maps listing) first, then the Lead's Google Maps branches that
  /// are not delivery branches yet. Empty on an older server.
  @override
  List<B2bBranch> get branches;

  /// Totals for the invoices that match no branch; null when there are none.
  @override
  @JsonKey(name: 'unassigned_invoices')
  B2bBranchStats? get unassignedInvoices;

  /// The Lead whose Google Maps branches were folded into [branches] (the
  /// account itself for a Lead, the linked Lead for a Customer). Null when
  /// there is none or on an older server.
  @override
  @JsonKey(name: 'branch_lead')
  String? get branchLead;

  /// The rep's dated field diary for this account, newest touch first. The
  /// account screen renders it through the shared journey timeline, which
  /// also owns the live (re-fetched) copy — this is the load-time snapshot.
  @override
  @JsonKey(name: 'journey_notes')
  List<JourneyNote> get journeyNotes;

  /// Create a copy of B2bAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bAccountImplCopyWith<_$B2bAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowupItem _$FollowupItemFromJson(Map<String, dynamic> json) {
  return _FollowupItem.fromJson(json);
}

/// @nodoc
mixin _$FollowupItem {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_type')
  String? get referenceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_name')
  String? get referenceName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  /// Serializes this FollowupItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowupItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowupItemCopyWith<FollowupItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowupItemCopyWith<$Res> {
  factory $FollowupItemCopyWith(
    FollowupItem value,
    $Res Function(FollowupItem) then,
  ) = _$FollowupItemCopyWithImpl<$Res, FollowupItem>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'reference_type') String? referenceType,
    @JsonKey(name: 'reference_name') String? referenceName,
    String? description,
    String? date,
  });
}

/// @nodoc
class _$FollowupItemCopyWithImpl<$Res, $Val extends FollowupItem>
    implements $FollowupItemCopyWith<$Res> {
  _$FollowupItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowupItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? referenceType = freezed,
    Object? referenceName = freezed,
    Object? description = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceType: freezed == referenceType
                ? _value.referenceType
                : referenceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            referenceName: freezed == referenceName
                ? _value.referenceName
                : referenceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowupItemImplCopyWith<$Res>
    implements $FollowupItemCopyWith<$Res> {
  factory _$$FollowupItemImplCopyWith(
    _$FollowupItemImpl value,
    $Res Function(_$FollowupItemImpl) then,
  ) = __$$FollowupItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'reference_type') String? referenceType,
    @JsonKey(name: 'reference_name') String? referenceName,
    String? description,
    String? date,
  });
}

/// @nodoc
class __$$FollowupItemImplCopyWithImpl<$Res>
    extends _$FollowupItemCopyWithImpl<$Res, _$FollowupItemImpl>
    implements _$$FollowupItemImplCopyWith<$Res> {
  __$$FollowupItemImplCopyWithImpl(
    _$FollowupItemImpl _value,
    $Res Function(_$FollowupItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowupItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? referenceType = freezed,
    Object? referenceName = freezed,
    Object? description = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _$FollowupItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceType: freezed == referenceType
            ? _value.referenceType
            : referenceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        referenceName: freezed == referenceName
            ? _value.referenceName
            : referenceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowupItemImpl implements _FollowupItem {
  const _$FollowupItemImpl({
    required this.name,
    @JsonKey(name: 'reference_type') this.referenceType,
    @JsonKey(name: 'reference_name') this.referenceName,
    this.description,
    this.date,
  });

  factory _$FollowupItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowupItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  @override
  @JsonKey(name: 'reference_name')
  final String? referenceName;
  @override
  final String? description;
  @override
  final String? date;

  @override
  String toString() {
    return 'FollowupItem(name: $name, referenceType: $referenceType, referenceName: $referenceName, description: $description, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowupItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            (identical(other.referenceName, referenceName) ||
                other.referenceName == referenceName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    referenceType,
    referenceName,
    description,
    date,
  );

  /// Create a copy of FollowupItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowupItemImplCopyWith<_$FollowupItemImpl> get copyWith =>
      __$$FollowupItemImplCopyWithImpl<_$FollowupItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowupItemImplToJson(this);
  }
}

abstract class _FollowupItem implements FollowupItem {
  const factory _FollowupItem({
    required final String name,
    @JsonKey(name: 'reference_type') final String? referenceType,
    @JsonKey(name: 'reference_name') final String? referenceName,
    final String? description,
    final String? date,
  }) = _$FollowupItemImpl;

  factory _FollowupItem.fromJson(Map<String, dynamic> json) =
      _$FollowupItemImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'reference_type')
  String? get referenceType;
  @override
  @JsonKey(name: 'reference_name')
  String? get referenceName;
  @override
  String? get description;
  @override
  String? get date;

  /// Create a copy of FollowupItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowupItemImplCopyWith<_$FollowupItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReorderDueItem _$ReorderDueItemFromJson(Map<String, dynamic> json) {
  return _ReorderDueItem.fromJson(json);
}

/// @nodoc
mixin _$ReorderDueItem {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_order_date')
  String? get lastOrderDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_basket_value')
  double? get avgBasketValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'predicted_next_order')
  String? get predictedNextOrder => throw _privateConstructorUsedError;

  /// Serializes this ReorderDueItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReorderDueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReorderDueItemCopyWith<ReorderDueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReorderDueItemCopyWith<$Res> {
  factory $ReorderDueItemCopyWith(
    ReorderDueItem value,
    $Res Function(ReorderDueItem) then,
  ) = _$ReorderDueItemCopyWithImpl<$Res, ReorderDueItem>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'last_order_date') String? lastOrderDate,
    @JsonKey(name: 'avg_basket_value') double? avgBasketValue,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
  });
}

/// @nodoc
class _$ReorderDueItemCopyWithImpl<$Res, $Val extends ReorderDueItem>
    implements $ReorderDueItemCopyWith<$Res> {
  _$ReorderDueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReorderDueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? customerName = freezed,
    Object? lastOrderDate = freezed,
    Object? avgBasketValue = freezed,
    Object? predictedNextOrder = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastOrderDate: freezed == lastOrderDate
                ? _value.lastOrderDate
                : lastOrderDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            avgBasketValue: freezed == avgBasketValue
                ? _value.avgBasketValue
                : avgBasketValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            predictedNextOrder: freezed == predictedNextOrder
                ? _value.predictedNextOrder
                : predictedNextOrder // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReorderDueItemImplCopyWith<$Res>
    implements $ReorderDueItemCopyWith<$Res> {
  factory _$$ReorderDueItemImplCopyWith(
    _$ReorderDueItemImpl value,
    $Res Function(_$ReorderDueItemImpl) then,
  ) = __$$ReorderDueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'last_order_date') String? lastOrderDate,
    @JsonKey(name: 'avg_basket_value') double? avgBasketValue,
    @JsonKey(name: 'predicted_next_order') String? predictedNextOrder,
  });
}

/// @nodoc
class __$$ReorderDueItemImplCopyWithImpl<$Res>
    extends _$ReorderDueItemCopyWithImpl<$Res, _$ReorderDueItemImpl>
    implements _$$ReorderDueItemImplCopyWith<$Res> {
  __$$ReorderDueItemImplCopyWithImpl(
    _$ReorderDueItemImpl _value,
    $Res Function(_$ReorderDueItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReorderDueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? customerName = freezed,
    Object? lastOrderDate = freezed,
    Object? avgBasketValue = freezed,
    Object? predictedNextOrder = freezed,
  }) {
    return _then(
      _$ReorderDueItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastOrderDate: freezed == lastOrderDate
            ? _value.lastOrderDate
            : lastOrderDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        avgBasketValue: freezed == avgBasketValue
            ? _value.avgBasketValue
            : avgBasketValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        predictedNextOrder: freezed == predictedNextOrder
            ? _value.predictedNextOrder
            : predictedNextOrder // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReorderDueItemImpl implements _ReorderDueItem {
  const _$ReorderDueItemImpl({
    required this.name,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'last_order_date') this.lastOrderDate,
    @JsonKey(name: 'avg_basket_value') this.avgBasketValue,
    @JsonKey(name: 'predicted_next_order') this.predictedNextOrder,
  });

  factory _$ReorderDueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReorderDueItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'last_order_date')
  final String? lastOrderDate;
  @override
  @JsonKey(name: 'avg_basket_value')
  final double? avgBasketValue;
  @override
  @JsonKey(name: 'predicted_next_order')
  final String? predictedNextOrder;

  @override
  String toString() {
    return 'ReorderDueItem(name: $name, customerName: $customerName, lastOrderDate: $lastOrderDate, avgBasketValue: $avgBasketValue, predictedNextOrder: $predictedNextOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReorderDueItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate) &&
            (identical(other.avgBasketValue, avgBasketValue) ||
                other.avgBasketValue == avgBasketValue) &&
            (identical(other.predictedNextOrder, predictedNextOrder) ||
                other.predictedNextOrder == predictedNextOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    customerName,
    lastOrderDate,
    avgBasketValue,
    predictedNextOrder,
  );

  /// Create a copy of ReorderDueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReorderDueItemImplCopyWith<_$ReorderDueItemImpl> get copyWith =>
      __$$ReorderDueItemImplCopyWithImpl<_$ReorderDueItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReorderDueItemImplToJson(this);
  }
}

abstract class _ReorderDueItem implements ReorderDueItem {
  const factory _ReorderDueItem({
    required final String name,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'last_order_date') final String? lastOrderDate,
    @JsonKey(name: 'avg_basket_value') final double? avgBasketValue,
    @JsonKey(name: 'predicted_next_order') final String? predictedNextOrder,
  }) = _$ReorderDueItemImpl;

  factory _ReorderDueItem.fromJson(Map<String, dynamic> json) =
      _$ReorderDueItemImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'last_order_date')
  String? get lastOrderDate;
  @override
  @JsonKey(name: 'avg_basket_value')
  double? get avgBasketValue;
  @override
  @JsonKey(name: 'predicted_next_order')
  String? get predictedNextOrder;

  /// Create a copy of ReorderDueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReorderDueItemImplCopyWith<_$ReorderDueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

B2bFollowups _$B2bFollowupsFromJson(Map<String, dynamic> json) {
  return _B2bFollowups.fromJson(json);
}

/// @nodoc
mixin _$B2bFollowups {
  List<FollowupItem> get todos => throw _privateConstructorUsedError;
  @JsonKey(name: 'reorder_due')
  List<ReorderDueItem> get reorderDue => throw _privateConstructorUsedError;

  /// Serializes this B2bFollowups to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of B2bFollowups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $B2bFollowupsCopyWith<B2bFollowups> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $B2bFollowupsCopyWith<$Res> {
  factory $B2bFollowupsCopyWith(
    B2bFollowups value,
    $Res Function(B2bFollowups) then,
  ) = _$B2bFollowupsCopyWithImpl<$Res, B2bFollowups>;
  @useResult
  $Res call({
    List<FollowupItem> todos,
    @JsonKey(name: 'reorder_due') List<ReorderDueItem> reorderDue,
  });
}

/// @nodoc
class _$B2bFollowupsCopyWithImpl<$Res, $Val extends B2bFollowups>
    implements $B2bFollowupsCopyWith<$Res> {
  _$B2bFollowupsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of B2bFollowups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? todos = null, Object? reorderDue = null}) {
    return _then(
      _value.copyWith(
            todos: null == todos
                ? _value.todos
                : todos // ignore: cast_nullable_to_non_nullable
                      as List<FollowupItem>,
            reorderDue: null == reorderDue
                ? _value.reorderDue
                : reorderDue // ignore: cast_nullable_to_non_nullable
                      as List<ReorderDueItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$B2bFollowupsImplCopyWith<$Res>
    implements $B2bFollowupsCopyWith<$Res> {
  factory _$$B2bFollowupsImplCopyWith(
    _$B2bFollowupsImpl value,
    $Res Function(_$B2bFollowupsImpl) then,
  ) = __$$B2bFollowupsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FollowupItem> todos,
    @JsonKey(name: 'reorder_due') List<ReorderDueItem> reorderDue,
  });
}

/// @nodoc
class __$$B2bFollowupsImplCopyWithImpl<$Res>
    extends _$B2bFollowupsCopyWithImpl<$Res, _$B2bFollowupsImpl>
    implements _$$B2bFollowupsImplCopyWith<$Res> {
  __$$B2bFollowupsImplCopyWithImpl(
    _$B2bFollowupsImpl _value,
    $Res Function(_$B2bFollowupsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of B2bFollowups
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? todos = null, Object? reorderDue = null}) {
    return _then(
      _$B2bFollowupsImpl(
        todos: null == todos
            ? _value._todos
            : todos // ignore: cast_nullable_to_non_nullable
                  as List<FollowupItem>,
        reorderDue: null == reorderDue
            ? _value._reorderDue
            : reorderDue // ignore: cast_nullable_to_non_nullable
                  as List<ReorderDueItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bFollowupsImpl implements _B2bFollowups {
  const _$B2bFollowupsImpl({
    final List<FollowupItem> todos = const <FollowupItem>[],
    @JsonKey(name: 'reorder_due')
    final List<ReorderDueItem> reorderDue = const <ReorderDueItem>[],
  }) : _todos = todos,
       _reorderDue = reorderDue;

  factory _$B2bFollowupsImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bFollowupsImplFromJson(json);

  final List<FollowupItem> _todos;
  @override
  @JsonKey()
  List<FollowupItem> get todos {
    if (_todos is EqualUnmodifiableListView) return _todos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todos);
  }

  final List<ReorderDueItem> _reorderDue;
  @override
  @JsonKey(name: 'reorder_due')
  List<ReorderDueItem> get reorderDue {
    if (_reorderDue is EqualUnmodifiableListView) return _reorderDue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reorderDue);
  }

  @override
  String toString() {
    return 'B2bFollowups(todos: $todos, reorderDue: $reorderDue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bFollowupsImpl &&
            const DeepCollectionEquality().equals(other._todos, _todos) &&
            const DeepCollectionEquality().equals(
              other._reorderDue,
              _reorderDue,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_todos),
    const DeepCollectionEquality().hash(_reorderDue),
  );

  /// Create a copy of B2bFollowups
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$B2bFollowupsImplCopyWith<_$B2bFollowupsImpl> get copyWith =>
      __$$B2bFollowupsImplCopyWithImpl<_$B2bFollowupsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$B2bFollowupsImplToJson(this);
  }
}

abstract class _B2bFollowups implements B2bFollowups {
  const factory _B2bFollowups({
    final List<FollowupItem> todos,
    @JsonKey(name: 'reorder_due') final List<ReorderDueItem> reorderDue,
  }) = _$B2bFollowupsImpl;

  factory _B2bFollowups.fromJson(Map<String, dynamic> json) =
      _$B2bFollowupsImpl.fromJson;

  @override
  List<FollowupItem> get todos;
  @override
  @JsonKey(name: 'reorder_due')
  List<ReorderDueItem> get reorderDue;

  /// Create a copy of B2bFollowups
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bFollowupsImplCopyWith<_$B2bFollowupsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderBinding _$OrderBindingFromJson(Map<String, dynamic> json) {
  return _OrderBinding.fromJson(json);
}

/// @nodoc
mixin _$OrderBinding {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_purpose')
  String get orderPurpose => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_list')
  String? get priceList => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_book')
  Map<String, dynamic> get addressBook => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_shipping_address_selection')
  bool get requiresShippingAddressSelection =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address_name')
  String? get shippingAddressName => throw _privateConstructorUsedError;

  /// Serializes this OrderBinding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderBindingCopyWith<OrderBinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderBindingCopyWith<$Res> {
  factory $OrderBindingCopyWith(
    OrderBinding value,
    $Res Function(OrderBinding) then,
  ) = _$OrderBindingCopyWithImpl<$Res, OrderBinding>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'order_purpose') String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
    @JsonKey(name: 'address_book') Map<String, dynamic> addressBook,
    @JsonKey(name: 'requires_shipping_address_selection')
    bool requiresShippingAddressSelection,
    @JsonKey(name: 'shipping_address_name') String? shippingAddressName,
  });
}

/// @nodoc
class _$OrderBindingCopyWithImpl<$Res, $Val extends OrderBinding>
    implements $OrderBindingCopyWith<$Res> {
  _$OrderBindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = freezed,
    Object? orderPurpose = null,
    Object? priceList = freezed,
    Object? addressBook = null,
    Object? requiresShippingAddressSelection = null,
    Object? shippingAddressName = freezed,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            orderPurpose: null == orderPurpose
                ? _value.orderPurpose
                : orderPurpose // ignore: cast_nullable_to_non_nullable
                      as String,
            priceList: freezed == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
                      as String?,
            addressBook: null == addressBook
                ? _value.addressBook
                : addressBook // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            requiresShippingAddressSelection:
                null == requiresShippingAddressSelection
                ? _value.requiresShippingAddressSelection
                : requiresShippingAddressSelection // ignore: cast_nullable_to_non_nullable
                      as bool,
            shippingAddressName: freezed == shippingAddressName
                ? _value.shippingAddressName
                : shippingAddressName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderBindingImplCopyWith<$Res>
    implements $OrderBindingCopyWith<$Res> {
  factory _$$OrderBindingImplCopyWith(
    _$OrderBindingImpl value,
    $Res Function(_$OrderBindingImpl) then,
  ) = __$$OrderBindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'order_purpose') String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
    @JsonKey(name: 'address_book') Map<String, dynamic> addressBook,
    @JsonKey(name: 'requires_shipping_address_selection')
    bool requiresShippingAddressSelection,
    @JsonKey(name: 'shipping_address_name') String? shippingAddressName,
  });
}

/// @nodoc
class __$$OrderBindingImplCopyWithImpl<$Res>
    extends _$OrderBindingCopyWithImpl<$Res, _$OrderBindingImpl>
    implements _$$OrderBindingImplCopyWith<$Res> {
  __$$OrderBindingImplCopyWithImpl(
    _$OrderBindingImpl _value,
    $Res Function(_$OrderBindingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = freezed,
    Object? orderPurpose = null,
    Object? priceList = freezed,
    Object? addressBook = null,
    Object? requiresShippingAddressSelection = null,
    Object? shippingAddressName = freezed,
  }) {
    return _then(
      _$OrderBindingImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        orderPurpose: null == orderPurpose
            ? _value.orderPurpose
            : orderPurpose // ignore: cast_nullable_to_non_nullable
                  as String,
        priceList: freezed == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
                  as String?,
        addressBook: null == addressBook
            ? _value._addressBook
            : addressBook // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        requiresShippingAddressSelection:
            null == requiresShippingAddressSelection
            ? _value.requiresShippingAddressSelection
            : requiresShippingAddressSelection // ignore: cast_nullable_to_non_nullable
                  as bool,
        shippingAddressName: freezed == shippingAddressName
            ? _value.shippingAddressName
            : shippingAddressName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderBindingImpl implements _OrderBinding {
  const _$OrderBindingImpl({
    required this.customer,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'order_purpose') required this.orderPurpose,
    @JsonKey(name: 'price_list') this.priceList,
    @JsonKey(name: 'address_book')
    final Map<String, dynamic> addressBook = const <String, dynamic>{},
    @JsonKey(name: 'requires_shipping_address_selection')
    this.requiresShippingAddressSelection = false,
    @JsonKey(name: 'shipping_address_name') this.shippingAddressName,
  }) : _addressBook = addressBook;

  factory _$OrderBindingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderBindingImplFromJson(json);

  @override
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'order_purpose')
  final String orderPurpose;
  @override
  @JsonKey(name: 'price_list')
  final String? priceList;
  final Map<String, dynamic> _addressBook;
  @override
  @JsonKey(name: 'address_book')
  Map<String, dynamic> get addressBook {
    if (_addressBook is EqualUnmodifiableMapView) return _addressBook;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_addressBook);
  }

  @override
  @JsonKey(name: 'requires_shipping_address_selection')
  final bool requiresShippingAddressSelection;
  @override
  @JsonKey(name: 'shipping_address_name')
  final String? shippingAddressName;

  @override
  String toString() {
    return 'OrderBinding(customer: $customer, customerName: $customerName, orderPurpose: $orderPurpose, priceList: $priceList, addressBook: $addressBook, requiresShippingAddressSelection: $requiresShippingAddressSelection, shippingAddressName: $shippingAddressName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderBindingImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.orderPurpose, orderPurpose) ||
                other.orderPurpose == orderPurpose) &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList) &&
            const DeepCollectionEquality().equals(
              other._addressBook,
              _addressBook,
            ) &&
            (identical(
                  other.requiresShippingAddressSelection,
                  requiresShippingAddressSelection,
                ) ||
                other.requiresShippingAddressSelection ==
                    requiresShippingAddressSelection) &&
            (identical(other.shippingAddressName, shippingAddressName) ||
                other.shippingAddressName == shippingAddressName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    orderPurpose,
    priceList,
    const DeepCollectionEquality().hash(_addressBook),
    requiresShippingAddressSelection,
    shippingAddressName,
  );

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderBindingImplCopyWith<_$OrderBindingImpl> get copyWith =>
      __$$OrderBindingImplCopyWithImpl<_$OrderBindingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderBindingImplToJson(this);
  }
}

abstract class _OrderBinding implements OrderBinding {
  const factory _OrderBinding({
    required final String customer,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'order_purpose') required final String orderPurpose,
    @JsonKey(name: 'price_list') final String? priceList,
    @JsonKey(name: 'address_book') final Map<String, dynamic> addressBook,
    @JsonKey(name: 'requires_shipping_address_selection')
    final bool requiresShippingAddressSelection,
    @JsonKey(name: 'shipping_address_name') final String? shippingAddressName,
  }) = _$OrderBindingImpl;

  factory _OrderBinding.fromJson(Map<String, dynamic> json) =
      _$OrderBindingImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'order_purpose')
  String get orderPurpose;
  @override
  @JsonKey(name: 'price_list')
  String? get priceList;
  @override
  @JsonKey(name: 'address_book')
  Map<String, dynamic> get addressBook;
  @override
  @JsonKey(name: 'requires_shipping_address_selection')
  bool get requiresShippingAddressSelection;
  @override
  @JsonKey(name: 'shipping_address_name')
  String? get shippingAddressName;

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderBindingImplCopyWith<_$OrderBindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

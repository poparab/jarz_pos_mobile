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
  String? get lastActivity => throw _privateConstructorUsedError;

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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bCardImpl implements _B2bCard {
  const _$B2bCardImpl({
    required this.doctype,
    required this.name,
    required this.title,
    required this.stage,
    this.owner,
    @JsonKey(name: 'lead_score') this.leadScore,
    this.customer,
    @JsonKey(name: 'last_activity') this.lastActivity,
  });

  factory _$B2bCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bCardImplFromJson(json);

  @override
  final String doctype;
  @override
  final String name;
  @override
  final String title;
  @override
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

  @override
  String toString() {
    return 'B2bCard(doctype: $doctype, name: $name, title: $title, stage: $stage, owner: $owner, leadScore: $leadScore, customer: $customer, lastActivity: $lastActivity)';
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
                other.lastActivity == lastActivity));
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

abstract class _B2bCard implements B2bCard {
  const factory _B2bCard({
    required final String doctype,
    required final String name,
    required final String title,
    required final String stage,
    final String? owner,
    @JsonKey(name: 'lead_score') final int? leadScore,
    final String? customer,
    @JsonKey(name: 'last_activity') final String? lastActivity,
  }) = _$B2bCardImpl;

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
  String? get lastActivity;

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
  @JsonKey(name: 'posting_date')
  String? get postingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'grand_total')
  double? get grandTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_order_purpose')
  String? get orderPurpose => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total') double? grandTotal,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    String? status,
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
    Object? postingDate = freezed,
    Object? grandTotal = freezed,
    Object? orderPurpose = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            postingDate: freezed == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            grandTotal: freezed == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double?,
            orderPurpose: freezed == orderPurpose
                ? _value.orderPurpose
                : orderPurpose // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'posting_date') String? postingDate,
    @JsonKey(name: 'grand_total') double? grandTotal,
    @JsonKey(name: 'custom_order_purpose') String? orderPurpose,
    String? status,
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
    Object? postingDate = freezed,
    Object? grandTotal = freezed,
    Object? orderPurpose = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$B2bRecentInvoiceImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        postingDate: freezed == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        grandTotal: freezed == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double?,
        orderPurpose: freezed == orderPurpose
            ? _value.orderPurpose
            : orderPurpose // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bRecentInvoiceImpl implements _B2bRecentInvoice {
  const _$B2bRecentInvoiceImpl({
    required this.name,
    @JsonKey(name: 'posting_date') this.postingDate,
    @JsonKey(name: 'grand_total') this.grandTotal,
    @JsonKey(name: 'custom_order_purpose') this.orderPurpose,
    this.status,
  });

  factory _$B2bRecentInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bRecentInvoiceImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'posting_date')
  final String? postingDate;
  @override
  @JsonKey(name: 'grand_total')
  final double? grandTotal;
  @override
  @JsonKey(name: 'custom_order_purpose')
  final String? orderPurpose;
  @override
  final String? status;

  @override
  String toString() {
    return 'B2bRecentInvoice(name: $name, postingDate: $postingDate, grandTotal: $grandTotal, orderPurpose: $orderPurpose, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$B2bRecentInvoiceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.orderPurpose, orderPurpose) ||
                other.orderPurpose == orderPurpose) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    postingDate,
    grandTotal,
    orderPurpose,
    status,
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

abstract class _B2bRecentInvoice implements B2bRecentInvoice {
  const factory _B2bRecentInvoice({
    required final String name,
    @JsonKey(name: 'posting_date') final String? postingDate,
    @JsonKey(name: 'grand_total') final double? grandTotal,
    @JsonKey(name: 'custom_order_purpose') final String? orderPurpose,
    final String? status,
  }) = _$B2bRecentInvoiceImpl;

  factory _B2bRecentInvoice.fromJson(Map<String, dynamic> json) =
      _$B2bRecentInvoiceImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'posting_date')
  String? get postingDate;
  @override
  @JsonKey(name: 'grand_total')
  double? get grandTotal;
  @override
  @JsonKey(name: 'custom_order_purpose')
  String? get orderPurpose;
  @override
  String? get status;

  /// Create a copy of B2bRecentInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$B2bRecentInvoiceImplCopyWith<_$B2bRecentInvoiceImpl> get copyWith =>
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
  });

  $B2bContactCopyWith<$Res> get contact;
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
  });

  @override
  $B2bContactCopyWith<$Res> get contact;
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$B2bAccountImpl implements _B2bAccount {
  const _$B2bAccountImpl({
    required this.doctype,
    required this.name,
    required this.title,
    required this.stage,
    this.owner,
    this.contact = const B2bContact(),
    this.customer,
    @JsonKey(name: 'predicted_next_order') this.predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') this.avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    final List<B2bRecentInvoice> recentInvoices = const <B2bRecentInvoice>[],
    @JsonKey(name: 'open_todos')
    final List<B2bTodo> openTodos = const <B2bTodo>[],
  }) : _recentInvoices = recentInvoices,
       _openTodos = openTodos;

  factory _$B2bAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$B2bAccountImplFromJson(json);

  @override
  final String doctype;
  @override
  final String name;
  @override
  final String title;
  @override
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

  @override
  String toString() {
    return 'B2bAccount(doctype: $doctype, name: $name, title: $title, stage: $stage, owner: $owner, contact: $contact, customer: $customer, predictedNextOrder: $predictedNextOrder, avgOrderCycleDays: $avgOrderCycleDays, recentInvoices: $recentInvoices, openTodos: $openTodos)';
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

abstract class _B2bAccount implements B2bAccount {
  const factory _B2bAccount({
    required final String doctype,
    required final String name,
    required final String title,
    required final String stage,
    final String? owner,
    final B2bContact contact,
    final String? customer,
    @JsonKey(name: 'predicted_next_order') final String? predictedNextOrder,
    @JsonKey(name: 'avg_order_cycle_days') final double? avgOrderCycleDays,
    @JsonKey(name: 'recent_invoices')
    final List<B2bRecentInvoice> recentInvoices,
    @JsonKey(name: 'open_todos') final List<B2bTodo> openTodos,
  }) = _$B2bAccountImpl;

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
  @JsonKey(name: 'order_purpose')
  String get orderPurpose => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_list')
  String? get priceList => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'order_purpose') String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
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
    Object? orderPurpose = null,
    Object? priceList = freezed,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            orderPurpose: null == orderPurpose
                ? _value.orderPurpose
                : orderPurpose // ignore: cast_nullable_to_non_nullable
                      as String,
            priceList: freezed == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'order_purpose') String orderPurpose,
    @JsonKey(name: 'price_list') String? priceList,
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
    Object? orderPurpose = null,
    Object? priceList = freezed,
  }) {
    return _then(
      _$OrderBindingImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        orderPurpose: null == orderPurpose
            ? _value.orderPurpose
            : orderPurpose // ignore: cast_nullable_to_non_nullable
                  as String,
        priceList: freezed == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
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
    @JsonKey(name: 'order_purpose') required this.orderPurpose,
    @JsonKey(name: 'price_list') this.priceList,
  });

  factory _$OrderBindingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderBindingImplFromJson(json);

  @override
  final String customer;
  @override
  @JsonKey(name: 'order_purpose')
  final String orderPurpose;
  @override
  @JsonKey(name: 'price_list')
  final String? priceList;

  @override
  String toString() {
    return 'OrderBinding(customer: $customer, orderPurpose: $orderPurpose, priceList: $priceList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderBindingImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.orderPurpose, orderPurpose) ||
                other.orderPurpose == orderPurpose) &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customer, orderPurpose, priceList);

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
    @JsonKey(name: 'order_purpose') required final String orderPurpose,
    @JsonKey(name: 'price_list') final String? priceList,
  }) = _$OrderBindingImpl;

  factory _OrderBinding.fromJson(Map<String, dynamic> json) =
      _$OrderBindingImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'order_purpose')
  String get orderPurpose;
  @override
  @JsonKey(name: 'price_list')
  String? get priceList;

  /// Create a copy of OrderBinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderBindingImplCopyWith<_$OrderBindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

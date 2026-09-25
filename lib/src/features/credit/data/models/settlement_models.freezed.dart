// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SettlementTerms _$SettlementTermsFromJson(Map<String, dynamic> json) {
  return _SettlementTerms.fromJson(json);
}

/// @nodoc
mixin _$SettlementTerms {
  @JsonKey(fromJson: settlementString)
  String get customer => throw _privateConstructorUsedError;

  /// Absent reads as enabled: the record exists to send reminders.
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get cycle => throw _privateConstructorUsedError;

  /// Comma list of `Mon..Sun`. A JSON list is accepted too.
  @JsonKey(fromJson: settlementCsv)
  String get weekdays => throw _privateConstructorUsedError;
  @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
  int get weekInterval => throw _privateConstructorUsedError;

  /// Comma list of `1..31` and/or `last`. A JSON list is accepted too.
  @JsonKey(name: 'month_days', fromJson: settlementCsv)
  String get monthDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
  int? get intervalDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'anchor_date', fromJson: settlementString)
  String get anchorDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
  int? get remindDaysBefore => throw _privateConstructorUsedError;
  @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
  int? get overdueRepeatDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  String get responsibleUser => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get notes => throw _privateConstructorUsedError;

  /// False when the server answered with an empty template for a customer
  /// that has no record yet.
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  bool get exists => throw _privateConstructorUsedError;

  /// Serializes this SettlementTerms to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettlementTerms
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementTermsCopyWith<SettlementTerms> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementTermsCopyWith<$Res> {
  factory $SettlementTermsCopyWith(
    SettlementTerms value,
    $Res Function(SettlementTerms) then,
  ) = _$SettlementTermsCopyWithImpl<$Res, SettlementTerms>;
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(fromJson: settlementBoolDefaultTrue) bool enabled,
    @JsonKey(fromJson: settlementString) String cycle,
    @JsonKey(fromJson: settlementCsv) String weekdays,
    @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
    int weekInterval,
    @JsonKey(name: 'month_days', fromJson: settlementCsv) String monthDays,
    @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
    int? intervalDays,
    @JsonKey(name: 'anchor_date', fromJson: settlementString) String anchorDate,
    @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
    int? remindDaysBefore,
    @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
    int? overdueRepeatDays,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    String responsibleUser,
    @JsonKey(fromJson: settlementString) String notes,
    @JsonKey(fromJson: settlementBoolDefaultTrue) bool exists,
  });
}

/// @nodoc
class _$SettlementTermsCopyWithImpl<$Res, $Val extends SettlementTerms>
    implements $SettlementTermsCopyWith<$Res> {
  _$SettlementTermsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementTerms
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? enabled = null,
    Object? cycle = null,
    Object? weekdays = null,
    Object? weekInterval = null,
    Object? monthDays = null,
    Object? intervalDays = freezed,
    Object? anchorDate = null,
    Object? remindDaysBefore = freezed,
    Object? overdueRepeatDays = freezed,
    Object? responsibleUser = null,
    Object? notes = null,
    Object? exists = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            cycle: null == cycle
                ? _value.cycle
                : cycle // ignore: cast_nullable_to_non_nullable
                      as String,
            weekdays: null == weekdays
                ? _value.weekdays
                : weekdays // ignore: cast_nullable_to_non_nullable
                      as String,
            weekInterval: null == weekInterval
                ? _value.weekInterval
                : weekInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            monthDays: null == monthDays
                ? _value.monthDays
                : monthDays // ignore: cast_nullable_to_non_nullable
                      as String,
            intervalDays: freezed == intervalDays
                ? _value.intervalDays
                : intervalDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            anchorDate: null == anchorDate
                ? _value.anchorDate
                : anchorDate // ignore: cast_nullable_to_non_nullable
                      as String,
            remindDaysBefore: freezed == remindDaysBefore
                ? _value.remindDaysBefore
                : remindDaysBefore // ignore: cast_nullable_to_non_nullable
                      as int?,
            overdueRepeatDays: freezed == overdueRepeatDays
                ? _value.overdueRepeatDays
                : overdueRepeatDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            responsibleUser: null == responsibleUser
                ? _value.responsibleUser
                : responsibleUser // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            exists: null == exists
                ? _value.exists
                : exists // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettlementTermsImplCopyWith<$Res>
    implements $SettlementTermsCopyWith<$Res> {
  factory _$$SettlementTermsImplCopyWith(
    _$SettlementTermsImpl value,
    $Res Function(_$SettlementTermsImpl) then,
  ) = __$$SettlementTermsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(fromJson: settlementBoolDefaultTrue) bool enabled,
    @JsonKey(fromJson: settlementString) String cycle,
    @JsonKey(fromJson: settlementCsv) String weekdays,
    @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
    int weekInterval,
    @JsonKey(name: 'month_days', fromJson: settlementCsv) String monthDays,
    @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
    int? intervalDays,
    @JsonKey(name: 'anchor_date', fromJson: settlementString) String anchorDate,
    @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
    int? remindDaysBefore,
    @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
    int? overdueRepeatDays,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    String responsibleUser,
    @JsonKey(fromJson: settlementString) String notes,
    @JsonKey(fromJson: settlementBoolDefaultTrue) bool exists,
  });
}

/// @nodoc
class __$$SettlementTermsImplCopyWithImpl<$Res>
    extends _$SettlementTermsCopyWithImpl<$Res, _$SettlementTermsImpl>
    implements _$$SettlementTermsImplCopyWith<$Res> {
  __$$SettlementTermsImplCopyWithImpl(
    _$SettlementTermsImpl _value,
    $Res Function(_$SettlementTermsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettlementTerms
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? enabled = null,
    Object? cycle = null,
    Object? weekdays = null,
    Object? weekInterval = null,
    Object? monthDays = null,
    Object? intervalDays = freezed,
    Object? anchorDate = null,
    Object? remindDaysBefore = freezed,
    Object? overdueRepeatDays = freezed,
    Object? responsibleUser = null,
    Object? notes = null,
    Object? exists = null,
  }) {
    return _then(
      _$SettlementTermsImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        cycle: null == cycle
            ? _value.cycle
            : cycle // ignore: cast_nullable_to_non_nullable
                  as String,
        weekdays: null == weekdays
            ? _value.weekdays
            : weekdays // ignore: cast_nullable_to_non_nullable
                  as String,
        weekInterval: null == weekInterval
            ? _value.weekInterval
            : weekInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        monthDays: null == monthDays
            ? _value.monthDays
            : monthDays // ignore: cast_nullable_to_non_nullable
                  as String,
        intervalDays: freezed == intervalDays
            ? _value.intervalDays
            : intervalDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        anchorDate: null == anchorDate
            ? _value.anchorDate
            : anchorDate // ignore: cast_nullable_to_non_nullable
                  as String,
        remindDaysBefore: freezed == remindDaysBefore
            ? _value.remindDaysBefore
            : remindDaysBefore // ignore: cast_nullable_to_non_nullable
                  as int?,
        overdueRepeatDays: freezed == overdueRepeatDays
            ? _value.overdueRepeatDays
            : overdueRepeatDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        responsibleUser: null == responsibleUser
            ? _value.responsibleUser
            : responsibleUser // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        exists: null == exists
            ? _value.exists
            : exists // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementTermsImpl extends _SettlementTerms {
  const _$SettlementTermsImpl({
    @JsonKey(fromJson: settlementString) this.customer = '',
    @JsonKey(fromJson: settlementBoolDefaultTrue) this.enabled = true,
    @JsonKey(fromJson: settlementString) this.cycle = '',
    @JsonKey(fromJson: settlementCsv) this.weekdays = '',
    @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
    this.weekInterval = 1,
    @JsonKey(name: 'month_days', fromJson: settlementCsv) this.monthDays = '',
    @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
    this.intervalDays,
    @JsonKey(name: 'anchor_date', fromJson: settlementString)
    this.anchorDate = '',
    @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
    this.remindDaysBefore,
    @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
    this.overdueRepeatDays,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    this.responsibleUser = '',
    @JsonKey(fromJson: settlementString) this.notes = '',
    @JsonKey(fromJson: settlementBoolDefaultTrue) this.exists = true,
  }) : super._();

  factory _$SettlementTermsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementTermsImplFromJson(json);

  @override
  @JsonKey(fromJson: settlementString)
  final String customer;

  /// Absent reads as enabled: the record exists to send reminders.
  @override
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  final bool enabled;
  @override
  @JsonKey(fromJson: settlementString)
  final String cycle;

  /// Comma list of `Mon..Sun`. A JSON list is accepted too.
  @override
  @JsonKey(fromJson: settlementCsv)
  final String weekdays;
  @override
  @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
  final int weekInterval;

  /// Comma list of `1..31` and/or `last`. A JSON list is accepted too.
  @override
  @JsonKey(name: 'month_days', fromJson: settlementCsv)
  final String monthDays;
  @override
  @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
  final int? intervalDays;
  @override
  @JsonKey(name: 'anchor_date', fromJson: settlementString)
  final String anchorDate;
  @override
  @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
  final int? remindDaysBefore;
  @override
  @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
  final int? overdueRepeatDays;
  @override
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  final String responsibleUser;
  @override
  @JsonKey(fromJson: settlementString)
  final String notes;

  /// False when the server answered with an empty template for a customer
  /// that has no record yet.
  @override
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  final bool exists;

  @override
  String toString() {
    return 'SettlementTerms(customer: $customer, enabled: $enabled, cycle: $cycle, weekdays: $weekdays, weekInterval: $weekInterval, monthDays: $monthDays, intervalDays: $intervalDays, anchorDate: $anchorDate, remindDaysBefore: $remindDaysBefore, overdueRepeatDays: $overdueRepeatDays, responsibleUser: $responsibleUser, notes: $notes, exists: $exists)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementTermsImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.cycle, cycle) || other.cycle == cycle) &&
            (identical(other.weekdays, weekdays) ||
                other.weekdays == weekdays) &&
            (identical(other.weekInterval, weekInterval) ||
                other.weekInterval == weekInterval) &&
            (identical(other.monthDays, monthDays) ||
                other.monthDays == monthDays) &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.anchorDate, anchorDate) ||
                other.anchorDate == anchorDate) &&
            (identical(other.remindDaysBefore, remindDaysBefore) ||
                other.remindDaysBefore == remindDaysBefore) &&
            (identical(other.overdueRepeatDays, overdueRepeatDays) ||
                other.overdueRepeatDays == overdueRepeatDays) &&
            (identical(other.responsibleUser, responsibleUser) ||
                other.responsibleUser == responsibleUser) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.exists, exists) || other.exists == exists));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    enabled,
    cycle,
    weekdays,
    weekInterval,
    monthDays,
    intervalDays,
    anchorDate,
    remindDaysBefore,
    overdueRepeatDays,
    responsibleUser,
    notes,
    exists,
  );

  /// Create a copy of SettlementTerms
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementTermsImplCopyWith<_$SettlementTermsImpl> get copyWith =>
      __$$SettlementTermsImplCopyWithImpl<_$SettlementTermsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementTermsImplToJson(this);
  }
}

abstract class _SettlementTerms extends SettlementTerms {
  const factory _SettlementTerms({
    @JsonKey(fromJson: settlementString) final String customer,
    @JsonKey(fromJson: settlementBoolDefaultTrue) final bool enabled,
    @JsonKey(fromJson: settlementString) final String cycle,
    @JsonKey(fromJson: settlementCsv) final String weekdays,
    @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
    final int weekInterval,
    @JsonKey(name: 'month_days', fromJson: settlementCsv)
    final String monthDays,
    @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
    final int? intervalDays,
    @JsonKey(name: 'anchor_date', fromJson: settlementString)
    final String anchorDate,
    @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
    final int? remindDaysBefore,
    @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
    final int? overdueRepeatDays,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    final String responsibleUser,
    @JsonKey(fromJson: settlementString) final String notes,
    @JsonKey(fromJson: settlementBoolDefaultTrue) final bool exists,
  }) = _$SettlementTermsImpl;
  const _SettlementTerms._() : super._();

  factory _SettlementTerms.fromJson(Map<String, dynamic> json) =
      _$SettlementTermsImpl.fromJson;

  @override
  @JsonKey(fromJson: settlementString)
  String get customer;

  /// Absent reads as enabled: the record exists to send reminders.
  @override
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  bool get enabled;
  @override
  @JsonKey(fromJson: settlementString)
  String get cycle;

  /// Comma list of `Mon..Sun`. A JSON list is accepted too.
  @override
  @JsonKey(fromJson: settlementCsv)
  String get weekdays;
  @override
  @JsonKey(name: 'week_interval', fromJson: settlementIntDefaultOne)
  int get weekInterval;

  /// Comma list of `1..31` and/or `last`. A JSON list is accepted too.
  @override
  @JsonKey(name: 'month_days', fromJson: settlementCsv)
  String get monthDays;
  @override
  @JsonKey(name: 'interval_days', fromJson: creditIntOrNull)
  int? get intervalDays;
  @override
  @JsonKey(name: 'anchor_date', fromJson: settlementString)
  String get anchorDate;
  @override
  @JsonKey(name: 'remind_days_before', fromJson: creditIntOrNull)
  int? get remindDaysBefore;
  @override
  @JsonKey(name: 'overdue_repeat_days', fromJson: creditIntOrNull)
  int? get overdueRepeatDays;
  @override
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  String get responsibleUser;
  @override
  @JsonKey(fromJson: settlementString)
  String get notes;

  /// False when the server answered with an empty template for a customer
  /// that has no record yet.
  @override
  @JsonKey(fromJson: settlementBoolDefaultTrue)
  bool get exists;

  /// Create a copy of SettlementTerms
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementTermsImplCopyWith<_$SettlementTermsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SettlementStatus _$SettlementStatusFromJson(Map<String, dynamic> json) {
  return _SettlementStatus.fromJson(json);
}

/// @nodoc
mixin _$SettlementStatus {
  @JsonKey(fromJson: settlementString)
  String get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  String get nextDueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  double get nextDueAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  double get dueNowAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  double get overdueAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  double get openBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
  String get oldestOverdueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
  List<String> get upcomingDates => throw _privateConstructorUsedError;

  /// Invoice after Invoice only: the newest invoice's outstanding, which the
  /// shop settles when the NEXT order arrives.
  @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
  double? get collectOnNextDelivery => throw _privateConstructorUsedError;

  /// Serializes this SettlementStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettlementStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementStatusCopyWith<SettlementStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementStatusCopyWith<$Res> {
  factory $SettlementStatusCopyWith(
    SettlementStatus value,
    $Res Function(SettlementStatus) then,
  ) = _$SettlementStatusCopyWithImpl<$Res, SettlementStatus>;
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble) double openBalance,
    @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
    String oldestOverdueDate,
    @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
    List<String> upcomingDates,
    @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
    double? collectOnNextDelivery,
  });
}

/// @nodoc
class _$SettlementStatusCopyWithImpl<$Res, $Val extends SettlementStatus>
    implements $SettlementStatusCopyWith<$Res> {
  _$SettlementStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? nextDueDate = null,
    Object? nextDueAmount = null,
    Object? dueNowAmount = null,
    Object? overdueAmount = null,
    Object? openBalance = null,
    Object? oldestOverdueDate = null,
    Object? upcomingDates = null,
    Object? collectOnNextDelivery = freezed,
  }) {
    return _then(
      _value.copyWith(
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDueDate: null == nextDueDate
                ? _value.nextDueDate
                : nextDueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDueAmount: null == nextDueAmount
                ? _value.nextDueAmount
                : nextDueAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            dueNowAmount: null == dueNowAmount
                ? _value.dueNowAmount
                : dueNowAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            overdueAmount: null == overdueAmount
                ? _value.overdueAmount
                : overdueAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            openBalance: null == openBalance
                ? _value.openBalance
                : openBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            oldestOverdueDate: null == oldestOverdueDate
                ? _value.oldestOverdueDate
                : oldestOverdueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            upcomingDates: null == upcomingDates
                ? _value.upcomingDates
                : upcomingDates // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            collectOnNextDelivery: freezed == collectOnNextDelivery
                ? _value.collectOnNextDelivery
                : collectOnNextDelivery // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettlementStatusImplCopyWith<$Res>
    implements $SettlementStatusCopyWith<$Res> {
  factory _$$SettlementStatusImplCopyWith(
    _$SettlementStatusImpl value,
    $Res Function(_$SettlementStatusImpl) then,
  ) = __$$SettlementStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble) double openBalance,
    @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
    String oldestOverdueDate,
    @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
    List<String> upcomingDates,
    @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
    double? collectOnNextDelivery,
  });
}

/// @nodoc
class __$$SettlementStatusImplCopyWithImpl<$Res>
    extends _$SettlementStatusCopyWithImpl<$Res, _$SettlementStatusImpl>
    implements _$$SettlementStatusImplCopyWith<$Res> {
  __$$SettlementStatusImplCopyWithImpl(
    _$SettlementStatusImpl _value,
    $Res Function(_$SettlementStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettlementStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? nextDueDate = null,
    Object? nextDueAmount = null,
    Object? dueNowAmount = null,
    Object? overdueAmount = null,
    Object? openBalance = null,
    Object? oldestOverdueDate = null,
    Object? upcomingDates = null,
    Object? collectOnNextDelivery = freezed,
  }) {
    return _then(
      _$SettlementStatusImpl(
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDueDate: null == nextDueDate
            ? _value.nextDueDate
            : nextDueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDueAmount: null == nextDueAmount
            ? _value.nextDueAmount
            : nextDueAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        dueNowAmount: null == dueNowAmount
            ? _value.dueNowAmount
            : dueNowAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        overdueAmount: null == overdueAmount
            ? _value.overdueAmount
            : overdueAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        openBalance: null == openBalance
            ? _value.openBalance
            : openBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        oldestOverdueDate: null == oldestOverdueDate
            ? _value.oldestOverdueDate
            : oldestOverdueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        upcomingDates: null == upcomingDates
            ? _value._upcomingDates
            : upcomingDates // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        collectOnNextDelivery: freezed == collectOnNextDelivery
            ? _value.collectOnNextDelivery
            : collectOnNextDelivery // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementStatusImpl extends _SettlementStatus {
  const _$SettlementStatusImpl({
    @JsonKey(fromJson: settlementString) this.state = '',
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    this.nextDueDate = '',
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    this.nextDueAmount = 0.0,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    this.dueNowAmount = 0.0,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    this.overdueAmount = 0.0,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    this.openBalance = 0.0,
    @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
    this.oldestOverdueDate = '',
    @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
    final List<String> upcomingDates = const <String>[],
    @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
    this.collectOnNextDelivery,
  }) : _upcomingDates = upcomingDates,
       super._();

  factory _$SettlementStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementStatusImplFromJson(json);

  @override
  @JsonKey(fromJson: settlementString)
  final String state;
  @override
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  final String nextDueDate;
  @override
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  final double nextDueAmount;
  @override
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  final double dueNowAmount;
  @override
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  final double overdueAmount;
  @override
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  final double openBalance;
  @override
  @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
  final String oldestOverdueDate;
  final List<String> _upcomingDates;
  @override
  @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
  List<String> get upcomingDates {
    if (_upcomingDates is EqualUnmodifiableListView) return _upcomingDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingDates);
  }

  /// Invoice after Invoice only: the newest invoice's outstanding, which the
  /// shop settles when the NEXT order arrives.
  @override
  @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
  final double? collectOnNextDelivery;

  @override
  String toString() {
    return 'SettlementStatus(state: $state, nextDueDate: $nextDueDate, nextDueAmount: $nextDueAmount, dueNowAmount: $dueNowAmount, overdueAmount: $overdueAmount, openBalance: $openBalance, oldestOverdueDate: $oldestOverdueDate, upcomingDates: $upcomingDates, collectOnNextDelivery: $collectOnNextDelivery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementStatusImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.nextDueAmount, nextDueAmount) ||
                other.nextDueAmount == nextDueAmount) &&
            (identical(other.dueNowAmount, dueNowAmount) ||
                other.dueNowAmount == dueNowAmount) &&
            (identical(other.overdueAmount, overdueAmount) ||
                other.overdueAmount == overdueAmount) &&
            (identical(other.openBalance, openBalance) ||
                other.openBalance == openBalance) &&
            (identical(other.oldestOverdueDate, oldestOverdueDate) ||
                other.oldestOverdueDate == oldestOverdueDate) &&
            const DeepCollectionEquality().equals(
              other._upcomingDates,
              _upcomingDates,
            ) &&
            (identical(other.collectOnNextDelivery, collectOnNextDelivery) ||
                other.collectOnNextDelivery == collectOnNextDelivery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    state,
    nextDueDate,
    nextDueAmount,
    dueNowAmount,
    overdueAmount,
    openBalance,
    oldestOverdueDate,
    const DeepCollectionEquality().hash(_upcomingDates),
    collectOnNextDelivery,
  );

  /// Create a copy of SettlementStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementStatusImplCopyWith<_$SettlementStatusImpl> get copyWith =>
      __$$SettlementStatusImplCopyWithImpl<_$SettlementStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementStatusImplToJson(this);
  }
}

abstract class _SettlementStatus extends SettlementStatus {
  const factory _SettlementStatus({
    @JsonKey(fromJson: settlementString) final String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    final String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    final double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    final double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    final double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    final double openBalance,
    @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
    final String oldestOverdueDate,
    @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
    final List<String> upcomingDates,
    @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
    final double? collectOnNextDelivery,
  }) = _$SettlementStatusImpl;
  const _SettlementStatus._() : super._();

  factory _SettlementStatus.fromJson(Map<String, dynamic> json) =
      _$SettlementStatusImpl.fromJson;

  @override
  @JsonKey(fromJson: settlementString)
  String get state;
  @override
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  String get nextDueDate;
  @override
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  double get nextDueAmount;
  @override
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  double get dueNowAmount;
  @override
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  double get overdueAmount;
  @override
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  double get openBalance;
  @override
  @JsonKey(name: 'oldest_overdue_date', fromJson: settlementString)
  String get oldestOverdueDate;
  @override
  @JsonKey(name: 'upcoming_dates', fromJson: settlementStringList)
  List<String> get upcomingDates;

  /// Invoice after Invoice only: the newest invoice's outstanding, which the
  /// shop settles when the NEXT order arrives.
  @override
  @JsonKey(name: 'collect_on_next_delivery', fromJson: creditDoubleOrNull)
  double? get collectOnNextDelivery;

  /// Create a copy of SettlementStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementStatusImplCopyWith<_$SettlementStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SettlementTermsResponse _$SettlementTermsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SettlementTermsResponse.fromJson(json);
}

/// @nodoc
mixin _$SettlementTermsResponse {
  bool get success => throw _privateConstructorUsedError;

  /// Empty for a Lead that has not become a Customer yet (the server sends
  /// `customer: null` then).
  @JsonKey(fromJson: settlementString)
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  String get customerName => throw _privateConstructorUsedError;

  /// `Customer` or `Lead`. Empty from a server older than lead support,
  /// which only ever answered for a Customer.
  @JsonKey(name: 'party_type', fromJson: settlementString)
  String get partyType => throw _privateConstructorUsedError;

  /// The Customer or Lead name the terms are stored against. A converted
  /// lead answers as its Customer.
  @JsonKey(fromJson: settlementString)
  String get party => throw _privateConstructorUsedError;

  /// Null when the customer has no record.
  SettlementTerms? get terms => throw _privateConstructorUsedError;

  /// The server's English sentence. The UI prefers a localized sentence
  /// built from [terms] and falls back to this one.
  @JsonKey(fromJson: settlementString)
  String get description => throw _privateConstructorUsedError;
  SettlementStatus get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get currency => throw _privateConstructorUsedError;

  /// Write gate; absent means read-only.
  @JsonKey(name: 'can_edit', fromJson: creditBool)
  bool get canEdit => throw _privateConstructorUsedError;

  /// Serializes this SettlementTermsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementTermsResponseCopyWith<SettlementTermsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementTermsResponseCopyWith<$Res> {
  factory $SettlementTermsResponseCopyWith(
    SettlementTermsResponse value,
    $Res Function(SettlementTermsResponse) then,
  ) = _$SettlementTermsResponseCopyWithImpl<$Res, SettlementTermsResponse>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    String customerName,
    @JsonKey(name: 'party_type', fromJson: settlementString) String partyType,
    @JsonKey(fromJson: settlementString) String party,
    SettlementTerms? terms,
    @JsonKey(fromJson: settlementString) String description,
    SettlementStatus status,
    @JsonKey(fromJson: settlementString) String currency,
    @JsonKey(name: 'can_edit', fromJson: creditBool) bool canEdit,
  });

  $SettlementTermsCopyWith<$Res>? get terms;
  $SettlementStatusCopyWith<$Res> get status;
}

/// @nodoc
class _$SettlementTermsResponseCopyWithImpl<
  $Res,
  $Val extends SettlementTermsResponse
>
    implements $SettlementTermsResponseCopyWith<$Res> {
  _$SettlementTermsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? customer = null,
    Object? customerName = null,
    Object? partyType = null,
    Object? party = null,
    Object? terms = freezed,
    Object? description = null,
    Object? status = null,
    Object? currency = null,
    Object? canEdit = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            partyType: null == partyType
                ? _value.partyType
                : partyType // ignore: cast_nullable_to_non_nullable
                      as String,
            party: null == party
                ? _value.party
                : party // ignore: cast_nullable_to_non_nullable
                      as String,
            terms: freezed == terms
                ? _value.terms
                : terms // ignore: cast_nullable_to_non_nullable
                      as SettlementTerms?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SettlementStatus,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            canEdit: null == canEdit
                ? _value.canEdit
                : canEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettlementTermsCopyWith<$Res>? get terms {
    if (_value.terms == null) {
      return null;
    }

    return $SettlementTermsCopyWith<$Res>(_value.terms!, (value) {
      return _then(_value.copyWith(terms: value) as $Val);
    });
  }

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettlementStatusCopyWith<$Res> get status {
    return $SettlementStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SettlementTermsResponseImplCopyWith<$Res>
    implements $SettlementTermsResponseCopyWith<$Res> {
  factory _$$SettlementTermsResponseImplCopyWith(
    _$SettlementTermsResponseImpl value,
    $Res Function(_$SettlementTermsResponseImpl) then,
  ) = __$$SettlementTermsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    String customerName,
    @JsonKey(name: 'party_type', fromJson: settlementString) String partyType,
    @JsonKey(fromJson: settlementString) String party,
    SettlementTerms? terms,
    @JsonKey(fromJson: settlementString) String description,
    SettlementStatus status,
    @JsonKey(fromJson: settlementString) String currency,
    @JsonKey(name: 'can_edit', fromJson: creditBool) bool canEdit,
  });

  @override
  $SettlementTermsCopyWith<$Res>? get terms;
  @override
  $SettlementStatusCopyWith<$Res> get status;
}

/// @nodoc
class __$$SettlementTermsResponseImplCopyWithImpl<$Res>
    extends
        _$SettlementTermsResponseCopyWithImpl<
          $Res,
          _$SettlementTermsResponseImpl
        >
    implements _$$SettlementTermsResponseImplCopyWith<$Res> {
  __$$SettlementTermsResponseImplCopyWithImpl(
    _$SettlementTermsResponseImpl _value,
    $Res Function(_$SettlementTermsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? customer = null,
    Object? customerName = null,
    Object? partyType = null,
    Object? party = null,
    Object? terms = freezed,
    Object? description = null,
    Object? status = null,
    Object? currency = null,
    Object? canEdit = null,
  }) {
    return _then(
      _$SettlementTermsResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        partyType: null == partyType
            ? _value.partyType
            : partyType // ignore: cast_nullable_to_non_nullable
                  as String,
        party: null == party
            ? _value.party
            : party // ignore: cast_nullable_to_non_nullable
                  as String,
        terms: freezed == terms
            ? _value.terms
            : terms // ignore: cast_nullable_to_non_nullable
                  as SettlementTerms?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SettlementStatus,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        canEdit: null == canEdit
            ? _value.canEdit
            : canEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementTermsResponseImpl extends _SettlementTermsResponse {
  const _$SettlementTermsResponseImpl({
    this.success = true,
    @JsonKey(fromJson: settlementString) this.customer = '',
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    this.customerName = '',
    @JsonKey(name: 'party_type', fromJson: settlementString)
    this.partyType = '',
    @JsonKey(fromJson: settlementString) this.party = '',
    this.terms,
    @JsonKey(fromJson: settlementString) this.description = '',
    this.status = const SettlementStatus(),
    @JsonKey(fromJson: settlementString) this.currency = '',
    @JsonKey(name: 'can_edit', fromJson: creditBool) this.canEdit = false,
  }) : super._();

  factory _$SettlementTermsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementTermsResponseImplFromJson(json);

  @override
  @JsonKey()
  final bool success;

  /// Empty for a Lead that has not become a Customer yet (the server sends
  /// `customer: null` then).
  @override
  @JsonKey(fromJson: settlementString)
  final String customer;
  @override
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  final String customerName;

  /// `Customer` or `Lead`. Empty from a server older than lead support,
  /// which only ever answered for a Customer.
  @override
  @JsonKey(name: 'party_type', fromJson: settlementString)
  final String partyType;

  /// The Customer or Lead name the terms are stored against. A converted
  /// lead answers as its Customer.
  @override
  @JsonKey(fromJson: settlementString)
  final String party;

  /// Null when the customer has no record.
  @override
  final SettlementTerms? terms;

  /// The server's English sentence. The UI prefers a localized sentence
  /// built from [terms] and falls back to this one.
  @override
  @JsonKey(fromJson: settlementString)
  final String description;
  @override
  @JsonKey()
  final SettlementStatus status;
  @override
  @JsonKey(fromJson: settlementString)
  final String currency;

  /// Write gate; absent means read-only.
  @override
  @JsonKey(name: 'can_edit', fromJson: creditBool)
  final bool canEdit;

  @override
  String toString() {
    return 'SettlementTermsResponse(success: $success, customer: $customer, customerName: $customerName, partyType: $partyType, party: $party, terms: $terms, description: $description, status: $status, currency: $currency, canEdit: $canEdit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementTermsResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.partyType, partyType) ||
                other.partyType == partyType) &&
            (identical(other.party, party) || other.party == party) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    customer,
    customerName,
    partyType,
    party,
    terms,
    description,
    status,
    currency,
    canEdit,
  );

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementTermsResponseImplCopyWith<_$SettlementTermsResponseImpl>
  get copyWith =>
      __$$SettlementTermsResponseImplCopyWithImpl<
        _$SettlementTermsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementTermsResponseImplToJson(this);
  }
}

abstract class _SettlementTermsResponse extends SettlementTermsResponse {
  const factory _SettlementTermsResponse({
    final bool success,
    @JsonKey(fromJson: settlementString) final String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    final String customerName,
    @JsonKey(name: 'party_type', fromJson: settlementString)
    final String partyType,
    @JsonKey(fromJson: settlementString) final String party,
    final SettlementTerms? terms,
    @JsonKey(fromJson: settlementString) final String description,
    final SettlementStatus status,
    @JsonKey(fromJson: settlementString) final String currency,
    @JsonKey(name: 'can_edit', fromJson: creditBool) final bool canEdit,
  }) = _$SettlementTermsResponseImpl;
  const _SettlementTermsResponse._() : super._();

  factory _SettlementTermsResponse.fromJson(Map<String, dynamic> json) =
      _$SettlementTermsResponseImpl.fromJson;

  @override
  bool get success;

  /// Empty for a Lead that has not become a Customer yet (the server sends
  /// `customer: null` then).
  @override
  @JsonKey(fromJson: settlementString)
  String get customer;
  @override
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  String get customerName;

  /// `Customer` or `Lead`. Empty from a server older than lead support,
  /// which only ever answered for a Customer.
  @override
  @JsonKey(name: 'party_type', fromJson: settlementString)
  String get partyType;

  /// The Customer or Lead name the terms are stored against. A converted
  /// lead answers as its Customer.
  @override
  @JsonKey(fromJson: settlementString)
  String get party;

  /// Null when the customer has no record.
  @override
  SettlementTerms? get terms;

  /// The server's English sentence. The UI prefers a localized sentence
  /// built from [terms] and falls back to this one.
  @override
  @JsonKey(fromJson: settlementString)
  String get description;
  @override
  SettlementStatus get status;
  @override
  @JsonKey(fromJson: settlementString)
  String get currency;

  /// Write gate; absent means read-only.
  @override
  @JsonKey(name: 'can_edit', fromJson: creditBool)
  bool get canEdit;

  /// Create a copy of SettlementTermsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementTermsResponseImplCopyWith<_$SettlementTermsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CollectionDueRow _$CollectionDueRowFromJson(Map<String, dynamic> json) {
  return _CollectionDueRow.fromJson(json);
}

/// @nodoc
mixin _$CollectionDueRow {
  @JsonKey(fromJson: settlementString)
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  String get customerName => throw _privateConstructorUsedError;

  /// Empty for an `unscheduled` shop (open credit, no terms).
  @JsonKey(fromJson: settlementString)
  String get cycle => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  String get nextDueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  double get nextDueAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  double get dueNowAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  double get overdueAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  double get openBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  String get responsibleUser => throw _privateConstructorUsedError;

  /// Serializes this CollectionDueRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionDueRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionDueRowCopyWith<CollectionDueRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionDueRowCopyWith<$Res> {
  factory $CollectionDueRowCopyWith(
    CollectionDueRow value,
    $Res Function(CollectionDueRow) then,
  ) = _$CollectionDueRowCopyWithImpl<$Res, CollectionDueRow>;
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    String customerName,
    @JsonKey(fromJson: settlementString) String cycle,
    @JsonKey(fromJson: settlementString) String description,
    @JsonKey(fromJson: settlementString) String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble) double openBalance,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    String responsibleUser,
  });
}

/// @nodoc
class _$CollectionDueRowCopyWithImpl<$Res, $Val extends CollectionDueRow>
    implements $CollectionDueRowCopyWith<$Res> {
  _$CollectionDueRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionDueRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? cycle = null,
    Object? description = null,
    Object? state = null,
    Object? nextDueDate = null,
    Object? nextDueAmount = null,
    Object? dueNowAmount = null,
    Object? overdueAmount = null,
    Object? openBalance = null,
    Object? responsibleUser = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            cycle: null == cycle
                ? _value.cycle
                : cycle // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDueDate: null == nextDueDate
                ? _value.nextDueDate
                : nextDueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDueAmount: null == nextDueAmount
                ? _value.nextDueAmount
                : nextDueAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            dueNowAmount: null == dueNowAmount
                ? _value.dueNowAmount
                : dueNowAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            overdueAmount: null == overdueAmount
                ? _value.overdueAmount
                : overdueAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            openBalance: null == openBalance
                ? _value.openBalance
                : openBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            responsibleUser: null == responsibleUser
                ? _value.responsibleUser
                : responsibleUser // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollectionDueRowImplCopyWith<$Res>
    implements $CollectionDueRowCopyWith<$Res> {
  factory _$$CollectionDueRowImplCopyWith(
    _$CollectionDueRowImpl value,
    $Res Function(_$CollectionDueRowImpl) then,
  ) = __$$CollectionDueRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: settlementString) String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    String customerName,
    @JsonKey(fromJson: settlementString) String cycle,
    @JsonKey(fromJson: settlementString) String description,
    @JsonKey(fromJson: settlementString) String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble) double openBalance,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    String responsibleUser,
  });
}

/// @nodoc
class __$$CollectionDueRowImplCopyWithImpl<$Res>
    extends _$CollectionDueRowCopyWithImpl<$Res, _$CollectionDueRowImpl>
    implements _$$CollectionDueRowImplCopyWith<$Res> {
  __$$CollectionDueRowImplCopyWithImpl(
    _$CollectionDueRowImpl _value,
    $Res Function(_$CollectionDueRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollectionDueRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? cycle = null,
    Object? description = null,
    Object? state = null,
    Object? nextDueDate = null,
    Object? nextDueAmount = null,
    Object? dueNowAmount = null,
    Object? overdueAmount = null,
    Object? openBalance = null,
    Object? responsibleUser = null,
  }) {
    return _then(
      _$CollectionDueRowImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        cycle: null == cycle
            ? _value.cycle
            : cycle // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDueDate: null == nextDueDate
            ? _value.nextDueDate
            : nextDueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDueAmount: null == nextDueAmount
            ? _value.nextDueAmount
            : nextDueAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        dueNowAmount: null == dueNowAmount
            ? _value.dueNowAmount
            : dueNowAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        overdueAmount: null == overdueAmount
            ? _value.overdueAmount
            : overdueAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        openBalance: null == openBalance
            ? _value.openBalance
            : openBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        responsibleUser: null == responsibleUser
            ? _value.responsibleUser
            : responsibleUser // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionDueRowImpl extends _CollectionDueRow {
  const _$CollectionDueRowImpl({
    @JsonKey(fromJson: settlementString) this.customer = '',
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    this.customerName = '',
    @JsonKey(fromJson: settlementString) this.cycle = '',
    @JsonKey(fromJson: settlementString) this.description = '',
    @JsonKey(fromJson: settlementString) this.state = '',
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    this.nextDueDate = '',
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    this.nextDueAmount = 0.0,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    this.dueNowAmount = 0.0,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    this.overdueAmount = 0.0,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    this.openBalance = 0.0,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    this.responsibleUser = '',
  }) : super._();

  factory _$CollectionDueRowImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionDueRowImplFromJson(json);

  @override
  @JsonKey(fromJson: settlementString)
  final String customer;
  @override
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  final String customerName;

  /// Empty for an `unscheduled` shop (open credit, no terms).
  @override
  @JsonKey(fromJson: settlementString)
  final String cycle;
  @override
  @JsonKey(fromJson: settlementString)
  final String description;
  @override
  @JsonKey(fromJson: settlementString)
  final String state;
  @override
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  final String nextDueDate;
  @override
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  final double nextDueAmount;
  @override
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  final double dueNowAmount;
  @override
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  final double overdueAmount;
  @override
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  final double openBalance;
  @override
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  final String responsibleUser;

  @override
  String toString() {
    return 'CollectionDueRow(customer: $customer, customerName: $customerName, cycle: $cycle, description: $description, state: $state, nextDueDate: $nextDueDate, nextDueAmount: $nextDueAmount, dueNowAmount: $dueNowAmount, overdueAmount: $overdueAmount, openBalance: $openBalance, responsibleUser: $responsibleUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionDueRowImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.cycle, cycle) || other.cycle == cycle) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.nextDueAmount, nextDueAmount) ||
                other.nextDueAmount == nextDueAmount) &&
            (identical(other.dueNowAmount, dueNowAmount) ||
                other.dueNowAmount == dueNowAmount) &&
            (identical(other.overdueAmount, overdueAmount) ||
                other.overdueAmount == overdueAmount) &&
            (identical(other.openBalance, openBalance) ||
                other.openBalance == openBalance) &&
            (identical(other.responsibleUser, responsibleUser) ||
                other.responsibleUser == responsibleUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    cycle,
    description,
    state,
    nextDueDate,
    nextDueAmount,
    dueNowAmount,
    overdueAmount,
    openBalance,
    responsibleUser,
  );

  /// Create a copy of CollectionDueRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionDueRowImplCopyWith<_$CollectionDueRowImpl> get copyWith =>
      __$$CollectionDueRowImplCopyWithImpl<_$CollectionDueRowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionDueRowImplToJson(this);
  }
}

abstract class _CollectionDueRow extends CollectionDueRow {
  const factory _CollectionDueRow({
    @JsonKey(fromJson: settlementString) final String customer,
    @JsonKey(name: 'customer_name', fromJson: settlementString)
    final String customerName,
    @JsonKey(fromJson: settlementString) final String cycle,
    @JsonKey(fromJson: settlementString) final String description,
    @JsonKey(fromJson: settlementString) final String state,
    @JsonKey(name: 'next_due_date', fromJson: settlementString)
    final String nextDueDate,
    @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
    final double nextDueAmount,
    @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
    final double dueNowAmount,
    @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
    final double overdueAmount,
    @JsonKey(name: 'open_balance', fromJson: creditDouble)
    final double openBalance,
    @JsonKey(name: 'responsible_user', fromJson: settlementString)
    final String responsibleUser,
  }) = _$CollectionDueRowImpl;
  const _CollectionDueRow._() : super._();

  factory _CollectionDueRow.fromJson(Map<String, dynamic> json) =
      _$CollectionDueRowImpl.fromJson;

  @override
  @JsonKey(fromJson: settlementString)
  String get customer;
  @override
  @JsonKey(name: 'customer_name', fromJson: settlementString)
  String get customerName;

  /// Empty for an `unscheduled` shop (open credit, no terms).
  @override
  @JsonKey(fromJson: settlementString)
  String get cycle;
  @override
  @JsonKey(fromJson: settlementString)
  String get description;
  @override
  @JsonKey(fromJson: settlementString)
  String get state;
  @override
  @JsonKey(name: 'next_due_date', fromJson: settlementString)
  String get nextDueDate;
  @override
  @JsonKey(name: 'next_due_amount', fromJson: creditDouble)
  double get nextDueAmount;
  @override
  @JsonKey(name: 'due_now_amount', fromJson: creditDouble)
  double get dueNowAmount;
  @override
  @JsonKey(name: 'overdue_amount', fromJson: creditDouble)
  double get overdueAmount;
  @override
  @JsonKey(name: 'open_balance', fromJson: creditDouble)
  double get openBalance;
  @override
  @JsonKey(name: 'responsible_user', fromJson: settlementString)
  String get responsibleUser;

  /// Create a copy of CollectionDueRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionDueRowImplCopyWith<_$CollectionDueRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollectionsDueCounts _$CollectionsDueCountsFromJson(Map<String, dynamic> json) {
  return _CollectionsDueCounts.fromJson(json);
}

/// @nodoc
mixin _$CollectionsDueCounts {
  @JsonKey(fromJson: creditInt)
  int get overdue => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_today', fromJson: creditInt)
  int get dueToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_soon', fromJson: creditInt)
  int get dueSoon => throw _privateConstructorUsedError;

  /// Serializes this CollectionsDueCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionsDueCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionsDueCountsCopyWith<CollectionsDueCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionsDueCountsCopyWith<$Res> {
  factory $CollectionsDueCountsCopyWith(
    CollectionsDueCounts value,
    $Res Function(CollectionsDueCounts) then,
  ) = _$CollectionsDueCountsCopyWithImpl<$Res, CollectionsDueCounts>;
  @useResult
  $Res call({
    @JsonKey(fromJson: creditInt) int overdue,
    @JsonKey(name: 'due_today', fromJson: creditInt) int dueToday,
    @JsonKey(name: 'due_soon', fromJson: creditInt) int dueSoon,
  });
}

/// @nodoc
class _$CollectionsDueCountsCopyWithImpl<
  $Res,
  $Val extends CollectionsDueCounts
>
    implements $CollectionsDueCountsCopyWith<$Res> {
  _$CollectionsDueCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionsDueCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overdue = null,
    Object? dueToday = null,
    Object? dueSoon = null,
  }) {
    return _then(
      _value.copyWith(
            overdue: null == overdue
                ? _value.overdue
                : overdue // ignore: cast_nullable_to_non_nullable
                      as int,
            dueToday: null == dueToday
                ? _value.dueToday
                : dueToday // ignore: cast_nullable_to_non_nullable
                      as int,
            dueSoon: null == dueSoon
                ? _value.dueSoon
                : dueSoon // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollectionsDueCountsImplCopyWith<$Res>
    implements $CollectionsDueCountsCopyWith<$Res> {
  factory _$$CollectionsDueCountsImplCopyWith(
    _$CollectionsDueCountsImpl value,
    $Res Function(_$CollectionsDueCountsImpl) then,
  ) = __$$CollectionsDueCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: creditInt) int overdue,
    @JsonKey(name: 'due_today', fromJson: creditInt) int dueToday,
    @JsonKey(name: 'due_soon', fromJson: creditInt) int dueSoon,
  });
}

/// @nodoc
class __$$CollectionsDueCountsImplCopyWithImpl<$Res>
    extends _$CollectionsDueCountsCopyWithImpl<$Res, _$CollectionsDueCountsImpl>
    implements _$$CollectionsDueCountsImplCopyWith<$Res> {
  __$$CollectionsDueCountsImplCopyWithImpl(
    _$CollectionsDueCountsImpl _value,
    $Res Function(_$CollectionsDueCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollectionsDueCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overdue = null,
    Object? dueToday = null,
    Object? dueSoon = null,
  }) {
    return _then(
      _$CollectionsDueCountsImpl(
        overdue: null == overdue
            ? _value.overdue
            : overdue // ignore: cast_nullable_to_non_nullable
                  as int,
        dueToday: null == dueToday
            ? _value.dueToday
            : dueToday // ignore: cast_nullable_to_non_nullable
                  as int,
        dueSoon: null == dueSoon
            ? _value.dueSoon
            : dueSoon // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionsDueCountsImpl extends _CollectionsDueCounts {
  const _$CollectionsDueCountsImpl({
    @JsonKey(fromJson: creditInt) this.overdue = 0,
    @JsonKey(name: 'due_today', fromJson: creditInt) this.dueToday = 0,
    @JsonKey(name: 'due_soon', fromJson: creditInt) this.dueSoon = 0,
  }) : super._();

  factory _$CollectionsDueCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionsDueCountsImplFromJson(json);

  @override
  @JsonKey(fromJson: creditInt)
  final int overdue;
  @override
  @JsonKey(name: 'due_today', fromJson: creditInt)
  final int dueToday;
  @override
  @JsonKey(name: 'due_soon', fromJson: creditInt)
  final int dueSoon;

  @override
  String toString() {
    return 'CollectionsDueCounts(overdue: $overdue, dueToday: $dueToday, dueSoon: $dueSoon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionsDueCountsImpl &&
            (identical(other.overdue, overdue) || other.overdue == overdue) &&
            (identical(other.dueToday, dueToday) ||
                other.dueToday == dueToday) &&
            (identical(other.dueSoon, dueSoon) || other.dueSoon == dueSoon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, overdue, dueToday, dueSoon);

  /// Create a copy of CollectionsDueCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionsDueCountsImplCopyWith<_$CollectionsDueCountsImpl>
  get copyWith =>
      __$$CollectionsDueCountsImplCopyWithImpl<_$CollectionsDueCountsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionsDueCountsImplToJson(this);
  }
}

abstract class _CollectionsDueCounts extends CollectionsDueCounts {
  const factory _CollectionsDueCounts({
    @JsonKey(fromJson: creditInt) final int overdue,
    @JsonKey(name: 'due_today', fromJson: creditInt) final int dueToday,
    @JsonKey(name: 'due_soon', fromJson: creditInt) final int dueSoon,
  }) = _$CollectionsDueCountsImpl;
  const _CollectionsDueCounts._() : super._();

  factory _CollectionsDueCounts.fromJson(Map<String, dynamic> json) =
      _$CollectionsDueCountsImpl.fromJson;

  @override
  @JsonKey(fromJson: creditInt)
  int get overdue;
  @override
  @JsonKey(name: 'due_today', fromJson: creditInt)
  int get dueToday;
  @override
  @JsonKey(name: 'due_soon', fromJson: creditInt)
  int get dueSoon;

  /// Create a copy of CollectionsDueCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionsDueCountsImplCopyWith<_$CollectionsDueCountsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CollectionsDue _$CollectionsDueFromJson(Map<String, dynamic> json) {
  return _CollectionsDue.fromJson(json);
}

/// @nodoc
mixin _$CollectionsDue {
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(fromJson: settlementString)
  String get currency => throw _privateConstructorUsedError;
  List<CollectionDueRow> get rows => throw _privateConstructorUsedError;
  CollectionsDueCounts get counts => throw _privateConstructorUsedError;

  /// Serializes this CollectionsDue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionsDueCopyWith<CollectionsDue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionsDueCopyWith<$Res> {
  factory $CollectionsDueCopyWith(
    CollectionsDue value,
    $Res Function(CollectionsDue) then,
  ) = _$CollectionsDueCopyWithImpl<$Res, CollectionsDue>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: settlementString) String currency,
    List<CollectionDueRow> rows,
    CollectionsDueCounts counts,
  });

  $CollectionsDueCountsCopyWith<$Res> get counts;
}

/// @nodoc
class _$CollectionsDueCopyWithImpl<$Res, $Val extends CollectionsDue>
    implements $CollectionsDueCopyWith<$Res> {
  _$CollectionsDueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? currency = null,
    Object? rows = null,
    Object? counts = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            rows: null == rows
                ? _value.rows
                : rows // ignore: cast_nullable_to_non_nullable
                      as List<CollectionDueRow>,
            counts: null == counts
                ? _value.counts
                : counts // ignore: cast_nullable_to_non_nullable
                      as CollectionsDueCounts,
          )
          as $Val,
    );
  }

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CollectionsDueCountsCopyWith<$Res> get counts {
    return $CollectionsDueCountsCopyWith<$Res>(_value.counts, (value) {
      return _then(_value.copyWith(counts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CollectionsDueImplCopyWith<$Res>
    implements $CollectionsDueCopyWith<$Res> {
  factory _$$CollectionsDueImplCopyWith(
    _$CollectionsDueImpl value,
    $Res Function(_$CollectionsDueImpl) then,
  ) = __$$CollectionsDueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(fromJson: settlementString) String currency,
    List<CollectionDueRow> rows,
    CollectionsDueCounts counts,
  });

  @override
  $CollectionsDueCountsCopyWith<$Res> get counts;
}

/// @nodoc
class __$$CollectionsDueImplCopyWithImpl<$Res>
    extends _$CollectionsDueCopyWithImpl<$Res, _$CollectionsDueImpl>
    implements _$$CollectionsDueImplCopyWith<$Res> {
  __$$CollectionsDueImplCopyWithImpl(
    _$CollectionsDueImpl _value,
    $Res Function(_$CollectionsDueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? currency = null,
    Object? rows = null,
    Object? counts = null,
  }) {
    return _then(
      _$CollectionsDueImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        rows: null == rows
            ? _value._rows
            : rows // ignore: cast_nullable_to_non_nullable
                  as List<CollectionDueRow>,
        counts: null == counts
            ? _value.counts
            : counts // ignore: cast_nullable_to_non_nullable
                  as CollectionsDueCounts,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectionsDueImpl extends _CollectionsDue {
  const _$CollectionsDueImpl({
    this.success = true,
    @JsonKey(fromJson: settlementString) this.currency = '',
    final List<CollectionDueRow> rows = const <CollectionDueRow>[],
    this.counts = const CollectionsDueCounts(),
  }) : _rows = rows,
       super._();

  factory _$CollectionsDueImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionsDueImplFromJson(json);

  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey(fromJson: settlementString)
  final String currency;
  final List<CollectionDueRow> _rows;
  @override
  @JsonKey()
  List<CollectionDueRow> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  @JsonKey()
  final CollectionsDueCounts counts;

  @override
  String toString() {
    return 'CollectionsDue(success: $success, currency: $currency, rows: $rows, counts: $counts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionsDueImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            (identical(other.counts, counts) || other.counts == counts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    currency,
    const DeepCollectionEquality().hash(_rows),
    counts,
  );

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionsDueImplCopyWith<_$CollectionsDueImpl> get copyWith =>
      __$$CollectionsDueImplCopyWithImpl<_$CollectionsDueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionsDueImplToJson(this);
  }
}

abstract class _CollectionsDue extends CollectionsDue {
  const factory _CollectionsDue({
    final bool success,
    @JsonKey(fromJson: settlementString) final String currency,
    final List<CollectionDueRow> rows,
    final CollectionsDueCounts counts,
  }) = _$CollectionsDueImpl;
  const _CollectionsDue._() : super._();

  factory _CollectionsDue.fromJson(Map<String, dynamic> json) =
      _$CollectionsDueImpl.fromJson;

  @override
  bool get success;
  @override
  @JsonKey(fromJson: settlementString)
  String get currency;
  @override
  List<CollectionDueRow> get rows;
  @override
  CollectionsDueCounts get counts;

  /// Create a copy of CollectionsDue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionsDueImplCopyWith<_$CollectionsDueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

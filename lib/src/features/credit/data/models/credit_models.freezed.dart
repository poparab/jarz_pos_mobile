// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerCreditProfile _$CustomerCreditProfileFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerCreditProfile.fromJson(json);
}

/// @nodoc
mixin _$CustomerCreditProfile {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;

  /// The gate for offering Credit at checkout. Defaults to false so a
  /// malformed or truncated payload can never silently open credit.
  @JsonKey(name: 'credit_allowed', fromJson: creditBool)
  bool get creditAllowed => throw _privateConstructorUsedError;

  /// Payment terms in days. Zero means the backend reported no term, in
  /// which case the checkout selector shows no "Due in N days" line rather
  /// than claiming "Due in 0 days".
  @JsonKey(name: 'credit_days', fromJson: creditInt)
  int get creditDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'credit_limit', fromJson: creditDouble)
  double get creditLimit => throw _privateConstructorUsedError;

  /// What the customer already owes, all-time.
  @JsonKey(name: 'current_balance', fromJson: creditDouble)
  double get currentBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_credit', fromJson: creditDouble)
  double get availableCredit => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this CustomerCreditProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerCreditProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCreditProfileCopyWith<CustomerCreditProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCreditProfileCopyWith<$Res> {
  factory $CustomerCreditProfileCopyWith(
    CustomerCreditProfile value,
    $Res Function(CustomerCreditProfile) then,
  ) = _$CustomerCreditProfileCopyWithImpl<$Res, CustomerCreditProfile>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'credit_allowed', fromJson: creditBool) bool creditAllowed,
    @JsonKey(name: 'credit_days', fromJson: creditInt) int creditDays,
    @JsonKey(name: 'credit_limit', fromJson: creditDouble) double creditLimit,
    @JsonKey(name: 'current_balance', fromJson: creditDouble)
    double currentBalance,
    @JsonKey(name: 'available_credit', fromJson: creditDouble)
    double availableCredit,
    String currency,
  });
}

/// @nodoc
class _$CustomerCreditProfileCopyWithImpl<
  $Res,
  $Val extends CustomerCreditProfile
>
    implements $CustomerCreditProfileCopyWith<$Res> {
  _$CustomerCreditProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerCreditProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? creditAllowed = null,
    Object? creditDays = null,
    Object? creditLimit = null,
    Object? currentBalance = null,
    Object? availableCredit = null,
    Object? currency = null,
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
            creditAllowed: null == creditAllowed
                ? _value.creditAllowed
                : creditAllowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            creditDays: null == creditDays
                ? _value.creditDays
                : creditDays // ignore: cast_nullable_to_non_nullable
                      as int,
            creditLimit: null == creditLimit
                ? _value.creditLimit
                : creditLimit // ignore: cast_nullable_to_non_nullable
                      as double,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            availableCredit: null == availableCredit
                ? _value.availableCredit
                : availableCredit // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerCreditProfileImplCopyWith<$Res>
    implements $CustomerCreditProfileCopyWith<$Res> {
  factory _$$CustomerCreditProfileImplCopyWith(
    _$CustomerCreditProfileImpl value,
    $Res Function(_$CustomerCreditProfileImpl) then,
  ) = __$$CustomerCreditProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'credit_allowed', fromJson: creditBool) bool creditAllowed,
    @JsonKey(name: 'credit_days', fromJson: creditInt) int creditDays,
    @JsonKey(name: 'credit_limit', fromJson: creditDouble) double creditLimit,
    @JsonKey(name: 'current_balance', fromJson: creditDouble)
    double currentBalance,
    @JsonKey(name: 'available_credit', fromJson: creditDouble)
    double availableCredit,
    String currency,
  });
}

/// @nodoc
class __$$CustomerCreditProfileImplCopyWithImpl<$Res>
    extends
        _$CustomerCreditProfileCopyWithImpl<$Res, _$CustomerCreditProfileImpl>
    implements _$$CustomerCreditProfileImplCopyWith<$Res> {
  __$$CustomerCreditProfileImplCopyWithImpl(
    _$CustomerCreditProfileImpl _value,
    $Res Function(_$CustomerCreditProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerCreditProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? creditAllowed = null,
    Object? creditDays = null,
    Object? creditLimit = null,
    Object? currentBalance = null,
    Object? availableCredit = null,
    Object? currency = null,
  }) {
    return _then(
      _$CustomerCreditProfileImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        creditAllowed: null == creditAllowed
            ? _value.creditAllowed
            : creditAllowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        creditDays: null == creditDays
            ? _value.creditDays
            : creditDays // ignore: cast_nullable_to_non_nullable
                  as int,
        creditLimit: null == creditLimit
            ? _value.creditLimit
            : creditLimit // ignore: cast_nullable_to_non_nullable
                  as double,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        availableCredit: null == availableCredit
            ? _value.availableCredit
            : availableCredit // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerCreditProfileImpl extends _CustomerCreditProfile {
  const _$CustomerCreditProfileImpl({
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'credit_allowed', fromJson: creditBool)
    this.creditAllowed = false,
    @JsonKey(name: 'credit_days', fromJson: creditInt) this.creditDays = 0,
    @JsonKey(name: 'credit_limit', fromJson: creditDouble)
    this.creditLimit = 0.0,
    @JsonKey(name: 'current_balance', fromJson: creditDouble)
    this.currentBalance = 0.0,
    @JsonKey(name: 'available_credit', fromJson: creditDouble)
    this.availableCredit = 0.0,
    this.currency = '',
  }) : super._();

  factory _$CustomerCreditProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerCreditProfileImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;

  /// The gate for offering Credit at checkout. Defaults to false so a
  /// malformed or truncated payload can never silently open credit.
  @override
  @JsonKey(name: 'credit_allowed', fromJson: creditBool)
  final bool creditAllowed;

  /// Payment terms in days. Zero means the backend reported no term, in
  /// which case the checkout selector shows no "Due in N days" line rather
  /// than claiming "Due in 0 days".
  @override
  @JsonKey(name: 'credit_days', fromJson: creditInt)
  final int creditDays;
  @override
  @JsonKey(name: 'credit_limit', fromJson: creditDouble)
  final double creditLimit;

  /// What the customer already owes, all-time.
  @override
  @JsonKey(name: 'current_balance', fromJson: creditDouble)
  final double currentBalance;
  @override
  @JsonKey(name: 'available_credit', fromJson: creditDouble)
  final double availableCredit;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'CustomerCreditProfile(customer: $customer, customerName: $customerName, creditAllowed: $creditAllowed, creditDays: $creditDays, creditLimit: $creditLimit, currentBalance: $currentBalance, availableCredit: $availableCredit, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerCreditProfileImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.creditAllowed, creditAllowed) ||
                other.creditAllowed == creditAllowed) &&
            (identical(other.creditDays, creditDays) ||
                other.creditDays == creditDays) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.availableCredit, availableCredit) ||
                other.availableCredit == availableCredit) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    creditAllowed,
    creditDays,
    creditLimit,
    currentBalance,
    availableCredit,
    currency,
  );

  /// Create a copy of CustomerCreditProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerCreditProfileImplCopyWith<_$CustomerCreditProfileImpl>
  get copyWith =>
      __$$CustomerCreditProfileImplCopyWithImpl<_$CustomerCreditProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerCreditProfileImplToJson(this);
  }
}

abstract class _CustomerCreditProfile extends CustomerCreditProfile {
  const factory _CustomerCreditProfile({
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'credit_allowed', fromJson: creditBool)
    final bool creditAllowed,
    @JsonKey(name: 'credit_days', fromJson: creditInt) final int creditDays,
    @JsonKey(name: 'credit_limit', fromJson: creditDouble)
    final double creditLimit,
    @JsonKey(name: 'current_balance', fromJson: creditDouble)
    final double currentBalance,
    @JsonKey(name: 'available_credit', fromJson: creditDouble)
    final double availableCredit,
    final String currency,
  }) = _$CustomerCreditProfileImpl;
  const _CustomerCreditProfile._() : super._();

  factory _CustomerCreditProfile.fromJson(Map<String, dynamic> json) =
      _$CustomerCreditProfileImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;

  /// The gate for offering Credit at checkout. Defaults to false so a
  /// malformed or truncated payload can never silently open credit.
  @override
  @JsonKey(name: 'credit_allowed', fromJson: creditBool)
  bool get creditAllowed;

  /// Payment terms in days. Zero means the backend reported no term, in
  /// which case the checkout selector shows no "Due in N days" line rather
  /// than claiming "Due in 0 days".
  @override
  @JsonKey(name: 'credit_days', fromJson: creditInt)
  int get creditDays;
  @override
  @JsonKey(name: 'credit_limit', fromJson: creditDouble)
  double get creditLimit;

  /// What the customer already owes, all-time.
  @override
  @JsonKey(name: 'current_balance', fromJson: creditDouble)
  double get currentBalance;
  @override
  @JsonKey(name: 'available_credit', fromJson: creditDouble)
  double get availableCredit;
  @override
  String get currency;

  /// Create a copy of CustomerCreditProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerCreditProfileImplCopyWith<_$CustomerCreditProfileImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CreditLedgerFilters _$CreditLedgerFiltersFromJson(Map<String, dynamic> json) {
  return _CreditLedgerFilters.fromJson(json);
}

/// @nodoc
mixin _$CreditLedgerFilters {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'pos_profile')
  String get posProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_date')
  String get fromDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_date')
  String get toDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: creditInt)
  int get limit => throw _privateConstructorUsedError;

  /// Serializes this CreditLedgerFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditLedgerFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditLedgerFiltersCopyWith<CreditLedgerFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditLedgerFiltersCopyWith<$Res> {
  factory $CreditLedgerFiltersCopyWith(
    CreditLedgerFilters value,
    $Res Function(CreditLedgerFilters) then,
  ) = _$CreditLedgerFiltersCopyWithImpl<$Res, CreditLedgerFilters>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'pos_profile') String posProfile,
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String toDate,
    @JsonKey(fromJson: creditInt) int limit,
  });
}

/// @nodoc
class _$CreditLedgerFiltersCopyWithImpl<$Res, $Val extends CreditLedgerFilters>
    implements $CreditLedgerFiltersCopyWith<$Res> {
  _$CreditLedgerFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditLedgerFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? posProfile = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? limit = null,
  }) {
    return _then(
      _value.copyWith(
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            posProfile: null == posProfile
                ? _value.posProfile
                : posProfile // ignore: cast_nullable_to_non_nullable
                      as String,
            fromDate: null == fromDate
                ? _value.fromDate
                : fromDate // ignore: cast_nullable_to_non_nullable
                      as String,
            toDate: null == toDate
                ? _value.toDate
                : toDate // ignore: cast_nullable_to_non_nullable
                      as String,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditLedgerFiltersImplCopyWith<$Res>
    implements $CreditLedgerFiltersCopyWith<$Res> {
  factory _$$CreditLedgerFiltersImplCopyWith(
    _$CreditLedgerFiltersImpl value,
    $Res Function(_$CreditLedgerFiltersImpl) then,
  ) = __$$CreditLedgerFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'pos_profile') String posProfile,
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String toDate,
    @JsonKey(fromJson: creditInt) int limit,
  });
}

/// @nodoc
class __$$CreditLedgerFiltersImplCopyWithImpl<$Res>
    extends _$CreditLedgerFiltersCopyWithImpl<$Res, _$CreditLedgerFiltersImpl>
    implements _$$CreditLedgerFiltersImplCopyWith<$Res> {
  __$$CreditLedgerFiltersImplCopyWithImpl(
    _$CreditLedgerFiltersImpl _value,
    $Res Function(_$CreditLedgerFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditLedgerFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? posProfile = null,
    Object? fromDate = null,
    Object? toDate = null,
    Object? limit = null,
  }) {
    return _then(
      _$CreditLedgerFiltersImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        posProfile: null == posProfile
            ? _value.posProfile
            : posProfile // ignore: cast_nullable_to_non_nullable
                  as String,
        fromDate: null == fromDate
            ? _value.fromDate
            : fromDate // ignore: cast_nullable_to_non_nullable
                  as String,
        toDate: null == toDate
            ? _value.toDate
            : toDate // ignore: cast_nullable_to_non_nullable
                  as String,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditLedgerFiltersImpl implements _CreditLedgerFilters {
  const _$CreditLedgerFiltersImpl({
    this.customer = '',
    @JsonKey(name: 'pos_profile') this.posProfile = '',
    @JsonKey(name: 'from_date') this.fromDate = '',
    @JsonKey(name: 'to_date') this.toDate = '',
    @JsonKey(fromJson: creditInt) this.limit = 0,
  });

  factory _$CreditLedgerFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditLedgerFiltersImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'pos_profile')
  final String posProfile;
  @override
  @JsonKey(name: 'from_date')
  final String fromDate;
  @override
  @JsonKey(name: 'to_date')
  final String toDate;
  @override
  @JsonKey(fromJson: creditInt)
  final int limit;

  @override
  String toString() {
    return 'CreditLedgerFilters(customer: $customer, posProfile: $posProfile, fromDate: $fromDate, toDate: $toDate, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditLedgerFiltersImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.posProfile, posProfile) ||
                other.posProfile == posProfile) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customer, posProfile, fromDate, toDate, limit);

  /// Create a copy of CreditLedgerFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditLedgerFiltersImplCopyWith<_$CreditLedgerFiltersImpl> get copyWith =>
      __$$CreditLedgerFiltersImplCopyWithImpl<_$CreditLedgerFiltersImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditLedgerFiltersImplToJson(this);
  }
}

abstract class _CreditLedgerFilters implements CreditLedgerFilters {
  const factory _CreditLedgerFilters({
    final String customer,
    @JsonKey(name: 'pos_profile') final String posProfile,
    @JsonKey(name: 'from_date') final String fromDate,
    @JsonKey(name: 'to_date') final String toDate,
    @JsonKey(fromJson: creditInt) final int limit,
  }) = _$CreditLedgerFiltersImpl;

  factory _CreditLedgerFilters.fromJson(Map<String, dynamic> json) =
      _$CreditLedgerFiltersImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'pos_profile')
  String get posProfile;
  @override
  @JsonKey(name: 'from_date')
  String get fromDate;
  @override
  @JsonKey(name: 'to_date')
  String get toDate;
  @override
  @JsonKey(fromJson: creditInt)
  int get limit;

  /// Create a copy of CreditLedgerFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditLedgerFiltersImplCopyWith<_$CreditLedgerFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditLedgerSummary _$CreditLedgerSummaryFromJson(Map<String, dynamic> json) {
  return _CreditLedgerSummary.fromJson(json);
}

/// @nodoc
mixin _$CreditLedgerSummary {
  @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
  double get totalOutstanding => throw _privateConstructorUsedError;

  /// Shops carrying a NON-ZERO balance. Can be smaller than
  /// `CreditLedger.customers.length`, because a shop with activity in the
  /// window but nothing owed is still listed, at zero.
  @JsonKey(name: 'customer_count', fromJson: creditInt)
  int get customerCount => throw _privateConstructorUsedError;

  /// Invoices LISTED IN THE WINDOW, not the count behind the balance. Zero
  /// here is perfectly compatible with a non-zero outstanding amount: the
  /// debt is simply older than the selected period.
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  int get invoiceCount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Absent means an older backend that had not yet split balance from
  /// activity; defaults to true so the label never quietly under-claims.
  @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
  bool get outstandingIsAllTime => throw _privateConstructorUsedError;

  /// Serializes this CreditLedgerSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditLedgerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditLedgerSummaryCopyWith<CreditLedgerSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditLedgerSummaryCopyWith<$Res> {
  factory $CreditLedgerSummaryCopyWith(
    CreditLedgerSummary value,
    $Res Function(CreditLedgerSummary) then,
  ) = _$CreditLedgerSummaryCopyWithImpl<$Res, CreditLedgerSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    double totalOutstanding,
    @JsonKey(name: 'customer_count', fromJson: creditInt) int customerCount,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) int invoiceCount,
    String currency,
    @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
    bool outstandingIsAllTime,
  });
}

/// @nodoc
class _$CreditLedgerSummaryCopyWithImpl<$Res, $Val extends CreditLedgerSummary>
    implements $CreditLedgerSummaryCopyWith<$Res> {
  _$CreditLedgerSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditLedgerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOutstanding = null,
    Object? customerCount = null,
    Object? invoiceCount = null,
    Object? currency = null,
    Object? outstandingIsAllTime = null,
  }) {
    return _then(
      _value.copyWith(
            totalOutstanding: null == totalOutstanding
                ? _value.totalOutstanding
                : totalOutstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            customerCount: null == customerCount
                ? _value.customerCount
                : customerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            invoiceCount: null == invoiceCount
                ? _value.invoiceCount
                : invoiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            outstandingIsAllTime: null == outstandingIsAllTime
                ? _value.outstandingIsAllTime
                : outstandingIsAllTime // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditLedgerSummaryImplCopyWith<$Res>
    implements $CreditLedgerSummaryCopyWith<$Res> {
  factory _$$CreditLedgerSummaryImplCopyWith(
    _$CreditLedgerSummaryImpl value,
    $Res Function(_$CreditLedgerSummaryImpl) then,
  ) = __$$CreditLedgerSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    double totalOutstanding,
    @JsonKey(name: 'customer_count', fromJson: creditInt) int customerCount,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) int invoiceCount,
    String currency,
    @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
    bool outstandingIsAllTime,
  });
}

/// @nodoc
class __$$CreditLedgerSummaryImplCopyWithImpl<$Res>
    extends _$CreditLedgerSummaryCopyWithImpl<$Res, _$CreditLedgerSummaryImpl>
    implements _$$CreditLedgerSummaryImplCopyWith<$Res> {
  __$$CreditLedgerSummaryImplCopyWithImpl(
    _$CreditLedgerSummaryImpl _value,
    $Res Function(_$CreditLedgerSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditLedgerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOutstanding = null,
    Object? customerCount = null,
    Object? invoiceCount = null,
    Object? currency = null,
    Object? outstandingIsAllTime = null,
  }) {
    return _then(
      _$CreditLedgerSummaryImpl(
        totalOutstanding: null == totalOutstanding
            ? _value.totalOutstanding
            : totalOutstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        customerCount: null == customerCount
            ? _value.customerCount
            : customerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        invoiceCount: null == invoiceCount
            ? _value.invoiceCount
            : invoiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        outstandingIsAllTime: null == outstandingIsAllTime
            ? _value.outstandingIsAllTime
            : outstandingIsAllTime // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditLedgerSummaryImpl implements _CreditLedgerSummary {
  const _$CreditLedgerSummaryImpl({
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    this.totalOutstanding = 0.0,
    @JsonKey(name: 'customer_count', fromJson: creditInt)
    this.customerCount = 0,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) this.invoiceCount = 0,
    this.currency = '',
    @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
    this.outstandingIsAllTime = true,
  });

  factory _$CreditLedgerSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditLedgerSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
  final double totalOutstanding;

  /// Shops carrying a NON-ZERO balance. Can be smaller than
  /// `CreditLedger.customers.length`, because a shop with activity in the
  /// window but nothing owed is still listed, at zero.
  @override
  @JsonKey(name: 'customer_count', fromJson: creditInt)
  final int customerCount;

  /// Invoices LISTED IN THE WINDOW, not the count behind the balance. Zero
  /// here is perfectly compatible with a non-zero outstanding amount: the
  /// debt is simply older than the selected period.
  @override
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  final int invoiceCount;
  @override
  @JsonKey()
  final String currency;

  /// Absent means an older backend that had not yet split balance from
  /// activity; defaults to true so the label never quietly under-claims.
  @override
  @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
  final bool outstandingIsAllTime;

  @override
  String toString() {
    return 'CreditLedgerSummary(totalOutstanding: $totalOutstanding, customerCount: $customerCount, invoiceCount: $invoiceCount, currency: $currency, outstandingIsAllTime: $outstandingIsAllTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditLedgerSummaryImpl &&
            (identical(other.totalOutstanding, totalOutstanding) ||
                other.totalOutstanding == totalOutstanding) &&
            (identical(other.customerCount, customerCount) ||
                other.customerCount == customerCount) &&
            (identical(other.invoiceCount, invoiceCount) ||
                other.invoiceCount == invoiceCount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.outstandingIsAllTime, outstandingIsAllTime) ||
                other.outstandingIsAllTime == outstandingIsAllTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalOutstanding,
    customerCount,
    invoiceCount,
    currency,
    outstandingIsAllTime,
  );

  /// Create a copy of CreditLedgerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditLedgerSummaryImplCopyWith<_$CreditLedgerSummaryImpl> get copyWith =>
      __$$CreditLedgerSummaryImplCopyWithImpl<_$CreditLedgerSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditLedgerSummaryImplToJson(this);
  }
}

abstract class _CreditLedgerSummary implements CreditLedgerSummary {
  const factory _CreditLedgerSummary({
    @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
    final double totalOutstanding,
    @JsonKey(name: 'customer_count', fromJson: creditInt)
    final int customerCount,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) final int invoiceCount,
    final String currency,
    @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
    final bool outstandingIsAllTime,
  }) = _$CreditLedgerSummaryImpl;

  factory _CreditLedgerSummary.fromJson(Map<String, dynamic> json) =
      _$CreditLedgerSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_outstanding', fromJson: creditDouble)
  double get totalOutstanding;

  /// Shops carrying a NON-ZERO balance. Can be smaller than
  /// `CreditLedger.customers.length`, because a shop with activity in the
  /// window but nothing owed is still listed, at zero.
  @override
  @JsonKey(name: 'customer_count', fromJson: creditInt)
  int get customerCount;

  /// Invoices LISTED IN THE WINDOW, not the count behind the balance. Zero
  /// here is perfectly compatible with a non-zero outstanding amount: the
  /// debt is simply older than the selected period.
  @override
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  int get invoiceCount;
  @override
  String get currency;

  /// Absent means an older backend that had not yet split balance from
  /// activity; defaults to true so the label never quietly under-claims.
  @override
  @JsonKey(name: 'outstanding_is_all_time', fromJson: creditAllTimeFlag)
  bool get outstandingIsAllTime;

  /// Create a copy of CreditLedgerSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditLedgerSummaryImplCopyWith<_$CreditLedgerSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditCustomerRow _$CreditCustomerRowFromJson(Map<String, dynamic> json) {
  return _CreditCustomerRow.fromJson(json);
}

/// @nodoc
mixin _$CreditCustomerRow {
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;

  /// ALL-TIME, never bounded by the ledger's date window.
  ///
  /// The wire key is **`outstanding`**, singular, and only on the row.
  /// `total_outstanding` is the SUMMARY's key; reading it here is what shipped
  /// to production reading 0.00 for every shop, emptying the accounts list and
  /// making the payment sheet reject every amount as over-balance. The
  /// tolerant reader accepts the summary spelling too, so a backend that ever
  /// unifies them cannot break this screen a second time.
  @JsonKey(
    name: 'outstanding',
    readValue: readRowOutstanding,
    fromJson: creditDouble,
  )
  double get outstanding => throw _privateConstructorUsedError;

  /// Open invoices behind [outstanding] — this one IS the count behind
  /// the balance, unlike `CreditLedgerSummary.invoiceCount`.
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  int get invoiceCount => throw _privateConstructorUsedError;

  /// Posting date of the oldest still-open invoice, `YYYY-MM-DD`.
  @JsonKey(name: 'oldest_invoice_date')
  String get oldestInvoiceDate => throw _privateConstructorUsedError;

  /// The server's own ageing of that invoice. Preferred over recomputing
  /// from the date, because the server ages against ITS today, not the
  /// handset's — a device with a wrong clock cannot invent an age here.
  @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
  int? get oldestAgeDays => throw _privateConstructorUsedError;

  /// THE list of genuinely open invoices for this shop, oldest first, with
  /// no date window applied — the same rows, in the same order, that a
  /// payment is allocated against. Distinct from `CreditLedger.invoices`,
  /// which is a windowed activity feed that includes fully-paid invoices.
  @JsonKey(name: 'open_invoices')
  List<CreditInvoice> get openInvoices => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this CreditCustomerRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditCustomerRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditCustomerRowCopyWith<CreditCustomerRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditCustomerRowCopyWith<$Res> {
  factory $CreditCustomerRowCopyWith(
    CreditCustomerRow value,
    $Res Function(CreditCustomerRow) then,
  ) = _$CreditCustomerRowCopyWithImpl<$Res, CreditCustomerRow>;
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(
      name: 'outstanding',
      readValue: readRowOutstanding,
      fromJson: creditDouble,
    )
    double outstanding,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) int invoiceCount,
    @JsonKey(name: 'oldest_invoice_date') String oldestInvoiceDate,
    @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
    int? oldestAgeDays,
    @JsonKey(name: 'open_invoices') List<CreditInvoice> openInvoices,
    String currency,
  });
}

/// @nodoc
class _$CreditCustomerRowCopyWithImpl<$Res, $Val extends CreditCustomerRow>
    implements $CreditCustomerRowCopyWith<$Res> {
  _$CreditCustomerRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditCustomerRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? outstanding = null,
    Object? invoiceCount = null,
    Object? oldestInvoiceDate = null,
    Object? oldestAgeDays = freezed,
    Object? openInvoices = null,
    Object? currency = null,
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
            outstanding: null == outstanding
                ? _value.outstanding
                : outstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            invoiceCount: null == invoiceCount
                ? _value.invoiceCount
                : invoiceCount // ignore: cast_nullable_to_non_nullable
                      as int,
            oldestInvoiceDate: null == oldestInvoiceDate
                ? _value.oldestInvoiceDate
                : oldestInvoiceDate // ignore: cast_nullable_to_non_nullable
                      as String,
            oldestAgeDays: freezed == oldestAgeDays
                ? _value.oldestAgeDays
                : oldestAgeDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            openInvoices: null == openInvoices
                ? _value.openInvoices
                : openInvoices // ignore: cast_nullable_to_non_nullable
                      as List<CreditInvoice>,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditCustomerRowImplCopyWith<$Res>
    implements $CreditCustomerRowCopyWith<$Res> {
  factory _$$CreditCustomerRowImplCopyWith(
    _$CreditCustomerRowImpl value,
    $Res Function(_$CreditCustomerRowImpl) then,
  ) = __$$CreditCustomerRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(
      name: 'outstanding',
      readValue: readRowOutstanding,
      fromJson: creditDouble,
    )
    double outstanding,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) int invoiceCount,
    @JsonKey(name: 'oldest_invoice_date') String oldestInvoiceDate,
    @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
    int? oldestAgeDays,
    @JsonKey(name: 'open_invoices') List<CreditInvoice> openInvoices,
    String currency,
  });
}

/// @nodoc
class __$$CreditCustomerRowImplCopyWithImpl<$Res>
    extends _$CreditCustomerRowCopyWithImpl<$Res, _$CreditCustomerRowImpl>
    implements _$$CreditCustomerRowImplCopyWith<$Res> {
  __$$CreditCustomerRowImplCopyWithImpl(
    _$CreditCustomerRowImpl _value,
    $Res Function(_$CreditCustomerRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditCustomerRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customer = null,
    Object? customerName = null,
    Object? outstanding = null,
    Object? invoiceCount = null,
    Object? oldestInvoiceDate = null,
    Object? oldestAgeDays = freezed,
    Object? openInvoices = null,
    Object? currency = null,
  }) {
    return _then(
      _$CreditCustomerRowImpl(
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        outstanding: null == outstanding
            ? _value.outstanding
            : outstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        invoiceCount: null == invoiceCount
            ? _value.invoiceCount
            : invoiceCount // ignore: cast_nullable_to_non_nullable
                  as int,
        oldestInvoiceDate: null == oldestInvoiceDate
            ? _value.oldestInvoiceDate
            : oldestInvoiceDate // ignore: cast_nullable_to_non_nullable
                  as String,
        oldestAgeDays: freezed == oldestAgeDays
            ? _value.oldestAgeDays
            : oldestAgeDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        openInvoices: null == openInvoices
            ? _value._openInvoices
            : openInvoices // ignore: cast_nullable_to_non_nullable
                  as List<CreditInvoice>,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditCustomerRowImpl extends _CreditCustomerRow {
  const _$CreditCustomerRowImpl({
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(
      name: 'outstanding',
      readValue: readRowOutstanding,
      fromJson: creditDouble,
    )
    this.outstanding = 0.0,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) this.invoiceCount = 0,
    @JsonKey(name: 'oldest_invoice_date') this.oldestInvoiceDate = '',
    @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
    this.oldestAgeDays,
    @JsonKey(name: 'open_invoices')
    final List<CreditInvoice> openInvoices = const <CreditInvoice>[],
    this.currency = '',
  }) : _openInvoices = openInvoices,
       super._();

  factory _$CreditCustomerRowImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditCustomerRowImplFromJson(json);

  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;

  /// ALL-TIME, never bounded by the ledger's date window.
  ///
  /// The wire key is **`outstanding`**, singular, and only on the row.
  /// `total_outstanding` is the SUMMARY's key; reading it here is what shipped
  /// to production reading 0.00 for every shop, emptying the accounts list and
  /// making the payment sheet reject every amount as over-balance. The
  /// tolerant reader accepts the summary spelling too, so a backend that ever
  /// unifies them cannot break this screen a second time.
  @override
  @JsonKey(
    name: 'outstanding',
    readValue: readRowOutstanding,
    fromJson: creditDouble,
  )
  final double outstanding;

  /// Open invoices behind [outstanding] — this one IS the count behind
  /// the balance, unlike `CreditLedgerSummary.invoiceCount`.
  @override
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  final int invoiceCount;

  /// Posting date of the oldest still-open invoice, `YYYY-MM-DD`.
  @override
  @JsonKey(name: 'oldest_invoice_date')
  final String oldestInvoiceDate;

  /// The server's own ageing of that invoice. Preferred over recomputing
  /// from the date, because the server ages against ITS today, not the
  /// handset's — a device with a wrong clock cannot invent an age here.
  @override
  @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
  final int? oldestAgeDays;

  /// THE list of genuinely open invoices for this shop, oldest first, with
  /// no date window applied — the same rows, in the same order, that a
  /// payment is allocated against. Distinct from `CreditLedger.invoices`,
  /// which is a windowed activity feed that includes fully-paid invoices.
  final List<CreditInvoice> _openInvoices;

  /// THE list of genuinely open invoices for this shop, oldest first, with
  /// no date window applied — the same rows, in the same order, that a
  /// payment is allocated against. Distinct from `CreditLedger.invoices`,
  /// which is a windowed activity feed that includes fully-paid invoices.
  @override
  @JsonKey(name: 'open_invoices')
  List<CreditInvoice> get openInvoices {
    if (_openInvoices is EqualUnmodifiableListView) return _openInvoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openInvoices);
  }

  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'CreditCustomerRow(customer: $customer, customerName: $customerName, outstanding: $outstanding, invoiceCount: $invoiceCount, oldestInvoiceDate: $oldestInvoiceDate, oldestAgeDays: $oldestAgeDays, openInvoices: $openInvoices, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditCustomerRowImpl &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.outstanding, outstanding) ||
                other.outstanding == outstanding) &&
            (identical(other.invoiceCount, invoiceCount) ||
                other.invoiceCount == invoiceCount) &&
            (identical(other.oldestInvoiceDate, oldestInvoiceDate) ||
                other.oldestInvoiceDate == oldestInvoiceDate) &&
            (identical(other.oldestAgeDays, oldestAgeDays) ||
                other.oldestAgeDays == oldestAgeDays) &&
            const DeepCollectionEquality().equals(
              other._openInvoices,
              _openInvoices,
            ) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customer,
    customerName,
    outstanding,
    invoiceCount,
    oldestInvoiceDate,
    oldestAgeDays,
    const DeepCollectionEquality().hash(_openInvoices),
    currency,
  );

  /// Create a copy of CreditCustomerRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditCustomerRowImplCopyWith<_$CreditCustomerRowImpl> get copyWith =>
      __$$CreditCustomerRowImplCopyWithImpl<_$CreditCustomerRowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditCustomerRowImplToJson(this);
  }
}

abstract class _CreditCustomerRow extends CreditCustomerRow {
  const factory _CreditCustomerRow({
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(
      name: 'outstanding',
      readValue: readRowOutstanding,
      fromJson: creditDouble,
    )
    final double outstanding,
    @JsonKey(name: 'invoice_count', fromJson: creditInt) final int invoiceCount,
    @JsonKey(name: 'oldest_invoice_date') final String oldestInvoiceDate,
    @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
    final int? oldestAgeDays,
    @JsonKey(name: 'open_invoices') final List<CreditInvoice> openInvoices,
    final String currency,
  }) = _$CreditCustomerRowImpl;
  const _CreditCustomerRow._() : super._();

  factory _CreditCustomerRow.fromJson(Map<String, dynamic> json) =
      _$CreditCustomerRowImpl.fromJson;

  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;

  /// ALL-TIME, never bounded by the ledger's date window.
  ///
  /// The wire key is **`outstanding`**, singular, and only on the row.
  /// `total_outstanding` is the SUMMARY's key; reading it here is what shipped
  /// to production reading 0.00 for every shop, emptying the accounts list and
  /// making the payment sheet reject every amount as over-balance. The
  /// tolerant reader accepts the summary spelling too, so a backend that ever
  /// unifies them cannot break this screen a second time.
  @override
  @JsonKey(
    name: 'outstanding',
    readValue: readRowOutstanding,
    fromJson: creditDouble,
  )
  double get outstanding;

  /// Open invoices behind [outstanding] — this one IS the count behind
  /// the balance, unlike `CreditLedgerSummary.invoiceCount`.
  @override
  @JsonKey(name: 'invoice_count', fromJson: creditInt)
  int get invoiceCount;

  /// Posting date of the oldest still-open invoice, `YYYY-MM-DD`.
  @override
  @JsonKey(name: 'oldest_invoice_date')
  String get oldestInvoiceDate;

  /// The server's own ageing of that invoice. Preferred over recomputing
  /// from the date, because the server ages against ITS today, not the
  /// handset's — a device with a wrong clock cannot invent an age here.
  @override
  @JsonKey(name: 'oldest_age_days', fromJson: creditIntOrNull)
  int? get oldestAgeDays;

  /// THE list of genuinely open invoices for this shop, oldest first, with
  /// no date window applied — the same rows, in the same order, that a
  /// payment is allocated against. Distinct from `CreditLedger.invoices`,
  /// which is a windowed activity feed that includes fully-paid invoices.
  @override
  @JsonKey(name: 'open_invoices')
  List<CreditInvoice> get openInvoices;
  @override
  String get currency;

  /// Create a copy of CreditCustomerRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditCustomerRowImplCopyWith<_$CreditCustomerRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditInvoice _$CreditInvoiceFromJson(Map<String, dynamic> json) {
  return _CreditInvoice.fromJson(json);
}

/// @nodoc
mixin _$CreditInvoice {
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  String get invoice => throw _privateConstructorUsedError;
  @JsonKey(name: 'woo_order_id')
  Object? get wooOrderId => throw _privateConstructorUsedError;
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'posting_date')
  String get postingDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  String get dueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'grand_total', fromJson: creditDouble)
  double get grandTotal => throw _privateConstructorUsedError;

  /// `outstanding_amount` in the activity feed, but the per-customer
  /// `open_invoices` rows spell it `outstanding`, exactly as the customer row
  /// does. Both are read so one list model serves both shapes.
  @JsonKey(
    name: 'outstanding_amount',
    readValue: readInvoiceOutstanding,
    fromJson: creditDouble,
  )
  double get outstandingAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'pos_profile')
  String get posProfile => throw _privateConstructorUsedError;
  String get branch => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this CreditInvoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditInvoiceCopyWith<CreditInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditInvoiceCopyWith<$Res> {
  factory $CreditInvoiceCopyWith(
    CreditInvoice value,
    $Res Function(CreditInvoice) then,
  ) = _$CreditInvoiceCopyWithImpl<$Res, CreditInvoice>;
  @useResult
  $Res call({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'posting_date') String postingDate,
    @JsonKey(name: 'due_date') String dueDate,
    @JsonKey(name: 'grand_total', fromJson: creditDouble) double grandTotal,
    @JsonKey(
      name: 'outstanding_amount',
      readValue: readInvoiceOutstanding,
      fromJson: creditDouble,
    )
    double outstandingAmount,
    String status,
    @JsonKey(name: 'pos_profile') String posProfile,
    String branch,
    String currency,
  });
}

/// @nodoc
class _$CreditInvoiceCopyWithImpl<$Res, $Val extends CreditInvoice>
    implements $CreditInvoiceCopyWith<$Res> {
  _$CreditInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? wooOrderId = freezed,
    Object? customer = null,
    Object? customerName = null,
    Object? postingDate = null,
    Object? dueDate = null,
    Object? grandTotal = null,
    Object? outstandingAmount = null,
    Object? status = null,
    Object? posProfile = null,
    Object? branch = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            invoice: null == invoice
                ? _value.invoice
                : invoice // ignore: cast_nullable_to_non_nullable
                      as String,
            wooOrderId: freezed == wooOrderId ? _value.wooOrderId : wooOrderId,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            postingDate: null == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            grandTotal: null == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            outstandingAmount: null == outstandingAmount
                ? _value.outstandingAmount
                : outstandingAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            posProfile: null == posProfile
                ? _value.posProfile
                : posProfile // ignore: cast_nullable_to_non_nullable
                      as String,
            branch: null == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditInvoiceImplCopyWith<$Res>
    implements $CreditInvoiceCopyWith<$Res> {
  factory _$$CreditInvoiceImplCopyWith(
    _$CreditInvoiceImpl value,
    $Res Function(_$CreditInvoiceImpl) then,
  ) = __$$CreditInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'posting_date') String postingDate,
    @JsonKey(name: 'due_date') String dueDate,
    @JsonKey(name: 'grand_total', fromJson: creditDouble) double grandTotal,
    @JsonKey(
      name: 'outstanding_amount',
      readValue: readInvoiceOutstanding,
      fromJson: creditDouble,
    )
    double outstandingAmount,
    String status,
    @JsonKey(name: 'pos_profile') String posProfile,
    String branch,
    String currency,
  });
}

/// @nodoc
class __$$CreditInvoiceImplCopyWithImpl<$Res>
    extends _$CreditInvoiceCopyWithImpl<$Res, _$CreditInvoiceImpl>
    implements _$$CreditInvoiceImplCopyWith<$Res> {
  __$$CreditInvoiceImplCopyWithImpl(
    _$CreditInvoiceImpl _value,
    $Res Function(_$CreditInvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? wooOrderId = freezed,
    Object? customer = null,
    Object? customerName = null,
    Object? postingDate = null,
    Object? dueDate = null,
    Object? grandTotal = null,
    Object? outstandingAmount = null,
    Object? status = null,
    Object? posProfile = null,
    Object? branch = null,
    Object? currency = null,
  }) {
    return _then(
      _$CreditInvoiceImpl(
        invoice: null == invoice
            ? _value.invoice
            : invoice // ignore: cast_nullable_to_non_nullable
                  as String,
        wooOrderId: freezed == wooOrderId ? _value.wooOrderId : wooOrderId,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        postingDate: null == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        grandTotal: null == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        outstandingAmount: null == outstandingAmount
            ? _value.outstandingAmount
            : outstandingAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        posProfile: null == posProfile
            ? _value.posProfile
            : posProfile // ignore: cast_nullable_to_non_nullable
                  as String,
        branch: null == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditInvoiceImpl extends _CreditInvoice {
  const _$CreditInvoiceImpl({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) this.invoice = '',
    @JsonKey(name: 'woo_order_id') this.wooOrderId,
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'posting_date') this.postingDate = '',
    @JsonKey(name: 'due_date') this.dueDate = '',
    @JsonKey(name: 'grand_total', fromJson: creditDouble) this.grandTotal = 0.0,
    @JsonKey(
      name: 'outstanding_amount',
      readValue: readInvoiceOutstanding,
      fromJson: creditDouble,
    )
    this.outstandingAmount = 0.0,
    this.status = '',
    @JsonKey(name: 'pos_profile') this.posProfile = '',
    this.branch = '',
    this.currency = '',
  }) : super._();

  factory _$CreditInvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditInvoiceImplFromJson(json);

  @override
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  final String invoice;
  @override
  @JsonKey(name: 'woo_order_id')
  final Object? wooOrderId;
  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'posting_date')
  final String postingDate;
  @override
  @JsonKey(name: 'due_date')
  final String dueDate;
  @override
  @JsonKey(name: 'grand_total', fromJson: creditDouble)
  final double grandTotal;

  /// `outstanding_amount` in the activity feed, but the per-customer
  /// `open_invoices` rows spell it `outstanding`, exactly as the customer row
  /// does. Both are read so one list model serves both shapes.
  @override
  @JsonKey(
    name: 'outstanding_amount',
    readValue: readInvoiceOutstanding,
    fromJson: creditDouble,
  )
  final double outstandingAmount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'pos_profile')
  final String posProfile;
  @override
  @JsonKey()
  final String branch;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'CreditInvoice(invoice: $invoice, wooOrderId: $wooOrderId, customer: $customer, customerName: $customerName, postingDate: $postingDate, dueDate: $dueDate, grandTotal: $grandTotal, outstandingAmount: $outstandingAmount, status: $status, posProfile: $posProfile, branch: $branch, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditInvoiceImpl &&
            (identical(other.invoice, invoice) || other.invoice == invoice) &&
            const DeepCollectionEquality().equals(
              other.wooOrderId,
              wooOrderId,
            ) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.posProfile, posProfile) ||
                other.posProfile == posProfile) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    invoice,
    const DeepCollectionEquality().hash(wooOrderId),
    customer,
    customerName,
    postingDate,
    dueDate,
    grandTotal,
    outstandingAmount,
    status,
    posProfile,
    branch,
    currency,
  );

  /// Create a copy of CreditInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditInvoiceImplCopyWith<_$CreditInvoiceImpl> get copyWith =>
      __$$CreditInvoiceImplCopyWithImpl<_$CreditInvoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditInvoiceImplToJson(this);
  }
}

abstract class _CreditInvoice extends CreditInvoice {
  const factory _CreditInvoice({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) final String invoice,
    @JsonKey(name: 'woo_order_id') final Object? wooOrderId,
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'posting_date') final String postingDate,
    @JsonKey(name: 'due_date') final String dueDate,
    @JsonKey(name: 'grand_total', fromJson: creditDouble)
    final double grandTotal,
    @JsonKey(
      name: 'outstanding_amount',
      readValue: readInvoiceOutstanding,
      fromJson: creditDouble,
    )
    final double outstandingAmount,
    final String status,
    @JsonKey(name: 'pos_profile') final String posProfile,
    final String branch,
    final String currency,
  }) = _$CreditInvoiceImpl;
  const _CreditInvoice._() : super._();

  factory _CreditInvoice.fromJson(Map<String, dynamic> json) =
      _$CreditInvoiceImpl.fromJson;

  @override
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  String get invoice;
  @override
  @JsonKey(name: 'woo_order_id')
  Object? get wooOrderId;
  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'posting_date')
  String get postingDate;
  @override
  @JsonKey(name: 'due_date')
  String get dueDate;
  @override
  @JsonKey(name: 'grand_total', fromJson: creditDouble)
  double get grandTotal;

  /// `outstanding_amount` in the activity feed, but the per-customer
  /// `open_invoices` rows spell it `outstanding`, exactly as the customer row
  /// does. Both are read so one list model serves both shapes.
  @override
  @JsonKey(
    name: 'outstanding_amount',
    readValue: readInvoiceOutstanding,
    fromJson: creditDouble,
  )
  double get outstandingAmount;
  @override
  String get status;
  @override
  @JsonKey(name: 'pos_profile')
  String get posProfile;
  @override
  String get branch;
  @override
  String get currency;

  /// Create a copy of CreditInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditInvoiceImplCopyWith<_$CreditInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditLedger _$CreditLedgerFromJson(Map<String, dynamic> json) {
  return _CreditLedger.fromJson(json);
}

/// @nodoc
mixin _$CreditLedger {
  bool get success => throw _privateConstructorUsedError;
  CreditLedgerFilters get filters => throw _privateConstructorUsedError;
  CreditLedgerSummary get summary => throw _privateConstructorUsedError;

  /// Sorted highest balance first by [CreditRepository.getCreditLedger], so
  /// the screen never depends on the server's ordering.
  List<CreditCustomerRow> get customers => throw _privateConstructorUsedError;

  /// The activity feed. Bounded by the date window AND by `limit`, unlike
  /// the balances above it.
  List<CreditInvoice> get invoices => throw _privateConstructorUsedError;
  @JsonKey(name: 'notice_code')
  String? get noticeCode => throw _privateConstructorUsedError;
  String? get notice => throw _privateConstructorUsedError;

  /// Serializes this CreditLedger to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditLedgerCopyWith<CreditLedger> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditLedgerCopyWith<$Res> {
  factory $CreditLedgerCopyWith(
    CreditLedger value,
    $Res Function(CreditLedger) then,
  ) = _$CreditLedgerCopyWithImpl<$Res, CreditLedger>;
  @useResult
  $Res call({
    bool success,
    CreditLedgerFilters filters,
    CreditLedgerSummary summary,
    List<CreditCustomerRow> customers,
    List<CreditInvoice> invoices,
    @JsonKey(name: 'notice_code') String? noticeCode,
    String? notice,
  });

  $CreditLedgerFiltersCopyWith<$Res> get filters;
  $CreditLedgerSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$CreditLedgerCopyWithImpl<$Res, $Val extends CreditLedger>
    implements $CreditLedgerCopyWith<$Res> {
  _$CreditLedgerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? filters = null,
    Object? summary = null,
    Object? customers = null,
    Object? invoices = null,
    Object? noticeCode = freezed,
    Object? notice = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as CreditLedgerFilters,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as CreditLedgerSummary,
            customers: null == customers
                ? _value.customers
                : customers // ignore: cast_nullable_to_non_nullable
                      as List<CreditCustomerRow>,
            invoices: null == invoices
                ? _value.invoices
                : invoices // ignore: cast_nullable_to_non_nullable
                      as List<CreditInvoice>,
            noticeCode: freezed == noticeCode
                ? _value.noticeCode
                : noticeCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            notice: freezed == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreditLedgerFiltersCopyWith<$Res> get filters {
    return $CreditLedgerFiltersCopyWith<$Res>(_value.filters, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreditLedgerSummaryCopyWith<$Res> get summary {
    return $CreditLedgerSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreditLedgerImplCopyWith<$Res>
    implements $CreditLedgerCopyWith<$Res> {
  factory _$$CreditLedgerImplCopyWith(
    _$CreditLedgerImpl value,
    $Res Function(_$CreditLedgerImpl) then,
  ) = __$$CreditLedgerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    CreditLedgerFilters filters,
    CreditLedgerSummary summary,
    List<CreditCustomerRow> customers,
    List<CreditInvoice> invoices,
    @JsonKey(name: 'notice_code') String? noticeCode,
    String? notice,
  });

  @override
  $CreditLedgerFiltersCopyWith<$Res> get filters;
  @override
  $CreditLedgerSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$CreditLedgerImplCopyWithImpl<$Res>
    extends _$CreditLedgerCopyWithImpl<$Res, _$CreditLedgerImpl>
    implements _$$CreditLedgerImplCopyWith<$Res> {
  __$$CreditLedgerImplCopyWithImpl(
    _$CreditLedgerImpl _value,
    $Res Function(_$CreditLedgerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? filters = null,
    Object? summary = null,
    Object? customers = null,
    Object? invoices = null,
    Object? noticeCode = freezed,
    Object? notice = freezed,
  }) {
    return _then(
      _$CreditLedgerImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        filters: null == filters
            ? _value.filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as CreditLedgerFilters,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as CreditLedgerSummary,
        customers: null == customers
            ? _value._customers
            : customers // ignore: cast_nullable_to_non_nullable
                  as List<CreditCustomerRow>,
        invoices: null == invoices
            ? _value._invoices
            : invoices // ignore: cast_nullable_to_non_nullable
                  as List<CreditInvoice>,
        noticeCode: freezed == noticeCode
            ? _value.noticeCode
            : noticeCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        notice: freezed == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditLedgerImpl extends _CreditLedger {
  const _$CreditLedgerImpl({
    this.success = true,
    this.filters = const CreditLedgerFilters(),
    this.summary = const CreditLedgerSummary(),
    final List<CreditCustomerRow> customers = const <CreditCustomerRow>[],
    final List<CreditInvoice> invoices = const <CreditInvoice>[],
    @JsonKey(name: 'notice_code') this.noticeCode,
    this.notice,
  }) : _customers = customers,
       _invoices = invoices,
       super._();

  factory _$CreditLedgerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditLedgerImplFromJson(json);

  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey()
  final CreditLedgerFilters filters;
  @override
  @JsonKey()
  final CreditLedgerSummary summary;

  /// Sorted highest balance first by [CreditRepository.getCreditLedger], so
  /// the screen never depends on the server's ordering.
  final List<CreditCustomerRow> _customers;

  /// Sorted highest balance first by [CreditRepository.getCreditLedger], so
  /// the screen never depends on the server's ordering.
  @override
  @JsonKey()
  List<CreditCustomerRow> get customers {
    if (_customers is EqualUnmodifiableListView) return _customers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customers);
  }

  /// The activity feed. Bounded by the date window AND by `limit`, unlike
  /// the balances above it.
  final List<CreditInvoice> _invoices;

  /// The activity feed. Bounded by the date window AND by `limit`, unlike
  /// the balances above it.
  @override
  @JsonKey()
  List<CreditInvoice> get invoices {
    if (_invoices is EqualUnmodifiableListView) return _invoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invoices);
  }

  @override
  @JsonKey(name: 'notice_code')
  final String? noticeCode;
  @override
  final String? notice;

  @override
  String toString() {
    return 'CreditLedger(success: $success, filters: $filters, summary: $summary, customers: $customers, invoices: $invoices, noticeCode: $noticeCode, notice: $notice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditLedgerImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._customers,
              _customers,
            ) &&
            const DeepCollectionEquality().equals(other._invoices, _invoices) &&
            (identical(other.noticeCode, noticeCode) ||
                other.noticeCode == noticeCode) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    filters,
    summary,
    const DeepCollectionEquality().hash(_customers),
    const DeepCollectionEquality().hash(_invoices),
    noticeCode,
    notice,
  );

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditLedgerImplCopyWith<_$CreditLedgerImpl> get copyWith =>
      __$$CreditLedgerImplCopyWithImpl<_$CreditLedgerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditLedgerImplToJson(this);
  }
}

abstract class _CreditLedger extends CreditLedger {
  const factory _CreditLedger({
    final bool success,
    final CreditLedgerFilters filters,
    final CreditLedgerSummary summary,
    final List<CreditCustomerRow> customers,
    final List<CreditInvoice> invoices,
    @JsonKey(name: 'notice_code') final String? noticeCode,
    final String? notice,
  }) = _$CreditLedgerImpl;
  const _CreditLedger._() : super._();

  factory _CreditLedger.fromJson(Map<String, dynamic> json) =
      _$CreditLedgerImpl.fromJson;

  @override
  bool get success;
  @override
  CreditLedgerFilters get filters;
  @override
  CreditLedgerSummary get summary;

  /// Sorted highest balance first by [CreditRepository.getCreditLedger], so
  /// the screen never depends on the server's ordering.
  @override
  List<CreditCustomerRow> get customers;

  /// The activity feed. Bounded by the date window AND by `limit`, unlike
  /// the balances above it.
  @override
  List<CreditInvoice> get invoices;
  @override
  @JsonKey(name: 'notice_code')
  String? get noticeCode;
  @override
  String? get notice;

  /// Create a copy of CreditLedger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditLedgerImplCopyWith<_$CreditLedgerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditPaymentAllocation _$CreditPaymentAllocationFromJson(
  Map<String, dynamic> json,
) {
  return _CreditPaymentAllocation.fromJson(json);
}

/// @nodoc
mixin _$CreditPaymentAllocation {
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  String get invoice => throw _privateConstructorUsedError;
  @JsonKey(name: 'woo_order_id')
  Object? get wooOrderId => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'allocated_amount',
    readValue: readAllocatedAmount,
    fromJson: creditDouble,
  )
  double get allocatedAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
  double get outstandingBefore => throw _privateConstructorUsedError;
  @JsonKey(name: 'fully_settled')
  bool get fullySettled => throw _privateConstructorUsedError;
  @JsonKey(name: 'posting_date')
  String get postingDate => throw _privateConstructorUsedError;

  /// Serializes this CreditPaymentAllocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditPaymentAllocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditPaymentAllocationCopyWith<CreditPaymentAllocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditPaymentAllocationCopyWith<$Res> {
  factory $CreditPaymentAllocationCopyWith(
    CreditPaymentAllocation value,
    $Res Function(CreditPaymentAllocation) then,
  ) = _$CreditPaymentAllocationCopyWithImpl<$Res, CreditPaymentAllocation>;
  @useResult
  $Res call({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    @JsonKey(
      name: 'allocated_amount',
      readValue: readAllocatedAmount,
      fromJson: creditDouble,
    )
    double allocatedAmount,
    @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
    double outstandingBefore,
    @JsonKey(name: 'fully_settled') bool fullySettled,
    @JsonKey(name: 'posting_date') String postingDate,
  });
}

/// @nodoc
class _$CreditPaymentAllocationCopyWithImpl<
  $Res,
  $Val extends CreditPaymentAllocation
>
    implements $CreditPaymentAllocationCopyWith<$Res> {
  _$CreditPaymentAllocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditPaymentAllocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? wooOrderId = freezed,
    Object? allocatedAmount = null,
    Object? outstandingBefore = null,
    Object? fullySettled = null,
    Object? postingDate = null,
  }) {
    return _then(
      _value.copyWith(
            invoice: null == invoice
                ? _value.invoice
                : invoice // ignore: cast_nullable_to_non_nullable
                      as String,
            wooOrderId: freezed == wooOrderId ? _value.wooOrderId : wooOrderId,
            allocatedAmount: null == allocatedAmount
                ? _value.allocatedAmount
                : allocatedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            outstandingBefore: null == outstandingBefore
                ? _value.outstandingBefore
                : outstandingBefore // ignore: cast_nullable_to_non_nullable
                      as double,
            fullySettled: null == fullySettled
                ? _value.fullySettled
                : fullySettled // ignore: cast_nullable_to_non_nullable
                      as bool,
            postingDate: null == postingDate
                ? _value.postingDate
                : postingDate // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditPaymentAllocationImplCopyWith<$Res>
    implements $CreditPaymentAllocationCopyWith<$Res> {
  factory _$$CreditPaymentAllocationImplCopyWith(
    _$CreditPaymentAllocationImpl value,
    $Res Function(_$CreditPaymentAllocationImpl) then,
  ) = __$$CreditPaymentAllocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) String invoice,
    @JsonKey(name: 'woo_order_id') Object? wooOrderId,
    @JsonKey(
      name: 'allocated_amount',
      readValue: readAllocatedAmount,
      fromJson: creditDouble,
    )
    double allocatedAmount,
    @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
    double outstandingBefore,
    @JsonKey(name: 'fully_settled') bool fullySettled,
    @JsonKey(name: 'posting_date') String postingDate,
  });
}

/// @nodoc
class __$$CreditPaymentAllocationImplCopyWithImpl<$Res>
    extends
        _$CreditPaymentAllocationCopyWithImpl<
          $Res,
          _$CreditPaymentAllocationImpl
        >
    implements _$$CreditPaymentAllocationImplCopyWith<$Res> {
  __$$CreditPaymentAllocationImplCopyWithImpl(
    _$CreditPaymentAllocationImpl _value,
    $Res Function(_$CreditPaymentAllocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditPaymentAllocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? wooOrderId = freezed,
    Object? allocatedAmount = null,
    Object? outstandingBefore = null,
    Object? fullySettled = null,
    Object? postingDate = null,
  }) {
    return _then(
      _$CreditPaymentAllocationImpl(
        invoice: null == invoice
            ? _value.invoice
            : invoice // ignore: cast_nullable_to_non_nullable
                  as String,
        wooOrderId: freezed == wooOrderId ? _value.wooOrderId : wooOrderId,
        allocatedAmount: null == allocatedAmount
            ? _value.allocatedAmount
            : allocatedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        outstandingBefore: null == outstandingBefore
            ? _value.outstandingBefore
            : outstandingBefore // ignore: cast_nullable_to_non_nullable
                  as double,
        fullySettled: null == fullySettled
            ? _value.fullySettled
            : fullySettled // ignore: cast_nullable_to_non_nullable
                  as bool,
        postingDate: null == postingDate
            ? _value.postingDate
            : postingDate // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditPaymentAllocationImpl extends _CreditPaymentAllocation {
  const _$CreditPaymentAllocationImpl({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) this.invoice = '',
    @JsonKey(name: 'woo_order_id') this.wooOrderId,
    @JsonKey(
      name: 'allocated_amount',
      readValue: readAllocatedAmount,
      fromJson: creditDouble,
    )
    this.allocatedAmount = 0.0,
    @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
    this.outstandingBefore = 0.0,
    @JsonKey(name: 'fully_settled') this.fullySettled = false,
    @JsonKey(name: 'posting_date') this.postingDate = '',
  }) : super._();

  factory _$CreditPaymentAllocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditPaymentAllocationImplFromJson(json);

  @override
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  final String invoice;
  @override
  @JsonKey(name: 'woo_order_id')
  final Object? wooOrderId;
  @override
  @JsonKey(
    name: 'allocated_amount',
    readValue: readAllocatedAmount,
    fromJson: creditDouble,
  )
  final double allocatedAmount;
  @override
  @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
  final double outstandingBefore;
  @override
  @JsonKey(name: 'fully_settled')
  final bool fullySettled;
  @override
  @JsonKey(name: 'posting_date')
  final String postingDate;

  @override
  String toString() {
    return 'CreditPaymentAllocation(invoice: $invoice, wooOrderId: $wooOrderId, allocatedAmount: $allocatedAmount, outstandingBefore: $outstandingBefore, fullySettled: $fullySettled, postingDate: $postingDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditPaymentAllocationImpl &&
            (identical(other.invoice, invoice) || other.invoice == invoice) &&
            const DeepCollectionEquality().equals(
              other.wooOrderId,
              wooOrderId,
            ) &&
            (identical(other.allocatedAmount, allocatedAmount) ||
                other.allocatedAmount == allocatedAmount) &&
            (identical(other.outstandingBefore, outstandingBefore) ||
                other.outstandingBefore == outstandingBefore) &&
            (identical(other.fullySettled, fullySettled) ||
                other.fullySettled == fullySettled) &&
            (identical(other.postingDate, postingDate) ||
                other.postingDate == postingDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    invoice,
    const DeepCollectionEquality().hash(wooOrderId),
    allocatedAmount,
    outstandingBefore,
    fullySettled,
    postingDate,
  );

  /// Create a copy of CreditPaymentAllocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditPaymentAllocationImplCopyWith<_$CreditPaymentAllocationImpl>
  get copyWith =>
      __$$CreditPaymentAllocationImplCopyWithImpl<
        _$CreditPaymentAllocationImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditPaymentAllocationImplToJson(this);
  }
}

abstract class _CreditPaymentAllocation extends CreditPaymentAllocation {
  const factory _CreditPaymentAllocation({
    @JsonKey(name: 'invoice', readValue: readInvoiceId) final String invoice,
    @JsonKey(name: 'woo_order_id') final Object? wooOrderId,
    @JsonKey(
      name: 'allocated_amount',
      readValue: readAllocatedAmount,
      fromJson: creditDouble,
    )
    final double allocatedAmount,
    @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
    final double outstandingBefore,
    @JsonKey(name: 'fully_settled') final bool fullySettled,
    @JsonKey(name: 'posting_date') final String postingDate,
  }) = _$CreditPaymentAllocationImpl;
  const _CreditPaymentAllocation._() : super._();

  factory _CreditPaymentAllocation.fromJson(Map<String, dynamic> json) =
      _$CreditPaymentAllocationImpl.fromJson;

  @override
  @JsonKey(name: 'invoice', readValue: readInvoiceId)
  String get invoice;
  @override
  @JsonKey(name: 'woo_order_id')
  Object? get wooOrderId;
  @override
  @JsonKey(
    name: 'allocated_amount',
    readValue: readAllocatedAmount,
    fromJson: creditDouble,
  )
  double get allocatedAmount;
  @override
  @JsonKey(name: 'outstanding_before', fromJson: creditDouble)
  double get outstandingBefore;
  @override
  @JsonKey(name: 'fully_settled')
  bool get fullySettled;
  @override
  @JsonKey(name: 'posting_date')
  String get postingDate;

  /// Create a copy of CreditPaymentAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditPaymentAllocationImplCopyWith<_$CreditPaymentAllocationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CreditPaymentResult _$CreditPaymentResultFromJson(Map<String, dynamic> json) {
  return _CreditPaymentResult.fromJson(json);
}

/// @nodoc
mixin _$CreditPaymentResult {
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_entry')
  String get paymentEntry => throw _privateConstructorUsedError;
  String get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount', fromJson: creditDouble)
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'total_allocated',
    readValue: readTotalAllocated,
    fromJson: creditDouble,
  )
  double get totalAllocated => throw _privateConstructorUsedError;

  /// The excess left sitting as an unallocated advance on the customer.
  @JsonKey(
    name: 'unallocated_amount',
    readValue: readUnallocatedAmount,
    fromJson: creditDouble,
  )
  double get unallocatedAmount => throw _privateConstructorUsedError;

  /// Remaining balance after the payment, when the backend reports it.
  @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
  double? get remainingBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'allocations', readValue: readAllocations)
  List<CreditPaymentAllocation> get allocations =>
      throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// The replay branch: this exact attempt was already posted, so the server
  /// returned the ORIGINAL Payment Entry and did nothing.
  ///
  /// That response carries no `allocations`, no `unallocated_amount` and no
  /// `remaining_balance` — every field the result dialog is built from. Not
  /// parsing these three keys is what made a replay render a title, an id and
  /// nothing else, which is exactly the blank screen that earns a third tap
  /// and, before the token existed, a third payment.
  @JsonKey(name: 'already_recorded', fromJson: creditBool)
  bool get alreadyRecorded => throw _privateConstructorUsedError;
  @JsonKey(name: 'notice_code')
  String? get noticeCode => throw _privateConstructorUsedError;
  String? get notice => throw _privateConstructorUsedError;

  /// Serializes this CreditPaymentResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditPaymentResultCopyWith<CreditPaymentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditPaymentResultCopyWith<$Res> {
  factory $CreditPaymentResultCopyWith(
    CreditPaymentResult value,
    $Res Function(CreditPaymentResult) then,
  ) = _$CreditPaymentResultCopyWithImpl<$Res, CreditPaymentResult>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'payment_entry') String paymentEntry,
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'amount', fromJson: creditDouble) double amount,
    @JsonKey(
      name: 'total_allocated',
      readValue: readTotalAllocated,
      fromJson: creditDouble,
    )
    double totalAllocated,
    @JsonKey(
      name: 'unallocated_amount',
      readValue: readUnallocatedAmount,
      fromJson: creditDouble,
    )
    double unallocatedAmount,
    @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
    double? remainingBalance,
    @JsonKey(name: 'allocations', readValue: readAllocations)
    List<CreditPaymentAllocation> allocations,
    String currency,
    @JsonKey(name: 'already_recorded', fromJson: creditBool)
    bool alreadyRecorded,
    @JsonKey(name: 'notice_code') String? noticeCode,
    String? notice,
  });
}

/// @nodoc
class _$CreditPaymentResultCopyWithImpl<$Res, $Val extends CreditPaymentResult>
    implements $CreditPaymentResultCopyWith<$Res> {
  _$CreditPaymentResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? paymentEntry = null,
    Object? customer = null,
    Object? customerName = null,
    Object? amount = null,
    Object? totalAllocated = null,
    Object? unallocatedAmount = null,
    Object? remainingBalance = freezed,
    Object? allocations = null,
    Object? currency = null,
    Object? alreadyRecorded = null,
    Object? noticeCode = freezed,
    Object? notice = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            paymentEntry: null == paymentEntry
                ? _value.paymentEntry
                : paymentEntry // ignore: cast_nullable_to_non_nullable
                      as String,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAllocated: null == totalAllocated
                ? _value.totalAllocated
                : totalAllocated // ignore: cast_nullable_to_non_nullable
                      as double,
            unallocatedAmount: null == unallocatedAmount
                ? _value.unallocatedAmount
                : unallocatedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            remainingBalance: freezed == remainingBalance
                ? _value.remainingBalance
                : remainingBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            allocations: null == allocations
                ? _value.allocations
                : allocations // ignore: cast_nullable_to_non_nullable
                      as List<CreditPaymentAllocation>,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            alreadyRecorded: null == alreadyRecorded
                ? _value.alreadyRecorded
                : alreadyRecorded // ignore: cast_nullable_to_non_nullable
                      as bool,
            noticeCode: freezed == noticeCode
                ? _value.noticeCode
                : noticeCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            notice: freezed == notice
                ? _value.notice
                : notice // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditPaymentResultImplCopyWith<$Res>
    implements $CreditPaymentResultCopyWith<$Res> {
  factory _$$CreditPaymentResultImplCopyWith(
    _$CreditPaymentResultImpl value,
    $Res Function(_$CreditPaymentResultImpl) then,
  ) = __$$CreditPaymentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'payment_entry') String paymentEntry,
    String customer,
    @JsonKey(name: 'customer_name') String customerName,
    @JsonKey(name: 'amount', fromJson: creditDouble) double amount,
    @JsonKey(
      name: 'total_allocated',
      readValue: readTotalAllocated,
      fromJson: creditDouble,
    )
    double totalAllocated,
    @JsonKey(
      name: 'unallocated_amount',
      readValue: readUnallocatedAmount,
      fromJson: creditDouble,
    )
    double unallocatedAmount,
    @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
    double? remainingBalance,
    @JsonKey(name: 'allocations', readValue: readAllocations)
    List<CreditPaymentAllocation> allocations,
    String currency,
    @JsonKey(name: 'already_recorded', fromJson: creditBool)
    bool alreadyRecorded,
    @JsonKey(name: 'notice_code') String? noticeCode,
    String? notice,
  });
}

/// @nodoc
class __$$CreditPaymentResultImplCopyWithImpl<$Res>
    extends _$CreditPaymentResultCopyWithImpl<$Res, _$CreditPaymentResultImpl>
    implements _$$CreditPaymentResultImplCopyWith<$Res> {
  __$$CreditPaymentResultImplCopyWithImpl(
    _$CreditPaymentResultImpl _value,
    $Res Function(_$CreditPaymentResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? paymentEntry = null,
    Object? customer = null,
    Object? customerName = null,
    Object? amount = null,
    Object? totalAllocated = null,
    Object? unallocatedAmount = null,
    Object? remainingBalance = freezed,
    Object? allocations = null,
    Object? currency = null,
    Object? alreadyRecorded = null,
    Object? noticeCode = freezed,
    Object? notice = freezed,
  }) {
    return _then(
      _$CreditPaymentResultImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        paymentEntry: null == paymentEntry
            ? _value.paymentEntry
            : paymentEntry // ignore: cast_nullable_to_non_nullable
                  as String,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAllocated: null == totalAllocated
            ? _value.totalAllocated
            : totalAllocated // ignore: cast_nullable_to_non_nullable
                  as double,
        unallocatedAmount: null == unallocatedAmount
            ? _value.unallocatedAmount
            : unallocatedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        remainingBalance: freezed == remainingBalance
            ? _value.remainingBalance
            : remainingBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        allocations: null == allocations
            ? _value._allocations
            : allocations // ignore: cast_nullable_to_non_nullable
                  as List<CreditPaymentAllocation>,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        alreadyRecorded: null == alreadyRecorded
            ? _value.alreadyRecorded
            : alreadyRecorded // ignore: cast_nullable_to_non_nullable
                  as bool,
        noticeCode: freezed == noticeCode
            ? _value.noticeCode
            : noticeCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        notice: freezed == notice
            ? _value.notice
            : notice // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditPaymentResultImpl extends _CreditPaymentResult {
  const _$CreditPaymentResultImpl({
    this.success = true,
    @JsonKey(name: 'payment_entry') this.paymentEntry = '',
    this.customer = '',
    @JsonKey(name: 'customer_name') this.customerName = '',
    @JsonKey(name: 'amount', fromJson: creditDouble) this.amount = 0.0,
    @JsonKey(
      name: 'total_allocated',
      readValue: readTotalAllocated,
      fromJson: creditDouble,
    )
    this.totalAllocated = 0.0,
    @JsonKey(
      name: 'unallocated_amount',
      readValue: readUnallocatedAmount,
      fromJson: creditDouble,
    )
    this.unallocatedAmount = 0.0,
    @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
    this.remainingBalance,
    @JsonKey(name: 'allocations', readValue: readAllocations)
    final List<CreditPaymentAllocation> allocations =
        const <CreditPaymentAllocation>[],
    this.currency = '',
    @JsonKey(name: 'already_recorded', fromJson: creditBool)
    this.alreadyRecorded = false,
    @JsonKey(name: 'notice_code') this.noticeCode,
    this.notice,
  }) : _allocations = allocations,
       super._();

  factory _$CreditPaymentResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditPaymentResultImplFromJson(json);

  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey(name: 'payment_entry')
  final String paymentEntry;
  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey(name: 'customer_name')
  final String customerName;
  @override
  @JsonKey(name: 'amount', fromJson: creditDouble)
  final double amount;
  @override
  @JsonKey(
    name: 'total_allocated',
    readValue: readTotalAllocated,
    fromJson: creditDouble,
  )
  final double totalAllocated;

  /// The excess left sitting as an unallocated advance on the customer.
  @override
  @JsonKey(
    name: 'unallocated_amount',
    readValue: readUnallocatedAmount,
    fromJson: creditDouble,
  )
  final double unallocatedAmount;

  /// Remaining balance after the payment, when the backend reports it.
  @override
  @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
  final double? remainingBalance;
  final List<CreditPaymentAllocation> _allocations;
  @override
  @JsonKey(name: 'allocations', readValue: readAllocations)
  List<CreditPaymentAllocation> get allocations {
    if (_allocations is EqualUnmodifiableListView) return _allocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allocations);
  }

  @override
  @JsonKey()
  final String currency;

  /// The replay branch: this exact attempt was already posted, so the server
  /// returned the ORIGINAL Payment Entry and did nothing.
  ///
  /// That response carries no `allocations`, no `unallocated_amount` and no
  /// `remaining_balance` — every field the result dialog is built from. Not
  /// parsing these three keys is what made a replay render a title, an id and
  /// nothing else, which is exactly the blank screen that earns a third tap
  /// and, before the token existed, a third payment.
  @override
  @JsonKey(name: 'already_recorded', fromJson: creditBool)
  final bool alreadyRecorded;
  @override
  @JsonKey(name: 'notice_code')
  final String? noticeCode;
  @override
  final String? notice;

  @override
  String toString() {
    return 'CreditPaymentResult(success: $success, paymentEntry: $paymentEntry, customer: $customer, customerName: $customerName, amount: $amount, totalAllocated: $totalAllocated, unallocatedAmount: $unallocatedAmount, remainingBalance: $remainingBalance, allocations: $allocations, currency: $currency, alreadyRecorded: $alreadyRecorded, noticeCode: $noticeCode, notice: $notice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditPaymentResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.paymentEntry, paymentEntry) ||
                other.paymentEntry == paymentEntry) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.totalAllocated, totalAllocated) ||
                other.totalAllocated == totalAllocated) &&
            (identical(other.unallocatedAmount, unallocatedAmount) ||
                other.unallocatedAmount == unallocatedAmount) &&
            (identical(other.remainingBalance, remainingBalance) ||
                other.remainingBalance == remainingBalance) &&
            const DeepCollectionEquality().equals(
              other._allocations,
              _allocations,
            ) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.alreadyRecorded, alreadyRecorded) ||
                other.alreadyRecorded == alreadyRecorded) &&
            (identical(other.noticeCode, noticeCode) ||
                other.noticeCode == noticeCode) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    paymentEntry,
    customer,
    customerName,
    amount,
    totalAllocated,
    unallocatedAmount,
    remainingBalance,
    const DeepCollectionEquality().hash(_allocations),
    currency,
    alreadyRecorded,
    noticeCode,
    notice,
  );

  /// Create a copy of CreditPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditPaymentResultImplCopyWith<_$CreditPaymentResultImpl> get copyWith =>
      __$$CreditPaymentResultImplCopyWithImpl<_$CreditPaymentResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditPaymentResultImplToJson(this);
  }
}

abstract class _CreditPaymentResult extends CreditPaymentResult {
  const factory _CreditPaymentResult({
    final bool success,
    @JsonKey(name: 'payment_entry') final String paymentEntry,
    final String customer,
    @JsonKey(name: 'customer_name') final String customerName,
    @JsonKey(name: 'amount', fromJson: creditDouble) final double amount,
    @JsonKey(
      name: 'total_allocated',
      readValue: readTotalAllocated,
      fromJson: creditDouble,
    )
    final double totalAllocated,
    @JsonKey(
      name: 'unallocated_amount',
      readValue: readUnallocatedAmount,
      fromJson: creditDouble,
    )
    final double unallocatedAmount,
    @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
    final double? remainingBalance,
    @JsonKey(name: 'allocations', readValue: readAllocations)
    final List<CreditPaymentAllocation> allocations,
    final String currency,
    @JsonKey(name: 'already_recorded', fromJson: creditBool)
    final bool alreadyRecorded,
    @JsonKey(name: 'notice_code') final String? noticeCode,
    final String? notice,
  }) = _$CreditPaymentResultImpl;
  const _CreditPaymentResult._() : super._();

  factory _CreditPaymentResult.fromJson(Map<String, dynamic> json) =
      _$CreditPaymentResultImpl.fromJson;

  @override
  bool get success;
  @override
  @JsonKey(name: 'payment_entry')
  String get paymentEntry;
  @override
  String get customer;
  @override
  @JsonKey(name: 'customer_name')
  String get customerName;
  @override
  @JsonKey(name: 'amount', fromJson: creditDouble)
  double get amount;
  @override
  @JsonKey(
    name: 'total_allocated',
    readValue: readTotalAllocated,
    fromJson: creditDouble,
  )
  double get totalAllocated;

  /// The excess left sitting as an unallocated advance on the customer.
  @override
  @JsonKey(
    name: 'unallocated_amount',
    readValue: readUnallocatedAmount,
    fromJson: creditDouble,
  )
  double get unallocatedAmount;

  /// Remaining balance after the payment, when the backend reports it.
  @override
  @JsonKey(name: 'remaining_balance', fromJson: creditDoubleOrNull)
  double? get remainingBalance;
  @override
  @JsonKey(name: 'allocations', readValue: readAllocations)
  List<CreditPaymentAllocation> get allocations;
  @override
  String get currency;

  /// The replay branch: this exact attempt was already posted, so the server
  /// returned the ORIGINAL Payment Entry and did nothing.
  ///
  /// That response carries no `allocations`, no `unallocated_amount` and no
  /// `remaining_balance` — every field the result dialog is built from. Not
  /// parsing these three keys is what made a replay render a title, an id and
  /// nothing else, which is exactly the blank screen that earns a third tap
  /// and, before the token existed, a third payment.
  @override
  @JsonKey(name: 'already_recorded', fromJson: creditBool)
  bool get alreadyRecorded;
  @override
  @JsonKey(name: 'notice_code')
  String? get noticeCode;
  @override
  String? get notice;

  /// Create a copy of CreditPaymentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditPaymentResultImplCopyWith<_$CreditPaymentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

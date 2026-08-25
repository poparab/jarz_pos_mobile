// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JourneyAction _$JourneyActionFromJson(Map<String, dynamic> json) {
  return _JourneyAction.fromJson(json);
}

/// @nodoc
mixin _$JourneyAction {
  /// 'journey' | 'followup'.
  String get source => throw _privateConstructorUsedError;

  /// The journey note behind this action; empty when [source] is 'followup'.
  String get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_name')
  String get referenceName => throw _privateConstructorUsedError;

  /// The account's display name — what the rep recognises, not the id.
  String get title => throw _privateConstructorUsedError;

  /// Due date, ISO `yyyy-MM-dd`.
  String get date => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_person')
  String get contactPerson => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_type')
  String get entryType => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;

  /// Past due AND not done — the server decides against ITS clock, which is
  /// the one the reminders run on.
  bool get overdue => throw _privateConstructorUsedError;
  String get owner => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_name')
  String get ownerName => throw _privateConstructorUsedError;

  /// Whether the CURRENT user may tick this off from the calendar.
  @JsonKey(name: 'can_complete')
  bool get canComplete => throw _privateConstructorUsedError;

  /// Serializes this JourneyAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyActionCopyWith<JourneyAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyActionCopyWith<$Res> {
  factory $JourneyActionCopyWith(
    JourneyAction value,
    $Res Function(JourneyAction) then,
  ) = _$JourneyActionCopyWithImpl<$Res, JourneyAction>;
  @useResult
  $Res call({
    String source,
    String note,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    String date,
    String action,
    @JsonKey(name: 'contact_person') String contactPerson,
    @JsonKey(name: 'entry_type') String entryType,
    bool done,
    bool overdue,
    String owner,
    @JsonKey(name: 'owner_name') String ownerName,
    @JsonKey(name: 'can_complete') bool canComplete,
  });
}

/// @nodoc
class _$JourneyActionCopyWithImpl<$Res, $Val extends JourneyAction>
    implements $JourneyActionCopyWith<$Res> {
  _$JourneyActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? note = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? date = null,
    Object? action = null,
    Object? contactPerson = null,
    Object? entryType = null,
    Object? done = null,
    Object? overdue = null,
    Object? owner = null,
    Object? ownerName = null,
    Object? canComplete = null,
  }) {
    return _then(
      _value.copyWith(
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceDoctype: null == referenceDoctype
                ? _value.referenceDoctype
                : referenceDoctype // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceName: null == referenceName
                ? _value.referenceName
                : referenceName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPerson: null == contactPerson
                ? _value.contactPerson
                : contactPerson // ignore: cast_nullable_to_non_nullable
                      as String,
            entryType: null == entryType
                ? _value.entryType
                : entryType // ignore: cast_nullable_to_non_nullable
                      as String,
            done: null == done
                ? _value.done
                : done // ignore: cast_nullable_to_non_nullable
                      as bool,
            overdue: null == overdue
                ? _value.overdue
                : overdue // ignore: cast_nullable_to_non_nullable
                      as bool,
            owner: null == owner
                ? _value.owner
                : owner // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerName: null == ownerName
                ? _value.ownerName
                : ownerName // ignore: cast_nullable_to_non_nullable
                      as String,
            canComplete: null == canComplete
                ? _value.canComplete
                : canComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JourneyActionImplCopyWith<$Res>
    implements $JourneyActionCopyWith<$Res> {
  factory _$$JourneyActionImplCopyWith(
    _$JourneyActionImpl value,
    $Res Function(_$JourneyActionImpl) then,
  ) = __$$JourneyActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String source,
    String note,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    String date,
    String action,
    @JsonKey(name: 'contact_person') String contactPerson,
    @JsonKey(name: 'entry_type') String entryType,
    bool done,
    bool overdue,
    String owner,
    @JsonKey(name: 'owner_name') String ownerName,
    @JsonKey(name: 'can_complete') bool canComplete,
  });
}

/// @nodoc
class __$$JourneyActionImplCopyWithImpl<$Res>
    extends _$JourneyActionCopyWithImpl<$Res, _$JourneyActionImpl>
    implements _$$JourneyActionImplCopyWith<$Res> {
  __$$JourneyActionImplCopyWithImpl(
    _$JourneyActionImpl _value,
    $Res Function(_$JourneyActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? note = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? date = null,
    Object? action = null,
    Object? contactPerson = null,
    Object? entryType = null,
    Object? done = null,
    Object? overdue = null,
    Object? owner = null,
    Object? ownerName = null,
    Object? canComplete = null,
  }) {
    return _then(
      _$JourneyActionImpl(
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceDoctype: null == referenceDoctype
            ? _value.referenceDoctype
            : referenceDoctype // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceName: null == referenceName
            ? _value.referenceName
            : referenceName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPerson: null == contactPerson
            ? _value.contactPerson
            : contactPerson // ignore: cast_nullable_to_non_nullable
                  as String,
        entryType: null == entryType
            ? _value.entryType
            : entryType // ignore: cast_nullable_to_non_nullable
                  as String,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
        overdue: null == overdue
            ? _value.overdue
            : overdue // ignore: cast_nullable_to_non_nullable
                  as bool,
        owner: null == owner
            ? _value.owner
            : owner // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerName: null == ownerName
            ? _value.ownerName
            : ownerName // ignore: cast_nullable_to_non_nullable
                  as String,
        canComplete: null == canComplete
            ? _value.canComplete
            : canComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyActionImpl extends _JourneyAction {
  const _$JourneyActionImpl({
    this.source = '',
    this.note = '',
    @JsonKey(name: 'reference_doctype') this.referenceDoctype = '',
    @JsonKey(name: 'reference_name') this.referenceName = '',
    this.title = '',
    this.date = '',
    this.action = '',
    @JsonKey(name: 'contact_person') this.contactPerson = '',
    @JsonKey(name: 'entry_type') this.entryType = '',
    this.done = false,
    this.overdue = false,
    this.owner = '',
    @JsonKey(name: 'owner_name') this.ownerName = '',
    @JsonKey(name: 'can_complete') this.canComplete = false,
  }) : super._();

  factory _$JourneyActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyActionImplFromJson(json);

  /// 'journey' | 'followup'.
  @override
  @JsonKey()
  final String source;

  /// The journey note behind this action; empty when [source] is 'followup'.
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey(name: 'reference_doctype')
  final String referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  final String referenceName;

  /// The account's display name — what the rep recognises, not the id.
  @override
  @JsonKey()
  final String title;

  /// Due date, ISO `yyyy-MM-dd`.
  @override
  @JsonKey()
  final String date;
  @override
  @JsonKey()
  final String action;
  @override
  @JsonKey(name: 'contact_person')
  final String contactPerson;
  @override
  @JsonKey(name: 'entry_type')
  final String entryType;
  @override
  @JsonKey()
  final bool done;

  /// Past due AND not done — the server decides against ITS clock, which is
  /// the one the reminders run on.
  @override
  @JsonKey()
  final bool overdue;
  @override
  @JsonKey()
  final String owner;
  @override
  @JsonKey(name: 'owner_name')
  final String ownerName;

  /// Whether the CURRENT user may tick this off from the calendar.
  @override
  @JsonKey(name: 'can_complete')
  final bool canComplete;

  @override
  String toString() {
    return 'JourneyAction(source: $source, note: $note, referenceDoctype: $referenceDoctype, referenceName: $referenceName, title: $title, date: $date, action: $action, contactPerson: $contactPerson, entryType: $entryType, done: $done, overdue: $overdue, owner: $owner, ownerName: $ownerName, canComplete: $canComplete)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyActionImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.referenceDoctype, referenceDoctype) ||
                other.referenceDoctype == referenceDoctype) &&
            (identical(other.referenceName, referenceName) ||
                other.referenceName == referenceName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.entryType, entryType) ||
                other.entryType == entryType) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.overdue, overdue) || other.overdue == overdue) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.canComplete, canComplete) ||
                other.canComplete == canComplete));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    source,
    note,
    referenceDoctype,
    referenceName,
    title,
    date,
    action,
    contactPerson,
    entryType,
    done,
    overdue,
    owner,
    ownerName,
    canComplete,
  );

  /// Create a copy of JourneyAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyActionImplCopyWith<_$JourneyActionImpl> get copyWith =>
      __$$JourneyActionImplCopyWithImpl<_$JourneyActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyActionImplToJson(this);
  }
}

abstract class _JourneyAction extends JourneyAction {
  const factory _JourneyAction({
    final String source,
    final String note,
    @JsonKey(name: 'reference_doctype') final String referenceDoctype,
    @JsonKey(name: 'reference_name') final String referenceName,
    final String title,
    final String date,
    final String action,
    @JsonKey(name: 'contact_person') final String contactPerson,
    @JsonKey(name: 'entry_type') final String entryType,
    final bool done,
    final bool overdue,
    final String owner,
    @JsonKey(name: 'owner_name') final String ownerName,
    @JsonKey(name: 'can_complete') final bool canComplete,
  }) = _$JourneyActionImpl;
  const _JourneyAction._() : super._();

  factory _JourneyAction.fromJson(Map<String, dynamic> json) =
      _$JourneyActionImpl.fromJson;

  /// 'journey' | 'followup'.
  @override
  String get source;

  /// The journey note behind this action; empty when [source] is 'followup'.
  @override
  String get note;
  @override
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  String get referenceName;

  /// The account's display name — what the rep recognises, not the id.
  @override
  String get title;

  /// Due date, ISO `yyyy-MM-dd`.
  @override
  String get date;
  @override
  String get action;
  @override
  @JsonKey(name: 'contact_person')
  String get contactPerson;
  @override
  @JsonKey(name: 'entry_type')
  String get entryType;
  @override
  bool get done;

  /// Past due AND not done — the server decides against ITS clock, which is
  /// the one the reminders run on.
  @override
  bool get overdue;
  @override
  String get owner;
  @override
  @JsonKey(name: 'owner_name')
  String get ownerName;

  /// Whether the CURRENT user may tick this off from the calendar.
  @override
  @JsonKey(name: 'can_complete')
  bool get canComplete;

  /// Create a copy of JourneyAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyActionImplCopyWith<_$JourneyActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JourneyActionCounts _$JourneyActionCountsFromJson(Map<String, dynamic> json) {
  return _JourneyActionCounts.fromJson(json);
}

/// @nodoc
mixin _$JourneyActionCounts {
  int get pending => throw _privateConstructorUsedError;
  int get overdue => throw _privateConstructorUsedError;
  int get done => throw _privateConstructorUsedError;

  /// Serializes this JourneyActionCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyActionCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyActionCountsCopyWith<JourneyActionCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyActionCountsCopyWith<$Res> {
  factory $JourneyActionCountsCopyWith(
    JourneyActionCounts value,
    $Res Function(JourneyActionCounts) then,
  ) = _$JourneyActionCountsCopyWithImpl<$Res, JourneyActionCounts>;
  @useResult
  $Res call({int pending, int overdue, int done});
}

/// @nodoc
class _$JourneyActionCountsCopyWithImpl<$Res, $Val extends JourneyActionCounts>
    implements $JourneyActionCountsCopyWith<$Res> {
  _$JourneyActionCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyActionCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pending = null,
    Object? overdue = null,
    Object? done = null,
  }) {
    return _then(
      _value.copyWith(
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int,
            overdue: null == overdue
                ? _value.overdue
                : overdue // ignore: cast_nullable_to_non_nullable
                      as int,
            done: null == done
                ? _value.done
                : done // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JourneyActionCountsImplCopyWith<$Res>
    implements $JourneyActionCountsCopyWith<$Res> {
  factory _$$JourneyActionCountsImplCopyWith(
    _$JourneyActionCountsImpl value,
    $Res Function(_$JourneyActionCountsImpl) then,
  ) = __$$JourneyActionCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pending, int overdue, int done});
}

/// @nodoc
class __$$JourneyActionCountsImplCopyWithImpl<$Res>
    extends _$JourneyActionCountsCopyWithImpl<$Res, _$JourneyActionCountsImpl>
    implements _$$JourneyActionCountsImplCopyWith<$Res> {
  __$$JourneyActionCountsImplCopyWithImpl(
    _$JourneyActionCountsImpl _value,
    $Res Function(_$JourneyActionCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyActionCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pending = null,
    Object? overdue = null,
    Object? done = null,
  }) {
    return _then(
      _$JourneyActionCountsImpl(
        pending: null == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int,
        overdue: null == overdue
            ? _value.overdue
            : overdue // ignore: cast_nullable_to_non_nullable
                  as int,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyActionCountsImpl extends _JourneyActionCounts {
  const _$JourneyActionCountsImpl({
    this.pending = 0,
    this.overdue = 0,
    this.done = 0,
  }) : super._();

  factory _$JourneyActionCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyActionCountsImplFromJson(json);

  @override
  @JsonKey()
  final int pending;
  @override
  @JsonKey()
  final int overdue;
  @override
  @JsonKey()
  final int done;

  @override
  String toString() {
    return 'JourneyActionCounts(pending: $pending, overdue: $overdue, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyActionCountsImpl &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.overdue, overdue) || other.overdue == overdue) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pending, overdue, done);

  /// Create a copy of JourneyActionCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyActionCountsImplCopyWith<_$JourneyActionCountsImpl> get copyWith =>
      __$$JourneyActionCountsImplCopyWithImpl<_$JourneyActionCountsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyActionCountsImplToJson(this);
  }
}

abstract class _JourneyActionCounts extends JourneyActionCounts {
  const factory _JourneyActionCounts({
    final int pending,
    final int overdue,
    final int done,
  }) = _$JourneyActionCountsImpl;
  const _JourneyActionCounts._() : super._();

  factory _JourneyActionCounts.fromJson(Map<String, dynamic> json) =
      _$JourneyActionCountsImpl.fromJson;

  @override
  int get pending;
  @override
  int get overdue;
  @override
  int get done;

  /// Create a copy of JourneyActionCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyActionCountsImplCopyWith<_$JourneyActionCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JourneyActionCalendar _$JourneyActionCalendarFromJson(
  Map<String, dynamic> json,
) {
  return _JourneyActionCalendar.fromJson(json);
}

/// @nodoc
mixin _$JourneyActionCalendar {
  @JsonKey(name: 'from_date')
  String get fromDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_date')
  String get toDate => throw _privateConstructorUsedError;

  /// 'mine' | 'all' — echoed back so the screen can trust that what it
  /// rendered is what it asked for.
  String get scope => throw _privateConstructorUsedError;
  List<JourneyAction> get actions => throw _privateConstructorUsedError;
  JourneyActionCounts get counts => throw _privateConstructorUsedError;

  /// Serializes this JourneyActionCalendar to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyActionCalendarCopyWith<JourneyActionCalendar> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyActionCalendarCopyWith<$Res> {
  factory $JourneyActionCalendarCopyWith(
    JourneyActionCalendar value,
    $Res Function(JourneyActionCalendar) then,
  ) = _$JourneyActionCalendarCopyWithImpl<$Res, JourneyActionCalendar>;
  @useResult
  $Res call({
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String toDate,
    String scope,
    List<JourneyAction> actions,
    JourneyActionCounts counts,
  });

  $JourneyActionCountsCopyWith<$Res> get counts;
}

/// @nodoc
class _$JourneyActionCalendarCopyWithImpl<
  $Res,
  $Val extends JourneyActionCalendar
>
    implements $JourneyActionCalendarCopyWith<$Res> {
  _$JourneyActionCalendarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromDate = null,
    Object? toDate = null,
    Object? scope = null,
    Object? actions = null,
    Object? counts = null,
  }) {
    return _then(
      _value.copyWith(
            fromDate: null == fromDate
                ? _value.fromDate
                : fromDate // ignore: cast_nullable_to_non_nullable
                      as String,
            toDate: null == toDate
                ? _value.toDate
                : toDate // ignore: cast_nullable_to_non_nullable
                      as String,
            scope: null == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<JourneyAction>,
            counts: null == counts
                ? _value.counts
                : counts // ignore: cast_nullable_to_non_nullable
                      as JourneyActionCounts,
          )
          as $Val,
    );
  }

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $JourneyActionCountsCopyWith<$Res> get counts {
    return $JourneyActionCountsCopyWith<$Res>(_value.counts, (value) {
      return _then(_value.copyWith(counts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JourneyActionCalendarImplCopyWith<$Res>
    implements $JourneyActionCalendarCopyWith<$Res> {
  factory _$$JourneyActionCalendarImplCopyWith(
    _$JourneyActionCalendarImpl value,
    $Res Function(_$JourneyActionCalendarImpl) then,
  ) = __$$JourneyActionCalendarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'from_date') String fromDate,
    @JsonKey(name: 'to_date') String toDate,
    String scope,
    List<JourneyAction> actions,
    JourneyActionCounts counts,
  });

  @override
  $JourneyActionCountsCopyWith<$Res> get counts;
}

/// @nodoc
class __$$JourneyActionCalendarImplCopyWithImpl<$Res>
    extends
        _$JourneyActionCalendarCopyWithImpl<$Res, _$JourneyActionCalendarImpl>
    implements _$$JourneyActionCalendarImplCopyWith<$Res> {
  __$$JourneyActionCalendarImplCopyWithImpl(
    _$JourneyActionCalendarImpl _value,
    $Res Function(_$JourneyActionCalendarImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromDate = null,
    Object? toDate = null,
    Object? scope = null,
    Object? actions = null,
    Object? counts = null,
  }) {
    return _then(
      _$JourneyActionCalendarImpl(
        fromDate: null == fromDate
            ? _value.fromDate
            : fromDate // ignore: cast_nullable_to_non_nullable
                  as String,
        toDate: null == toDate
            ? _value.toDate
            : toDate // ignore: cast_nullable_to_non_nullable
                  as String,
        scope: null == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<JourneyAction>,
        counts: null == counts
            ? _value.counts
            : counts // ignore: cast_nullable_to_non_nullable
                  as JourneyActionCounts,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyActionCalendarImpl extends _JourneyActionCalendar {
  const _$JourneyActionCalendarImpl({
    @JsonKey(name: 'from_date') this.fromDate = '',
    @JsonKey(name: 'to_date') this.toDate = '',
    this.scope = 'mine',
    final List<JourneyAction> actions = const <JourneyAction>[],
    this.counts = const JourneyActionCounts(),
  }) : _actions = actions,
       super._();

  factory _$JourneyActionCalendarImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyActionCalendarImplFromJson(json);

  @override
  @JsonKey(name: 'from_date')
  final String fromDate;
  @override
  @JsonKey(name: 'to_date')
  final String toDate;

  /// 'mine' | 'all' — echoed back so the screen can trust that what it
  /// rendered is what it asked for.
  @override
  @JsonKey()
  final String scope;
  final List<JourneyAction> _actions;
  @override
  @JsonKey()
  List<JourneyAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  @JsonKey()
  final JourneyActionCounts counts;

  @override
  String toString() {
    return 'JourneyActionCalendar(fromDate: $fromDate, toDate: $toDate, scope: $scope, actions: $actions, counts: $counts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyActionCalendarImpl &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.counts, counts) || other.counts == counts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fromDate,
    toDate,
    scope,
    const DeepCollectionEquality().hash(_actions),
    counts,
  );

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyActionCalendarImplCopyWith<_$JourneyActionCalendarImpl>
  get copyWith =>
      __$$JourneyActionCalendarImplCopyWithImpl<_$JourneyActionCalendarImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyActionCalendarImplToJson(this);
  }
}

abstract class _JourneyActionCalendar extends JourneyActionCalendar {
  const factory _JourneyActionCalendar({
    @JsonKey(name: 'from_date') final String fromDate,
    @JsonKey(name: 'to_date') final String toDate,
    final String scope,
    final List<JourneyAction> actions,
    final JourneyActionCounts counts,
  }) = _$JourneyActionCalendarImpl;
  const _JourneyActionCalendar._() : super._();

  factory _JourneyActionCalendar.fromJson(Map<String, dynamic> json) =
      _$JourneyActionCalendarImpl.fromJson;

  @override
  @JsonKey(name: 'from_date')
  String get fromDate;
  @override
  @JsonKey(name: 'to_date')
  String get toDate;

  /// 'mine' | 'all' — echoed back so the screen can trust that what it
  /// rendered is what it asked for.
  @override
  String get scope;
  @override
  List<JourneyAction> get actions;
  @override
  JourneyActionCounts get counts;

  /// Create a copy of JourneyActionCalendar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyActionCalendarImplCopyWith<_$JourneyActionCalendarImpl>
  get copyWith => throw _privateConstructorUsedError;
}

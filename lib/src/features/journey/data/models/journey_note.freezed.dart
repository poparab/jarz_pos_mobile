// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JourneyNote _$JourneyNoteFromJson(Map<String, dynamic> json) {
  return _JourneyNote.fromJson(json);
}

/// @nodoc
mixin _$JourneyNote {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_name')
  String get referenceName => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_date')
  String? get entryDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_type')
  String get entryType => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_person')
  String get contactPerson => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_role')
  String get contactRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action')
  String get nextAction => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate => throw _privateConstructorUsedError;
  String get outcome => throw _privateConstructorUsedError;
  @JsonKey(name: 'logged_by')
  String get loggedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'logged_by_name')
  String get loggedByName => throw _privateConstructorUsedError;
  String? get creation => throw _privateConstructorUsedError;
  String? get modified => throw _privateConstructorUsedError;

  /// Whether the CURRENT user may edit/delete this note — the server decides
  /// (author or manager), the app only honours the answer.
  @JsonKey(name: 'can_edit')
  bool get canEdit => throw _privateConstructorUsedError;

  /// Whether the promise in [nextAction] has been kept. A done action stops
  /// tinting the card and its reminder stops nagging — closing the loop is
  /// the whole point of writing the promise down.
  @JsonKey(name: 'next_action_done')
  bool get nextActionDone => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_done_on')
  String? get nextActionDoneOn => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_done_by')
  String get nextActionDoneBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_action_done_by_name')
  String get nextActionDoneByName => throw _privateConstructorUsedError;

  /// Whether the CURRENT user may tick the next action off. Separate from
  /// [canEdit] because a colleague may close a promise they did not write;
  /// the server decides, the app only honours the answer.
  @JsonKey(name: 'can_complete')
  bool get canComplete => throw _privateConstructorUsedError;

  /// Serializes this JourneyNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyNoteCopyWith<JourneyNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyNoteCopyWith<$Res> {
  factory $JourneyNoteCopyWith(
    JourneyNote value,
    $Res Function(JourneyNote) then,
  ) = _$JourneyNoteCopyWithImpl<$Res, JourneyNote>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    @JsonKey(name: 'entry_date') String? entryDate,
    @JsonKey(name: 'entry_type') String entryType,
    String note,
    @JsonKey(name: 'contact_person') String contactPerson,
    @JsonKey(name: 'contact_role') String contactRole,
    @JsonKey(name: 'contact_phone') String contactPhone,
    @JsonKey(name: 'next_action') String nextAction,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    String outcome,
    @JsonKey(name: 'logged_by') String loggedBy,
    @JsonKey(name: 'logged_by_name') String loggedByName,
    String? creation,
    String? modified,
    @JsonKey(name: 'can_edit') bool canEdit,
    @JsonKey(name: 'next_action_done') bool nextActionDone,
    @JsonKey(name: 'next_action_done_on') String? nextActionDoneOn,
    @JsonKey(name: 'next_action_done_by') String nextActionDoneBy,
    @JsonKey(name: 'next_action_done_by_name') String nextActionDoneByName,
    @JsonKey(name: 'can_complete') bool canComplete,
  });
}

/// @nodoc
class _$JourneyNoteCopyWithImpl<$Res, $Val extends JourneyNote>
    implements $JourneyNoteCopyWith<$Res> {
  _$JourneyNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? entryDate = freezed,
    Object? entryType = null,
    Object? note = null,
    Object? contactPerson = null,
    Object? contactRole = null,
    Object? contactPhone = null,
    Object? nextAction = null,
    Object? nextActionDate = freezed,
    Object? outcome = null,
    Object? loggedBy = null,
    Object? loggedByName = null,
    Object? creation = freezed,
    Object? modified = freezed,
    Object? canEdit = null,
    Object? nextActionDone = null,
    Object? nextActionDoneOn = freezed,
    Object? nextActionDoneBy = null,
    Object? nextActionDoneByName = null,
    Object? canComplete = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceDoctype: null == referenceDoctype
                ? _value.referenceDoctype
                : referenceDoctype // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceName: null == referenceName
                ? _value.referenceName
                : referenceName // ignore: cast_nullable_to_non_nullable
                      as String,
            entryDate: freezed == entryDate
                ? _value.entryDate
                : entryDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryType: null == entryType
                ? _value.entryType
                : entryType // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPerson: null == contactPerson
                ? _value.contactPerson
                : contactPerson // ignore: cast_nullable_to_non_nullable
                      as String,
            contactRole: null == contactRole
                ? _value.contactRole
                : contactRole // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPhone: null == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
                      as String,
            nextAction: null == nextAction
                ? _value.nextAction
                : nextAction // ignore: cast_nullable_to_non_nullable
                      as String,
            nextActionDate: freezed == nextActionDate
                ? _value.nextActionDate
                : nextActionDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            outcome: null == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as String,
            loggedBy: null == loggedBy
                ? _value.loggedBy
                : loggedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            loggedByName: null == loggedByName
                ? _value.loggedByName
                : loggedByName // ignore: cast_nullable_to_non_nullable
                      as String,
            creation: freezed == creation
                ? _value.creation
                : creation // ignore: cast_nullable_to_non_nullable
                      as String?,
            modified: freezed == modified
                ? _value.modified
                : modified // ignore: cast_nullable_to_non_nullable
                      as String?,
            canEdit: null == canEdit
                ? _value.canEdit
                : canEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextActionDone: null == nextActionDone
                ? _value.nextActionDone
                : nextActionDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextActionDoneOn: freezed == nextActionDoneOn
                ? _value.nextActionDoneOn
                : nextActionDoneOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextActionDoneBy: null == nextActionDoneBy
                ? _value.nextActionDoneBy
                : nextActionDoneBy // ignore: cast_nullable_to_non_nullable
                      as String,
            nextActionDoneByName: null == nextActionDoneByName
                ? _value.nextActionDoneByName
                : nextActionDoneByName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$JourneyNoteImplCopyWith<$Res>
    implements $JourneyNoteCopyWith<$Res> {
  factory _$$JourneyNoteImplCopyWith(
    _$JourneyNoteImpl value,
    $Res Function(_$JourneyNoteImpl) then,
  ) = __$$JourneyNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    @JsonKey(name: 'entry_date') String? entryDate,
    @JsonKey(name: 'entry_type') String entryType,
    String note,
    @JsonKey(name: 'contact_person') String contactPerson,
    @JsonKey(name: 'contact_role') String contactRole,
    @JsonKey(name: 'contact_phone') String contactPhone,
    @JsonKey(name: 'next_action') String nextAction,
    @JsonKey(name: 'next_action_date') String? nextActionDate,
    String outcome,
    @JsonKey(name: 'logged_by') String loggedBy,
    @JsonKey(name: 'logged_by_name') String loggedByName,
    String? creation,
    String? modified,
    @JsonKey(name: 'can_edit') bool canEdit,
    @JsonKey(name: 'next_action_done') bool nextActionDone,
    @JsonKey(name: 'next_action_done_on') String? nextActionDoneOn,
    @JsonKey(name: 'next_action_done_by') String nextActionDoneBy,
    @JsonKey(name: 'next_action_done_by_name') String nextActionDoneByName,
    @JsonKey(name: 'can_complete') bool canComplete,
  });
}

/// @nodoc
class __$$JourneyNoteImplCopyWithImpl<$Res>
    extends _$JourneyNoteCopyWithImpl<$Res, _$JourneyNoteImpl>
    implements _$$JourneyNoteImplCopyWith<$Res> {
  __$$JourneyNoteImplCopyWithImpl(
    _$JourneyNoteImpl _value,
    $Res Function(_$JourneyNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? entryDate = freezed,
    Object? entryType = null,
    Object? note = null,
    Object? contactPerson = null,
    Object? contactRole = null,
    Object? contactPhone = null,
    Object? nextAction = null,
    Object? nextActionDate = freezed,
    Object? outcome = null,
    Object? loggedBy = null,
    Object? loggedByName = null,
    Object? creation = freezed,
    Object? modified = freezed,
    Object? canEdit = null,
    Object? nextActionDone = null,
    Object? nextActionDoneOn = freezed,
    Object? nextActionDoneBy = null,
    Object? nextActionDoneByName = null,
    Object? canComplete = null,
  }) {
    return _then(
      _$JourneyNoteImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceDoctype: null == referenceDoctype
            ? _value.referenceDoctype
            : referenceDoctype // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceName: null == referenceName
            ? _value.referenceName
            : referenceName // ignore: cast_nullable_to_non_nullable
                  as String,
        entryDate: freezed == entryDate
            ? _value.entryDate
            : entryDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryType: null == entryType
            ? _value.entryType
            : entryType // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPerson: null == contactPerson
            ? _value.contactPerson
            : contactPerson // ignore: cast_nullable_to_non_nullable
                  as String,
        contactRole: null == contactRole
            ? _value.contactRole
            : contactRole // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPhone: null == contactPhone
            ? _value.contactPhone
            : contactPhone // ignore: cast_nullable_to_non_nullable
                  as String,
        nextAction: null == nextAction
            ? _value.nextAction
            : nextAction // ignore: cast_nullable_to_non_nullable
                  as String,
        nextActionDate: freezed == nextActionDate
            ? _value.nextActionDate
            : nextActionDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        outcome: null == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as String,
        loggedBy: null == loggedBy
            ? _value.loggedBy
            : loggedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        loggedByName: null == loggedByName
            ? _value.loggedByName
            : loggedByName // ignore: cast_nullable_to_non_nullable
                  as String,
        creation: freezed == creation
            ? _value.creation
            : creation // ignore: cast_nullable_to_non_nullable
                  as String?,
        modified: freezed == modified
            ? _value.modified
            : modified // ignore: cast_nullable_to_non_nullable
                  as String?,
        canEdit: null == canEdit
            ? _value.canEdit
            : canEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextActionDone: null == nextActionDone
            ? _value.nextActionDone
            : nextActionDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextActionDoneOn: freezed == nextActionDoneOn
            ? _value.nextActionDoneOn
            : nextActionDoneOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextActionDoneBy: null == nextActionDoneBy
            ? _value.nextActionDoneBy
            : nextActionDoneBy // ignore: cast_nullable_to_non_nullable
                  as String,
        nextActionDoneByName: null == nextActionDoneByName
            ? _value.nextActionDoneByName
            : nextActionDoneByName // ignore: cast_nullable_to_non_nullable
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
class _$JourneyNoteImpl extends _JourneyNote {
  const _$JourneyNoteImpl({
    required this.name,
    @JsonKey(name: 'reference_doctype') this.referenceDoctype = '',
    @JsonKey(name: 'reference_name') this.referenceName = '',
    @JsonKey(name: 'entry_date') this.entryDate,
    @JsonKey(name: 'entry_type') this.entryType = '',
    this.note = '',
    @JsonKey(name: 'contact_person') this.contactPerson = '',
    @JsonKey(name: 'contact_role') this.contactRole = '',
    @JsonKey(name: 'contact_phone') this.contactPhone = '',
    @JsonKey(name: 'next_action') this.nextAction = '',
    @JsonKey(name: 'next_action_date') this.nextActionDate,
    this.outcome = '',
    @JsonKey(name: 'logged_by') this.loggedBy = '',
    @JsonKey(name: 'logged_by_name') this.loggedByName = '',
    this.creation,
    this.modified,
    @JsonKey(name: 'can_edit') this.canEdit = false,
    @JsonKey(name: 'next_action_done') this.nextActionDone = false,
    @JsonKey(name: 'next_action_done_on') this.nextActionDoneOn,
    @JsonKey(name: 'next_action_done_by') this.nextActionDoneBy = '',
    @JsonKey(name: 'next_action_done_by_name') this.nextActionDoneByName = '',
    @JsonKey(name: 'can_complete') this.canComplete = false,
  }) : super._();

  factory _$JourneyNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyNoteImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'reference_doctype')
  final String referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  final String referenceName;
  @override
  @JsonKey(name: 'entry_date')
  final String? entryDate;
  @override
  @JsonKey(name: 'entry_type')
  final String entryType;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey(name: 'contact_person')
  final String contactPerson;
  @override
  @JsonKey(name: 'contact_role')
  final String contactRole;
  @override
  @JsonKey(name: 'contact_phone')
  final String contactPhone;
  @override
  @JsonKey(name: 'next_action')
  final String nextAction;
  @override
  @JsonKey(name: 'next_action_date')
  final String? nextActionDate;
  @override
  @JsonKey()
  final String outcome;
  @override
  @JsonKey(name: 'logged_by')
  final String loggedBy;
  @override
  @JsonKey(name: 'logged_by_name')
  final String loggedByName;
  @override
  final String? creation;
  @override
  final String? modified;

  /// Whether the CURRENT user may edit/delete this note — the server decides
  /// (author or manager), the app only honours the answer.
  @override
  @JsonKey(name: 'can_edit')
  final bool canEdit;

  /// Whether the promise in [nextAction] has been kept. A done action stops
  /// tinting the card and its reminder stops nagging — closing the loop is
  /// the whole point of writing the promise down.
  @override
  @JsonKey(name: 'next_action_done')
  final bool nextActionDone;
  @override
  @JsonKey(name: 'next_action_done_on')
  final String? nextActionDoneOn;
  @override
  @JsonKey(name: 'next_action_done_by')
  final String nextActionDoneBy;
  @override
  @JsonKey(name: 'next_action_done_by_name')
  final String nextActionDoneByName;

  /// Whether the CURRENT user may tick the next action off. Separate from
  /// [canEdit] because a colleague may close a promise they did not write;
  /// the server decides, the app only honours the answer.
  @override
  @JsonKey(name: 'can_complete')
  final bool canComplete;

  @override
  String toString() {
    return 'JourneyNote(name: $name, referenceDoctype: $referenceDoctype, referenceName: $referenceName, entryDate: $entryDate, entryType: $entryType, note: $note, contactPerson: $contactPerson, contactRole: $contactRole, contactPhone: $contactPhone, nextAction: $nextAction, nextActionDate: $nextActionDate, outcome: $outcome, loggedBy: $loggedBy, loggedByName: $loggedByName, creation: $creation, modified: $modified, canEdit: $canEdit, nextActionDone: $nextActionDone, nextActionDoneOn: $nextActionDoneOn, nextActionDoneBy: $nextActionDoneBy, nextActionDoneByName: $nextActionDoneByName, canComplete: $canComplete)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyNoteImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.referenceDoctype, referenceDoctype) ||
                other.referenceDoctype == referenceDoctype) &&
            (identical(other.referenceName, referenceName) ||
                other.referenceName == referenceName) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.entryType, entryType) ||
                other.entryType == entryType) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.contactRole, contactRole) ||
                other.contactRole == contactRole) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.nextAction, nextAction) ||
                other.nextAction == nextAction) &&
            (identical(other.nextActionDate, nextActionDate) ||
                other.nextActionDate == nextActionDate) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.loggedBy, loggedBy) ||
                other.loggedBy == loggedBy) &&
            (identical(other.loggedByName, loggedByName) ||
                other.loggedByName == loggedByName) &&
            (identical(other.creation, creation) ||
                other.creation == creation) &&
            (identical(other.modified, modified) ||
                other.modified == modified) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            (identical(other.nextActionDone, nextActionDone) ||
                other.nextActionDone == nextActionDone) &&
            (identical(other.nextActionDoneOn, nextActionDoneOn) ||
                other.nextActionDoneOn == nextActionDoneOn) &&
            (identical(other.nextActionDoneBy, nextActionDoneBy) ||
                other.nextActionDoneBy == nextActionDoneBy) &&
            (identical(other.nextActionDoneByName, nextActionDoneByName) ||
                other.nextActionDoneByName == nextActionDoneByName) &&
            (identical(other.canComplete, canComplete) ||
                other.canComplete == canComplete));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    referenceDoctype,
    referenceName,
    entryDate,
    entryType,
    note,
    contactPerson,
    contactRole,
    contactPhone,
    nextAction,
    nextActionDate,
    outcome,
    loggedBy,
    loggedByName,
    creation,
    modified,
    canEdit,
    nextActionDone,
    nextActionDoneOn,
    nextActionDoneBy,
    nextActionDoneByName,
    canComplete,
  ]);

  /// Create a copy of JourneyNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyNoteImplCopyWith<_$JourneyNoteImpl> get copyWith =>
      __$$JourneyNoteImplCopyWithImpl<_$JourneyNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyNoteImplToJson(this);
  }
}

abstract class _JourneyNote extends JourneyNote {
  const factory _JourneyNote({
    required final String name,
    @JsonKey(name: 'reference_doctype') final String referenceDoctype,
    @JsonKey(name: 'reference_name') final String referenceName,
    @JsonKey(name: 'entry_date') final String? entryDate,
    @JsonKey(name: 'entry_type') final String entryType,
    final String note,
    @JsonKey(name: 'contact_person') final String contactPerson,
    @JsonKey(name: 'contact_role') final String contactRole,
    @JsonKey(name: 'contact_phone') final String contactPhone,
    @JsonKey(name: 'next_action') final String nextAction,
    @JsonKey(name: 'next_action_date') final String? nextActionDate,
    final String outcome,
    @JsonKey(name: 'logged_by') final String loggedBy,
    @JsonKey(name: 'logged_by_name') final String loggedByName,
    final String? creation,
    final String? modified,
    @JsonKey(name: 'can_edit') final bool canEdit,
    @JsonKey(name: 'next_action_done') final bool nextActionDone,
    @JsonKey(name: 'next_action_done_on') final String? nextActionDoneOn,
    @JsonKey(name: 'next_action_done_by') final String nextActionDoneBy,
    @JsonKey(name: 'next_action_done_by_name')
    final String nextActionDoneByName,
    @JsonKey(name: 'can_complete') final bool canComplete,
  }) = _$JourneyNoteImpl;
  const _JourneyNote._() : super._();

  factory _JourneyNote.fromJson(Map<String, dynamic> json) =
      _$JourneyNoteImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  String get referenceName;
  @override
  @JsonKey(name: 'entry_date')
  String? get entryDate;
  @override
  @JsonKey(name: 'entry_type')
  String get entryType;
  @override
  String get note;
  @override
  @JsonKey(name: 'contact_person')
  String get contactPerson;
  @override
  @JsonKey(name: 'contact_role')
  String get contactRole;
  @override
  @JsonKey(name: 'contact_phone')
  String get contactPhone;
  @override
  @JsonKey(name: 'next_action')
  String get nextAction;
  @override
  @JsonKey(name: 'next_action_date')
  String? get nextActionDate;
  @override
  String get outcome;
  @override
  @JsonKey(name: 'logged_by')
  String get loggedBy;
  @override
  @JsonKey(name: 'logged_by_name')
  String get loggedByName;
  @override
  String? get creation;
  @override
  String? get modified;

  /// Whether the CURRENT user may edit/delete this note — the server decides
  /// (author or manager), the app only honours the answer.
  @override
  @JsonKey(name: 'can_edit')
  bool get canEdit;

  /// Whether the promise in [nextAction] has been kept. A done action stops
  /// tinting the card and its reminder stops nagging — closing the loop is
  /// the whole point of writing the promise down.
  @override
  @JsonKey(name: 'next_action_done')
  bool get nextActionDone;
  @override
  @JsonKey(name: 'next_action_done_on')
  String? get nextActionDoneOn;
  @override
  @JsonKey(name: 'next_action_done_by')
  String get nextActionDoneBy;
  @override
  @JsonKey(name: 'next_action_done_by_name')
  String get nextActionDoneByName;

  /// Whether the CURRENT user may tick the next action off. Separate from
  /// [canEdit] because a colleague may close a promise they did not write;
  /// the server decides, the app only honours the answer.
  @override
  @JsonKey(name: 'can_complete')
  bool get canComplete;

  /// Create a copy of JourneyNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyNoteImplCopyWith<_$JourneyNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JourneySummary _$JourneySummaryFromJson(Map<String, dynamic> json) {
  return _JourneySummary.fromJson(json);
}

/// @nodoc
mixin _$JourneySummary {
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

  /// Serializes this JourneySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneySummaryCopyWith<JourneySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneySummaryCopyWith<$Res> {
  factory $JourneySummaryCopyWith(
    JourneySummary value,
    $Res Function(JourneySummary) then,
  ) = _$JourneySummaryCopyWithImpl<$Res, JourneySummary>;
  @useResult
  $Res call({
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
class _$JourneySummaryCopyWithImpl<$Res, $Val extends JourneySummary>
    implements $JourneySummaryCopyWith<$Res> {
  _$JourneySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
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
abstract class _$$JourneySummaryImplCopyWith<$Res>
    implements $JourneySummaryCopyWith<$Res> {
  factory _$$JourneySummaryImplCopyWith(
    _$JourneySummaryImpl value,
    $Res Function(_$JourneySummaryImpl) then,
  ) = __$$JourneySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
class __$$JourneySummaryImplCopyWithImpl<$Res>
    extends _$JourneySummaryCopyWithImpl<$Res, _$JourneySummaryImpl>
    implements _$$JourneySummaryImplCopyWith<$Res> {
  __$$JourneySummaryImplCopyWithImpl(
    _$JourneySummaryImpl _value,
    $Res Function(_$JourneySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? journeyCount = null,
    Object? lastJourneyDate = freezed,
    Object? lastJourneyType = freezed,
    Object? lastJourneyNote = freezed,
    Object? lastJourneyContact = freezed,
    Object? nextActionDate = freezed,
    Object? nextAction = freezed,
  }) {
    return _then(
      _$JourneySummaryImpl(
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
class _$JourneySummaryImpl extends _JourneySummary {
  const _$JourneySummaryImpl({
    @JsonKey(name: 'journey_count') this.journeyCount = 0,
    @JsonKey(name: 'last_journey_date') this.lastJourneyDate,
    @JsonKey(name: 'last_journey_type') this.lastJourneyType,
    @JsonKey(name: 'last_journey_note') this.lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') this.lastJourneyContact,
    @JsonKey(name: 'next_action_date') this.nextActionDate,
    @JsonKey(name: 'next_action') this.nextAction,
  }) : super._();

  factory _$JourneySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneySummaryImplFromJson(json);

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
    return 'JourneySummary(journeyCount: $journeyCount, lastJourneyDate: $lastJourneyDate, lastJourneyType: $lastJourneyType, lastJourneyNote: $lastJourneyNote, lastJourneyContact: $lastJourneyContact, nextActionDate: $nextActionDate, nextAction: $nextAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneySummaryImpl &&
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
    journeyCount,
    lastJourneyDate,
    lastJourneyType,
    lastJourneyNote,
    lastJourneyContact,
    nextActionDate,
    nextAction,
  );

  /// Create a copy of JourneySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneySummaryImplCopyWith<_$JourneySummaryImpl> get copyWith =>
      __$$JourneySummaryImplCopyWithImpl<_$JourneySummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneySummaryImplToJson(this);
  }
}

abstract class _JourneySummary extends JourneySummary {
  const factory _JourneySummary({
    @JsonKey(name: 'journey_count') final int journeyCount,
    @JsonKey(name: 'last_journey_date') final String? lastJourneyDate,
    @JsonKey(name: 'last_journey_type') final String? lastJourneyType,
    @JsonKey(name: 'last_journey_note') final String? lastJourneyNote,
    @JsonKey(name: 'last_journey_contact') final String? lastJourneyContact,
    @JsonKey(name: 'next_action_date') final String? nextActionDate,
    @JsonKey(name: 'next_action') final String? nextAction,
  }) = _$JourneySummaryImpl;
  const _JourneySummary._() : super._();

  factory _JourneySummary.fromJson(Map<String, dynamic> json) =
      _$JourneySummaryImpl.fromJson;

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

  /// Create a copy of JourneySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneySummaryImplCopyWith<_$JourneySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JourneyOptions _$JourneyOptionsFromJson(Map<String, dynamic> json) {
  return _JourneyOptions.fromJson(json);
}

/// @nodoc
mixin _$JourneyOptions {
  @JsonKey(name: 'entry_types')
  List<String> get entryTypes => throw _privateConstructorUsedError;
  List<String> get outcomes => throw _privateConstructorUsedError;

  /// Serializes this JourneyOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyOptionsCopyWith<JourneyOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyOptionsCopyWith<$Res> {
  factory $JourneyOptionsCopyWith(
    JourneyOptions value,
    $Res Function(JourneyOptions) then,
  ) = _$JourneyOptionsCopyWithImpl<$Res, JourneyOptions>;
  @useResult
  $Res call({
    @JsonKey(name: 'entry_types') List<String> entryTypes,
    List<String> outcomes,
  });
}

/// @nodoc
class _$JourneyOptionsCopyWithImpl<$Res, $Val extends JourneyOptions>
    implements $JourneyOptionsCopyWith<$Res> {
  _$JourneyOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entryTypes = null, Object? outcomes = null}) {
    return _then(
      _value.copyWith(
            entryTypes: null == entryTypes
                ? _value.entryTypes
                : entryTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            outcomes: null == outcomes
                ? _value.outcomes
                : outcomes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JourneyOptionsImplCopyWith<$Res>
    implements $JourneyOptionsCopyWith<$Res> {
  factory _$$JourneyOptionsImplCopyWith(
    _$JourneyOptionsImpl value,
    $Res Function(_$JourneyOptionsImpl) then,
  ) = __$$JourneyOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'entry_types') List<String> entryTypes,
    List<String> outcomes,
  });
}

/// @nodoc
class __$$JourneyOptionsImplCopyWithImpl<$Res>
    extends _$JourneyOptionsCopyWithImpl<$Res, _$JourneyOptionsImpl>
    implements _$$JourneyOptionsImplCopyWith<$Res> {
  __$$JourneyOptionsImplCopyWithImpl(
    _$JourneyOptionsImpl _value,
    $Res Function(_$JourneyOptionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entryTypes = null, Object? outcomes = null}) {
    return _then(
      _$JourneyOptionsImpl(
        entryTypes: null == entryTypes
            ? _value._entryTypes
            : entryTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        outcomes: null == outcomes
            ? _value._outcomes
            : outcomes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyOptionsImpl implements _JourneyOptions {
  const _$JourneyOptionsImpl({
    @JsonKey(name: 'entry_types')
    final List<String> entryTypes = const <String>[],
    final List<String> outcomes = const <String>[],
  }) : _entryTypes = entryTypes,
       _outcomes = outcomes;

  factory _$JourneyOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyOptionsImplFromJson(json);

  final List<String> _entryTypes;
  @override
  @JsonKey(name: 'entry_types')
  List<String> get entryTypes {
    if (_entryTypes is EqualUnmodifiableListView) return _entryTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entryTypes);
  }

  final List<String> _outcomes;
  @override
  @JsonKey()
  List<String> get outcomes {
    if (_outcomes is EqualUnmodifiableListView) return _outcomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outcomes);
  }

  @override
  String toString() {
    return 'JourneyOptions(entryTypes: $entryTypes, outcomes: $outcomes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyOptionsImpl &&
            const DeepCollectionEquality().equals(
              other._entryTypes,
              _entryTypes,
            ) &&
            const DeepCollectionEquality().equals(other._outcomes, _outcomes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entryTypes),
    const DeepCollectionEquality().hash(_outcomes),
  );

  /// Create a copy of JourneyOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyOptionsImplCopyWith<_$JourneyOptionsImpl> get copyWith =>
      __$$JourneyOptionsImplCopyWithImpl<_$JourneyOptionsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyOptionsImplToJson(this);
  }
}

abstract class _JourneyOptions implements JourneyOptions {
  const factory _JourneyOptions({
    @JsonKey(name: 'entry_types') final List<String> entryTypes,
    final List<String> outcomes,
  }) = _$JourneyOptionsImpl;

  factory _JourneyOptions.fromJson(Map<String, dynamic> json) =
      _$JourneyOptionsImpl.fromJson;

  @override
  @JsonKey(name: 'entry_types')
  List<String> get entryTypes;
  @override
  List<String> get outcomes;

  /// Create a copy of JourneyOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyOptionsImplCopyWith<_$JourneyOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JourneyContacts _$JourneyContactsFromJson(Map<String, dynamic> json) {
  return _JourneyContacts.fromJson(json);
}

/// @nodoc
mixin _$JourneyContacts {
  List<LeadContact> get contacts => throw _privateConstructorUsedError;
  String get lead => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_add')
  bool get canAdd => throw _privateConstructorUsedError;
  LeadContact? get added => throw _privateConstructorUsedError;

  /// Serializes this JourneyContacts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JourneyContactsCopyWith<JourneyContacts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JourneyContactsCopyWith<$Res> {
  factory $JourneyContactsCopyWith(
    JourneyContacts value,
    $Res Function(JourneyContacts) then,
  ) = _$JourneyContactsCopyWithImpl<$Res, JourneyContacts>;
  @useResult
  $Res call({
    List<LeadContact> contacts,
    String lead,
    @JsonKey(name: 'can_add') bool canAdd,
    LeadContact? added,
  });

  $LeadContactCopyWith<$Res>? get added;
}

/// @nodoc
class _$JourneyContactsCopyWithImpl<$Res, $Val extends JourneyContacts>
    implements $JourneyContactsCopyWith<$Res> {
  _$JourneyContactsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? lead = null,
    Object? canAdd = null,
    Object? added = freezed,
  }) {
    return _then(
      _value.copyWith(
            contacts: null == contacts
                ? _value.contacts
                : contacts // ignore: cast_nullable_to_non_nullable
                      as List<LeadContact>,
            lead: null == lead
                ? _value.lead
                : lead // ignore: cast_nullable_to_non_nullable
                      as String,
            canAdd: null == canAdd
                ? _value.canAdd
                : canAdd // ignore: cast_nullable_to_non_nullable
                      as bool,
            added: freezed == added
                ? _value.added
                : added // ignore: cast_nullable_to_non_nullable
                      as LeadContact?,
          )
          as $Val,
    );
  }

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadContactCopyWith<$Res>? get added {
    if (_value.added == null) {
      return null;
    }

    return $LeadContactCopyWith<$Res>(_value.added!, (value) {
      return _then(_value.copyWith(added: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JourneyContactsImplCopyWith<$Res>
    implements $JourneyContactsCopyWith<$Res> {
  factory _$$JourneyContactsImplCopyWith(
    _$JourneyContactsImpl value,
    $Res Function(_$JourneyContactsImpl) then,
  ) = __$$JourneyContactsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<LeadContact> contacts,
    String lead,
    @JsonKey(name: 'can_add') bool canAdd,
    LeadContact? added,
  });

  @override
  $LeadContactCopyWith<$Res>? get added;
}

/// @nodoc
class __$$JourneyContactsImplCopyWithImpl<$Res>
    extends _$JourneyContactsCopyWithImpl<$Res, _$JourneyContactsImpl>
    implements _$$JourneyContactsImplCopyWith<$Res> {
  __$$JourneyContactsImplCopyWithImpl(
    _$JourneyContactsImpl _value,
    $Res Function(_$JourneyContactsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? lead = null,
    Object? canAdd = null,
    Object? added = freezed,
  }) {
    return _then(
      _$JourneyContactsImpl(
        contacts: null == contacts
            ? _value._contacts
            : contacts // ignore: cast_nullable_to_non_nullable
                  as List<LeadContact>,
        lead: null == lead
            ? _value.lead
            : lead // ignore: cast_nullable_to_non_nullable
                  as String,
        canAdd: null == canAdd
            ? _value.canAdd
            : canAdd // ignore: cast_nullable_to_non_nullable
                  as bool,
        added: freezed == added
            ? _value.added
            : added // ignore: cast_nullable_to_non_nullable
                  as LeadContact?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JourneyContactsImpl extends _JourneyContacts {
  const _$JourneyContactsImpl({
    final List<LeadContact> contacts = const <LeadContact>[],
    this.lead = '',
    @JsonKey(name: 'can_add') this.canAdd = false,
    this.added,
  }) : _contacts = contacts,
       super._();

  factory _$JourneyContactsImpl.fromJson(Map<String, dynamic> json) =>
      _$$JourneyContactsImplFromJson(json);

  final List<LeadContact> _contacts;
  @override
  @JsonKey()
  List<LeadContact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  @JsonKey()
  final String lead;
  @override
  @JsonKey(name: 'can_add')
  final bool canAdd;
  @override
  final LeadContact? added;

  @override
  String toString() {
    return 'JourneyContacts(contacts: $contacts, lead: $lead, canAdd: $canAdd, added: $added)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JourneyContactsImpl &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.lead, lead) || other.lead == lead) &&
            (identical(other.canAdd, canAdd) || other.canAdd == canAdd) &&
            (identical(other.added, added) || other.added == added));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_contacts),
    lead,
    canAdd,
    added,
  );

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JourneyContactsImplCopyWith<_$JourneyContactsImpl> get copyWith =>
      __$$JourneyContactsImplCopyWithImpl<_$JourneyContactsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JourneyContactsImplToJson(this);
  }
}

abstract class _JourneyContacts extends JourneyContacts {
  const factory _JourneyContacts({
    final List<LeadContact> contacts,
    final String lead,
    @JsonKey(name: 'can_add') final bool canAdd,
    final LeadContact? added,
  }) = _$JourneyContactsImpl;
  const _JourneyContacts._() : super._();

  factory _JourneyContacts.fromJson(Map<String, dynamic> json) =
      _$JourneyContactsImpl.fromJson;

  @override
  List<LeadContact> get contacts;
  @override
  String get lead;
  @override
  @JsonKey(name: 'can_add')
  bool get canAdd;
  @override
  LeadContact? get added;

  /// Create a copy of JourneyContacts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JourneyContactsImplCopyWith<_$JourneyContactsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

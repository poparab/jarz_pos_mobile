// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VisitPlan _$VisitPlanFromJson(Map<String, dynamic> json) {
  return _VisitPlan.fromJson(json);
}

/// @nodoc
mixin _$VisitPlan {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'visit_date')
  String? get visitDate => throw _privateConstructorUsedError;
  String get rep => throw _privateConstructorUsedError;
  @JsonKey(name: 'rep_name')
  String get repName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_mode')
  String get startMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_label')
  String get startLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_latitude')
  double? get startLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_longitude')
  double? get startLongitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_start_time')
  String? get plannedStartTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_visit_minutes')
  int get defaultVisitMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'return_to_start', fromJson: _flag)
  bool get returnToStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_stops')
  int get totalStops => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_drive_minutes')
  int get totalDriveMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_duration_minutes')
  int get totalDurationMinutes => throw _privateConstructorUsedError;

  /// 'osrm' = real road distances, 'haversine' = straight-line estimate.
  /// Shown on the screen because it changes what the numbers mean.
  @JsonKey(name: 'route_engine')
  String get routeEngine => throw _privateConstructorUsedError;
  @JsonKey(name: 'optimized_on')
  String? get optimizedOn => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_edit', fromJson: _flagTrue)
  bool get canEdit => throw _privateConstructorUsedError;
  List<VisitStop> get stops => throw _privateConstructorUsedError;

  /// Road path through the stops, `[[lat, lng], ...]`. Null whenever OSRM is
  /// not in play; the map then draws straight legs between stops instead.
  @JsonKey(name: 'geometry')
  List<List<double>>? get geometry => throw _privateConstructorUsedError;

  /// Serializes this VisitPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitPlanCopyWith<VisitPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitPlanCopyWith<$Res> {
  factory $VisitPlanCopyWith(VisitPlan value, $Res Function(VisitPlan) then) =
      _$VisitPlanCopyWithImpl<$Res, VisitPlan>;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'visit_date') String? visitDate,
    String rep,
    @JsonKey(name: 'rep_name') String repName,
    String title,
    String status,
    @JsonKey(name: 'start_mode') String startMode,
    @JsonKey(name: 'start_label') String startLabel,
    @JsonKey(name: 'start_latitude') double? startLatitude,
    @JsonKey(name: 'start_longitude') double? startLongitude,
    @JsonKey(name: 'planned_start_time') String? plannedStartTime,
    @JsonKey(name: 'default_visit_minutes') int defaultVisitMinutes,
    @JsonKey(name: 'return_to_start', fromJson: _flag) bool returnToStart,
    @JsonKey(name: 'total_stops') int totalStops,
    @JsonKey(name: 'total_distance_km') double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') int totalDurationMinutes,
    @JsonKey(name: 'route_engine') String routeEngine,
    @JsonKey(name: 'optimized_on') String? optimizedOn,
    String notes,
    @JsonKey(name: 'can_edit', fromJson: _flagTrue) bool canEdit,
    List<VisitStop> stops,
    @JsonKey(name: 'geometry') List<List<double>>? geometry,
  });
}

/// @nodoc
class _$VisitPlanCopyWithImpl<$Res, $Val extends VisitPlan>
    implements $VisitPlanCopyWith<$Res> {
  _$VisitPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? visitDate = freezed,
    Object? rep = null,
    Object? repName = null,
    Object? title = null,
    Object? status = null,
    Object? startMode = null,
    Object? startLabel = null,
    Object? startLatitude = freezed,
    Object? startLongitude = freezed,
    Object? plannedStartTime = freezed,
    Object? defaultVisitMinutes = null,
    Object? returnToStart = null,
    Object? totalStops = null,
    Object? totalDistanceKm = null,
    Object? totalDriveMinutes = null,
    Object? totalDurationMinutes = null,
    Object? routeEngine = null,
    Object? optimizedOn = freezed,
    Object? notes = null,
    Object? canEdit = null,
    Object? stops = null,
    Object? geometry = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            visitDate: freezed == visitDate
                ? _value.visitDate
                : visitDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            rep: null == rep
                ? _value.rep
                : rep // ignore: cast_nullable_to_non_nullable
                      as String,
            repName: null == repName
                ? _value.repName
                : repName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            startMode: null == startMode
                ? _value.startMode
                : startMode // ignore: cast_nullable_to_non_nullable
                      as String,
            startLabel: null == startLabel
                ? _value.startLabel
                : startLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            startLatitude: freezed == startLatitude
                ? _value.startLatitude
                : startLatitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            startLongitude: freezed == startLongitude
                ? _value.startLongitude
                : startLongitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            plannedStartTime: freezed == plannedStartTime
                ? _value.plannedStartTime
                : plannedStartTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultVisitMinutes: null == defaultVisitMinutes
                ? _value.defaultVisitMinutes
                : defaultVisitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            returnToStart: null == returnToStart
                ? _value.returnToStart
                : returnToStart // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalStops: null == totalStops
                ? _value.totalStops
                : totalStops // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDistanceKm: null == totalDistanceKm
                ? _value.totalDistanceKm
                : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDriveMinutes: null == totalDriveMinutes
                ? _value.totalDriveMinutes
                : totalDriveMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDurationMinutes: null == totalDurationMinutes
                ? _value.totalDurationMinutes
                : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            routeEngine: null == routeEngine
                ? _value.routeEngine
                : routeEngine // ignore: cast_nullable_to_non_nullable
                      as String,
            optimizedOn: freezed == optimizedOn
                ? _value.optimizedOn
                : optimizedOn // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            canEdit: null == canEdit
                ? _value.canEdit
                : canEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
            stops: null == stops
                ? _value.stops
                : stops // ignore: cast_nullable_to_non_nullable
                      as List<VisitStop>,
            geometry: freezed == geometry
                ? _value.geometry
                : geometry // ignore: cast_nullable_to_non_nullable
                      as List<List<double>>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitPlanImplCopyWith<$Res>
    implements $VisitPlanCopyWith<$Res> {
  factory _$$VisitPlanImplCopyWith(
    _$VisitPlanImpl value,
    $Res Function(_$VisitPlanImpl) then,
  ) = __$$VisitPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'visit_date') String? visitDate,
    String rep,
    @JsonKey(name: 'rep_name') String repName,
    String title,
    String status,
    @JsonKey(name: 'start_mode') String startMode,
    @JsonKey(name: 'start_label') String startLabel,
    @JsonKey(name: 'start_latitude') double? startLatitude,
    @JsonKey(name: 'start_longitude') double? startLongitude,
    @JsonKey(name: 'planned_start_time') String? plannedStartTime,
    @JsonKey(name: 'default_visit_minutes') int defaultVisitMinutes,
    @JsonKey(name: 'return_to_start', fromJson: _flag) bool returnToStart,
    @JsonKey(name: 'total_stops') int totalStops,
    @JsonKey(name: 'total_distance_km') double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') int totalDurationMinutes,
    @JsonKey(name: 'route_engine') String routeEngine,
    @JsonKey(name: 'optimized_on') String? optimizedOn,
    String notes,
    @JsonKey(name: 'can_edit', fromJson: _flagTrue) bool canEdit,
    List<VisitStop> stops,
    @JsonKey(name: 'geometry') List<List<double>>? geometry,
  });
}

/// @nodoc
class __$$VisitPlanImplCopyWithImpl<$Res>
    extends _$VisitPlanCopyWithImpl<$Res, _$VisitPlanImpl>
    implements _$$VisitPlanImplCopyWith<$Res> {
  __$$VisitPlanImplCopyWithImpl(
    _$VisitPlanImpl _value,
    $Res Function(_$VisitPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? visitDate = freezed,
    Object? rep = null,
    Object? repName = null,
    Object? title = null,
    Object? status = null,
    Object? startMode = null,
    Object? startLabel = null,
    Object? startLatitude = freezed,
    Object? startLongitude = freezed,
    Object? plannedStartTime = freezed,
    Object? defaultVisitMinutes = null,
    Object? returnToStart = null,
    Object? totalStops = null,
    Object? totalDistanceKm = null,
    Object? totalDriveMinutes = null,
    Object? totalDurationMinutes = null,
    Object? routeEngine = null,
    Object? optimizedOn = freezed,
    Object? notes = null,
    Object? canEdit = null,
    Object? stops = null,
    Object? geometry = freezed,
  }) {
    return _then(
      _$VisitPlanImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        visitDate: freezed == visitDate
            ? _value.visitDate
            : visitDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        rep: null == rep
            ? _value.rep
            : rep // ignore: cast_nullable_to_non_nullable
                  as String,
        repName: null == repName
            ? _value.repName
            : repName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        startMode: null == startMode
            ? _value.startMode
            : startMode // ignore: cast_nullable_to_non_nullable
                  as String,
        startLabel: null == startLabel
            ? _value.startLabel
            : startLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        startLatitude: freezed == startLatitude
            ? _value.startLatitude
            : startLatitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        startLongitude: freezed == startLongitude
            ? _value.startLongitude
            : startLongitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        plannedStartTime: freezed == plannedStartTime
            ? _value.plannedStartTime
            : plannedStartTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultVisitMinutes: null == defaultVisitMinutes
            ? _value.defaultVisitMinutes
            : defaultVisitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        returnToStart: null == returnToStart
            ? _value.returnToStart
            : returnToStart // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalStops: null == totalStops
            ? _value.totalStops
            : totalStops // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDistanceKm: null == totalDistanceKm
            ? _value.totalDistanceKm
            : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDriveMinutes: null == totalDriveMinutes
            ? _value.totalDriveMinutes
            : totalDriveMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDurationMinutes: null == totalDurationMinutes
            ? _value.totalDurationMinutes
            : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        routeEngine: null == routeEngine
            ? _value.routeEngine
            : routeEngine // ignore: cast_nullable_to_non_nullable
                  as String,
        optimizedOn: freezed == optimizedOn
            ? _value.optimizedOn
            : optimizedOn // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        canEdit: null == canEdit
            ? _value.canEdit
            : canEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
        stops: null == stops
            ? _value._stops
            : stops // ignore: cast_nullable_to_non_nullable
                  as List<VisitStop>,
        geometry: freezed == geometry
            ? _value._geometry
            : geometry // ignore: cast_nullable_to_non_nullable
                  as List<List<double>>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitPlanImpl extends _VisitPlan {
  const _$VisitPlanImpl({
    required this.name,
    @JsonKey(name: 'visit_date') this.visitDate,
    this.rep = '',
    @JsonKey(name: 'rep_name') this.repName = '',
    this.title = '',
    this.status = 'Draft',
    @JsonKey(name: 'start_mode') this.startMode = 'Current Location',
    @JsonKey(name: 'start_label') this.startLabel = '',
    @JsonKey(name: 'start_latitude') this.startLatitude,
    @JsonKey(name: 'start_longitude') this.startLongitude,
    @JsonKey(name: 'planned_start_time') this.plannedStartTime,
    @JsonKey(name: 'default_visit_minutes') this.defaultVisitMinutes = 20,
    @JsonKey(name: 'return_to_start', fromJson: _flag)
    this.returnToStart = false,
    @JsonKey(name: 'total_stops') this.totalStops = 0,
    @JsonKey(name: 'total_distance_km') this.totalDistanceKm = 0.0,
    @JsonKey(name: 'total_drive_minutes') this.totalDriveMinutes = 0,
    @JsonKey(name: 'total_duration_minutes') this.totalDurationMinutes = 0,
    @JsonKey(name: 'route_engine') this.routeEngine = 'haversine',
    @JsonKey(name: 'optimized_on') this.optimizedOn,
    this.notes = '',
    @JsonKey(name: 'can_edit', fromJson: _flagTrue) this.canEdit = true,
    final List<VisitStop> stops = const <VisitStop>[],
    @JsonKey(name: 'geometry') final List<List<double>>? geometry,
  }) : _stops = stops,
       _geometry = geometry,
       super._();

  factory _$VisitPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitPlanImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'visit_date')
  final String? visitDate;
  @override
  @JsonKey()
  final String rep;
  @override
  @JsonKey(name: 'rep_name')
  final String repName;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'start_mode')
  final String startMode;
  @override
  @JsonKey(name: 'start_label')
  final String startLabel;
  @override
  @JsonKey(name: 'start_latitude')
  final double? startLatitude;
  @override
  @JsonKey(name: 'start_longitude')
  final double? startLongitude;
  @override
  @JsonKey(name: 'planned_start_time')
  final String? plannedStartTime;
  @override
  @JsonKey(name: 'default_visit_minutes')
  final int defaultVisitMinutes;
  @override
  @JsonKey(name: 'return_to_start', fromJson: _flag)
  final bool returnToStart;
  @override
  @JsonKey(name: 'total_stops')
  final int totalStops;
  @override
  @JsonKey(name: 'total_distance_km')
  final double totalDistanceKm;
  @override
  @JsonKey(name: 'total_drive_minutes')
  final int totalDriveMinutes;
  @override
  @JsonKey(name: 'total_duration_minutes')
  final int totalDurationMinutes;

  /// 'osrm' = real road distances, 'haversine' = straight-line estimate.
  /// Shown on the screen because it changes what the numbers mean.
  @override
  @JsonKey(name: 'route_engine')
  final String routeEngine;
  @override
  @JsonKey(name: 'optimized_on')
  final String? optimizedOn;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'can_edit', fromJson: _flagTrue)
  final bool canEdit;
  final List<VisitStop> _stops;
  @override
  @JsonKey()
  List<VisitStop> get stops {
    if (_stops is EqualUnmodifiableListView) return _stops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stops);
  }

  /// Road path through the stops, `[[lat, lng], ...]`. Null whenever OSRM is
  /// not in play; the map then draws straight legs between stops instead.
  final List<List<double>>? _geometry;

  /// Road path through the stops, `[[lat, lng], ...]`. Null whenever OSRM is
  /// not in play; the map then draws straight legs between stops instead.
  @override
  @JsonKey(name: 'geometry')
  List<List<double>>? get geometry {
    final value = _geometry;
    if (value == null) return null;
    if (_geometry is EqualUnmodifiableListView) return _geometry;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'VisitPlan(name: $name, visitDate: $visitDate, rep: $rep, repName: $repName, title: $title, status: $status, startMode: $startMode, startLabel: $startLabel, startLatitude: $startLatitude, startLongitude: $startLongitude, plannedStartTime: $plannedStartTime, defaultVisitMinutes: $defaultVisitMinutes, returnToStart: $returnToStart, totalStops: $totalStops, totalDistanceKm: $totalDistanceKm, totalDriveMinutes: $totalDriveMinutes, totalDurationMinutes: $totalDurationMinutes, routeEngine: $routeEngine, optimizedOn: $optimizedOn, notes: $notes, canEdit: $canEdit, stops: $stops, geometry: $geometry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitPlanImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.visitDate, visitDate) ||
                other.visitDate == visitDate) &&
            (identical(other.rep, rep) || other.rep == rep) &&
            (identical(other.repName, repName) || other.repName == repName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startMode, startMode) ||
                other.startMode == startMode) &&
            (identical(other.startLabel, startLabel) ||
                other.startLabel == startLabel) &&
            (identical(other.startLatitude, startLatitude) ||
                other.startLatitude == startLatitude) &&
            (identical(other.startLongitude, startLongitude) ||
                other.startLongitude == startLongitude) &&
            (identical(other.plannedStartTime, plannedStartTime) ||
                other.plannedStartTime == plannedStartTime) &&
            (identical(other.defaultVisitMinutes, defaultVisitMinutes) ||
                other.defaultVisitMinutes == defaultVisitMinutes) &&
            (identical(other.returnToStart, returnToStart) ||
                other.returnToStart == returnToStart) &&
            (identical(other.totalStops, totalStops) ||
                other.totalStops == totalStops) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(other.totalDriveMinutes, totalDriveMinutes) ||
                other.totalDriveMinutes == totalDriveMinutes) &&
            (identical(other.totalDurationMinutes, totalDurationMinutes) ||
                other.totalDurationMinutes == totalDurationMinutes) &&
            (identical(other.routeEngine, routeEngine) ||
                other.routeEngine == routeEngine) &&
            (identical(other.optimizedOn, optimizedOn) ||
                other.optimizedOn == optimizedOn) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            const DeepCollectionEquality().equals(other._stops, _stops) &&
            const DeepCollectionEquality().equals(other._geometry, _geometry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    visitDate,
    rep,
    repName,
    title,
    status,
    startMode,
    startLabel,
    startLatitude,
    startLongitude,
    plannedStartTime,
    defaultVisitMinutes,
    returnToStart,
    totalStops,
    totalDistanceKm,
    totalDriveMinutes,
    totalDurationMinutes,
    routeEngine,
    optimizedOn,
    notes,
    canEdit,
    const DeepCollectionEquality().hash(_stops),
    const DeepCollectionEquality().hash(_geometry),
  ]);

  /// Create a copy of VisitPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitPlanImplCopyWith<_$VisitPlanImpl> get copyWith =>
      __$$VisitPlanImplCopyWithImpl<_$VisitPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitPlanImplToJson(this);
  }
}

abstract class _VisitPlan extends VisitPlan {
  const factory _VisitPlan({
    required final String name,
    @JsonKey(name: 'visit_date') final String? visitDate,
    final String rep,
    @JsonKey(name: 'rep_name') final String repName,
    final String title,
    final String status,
    @JsonKey(name: 'start_mode') final String startMode,
    @JsonKey(name: 'start_label') final String startLabel,
    @JsonKey(name: 'start_latitude') final double? startLatitude,
    @JsonKey(name: 'start_longitude') final double? startLongitude,
    @JsonKey(name: 'planned_start_time') final String? plannedStartTime,
    @JsonKey(name: 'default_visit_minutes') final int defaultVisitMinutes,
    @JsonKey(name: 'return_to_start', fromJson: _flag) final bool returnToStart,
    @JsonKey(name: 'total_stops') final int totalStops,
    @JsonKey(name: 'total_distance_km') final double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') final int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') final int totalDurationMinutes,
    @JsonKey(name: 'route_engine') final String routeEngine,
    @JsonKey(name: 'optimized_on') final String? optimizedOn,
    final String notes,
    @JsonKey(name: 'can_edit', fromJson: _flagTrue) final bool canEdit,
    final List<VisitStop> stops,
    @JsonKey(name: 'geometry') final List<List<double>>? geometry,
  }) = _$VisitPlanImpl;
  const _VisitPlan._() : super._();

  factory _VisitPlan.fromJson(Map<String, dynamic> json) =
      _$VisitPlanImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'visit_date')
  String? get visitDate;
  @override
  String get rep;
  @override
  @JsonKey(name: 'rep_name')
  String get repName;
  @override
  String get title;
  @override
  String get status;
  @override
  @JsonKey(name: 'start_mode')
  String get startMode;
  @override
  @JsonKey(name: 'start_label')
  String get startLabel;
  @override
  @JsonKey(name: 'start_latitude')
  double? get startLatitude;
  @override
  @JsonKey(name: 'start_longitude')
  double? get startLongitude;
  @override
  @JsonKey(name: 'planned_start_time')
  String? get plannedStartTime;
  @override
  @JsonKey(name: 'default_visit_minutes')
  int get defaultVisitMinutes;
  @override
  @JsonKey(name: 'return_to_start', fromJson: _flag)
  bool get returnToStart;
  @override
  @JsonKey(name: 'total_stops')
  int get totalStops;
  @override
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm;
  @override
  @JsonKey(name: 'total_drive_minutes')
  int get totalDriveMinutes;
  @override
  @JsonKey(name: 'total_duration_minutes')
  int get totalDurationMinutes;

  /// 'osrm' = real road distances, 'haversine' = straight-line estimate.
  /// Shown on the screen because it changes what the numbers mean.
  @override
  @JsonKey(name: 'route_engine')
  String get routeEngine;
  @override
  @JsonKey(name: 'optimized_on')
  String? get optimizedOn;
  @override
  String get notes;
  @override
  @JsonKey(name: 'can_edit', fromJson: _flagTrue)
  bool get canEdit;
  @override
  List<VisitStop> get stops;

  /// Road path through the stops, `[[lat, lng], ...]`. Null whenever OSRM is
  /// not in play; the map then draws straight legs between stops instead.
  @override
  @JsonKey(name: 'geometry')
  List<List<double>>? get geometry;

  /// Create a copy of VisitPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitPlanImplCopyWith<_$VisitPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisitStop _$VisitStopFromJson(Map<String, dynamic> json) {
  return _VisitStop.fromJson(json);
}

/// @nodoc
mixin _$VisitStop {
  String get name => throw _privateConstructorUsedError;
  int get idx => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_name')
  String get referenceName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_name')
  String get branchName => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'maps_url')
  String get mapsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_time')
  String? get plannedTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'visit_minutes')
  int get visitMinutes => throw _privateConstructorUsedError;

  /// Pinned to this position; the optimiser reorders around it. This is how
  /// a booked appointment is expressed.
  @JsonKey(fromJson: _flag)
  bool get locked => throw _privateConstructorUsedError;
  @JsonKey(name: 'leg_km')
  double get legKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'leg_minutes')
  int get legMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'arrived_at')
  String? get arrivedAt => throw _privateConstructorUsedError;
  String get outcome => throw _privateConstructorUsedError;
  @JsonKey(name: 'journey_note')
  String? get journeyNote => throw _privateConstructorUsedError;

  /// Serializes this VisitStop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitStopCopyWith<VisitStop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitStopCopyWith<$Res> {
  factory $VisitStopCopyWith(VisitStop value, $Res Function(VisitStop) then) =
      _$VisitStopCopyWithImpl<$Res, VisitStop>;
  @useResult
  $Res call({
    String name,
    int idx,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    String status,
    double? latitude,
    double? longitude,
    String address,
    String phone,
    @JsonKey(name: 'maps_url') String mapsUrl,
    @JsonKey(name: 'planned_time') String? plannedTime,
    @JsonKey(name: 'visit_minutes') int visitMinutes,
    @JsonKey(fromJson: _flag) bool locked,
    @JsonKey(name: 'leg_km') double legKm,
    @JsonKey(name: 'leg_minutes') int legMinutes,
    @JsonKey(name: 'arrived_at') String? arrivedAt,
    String outcome,
    @JsonKey(name: 'journey_note') String? journeyNote,
  });
}

/// @nodoc
class _$VisitStopCopyWithImpl<$Res, $Val extends VisitStop>
    implements $VisitStopCopyWith<$Res> {
  _$VisitStopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? idx = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? branchName = null,
    Object? area = null,
    Object? status = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? address = null,
    Object? phone = null,
    Object? mapsUrl = null,
    Object? plannedTime = freezed,
    Object? visitMinutes = null,
    Object? locked = null,
    Object? legKm = null,
    Object? legMinutes = null,
    Object? arrivedAt = freezed,
    Object? outcome = null,
    Object? journeyNote = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            idx: null == idx
                ? _value.idx
                : idx // ignore: cast_nullable_to_non_nullable
                      as int,
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
            branchName: null == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String,
            area: null == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            mapsUrl: null == mapsUrl
                ? _value.mapsUrl
                : mapsUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            plannedTime: freezed == plannedTime
                ? _value.plannedTime
                : plannedTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            visitMinutes: null == visitMinutes
                ? _value.visitMinutes
                : visitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            locked: null == locked
                ? _value.locked
                : locked // ignore: cast_nullable_to_non_nullable
                      as bool,
            legKm: null == legKm
                ? _value.legKm
                : legKm // ignore: cast_nullable_to_non_nullable
                      as double,
            legMinutes: null == legMinutes
                ? _value.legMinutes
                : legMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            arrivedAt: freezed == arrivedAt
                ? _value.arrivedAt
                : arrivedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            outcome: null == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as String,
            journeyNote: freezed == journeyNote
                ? _value.journeyNote
                : journeyNote // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitStopImplCopyWith<$Res>
    implements $VisitStopCopyWith<$Res> {
  factory _$$VisitStopImplCopyWith(
    _$VisitStopImpl value,
    $Res Function(_$VisitStopImpl) then,
  ) = __$$VisitStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int idx,
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    String status,
    double? latitude,
    double? longitude,
    String address,
    String phone,
    @JsonKey(name: 'maps_url') String mapsUrl,
    @JsonKey(name: 'planned_time') String? plannedTime,
    @JsonKey(name: 'visit_minutes') int visitMinutes,
    @JsonKey(fromJson: _flag) bool locked,
    @JsonKey(name: 'leg_km') double legKm,
    @JsonKey(name: 'leg_minutes') int legMinutes,
    @JsonKey(name: 'arrived_at') String? arrivedAt,
    String outcome,
    @JsonKey(name: 'journey_note') String? journeyNote,
  });
}

/// @nodoc
class __$$VisitStopImplCopyWithImpl<$Res>
    extends _$VisitStopCopyWithImpl<$Res, _$VisitStopImpl>
    implements _$$VisitStopImplCopyWith<$Res> {
  __$$VisitStopImplCopyWithImpl(
    _$VisitStopImpl _value,
    $Res Function(_$VisitStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? idx = null,
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? branchName = null,
    Object? area = null,
    Object? status = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? address = null,
    Object? phone = null,
    Object? mapsUrl = null,
    Object? plannedTime = freezed,
    Object? visitMinutes = null,
    Object? locked = null,
    Object? legKm = null,
    Object? legMinutes = null,
    Object? arrivedAt = freezed,
    Object? outcome = null,
    Object? journeyNote = freezed,
  }) {
    return _then(
      _$VisitStopImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        idx: null == idx
            ? _value.idx
            : idx // ignore: cast_nullable_to_non_nullable
                  as int,
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
        branchName: null == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String,
        area: null == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        mapsUrl: null == mapsUrl
            ? _value.mapsUrl
            : mapsUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        plannedTime: freezed == plannedTime
            ? _value.plannedTime
            : plannedTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        visitMinutes: null == visitMinutes
            ? _value.visitMinutes
            : visitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        locked: null == locked
            ? _value.locked
            : locked // ignore: cast_nullable_to_non_nullable
                  as bool,
        legKm: null == legKm
            ? _value.legKm
            : legKm // ignore: cast_nullable_to_non_nullable
                  as double,
        legMinutes: null == legMinutes
            ? _value.legMinutes
            : legMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        arrivedAt: freezed == arrivedAt
            ? _value.arrivedAt
            : arrivedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        outcome: null == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as String,
        journeyNote: freezed == journeyNote
            ? _value.journeyNote
            : journeyNote // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitStopImpl extends _VisitStop {
  const _$VisitStopImpl({
    required this.name,
    this.idx = 0,
    @JsonKey(name: 'reference_doctype') this.referenceDoctype = 'Lead',
    @JsonKey(name: 'reference_name') this.referenceName = '',
    this.title = '',
    @JsonKey(name: 'branch_name') this.branchName = '',
    this.area = '',
    this.status = 'Planned',
    this.latitude,
    this.longitude,
    this.address = '',
    this.phone = '',
    @JsonKey(name: 'maps_url') this.mapsUrl = '',
    @JsonKey(name: 'planned_time') this.plannedTime,
    @JsonKey(name: 'visit_minutes') this.visitMinutes = 0,
    @JsonKey(fromJson: _flag) this.locked = false,
    @JsonKey(name: 'leg_km') this.legKm = 0.0,
    @JsonKey(name: 'leg_minutes') this.legMinutes = 0,
    @JsonKey(name: 'arrived_at') this.arrivedAt,
    this.outcome = '',
    @JsonKey(name: 'journey_note') this.journeyNote,
  }) : super._();

  factory _$VisitStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitStopImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int idx;
  @override
  @JsonKey(name: 'reference_doctype')
  final String referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  final String referenceName;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey(name: 'branch_name')
  final String branchName;
  @override
  @JsonKey()
  final String area;
  @override
  @JsonKey()
  final String status;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey(name: 'maps_url')
  final String mapsUrl;
  @override
  @JsonKey(name: 'planned_time')
  final String? plannedTime;
  @override
  @JsonKey(name: 'visit_minutes')
  final int visitMinutes;

  /// Pinned to this position; the optimiser reorders around it. This is how
  /// a booked appointment is expressed.
  @override
  @JsonKey(fromJson: _flag)
  final bool locked;
  @override
  @JsonKey(name: 'leg_km')
  final double legKm;
  @override
  @JsonKey(name: 'leg_minutes')
  final int legMinutes;
  @override
  @JsonKey(name: 'arrived_at')
  final String? arrivedAt;
  @override
  @JsonKey()
  final String outcome;
  @override
  @JsonKey(name: 'journey_note')
  final String? journeyNote;

  @override
  String toString() {
    return 'VisitStop(name: $name, idx: $idx, referenceDoctype: $referenceDoctype, referenceName: $referenceName, title: $title, branchName: $branchName, area: $area, status: $status, latitude: $latitude, longitude: $longitude, address: $address, phone: $phone, mapsUrl: $mapsUrl, plannedTime: $plannedTime, visitMinutes: $visitMinutes, locked: $locked, legKm: $legKm, legMinutes: $legMinutes, arrivedAt: $arrivedAt, outcome: $outcome, journeyNote: $journeyNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitStopImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.idx, idx) || other.idx == idx) &&
            (identical(other.referenceDoctype, referenceDoctype) ||
                other.referenceDoctype == referenceDoctype) &&
            (identical(other.referenceName, referenceName) ||
                other.referenceName == referenceName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl) &&
            (identical(other.plannedTime, plannedTime) ||
                other.plannedTime == plannedTime) &&
            (identical(other.visitMinutes, visitMinutes) ||
                other.visitMinutes == visitMinutes) &&
            (identical(other.locked, locked) || other.locked == locked) &&
            (identical(other.legKm, legKm) || other.legKm == legKm) &&
            (identical(other.legMinutes, legMinutes) ||
                other.legMinutes == legMinutes) &&
            (identical(other.arrivedAt, arrivedAt) ||
                other.arrivedAt == arrivedAt) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.journeyNote, journeyNote) ||
                other.journeyNote == journeyNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    name,
    idx,
    referenceDoctype,
    referenceName,
    title,
    branchName,
    area,
    status,
    latitude,
    longitude,
    address,
    phone,
    mapsUrl,
    plannedTime,
    visitMinutes,
    locked,
    legKm,
    legMinutes,
    arrivedAt,
    outcome,
    journeyNote,
  ]);

  /// Create a copy of VisitStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitStopImplCopyWith<_$VisitStopImpl> get copyWith =>
      __$$VisitStopImplCopyWithImpl<_$VisitStopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitStopImplToJson(this);
  }
}

abstract class _VisitStop extends VisitStop {
  const factory _VisitStop({
    required final String name,
    final int idx,
    @JsonKey(name: 'reference_doctype') final String referenceDoctype,
    @JsonKey(name: 'reference_name') final String referenceName,
    final String title,
    @JsonKey(name: 'branch_name') final String branchName,
    final String area,
    final String status,
    final double? latitude,
    final double? longitude,
    final String address,
    final String phone,
    @JsonKey(name: 'maps_url') final String mapsUrl,
    @JsonKey(name: 'planned_time') final String? plannedTime,
    @JsonKey(name: 'visit_minutes') final int visitMinutes,
    @JsonKey(fromJson: _flag) final bool locked,
    @JsonKey(name: 'leg_km') final double legKm,
    @JsonKey(name: 'leg_minutes') final int legMinutes,
    @JsonKey(name: 'arrived_at') final String? arrivedAt,
    final String outcome,
    @JsonKey(name: 'journey_note') final String? journeyNote,
  }) = _$VisitStopImpl;
  const _VisitStop._() : super._();

  factory _VisitStop.fromJson(Map<String, dynamic> json) =
      _$VisitStopImpl.fromJson;

  @override
  String get name;
  @override
  int get idx;
  @override
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  String get referenceName;
  @override
  String get title;
  @override
  @JsonKey(name: 'branch_name')
  String get branchName;
  @override
  String get area;
  @override
  String get status;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String get address;
  @override
  String get phone;
  @override
  @JsonKey(name: 'maps_url')
  String get mapsUrl;
  @override
  @JsonKey(name: 'planned_time')
  String? get plannedTime;
  @override
  @JsonKey(name: 'visit_minutes')
  int get visitMinutes;

  /// Pinned to this position; the optimiser reorders around it. This is how
  /// a booked appointment is expressed.
  @override
  @JsonKey(fromJson: _flag)
  bool get locked;
  @override
  @JsonKey(name: 'leg_km')
  double get legKm;
  @override
  @JsonKey(name: 'leg_minutes')
  int get legMinutes;
  @override
  @JsonKey(name: 'arrived_at')
  String? get arrivedAt;
  @override
  String get outcome;
  @override
  @JsonKey(name: 'journey_note')
  String? get journeyNote;

  /// Create a copy of VisitStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitStopImplCopyWith<_$VisitStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisitTarget _$VisitTargetFromJson(Map<String, dynamic> json) {
  return _VisitTarget.fromJson(json);
}

/// @nodoc
mixin _$VisitTarget {
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_name')
  String get referenceName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'branch_name')
  String get branchName => throw _privateConstructorUsedError;
  String get area => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'maps_url')
  String get mapsUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'fit_score')
  double get fitScore => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_specialty', fromJson: _flag)
  bool get isSpecialty => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_visit_date')
  String? get lastVisitDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_since_visit')
  int? get daysSinceVisit => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_followup_date')
  String? get nextFollowupDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'followup_overdue', fromJson: _flag)
  bool get followupOverdue => throw _privateConstructorUsedError;
  double get priority => throw _privateConstructorUsedError;
  List<String> get reasons => throw _privateConstructorUsedError;

  /// Serializes this VisitTarget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitTargetCopyWith<VisitTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitTargetCopyWith<$Res> {
  factory $VisitTargetCopyWith(
    VisitTarget value,
    $Res Function(VisitTarget) then,
  ) = _$VisitTargetCopyWithImpl<$Res, VisitTarget>;
  @useResult
  $Res call({
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    double latitude,
    double longitude,
    String address,
    String phone,
    @JsonKey(name: 'maps_url') String mapsUrl,
    @JsonKey(name: 'fit_score') double fitScore,
    String stage,
    String tier,
    String category,
    @JsonKey(name: 'is_specialty', fromJson: _flag) bool isSpecialty,
    @JsonKey(name: 'last_visit_date') String? lastVisitDate,
    @JsonKey(name: 'days_since_visit') int? daysSinceVisit,
    @JsonKey(name: 'next_followup_date') String? nextFollowupDate,
    @JsonKey(name: 'followup_overdue', fromJson: _flag) bool followupOverdue,
    double priority,
    List<String> reasons,
  });
}

/// @nodoc
class _$VisitTargetCopyWithImpl<$Res, $Val extends VisitTarget>
    implements $VisitTargetCopyWith<$Res> {
  _$VisitTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? branchName = null,
    Object? area = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = null,
    Object? phone = null,
    Object? mapsUrl = null,
    Object? fitScore = null,
    Object? stage = null,
    Object? tier = null,
    Object? category = null,
    Object? isSpecialty = null,
    Object? lastVisitDate = freezed,
    Object? daysSinceVisit = freezed,
    Object? nextFollowupDate = freezed,
    Object? followupOverdue = null,
    Object? priority = null,
    Object? reasons = null,
  }) {
    return _then(
      _value.copyWith(
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
            branchName: null == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String,
            area: null == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            mapsUrl: null == mapsUrl
                ? _value.mapsUrl
                : mapsUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            fitScore: null == fitScore
                ? _value.fitScore
                : fitScore // ignore: cast_nullable_to_non_nullable
                      as double,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            isSpecialty: null == isSpecialty
                ? _value.isSpecialty
                : isSpecialty // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastVisitDate: freezed == lastVisitDate
                ? _value.lastVisitDate
                : lastVisitDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            daysSinceVisit: freezed == daysSinceVisit
                ? _value.daysSinceVisit
                : daysSinceVisit // ignore: cast_nullable_to_non_nullable
                      as int?,
            nextFollowupDate: freezed == nextFollowupDate
                ? _value.nextFollowupDate
                : nextFollowupDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            followupOverdue: null == followupOverdue
                ? _value.followupOverdue
                : followupOverdue // ignore: cast_nullable_to_non_nullable
                      as bool,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as double,
            reasons: null == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitTargetImplCopyWith<$Res>
    implements $VisitTargetCopyWith<$Res> {
  factory _$$VisitTargetImplCopyWith(
    _$VisitTargetImpl value,
    $Res Function(_$VisitTargetImpl) then,
  ) = __$$VisitTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'reference_doctype') String referenceDoctype,
    @JsonKey(name: 'reference_name') String referenceName,
    String title,
    @JsonKey(name: 'branch_name') String branchName,
    String area,
    double latitude,
    double longitude,
    String address,
    String phone,
    @JsonKey(name: 'maps_url') String mapsUrl,
    @JsonKey(name: 'fit_score') double fitScore,
    String stage,
    String tier,
    String category,
    @JsonKey(name: 'is_specialty', fromJson: _flag) bool isSpecialty,
    @JsonKey(name: 'last_visit_date') String? lastVisitDate,
    @JsonKey(name: 'days_since_visit') int? daysSinceVisit,
    @JsonKey(name: 'next_followup_date') String? nextFollowupDate,
    @JsonKey(name: 'followup_overdue', fromJson: _flag) bool followupOverdue,
    double priority,
    List<String> reasons,
  });
}

/// @nodoc
class __$$VisitTargetImplCopyWithImpl<$Res>
    extends _$VisitTargetCopyWithImpl<$Res, _$VisitTargetImpl>
    implements _$$VisitTargetImplCopyWith<$Res> {
  __$$VisitTargetImplCopyWithImpl(
    _$VisitTargetImpl _value,
    $Res Function(_$VisitTargetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referenceDoctype = null,
    Object? referenceName = null,
    Object? title = null,
    Object? branchName = null,
    Object? area = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = null,
    Object? phone = null,
    Object? mapsUrl = null,
    Object? fitScore = null,
    Object? stage = null,
    Object? tier = null,
    Object? category = null,
    Object? isSpecialty = null,
    Object? lastVisitDate = freezed,
    Object? daysSinceVisit = freezed,
    Object? nextFollowupDate = freezed,
    Object? followupOverdue = null,
    Object? priority = null,
    Object? reasons = null,
  }) {
    return _then(
      _$VisitTargetImpl(
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
        branchName: null == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String,
        area: null == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        mapsUrl: null == mapsUrl
            ? _value.mapsUrl
            : mapsUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        fitScore: null == fitScore
            ? _value.fitScore
            : fitScore // ignore: cast_nullable_to_non_nullable
                  as double,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        isSpecialty: null == isSpecialty
            ? _value.isSpecialty
            : isSpecialty // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastVisitDate: freezed == lastVisitDate
            ? _value.lastVisitDate
            : lastVisitDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        daysSinceVisit: freezed == daysSinceVisit
            ? _value.daysSinceVisit
            : daysSinceVisit // ignore: cast_nullable_to_non_nullable
                  as int?,
        nextFollowupDate: freezed == nextFollowupDate
            ? _value.nextFollowupDate
            : nextFollowupDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        followupOverdue: null == followupOverdue
            ? _value.followupOverdue
            : followupOverdue // ignore: cast_nullable_to_non_nullable
                  as bool,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as double,
        reasons: null == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitTargetImpl extends _VisitTarget {
  const _$VisitTargetImpl({
    @JsonKey(name: 'reference_doctype') this.referenceDoctype = 'Lead',
    @JsonKey(name: 'reference_name') this.referenceName = '',
    this.title = '',
    @JsonKey(name: 'branch_name') this.branchName = '',
    this.area = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = '',
    this.phone = '',
    @JsonKey(name: 'maps_url') this.mapsUrl = '',
    @JsonKey(name: 'fit_score') this.fitScore = 0.0,
    this.stage = '',
    this.tier = '',
    this.category = '',
    @JsonKey(name: 'is_specialty', fromJson: _flag) this.isSpecialty = false,
    @JsonKey(name: 'last_visit_date') this.lastVisitDate,
    @JsonKey(name: 'days_since_visit') this.daysSinceVisit,
    @JsonKey(name: 'next_followup_date') this.nextFollowupDate,
    @JsonKey(name: 'followup_overdue', fromJson: _flag)
    this.followupOverdue = false,
    this.priority = 0.0,
    final List<String> reasons = const <String>[],
  }) : _reasons = reasons,
       super._();

  factory _$VisitTargetImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitTargetImplFromJson(json);

  @override
  @JsonKey(name: 'reference_doctype')
  final String referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  final String referenceName;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey(name: 'branch_name')
  final String branchName;
  @override
  @JsonKey()
  final String area;
  @override
  @JsonKey()
  final double latitude;
  @override
  @JsonKey()
  final double longitude;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey(name: 'maps_url')
  final String mapsUrl;
  @override
  @JsonKey(name: 'fit_score')
  final double fitScore;
  @override
  @JsonKey()
  final String stage;
  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey(name: 'is_specialty', fromJson: _flag)
  final bool isSpecialty;
  @override
  @JsonKey(name: 'last_visit_date')
  final String? lastVisitDate;
  @override
  @JsonKey(name: 'days_since_visit')
  final int? daysSinceVisit;
  @override
  @JsonKey(name: 'next_followup_date')
  final String? nextFollowupDate;
  @override
  @JsonKey(name: 'followup_overdue', fromJson: _flag)
  final bool followupOverdue;
  @override
  @JsonKey()
  final double priority;
  final List<String> _reasons;
  @override
  @JsonKey()
  List<String> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  String toString() {
    return 'VisitTarget(referenceDoctype: $referenceDoctype, referenceName: $referenceName, title: $title, branchName: $branchName, area: $area, latitude: $latitude, longitude: $longitude, address: $address, phone: $phone, mapsUrl: $mapsUrl, fitScore: $fitScore, stage: $stage, tier: $tier, category: $category, isSpecialty: $isSpecialty, lastVisitDate: $lastVisitDate, daysSinceVisit: $daysSinceVisit, nextFollowupDate: $nextFollowupDate, followupOverdue: $followupOverdue, priority: $priority, reasons: $reasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitTargetImpl &&
            (identical(other.referenceDoctype, referenceDoctype) ||
                other.referenceDoctype == referenceDoctype) &&
            (identical(other.referenceName, referenceName) ||
                other.referenceName == referenceName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.mapsUrl, mapsUrl) || other.mapsUrl == mapsUrl) &&
            (identical(other.fitScore, fitScore) ||
                other.fitScore == fitScore) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isSpecialty, isSpecialty) ||
                other.isSpecialty == isSpecialty) &&
            (identical(other.lastVisitDate, lastVisitDate) ||
                other.lastVisitDate == lastVisitDate) &&
            (identical(other.daysSinceVisit, daysSinceVisit) ||
                other.daysSinceVisit == daysSinceVisit) &&
            (identical(other.nextFollowupDate, nextFollowupDate) ||
                other.nextFollowupDate == nextFollowupDate) &&
            (identical(other.followupOverdue, followupOverdue) ||
                other.followupOverdue == followupOverdue) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    referenceDoctype,
    referenceName,
    title,
    branchName,
    area,
    latitude,
    longitude,
    address,
    phone,
    mapsUrl,
    fitScore,
    stage,
    tier,
    category,
    isSpecialty,
    lastVisitDate,
    daysSinceVisit,
    nextFollowupDate,
    followupOverdue,
    priority,
    const DeepCollectionEquality().hash(_reasons),
  ]);

  /// Create a copy of VisitTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitTargetImplCopyWith<_$VisitTargetImpl> get copyWith =>
      __$$VisitTargetImplCopyWithImpl<_$VisitTargetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitTargetImplToJson(this);
  }
}

abstract class _VisitTarget extends VisitTarget {
  const factory _VisitTarget({
    @JsonKey(name: 'reference_doctype') final String referenceDoctype,
    @JsonKey(name: 'reference_name') final String referenceName,
    final String title,
    @JsonKey(name: 'branch_name') final String branchName,
    final String area,
    final double latitude,
    final double longitude,
    final String address,
    final String phone,
    @JsonKey(name: 'maps_url') final String mapsUrl,
    @JsonKey(name: 'fit_score') final double fitScore,
    final String stage,
    final String tier,
    final String category,
    @JsonKey(name: 'is_specialty', fromJson: _flag) final bool isSpecialty,
    @JsonKey(name: 'last_visit_date') final String? lastVisitDate,
    @JsonKey(name: 'days_since_visit') final int? daysSinceVisit,
    @JsonKey(name: 'next_followup_date') final String? nextFollowupDate,
    @JsonKey(name: 'followup_overdue', fromJson: _flag)
    final bool followupOverdue,
    final double priority,
    final List<String> reasons,
  }) = _$VisitTargetImpl;
  const _VisitTarget._() : super._();

  factory _VisitTarget.fromJson(Map<String, dynamic> json) =
      _$VisitTargetImpl.fromJson;

  @override
  @JsonKey(name: 'reference_doctype')
  String get referenceDoctype;
  @override
  @JsonKey(name: 'reference_name')
  String get referenceName;
  @override
  String get title;
  @override
  @JsonKey(name: 'branch_name')
  String get branchName;
  @override
  String get area;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get address;
  @override
  String get phone;
  @override
  @JsonKey(name: 'maps_url')
  String get mapsUrl;
  @override
  @JsonKey(name: 'fit_score')
  double get fitScore;
  @override
  String get stage;
  @override
  String get tier;
  @override
  String get category;
  @override
  @JsonKey(name: 'is_specialty', fromJson: _flag)
  bool get isSpecialty;
  @override
  @JsonKey(name: 'last_visit_date')
  String? get lastVisitDate;
  @override
  @JsonKey(name: 'days_since_visit')
  int? get daysSinceVisit;
  @override
  @JsonKey(name: 'next_followup_date')
  String? get nextFollowupDate;
  @override
  @JsonKey(name: 'followup_overdue', fromJson: _flag)
  bool get followupOverdue;
  @override
  double get priority;
  @override
  List<String> get reasons;

  /// Create a copy of VisitTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitTargetImplCopyWith<_$VisitTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisitSuggestion _$VisitSuggestionFromJson(Map<String, dynamic> json) {
  return _VisitSuggestion.fromJson(json);
}

/// @nodoc
mixin _$VisitSuggestion {
  List<VisitTarget> get targets => throw _privateConstructorUsedError;
  String get engine => throw _privateConstructorUsedError;
  @JsonKey(name: 'engine_note')
  String? get engineNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_drive_minutes')
  int get totalDriveMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_duration_minutes')
  int get totalDurationMinutes => throw _privateConstructorUsedError;

  /// How many doors were weighed to produce this. Worth showing: "9 of 812
  /// considered" is what makes the suggestion feel like a decision rather
  /// than a coincidence.
  int get considered => throw _privateConstructorUsedError;
  @JsonKey(name: 'dropped_for_time')
  int get droppedForTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_minutes')
  int get dayMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'visit_date')
  String? get visitDate => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this VisitSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitSuggestionCopyWith<VisitSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitSuggestionCopyWith<$Res> {
  factory $VisitSuggestionCopyWith(
    VisitSuggestion value,
    $Res Function(VisitSuggestion) then,
  ) = _$VisitSuggestionCopyWithImpl<$Res, VisitSuggestion>;
  @useResult
  $Res call({
    List<VisitTarget> targets,
    String engine,
    @JsonKey(name: 'engine_note') String? engineNote,
    @JsonKey(name: 'total_distance_km') double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') int totalDurationMinutes,
    int considered,
    @JsonKey(name: 'dropped_for_time') int droppedForTime,
    @JsonKey(name: 'day_minutes') int dayMinutes,
    @JsonKey(name: 'visit_date') String? visitDate,
    String? note,
  });
}

/// @nodoc
class _$VisitSuggestionCopyWithImpl<$Res, $Val extends VisitSuggestion>
    implements $VisitSuggestionCopyWith<$Res> {
  _$VisitSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targets = null,
    Object? engine = null,
    Object? engineNote = freezed,
    Object? totalDistanceKm = null,
    Object? totalDriveMinutes = null,
    Object? totalDurationMinutes = null,
    Object? considered = null,
    Object? droppedForTime = null,
    Object? dayMinutes = null,
    Object? visitDate = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _value.copyWith(
            targets: null == targets
                ? _value.targets
                : targets // ignore: cast_nullable_to_non_nullable
                      as List<VisitTarget>,
            engine: null == engine
                ? _value.engine
                : engine // ignore: cast_nullable_to_non_nullable
                      as String,
            engineNote: freezed == engineNote
                ? _value.engineNote
                : engineNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalDistanceKm: null == totalDistanceKm
                ? _value.totalDistanceKm
                : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDriveMinutes: null == totalDriveMinutes
                ? _value.totalDriveMinutes
                : totalDriveMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDurationMinutes: null == totalDurationMinutes
                ? _value.totalDurationMinutes
                : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            considered: null == considered
                ? _value.considered
                : considered // ignore: cast_nullable_to_non_nullable
                      as int,
            droppedForTime: null == droppedForTime
                ? _value.droppedForTime
                : droppedForTime // ignore: cast_nullable_to_non_nullable
                      as int,
            dayMinutes: null == dayMinutes
                ? _value.dayMinutes
                : dayMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            visitDate: freezed == visitDate
                ? _value.visitDate
                : visitDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitSuggestionImplCopyWith<$Res>
    implements $VisitSuggestionCopyWith<$Res> {
  factory _$$VisitSuggestionImplCopyWith(
    _$VisitSuggestionImpl value,
    $Res Function(_$VisitSuggestionImpl) then,
  ) = __$$VisitSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<VisitTarget> targets,
    String engine,
    @JsonKey(name: 'engine_note') String? engineNote,
    @JsonKey(name: 'total_distance_km') double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') int totalDurationMinutes,
    int considered,
    @JsonKey(name: 'dropped_for_time') int droppedForTime,
    @JsonKey(name: 'day_minutes') int dayMinutes,
    @JsonKey(name: 'visit_date') String? visitDate,
    String? note,
  });
}

/// @nodoc
class __$$VisitSuggestionImplCopyWithImpl<$Res>
    extends _$VisitSuggestionCopyWithImpl<$Res, _$VisitSuggestionImpl>
    implements _$$VisitSuggestionImplCopyWith<$Res> {
  __$$VisitSuggestionImplCopyWithImpl(
    _$VisitSuggestionImpl _value,
    $Res Function(_$VisitSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targets = null,
    Object? engine = null,
    Object? engineNote = freezed,
    Object? totalDistanceKm = null,
    Object? totalDriveMinutes = null,
    Object? totalDurationMinutes = null,
    Object? considered = null,
    Object? droppedForTime = null,
    Object? dayMinutes = null,
    Object? visitDate = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _$VisitSuggestionImpl(
        targets: null == targets
            ? _value._targets
            : targets // ignore: cast_nullable_to_non_nullable
                  as List<VisitTarget>,
        engine: null == engine
            ? _value.engine
            : engine // ignore: cast_nullable_to_non_nullable
                  as String,
        engineNote: freezed == engineNote
            ? _value.engineNote
            : engineNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalDistanceKm: null == totalDistanceKm
            ? _value.totalDistanceKm
            : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDriveMinutes: null == totalDriveMinutes
            ? _value.totalDriveMinutes
            : totalDriveMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDurationMinutes: null == totalDurationMinutes
            ? _value.totalDurationMinutes
            : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        considered: null == considered
            ? _value.considered
            : considered // ignore: cast_nullable_to_non_nullable
                  as int,
        droppedForTime: null == droppedForTime
            ? _value.droppedForTime
            : droppedForTime // ignore: cast_nullable_to_non_nullable
                  as int,
        dayMinutes: null == dayMinutes
            ? _value.dayMinutes
            : dayMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        visitDate: freezed == visitDate
            ? _value.visitDate
            : visitDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitSuggestionImpl extends _VisitSuggestion {
  const _$VisitSuggestionImpl({
    final List<VisitTarget> targets = const <VisitTarget>[],
    this.engine = 'haversine',
    @JsonKey(name: 'engine_note') this.engineNote,
    @JsonKey(name: 'total_distance_km') this.totalDistanceKm = 0.0,
    @JsonKey(name: 'total_drive_minutes') this.totalDriveMinutes = 0,
    @JsonKey(name: 'total_duration_minutes') this.totalDurationMinutes = 0,
    this.considered = 0,
    @JsonKey(name: 'dropped_for_time') this.droppedForTime = 0,
    @JsonKey(name: 'day_minutes') this.dayMinutes = 0,
    @JsonKey(name: 'visit_date') this.visitDate,
    this.note,
  }) : _targets = targets,
       super._();

  factory _$VisitSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitSuggestionImplFromJson(json);

  final List<VisitTarget> _targets;
  @override
  @JsonKey()
  List<VisitTarget> get targets {
    if (_targets is EqualUnmodifiableListView) return _targets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targets);
  }

  @override
  @JsonKey()
  final String engine;
  @override
  @JsonKey(name: 'engine_note')
  final String? engineNote;
  @override
  @JsonKey(name: 'total_distance_km')
  final double totalDistanceKm;
  @override
  @JsonKey(name: 'total_drive_minutes')
  final int totalDriveMinutes;
  @override
  @JsonKey(name: 'total_duration_minutes')
  final int totalDurationMinutes;

  /// How many doors were weighed to produce this. Worth showing: "9 of 812
  /// considered" is what makes the suggestion feel like a decision rather
  /// than a coincidence.
  @override
  @JsonKey()
  final int considered;
  @override
  @JsonKey(name: 'dropped_for_time')
  final int droppedForTime;
  @override
  @JsonKey(name: 'day_minutes')
  final int dayMinutes;
  @override
  @JsonKey(name: 'visit_date')
  final String? visitDate;
  @override
  final String? note;

  @override
  String toString() {
    return 'VisitSuggestion(targets: $targets, engine: $engine, engineNote: $engineNote, totalDistanceKm: $totalDistanceKm, totalDriveMinutes: $totalDriveMinutes, totalDurationMinutes: $totalDurationMinutes, considered: $considered, droppedForTime: $droppedForTime, dayMinutes: $dayMinutes, visitDate: $visitDate, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitSuggestionImpl &&
            const DeepCollectionEquality().equals(other._targets, _targets) &&
            (identical(other.engine, engine) || other.engine == engine) &&
            (identical(other.engineNote, engineNote) ||
                other.engineNote == engineNote) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(other.totalDriveMinutes, totalDriveMinutes) ||
                other.totalDriveMinutes == totalDriveMinutes) &&
            (identical(other.totalDurationMinutes, totalDurationMinutes) ||
                other.totalDurationMinutes == totalDurationMinutes) &&
            (identical(other.considered, considered) ||
                other.considered == considered) &&
            (identical(other.droppedForTime, droppedForTime) ||
                other.droppedForTime == droppedForTime) &&
            (identical(other.dayMinutes, dayMinutes) ||
                other.dayMinutes == dayMinutes) &&
            (identical(other.visitDate, visitDate) ||
                other.visitDate == visitDate) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_targets),
    engine,
    engineNote,
    totalDistanceKm,
    totalDriveMinutes,
    totalDurationMinutes,
    considered,
    droppedForTime,
    dayMinutes,
    visitDate,
    note,
  );

  /// Create a copy of VisitSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitSuggestionImplCopyWith<_$VisitSuggestionImpl> get copyWith =>
      __$$VisitSuggestionImplCopyWithImpl<_$VisitSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitSuggestionImplToJson(this);
  }
}

abstract class _VisitSuggestion extends VisitSuggestion {
  const factory _VisitSuggestion({
    final List<VisitTarget> targets,
    final String engine,
    @JsonKey(name: 'engine_note') final String? engineNote,
    @JsonKey(name: 'total_distance_km') final double totalDistanceKm,
    @JsonKey(name: 'total_drive_minutes') final int totalDriveMinutes,
    @JsonKey(name: 'total_duration_minutes') final int totalDurationMinutes,
    final int considered,
    @JsonKey(name: 'dropped_for_time') final int droppedForTime,
    @JsonKey(name: 'day_minutes') final int dayMinutes,
    @JsonKey(name: 'visit_date') final String? visitDate,
    final String? note,
  }) = _$VisitSuggestionImpl;
  const _VisitSuggestion._() : super._();

  factory _VisitSuggestion.fromJson(Map<String, dynamic> json) =
      _$VisitSuggestionImpl.fromJson;

  @override
  List<VisitTarget> get targets;
  @override
  String get engine;
  @override
  @JsonKey(name: 'engine_note')
  String? get engineNote;
  @override
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm;
  @override
  @JsonKey(name: 'total_drive_minutes')
  int get totalDriveMinutes;
  @override
  @JsonKey(name: 'total_duration_minutes')
  int get totalDurationMinutes;

  /// How many doors were weighed to produce this. Worth showing: "9 of 812
  /// considered" is what makes the suggestion feel like a decision rather
  /// than a coincidence.
  @override
  int get considered;
  @override
  @JsonKey(name: 'dropped_for_time')
  int get droppedForTime;
  @override
  @JsonKey(name: 'day_minutes')
  int get dayMinutes;
  @override
  @JsonKey(name: 'visit_date')
  String? get visitDate;
  @override
  String? get note;

  /// Create a copy of VisitSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitSuggestionImplCopyWith<_$VisitSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteEngineStatus _$RouteEngineStatusFromJson(Map<String, dynamic> json) {
  return _RouteEngineStatus.fromJson(json);
}

/// @nodoc
mixin _$RouteEngineStatus {
  @JsonKey(fromJson: _flag)
  bool get configured => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableFlag)
  bool? get reachable => throw _privateConstructorUsedError;
  String get engine => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'road_factor')
  double get roadFactor => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_speed_kmh')
  double get avgSpeedKmh => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_visit_minutes')
  int get defaultVisitMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_stops')
  int get maxStops => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_minutes')
  int get dayMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'visit_days')
  List<String> get visitDays => throw _privateConstructorUsedError;

  /// Serializes this RouteEngineStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteEngineStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteEngineStatusCopyWith<RouteEngineStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteEngineStatusCopyWith<$Res> {
  factory $RouteEngineStatusCopyWith(
    RouteEngineStatus value,
    $Res Function(RouteEngineStatus) then,
  ) = _$RouteEngineStatusCopyWithImpl<$Res, RouteEngineStatus>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _flag) bool configured,
    @JsonKey(fromJson: _nullableFlag) bool? reachable,
    String engine,
    String? reason,
    @JsonKey(name: 'road_factor') double roadFactor,
    @JsonKey(name: 'avg_speed_kmh') double avgSpeedKmh,
    @JsonKey(name: 'default_visit_minutes') int defaultVisitMinutes,
    @JsonKey(name: 'max_stops') int maxStops,
    @JsonKey(name: 'day_minutes') int dayMinutes,
    @JsonKey(name: 'visit_days') List<String> visitDays,
  });
}

/// @nodoc
class _$RouteEngineStatusCopyWithImpl<$Res, $Val extends RouteEngineStatus>
    implements $RouteEngineStatusCopyWith<$Res> {
  _$RouteEngineStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteEngineStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configured = null,
    Object? reachable = freezed,
    Object? engine = null,
    Object? reason = freezed,
    Object? roadFactor = null,
    Object? avgSpeedKmh = null,
    Object? defaultVisitMinutes = null,
    Object? maxStops = null,
    Object? dayMinutes = null,
    Object? visitDays = null,
  }) {
    return _then(
      _value.copyWith(
            configured: null == configured
                ? _value.configured
                : configured // ignore: cast_nullable_to_non_nullable
                      as bool,
            reachable: freezed == reachable
                ? _value.reachable
                : reachable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            engine: null == engine
                ? _value.engine
                : engine // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            roadFactor: null == roadFactor
                ? _value.roadFactor
                : roadFactor // ignore: cast_nullable_to_non_nullable
                      as double,
            avgSpeedKmh: null == avgSpeedKmh
                ? _value.avgSpeedKmh
                : avgSpeedKmh // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultVisitMinutes: null == defaultVisitMinutes
                ? _value.defaultVisitMinutes
                : defaultVisitMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            maxStops: null == maxStops
                ? _value.maxStops
                : maxStops // ignore: cast_nullable_to_non_nullable
                      as int,
            dayMinutes: null == dayMinutes
                ? _value.dayMinutes
                : dayMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            visitDays: null == visitDays
                ? _value.visitDays
                : visitDays // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteEngineStatusImplCopyWith<$Res>
    implements $RouteEngineStatusCopyWith<$Res> {
  factory _$$RouteEngineStatusImplCopyWith(
    _$RouteEngineStatusImpl value,
    $Res Function(_$RouteEngineStatusImpl) then,
  ) = __$$RouteEngineStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _flag) bool configured,
    @JsonKey(fromJson: _nullableFlag) bool? reachable,
    String engine,
    String? reason,
    @JsonKey(name: 'road_factor') double roadFactor,
    @JsonKey(name: 'avg_speed_kmh') double avgSpeedKmh,
    @JsonKey(name: 'default_visit_minutes') int defaultVisitMinutes,
    @JsonKey(name: 'max_stops') int maxStops,
    @JsonKey(name: 'day_minutes') int dayMinutes,
    @JsonKey(name: 'visit_days') List<String> visitDays,
  });
}

/// @nodoc
class __$$RouteEngineStatusImplCopyWithImpl<$Res>
    extends _$RouteEngineStatusCopyWithImpl<$Res, _$RouteEngineStatusImpl>
    implements _$$RouteEngineStatusImplCopyWith<$Res> {
  __$$RouteEngineStatusImplCopyWithImpl(
    _$RouteEngineStatusImpl _value,
    $Res Function(_$RouteEngineStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteEngineStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configured = null,
    Object? reachable = freezed,
    Object? engine = null,
    Object? reason = freezed,
    Object? roadFactor = null,
    Object? avgSpeedKmh = null,
    Object? defaultVisitMinutes = null,
    Object? maxStops = null,
    Object? dayMinutes = null,
    Object? visitDays = null,
  }) {
    return _then(
      _$RouteEngineStatusImpl(
        configured: null == configured
            ? _value.configured
            : configured // ignore: cast_nullable_to_non_nullable
                  as bool,
        reachable: freezed == reachable
            ? _value.reachable
            : reachable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        engine: null == engine
            ? _value.engine
            : engine // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        roadFactor: null == roadFactor
            ? _value.roadFactor
            : roadFactor // ignore: cast_nullable_to_non_nullable
                  as double,
        avgSpeedKmh: null == avgSpeedKmh
            ? _value.avgSpeedKmh
            : avgSpeedKmh // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultVisitMinutes: null == defaultVisitMinutes
            ? _value.defaultVisitMinutes
            : defaultVisitMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        maxStops: null == maxStops
            ? _value.maxStops
            : maxStops // ignore: cast_nullable_to_non_nullable
                  as int,
        dayMinutes: null == dayMinutes
            ? _value.dayMinutes
            : dayMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        visitDays: null == visitDays
            ? _value._visitDays
            : visitDays // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteEngineStatusImpl extends _RouteEngineStatus {
  const _$RouteEngineStatusImpl({
    @JsonKey(fromJson: _flag) this.configured = false,
    @JsonKey(fromJson: _nullableFlag) this.reachable,
    this.engine = 'straight_line',
    this.reason,
    @JsonKey(name: 'road_factor') this.roadFactor = 1.35,
    @JsonKey(name: 'avg_speed_kmh') this.avgSpeedKmh = 22.0,
    @JsonKey(name: 'default_visit_minutes') this.defaultVisitMinutes = 20,
    @JsonKey(name: 'max_stops') this.maxStops = 12,
    @JsonKey(name: 'day_minutes') this.dayMinutes = 360,
    @JsonKey(name: 'visit_days')
    final List<String> visitDays = const <String>[],
  }) : _visitDays = visitDays,
       super._();

  factory _$RouteEngineStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteEngineStatusImplFromJson(json);

  @override
  @JsonKey(fromJson: _flag)
  final bool configured;
  @override
  @JsonKey(fromJson: _nullableFlag)
  final bool? reachable;
  @override
  @JsonKey()
  final String engine;
  @override
  final String? reason;
  @override
  @JsonKey(name: 'road_factor')
  final double roadFactor;
  @override
  @JsonKey(name: 'avg_speed_kmh')
  final double avgSpeedKmh;
  @override
  @JsonKey(name: 'default_visit_minutes')
  final int defaultVisitMinutes;
  @override
  @JsonKey(name: 'max_stops')
  final int maxStops;
  @override
  @JsonKey(name: 'day_minutes')
  final int dayMinutes;
  final List<String> _visitDays;
  @override
  @JsonKey(name: 'visit_days')
  List<String> get visitDays {
    if (_visitDays is EqualUnmodifiableListView) return _visitDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visitDays);
  }

  @override
  String toString() {
    return 'RouteEngineStatus(configured: $configured, reachable: $reachable, engine: $engine, reason: $reason, roadFactor: $roadFactor, avgSpeedKmh: $avgSpeedKmh, defaultVisitMinutes: $defaultVisitMinutes, maxStops: $maxStops, dayMinutes: $dayMinutes, visitDays: $visitDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteEngineStatusImpl &&
            (identical(other.configured, configured) ||
                other.configured == configured) &&
            (identical(other.reachable, reachable) ||
                other.reachable == reachable) &&
            (identical(other.engine, engine) || other.engine == engine) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.roadFactor, roadFactor) ||
                other.roadFactor == roadFactor) &&
            (identical(other.avgSpeedKmh, avgSpeedKmh) ||
                other.avgSpeedKmh == avgSpeedKmh) &&
            (identical(other.defaultVisitMinutes, defaultVisitMinutes) ||
                other.defaultVisitMinutes == defaultVisitMinutes) &&
            (identical(other.maxStops, maxStops) ||
                other.maxStops == maxStops) &&
            (identical(other.dayMinutes, dayMinutes) ||
                other.dayMinutes == dayMinutes) &&
            const DeepCollectionEquality().equals(
              other._visitDays,
              _visitDays,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    configured,
    reachable,
    engine,
    reason,
    roadFactor,
    avgSpeedKmh,
    defaultVisitMinutes,
    maxStops,
    dayMinutes,
    const DeepCollectionEquality().hash(_visitDays),
  );

  /// Create a copy of RouteEngineStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteEngineStatusImplCopyWith<_$RouteEngineStatusImpl> get copyWith =>
      __$$RouteEngineStatusImplCopyWithImpl<_$RouteEngineStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteEngineStatusImplToJson(this);
  }
}

abstract class _RouteEngineStatus extends RouteEngineStatus {
  const factory _RouteEngineStatus({
    @JsonKey(fromJson: _flag) final bool configured,
    @JsonKey(fromJson: _nullableFlag) final bool? reachable,
    final String engine,
    final String? reason,
    @JsonKey(name: 'road_factor') final double roadFactor,
    @JsonKey(name: 'avg_speed_kmh') final double avgSpeedKmh,
    @JsonKey(name: 'default_visit_minutes') final int defaultVisitMinutes,
    @JsonKey(name: 'max_stops') final int maxStops,
    @JsonKey(name: 'day_minutes') final int dayMinutes,
    @JsonKey(name: 'visit_days') final List<String> visitDays,
  }) = _$RouteEngineStatusImpl;
  const _RouteEngineStatus._() : super._();

  factory _RouteEngineStatus.fromJson(Map<String, dynamic> json) =
      _$RouteEngineStatusImpl.fromJson;

  @override
  @JsonKey(fromJson: _flag)
  bool get configured;
  @override
  @JsonKey(fromJson: _nullableFlag)
  bool? get reachable;
  @override
  String get engine;
  @override
  String? get reason;
  @override
  @JsonKey(name: 'road_factor')
  double get roadFactor;
  @override
  @JsonKey(name: 'avg_speed_kmh')
  double get avgSpeedKmh;
  @override
  @JsonKey(name: 'default_visit_minutes')
  int get defaultVisitMinutes;
  @override
  @JsonKey(name: 'max_stops')
  int get maxStops;
  @override
  @JsonKey(name: 'day_minutes')
  int get dayMinutes;
  @override
  @JsonKey(name: 'visit_days')
  List<String> get visitDays;

  /// Create a copy of RouteEngineStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteEngineStatusImplCopyWith<_$RouteEngineStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisitPlanImpl _$$VisitPlanImplFromJson(
  Map<String, dynamic> json,
) => _$VisitPlanImpl(
  name: json['name'] as String,
  visitDate: json['visit_date'] as String?,
  rep: json['rep'] as String? ?? '',
  repName: json['rep_name'] as String? ?? '',
  title: json['title'] as String? ?? '',
  status: json['status'] as String? ?? 'Draft',
  startMode: json['start_mode'] as String? ?? 'Current Location',
  startLabel: json['start_label'] as String? ?? '',
  startLatitude: (json['start_latitude'] as num?)?.toDouble(),
  startLongitude: (json['start_longitude'] as num?)?.toDouble(),
  plannedStartTime: json['planned_start_time'] as String?,
  defaultVisitMinutes: (json['default_visit_minutes'] as num?)?.toInt() ?? 20,
  returnToStart: json['return_to_start'] == null
      ? false
      : _flag(json['return_to_start']),
  totalStops: (json['total_stops'] as num?)?.toInt() ?? 0,
  totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
  totalDriveMinutes: (json['total_drive_minutes'] as num?)?.toInt() ?? 0,
  totalDurationMinutes: (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
  routeEngine: json['route_engine'] as String? ?? 'haversine',
  optimizedOn: json['optimized_on'] as String?,
  notes: json['notes'] as String? ?? '',
  canEdit: json['can_edit'] == null ? true : _flagTrue(json['can_edit']),
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => VisitStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VisitStop>[],
  geometry: (json['geometry'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
);

Map<String, dynamic> _$$VisitPlanImplToJson(_$VisitPlanImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'visit_date': instance.visitDate,
      'rep': instance.rep,
      'rep_name': instance.repName,
      'title': instance.title,
      'status': instance.status,
      'start_mode': instance.startMode,
      'start_label': instance.startLabel,
      'start_latitude': instance.startLatitude,
      'start_longitude': instance.startLongitude,
      'planned_start_time': instance.plannedStartTime,
      'default_visit_minutes': instance.defaultVisitMinutes,
      'return_to_start': instance.returnToStart,
      'total_stops': instance.totalStops,
      'total_distance_km': instance.totalDistanceKm,
      'total_drive_minutes': instance.totalDriveMinutes,
      'total_duration_minutes': instance.totalDurationMinutes,
      'route_engine': instance.routeEngine,
      'optimized_on': instance.optimizedOn,
      'notes': instance.notes,
      'can_edit': instance.canEdit,
      'stops': instance.stops,
      'geometry': instance.geometry,
    };

_$VisitStopImpl _$$VisitStopImplFromJson(Map<String, dynamic> json) =>
    _$VisitStopImpl(
      name: json['name'] as String,
      idx: (json['idx'] as num?)?.toInt() ?? 0,
      referenceDoctype: json['reference_doctype'] as String? ?? 'Lead',
      referenceName: json['reference_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      status: json['status'] as String? ?? 'Planned',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      mapsUrl: json['maps_url'] as String? ?? '',
      plannedTime: json['planned_time'] as String?,
      visitMinutes: (json['visit_minutes'] as num?)?.toInt() ?? 0,
      locked: json['locked'] == null ? false : _flag(json['locked']),
      legKm: (json['leg_km'] as num?)?.toDouble() ?? 0.0,
      legMinutes: (json['leg_minutes'] as num?)?.toInt() ?? 0,
      arrivedAt: json['arrived_at'] as String?,
      outcome: json['outcome'] as String? ?? '',
      journeyNote: json['journey_note'] as String?,
    );

Map<String, dynamic> _$$VisitStopImplToJson(_$VisitStopImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'idx': instance.idx,
      'reference_doctype': instance.referenceDoctype,
      'reference_name': instance.referenceName,
      'title': instance.title,
      'branch_name': instance.branchName,
      'area': instance.area,
      'status': instance.status,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'phone': instance.phone,
      'maps_url': instance.mapsUrl,
      'planned_time': instance.plannedTime,
      'visit_minutes': instance.visitMinutes,
      'locked': instance.locked,
      'leg_km': instance.legKm,
      'leg_minutes': instance.legMinutes,
      'arrived_at': instance.arrivedAt,
      'outcome': instance.outcome,
      'journey_note': instance.journeyNote,
    };

_$VisitTargetImpl _$$VisitTargetImplFromJson(Map<String, dynamic> json) =>
    _$VisitTargetImpl(
      referenceDoctype: json['reference_doctype'] as String? ?? 'Lead',
      referenceName: json['reference_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      mapsUrl: json['maps_url'] as String? ?? '',
      fitScore: (json['fit_score'] as num?)?.toDouble() ?? 0.0,
      stage: json['stage'] as String? ?? '',
      tier: json['tier'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isSpecialty: json['is_specialty'] == null
          ? false
          : _flag(json['is_specialty']),
      lastVisitDate: json['last_visit_date'] as String?,
      daysSinceVisit: (json['days_since_visit'] as num?)?.toInt(),
      nextFollowupDate: json['next_followup_date'] as String?,
      followupOverdue: json['followup_overdue'] == null
          ? false
          : _flag(json['followup_overdue']),
      priority: (json['priority'] as num?)?.toDouble() ?? 0.0,
      reasons:
          (json['reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$VisitTargetImplToJson(_$VisitTargetImpl instance) =>
    <String, dynamic>{
      'reference_doctype': instance.referenceDoctype,
      'reference_name': instance.referenceName,
      'title': instance.title,
      'branch_name': instance.branchName,
      'area': instance.area,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'phone': instance.phone,
      'maps_url': instance.mapsUrl,
      'fit_score': instance.fitScore,
      'stage': instance.stage,
      'tier': instance.tier,
      'category': instance.category,
      'is_specialty': instance.isSpecialty,
      'last_visit_date': instance.lastVisitDate,
      'days_since_visit': instance.daysSinceVisit,
      'next_followup_date': instance.nextFollowupDate,
      'followup_overdue': instance.followupOverdue,
      'priority': instance.priority,
      'reasons': instance.reasons,
    };

_$VisitSuggestionImpl _$$VisitSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$VisitSuggestionImpl(
  targets:
      (json['targets'] as List<dynamic>?)
          ?.map((e) => VisitTarget.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VisitTarget>[],
  engine: json['engine'] as String? ?? 'haversine',
  engineNote: json['engine_note'] as String?,
  totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
  totalDriveMinutes: (json['total_drive_minutes'] as num?)?.toInt() ?? 0,
  totalDurationMinutes: (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
  considered: (json['considered'] as num?)?.toInt() ?? 0,
  droppedForTime: (json['dropped_for_time'] as num?)?.toInt() ?? 0,
  dayMinutes: (json['day_minutes'] as num?)?.toInt() ?? 0,
  visitDate: json['visit_date'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$$VisitSuggestionImplToJson(
  _$VisitSuggestionImpl instance,
) => <String, dynamic>{
  'targets': instance.targets,
  'engine': instance.engine,
  'engine_note': instance.engineNote,
  'total_distance_km': instance.totalDistanceKm,
  'total_drive_minutes': instance.totalDriveMinutes,
  'total_duration_minutes': instance.totalDurationMinutes,
  'considered': instance.considered,
  'dropped_for_time': instance.droppedForTime,
  'day_minutes': instance.dayMinutes,
  'visit_date': instance.visitDate,
  'note': instance.note,
};

_$RouteEngineStatusImpl _$$RouteEngineStatusImplFromJson(
  Map<String, dynamic> json,
) => _$RouteEngineStatusImpl(
  configured: json['configured'] == null ? false : _flag(json['configured']),
  reachable: _nullableFlag(json['reachable']),
  engine: json['engine'] as String? ?? 'straight_line',
  reason: json['reason'] as String?,
  roadFactor: (json['road_factor'] as num?)?.toDouble() ?? 1.35,
  avgSpeedKmh: (json['avg_speed_kmh'] as num?)?.toDouble() ?? 22.0,
  defaultVisitMinutes: (json['default_visit_minutes'] as num?)?.toInt() ?? 20,
  maxStops: (json['max_stops'] as num?)?.toInt() ?? 12,
  dayMinutes: (json['day_minutes'] as num?)?.toInt() ?? 360,
  visitDays:
      (json['visit_days'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$$RouteEngineStatusImplToJson(
  _$RouteEngineStatusImpl instance,
) => <String, dynamic>{
  'configured': instance.configured,
  'reachable': instance.reachable,
  'engine': instance.engine,
  'reason': instance.reason,
  'road_factor': instance.roadFactor,
  'avg_speed_kmh': instance.avgSpeedKmh,
  'default_visit_minutes': instance.defaultVisitMinutes,
  'max_stops': instance.maxStops,
  'day_minutes': instance.dayMinutes,
  'visit_days': instance.visitDays,
};

_$RoutePreviewImpl _$$RoutePreviewImplFromJson(Map<String, dynamic> json) =>
    _$RoutePreviewImpl(
      stops:
          (json['stops'] as List<dynamic>?)
              ?.map((e) => PreviewStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PreviewStop>[],
      order:
          (json['order'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      engine: json['engine'] as String? ?? 'haversine',
      engineNote: json['engine_note'] as String?,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      totalDriveMinutes: (json['total_drive_minutes'] as num?)?.toInt() ?? 0,
      totalDurationMinutes:
          (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RoutePreviewImplToJson(_$RoutePreviewImpl instance) =>
    <String, dynamic>{
      'stops': instance.stops,
      'order': instance.order,
      'engine': instance.engine,
      'engine_note': instance.engineNote,
      'total_distance_km': instance.totalDistanceKm,
      'total_drive_minutes': instance.totalDriveMinutes,
      'total_duration_minutes': instance.totalDurationMinutes,
      'skipped': instance.skipped,
    };

_$PreviewStopImpl _$$PreviewStopImplFromJson(Map<String, dynamic> json) =>
    _$PreviewStopImpl(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      referenceDoctype: json['reference_doctype'] as String? ?? 'Lead',
      referenceName: json['reference_name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      mapsUrl: json['maps_url'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      legKm: (json['leg_km'] as num?)?.toDouble() ?? 0.0,
      legMinutes: (json['leg_minutes'] as num?)?.toInt() ?? 0,
      locked: json['locked'] == null ? false : _flag(json['locked']),
    );

Map<String, dynamic> _$$PreviewStopImplToJson(_$PreviewStopImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'branch_name': instance.branchName,
      'area': instance.area,
      'reference_doctype': instance.referenceDoctype,
      'reference_name': instance.referenceName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'phone': instance.phone,
      'maps_url': instance.mapsUrl,
      'position': instance.position,
      'leg_km': instance.legKm,
      'leg_minutes': instance.legMinutes,
      'locked': instance.locked,
    };

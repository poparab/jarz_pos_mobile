import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:latlong2/latlong.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../geo/presentation/widgets/location_preview_map.dart';
import '../data/order_timeline.dart';
import '../data/order_timeline_repository.dart';

/// The timeline of [invoiceId], or null when there is nothing to show: the user
/// lacks the courier-map role (403), the courier app is not installed (404), or
/// the call failed. The section hides quietly in every one of those cases — a
/// missing timeline must never put an error on an order card.
final orderTimelineProvider = FutureProvider.autoDispose
    .family<OrderTimeline?, String>((ref, invoiceId) async {
      try {
        return await ref
            .read(orderTimelineRepositoryProvider)
            .getTimeline(invoiceId);
      } catch (_) {
        return null;
      }
    });

/// "Delivery timeline" block for order details: a vertical list of stamped
/// events, the per-stage minutes against their targets, and a small map of where
/// the located events happened.
///
/// The caller is responsible for the role gate
/// (`canViewLiveCourierMapProvider`) and for only mounting this once the card is
/// expanded, so the board does not fetch one timeline per card.
class OrderTimelineSection extends ConsumerWidget {
  const OrderTimelineSection({super.key, required this.invoiceId});

  final String invoiceId;

  static const sectionKey = ValueKey('order_timeline_section');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderTimelineProvider(invoiceId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (timeline) {
        if (timeline == null || timeline.isEmpty) {
          return const SizedBox.shrink();
        }
        return OrderTimelineView(
          key: sectionKey,
          timeline: timeline,
          tileProvider: ref.watch(locationTileProviderProvider),
        );
      },
    );
  }
}

/// Pure rendering of an [OrderTimeline]; separate from the provider so tests can
/// pump it with a fixture.
class OrderTimelineView extends StatelessWidget {
  const OrderTimelineView({super.key, required this.timeline, this.tileProvider});

  final OrderTimeline timeline;

  /// Injectable tile source (see [locationTileProviderProvider]).
  final TileProvider? tileProvider;

  /// Row keys carry the row index (`order_timeline_event_row_0`, ...): sibling
  /// widgets cannot share one key.
  static const eventRowKeyPrefix = 'order_timeline_event_row_';
  static const segmentRowKeyPrefix = 'order_timeline_segment_row_';
  static const overKey = ValueKey('order_timeline_over');
  static const totalKey = ValueKey('order_timeline_total');
  static const mapKey = ValueKey('order_timeline_map');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final courier = timeline.courierName ?? timeline.courierParty;
    final located = timeline.locatedEvents;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.courierLaunchTimelineTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (timeline.totalMinutes != null)
                Text(
                  l10n.courierLaunchTimelineTotal(timeline.totalMinutes!),
                  key: totalKey,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (courier != null) ...[
            const SizedBox(height: 2),
            Text(
              l10n.courierLaunchTimelineCourier(courier),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          for (var i = 0; i < timeline.events.length; i++)
            _EventRow(
              key: ValueKey('${OrderTimelineView.eventRowKeyPrefix}$i'),
              event: timeline.events[i],
              isFirst: i == 0,
              isLast: i == timeline.events.length - 1,
            ),
          if (timeline.segments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.courierLaunchTimelineStages,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < timeline.segments.length; i++)
              _SegmentRow(
                key: ValueKey('${OrderTimelineView.segmentRowKeyPrefix}$i'),
                segment: timeline.segments[i],
              ),
          ],
          if (located.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.courierLaunchTimelineMapTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _TimelineMap(
              key: mapKey,
              events: located,
              tileProvider: tileProvider,
            ),
          ],
        ],
      ),
    );
  }
}

/// Localized label for an event key, falling back to the server's label for a
/// key this build does not know.
String timelineEventLabel(AppLocalizations l10n, TimelineEvent event) {
  switch (event.key) {
    case TimelineEventKey.created:
      return l10n.courierLaunchEventCreated;
    case TimelineEventKey.accepted:
      return l10n.courierLaunchEventAccepted;
    case TimelineEventKey.inProgress:
      return l10n.courierLaunchEventInProgress;
    case TimelineEventKey.outForDelivery:
      return l10n.courierLaunchEventOutForDelivery;
    case TimelineEventKey.leftBranch:
      return l10n.courierLaunchEventLeftBranch;
    case TimelineEventKey.legStarted:
      return l10n.courierLaunchEventLegStarted;
    case TimelineEventKey.arrived:
      return l10n.courierLaunchEventArrived;
    case TimelineEventKey.delivered:
      return l10n.courierLaunchEventDelivered;
    case TimelineEventKey.failed:
      return l10n.courierLaunchEventFailed;
    case TimelineEventKey.backAtBranch:
      return l10n.courierLaunchEventBackAtBranch;
    default:
      return event.label;
  }
}

/// Localized label for a segment key, falling back to the server's label.
String timelineSegmentLabel(AppLocalizations l10n, TimelineSegment segment) {
  switch (segment.key) {
    case TimelineSegmentKey.prep:
      return l10n.courierLaunchSegmentPrep;
    case TimelineSegmentKey.dispatchWait:
      return l10n.courierLaunchSegmentDispatchWait;
    case TimelineSegmentKey.travel:
      return l10n.courierLaunchSegmentTravel;
    case TimelineSegmentKey.atDoor:
      return l10n.courierLaunchSegmentAtDoor;
    case TimelineSegmentKey.returnTrip:
      return l10n.courierLaunchSegmentReturn;
    default:
      return segment.label;
  }
}

Color _eventColor(ThemeData theme, TimelineEvent event) {
  switch (event.key) {
    case TimelineEventKey.delivered:
      return Colors.green.shade700;
    case TimelineEventKey.failed:
      return theme.colorScheme.error;
    default:
      return theme.colorScheme.primary;
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    super.key,
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = _eventColor(theme, event);
    final at = event.at;
    final time = at == null
        ? '—'
        : DateFormat('h:mm a', l10n.localeName).format(at);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 64,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: Text(
                timelineEventLabel(l10n, event),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({super.key, required this.segment});

  final TimelineSegment segment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final over = segment.over;
    final color = over ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final minutes = segment.minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              timelineSegmentLabel(l10n, segment),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (over) ...[
            Container(
              key: OrderTimelineView.overKey,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.courierLaunchTimelineOver,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            minutes == null ? '—' : l10n.courierLaunchTimelineMinutes(minutes),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: over ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (segment.targetMinutes != null) ...[
            const SizedBox(width: 8),
            Text(
              l10n.courierLaunchTimelineTarget(segment.targetMinutes!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small non-interactive map of the located events, numbered in order.
class _TimelineMap extends StatelessWidget {
  const _TimelineMap({super.key, required this.events, this.tileProvider});

  final List<TimelineEvent> events;
  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = [
      for (final e in events) LatLng(e.latitude!, e.longitude!),
    ];
    final single = points.length == 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 15,
            initialCameraFit: single
                ? null
                : CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(points),
                    padding: const EdgeInsets.all(28),
                    maxZoom: 17,
                  ),
            minZoom: 4,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.jarz.pos',
              maxZoom: 19,
              tileProvider: tileProvider,
            ),
            PolylineLayer(
              polylines: [
                if (!single)
                  Polyline(
                    points: points,
                    strokeWidth: 3,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (var i = 0; i < events.length; i++)
                  Marker(
                    point: points[i],
                    width: 22,
                    height: 22,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _eventColor(theme, events[i]),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

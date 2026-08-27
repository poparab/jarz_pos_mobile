import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../leads/presentation/leads_theme.dart';
import '../../../leads/state/my_location_notifier.dart';
import '../../state/visit_builder_notifier.dart';
import 'route_map.dart';

/// The day as it currently stands, while the rep is still building it.
///
/// This is the difference between a shopping list and a plan. The stops are
/// ordered and costed by the server on every change, so the map line, the
/// sequence and the day's length are the real ones — not a client-side
/// approximation that disagrees with what gets saved.
///
/// Dragging a stop pins the order: the server is then asked to cost exactly
/// that sequence rather than re-solve it. "Optimise" hands the order back.
class RoutePreviewPanel extends ConsumerWidget {
  const RoutePreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(visitBuilderProvider);
    final notifier = ref.read(visitBuilderProvider.notifier);
    final preview = state.preview;

    if (!state.hasSelection) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Column(
          children: [
            Icon(Icons.route, size: 34, color: theme.hintColor),
            const SizedBox(height: 10),
            Text(
              l10n.visitEmptyDayHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    final located = ref.watch(myLocationProvider).position;
    final start = state.useMyLocation && located != null
        ? LatLng(located.latitude, located.longitude)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null && preview.stops.isNotEmpty)
          RouteMapView(
            height: 200,
            start: start,
            stops: [
              for (final stop in preview.stops)
                RouteMapStop(
                  latitude: stop.latitude,
                  longitude: stop.longitude,
                ),
            ],
          ),

        // Totals + the order control.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: preview == null
                    ? Text(
                        state.previewing
                            ? l10n.visitCostingDay
                            : l10n.visitSelectedCount(state.selectedCount),
                        style: theme.textTheme.bodySmall,
                      )
                    : Wrap(
                        spacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.visitStopsCount(preview.stops.length),
                              style: theme.textTheme.bodySmall),
                          Text(
                              l10n.visitDistanceKm(
                                  preview.totalDistanceKm.toStringAsFixed(1)),
                              style: theme.textTheme.bodySmall),
                          Text(l10n.visitDayTotal(preview.durationLabel),
                              style: theme.textTheme.bodySmall),
                          if (state.previewing)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
              ),
              if (state.isManualOrder)
                TextButton.icon(
                  onPressed: notifier.optimise,
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: Text(l10n.visitOptimise),
                ),
            ],
          ),
        ),

        if (state.isManualOrder)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.visitManualOrderNote,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
            ),
          ),

        if (preview != null && preview.skipped > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.visitSkippedNoPin(preview.skipped),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ),

        // The ordered stops. Reorderable, because the whole point is that the
        // rep can arrange the day rather than accept it.
        if (preview != null && preview.stops.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: preview.stops.length,
            onReorder: notifier.moveStop,
            itemBuilder: (context, index) {
              final stop = preview.stops[index];
              return ListTile(
                key: ValueKey(stop.key),
                dense: true,
                leading: CircleAvatar(
                  radius: 13,
                  backgroundColor: LeadsTheme.sahelBlue,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(stop.displayTitle,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [
                    if (stop.area.trim().isNotEmpty) stop.area,
                    if (stop.legKm > 0)
                      l10n.visitLeg(
                          stop.legKm.toStringAsFixed(1), stop.legMinutes),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: IconButton(
                  tooltip: l10n.visitRemoveStop,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => notifier.removeKey(stop.key),
                ),
              );
            },
          )
        else if (state.previewing)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../data/models/fleet_models.dart';
import '../fleet_labels.dart';

/// "Updated 40 sec ago · 3 couriers on the map", plus the two warnings that
/// must never be silent: a failed refresh, and stale dots on the map.
class FleetStatusBar extends StatelessWidget {
  const FleetStatusBar({
    super.key,
    required this.snapshot,
    required this.now,
    required this.isRefreshing,
    required this.refreshFailed,
  });

  final FleetSnapshot snapshot;
  final DateTime now;
  final bool isRefreshing;
  final bool refreshFailed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final age = now.difference(snapshot.fetchedAt);
    final worst = snapshot.worstFreshnessAt(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isRefreshing
                        ? l10n.fleetUpdating
                        : l10n.fleetUpdatedAgo(
                            fleetRelativeAge(
                              l10n,
                              age.isNegative ? Duration.zero : age,
                            ),
                          ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                l10n.fleetCouriersOnMap(snapshot.located.length),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (refreshFailed) ...[
            const SizedBox(height: 6),
            _Warning(
              color: fleetFreshnessColor(FleetFreshness.stale),
              message: l10n.fleetRefreshFailed,
            ),
          ],
          if (worst == FleetFreshness.stale) ...[
            const SizedBox(height: 6),
            _Warning(
              color: fleetFreshnessColor(FleetFreshness.stale),
              message: l10n.fleetStaleWarning,
            ),
          ],
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.color, required this.message});

  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Spells out what each dot colour means, in minutes derived from the TTL the
/// server actually returned rather than a hardcoded guess.
class FleetLegend extends StatelessWidget {
  const FleetLegend({super.key, required this.ttl});

  final Duration ttl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final ageingFrom = fleetFreshnessThreshold(
      FleetFreshness.ageing,
      ttl,
    ).inMinutes;
    final staleFrom = fleetFreshnessThreshold(
      FleetFreshness.stale,
      ttl,
    ).inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fleetLegendTitle,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _LegendEntry(
                freshness: FleetFreshness.fresh,
                label: l10n.fleetLegendFresh(ageingFrom),
              ),
              _LegendEntry(
                freshness: FleetFreshness.ageing,
                label: l10n.fleetLegendAgeing(ageingFrom, staleFrom),
              ),
              _LegendEntry(
                freshness: FleetFreshness.stale,
                label: l10n.fleetLegendStale(staleFrom),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.freshness, required this.label});

  final FleetFreshness freshness;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = fleetFreshnessColor(freshness);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Shown above the map when some couriers are reporting in but cannot be
/// placed — otherwise they would silently vanish from the dispatcher's count.
class FleetUnlocatedBanner extends StatelessWidget {
  const FleetUnlocatedBanner({super.key, required this.couriers});

  final List<CourierPosition> couriers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final names = couriers
        .map((courier) => courier.displayName)
        .where((name) => name.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: kFleetUnknownColor.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: kFleetUnknownColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.fleetUnlocatedBanner(couriers.length),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (names.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 22, top: 2),
              child: Text(
                l10n.fleetEmptyNoPositionsNames(names.join('، ')),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The tap target's detail card: who, where, how old, how accurate.
class CourierPositionSheet extends StatelessWidget {
  const CourierPositionSheet({
    super.key,
    required this.courier,
    required this.now,
    required this.onClose,
  });

  final CourierPosition courier;
  final DateTime now;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final age = courier.ageAt(now);
    final freshness = courier.freshnessAt(now);
    final color = freshness == null
        ? kFleetUnknownColor
        : fleetFreshnessColor(freshness);
    final accuracy = courier.accuracyMeters;

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          courier.displayName.isEmpty
                              ? l10n.commonNotSpecified
                              : courier.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (freshness != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            fleetFreshnessLabel(l10n, freshness),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SheetRow(
                    label: l10n.fleetBranchLabel,
                    value: courier.branch.isEmpty
                        ? l10n.fleetBranchUnknown
                        : courier.branch,
                  ),
                  _SheetRow(
                    label: l10n.fleetLastFixLabel,
                    value: fleetRelativeAge(l10n, age),
                    valueColor: color,
                  ),
                  _SheetRow(
                    label: l10n.fleetAccuracyLabel,
                    value: accuracy == null
                        ? l10n.fleetAccuracyUnknown
                        : l10n.fleetAccuracyValue(
                            formatCount(context, accuracy.round()),
                          ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.commonClose,
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/visit_plans_notifier.dart';

/// Says whether the distances on screen are real or estimated.
///
/// This is not decoration. "34 km" from a road network and "34 km" from a
/// straight line inflated by a detour factor look identical and mean different
/// things — the first is a promise, the second is a guess good enough to
/// order stops by. A rep who plans a day against an estimate and finds it
/// takes 40 minutes longer needs to have been told which one they were
/// reading.
///
/// Tapping it explains *why* estimates are in play, because "no routing
/// server configured" and "the routing server is down" present identically and
/// need completely different fixes.
class RouteEngineBadge extends ConsumerWidget {
  const RouteEngineBadge({super.key, this.compact = true});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(routeEngineStatusProvider).valueOrNull;
    if (status == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final road = status.usesRoadDistances;
    final color = road ? theme.colorScheme.primary : theme.hintColor;
    final icon = road ? Icons.alt_route : Icons.straighten;

    return Tooltip(
      message: status.summary,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _explain(context, ref, status.summary, status.reason),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text(
                  status.summary,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _explain(
    BuildContext context,
    WidgetRef ref,
    String summary,
    String? reason,
  ) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(summary),
        content: Text(
          reason == null || reason.isEmpty
              ? l10n.visitEngineRoadExplained
              : '$reason\n\n${l10n.visitEngineEstimateExplained}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.invalidate(routeEngineStatusProvider);
              Navigator.of(context).pop();
            },
            child: Text(l10n.visitEngineRecheck),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }
}

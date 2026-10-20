import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../data/weekly_count_models.dart';
import '../weekly_count_format.dart';
import '../weekly_count_providers.dart';

/// How often a home screen left open re-checks. The status is cached for
/// [weeklyCountStatusMaxAge], so this only fetches when that has run out.
const _bannerPollInterval = Duration(minutes: 5);

/// "Weekly count due — X days left" at the top of the home screens.
///
/// Shows only for a member branch that still owes this week's count (due or
/// rejected). Amber normally; red on the last day, after a missed week, or
/// for a rejected count. Tapping opens `/weekly-count`. It blocks nothing,
/// and renders nothing when there is nothing to count or the status failed.
class WeeklyCountBanner extends ConsumerStatefulWidget {
  const WeeklyCountBanner({super.key});

  @override
  ConsumerState<WeeklyCountBanner> createState() => _WeeklyCountBannerState();
}

class _WeeklyCountBannerState extends ConsumerState<WeeklyCountBanner>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIfStale());
    _timer = Timer.periodic(_bannerPollInterval, (_) => _refreshIfStale());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshIfStale();
  }

  void _refreshIfStale() {
    if (!mounted) return;
    refreshWeeklyCountStatusIfStale(ref);
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(weeklyCountStatusProvider).valueOrNull;
    if (status == null || !status.hasDue) return const SizedBox.shrink();
    return WeeklyCountBannerBody(
      status: status,
      onTap: () => context.push(AppRoutes.weeklyCount),
    );
  }
}

/// The banner's look, split out so it can be tested without a provider.
class WeeklyCountBannerBody extends StatelessWidget {
  const WeeklyCountBannerBody({
    super.key,
    required this.status,
    required this.onTap,
  });

  final WeeklyCountStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final urgent = status.urgent;
    final due = status.dueMemberBranches;
    final String text;
    if (status.hasRejected) {
      text = l10n.weeklyCountBannerRejected;
    } else if (due.any((b) => b.lastDay) || status.daysLeft <= 0) {
      text = l10n.weeklyCountBannerLastDay;
    } else {
      text = l10n.weeklyCountBannerDue(status.daysLeft);
    }
    final fg = urgent ? WeeklyCountColors.red : WeeklyCountColors.amber;
    final bg = urgent ? WeeklyCountColors.redBg : WeeklyCountColors.amberBg;
    // Name the branch only when the user owes more than one; one branch is
    // obvious.
    final branches = due.length > 1
        ? due.map((b) => b.posProfile).join('، ')
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: fg.withValues(alpha: 0.5), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('weekly-count-banner'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  urgent ? Icons.warning_amber_rounded : Icons.inventory_2,
                  color: fg,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (branches != null)
                        Text(
                          branches,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

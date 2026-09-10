import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../state/base_production_providers.dart';
import '../state/production_basket_notifier.dart';
import '../state/production_providers.dart';
import '../state/running_batches_notifier.dart';
import 'screens/base_production_tab.dart';
import 'screens/daily_plan_tab.dart';
import 'screens/production_batch_tab.dart';
import 'screens/production_plan_tab.dart';
import 'screens/production_running_tab.dart';
import 'widgets/recent_work_orders_sheet.dart';

/// The Production Board.
///
/// A thin five-tab host: Daily is the morning jar plan, Plan answers "what
/// should we make", Batch holds what has been queued, Bases makes the
/// sub-assemblies the jars are built from, and Running holds what is on the
/// floor right now. All the state lives in providers, so every tab stays
/// independently loadable and the basket survives navigation.
class ManufacturingScreen extends ConsumerStatefulWidget {
  const ManufacturingScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ManufacturingScreen> createState() =>
      _ManufacturingScreenState();
}

class _ManufacturingScreenState extends ConsumerState<ManufacturingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: kProductionTabCount,
      vsync: this,
      // Deep-linked (`/manufacturing?tab=N`), so an index from an older link
      // is clamped rather than thrown.
      initialIndex: widget.initialTab.clamp(0, kProductionTabCount - 1),
    );
    // Hive opens asynchronously, so the basket is hydrated after first frame
    // rather than in the notifier's build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(productionBasketProvider.notifier).restore();
      // A tab request left set while no host was listening would otherwise
      // deaden the next one: `ref.listen` does not replay the current value on
      // subscribe, and re-assigning the same int notifies nobody
      // (`identical(2, 2)`), so "View batch" would be dead for the rest of the
      // app process. Clearing on mount keeps the one-shot one-shot.
      ref.read(productionTabRequestProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Role-derived and synchronous. The old screen gated on
    // `managerAccessProvider`, which fires a manager-dashboard request on every
    // open and admits roles the production API rejects — so a user could see
    // the screen and then fail every call on it.
    final allowed = ref.watch(canAccessProductionBoardProvider);
    if (!allowed) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.productionBoardTitle)),
        drawer: const AppDrawer(),
        body: Center(child: Text(l10n.productionAccessDenied)),
      );
    }

    final basket = ref.watch(productionBasketProvider);
    final isNarrow = MediaQuery.sizeOf(context).width < 420;
    final runningCount =
        ref.watch(runningBatchesProvider).valueOrNull?.length ?? 0;

    // The Batch tab asks to be moved here once a start succeeds — the batch has
    // physically left the queue at that point, so leaving the user staring at
    // the list it just emptied reads as "nothing happened".
    ref.listen<int?>(productionTabRequestProvider, (_, next) {
      if (next == null) return;
      if (next >= 0 && next < _tabController.length) {
        _tabController.animateTo(next);
      }
      // Cleared immediately so the same request cannot fire twice.
      ref.read(productionTabRequestProvider.notifier).state = null;
    });

    return Scaffold(
      appBar: AppBar(
        // A phone gives the title ~190 dp beside a menu and three actions,
        // and "Production Board" at the default 20 sp needs more than that —
        // it rendered as "Production Bo…". One step down the type scale fits
        // the whole name, which is worth more here than two points of size.
        title: Text(
          l10n.productionBoardTitle,
          style: isNarrow ? Theme.of(context).textTheme.titleMedium : null,
        ),
        actions: [
          // The return leg of Today's "Full board". Today navigates with `go`,
          // which replaces rather than pushes, so without this the only way
          // back to the screen the floor actually opens is the drawer — where
          // the tile reads "Production Board" and lands somewhere else again.
          //
          // Labelled where there is room and icon-only where there is not: a
          // phone cannot hold the title, a labelled button and two icons, and
          // the half that must not be dropped is the screen's own name.
          if (isNarrow)
            IconButton(
              tooltip: l10n.productionTodayTitle,
              icon: const Icon(Icons.today_outlined),
              onPressed: () => context.go(AppRoutes.productionToday),
            )
          else
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.productionToday),
              icon: const Icon(Icons.today_outlined, size: 18),
              label: Text(l10n.productionTodayTitle),
            ),
          IconButton(
            tooltip: l10n.manufacturingRecentWorkOrdersTooltip,
            icon: const Icon(Icons.history),
            onPressed: () => showRecentWorkOrders(context, ref),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh),
            onPressed: _refreshVisibleTab,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          // Five fixed tabs divide a 360 dp phone into 72 dp each, and
          // "Running" plus its count badge needs 79 — so the two tabs that
          // carry a badge were the two whose labels got clipped, on the
          // narrowest screen the floor actually holds. Scrolling the bar
          // below that width keeps every label whole; a tablet still gets
          // the full five across.
          isScrollable: isNarrow,
          tabAlignment: isNarrow ? TabAlignment.start : null,
          tabs: [
            Tab(text: l10n.productionTabDaily),
            Tab(text: l10n.productionTabPlan),
            Tab(
              child: _TabLabel(
                text: l10n.productionTabBatch,
                count: basket.isNotEmpty ? basket.lines.length : 0,
              ),
            ),
            Tab(text: l10n.productionTabBases),
            Tab(
              child: _TabLabel(
                text: l10n.productionTabRunning,
                count: runningCount,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DailyPlanTab(),
          ProductionPlanTab(),
          ProductionBatchTab(),
          BaseProductionTab(),
          ProductionRunningTab(),
        ],
      ),
    );
  }

  /// Refreshes whichever list is on screen rather than everything.
  ///
  /// Recomputing the ranked board costs a BOM explosion per item server-side,
  /// so firing it while the user is looking at running batches is a slow answer
  /// to a question nobody asked.
  void _refreshVisibleTab() {
    // The policy is keep-alive, so a single failed probe would otherwise pin
    // this tablet to today-only for the rest of the app process — silently,
    // since every consumer falls back rather than showing the error. Refresh
    // is the one gesture a user already makes when a screen looks wrong, so a
    // failure costs one tap instead of a restart. A successful policy is left
    // alone: it does not change while a batch is being queued.
    unawaited(refreshProductionPolicy(ref));

    switch (_tabController.index) {
      case kProductionRunningTabIndex:
        ref.read(runningBatchesProvider.notifier).refresh();
      case kProductionBasesTabIndex:
        ref.read(baseItemsProvider.notifier).refresh();
      default:
        ref.read(productionSuggestionsProvider.notifier).refresh();
    }
  }
}

/// A tab label with an optional count badge.
class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.text, required this.count});

  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Badge(label: Text('$count')),
        ],
      ],
    );
  }
}

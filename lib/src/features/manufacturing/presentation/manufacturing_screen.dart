import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../state/production_basket_notifier.dart';
import '../state/production_providers.dart';
import 'screens/production_batch_tab.dart';
import 'screens/production_plan_tab.dart';
import 'widgets/recent_work_orders_sheet.dart';

/// The Production Board.
///
/// A thin two-tab host: Plan answers "what should we make", Batch holds what
/// has been queued. All the state lives in providers, so both tabs stay
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
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    // Hive opens asynchronously, so the basket is hydrated after first frame
    // rather than in the notifier's build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(productionBasketProvider.notifier).restore();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productionBoardTitle),
        actions: [
          IconButton(
            tooltip: l10n.manufacturingRecentWorkOrdersTooltip,
            icon: const Icon(Icons.history),
            onPressed: () => showRecentWorkOrders(context, ref),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(productionSuggestionsProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.productionTabPlan),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.productionTabBatch),
                  if (basket.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Badge(label: Text('${basket.lines.length}')),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [ProductionPlanTab(), ProductionBatchTab()],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/network/user_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/localization/localization_extensions.dart';
import 'screens/stock_reports_screen.dart';

/// The Reports hub: a responsive grid of destination cards. Six of them push
/// the new analytics dashboards (via `context.push`, so each keeps a back
/// button and returns here); the two stock reports (Final Products, Materials)
/// open the preserved [StockReportsScreen].
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final roles = ref.watch(userRolesFutureProvider).valueOrNull;

    // Every tile is gated on the role set its own endpoint accepts. The six
    // analytics dashboards and Final Products all call `_ensure_jarz_manager`
    // (JARZ Manager or Administrator — NOT System Manager, NOT POS Manager);
    // Materials & Consumables calls `_ensure_materials_report_access`, which
    // takes the whole line-manager tier. Gating the hub on anything wider is how
    // a tile ends up answering "Not permitted" on every tap.
    final canViewAllReports = roles?.canViewAllReports ?? false;
    final canViewMaterials = roles?.canViewMaterialsReport ?? false;

    void openStock(int tab) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StockReportsScreen(initialTab: tab),
          ),
        );

    final destinations = <_ReportDestination>[
      _ReportDestination(
        icon: Icons.local_shipping_outlined,
        color: Colors.indigo,
        title: l10n.reportShippingTitle,
        subtitle: l10n.reportShippingSubtitle,
        onTap: () => context.push(AppRoutes.reportsShipping),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.inventory_2_outlined,
        color: Colors.teal,
        title: l10n.reportInventoryTitle,
        subtitle: l10n.reportInventorySubtitle,
        onTap: () => context.push(AppRoutes.reportsInventory),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.category_outlined,
        color: Colors.deepPurple,
        title: l10n.reportProductTitle,
        subtitle: l10n.reportProductSubtitle,
        onTap: () => context.push(AppRoutes.reportsProduct),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.groups_outlined,
        color: Colors.orange,
        title: l10n.reportCustomerTitle,
        subtitle: l10n.reportCustomerSubtitle,
        onTap: () => context.push(AppRoutes.reportsCustomer),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.insights_outlined,
        color: Colors.blueGrey,
        title: l10n.reportExecutiveTitle,
        subtitle: l10n.reportExecutiveSubtitle,
        onTap: () => context.push(AppRoutes.reportsExecutive),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.handshake_outlined,
        color: Colors.brown,
        title: l10n.reportB2bTitle,
        subtitle: l10n.reportB2bSubtitle,
        onTap: () => context.push(AppRoutes.reportsB2b),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.widgets_outlined,
        color: Colors.green,
        title: l10n.reportsFinalProducts,
        subtitle: l10n.reportsFinalProductsDesc,
        onTap: () => openStock(0),
        visible: canViewAllReports,
      ),
      _ReportDestination(
        icon: Icons.science_outlined,
        color: Colors.blue,
        title: l10n.reportsMaterials,
        subtitle: l10n.reportsMaterialsDesc,
        onTap: () => openStock(1),
        visible: canViewMaterials,
      ),
    ];

    final visibleDestinations =
        destinations.where((d) => d.visible).toList(growable: false);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: roles == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossCount =
                    ResponsiveUtils.getGridColumns(context, min: 1, max: 4);
                const spacing = 12.0;
                final cardWidth =
                    (constraints.maxWidth - 16 - spacing * (crossCount - 1)) /
                        crossCount;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final d in visibleDestinations)
                        SizedBox(
                          width: cardWidth,
                          child: _ReportCard(destination: d),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _ReportDestination {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Whether the current user's roles satisfy this report's own backend gate.
  final bool visible;

  const _ReportDestination({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.visible,
  });
}

class _ReportCard extends StatelessWidget {
  final _ReportDestination destination;
  const _ReportCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: destination.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: destination.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(destination.icon, color: destination.color),
              ),
              const SizedBox(height: 12),
              Text(
                destination.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                destination.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

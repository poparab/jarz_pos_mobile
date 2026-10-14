import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../fleet/presentation/fleet_labels.dart';
import '../../user_admin/presentation/widgets/user_admin_widgets.dart';
import '../data/courier_alert_models.dart';
import '../state/courier_alerts_providers.dart';
import 'courier_alert_labels.dart';
import 'courier_alert_sheet.dart';

/// Courier anomaly alerts (Detour, Speeding, Mock GPS ...), newest first.
///
/// Visible to the courier-map tier only, matching the server gate on
/// `jarz_courier.api.alerts`. The list refreshes itself every minute while the
/// screen is on top and the app is in the foreground; a push of type
/// `courier_alert` refreshes it sooner (see the order-alert bridge).
class CourierAlertsScreen extends ConsumerStatefulWidget {
  const CourierAlertsScreen({super.key});

  /// How often the visible list re-asks the server.
  static const refreshInterval = Duration(seconds: 60);

  @override
  ConsumerState<CourierAlertsScreen> createState() =>
      _CourierAlertsScreenState();
}

class _CourierAlertsScreenState extends ConsumerState<CourierAlertsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(CourierAlertsScreen.refreshInterval, (_) {
      if (!mounted || _lifecycle != AppLifecycleState.resumed) return;
      _reload();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasBackground = _lifecycle != AppLifecycleState.resumed;
    _lifecycle = state;
    // Coming back after a while away: the list is stale, refresh at once.
    if (state == AppLifecycleState.resumed && wasBackground && mounted) {
      _reload();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _reload() {
    ref.invalidate(courierAlertsProvider);
    ref.invalidate(courierAlertCountsProvider);
  }

  Future<void> _refresh() async {
    ref.invalidate(courierAlertCountsProvider);
    ref.invalidate(courierAlertsProvider);
    await ref.read(courierAlertsProvider.future);
  }

  Future<void> _open(CourierAlert alert) async {
    final changed = await showCourierAlertSheet(context, alert);
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allowed = ref.watch(canViewLiveCourierMapProvider);
    final async = ref.watch(courierAlertsProvider);

    Widget body;
    if (!allowed) {
      body = UserAdminMessage(
        icon: Icons.lock_outline,
        message: l10n.courierAlertsNoAccess,
      );
    } else {
      body = async.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => UserAdminErrorPanel(
          error: e,
          onRetry: () => ref.invalidate(courierAlertsProvider),
        ),
        data: (result) => RefreshIndicator(
          onRefresh: _refresh,
          child: _AlertsList(result: result, onOpen: _open),
        ),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.managerMenuTooltip,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(l10n.courierAlertsTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: allowed ? _reload : null,
          ),
        ],
      ),
      body: body,
    );
  }
}

class _AlertsList extends ConsumerWidget {
  const _AlertsList({required this.result, required this.onOpen});

  final CourierAlertsResult result;
  final void Function(CourierAlert alert) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final openOnly = ref.watch(courierAlertsOpenOnlyProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.courierAlertsFilterOpen),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.courierAlertsFilterAll),
                      ),
                    ],
                    selected: {openOnly},
                    onSelectionChanged: (s) =>
                        ref.read(courierAlertsOpenOnlyProvider.notifier).state =
                            s.first,
                  ),
                  UserAdminTag(
                    text: l10n.courierAlertsOpenCount(result.openCount),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (result.highCount > 0)
                    UserAdminTag(
                      text: l10n.courierAlertsHighCount(result.highCount),
                      color: courierAlertSeverityColor(
                        CourierAlertSeverity.high,
                      ),
                      icon: Icons.priority_high,
                    ),
                ],
              ),
            ),
            if (result.alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Text(
                    openOnly
                        ? l10n.courierAlertsEmptyOpen
                        : l10n.courierAlertsEmptyAll,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            for (final alert in result.alerts)
              CourierAlertTile(
                key: ValueKey(alert.name),
                alert: alert,
                onTap: () => onOpen(alert),
              ),
          ],
        ),
      ),
    );
  }
}

/// One alert row: severity bar, type, courier, invoice and how long ago.
class CourierAlertTile extends StatelessWidget {
  const CourierAlertTile({super.key, required this.alert, required this.onTap});

  final CourierAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = courierAlertSeverityColor(alert.severity);
    final detected = alert.detectedOn;
    final age = detected == null ? null : DateTime.now().difference(detected);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final subtitleParts = <String>[
      if (alert.courierLabel != null) alert.courierLabel!,
      if (alert.invoice != null) alert.invoice!,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              courierAlertTypeLabel(l10n, alert.anomalyType),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          UserAdminTag(
                            text: courierAlertSeverityLabel(
                              l10n,
                              alert.severity,
                            ),
                            color: color,
                          ),
                        ],
                      ),
                      // Arabic UI: keep the English name the server uses next
                      // to the translation, so a manager can match it to the
                      // desk and to what the courier is told.
                      if (isArabic &&
                          courierAlertTypeIsKnown(alert.anomalyType))
                        Text(
                          alert.anomalyType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subtitleParts.join(' · ')),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            fleetRelativeAge(l10n, age),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          if (!alert.isOpen) ...[
                            const SizedBox(width: 8),
                            UserAdminTag(
                              text: courierAlertStatusLabel(l10n, alert.status),
                              color: theme.colorScheme.outline,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/router.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../geo/presentation/widgets/location_preview_map.dart';
import '../../data/models/fleet_models.dart';
import '../../state/fleet_providers.dart';
import '../fleet_labels.dart';
import '../widgets/fleet_header.dart';
import '../widgets/fleet_map.dart';
import '../widgets/fleet_message_panel.dart';

/// How often the age labels are recomputed.
///
/// Deliberately independent of the poll: if the network dies, the dots must
/// still march from fresh to stale on their own. Freezing a green dot at
/// "1 min ago" because the last refresh failed is exactly the lie this screen
/// exists to prevent.
const Duration _kTickInterval = Duration(seconds: 10);

/// Dispatcher view of where every working courier is right now.
class FleetMapScreen extends ConsumerStatefulWidget {
  const FleetMapScreen({super.key});

  @override
  ConsumerState<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends ConsumerState<FleetMapScreen>
    with RouteAware, WidgetsBindingObserver {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  /// Selection is held by id, not by object: every poll produces fresh
  /// [CourierPosition] instances, and pinning the object would freeze the
  /// sheet's age at whatever it was when the marker was tapped.
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTicker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    try {
      routeObserver.unsubscribe(this);
    } catch (_) {}
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_kTickInterval, (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  void _setActive(bool active) {
    if (active) {
      setState(() => _now = DateTime.now());
      _startTicker();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
    // `read` on purpose: this fires from lifecycle callbacks, not from build.
    ref.read(fleetControllerProvider.notifier).setActive(active);
  }

  // Covered by another route → stop polling and ticking.
  @override
  void didPushNext() => _setActive(false);

  @override
  void didPopNext() => _setActive(true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _setActive(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canView = ref.watch(canAccessManagerDashboardRoleProvider);
    final state = ref.watch(fleetControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.fleetTitle),
        actions: [
          if (canView && !state.isPermissionDenied)
            IconButton(
              tooltip: l10n.fleetRefreshTooltip,
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(fleetControllerProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(context, state, canView: canView),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FleetState state, {
    required bool canView,
  }) {
    final l10n = context.l10n;

    // Role gate mirrors the server's supervisor-only rule. The 403 branch below
    // still exists because the client's role set can only ever approximate it.
    if (!canView || state.isPermissionDenied) {
      return FleetMessagePanel(
        icon: Icons.lock_outline,
        title: l10n.fleetForbiddenTitle,
        body: l10n.fleetForbiddenBody,
      );
    }

    final snapshot = state.snapshot;

    if (snapshot == null) {
      if (state.error != null) {
        return FleetMessagePanel(
          icon: Icons.error_outline,
          iconColor: fleetFreshnessColor(FleetFreshness.stale),
          title: l10n.fleetErrorTitle,
          body: context.userErrorMessage(
            state.error!,
            fallback: l10n.commonError,
          ),
          onRetry: () => ref.read(fleetControllerProvider.notifier).refresh(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        FleetStatusBar(
          snapshot: snapshot,
          now: _now,
          isRefreshing: state.isRefreshing,
          refreshFailed: state.isShowingStaleAfterFailure,
        ),
        FleetLegend(ttl: snapshot.ttl),
        Expanded(child: _buildContent(context, snapshot)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FleetSnapshot snapshot) {
    final l10n = context.l10n;

    switch (snapshot.emptyReason) {
      case FleetEmptyReason.noCouriers:
        // Nobody is reporting at all — a staffing/shift question.
        return FleetMessagePanel(
          icon: Icons.local_shipping_outlined,
          title: l10n.fleetEmptyNoCouriersTitle,
          body: l10n.fleetEmptyNoCouriersBody,
          onRetry: () => ref.read(fleetControllerProvider.notifier).refresh(),
        );
      case FleetEmptyReason.noPositions:
        // Couriers are known but unplaceable — a device/permission question.
        return FleetMessagePanel(
          icon: Icons.place,
          iconColor: kFleetUnknownColor,
          title: l10n.fleetEmptyNoPositionsTitle,
          body: l10n.fleetEmptyNoPositionsBody,
          detail: l10n.fleetEmptyNoPositionsNames(
            snapshot.unlocated
                .map((courier) => courier.displayName)
                .where((name) => name.isNotEmpty)
                .join('، '),
          ),
          onRetry: () => ref.read(fleetControllerProvider.notifier).refresh(),
        );
      case null:
        break;
    }

    final located = snapshot.located;
    final selected = _selectedCourier(located);
    final unlocated = snapshot.unlocated;

    return Column(
      children: [
        if (unlocated.isNotEmpty) FleetUnlocatedBanner(couriers: unlocated),
        Expanded(
          child: Stack(
            children: [
              FleetMap(
                couriers: located,
                now: _now,
                selectedId: _selectedId,
                tileProvider: ref.watch(locationTileProviderProvider),
                onMarkerTap: (courier) =>
                    setState(() => _selectedId = courier.id),
              ),
              if (selected != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: CourierPositionSheet(
                    courier: selected,
                    now: _now,
                    onClose: () => setState(() => _selectedId = null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Re-resolves the selection against the latest poll, and drops it when the
  /// courier has gone off the map.
  CourierPosition? _selectedCourier(List<CourierPosition> located) {
    final id = _selectedId;
    if (id == null) return null;
    for (final courier in located) {
      if (courier.id == id) return courier;
    }
    return null;
  }
}

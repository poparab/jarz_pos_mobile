import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../../../core/sync/offline_sync_service.dart';
import '../../state/courier_balances_provider.dart';

// Merged system status: connectivity, realtime, sync, couriers, partner chip
// Removed unused system status imports (connectivity, sync, websocket) to satisfy analyzer.
import '../../state/pos_notifier.dart';
import '../widgets/customer_search_widget.dart';
import '../widgets/sales_partner_selector.dart';
import '../widgets/item_grid_widget.dart';
import '../widgets/cart_widget.dart';
import '../widgets/courier_balances_dialog.dart';
// Kanban is navigated as a separate route to keep headers consistent
// Printing
import '../../../printing/pos_printer_provider.dart';
import '../../../printing/printer_status.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/network/user_service.dart';
import '../../../shift/state/shift_notifier.dart';
import '../../../shift/presentation/widgets/shift_status_banner.dart';
// Removed branch filter from POS; filter lives in Kanban header
// Removed unused direct service import (service accessed through provider)

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProfileDialogOpen = false;

  // ── Scroll-to-hide state (phones only) ──────────────────────────
  late final AnimationController _hideController;
  /// 1.0 → visible, 0.0 → hidden.  Used for SizeTransition + FAB.
  late final Animation<double> _hideAnim;
  bool _headerVisible = true;
  double _lastScrollOffset = 0;
  /// Accumulated scroll delta – works on 120 Hz+ displays where per-frame
  /// delta can be tiny.  Resets when scroll direction reverses.
  double _accumulatedDelta = 0;
  // Accumulated px in one direction before triggering hide/show
  static const _scrollThreshold = 30.0;

  @override
  void initState() {
    super.initState();

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // When controller goes 0→1 (forward), this animation goes 1→0 (hide)
    _hideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _hideController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Authentication assumed handled by route guard; proceed to load profiles.

      final state = ref.read(posNotifierProvider);
      if (state.selectedProfile == null) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      }
    });
  }

  @override
  void dispose() {
    _hideController.dispose();
    super.dispose();
  }

  /// Handle scroll notifications from nested scrollables (phones only).
  /// Uses accumulated delta so small per-frame deltas on 120 Hz+ screens
  /// still trigger hide/show after the user has scrolled enough.
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.axis == Axis.vertical) {
      final offset = notification.metrics.pixels;
      final delta = offset - _lastScrollOffset;
      _lastScrollOffset = offset;

      // At the very top – always show header
      if (offset <= 0) {
        _accumulatedDelta = 0;
        _showHeader();
        return false;
      }

      // Accumulate; reset when direction reverses
      if (delta > 0) {
        _accumulatedDelta = _accumulatedDelta > 0
            ? _accumulatedDelta + delta
            : delta;
      } else if (delta < 0) {
        _accumulatedDelta = _accumulatedDelta < 0
            ? _accumulatedDelta + delta
            : delta;
      }

      if (_accumulatedDelta > _scrollThreshold && _headerVisible) {
        _hideHeader();
        _accumulatedDelta = 0;
      }

      // Only auto-show when the user returns to the very top; avoid
      // popping the header back on small upward scrolls mid-list.
      if (!_headerVisible && offset < 12) {
        _showHeader();
        _accumulatedDelta = 0;
      }
    }
    return false;
  }

  void _hideHeader() {
    if (!_headerVisible) return;
    setState(() {
      _headerVisible = false;
    });
    _hideController.forward();
  }

  void _showHeader() {
    if (_headerVisible) return;
    setState(() {
      _headerVisible = true;
    });
    _hideController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posNotifierProvider);
    final requirePosShift = ref.watch(requirePosShiftProvider);
    final activeShiftAsync = ref.watch(activeShiftProvider);
    final selectedProfileName = (state.selectedProfile?['name'] ?? '').toString();
    // Enforce POS profile selection: show startup popup chooser on entry
    if (state.selectedProfile == null) {
      if (state.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Auto-select if only one profile available
      if (state.profiles.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(posNotifierProvider.notifier).selectProfile(state.profiles.first);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // Show popup chooser for multiple profiles
      if (state.profiles.isNotEmpty) {
        if (!_isProfileDialogOpen) {
          _isProfileDialogOpen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final selected = await showDialog<Map<String, dynamic>>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return AlertDialog(
                  title: Text(context.l10n.posProfileSelectionTitle),
                  content: SizedBox(
                    width: 380,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.profiles.length,
                      separatorBuilder: (_, x) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final profile = state.profiles[index];
                        final name = (profile['name'] ?? '').toString();
                        final title = (profile['title'] ?? profile['name'] ?? '').toString();
                        return ListTile(
                          leading: const Icon(Icons.store),
                          title: Text(title.isNotEmpty ? title : name),
                          subtitle: name.isNotEmpty ? Text(name) : null,
                          onTap: () => Navigator.of(dialogContext).pop(profile),
                        );
                      },
                    ),
                  ),
                );
              },
            );

            _isProfileDialogOpen = false;
            if (!mounted) return;
            if (selected != null) {
              await ref.read(posNotifierProvider.notifier).selectProfile(selected);
            }
          });
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (requirePosShift) {
      final activeShift = activeShiftAsync.valueOrNull;
      if (activeShift != null && activeShift.posProfile != selectedProfileName) {
        return _buildShiftProfileMismatch(context, activeShift, selectedProfileName);
      }
    }

    final isPhone = ResponsiveUtils.isPhone(context);
    final headerHeight = ResponsiveUtils.getHeaderHeight(context);

    final header = _MergedHeader(
      state: state,
      onShowCart: () => _showCartBottomSheet(context),
      onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      ref: ref,
      context: context,
    );
    final matchedActiveShift = requirePosShift ? activeShiftAsync.valueOrNull : null;

    // ── Phone: scroll-to-hide header + FAB ──────────────────────────
    if (isPhone) {
      final primary = Theme.of(context).colorScheme.primary;
      final onPrimary = Theme.of(context).colorScheme.onPrimary;
      final statusBarHeight = MediaQuery.of(context).viewPadding.top;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          key: _scaffoldKey,
          drawer: const AppDrawer(),
          // FAB slides out when header hides
          floatingActionButton: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, 2), // slide down off screen
            ).animate(CurvedAnimation(
              parent: _hideController,
              curve: Curves.easeInOut,
            )),
            child: Consumer(builder: (c, ref2, _) {
              final cartCount = ref2.watch(
                posNotifierProvider.select((s) => s.cartItemCount),
              );
              return FloatingActionButton(
                heroTag: 'pos_cart_fab',
                onPressed: () => _showCartBottomSheet(context),
                child: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  child: const Icon(Icons.shopping_cart),
                ),
              );
            }),
          ),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: Column(
                      children: [
                        // Persistent primary-coloured status bar area
                        Container(
                          width: double.infinity,
                          height: statusBarHeight,
                          color: primary,
                        ),
                        // Header collapses smoothly when scrolling down
                        ClipRect(
                          child: SizeTransition(
                            sizeFactor: _hideAnim,
                            axisAlignment: -1.0, // collapse from top edge
                            child: header,
                          ),
                        ),
                        // Main content
                        if (matchedActiveShift != null)
                          ShiftStatusBanner(shift: matchedActiveShift),
                        Expanded(
                          child: state.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : state.error != null
                                  ? _buildError(context, state.error!)
                                  : _buildResponsiveLayout(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick reveal button when header is hidden (phones only)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 200),
                        offset: _headerVisible ? const Offset(0, -0.4) : Offset.zero,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _headerVisible ? 0.0 : 0.9,
                          child: IgnorePointer(
                            ignoring: _headerVisible,
                            child: FloatingActionButton.small(
                              heroTag: 'pos_header_reveal',
                              tooltip: 'Show header',
                              onPressed: () {
                                _accumulatedDelta = 0;
                                _showHeader();
                              },
                              backgroundColor: primary,
                              foregroundColor: onPrimary,
                              child: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Tablet: standard layout ─────────────────────────────────────
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerHeight),
        child: header,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            if (matchedActiveShift != null) ShiftStatusBanner(shift: matchedActiveShift),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _buildError(context, state.error!)
                      : _buildResponsiveLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftProfileMismatch(
    BuildContext context,
    dynamic activeShift,
    String selectedProfileName,
  ) {
    final l10n = context.l10n;
    final activeProfile = (activeShift.posProfile).toString();
    final fallbackName = stateSafeSelectedName(selectedProfileName, l10n);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.menuPointOfSale),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.shiftProfileMismatch(activeProfile, fallbackName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.shiftEnd),
                  icon: const Icon(Icons.timer_off),
                  label: Text(l10n.shiftGoToEnd),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    final profiles = ref.read(posNotifierProvider).profiles;
                    final target = profiles.firstWhere(
                      (p) => (p['name'] ?? '').toString() == activeProfile,
                      orElse: () => <String, dynamic>{},
                    );
                    if (target.isNotEmpty) {
                      ref.read(posNotifierProvider.notifier).selectProfile(target);
                    }
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.shiftSwitchToActiveProfile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String stateSafeSelectedName(String selectedProfileName, dynamic l10n) {
    if (selectedProfileName.isNotEmpty) return selectedProfileName;
    return l10n.posProfileSelectionShortFallback;
  }

  /// Build responsive layout that adapts to screen size.
  /// On phones (< 600px) show items full-width; cart accessible via FAB / bottom sheet.
  /// The customer search bar is animated on phones (collapses with the header).
  /// On tablets keep the side-by-side Row layout.
  Widget _buildResponsiveLayout(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(
      context,
      small: 12,
      medium: 14,
      large: 16,
    );
    final isPhone = ResponsiveUtils.isPhone(context);

    final customerSearch = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const CustomerSearchWidget(),
    );

    // Phone: customer search collapses with header
    if (isPhone) {
      return Column(
        children: [
          // Customer search slides away with the header
          ClipRect(
            child: SizeTransition(
              sizeFactor: _hideAnim, // 1→0 collapses customer search
              axisAlignment: -1.0, // collapse from top
              child: customerSearch,
            ),
          ),
          Expanded(child: ItemGridWidget(hideAnimation: _hideAnim)),
        ],
      );
    }

    // Tablet: side-by-side
    final itemsPanel = Column(
      children: [customerSearch, const Expanded(child: ItemGridWidget())],
    );
    final flexRatio = ResponsiveUtils.getCartFlexRatio(context);
    return Row(
      children: [
        Expanded(flex: flexRatio[0], child: itemsPanel),
        Expanded(flex: flexRatio[1], child: const CartWidget()),
      ],
    );
  }

  Widget _buildError(BuildContext context, String error) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(l10n.commonError, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(posNotifierProvider.notifier).loadProfiles(),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    final l10n = context.l10n;
    final isPhone = ResponsiveUtils.isPhone(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(isPhone ? 12 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.posCartTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: isPhone ? 18 : null,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: isPhone ? 22 : null,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: CartWidget(scrollController: scrollController),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _MergedHeader extends ConsumerWidget implements PreferredSizeWidget {
  final PosState state;
  final VoidCallback onShowCart;
  final VoidCallback onOpenDrawer;
  final WidgetRef ref;
  final BuildContext context;
  const _MergedHeader({required this.state, required this.onShowCart, required this.onOpenDrawer, required this.ref, required this.context, double? headerHeight}) : _headerHeight = headerHeight;

  @override
  Size get preferredSize => Size.fromHeight(_headerHeight ?? 88);
  final double? _headerHeight;

  @override
  Widget build(BuildContext ctx, WidgetRef r) {
    final theme = Theme.of(ctx);
    final l10n = ctx.l10n;
    final connectivityAsync = r.watch(connectivityStatusProvider);
    final webSocketService = r.watch(webSocketServiceProvider);
    final offlineSyncService = r.watch(offlineSyncServiceProvider);
    final courierState = r.watch(courierBalancesProvider);
    final partner = r.watch(posNotifierProvider.select((s) => s.selectedSalesPartner));
    final printer = r.watch(posPrinterServiceProvider);
    final isPhone = ResponsiveUtils.isPhone(ctx);

    // On phones condense to essential controls; move status to overflow menu
    final essentialChildren = <Widget>[
      // Hamburger menu
      IconButton(
        icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary, size: isPhone ? 20 : 24),
        onPressed: onOpenDrawer,
        tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
        visualDensity: isPhone ? VisualDensity.compact : VisualDensity.standard,
      ),
      if (!isPhone) ...[
        const SizedBox(width: 4),
        const SizedBox(width: 12),
        _vDivider(theme),
        const SizedBox(width: 12),
      ],
      // Section: Partner
      if (partner != null)
        InputChip(
          backgroundColor: theme.colorScheme.secondaryContainer,
          avatar: const Icon(Icons.handshake, size: 16),
          label: Text(
            partner['title'] ??
                partner['partner_name'] ??
                partner['name'] ??
                l10n.systemStatusPartnerChip,
            overflow: TextOverflow.ellipsis,
          ),
          onDeleted: () => r.read(posNotifierProvider.notifier).setSalesPartner(null),
          deleteIcon: const Icon(Icons.close, size: 16),
        )
      else
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary),
          onPressed: () async {
            final sel = await showDialog<Map<String, dynamic>?>(
              context: ctx,
              builder: (_) => const SalesPartnerSelectorDialog(),
            );
            if (sel != null) {
              r.read(posNotifierProvider.notifier).setSalesPartner(sel);
            }
          },
          icon: const Icon(Icons.handshake),
          label: isPhone ? const SizedBox.shrink() : Text(l10n.systemStatusPartnerChip),
        ),
      if (!isPhone) ...[
        const SizedBox(width: 12),
        _vDivider(theme),
        const SizedBox(width: 12),
      ] else
        const SizedBox(width: 4),
      // Section: POS Profile quick selector (dialog-based)
      Builder(builder: (bCtx) {
        final profiles = r.watch(posNotifierProvider).profiles;
        final selected = r.watch(posNotifierProvider).selectedProfile;
        final onPrimary = theme.colorScheme.onPrimary;

        if (profiles.isEmpty) {
          return Text(
            selected?['title'] ??
                selected?['name'] ??
                l10n.posProfileSelectionShortFallback,
            style: theme.textTheme.titleMedium?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: isPhone ? 11 : null,
            ),
          );
        }

        final label = selected != null
            ? (selected['title'] ??
                    selected['name'] ??
                    l10n.posProfileSelectionShortFallback)
                .toString()
            : (profiles.length == 1
                ? (profiles.first['title'] ??
                        profiles.first['name'] ??
                        l10n.posProfileSelectionShortFallback)
                    .toString()
                : l10n.posProfileSelectionCycleHint);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: InkWell(
            onTap: () async {
              if (profiles.length == 1) {
                r.read(posNotifierProvider.notifier).selectProfile(profiles.first);
                return;
              }
              // Cycle through profiles without modal dialog
              final currentIndex = selected != null 
                  ? profiles.indexWhere((p) => p['name'] == selected['name'])
                  : -1;
              final nextIndex = (currentIndex + 1) % profiles.length;
              final nextProfile = profiles[nextIndex];
              r.read(posNotifierProvider.notifier).selectProfile(nextProfile);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 10, vertical: 6),
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: onPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store, size: isPhone ? 14 : 16, color: onPrimary),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isPhone ? 80 : 200),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onPrimary,
                        fontSize: isPhone ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 18, color: onPrimary),
                ],
              ),
            ),
          ),
        );
      }),
    ];

    // Status chips – shown inline on tablets, in trailing overflow on phones
    final statusChips = <Widget>[
      connectivityAsync.when(
        data: (isOnline) => _statusChip(
          ctx,
          icon: isOnline ? Icons.wifi : Icons.wifi_off,
          label: isOnline ? l10n.commonOnline : l10n.commonOffline,
          color: isOnline ? Colors.green : Colors.red,
        ),
        loading: () =>
            _statusChip(ctx, icon: Icons.wifi, label: l10n.systemStatusChecking, color: Colors.orange),
        error: (e, st) =>
            _statusChip(ctx, icon: Icons.wifi_off, label: l10n.commonError, color: Colors.red),
      ),
      const SizedBox(width: 8),
      StreamBuilder<bool>(
        stream: webSocketService.connectionStatus,
        initialData: false,
        builder: (c, snap) {
          final connected = snap.data ?? false;
          return _statusChip(
            ctx,
            icon: connected ? Icons.sync : Icons.sync_disabled,
            label: connected ? l10n.systemStatusRealtime : l10n.systemStatusNoRealtime,
            color: connected ? Colors.blue : Colors.grey,
          );
        },
      ),
      const SizedBox(width: 8),
      FutureBuilder<int>(
        future: offlineSyncService.getPendingCount(),
        builder: (c, snap) {
          final pending = snap.data ?? 0;
          return _statusChip(
            ctx,
            icon: pending == 0 ? Icons.check_circle : Icons.sync_problem,
            label: pending == 0
                ? l10n.systemStatusSynced
                : l10n.systemStatusPendingCount(pending),
            color: pending == 0 ? Colors.green : Colors.orange,
          );
        },
      ),
      const SizedBox(width: 8),
      InkWell(
        onTap: () => showCourierBalancesDialog(ctx),
        child: _statusChip(
          ctx,
          icon: courierState.hasUnsettled ? Icons.delivery_dining : Icons.local_shipping,
          label: courierState.hasUnsettled
              ? l10n.systemStatusCourierCount(courierState.unsettledCount)
              : l10n.systemStatusCouriers,
          color: courierState.hasUnsettled ? Colors.orange : Colors.grey,
        ),
      ),
      const SizedBox(width: 8),
      StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (c, snap) {
          final now = DateTime.now();
          return _statusChip(
            ctx,
            icon: Icons.schedule,
            label: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            color: Colors.teal,
          );
        },
      ),
    ];

    // Printer chip
    final printerChip = InkWell(
      onTap: () => context.push(AppRoutes.printers),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: () {
            switch (printer.unifiedStatus) {
              case PrinterUnifiedStatus.connectedBle:
              case PrinterUnifiedStatus.connectedClassic:
                return Colors.green.withValues(alpha: 0.15);
              case PrinterUnifiedStatus.connecting:
                return Colors.orange.withValues(alpha: 0.15);
              case PrinterUnifiedStatus.error:
                return Colors.red.withValues(alpha: 0.18);
              case PrinterUnifiedStatus.disconnected:
                return Colors.red.withValues(alpha: 0.15);
            }
          }(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: () {
              switch (printer.unifiedStatus) {
                case PrinterUnifiedStatus.connectedBle:
                case PrinterUnifiedStatus.connectedClassic:
                  return Colors.green;
                case PrinterUnifiedStatus.connecting:
                  return Colors.orange;
                case PrinterUnifiedStatus.error:
                  return Colors.red;
                case PrinterUnifiedStatus.disconnected:
                  return Colors.red;
              }
            }().withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.print,
              size: isPhone ? 14 : 16,
              color: () {
                switch (printer.unifiedStatus) {
                  case PrinterUnifiedStatus.connectedBle:
                  case PrinterUnifiedStatus.connectedClassic:
                    return Colors.greenAccent;
                  case PrinterUnifiedStatus.connecting:
                    return Colors.orangeAccent;
                  case PrinterUnifiedStatus.error:
                    return Colors.redAccent;
                  case PrinterUnifiedStatus.disconnected:
                    return Colors.redAccent;
                }
              }(),
            ),
            if (!isPhone) ...[
              const SizedBox(width: 6),
              Text(
                () {
                  switch (printer.unifiedStatus) {
                    case PrinterUnifiedStatus.connectedBle:
                      return l10n.printerStatusBle;
                    case PrinterUnifiedStatus.connectedClassic:
                      return l10n.printerStatusClassic;
                    case PrinterUnifiedStatus.connecting:
                      return l10n.printerStatusConnecting;
                    case PrinterUnifiedStatus.error:
                      return printer.lastErrorMessage ?? l10n.printerStatusError;
                    case PrinterUnifiedStatus.disconnected:
                      return l10n.printerStatusDisconnected;
                  }
                }(),
                style: TextStyle(
                  color: () {
                    switch (printer.unifiedStatus) {
                      case PrinterUnifiedStatus.connectedBle:
                      case PrinterUnifiedStatus.connectedClassic:
                        return Colors.green;
                      case PrinterUnifiedStatus.connecting:
                        return Colors.orange;
                      case PrinterUnifiedStatus.error:
                        return Colors.red;
                      case PrinterUnifiedStatus.disconnected:
                        return Colors.red;
                    }
                  }(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Action buttons
    final actionButtons = <Widget>[
      printerChip,
      SizedBox(width: isPhone ? 4 : 12),
      IconButton(
        icon: Icon(Icons.view_kanban, color: theme.colorScheme.onPrimary, size: isPhone ? 20 : 24),
        tooltip: l10n.menuSalesKanban,
        onPressed: () => context.push(AppRoutes.kanban),
        visualDensity: isPhone ? VisualDensity.compact : VisualDensity.standard,
      ),
      // Cart icon only shown on tablets (phones use FAB)
      if (!isPhone)
        Consumer(builder: (c, ref2, _) {
          final cartCount = ref2.watch(posNotifierProvider.select((s) => s.cartItemCount));
          return Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
                onPressed: onShowCart,
                tooltip: l10n.posCartTitle,
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$cartCount',
                        style: TextStyle(color: theme.colorScheme.onError, fontSize: 11),
                        textAlign: TextAlign.center),
                  ),
                ),
            ],
          );
        }),
      SizedBox(width: isPhone ? 2 : 12),
      // Force sync
      IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: l10n.systemStatusForceSyncTooltip,
        icon: Icon(Icons.refresh, size: isPhone ? 18 : 20, color: theme.colorScheme.onPrimary),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(ctx);
          await offlineSyncService.forceSyncNow();
          await r.read(courierBalancesProvider.notifier).load();
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.systemStatusSyncComplete),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    ];

    return Material(
      elevation: 4,
      color: theme.colorScheme.primary,
      child: SafeArea(
        top: !isPhone, // phones handle status bar padding externally
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isPhone ? 4 : 12, vertical: isPhone ? 2 : 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...essentialChildren,
                if (!isPhone) ...[
                  const SizedBox(width: 12),
                  _vDivider(theme),
                  const SizedBox(width: 12),
                  ...statusChips,
                  const SizedBox(width: 12),
                  _vDivider(theme),
                  const SizedBox(width: 12),
                ],
                ...actionButtons,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _vDivider(ThemeData theme) => Container(
        width: 1,
        height: 24,
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
      );
}

// Footer removed: printer status now lives in header

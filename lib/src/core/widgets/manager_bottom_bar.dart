import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../localization/localization_extensions.dart';
import '../network/user_service.dart';
import '../router.dart';
import 'app_drawer.dart';

/// The manager bottom bar: Today, Orders, Reports, Final Products, More.
///
/// Shown only to a user with `User.custom_manager_home` switched on (see
/// [managerHomeProvider]); for everyone else [ManagerBottomBarHost] renders
/// its child untouched, so the Kanban and the POS keep the whole screen.
///
/// The bar lives once, under the router, instead of on each screen's
/// Scaffold, so it stays at the bottom wherever the side menu goes. It steps
/// aside whenever something else owns the bottom of the screen: a dialog,
/// sheet or pushed page ([managerBarRouteObserver]), the keyboard, a phone
/// held sideways, and the screens listed in [managerBarHiddenOn].

/// Tracks routes pushed on the root navigator that are not GoRouter pages:
/// dialogs, bottom sheets, and screens opened with `Navigator.push`. While any
/// is open the bar hides, so a tap on it cannot swap the page out from under
/// a half-finished dialog, and a pushed screen with its own bottom buttons
/// does not get a second bar under them.
class ManagerBarRouteObserver extends NavigatorObserver with ChangeNotifier {
  final List<Route<dynamic>> _covering = [];

  bool get covered {
    _covering.removeWhere((r) => !r.isActive);
    return _covering.isNotEmpty;
  }

  static bool _isCovering(Route<dynamic>? route) =>
      route != null && (route is PopupRoute || route.settings is! Page);

  void _changed() {
    // Navigator callbacks can arrive mid-build; listeners rebuild next frame.
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isCovering(route)) _covering.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _covering.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _covering.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _covering.remove(oldRoute);
    if (_isCovering(newRoute)) _covering.add(newRoute!);
    _changed();
  }
}

final ManagerBarRouteObserver managerBarRouteObserver =
    ManagerBarRouteObserver();

/// Locations where the bar never shows: sign-in and the shift gates, and the
/// screens that already carry their own bottom action bar.
bool managerBarHiddenOn(String path) {
  if (path.isEmpty ||
      path == AppRoutes.root ||
      path == AppRoutes.login ||
      path == AppRoutes.shiftStart ||
      path == AppRoutes.shiftEnd) {
    return true;
  }
  bool under(String route) => path == route || path.startsWith('$route/');
  return under(AppRoutes.inventoryCount) ||
      path.startsWith('/users/') ||
      under(AppRoutes.b2bVisitBuilder) ||
      under(AppRoutes.b2bVisitPlan);
}

/// Which tab [path] belongs to: 0 Today, 1 Orders, 2 Reports, 3 Final
/// Products, or null for a screen outside the bar.
int? managerBarIndexFor(String path) {
  bool under(String route) => path == route || path.startsWith('$route/');
  if (under(AppRoutes.reportsRevenueDashboard)) return 0;
  if (under(AppRoutes.kanban)) return 1;
  if (under(AppRoutes.reportsFinalProducts)) return 3;
  if (under(AppRoutes.reports)) return 2;
  return null;
}

/// Whether the bar shows, given everything that can push it aside.
bool shouldShowManagerBar({
  required bool enabled,
  required String path,
  required bool covered,
  required bool keyboardOpen,
  required bool phoneLandscape,
}) =>
    enabled &&
    !covered &&
    !keyboardOpen &&
    !phoneLandscape &&
    !managerBarHiddenOn(path);

String _currentPath(GoRouter router) {
  try {
    final config = router.routerDelegate.currentConfiguration;
    if (config.isEmpty) return '';
    return config.uri.path;
  } catch (_) {
    return '';
  }
}

/// Wraps the routed app. Keeps one fixed tree shape (the router always sits
/// in the same slot) so hiding or showing the bar never rebuilds the
/// navigator and its pages.
class ManagerBottomBarHost extends ConsumerStatefulWidget {
  const ManagerBottomBarHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ManagerBottomBarHost> createState() =>
      _ManagerBottomBarHostState();
}

class _ManagerBottomBarHostState extends ConsumerState<ManagerBottomBarHost> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    managerBarRouteObserver.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    managerBarRouteObserver.removeListener(_onRouteChanged);
    _router?.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _listenTo(GoRouter router) {
    if (identical(router, _router)) return;
    _router?.routerDelegate.removeListener(_onRouteChanged);
    _router = router;
    router.routerDelegate.addListener(_onRouteChanged);
  }

  // The router delegate can notify while the navigator below is still
  // building; rebuilding this ancestor then is an error, so wait for the
  // frame to finish.
  void _onRouteChanged() {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(managerHomeProvider);
    final router = ref.watch(routerProvider);
    _listenTo(router);
    final mq = MediaQuery.of(context);
    final path = _currentPath(router);
    final show = shouldShowManagerBar(
      enabled: enabled,
      path: path,
      covered: enabled && managerBarRouteObserver.covered,
      keyboardOpen: mq.viewInsets.bottom > 0,
      phoneLandscape:
          mq.orientation == Orientation.landscape &&
          mq.size.shortestSide < 600,
    );
    return Column(
      children: [
        Expanded(
          child: MediaQuery(
            // The bar takes the system inset; the page must not pad for it a
            // second time.
            data: show
                ? mq
                      .removePadding(removeBottom: true)
                      .removeViewPadding(removeBottom: true)
                : mq,
            child: widget.child,
          ),
        ),
        if (show)
          ManagerBottomBar(
            selectedIndex: managerBarIndexFor(path),
            onSelect: (route) {
              if (route != path) router.go(route);
            },
            onMore: openManagerMoreMenu,
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

/// Opens the full side menu from the bar's More tab, over whatever screen is
/// showing. The drawer's own items close it before they navigate.
void openManagerMoreMenu() {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => const Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppDrawer(),
    ),
    transitionBuilder: (context, animation, _, child) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(rtl ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

class ManagerBottomBar extends StatelessWidget {
  const ManagerBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onMore,
  });

  /// The highlighted tab, or null on a screen outside the bar.
  final int? selectedIndex;
  final ValueChanged<String> onSelect;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // Built from plain ink buttons rather than NavigationBar: this sits above
    // the navigator, where there is no Overlay for NavigationBar's tooltips.
    final items = <_BarItem>[
      _BarItem(
        const ValueKey('manager-bar-today'),
        Icons.today_outlined,
        Icons.today,
        l10n.rptRevToday,
        () => onSelect(AppRoutes.reportsRevenueDashboard),
      ),
      _BarItem(
        const ValueKey('manager-bar-orders'),
        Icons.view_kanban_outlined,
        Icons.view_kanban,
        l10n.managerBarOrders,
        () => onSelect(AppRoutes.kanban),
      ),
      _BarItem(
        const ValueKey('manager-bar-reports'),
        Icons.bar_chart_outlined,
        Icons.bar_chart,
        l10n.menuReports,
        () => onSelect(AppRoutes.reports),
      ),
      _BarItem(
        const ValueKey('manager-bar-final-products'),
        Icons.inventory_2_outlined,
        Icons.inventory_2,
        l10n.reportsFinalProducts,
        () => onSelect(AppRoutes.reportsFinalProducts),
      ),
      _BarItem(
        const ValueKey('manager-bar-more'),
        Icons.menu,
        Icons.menu,
        l10n.managerBarMore,
        onMore,
      ),
    ];
    return Material(
      key: const ValueKey('manager-bottom-bar'),
      color: theme.colorScheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BarButton(item: items[i], selected: i == selectedIndex),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem {
  final Key key;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
  const _BarItem(
    this.key,
    this.icon,
    this.selectedIcon,
    this.label,
    this.onTap,
  );
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.item, required this.selected});

  final _BarItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        key: item.key,
        onTap: item.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? scheme.secondaryContainer : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

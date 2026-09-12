import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../state/attendance_providers.dart';
import 'widgets/attendance_day_tab.dart';
import 'widgets/attendance_employee_tab.dart';
import 'widgets/attendance_month_tab.dart';
import 'widgets/attendance_states.dart';
import 'widgets/attendance_summary_tab.dart';

/// Attendance — who actually came in, against who was rostered.
///
/// Four readings of the same derived data, because four different questions
/// get asked of it: the month (a pattern), the day (this morning), one person
/// (a conversation with them), and the aggregate (a comparison between
/// branches). They share one branch filter and one date range on purpose, so
/// moving between tabs does not silently change the period under discussion.
///
/// Nothing here writes: attendance is derived server-side from Employee
/// Checkin + Shift Assignment + Day Off. The roster screen is where the
/// schedule is edited.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The same gate `api/attendance.py` applies (`ROLES.ADMIN |
    // ROLES.LINE_MANAGER_TIER`). A narrower gate here would be a dead tile, a
    // wider one a screen that 403s on open.
    final canView = ref.watch(canActAsLineManagerProvider);

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
        title: Text(l10n.attendanceTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
          ),
        ],
        bottom: canView
            ? TabBar(
                controller: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l10n.attendanceTabMonth),
                  Tab(text: l10n.attendanceTabDay),
                  Tab(text: l10n.attendanceTabEmployee),
                  Tab(text: l10n.attendanceTabSummary),
                ],
              )
            : null,
      ),
      body: !canView
          ? AttendanceMessageState(
              icon: Icons.lock_outline,
              message: l10n.attendanceAccessDenied,
              detail: l10n.attendanceAccessDeniedHint,
              tone: AttendanceMessageTone.warning,
            )
          : TabBarView(
              controller: _tabs,
              children: const [
                AttendanceMonthTab(),
                AttendanceDayTab(),
                AttendanceEmployeeTab(),
                AttendanceSummaryTab(),
              ],
            ),
    );
  }

  /// One refresh for the whole screen.
  ///
  /// The families are invalidated wholesale rather than per key: a manager who
  /// hits refresh is saying "the numbers on this screen are stale", and
  /// refreshing only the visible tab is what leaves the other three quietly
  /// showing yesterday.
  void _refreshAll() {
    ref.invalidate(attendanceBootstrapProvider);
    ref.invalidate(attendanceMonthDataProvider);
    ref.invalidate(attendanceDayDataProvider);
    ref.invalidate(attendanceEmployeeDataProvider);
    ref.invalidate(attendanceSummaryDataProvider);
  }
}

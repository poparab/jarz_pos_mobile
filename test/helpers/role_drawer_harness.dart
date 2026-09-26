// Renders the real AppDrawer for a real role set.
//
// Only `userRolesFutureProvider` is faked: every gate the drawer reads is
// derived from it by production code, so a test built on this harness checks
// the actual getters, not a hand-picked set of overridden booleans. The other
// overrides only stop network calls (badges, the manager-dashboard probe, the
// custody holder check, the active shift).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/core/localization/locale_notifier.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';
import 'package:jarz_pos/src/core/widgets/app_drawer.dart';
import 'package:jarz_pos/src/features/approvals/models/pending_approvals.dart';
import 'package:jarz_pos/src/features/approvals/state/pending_approvals_provider.dart';
import 'package:jarz_pos/src/features/cash_custody/state/cash_custody_notifier.dart';
import 'package:jarz_pos/src/features/kanban/providers/kanban_provider.dart';
import 'package:jarz_pos/src/features/manager/state/manager_providers.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';
import 'package:jarz_pos/src/features/purchase_request/models/purchase_request_models.dart';
import 'package:jarz_pos/src/features/purchase_request/state/purchase_request_notifier.dart';
import 'package:jarz_pos/src/features/shift/state/shift_notifier.dart';

import 'mock_services.dart';

/// The roles each Jarz role profile resolves to on production, read with
/// `frappe.get_roles` for a real member of each profile on 2026-09-26.
class RoleProfiles {
  static const manager = <String>[
    'Accounts Manager', 'Accounts User', 'All', 'Desk User', 'Guest',
    'Item Manager', 'JARZ Manager', 'JARZ line manager',
    'Manufacturing Manager', 'Manufacturing User', 'Moderator', 'POS Manager',
    'POS User', 'Production Operator', 'Purchase Manager', 'Purchase User',
    'Sales User', 'Stock Manager', 'Stock User',
  ];
  static const lineManager = <String>[
    'Accounts User', 'All', 'Desk User', 'Guest', 'JARZ line manager',
    'Moderator', 'POS User', 'Sales User',
  ];
  static const moderator = <String>[
    'Accounts User', 'All', 'Desk User', 'Guest', 'Moderator', 'POS User',
    'Sales User',
  ];
  static const staff = <String>[
    'Accounts User', 'All', 'Desk User', 'Employee', 'Guest', 'POS User',
    'Sales User',
  ];
}

class _FakePos extends StateNotifier<PosState> implements PosNotifier {
  _FakePos() : super(PosState());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeKanban extends StateNotifier<KanbanState> implements KanbanNotifier {
  _FakeKanban() : super(KanbanState());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeLocale extends StateNotifier<Locale?> implements LocaleNotifier {
  _FakeLocale() : super(null);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

List<Override> roleDrawerOverrides(List<String> roles) {
  final userRoles = UserRoles(
    user: 'someone@jarz.test',
    fullName: 'Someone',
    roles: roles,
    requirePosShift: true,
    canAccessB2b: roles.contains('JARZ Manager') ||
        roles.contains('System Manager') ||
        roles.contains('B2B Sales Rep'),
    isB2bSalesRep: roles.contains('B2B Sales Rep'),
  );
  return [
    userRolesFutureProvider.overrideWith((ref) async => userRoles),
    // The live probe answers exactly what the role check does for these
    // profiles (verified on production); no network here.
    managerAccessProvider
        .overrideWith((ref) async => userRoles.canAccessManagerDashboard),
    // Server-driven (custody holder); none of the probed accounts holds one.
    custodyMenuVisibleProvider
        .overrideWithValue(userRoles.canAccessCashTransfer),
    activeShiftProvider.overrideWith((ref) async => null),
    itemRequestCountsProvider.overrideWith(
      (ref) async => const ItemRequestCounts(open: 0, unacknowledged: 0),
    ),
    pendingApprovalsProvider.overrideWith(
      (ref) async => PendingApprovals(
        eligible: false,
        queues: const [],
        fetchedAt: DateTime(2026, 9, 26),
      ),
    ),
    posNotifierProvider.overrideWith((ref) => _FakePos()),
    kanbanProvider.overrideWith((ref) => _FakeKanban()),
    webSocketServiceProvider.overrideWithValue(MockWebSocketService()),
    localeNotifierProvider.overrideWith((ref) => _FakeLocale()),
  ];
}

/// Opens every drawer group, one after the other, and returns every menu
/// label that became visible. The drawer is an accordion, so a group's tiles
/// only exist while that group is the open one.
Future<Set<String>> collectDrawerLabels(WidgetTester tester) async {
  final labels = <String>{};
  void harvest() {
    for (final t in tester.widgetList<Text>(
      find.descendant(of: find.byType(AppDrawer), matching: find.byType(Text)),
    )) {
      final data = t.data;
      if (data != null && data.trim().isNotEmpty) labels.add(data);
    }
  }

  harvest();
  final headers = find.descendant(
    of: find.byType(AppDrawer),
    matching: find.byType(ExpansionTile),
  );
  final count = tester.widgetList(headers).length;
  for (var i = 0; i < count; i++) {
    final tile = tester.widget<ExpansionTile>(headers.at(i));
    if (!(tile.controller?.isExpanded ?? false)) {
      await tester.ensureVisible(headers.at(i));
      await tester.tap(find.descendant(
        of: headers.at(i),
        matching: find.byType(ListTile),
      ).first);
      await tester.pumpAndSettle();
    }
    harvest();
  }
  return labels;
}

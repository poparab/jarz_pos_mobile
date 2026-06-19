import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/app_routes.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/core/router.dart';

UserRoles _roles(
  List<String> roles, {
  bool isB2bSalesRep = false,
  bool canAccessB2b = false,
}) =>
    UserRoles(
      user: 'u@x.com',
      roles: roles,
      isB2bSalesRep: isB2bSalesRep,
      canAccessB2b: canAccessB2b,
    );

void main() {
  group('UserRoles B2B flags', () {
    test('parses is_b2b_sales_rep and can_access_b2b from json', () {
      final r = UserRoles.fromJson({
        'user': 'rep@x.com',
        'roles': ['B2B Sales Rep'],
        'is_b2b_sales_rep': true,
        'can_access_b2b': true,
      });
      expect(r.isB2bSalesRep, isTrue);
      expect(r.canAccessB2b, isTrue);
      expect(r.isB2bRep, isTrue);
      expect(r.canUseB2b, isTrue);
    });

    test('falls back to role name when flags absent', () {
      final r = _roles([RoleNames.b2bSalesRep]);
      expect(r.isB2bRep, isTrue);
      expect(r.canUseB2b, isTrue);
    });

    test('a non-manager B2B rep lands on B2B', () {
      final r = _roles([RoleNames.b2bSalesRep], isB2bSalesRep: true);
      expect(r.landsOnB2b, isTrue);
      expect(homeRouteFor(r), AppRoutes.b2b);
    });

    test('a manager who is also a B2B rep keeps POS home (manager wins)', () {
      final r = _roles(
        [RoleNames.b2bSalesRep, RoleNames.jarzManager],
        isB2bSalesRep: true,
        canAccessB2b: true,
      );
      expect(r.landsOnB2b, isFalse);
      expect(homeRouteFor(r), AppRoutes.pos);
      expect(r.canUseB2b, isTrue); // still gets the switch
    });

    test('a cashier (POS staff, no B2B) cannot use B2B', () {
      final r = _roles([RoleNames.jarzPosStaff]);
      expect(r.canUseB2b, isFalse);
      expect(homeRouteFor(r), AppRoutes.kanban);
    });
  });

  group('resolveB2bRedirect', () {
    test('B2B rep is redirected away from POS to B2B', () {
      final r = _roles([RoleNames.b2bSalesRep], isB2bSalesRep: true);
      expect(
        resolveB2bRedirect(roles: r, location: AppRoutes.pos),
        AppRoutes.b2b,
      );
    });

    test('B2B rep is redirected away from Kanban to B2B', () {
      final r = _roles([RoleNames.b2bSalesRep], isB2bSalesRep: true);
      expect(
        resolveB2bRedirect(roles: r, location: AppRoutes.kanban),
        AppRoutes.b2b,
      );
    });

    test('B2B rep can stay in B2B mode', () {
      final r = _roles([RoleNames.b2bSalesRep], isB2bSalesRep: true);
      expect(resolveB2bRedirect(roles: r, location: AppRoutes.b2b), isNull);
      expect(
        resolveB2bRedirect(roles: r, location: AppRoutes.b2bAccount),
        isNull,
      );
    });

    test('cashier cannot reach /b2b and is sent to their home', () {
      final r = _roles([RoleNames.jarzPosStaff]);
      expect(
        resolveB2bRedirect(roles: r, location: AppRoutes.b2b),
        AppRoutes.kanban,
      );
    });

    test('manager can reach both POS and B2B (no redirect)', () {
      final r = _roles(
        [RoleNames.jarzManager],
        canAccessB2b: true,
      );
      expect(resolveB2bRedirect(roles: r, location: AppRoutes.pos), isNull);
      expect(resolveB2bRedirect(roles: r, location: AppRoutes.b2b), isNull);
    });
  });
}

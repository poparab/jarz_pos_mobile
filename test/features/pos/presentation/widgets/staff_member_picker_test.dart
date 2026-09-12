import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/user_service.dart';
import 'package:jarz_pos/src/features/manager/presentation/sync_staff_customers_action.dart';
import 'package:jarz_pos/src/features/pos/data/models/draft_cart.dart';
import 'package:jarz_pos/src/features/pos/data/models/pos_models.dart';
import 'package:jarz_pos/src/features/pos/data/models/staff_customer_models.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/draft_cart_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/pos_repository.dart';
import 'package:jarz_pos/src/features/pos/data/repositories/staff_customer_repository.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/cart_widget.dart';
import 'package:jarz_pos/src/features/pos/state/pos_notifier.dart';

class _DummyPosRepository extends PosRepository {
  _DummyPosRepository() : super(Dio());

  @override
  Future<List<Map<String, dynamic>>> getItems(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getBundles(
    String posProfile, {
    String? priceList,
    String? customer,
    String? orderPurpose,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getPosPriceLists(
    String posProfile,
  ) async => const [];

  @override
  Future<List<CommercialPolicy>> getCommercialPolicies(
    String posProfile,
  ) async => const [_employeePolicy];

  @override
  Future<List<DeliverySlot>> getDeliverySlots(String posProfile) async =>
      const [];

  @override
  Future<String?> getCustomerPriceList(
    String customer,
    String posProfile, {
    String? orderPurpose,
  }) async => null;
}

class _DummyDraftCartRepository extends DraftCartRepository {
  @override
  Future<List<DraftCart>> loadAll() async => const [];

  @override
  Future<void> upsert(draft) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _PosNotifierStub extends PosNotifier {
  _PosNotifierStub(PosState initialState)
    : super(_DummyPosRepository(), _DummyDraftCartRepository()) {
    state = initialState;
  }
}

class _FakeStaffCustomerRepository extends StaffCustomerRepository {
  _FakeStaffCustomerRepository({
    this.hrmsAvailable = true,
    this.employees = const [],
    this.ensureError,
  }) : super(Dio());

  final bool hrmsAvailable;
  final List<StaffOrderEmployee> employees;
  final Object? ensureError;
  final List<String> ensured = [];

  @override
  Future<StaffOrderEmployeeList> listStaffForOrders({String? search}) async {
    return StaffOrderEmployeeList(
      hrmsAvailable: hrmsAvailable,
      employees: employees,
    );
  }

  @override
  Future<StaffCustomerEnsureResult> ensureStaffCustomer(String employee) async {
    ensured.add(employee);
    if (ensureError != null) throw ensureError!;
    return StaffCustomerEnsureResult(
      created: true,
      action: 'created',
      customer: {
        'name': 'CUST-$employee',
        'customer_name': 'Mona Adel',
        'employee': employee,
        'is_staff_customer': true,
      },
    );
  }
}

const _employeePolicy = CommercialPolicy(
  name: 'POL-EMPLOYEE',
  policyName: 'Employee Order',
  orderPurpose: 'Employee',
  deliverAtBranch: true,
);

const _manager = UserRoles(
  user: 'manager@example.invalid',
  roles: ['JARZ Manager'],
);

const _mona = StaffOrderEmployee(
  employee: 'HR-EMP-00007',
  employeeName: 'Mona Adel',
  branch: 'Heliopolis',
  designation: 'Cashier',
);

PosState _employeeOrderState({
  String? staffEmployee,
  String? staffEmployeeName,
}) {
  return PosState(
    selectedProfile: const {'name': 'Heliopolis POS'},
    availableCommercialPolicies: const [_employeePolicy],
    selectedCommercialPolicy: _employeePolicy,
    selectedCustomer: staffEmployee == null
        ? null
        : const {'name': 'CUST-HR-EMP-00007', 'customer_name': 'Mona Adel'},
    selectedStaffEmployee: staffEmployee,
    selectedStaffEmployeeName: staffEmployeeName,
  );
}

Widget _app({required List<Override> overrides, required Widget home}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

Future<_PosNotifierStub> _pumpCart(
  WidgetTester tester,
  PosState state,
  _FakeStaffCustomerRepository staffRepository,
) async {
  final notifier = _PosNotifierStub(state);
  await tester.pumpWidget(
    _app(
      overrides: [
        posNotifierProvider.overrideWith((ref) => notifier),
        userRolesFutureProvider.overrideWith((ref) async => _manager),
        staffCustomerRepositoryProvider.overrideWithValue(staffRepository),
      ],
      home: const Scaffold(body: CartWidget()),
    ),
  );
  await tester.pumpAndSettle();
  return notifier;
}

void main() {
  group('StaffMemberControl in the cart', () {
    testWidgets('should ask for a staff member on an Employee order', (
      tester,
    ) async {
      await _pumpCart(
        tester,
        _employeeOrderState(),
        _FakeStaffCustomerRepository(),
      );

      expect(find.byKey(const ValueKey('choose-staff-member')), findsOneWidget);
      expect(find.text('Collected at the branch'), findsOneWidget);
    });

    testWidgets('should show the chosen staff member with a change action', (
      tester,
    ) async {
      await _pumpCart(
        tester,
        _employeeOrderState(
          staffEmployee: 'HR-EMP-00007',
          staffEmployeeName: 'Mona Adel',
        ),
        _FakeStaffCustomerRepository(),
      );

      expect(find.byKey(const ValueKey('staff-member-name')), findsOneWidget);
      expect(find.text('Mona Adel'), findsWidgets);
      expect(find.text('Change'), findsOneWidget);
      expect(find.byKey(const ValueKey('choose-staff-member')), findsNothing);
    });

    testWidgets('should hide the control on a Standard order', (tester) async {
      await _pumpCart(
        tester,
        PosState(
          selectedProfile: const {'name': 'Heliopolis POS'},
          availableCommercialPolicies: const [_employeePolicy],
        ),
        _FakeStaffCustomerRepository(),
      );

      expect(find.byKey(const ValueKey('staff-member-control')), findsNothing);
    });

    testWidgets('should put the order on the picked staff member', (
      tester,
    ) async {
      final staff = _FakeStaffCustomerRepository(employees: const [_mona]);
      final notifier = await _pumpCart(tester, _employeeOrderState(), staff);

      await tester.tap(find.byKey(const ValueKey('choose-staff-member')));
      await tester.pumpAndSettle();

      expect(find.text('Heliopolis • Cashier'), findsOneWidget);
      expect(
        find.text('A customer account will be created for them'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('staff-member-HR-EMP-00007')));
      await tester.pumpAndSettle();

      expect(staff.ensured, ['HR-EMP-00007']);
      expect(notifier.state.selectedStaffEmployee, 'HR-EMP-00007');
      expect(notifier.state.selectedCustomer?['name'], 'CUST-HR-EMP-00007');
      expect(find.text('Staff customer created for Mona Adel'), findsOneWidget);
    });

    testWidgets('should pick from a bottom sheet on a phone', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final staff = _FakeStaffCustomerRepository(employees: const [_mona]);
      final notifier = await _pumpCart(tester, _employeeOrderState(), staff);

      await tester.ensureVisible(
        find.byKey(const ValueKey('choose-staff-member')),
      );
      await tester.tap(find.byKey(const ValueKey('choose-staff-member')));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('staff-member-HR-EMP-00007')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(notifier.state.selectedStaffEmployee, 'HR-EMP-00007');
    });

    testWidgets('should keep the picker open and explain an ensure failure', (
      tester,
    ) async {
      final staff = _FakeStaffCustomerRepository(
        employees: const [_mona],
        ensureError: Exception('Failed to prepare the staff customer'),
      );
      final notifier = await _pumpCart(tester, _employeeOrderState(), staff);

      await tester.tap(find.byKey(const ValueKey('choose-staff-member')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('staff-member-HR-EMP-00007')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('staff-member-ensure-error')),
        findsOneWidget,
      );
      expect(notifier.state.selectedStaffEmployee, isNull);
    });

    testWidgets('should explain when HRMS is not installed', (tester) async {
      await _pumpCart(
        tester,
        _employeeOrderState(),
        _FakeStaffCustomerRepository(hrmsAvailable: false),
      );

      await tester.tap(find.byKey(const ValueKey('choose-staff-member')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('staff-member-hrms-unavailable')),
        findsOneWidget,
      );
      expect(find.text('HR is not set up'), findsOneWidget);
    });
  });

  group('StaffCustomersSyncResultDialog', () {
    testWidgets('should list counts, skipped and conflicting employees', (
      tester,
    ) async {
      const result = StaffCustomerSyncResult(
        created: [StaffCustomerSyncEntry(employee: 'HR-EMP-1')],
        adopted: [
          StaffCustomerSyncEntry(employee: 'HR-EMP-2'),
          StaffCustomerSyncEntry(employee: 'HR-EMP-3'),
        ],
        existing: [],
        skipped: [
          StaffCustomerSyncEntry(
            employee: 'HR-EMP-4',
            employeeName: 'Karim',
            reason: 'No company',
          ),
        ],
        conflicts: [
          StaffCustomerSyncEntry(
            employee: 'HR-EMP-5',
            employeeName: 'Salma',
            customers: ['Salma A', 'Salma B'],
          ),
        ],
      );

      await tester.pumpWidget(
        _app(
          overrides: const [],
          home: const Scaffold(
            body: StaffCustomersSyncResultDialog(result: result),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Created: 1'), findsOneWidget);
      expect(find.text('Linked to an existing customer: 2'), findsOneWidget);
      expect(find.text('Already linked: 0'), findsOneWidget);
      expect(find.text('Karim — No company'), findsOneWidget);
      expect(find.text('Salma'), findsOneWidget);
      expect(find.text('Matching customers: Salma A, Salma B'), findsOneWidget);
    });

    testWidgets('should hide the sync action from a non-manager', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          overrides: [
            userRolesFutureProvider.overrideWith(
              (ref) async => const UserRoles(
                user: 'staff@example.invalid',
                roles: ['Jarz POS Staff'],
              ),
            ),
          ],
          home: const Scaffold(body: SyncStaffCustomersAction()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sync-staff-customers')), findsNothing);
    });

    testWidgets('should run the sync after confirmation for a manager', (
      tester,
    ) async {
      final staff = _SyncingStaffCustomerRepository();
      var synced = 0;
      await tester.pumpWidget(
        _app(
          overrides: [
            userRolesFutureProvider.overrideWith((ref) async => _manager),
            staffCustomerRepositoryProvider.overrideWithValue(staff),
          ],
          home: Scaffold(
            body: SyncStaffCustomersAction(onSynced: () => synced++),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('sync-staff-customers')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('sync-staff-customers-confirm')),
      );
      await tester.pumpAndSettle();

      expect(staff.calls, 1);
      expect(synced, 1);
      expect(find.text('Created: 1'), findsOneWidget);
    });
  });
}

class _SyncingStaffCustomerRepository extends StaffCustomerRepository {
  _SyncingStaffCustomerRepository() : super(Dio());

  int calls = 0;

  @override
  Future<StaffCustomerSyncResult> syncStaffCustomers() async {
    calls += 1;
    return const StaffCustomerSyncResult(
      created: [StaffCustomerSyncEntry(employee: 'HR-EMP-1')],
    );
  }
}

// Smoke tests of the User management screens against a fake repository: the
// list renders in both languages, the server rules show in the form (view
// only, self), create validates before calling the server, and a refused
// delete shows the server's own sentence.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/user_admin/data/user_admin_repository.dart';
import 'package:jarz_pos/src/features/user_admin/models/user_admin_models.dart';
import 'package:jarz_pos/src/features/user_admin/presentation/user_admin_form_screen.dart';
import 'package:jarz_pos/src/features/user_admin/presentation/user_admin_list_screen.dart';

const _refusal =
    'Ali is linked to 3 Sales Invoices and cannot be deleted. '
    'Disable the account instead.';

final _users = <String, Map<String, dynamic>>{
  'ali@example.com': {
    'name': 'ali@example.com',
    'email': 'ali@example.com',
    'full_name': 'Ali Hassan',
    'first_name': 'Ali',
    'last_name': 'Hassan',
    'enabled': 1,
    'role_profiles': ['Jarz Cashier'],
    'tier': 'staff',
    'branches': ['Dokki'],
    'can_edit': true,
  },
  'sara@example.com': {
    'name': 'sara@example.com',
    'full_name': 'Sara',
    'first_name': 'Sara',
    'enabled': 0,
    'role_profiles': ['Jarz Line Manager'],
    'tier': 'line_manager',
    'can_edit': true,
  },
  'admin@example.com': {
    'name': 'admin@example.com',
    'full_name': 'Sys Admin',
    'first_name': 'Sys',
    'enabled': 1,
    'role_profiles': ['System Manager'],
    'tier': 'manager',
    'is_privileged': true,
    'can_edit': false,
  },
  'me@example.com': {
    'name': 'me@example.com',
    'full_name': 'Me Manager',
    'first_name': 'Me',
    'enabled': 1,
    'role_profiles': ['Jarz Manager'],
    'tier': 'manager',
    'is_self': true,
    'can_edit': true,
  },
};

class _FakeRepository implements UserAdminRepository {
  _FakeRepository({this.canManage = true});

  final bool canManage;
  int createCalls = 0;

  @override
  Future<UserAdminContext> getContext() async => UserAdminContext.fromJson({
    'can_manage': canManage,
    'min_password_length': 8,
    'role_profiles': [
      {
        'name': 'Jarz Manager',
        'roles': ['JARZ Manager'],
        'tier': 'manager',
        'privileged': true,
        'assignable': false,
      },
      {
        'name': 'Jarz Line Manager',
        'roles': ['JARZ Line Manager'],
        'tier': 'line_manager',
        'assignable': true,
      },
      {
        'name': 'Jarz Cashier',
        'roles': ['POS User'],
        'tier': 'staff',
        'assignable': true,
      },
    ],
  });

  @override
  Future<List<UserAdminUser>> listUsers({
    String? search,
    bool includeDisabled = true,
  }) async => _users.values.map(UserAdminUser.fromJson).toList();

  @override
  Future<UserAdminUser> getUser(String user) async =>
      UserAdminUser.fromJson(_users[user]!);

  @override
  Future<List<UserAdminEmployee>> listEmployees({String? search}) async => [
    UserAdminEmployee.fromJson({
      'name': 'HR-EMP-1',
      'employee_name': 'Mona',
      'branch': 'Dokki',
      'user_id': 'mona@example.com',
    }),
  ];

  @override
  Future<UserAdminUser> createUser({
    required String email,
    required String firstName,
    required String password,
    required List<String> roleProfiles,
    String? lastName,
    String? mobileNo,
    bool? requirePosShift,
    String? employee,
  }) async {
    createCalls++;
    return UserAdminUser.fromJson({'name': email, 'first_name': firstName});
  }

  @override
  Future<UserAdminUser> updateUser({
    required String user,
    String? firstName,
    String? lastName,
    String? mobileNo,
    List<String>? roleProfiles,
    bool? requirePosShift,
    String? employee,
    bool clearEmployee = false,
  }) async => UserAdminUser.fromJson(_users[user]!);

  @override
  Future<UserAdminUser> setEnabled({
    required String user,
    required bool enabled,
  }) async =>
      UserAdminUser.fromJson({..._users[user]!, 'enabled': enabled ? 1 : 0});

  @override
  Future<UserAdminAck> resetPassword({
    required String user,
    required String newPassword,
    bool signOut = true,
  }) async => const UserAdminAck(ok: true);

  @override
  Future<UserAdminAck> deleteUser(String user) async {
    final options = RequestOptions(path: '/delete');
    throw DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 417,
        data: {
          'exc_type': 'LinkExistsError',
          '_server_messages':
              '["{\\"message\\": \\"$_refusal\\", \\"indicator\\": \\"red\\"}"]',
        },
      ),
      type: DioExceptionType.badResponse,
    );
  }
}

Future<_FakeRepository> _pump(
  WidgetTester tester,
  Widget home, {
  Locale locale = const Locale('en'),
  bool canManage = true,
  Size size = const Size(1000, 2600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _FakeRepository(canManage: canManage);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [userAdminRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('list renders every account ($locale)', (tester) async {
      await _pump(tester, const UserAdminListScreen(), locale: locale);
      expect(tester.takeException(), isNull);
      expect(find.text('Ali Hassan'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('Sys Admin'), findsOneWidget);
      expect(find.byKey(const ValueKey('user-admin-locked')), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  }

  testWidgets('list filters: Disabled shows only disabled accounts', (
    tester,
  ) async {
    await _pump(tester, const UserAdminListScreen());
    await tester.tap(find.widgetWithText(ChoiceChip, 'Disabled'));
    await tester.pumpAndSettle();
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Ali Hassan'), findsNothing);
  });

  testWidgets('list: no FAB and a lock message when the caller cannot manage', (
    tester,
  ) async {
    await _pump(tester, const UserAdminListScreen(), canManage: false);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Ali Hassan'), findsNothing);
  });

  testWidgets('a System Manager account is view only', (tester) async {
    await _pump(
      tester,
      const UserAdminFormScreen(userName: 'admin@example.com'),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('user-admin-save')), findsNothing);
    expect(
      find.byKey(const ValueKey('user-admin-change-password')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('user-admin-delete')), findsNothing);
  });

  testWidgets('own account: no disable/delete, role profiles locked', (
    tester,
  ) async {
    await _pump(tester, const UserAdminFormScreen(userName: 'me@example.com'));
    expect(
      find.byKey(const ValueKey('user-admin-change-password')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('user-admin-toggle-enabled')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('user-admin-delete')), findsNothing);
    final boxes = tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(boxes, isNotEmpty);
    expect(boxes.every((b) => b.onChanged == null), isTrue);
  });

  testWidgets('changing profiles warns that roles will be replaced', (
    tester,
  ) async {
    await _pump(tester, const UserAdminFormScreen(userName: 'ali@example.com'));
    expect(
      find.byKey(const ValueKey('user-admin-roles-warning')),
      findsNothing,
    );
    await tester.tap(
      find.widgetWithText(CheckboxListTile, 'Jarz Line Manager'),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('user-admin-roles-warning')),
      findsOneWidget,
    );
  });

  testWidgets('create validates before calling the server', (tester) async {
    final repo = await _pump(tester, const UserAdminFormScreen());
    await tester.tap(find.byKey(const ValueKey('user-admin-save')));
    await tester.pumpAndSettle();
    expect(repo.createCalls, 0);
    expect(find.text('Required'), findsWidgets);
    expect(find.text('Select at least one role profile.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('user-admin-email')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const ValueKey('user-admin-password')),
      'short',
    );
    await tester.tap(find.byKey(const ValueKey('user-admin-save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('At least 8 characters'), findsWidgets);
    expect(repo.createCalls, 0);
  });

  testWidgets('a refused delete shows the server sentence in Arabic', (
    tester,
  ) async {
    await _pump(
      tester,
      const UserAdminFormScreen(userName: 'ali@example.com'),
      locale: const Locale('ar'),
    );
    await tester.tap(find.byKey(const ValueKey('user-admin-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    expect(find.text(_refusal), findsOneWidget);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('fits a narrow phone without overflow ($locale)', (
      tester,
    ) async {
      await _pump(
        tester,
        const UserAdminListScreen(),
        locale: locale,
        size: const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
      await _pump(
        tester,
        const UserAdminFormScreen(userName: 'ali@example.com'),
        locale: locale,
        size: const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
      await _pump(
        tester,
        const UserAdminFormScreen(),
        locale: locale,
        size: const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

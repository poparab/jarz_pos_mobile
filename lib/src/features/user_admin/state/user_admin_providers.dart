import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_admin_repository.dart';
import '../models/user_admin_models.dart';

/// What the caller may do plus the role profiles on offer.
final userAdminContextProvider = FutureProvider.autoDispose<UserAdminContext>((
  ref,
) async {
  return ref.watch(userAdminRepositoryProvider).getContext();
});

/// Every account, disabled ones included. The team is small, so search and
/// the filter chips run on this one list rather than re-querying the server.
final userAdminUsersProvider = FutureProvider.autoDispose<List<UserAdminUser>>((
  ref,
) async {
  return ref.watch(userAdminRepositoryProvider).listUsers();
});

/// One account, fresh from the server, for the detail screen.
final userAdminUserProvider = FutureProvider.autoDispose
    .family<UserAdminUser, String>((ref, user) async {
      return ref.watch(userAdminRepositoryProvider).getUser(user);
    });

/// Employee picker results for one search string.
final userAdminEmployeesProvider = FutureProvider.autoDispose
    .family<List<UserAdminEmployee>, String>((ref, search) async {
      return ref
          .watch(userAdminRepositoryProvider)
          .listEmployees(search: search);
    });

enum UserStatusFilter { all, active, disabled }

/// Free-text filter on the list.
final userAdminSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final userAdminStatusFilterProvider =
    StateProvider.autoDispose<UserStatusFilter>((ref) => UserStatusFilter.all);

/// Null means every tier.
final userAdminTierFilterProvider = StateProvider.autoDispose<UserTier?>(
  (ref) => null,
);

/// Applies search, status and tier filters.
List<UserAdminUser> filterUsers(
  List<UserAdminUser> users, {
  String query = '',
  UserStatusFilter status = UserStatusFilter.all,
  UserTier? tier,
}) {
  return users.where((u) {
    if (status == UserStatusFilter.active && !u.enabled) return false;
    if (status == UserStatusFilter.disabled && u.enabled) return false;
    if (tier != null && u.tier != tier) return false;
    return u.matches(query);
  }).toList();
}

/// The filtered list the screen renders.
final userAdminFilteredUsersProvider =
    Provider.autoDispose<AsyncValue<List<UserAdminUser>>>((ref) {
      final users = ref.watch(userAdminUsersProvider);
      final query = ref.watch(userAdminSearchProvider);
      final status = ref.watch(userAdminStatusFilterProvider);
      final tier = ref.watch(userAdminTierFilterProvider);
      return users.whenData(
        (list) => filterUsers(list, query: query, status: status, tier: tier),
      );
    });

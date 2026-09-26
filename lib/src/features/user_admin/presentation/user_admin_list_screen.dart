import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/user_admin_models.dart';
import '../state/user_admin_providers.dart';
import 'widgets/user_admin_widgets.dart';

/// User management: every ERPNext account, with who can do what.
///
/// Gated by the server (JARZ Manager / System Manager). The screen asks
/// `get_context` first and shows a lock message when the caller may not
/// manage accounts, instead of a bare 403.
class UserAdminListScreen extends ConsumerWidget {
  const UserAdminListScreen({super.key});

  static const maxContentWidth = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contextAsync = ref.watch(userAdminContextProvider);
    final canManage = contextAsync.valueOrNull?.canManage ?? false;

    Widget body;
    if (contextAsync.hasError && !contextAsync.hasValue) {
      body = UserAdminErrorPanel(
        error: contextAsync.error!,
        onRetry: () => ref.invalidate(userAdminContextProvider),
      );
    } else if (!contextAsync.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (!canManage) {
      body = UserAdminMessage(
        icon: Icons.lock_outline,
        message: l10n.userAdminAccessDenied,
      );
    } else {
      body = const _UsersBody();
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
        title: Text(l10n.userAdminTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userAdminContextProvider);
              ref.invalidate(userAdminUsersProvider);
            },
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              heroTag: 'user-admin-add',
              onPressed: () => context.push(AppRoutes.userNew),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.userAdminAddUser),
            )
          : null,
      body: body,
    );
  }
}

class _UsersBody extends ConsumerWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userAdminFilteredUsersProvider);
    return usersAsync.when(
      // Keep the list on screen while a re-fetch after a change is in flight.
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (users) => _UsersList(users: users),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => UserAdminErrorPanel(
        error: error,
        onRetry: () => ref.invalidate(userAdminUsersProvider),
      ),
    );
  }
}

class _UsersList extends ConsumerWidget {
  const _UsersList({required this.users});

  final List<UserAdminUser> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final status = ref.watch(userAdminStatusFilterProvider);
    final tier = ref.watch(userAdminTierFilterProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(userAdminUsersProvider.future),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: UserAdminListScreen.maxContentWidth,
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.userAdminSearchHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        ref.read(userAdminSearchProvider.notifier).state =
                            value,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      for (final s in UserStatusFilter.values)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: ChoiceChip(
                            label: Text(_statusLabel(context, s)),
                            selected: status == s,
                            onSelected: (_) =>
                                ref
                                        .read(
                                          userAdminStatusFilterProvider
                                              .notifier,
                                        )
                                        .state =
                                    s,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Row(
                    children: [
                      for (final t in UserTier.values)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: FilterChip(
                            label: Text(tierFilterLabel(l10n, t)),
                            selected: tier == t,
                            selectedColor: tierColor(
                              theme,
                              t,
                            ).withValues(alpha: 0.18),
                            onSelected: (selected) =>
                                ref
                                    .read(userAdminTierFilterProvider.notifier)
                                    .state = selected
                                ? t
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(
                    l10n.userAdminCount(users.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (users.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: UserAdminMessage(
                    icon: Icons.person_search_outlined,
                    message: l10n.userAdminNoUsers,
                  ),
                )
              else
                SliverList.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      UserAdminRow(user: users[index]),
                ),
              // Room for the FAB.
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(BuildContext context, UserStatusFilter s) {
    final l10n = context.l10n;
    switch (s) {
      case UserStatusFilter.all:
        return l10n.userAdminFilterAll;
      case UserStatusFilter.active:
        return l10n.userAdminFilterActive;
      case UserStatusFilter.disabled:
        return l10n.userAdminFilterDisabled;
    }
  }
}

/// One account in the list.
class UserAdminRow extends StatelessWidget {
  const UserAdminRow({super.key, required this.user});

  final UserAdminUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.userDetailFor(user.name)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(user: user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TierTag(tier: user.tier),
                        if (user.isSelf)
                          UserAdminTag(text: l10n.userAdminYouTag),
                        if (!user.enabled)
                          UserAdminTag(
                            text: l10n.userAdminDisabledTag,
                            color: theme.colorScheme.error,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.emailOrName,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.roleProfiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          user.roleProfiles.join(' · '),
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (user.branches.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 13,
                              color: muted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.branches.join(', '),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: user.canEdit
                    ? Icon(Icons.chevron_right, color: muted)
                    : Tooltip(
                        message: l10n.userAdminViewOnly,
                        child: Icon(
                          Icons.lock_outline,
                          key: const ValueKey('user-admin-locked'),
                          color: muted,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    // Disabled accounts stay listed (they are the ones re-enabled), greyed.
    return user.enabled ? card : Opacity(opacity: 0.6, child: card);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/branch_access_repository.dart';
import '../models/branch_access_models.dart';
import '../state/branch_access_providers.dart';
import 'server_error_text.dart';
import 'widgets/branch_access_chip.dart';

/// Branch access: who may open which branch's POS.
///
/// Membership is the POS Profile's user table, edited here by hand; the roster
/// never computes it. A branch with an open shift is frozen - the server
/// refuses every change on it - so the screen shows that up front instead of
/// letting the manager find out from an error.
class BranchAccessScreen extends ConsumerWidget {
  const BranchAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.watch(canActAsLineManagerProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          title: Text(l10n.branchAccessTitle),
          actions: [
            IconButton(
              tooltip: l10n.commonRetry,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(branchAccessOverviewProvider);
                ref.invalidate(branchAccessLogProvider);
              },
            ),
          ],
          bottom: canManage
              ? TabBar(
                  tabs: [
                    Tab(text: l10n.branchAccessTabPeople),
                    Tab(text: l10n.branchAccessTabHistory),
                  ],
                )
              : null,
        ),
        body: !canManage
            ? _Message(
                icon: Icons.lock_outline,
                message: l10n.branchAccessAccessDenied,
              )
            : const TabBarView(children: [_PeopleTab(), _HistoryTab()]),
      ),
    );
  }
}

// ── Actions ──────────────────────────────────────────────────────────────

/// Run one change, report it, and re-fetch whatever the outcome.
///
/// Re-fetched on failure too: the usual failure is "branch just opened", and
/// the stale screen would still be offering the change that was refused.
Future<void> _perform(
  BuildContext context,
  Future<String> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.error;
  // The container, not the card's ref: the card that started this may have
  // been rebuilt away by the time the request answers.
  final container = ProviderScope.containerOf(context, listen: false);
  try {
    final message = await action();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } catch (error) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(serverErrorText(context, error)),
        backgroundColor: errorColor,
        duration: const Duration(seconds: 6),
      ),
    );
  } finally {
    container.invalidate(branchAccessOverviewProvider);
    container.invalidate(branchAccessLogProvider);
  }
}

Future<void> _toggleMembership(
  BuildContext context,
  WidgetRef ref,
  BranchAccessUser user,
  BranchAccessBranch branch,
) async {
  final l10n = context.l10n;
  final branchName = branch.posProfile;
  // A row that only a day access put there is not a permanent membership:
  // tapping it makes it one (the server flips the grant to permanent).
  final allowed = !user.isPermanentOn(branchName);
  final note = await showDialog<String>(
    context: context,
    builder: (_) => _NoteConfirmDialog(
      title: allowed
          ? l10n.branchAccessAddTitle(branchName)
          : l10n.branchAccessRemoveTitle(branchName),
      body: !allowed
          ? l10n.branchAccessRemoveBody(user.displayName, branchName)
          : (user.isTemporaryOn(branchName)
                ? l10n.branchAccessMakePermanentBody(
                    user.displayName,
                    branchName,
                  )
                : l10n.branchAccessAddBody(user.displayName, branchName)),
      confirmLabel: allowed
          ? l10n.branchAccessAddAction
          : l10n.branchAccessRemoveAction,
      destructive: !allowed,
    ),
  );
  if (note == null || !context.mounted) return;

  await _perform(context, () async {
    final result = await ref
        .read(branchAccessRepositoryProvider)
        .setBranchAccess(
          user: user.user,
          posProfile: branchName,
          allowed: allowed,
          notes: note,
        );
    if (!result.changed) return l10n.branchAccessUnchanged;
    return allowed
        ? l10n.branchAccessAdded(user.displayName, branchName)
        : l10n.branchAccessRemoved(user.displayName, branchName);
  });
}

Future<void> _giveDayAccess(
  BuildContext context,
  WidgetRef ref,
  BranchAccessUser user,
  List<BranchAccessBranch> candidates,
) async {
  final l10n = context.l10n;
  final choice = await showDialog<_DayAccessChoice>(
    context: context,
    builder: (_) => _DayAccessDialog(user: user, branches: candidates),
  );
  if (choice == null || !context.mounted) return;
  final dateText = formatDate(context, choice.date, pattern: 'd MMM');

  await _perform(context, () async {
    final result = await ref
        .read(branchAccessRepositoryProvider)
        .grantDayAccess(
          user: user.user,
          posProfile: choice.posProfile,
          accessDate: isoDate(choice.date),
          notes: choice.note,
        );
    // The server's sentence says whether it started now or is scheduled.
    return result.message ?? l10n.branchAccessDayGranted(dateText);
  });
}

Future<void> _cancelDayAccess(
  BuildContext context,
  WidgetRef ref,
  BranchAccessUser user,
  DayAccess day,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.branchAccessCancelDayTitle),
      content: Text(
        l10n.branchAccessCancelDayBody(
          user.displayName,
          day.posProfile,
          formatDateString(ctx, day.accessDate, pattern: 'd MMM'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.branchAccessKeep),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.branchAccessCancelDay),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await _perform(context, () async {
    await ref.read(branchAccessRepositoryProvider).cancelDayAccess(day.name);
    return l10n.branchAccessDayCancelled;
  });
}

/// `YYYY-MM-DD`, the only date shape the API takes.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

// ── People tab ───────────────────────────────────────────────────────────

class _PeopleTab extends ConsumerWidget {
  const _PeopleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(branchAccessOverviewProvider);
    return overviewAsync.when(
      // Keep the list on screen while a re-fetch after a change is in flight.
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (overview) => _PeopleBody(overview: overview),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorPanel(
        error: error,
        onRetry: () => ref.invalidate(branchAccessOverviewProvider),
      ),
    );
  }
}

class _PeopleBody extends ConsumerWidget {
  const _PeopleBody({required this.overview});

  final BranchAccessOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(branchAccessSearchProvider);
    final users = overview.users.where((u) => u.matches(query)).toList();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(branchAccessOverviewProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: overview.branches.isEmpty
                  ? Text(l10n.branchAccessNoBranches)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final branch in overview.branches)
                          BranchStatusChip(branch: branch),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.branchAccessSearchHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) =>
                    ref.read(branchAccessSearchProvider.notifier).state = value,
              ),
            ),
          ),
          if (users.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _Message(
                icon: Icons.person_search_outlined,
                message: l10n.branchAccessNoUsers,
              ),
            )
          else
            SliverList.builder(
              itemCount: users.length,
              itemBuilder: (context, index) =>
                  _UserCard(user: users[index], overview: overview),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// A branch's open/closed state. Open means frozen: nobody's access to it can
/// change until that shift is closed.
class BranchStatusChip extends StatelessWidget {
  const BranchStatusChip({super.key, required this.branch});

  final BranchAccessBranch branch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final open = branch.openShift;
    final status = open == null
        ? l10n.branchAccessBranchClosed
        : l10n.branchAccessOpenSince(
            formatOpenSince(context, open),
            open.holder,
          );
    final color = open == null
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.tertiary;
    return Chip(
      avatar: Icon(
        open == null ? Icons.storefront_outlined : Icons.lock,
        size: 18,
        color: color,
      ),
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: branch.posProfile,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: '\n$status',
              style: TextStyle(color: color),
            ),
          ],
        ),
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user, required this.overview});

  final BranchAccessUser user;
  final BranchAccessOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final userLock = userLockReason(
      l10n,
      user,
      canManageAll: overview.canManageAll,
    );

    // Where a one-day access could still add something: branches the caller
    // manages that this person is not already a permanent member of.
    final dayCandidates = overview.branches
        .where((b) => b.manageable && !user.isPermanentOn(b.posProfile))
        .toList();

    final subtitleParts = <String>[
      if (user.employeeName != null && user.employeeName != user.fullName)
        user.employeeName!,
      user.user,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            user.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (user.isSelf) _Tag(text: l10n.branchAccessYouTag),
                          if (!user.enabled)
                            _Tag(
                              text: l10n.branchAccessDisabledTag,
                              color: theme.colorScheme.error,
                            ),
                        ],
                      ),
                      Text(
                        subtitleParts.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (userLock != null)
                  // Disabled, but still explains itself on tap.
                  Tooltip(
                    message: userLock,
                    triggerMode: TooltipTriggerMode.tap,
                    child: const IconButton(
                      key: ValueKey('give-day-access-locked'),
                      icon: Icon(Icons.more_time),
                      onPressed: null,
                    ),
                  )
                else
                  IconButton(
                    tooltip: l10n.branchAccessGiveDay,
                    icon: const Icon(Icons.more_time),
                    onPressed: dayCandidates.isEmpty
                        ? null
                        : () =>
                              _giveDayAccess(context, ref, user, dayCandidates),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final branch in overview.branches)
                  BranchAccessChip(
                    user: user,
                    branch: branch,
                    canManageAll: overview.canManageAll,
                    onTap: () => _toggleMembership(context, ref, user, branch),
                  ),
              ],
            ),
            if (user.dayAccess.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.branchAccessDaySection,
                style: theme.textTheme.labelMedium,
              ),
              for (final day in user.dayAccess)
                _DayAccessRow(
                  user: user,
                  day: day,
                  branch: overview.branch(day.posProfile),
                  userLock: userLock,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayAccessRow extends ConsumerWidget {
  const _DayAccessRow({
    required this.user,
    required this.day,
    required this.branch,
    required this.userLock,
  });

  final BranchAccessUser user;
  final DayAccess day;
  final BranchAccessBranch? branch;

  /// Why nothing about this person may be changed, or null.
  final String? userLock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final b = branch;
    // Cancelling an Active grant removes the row, which the server refuses
    // while the branch is open; a Scheduled one touches nothing yet.
    String? lockReason;
    if (userLock != null) {
      lockReason = userLock;
    } else if (b == null || !b.manageable) {
      lockReason = l10n.branchAccessNotYourBranch;
    } else if (day.isActive && b.openShift != null) {
      lockReason = l10n.branchAccessLockedOpen(
        b.posProfile,
        formatOpenSince(context, b.openShift!),
        b.openShift!.holder,
      );
    }

    final button = TextButton(
      onPressed: lockReason != null
          ? null
          : () => _cancelDayAccess(context, ref, user, day),
      child: Text(l10n.branchAccessCancelDay),
    );

    return Row(
      children: [
        Icon(
          day.isActive ? Icons.today : Icons.event,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${l10n.branchAccessChipDay(day.posProfile, formatDateString(context, day.accessDate, pattern: 'EEE d MMM'))}'
            ' · ${dayAccessStatusLabel(l10n, day.status)}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (lockReason != null)
          Tooltip(
            message: lockReason,
            triggerMode: TooltipTriggerMode.tap,
            child: button,
          )
        else
          button,
      ],
    );
  }
}

String dayAccessStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'Active':
      return l10n.branchAccessDayStatusActive;
    case 'Scheduled':
      return l10n.branchAccessDayStatusScheduled;
    case 'Ended':
      return l10n.branchAccessDayStatusEnded;
    case 'Cancelled':
      return l10n.branchAccessDayStatusCancelled;
    default:
      return status;
  }
}

// ── Dialogs ──────────────────────────────────────────────────────────────

/// Confirm a change with an optional note. Pops the note ('' when left blank)
/// on confirm, null on cancel.
class _NoteConfirmDialog extends StatefulWidget {
  const _NoteConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.destructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final bool destructive;

  @override
  State<_NoteConfirmDialog> createState() => _NoteConfirmDialogState();
}

class _NoteConfirmDialogState extends State<_NoteConfirmDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.body),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.branchAccessNoteLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(_note.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _DayAccessChoice {
  const _DayAccessChoice({
    required this.posProfile,
    required this.date,
    this.note,
  });

  final String posProfile;
  final DateTime date;
  final String? note;
}

class _DayAccessDialog extends StatefulWidget {
  const _DayAccessDialog({required this.user, required this.branches});

  final BranchAccessUser user;
  final List<BranchAccessBranch> branches;

  @override
  State<_DayAccessDialog> createState() => _DayAccessDialogState();
}

class _DayAccessDialogState extends State<_DayAccessDialog> {
  late String? _branch = widget.branches.isEmpty
      ? null
      : widget.branches.first.posProfile;
  late DateTime _date = _today;
  final _note = TextEditingController();

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today,
      // The server refuses anything further ahead.
      lastDate: today.add(const Duration(days: 14)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    BranchAccessBranch? selected;
    for (final b in widget.branches) {
      if (b.posProfile == _branch) selected = b;
    }
    // Starting today on an open branch is refused; say so before submitting.
    // A later day is fine - the hourly job starts it once the branch closes.
    final openShift = selected?.openShift;
    final warn = openShift != null && isoDate(_date) == isoDate(_today)
        ? l10n.branchAccessLockedOpen(
            selected!.posProfile,
            formatOpenSince(context, openShift),
            openShift.holder,
          )
        : null;

    return AlertDialog(
      title: Text(l10n.branchAccessDayTitle(widget.user.displayName)),
      content: SingleChildScrollView(
        child: widget.branches.isEmpty
            ? Text(l10n.branchAccessDayNoBranch)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _branch,
                    decoration: InputDecoration(
                      labelText: l10n.branchAccessDayBranch,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final b in widget.branches)
                        DropdownMenuItem(
                          value: b.posProfile,
                          child: Text(b.posProfile),
                        ),
                    ],
                    onChanged: (value) => setState(() => _branch = value),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.branchAccessDayDate,
                        helperText: l10n.branchAccessDayHelper,
                        helperMaxLines: 3,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        formatDate(context, _date, pattern: 'EEEE d MMM'),
                      ),
                    ),
                  ),
                  if (warn != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      warn,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.branchAccessNoteLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _branch == null
              ? null
              : () => Navigator.of(context).pop(
                  _DayAccessChoice(
                    posProfile: _branch!,
                    date: _date,
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  ),
                ),
          child: Text(l10n.branchAccessAddAction),
        ),
      ],
    );
  }
}

// ── History tab ──────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final log = ref.watch(branchAccessLogProvider);
    final filter = ref.watch(branchAccessLogBranchProvider);
    // A line manager's log is already limited to their own branches, so only
    // those are offered as a filter; the manager tier sees every branch.
    final overview = ref.watch(branchAccessOverviewProvider).asData?.value;
    final branches = overview == null
        ? const <String>[]
        : overview.branches
              .where((b) => overview.canManageAll || b.manageable)
              .map((b) => b.posProfile)
              .toList();

    Widget list;
    if (log.rows.isEmpty && log.loading) {
      list = const Center(child: CircularProgressIndicator());
    } else if (log.rows.isEmpty && log.error != null) {
      list = _ErrorPanel(
        error: log.error!,
        onRetry: () => ref.read(branchAccessLogProvider.notifier).refresh(),
      );
    } else if (log.rows.isEmpty) {
      list = _Message(
        icon: Icons.history,
        message: l10n.branchAccessHistoryEmpty,
      );
    } else {
      final showFooter = log.hasMore || log.error != null;
      list = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Infinite scroll: fetch the next page near the bottom. Not after a
          // failed page - that waits for the retry button, not every scroll.
          if (notification.metrics.extentAfter < 400 &&
              log.hasMore &&
              !log.loading &&
              log.error == null) {
            ref.read(branchAccessLogProvider.notifier).loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => ref.read(branchAccessLogProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: log.rows.length + (showFooter ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= log.rows.length) {
                if (log.error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          serverErrorText(context, log.error),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(branchAccessLogProvider.notifier)
                              .loadMore(),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _LogTile(entry: log.rows[index]);
            },
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: DropdownButtonFormField<String?>(
            initialValue: filter,
            decoration: InputDecoration(
              labelText: l10n.branchAccessDayBranch,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.branchAccessHistoryAllBranches),
              ),
              for (final b in branches)
                DropdownMenuItem<String?>(value: b, child: Text(b)),
            ],
            onChanged: (value) =>
                ref.read(branchAccessLogBranchProvider.notifier).state = value,
          ),
        ),
        Expanded(child: list),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final BranchAccessLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final when = entry.creationTime;
    final meta = <String>[
      if (entry.actorName.isNotEmpty)
        l10n.branchAccessHistoryBy(entry.actorName),
      if (when != null) formatDateTime(context, when, pattern: 'd MMM, HH:mm'),
      if (entry.source != null) logSourceLabel(l10n, entry.source!),
    ];
    return ListTile(
      leading: Icon(
        _actionIcon(entry.action),
        color: theme.colorScheme.primary,
      ),
      title: Text(
        '${logActionLabel(l10n, entry.action)} · ${entry.posProfile}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        [
          entry.subjectName,
          meta.join(' · '),
          if (entry.notes != null) entry.notes!,
        ].join('\n'),
      ),
      isThreeLine: true,
    );
  }

  static IconData _actionIcon(String action) {
    switch (action) {
      case 'Added':
        return Icons.person_add_alt_1_outlined;
      case 'Removed':
        return Icons.person_remove_outlined;
      case 'Day Access Scheduled':
        return Icons.event;
      case 'Day Access Started':
        return Icons.today;
      case 'Day Access Ended':
        return Icons.event_available;
      case 'Day Access Cancelled':
        return Icons.event_busy;
      default:
        return Icons.history;
    }
  }
}

/// Log actions are a server-side Select, stored in English; translated here.
String logActionLabel(AppLocalizations l10n, String action) {
  switch (action) {
    case 'Added':
      return l10n.branchAccessActionAdded;
    case 'Removed':
      return l10n.branchAccessActionRemoved;
    case 'Day Access Scheduled':
      return l10n.branchAccessActionDayScheduled;
    case 'Day Access Started':
      return l10n.branchAccessActionDayStarted;
    case 'Day Access Ended':
      return l10n.branchAccessActionDayEnded;
    case 'Day Access Cancelled':
      return l10n.branchAccessActionDayCancelled;
    default:
      return action;
  }
}

String logSourceLabel(AppLocalizations l10n, String source) {
  switch (source) {
    case 'Branch Access Screen':
      return l10n.branchAccessSourceScreen;
    case 'Shift Assignment':
      return l10n.branchAccessSourceShift;
    case 'Day Off Cover':
      return l10n.branchAccessSourceCover;
    case 'Scheduler':
      return l10n.branchAccessSourceScheduler;
    default:
      return source;
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: c),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.labelSmall?.copyWith(color: c)),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(serverErrorText(context, error), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

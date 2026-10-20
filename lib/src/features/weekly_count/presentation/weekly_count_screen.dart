import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/weekly_count_models.dart';
import 'weekly_count_format.dart';
import 'weekly_count_providers.dart';
import 'widgets/weekly_count_sheet_view.dart';

/// `/weekly-count`: pick the branch (when there is more than one), then
/// either the blind count sheet or the card saying where this week's count
/// stands.
class WeeklyCountScreen extends ConsumerStatefulWidget {
  const WeeklyCountScreen({super.key});

  @override
  ConsumerState<WeeklyCountScreen> createState() => _WeeklyCountScreenState();
}

class _WeeklyCountScreenState extends ConsumerState<WeeklyCountScreen> {
  /// The branch the user picked; null = decide from the status.
  String? _picked;

  /// Shown the picker on purpose ("change branch"), even with one branch.
  bool _forcePicker = false;

  /// Rejected branches open on the rejection card; this flips to the sheet.
  final Set<String> _recounting = {};

  WeeklyCountSubmitResult? _done;

  @override
  void initState() {
    super.initState();
    // The screen is a decision point: always ask fresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(weeklyCountStatusProvider);
    });
  }

  String? _autoBranch(WeeklyCountStatus status) {
    final members = status.memberBranches;
    if (members.length == 1) return members.first.posProfile;
    if (members.isEmpty && status.branches.length == 1) {
      return status.branches.first.posProfile;
    }
    return null;
  }

  void _pick(String posProfile) {
    setState(() {
      _picked = posProfile;
      _forcePicker = false;
    });
  }

  void _onSubmitted(String posProfile, WeeklyCountSubmitResult result) {
    invalidateWeeklyCountState(ref, name: result.name);
    setState(() {
      _done = result;
      _recounting.remove(posProfile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusAsync = ref.watch(weeklyCountStatusProvider);
    final status = statusAsync.valueOrNull;

    final branchCount = status?.branches.length ?? 0;
    final selected = status == null || _forcePicker
        ? null
        : (_picked ?? _autoBranch(status));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.weeklyCountTitle),
        actions: [
          if (status?.isApprover == true)
            IconButton(
              tooltip: l10n.weeklyCountApprovalsTitle,
              icon: Badge(
                isLabelVisible: (status?.pendingApprovalCount ?? 0) > 0,
                label: Text('${status?.pendingApprovalCount ?? 0}'),
                child: const Icon(Icons.fact_check_outlined),
              ),
              onPressed: () => context.push(AppRoutes.weeklyCountApprovals),
            ),
          if (_done == null && selected != null && branchCount > 1)
            IconButton(
              tooltip: l10n.weeklyCountChangeBranch,
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => setState(() {
                _forcePicker = true;
                _picked = null;
              }),
            ),
        ],
      ),
      body: _buildBody(context, statusAsync, status, selected),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<WeeklyCountStatus> statusAsync,
    WeeklyCountStatus? status,
    String? selected,
  ) {
    final done = _done;
    if (done != null) {
      return _DoneView(result: done, onHome: () => context.go(AppRoutes.root));
    }
    if (status == null) {
      if (statusAsync.hasError) {
        return WeeklyCountErrorView(
          error: statusAsync.error!,
          onRetry: () => ref.invalidate(weeklyCountStatusProvider),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (status.branches.isEmpty) {
      return _Message(
        icon: Icons.storefront_outlined,
        text: context.l10n.weeklyCountNoBranches,
      );
    }
    if (selected == null) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(weeklyCountStatusProvider.future),
        child: _BranchPicker(status: status, onPick: _pick),
      );
    }
    final branch = status.branchNamed(selected);
    if (branch == null) {
      // The branch left the user's scope since it was picked.
      return _BranchPicker(status: status, onPick: _pick);
    }

    final showSheet =
        branch.state == WeeklyCountState.due ||
        branch.state == WeeklyCountState.unknown ||
        (branch.state == WeeklyCountState.rejected &&
            _recounting.contains(branch.posProfile));
    if (!showSheet) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(weeklyCountStatusProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WeekLine(status: status),
            const SizedBox(height: 12),
            _BranchStateCard(
              branchLabel: branch.posProfile,
              state: branch.state,
              count: branch.count,
              isApprover: status.isApprover,
              onRecount: () =>
                  setState(() => _recounting.add(branch.posProfile)),
            ),
          ],
        ),
      );
    }
    return _SheetLoader(
      posProfile: branch.posProfile,
      onSubmitted: (r) => _onSubmitted(branch.posProfile, r),
      onClosed: () {
        _recounting.remove(branch.posProfile);
        ref.invalidate(weeklyCountStatusProvider);
      },
    );
  }
}

class _SheetLoader extends ConsumerWidget {
  const _SheetLoader({
    required this.posProfile,
    required this.onSubmitted,
    required this.onClosed,
  });

  final String posProfile;
  final ValueChanged<WeeklyCountSubmitResult> onSubmitted;
  final VoidCallback onClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetAsync = ref.watch(weeklyCountSheetProvider(posProfile));
    final sheet = sheetAsync.valueOrNull;
    if (sheet == null) {
      if (sheetAsync.hasError) {
        return WeeklyCountErrorView(
          error: sheetAsync.error!,
          onRetry: () => ref.invalidate(weeklyCountSheetProvider(posProfile)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    // The sheet answers with the state too: a count that landed from another
    // device since the status was read shows its card, not a second sheet.
    if (sheet.state == WeeklyCountState.pendingApproval ||
        sheet.state == WeeklyCountState.done) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BranchStateCard(
            branchLabel: sheet.posProfile,
            state: sheet.state,
            count: sheet.count,
            isApprover: sheet.isApprover,
            onRecount: null,
          ),
        ],
      );
    }
    return WeeklyCountSheetView(
      sheet: sheet,
      branchLabel: sheet.posProfile.isEmpty ? posProfile : sheet.posProfile,
      onSubmitted: onSubmitted,
      onReloadSheet: () => ref.invalidate(weeklyCountSheetProvider(posProfile)),
      onClosed: () {
        ref.invalidate(weeklyCountSheetProvider(posProfile));
        onClosed();
      },
    );
  }
}

class _WeekLine extends StatelessWidget {
  const _WeekLine({required this.status});

  final WeeklyCountStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.weekStart.isEmpty) return const SizedBox.shrink();
    return Text(
      context.l10n.weeklyCountWeekRange(
        weeklyCountDayLabel(context, status.weekStart),
        weeklyCountDayLabel(context, status.dueDate),
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({required this.status, required this.onPick});

  final WeeklyCountStatus status;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final members = status.memberBranches;
    final others = status.branches.where((b) => !b.isMember).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WeekLine(status: status),
        const SizedBox(height: 8),
        Text(
          l10n.weeklyCountPickBranch,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final b in members)
          _BranchCard(branch: b, onTap: () => onPick(b.posProfile)),
        if (others.isNotEmpty) ...[
          if (members.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.weeklyCountOtherBranches,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
          ],
          for (final b in others)
            _BranchCard(branch: b, onTap: () => onPick(b.posProfile)),
        ],
      ],
    );
  }
}

(Color, Color, IconData, String) _stateLook(
  BuildContext context,
  WeeklyCountState state,
  bool urgent,
) {
  final l10n = context.l10n;
  switch (state) {
    case WeeklyCountState.pendingApproval:
      return (
        WeeklyCountColors.amber,
        WeeklyCountColors.amberBg,
        Icons.hourglass_top,
        l10n.weeklyCountStatePending,
      );
    case WeeklyCountState.done:
      return (
        WeeklyCountColors.green,
        WeeklyCountColors.greenBg,
        Icons.check_circle,
        l10n.weeklyCountStateDone,
      );
    case WeeklyCountState.rejected:
      return (
        WeeklyCountColors.red,
        WeeklyCountColors.redBg,
        Icons.replay,
        l10n.weeklyCountStateRejected,
      );
    case WeeklyCountState.due:
    case WeeklyCountState.unknown:
      return (
        urgent ? WeeklyCountColors.red : WeeklyCountColors.amber,
        urgent ? WeeklyCountColors.redBg : WeeklyCountColors.amberBg,
        Icons.inventory_2_outlined,
        l10n.weeklyCountStateDue,
      );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.onTap});

  final WeeklyCountBranch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon, label) = _stateLook(
      context,
      branch.state,
      branch.urgent,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: fg.withValues(alpha: 0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: bg,
                child: Icon(icon, color: fg, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.posProfile,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// pending / done / rejected for one branch.
class _BranchStateCard extends StatelessWidget {
  const _BranchStateCard({
    required this.branchLabel,
    required this.state,
    required this.count,
    required this.isApprover,
    required this.onRecount,
  });

  final String branchLabel;
  final WeeklyCountState state;
  final WeeklyCountRef? count;
  final bool isApprover;
  final VoidCallback? onRecount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (fg, bg, icon, label) = _stateLook(context, state, false);
    final ref = count;
    final who = ref?.counterLabel ?? '';
    final when = weeklyCountTimeLabel(context, ref?.countedAt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: fg, size: 64),
          const SizedBox(height: 12),
          Text(
            branchLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (who.isNotEmpty || when.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.weeklyCountCountedBy(who, when),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
          if (state == WeeklyCountState.done &&
              (ref?.approvedByName ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l10n.weeklyCountApprovedBy(ref!.approvedByName!),
              textAlign: TextAlign.center,
            ),
          ],
          if (state == WeeklyCountState.rejected &&
              (ref?.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.weeklyCountRejectionReason(ref!.rejectionReason!),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
          if (state == WeeklyCountState.rejected && onRecount != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: WeeklyCountColors.red,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onRecount,
                icon: const Icon(Icons.replay),
                label: Text(l10n.weeklyCountRecount),
              ),
            ),
          ],
          if (state == WeeklyCountState.pendingApproval &&
              isApprover &&
              (ref?.name ?? '').isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.weeklyCountDetailFor(ref!.name)),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l10n.weeklyCountReviewButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.result, required this.onHome});

  final WeeklyCountSubmitResult result;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final posted = result.posted;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 56,
              backgroundColor: WeeklyCountColors.greenBg,
              child: Icon(
                Icons.check_rounded,
                size: 80,
                color: WeeklyCountColors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.weeklyCountDoneTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              posted
                  ? l10n.weeklyCountDonePosted
                  : l10n.weeklyCountStatePending,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: posted
                    ? WeeklyCountColors.green
                    : WeeklyCountColors.amber,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_outlined),
                label: Text(
                  l10n.weeklyCountBackHome,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

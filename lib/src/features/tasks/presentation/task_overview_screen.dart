import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../models/task_models.dart';
import '../state/tasks_providers.dart';
import 'task_labels.dart';
import 'widgets/task_common_widgets.dart';

/// Per-person workload and delivery, for managers and full-access users.
class TaskOverviewScreen extends ConsumerStatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  ConsumerState<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends ConsumerState<TaskOverviewScreen> {
  static const _periods = [7, 30, 90];
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final boardContext = ref.watch(taskBoardContextProvider);
    final allowed = boardContext.valueOrNull?.canViewOverview;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => context.go(AppRoutes.tasks),
              ),
        title: Text(l10n.tasksOverviewTitle),
      ),
      body: boardContext.isLoading && allowed == null
          ? const Center(child: CircularProgressIndicator())
          : allowed == false
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.tasksNoAccess,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SegmentedButton<int>(
                    segments: [
                      for (final d in _periods)
                        ButtonSegment(
                          value: d,
                          label: Text(l10n.tasksOverviewDays(d)),
                        ),
                    ],
                    selected: {_days},
                    onSelectionChanged: (s) => setState(() => _days = s.first),
                  ),
                ),
                Expanded(child: _OverviewBody(days: _days)),
              ],
            ),
    );
  }
}

class _OverviewBody extends ConsumerWidget {
  final int days;
  const _OverviewBody({required this.days});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(taskOverviewProvider(days));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(taskOverviewProvider(days).future),
      child: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(taskErrorMessage(context, e), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(taskOverviewProvider(days)),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TotalTile(
                  label: l10n.tasksOverviewOpen,
                  value: data.totalOpen,
                  color: taskStatusColor(TaskStatus.inProgress),
                ),
                _TotalTile(
                  label: l10n.tasksOverviewInReview,
                  value: data.totalInReview,
                  color: taskStatusColor(TaskStatus.inReview),
                ),
                _TotalTile(
                  label: l10n.tasksOverviewOverdue,
                  value: data.totalOverdue,
                  color: taskOverdueColor,
                ),
                _TotalTile(
                  label: l10n.tasksOverviewDone,
                  value: data.totalDoneInPeriod,
                  color: taskStatusColor(TaskStatus.done),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data.people.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l10n.tasksOverviewNoData)),
              )
            else
              for (final person in data.people) _PersonCard(person: person),
          ],
        ),
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TotalTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final TaskOverviewPerson person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rate = person.onTimeRate;
    final rateText = rate == null ? '—' : '${(rate * 100).round()}%';
    final rateColor = rate == null
        ? null
        : rate >= 0.8
        ? taskStatusColor(TaskStatus.done)
        : rate >= 0.5
        ? taskStatusColor(TaskStatus.inReview)
        : taskOverdueColor;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TaskAvatar(name: person.displayName, radius: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    person.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (person.isManager)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(l10n.tasksOverviewManagerTag),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Stat(l10n.tasksOverviewOpen, '${person.open}'),
                _Stat(l10n.tasksOverviewInProgress, '${person.inProgress}'),
                _Stat(l10n.tasksOverviewInReview, '${person.inReview}'),
                _Stat(
                  l10n.tasksOverviewOverdue,
                  '${person.overdue}',
                  color: person.overdue > 0 ? taskOverdueColor : null,
                ),
                _Stat(l10n.tasksOverviewDone, '${person.doneInPeriod}'),
                _Stat(l10n.tasksOverviewOnTime, rateText, color: rateColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

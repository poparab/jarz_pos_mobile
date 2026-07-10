import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/b2b_repository.dart';
import '../../data/models/b2b_models.dart';
import '../../state/b2b_today_notifier.dart';

/// My follow-ups / Today: open todos + reorder-due cards for the B2B rep.
class B2bTodayScreen extends ConsumerWidget {
  const B2bTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followupsAsync = ref.watch(b2bTodayProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(b2bTodayProvider),
          ),
        ],
      ),
      body: followupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load follow-ups.\n$error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(b2bTodayProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (followups) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(b2bTodayProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(context, 'Follow-ups'),
              if (followups.todos.isEmpty)
                const _EmptyRow(label: 'No follow-ups today')
              else
                ...followups.todos.map((t) => _TodoTile(todo: t)),
              const SizedBox(height: 16),
              _header(context, 'Reorder due'),
              if (followups.reorderDue.isEmpty)
                const _EmptyRow(label: 'No reorders due')
              else
                ...followups.reorderDue.map((r) => _ReorderTile(item: r)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Whether [date] (ISO `yyyy-MM-dd`) is strictly before today.
bool isFollowupOverdue(String? date, {DateTime? now}) {
  if (date == null || date.trim().isEmpty) return false;
  final parsed = DateTime.tryParse(date.trim());
  if (parsed == null) return false;
  final today = now ?? DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final due = DateTime(parsed.year, parsed.month, parsed.day);
  return due.isBefore(startOfToday);
}

class _TodoTile extends ConsumerStatefulWidget {
  final FollowupItem todo;
  const _TodoTile({required this.todo});

  @override
  ConsumerState<_TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends ConsumerState<_TodoTile> {
  bool _busy = false;

  bool get _canReference =>
      widget.todo.referenceType != null &&
      widget.todo.referenceName != null &&
      (widget.todo.referenceType == 'Lead' ||
          widget.todo.referenceType == 'Opportunity');

  Future<void> _complete() async {
    final todo = widget.todo;
    if (todo.referenceType == null || todo.referenceName == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(b2bRepositoryProvider).completeFollowup(
            doctype: todo.referenceType!,
            name: todo.referenceName!,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Follow-up marked done')),
      );
      ref.invalidate(b2bTodayProvider);
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Could not complete follow-up: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final overdue = isFollowupOverdue(todo.date);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: overdue ? scheme.errorContainer : null,
      child: ListTile(
        leading: Icon(
          overdue ? Icons.warning_amber : Icons.event_note,
          color: overdue ? scheme.error : null,
        ),
        title: Text(todo.description ?? todo.name),
        subtitle: todo.date != null
            ? Text(overdue ? '${todo.date!} · overdue' : todo.date!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (todo.referenceType != null && todo.referenceName != null)
              _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Done'),
                      onPressed: _complete,
                    ),
            if (_canReference) const Icon(Icons.chevron_right),
          ],
        ),
        onTap: _canReference
            ? () => context.push(
                  AppRoutes.b2bAccount,
                  extra: <String, dynamic>{
                    'doctype': todo.referenceType,
                    'name': todo.referenceName,
                  },
                )
            : null,
      ),
    );
  }
}

class _ReorderTile extends StatelessWidget {
  final ReorderDueItem item;
  const _ReorderTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.lastOrderDate != null) 'Last: ${item.lastOrderDate}',
      if (item.predictedNextOrder != null) 'Next: ${item.predictedNextOrder}',
      if (item.avgBasketValue != null)
        'Avg: ${item.avgBasketValue!.toStringAsFixed(2)}',
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.replay),
        title: Text(item.customerName ?? item.name),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String label;
  const _EmptyRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

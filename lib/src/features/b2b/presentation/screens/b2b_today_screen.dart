import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
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

class _TodoTile extends StatelessWidget {
  final FollowupItem todo;
  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    final canOpen = todo.referenceType != null &&
        todo.referenceName != null &&
        (todo.referenceType == 'Lead' || todo.referenceType == 'Opportunity');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_note),
        title: Text(todo.description ?? todo.name),
        subtitle: todo.date != null ? Text(todo.date!) : null,
        trailing: canOpen ? const Icon(Icons.chevron_right) : null,
        onTap: canOpen
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/repositories/woo_sync_repository.dart';
import '../providers/woo_sync_console_provider.dart';
import '../widgets/woo_backlog_summary.dart';
import '../widgets/woo_breaker_banner.dart';
import '../widgets/woo_sync_dialogs.dart';
import '../widgets/woo_sync_event_tile.dart';
import '../widgets/woo_sync_filter_bar.dart';

/// The WooCommerce Sync operations console.
///
/// Native rebuild of the Desk page at `/app/woo-sync-operations`: a summary
/// (breaker + backlog) surfaced before any detail, a filterable event list
/// with per-row and bulk actions, and two system-wide actions gated behind
/// confirmation. Requires `canAccessWooSyncProvider` — everything else on
/// this screen assumes that gate already passed.
class WooSyncScreen extends ConsumerWidget {
  const WooSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canAccess = ref.watch(canAccessWooSyncProvider);

    if (!canAccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wooSyncMenuTitle)),
        drawer: const AppDrawer(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 12),
                Text(l10n.wooSyncNotPermittedTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(l10n.wooSyncNotPermittedBody, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final state = ref.watch(wooSyncConsoleProvider);
    final notifier = ref.read(wooSyncConsoleProvider.notifier);
    final selectedCount = state.selected.length;

    Future<void> handle(Future<void> Function() action, {String? successMessage}) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
        if (successMessage != null) {
          messenger.showSnackBar(SnackBar(content: Text(successMessage)));
        }
      } catch (e) {
        if (!context.mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(context.userErrorMessage(e.toString()))));
      }
    }

    Future<void> onRetry(String name) => handle(
          () => notifier.retrySingle(name),
          successMessage: l10n.wooSyncRetryQueued(name),
        );

    Future<void> onProcessNow(String name) => handle(
          () => notifier.processNow(name),
          successMessage: l10n.wooSyncProcessedNow(name),
        );

    Future<void> onSetReviewState(String name, {String? initialState}) async {
      final picked = await pickWooSyncReviewState(context, initialState: initialState);
      if (picked == null) return;
      await handle(
        () => notifier.setReviewStateSingle(name, picked.reviewState, notes: picked.notes),
        successMessage: l10n.wooSyncReviewStateSaved,
      );
    }

    Future<void> onPushInvoice(String invoiceName) => handle(
          () => notifier.pushInvoice(invoiceName),
          successMessage: l10n.wooSyncInvoicePushed(invoiceName),
        );

    Future<void> onBulkRetry() async {
      if (selectedCount > WooSyncRepository.bulkNameLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.wooSyncBulkLimitExceeded(WooSyncRepository.bulkNameLimit, selectedCount))),
        );
        return;
      }
      await handle(() async {
        final result = await notifier.retrySelected();
        final count = (result['count'] as num?)?.toInt() ?? selectedCount;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.wooSyncBulkRetryDone(count))));
        }
      });
    }

    Future<void> onBulkReviewState() async {
      if (selectedCount > WooSyncRepository.bulkNameLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.wooSyncBulkLimitExceeded(WooSyncRepository.bulkNameLimit, selectedCount))),
        );
        return;
      }
      final picked = await pickWooSyncReviewState(context);
      if (picked == null) return;
      await handle(() async {
        final result = await notifier.setReviewStateSelected(picked.reviewState, notes: picked.notes);
        final count = (result['count'] as num?)?.toInt() ?? selectedCount;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.wooSyncBulkReviewStateDone(count))));
        }
      });
    }

    Future<void> onRunWorker() async {
      final confirmed = await confirmWooSyncAction(
        context,
        title: l10n.wooSyncRunWorkerConfirmTitle,
        body: l10n.wooSyncRunWorkerConfirmBody,
      );
      if (!confirmed) return;
      await handle(
        () => notifier.runWorker(),
        successMessage: l10n.wooSyncWorkerRunDone,
      );
    }

    Future<void> onClearBreaker() async {
      final confirmed = await confirmWooSyncAction(
        context,
        title: l10n.wooSyncClearBreakerConfirmTitle,
        body: l10n.wooSyncClearBreakerConfirmBody,
      );
      if (!confirmed) return;
      await handle(() async {
        final result = await notifier.clearBreaker();
        final released = (result['released_rows'] as num?)?.toInt() ?? 0;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.wooSyncBreakerCleared(released))));
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wooSyncMenuTitle),
        actions: [
          IconButton(
            tooltip: l10n.wooSyncRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: state.dashboardLoading || state.eventsLoading ? null : () => notifier.refreshAll(),
          ),
          IconButton(
            tooltip: l10n.wooDuplicatesMenuTitle,
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: () => context.push(AppRoutes.wooDuplicates),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: notifier.refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (state.dashboard != null) ...[
              WooBreakerBanner(breaker: state.dashboard!.breaker),
              const SizedBox(height: 12),
              WooBacklogSummary(backlog: state.dashboard!.backlog),
              const SizedBox(height: 12),
            ] else if (state.dashboardLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.dashboardError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(context.userErrorMessage(state.dashboardError!), style: TextStyle(color: Colors.red.shade700)),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.consoleActionBusy ? null : onRunWorker,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.wooSyncRunWorker),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                    onPressed: state.consoleActionBusy ? null : onClearBreaker,
                    icon: const Icon(Icons.settings_backup_restore),
                    label: Text(l10n.wooSyncClearBreaker),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            WooSyncFilterBar(filters: state.filters, onChanged: notifier.setFilters),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(l10n.wooSyncEventCount(state.events.length)),
                const Spacer(),
                if (state.events.isNotEmpty)
                  TextButton(
                    onPressed: selectedCount == state.events.length ? notifier.clearSelection : notifier.selectAllVisible,
                    child: Text(selectedCount == state.events.length ? l10n.wooSyncClearSelection : l10n.wooSyncSelectAll),
                  ),
              ],
            ),
            if (selectedCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.wooSyncSelectedCount(selectedCount))),
                    if (state.bulkActionBusy)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    TextButton.icon(
                      onPressed: state.bulkActionBusy ? null : onBulkRetry,
                      icon: const Icon(Icons.replay, size: 16),
                      label: Text(l10n.wooSyncBulkRetry),
                    ),
                    TextButton.icon(
                      onPressed: state.bulkActionBusy ? null : onBulkReviewState,
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: Text(l10n.wooSyncBulkSetReviewState),
                    ),
                  ],
                ),
              ),
            if (state.eventsLoading && state.events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.eventsError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(context.userErrorMessage(state.eventsError!), style: TextStyle(color: Colors.red.shade700)),
              )
            else if (state.events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(l10n.wooSyncEventsEmpty)),
              )
            else
              for (final event in state.events)
                WooSyncEventTile(
                  event: event,
                  selected: state.selected.contains(event.name),
                  busy: state.busyEventNames.contains(event.name),
                  onSelectedChanged: (_) => notifier.toggleSelected(event.name),
                  onRetry: () => onRetry(event.name),
                  onProcessNow: () => onProcessNow(event.name),
                  onSetReviewState: () => onSetReviewState(event.name, initialState: event.reviewState),
                  onPushInvoice: event.hasLocalInvoice ? () => onPushInvoice(event.localDocname!) : null,
                ),
          ],
        ),
      ),
    );
  }
}

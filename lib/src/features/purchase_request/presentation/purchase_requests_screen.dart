import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../models/purchase_request_models.dart';
import '../state/purchase_request_notifier.dart';
import 'widgets/new_request_sheet.dart';
import 'widgets/request_card.dart';

/// The team-facing side of purchasing: what people have asked for, and where
/// each ask stands. Buyers act on this queue from the purchase screen's
/// "From requests" sheet, which rolls the same data up per item.
class PurchaseRequestsScreen extends ConsumerStatefulWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  ConsumerState<PurchaseRequestsScreen> createState() =>
      _PurchaseRequestsScreenState();
}

class _PurchaseRequestsScreenState
    extends ConsumerState<PurchaseRequestsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseRequestNotifierProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 200) {
      ref.read(purchaseRequestNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _reject(ItemRequest request) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.requestsRejectTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.requestsRejectReason),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.requestsReject),
          ),
        ],
      ),
    );
    final reason = controller.text;
    controller.dispose();

    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(purchaseRequestNotifierProvider.notifier)
        .stopRequest(request.name, reason: reason);
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.requestsRejected)));
    }
  }

  Future<void> _reopen(ItemRequest request) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(purchaseRequestNotifierProvider.notifier)
        .reopenRequest(request.name);
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.requestsReopened)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(purchaseRequestNotifierProvider);

    // Surface errors as a transient bar rather than replacing the list — a
    // failed reject should not wipe the queue the user is reading.
    ref.listen<PurchaseRequestState>(purchaseRequestNotifierProvider,
        (previous, next) {
      final error = next.error;
      if (error != null && error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonErrorWithDetails(error))),
        );
        ref.read(purchaseRequestNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestsTitle)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewRequestSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.requestsAddItems),
      ),
      body: Column(
        children: [
          _filterBar(context, state),
          Expanded(child: _body(context, state)),
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context, PurchaseRequestState state) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          for (final entry in <(RequestFilter, String)>[
            (RequestFilter.open, l10n.requestsFilterOpen),
            (RequestFilter.mine, l10n.requestsFilterMine),
            (RequestFilter.all, l10n.requestsFilterAll),
          ])
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(entry.$2),
                selected: state.filter == entry.$1,
                onSelected: (_) => ref
                    .read(purchaseRequestNotifierProvider.notifier)
                    .load(filter: entry.$1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, PurchaseRequestState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.requests.isEmpty) {
      final message = switch (state.filter) {
        RequestFilter.open => l10n.requestsEmptyOpen,
        RequestFilter.mine => l10n.requestsEmptyMine,
        RequestFilter.all => l10n.requestsEmptyAll,
      };
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(purchaseRequestNotifierProvider.notifier).load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Icon(Icons.inbox_outlined,
                size: 48, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Center(child: Text(message, style: theme.textTheme.titleSmall)),
            const SizedBox(height: 4),
            Center(
              child: Text(
                l10n.requestsEmptyHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(purchaseRequestNotifierProvider.notifier).load(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
        itemCount: state.requests.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.requests.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final request = state.requests[index];
          return RequestCard(
            key: ValueKey(request.name),
            request: request,
            canReview: state.canReview,
            onReject: () => _reject(request),
            onReopen: () => _reopen(request),
          );
        },
      ),
    );
  }
}

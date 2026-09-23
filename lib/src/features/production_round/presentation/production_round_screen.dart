import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../../../core/network/user_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/models/production_round.dart';
import '../state/production_round_providers.dart';
import 'widgets/production_round_branches_tab.dart';
import 'widgets/production_round_header.dart';
import 'widgets/production_round_make_tab.dart';
import 'widgets/production_round_materials_tab.dart';
import 'widgets/production_round_tune_sheet.dart';

/// What the factory should MAKE this round so every branch holds a full
/// delivery cycle plus its backup.
///
/// The sibling of Send to Branches: that screen moves what already exists,
/// this one says what has to exist first. Read only — the batches themselves
/// are still started from the Production screens.
class ProductionRoundScreen extends ConsumerWidget {
  const ProductionRoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final roles = ref.watch(userRolesFutureProvider);
    final allowed = roles.valueOrNull?.canAccessProductionBoard ?? false;
    final round = ref.watch(productionRoundProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productionRoundTitle),
        actions: [
          if (allowed) ...[
            IconButton(
              tooltip: l10n.productionRoundTune,
              icon: const Icon(Icons.tune),
              onPressed: () => showProductionRoundTuneSheet(
                context,
                currentCycleDays: round?.cycleDays ?? 0,
                currentBackupDays: round?.backupDays ?? 0,
                currentSalesWeeks: round?.salesWeeks ?? 0,
              ),
            ),
            IconButton(
              tooltip: l10n.productionRoundRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(productionRoundProvider),
            ),
          ],
        ],
      ),
      drawer: const AppDrawer(),
      body: roles.when(
        // Roles still in flight means "not yet", not "not permitted".
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Message(text: l10n.productionRoundNotAllowed),
        data: (data) => data.canAccessProductionBoard
            ? const _ProductionRoundBody()
            : _Message(text: l10n.productionRoundNotAllowed),
      ),
    );
  }
}

class _ProductionRoundBody extends ConsumerWidget {
  const _ProductionRoundBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final roundAsync = ref.watch(productionRoundProvider);
    final round = roundAsync.valueOrNull;

    if (round == null && roundAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (round == null) {
      return _Message(
        text: l10n.productionRoundLoadFailed,
        detail: context.userErrorMessage(roundAsync.error),
        onRetry: () => ref.invalidate(productionRoundProvider),
        retryLabel: l10n.commonRetry,
      );
    }

    Future<void> refresh() async {
      try {
        await ref.refresh(productionRoundProvider.future).then((_) {});
      } catch (_) {
        // The failure is rendered by the stale-data banner below; the
        // indicator only needs to stop spinning.
      }
    }

    return Column(
      children: [
        if (roundAsync.isLoading)
          const LinearProgressIndicator(minHeight: 2)
        else
          const SizedBox(height: 2),
        if (roundAsync.hasError && !roundAsync.isLoading)
          _StaleBanner(onRetry: () => ref.invalidate(productionRoundProvider)),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              // Tablets: the rows are short, and a 1000 dp line would put a
              // row's figures a hand width away from its name.
              constraints: const BoxConstraints(maxWidth: 760),
              child: _RoundView(round: round, onRefresh: refresh),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundView extends StatelessWidget {
  const _RoundView({required this.round, required this.onRefresh});

  final ProductionRound round;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: ProductionRoundHeader(round: round),
          ),
          TabBar(
            tabs: [
              Tab(text: l10n.productionRoundTabMake),
              Tab(text: l10n.productionRoundTabMaterials),
              Tab(text: l10n.productionRoundTabBranches),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ProductionRoundMakeTab(round: round, onRefresh: onRefresh),
                ProductionRoundMaterialsTab(round: round, onRefresh: onRefresh),
                ProductionRoundBranchesTab(round: round, onRefresh: onRefresh),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown over figures that are still on screen after a refresh failed, so
/// nobody plans a batch off numbers they believe are fresh.
class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.productionRoundRefreshFailed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    this.detail,
    this.onRetry,
    this.retryLabel,
  });

  final String text;
  final String? detail;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: onRetry, child: Text(retryLabel ?? '')),
            ],
          ],
        ),
      ),
    );
  }
}

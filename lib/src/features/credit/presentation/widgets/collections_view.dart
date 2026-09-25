import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/models/settlement_models.dart';
import '../../state/credit_providers.dart';
import '../settlement_labels.dart';
import 'settlement_terms_card.dart';

/// "Collections": the shops to chase, grouped overdue → due today → due soon
/// → not scheduled → on track, with what is due and when.
class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(collectionsDueProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(collectionsDueProvider);
        await ref.read(collectionsDueProvider.future);
      },
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              context.userErrorMessage(
                extractFrappeErrorMessage(
                  error,
                  fallback: l10n.collectionsLoadFailed,
                ),
                fallback: l10n.collectionsLoadFailed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(collectionsDueProvider),
                child: Text(l10n.commonRetry),
              ),
            ),
          ],
        ),
        data: (data) => _CollectionsBody(data: data),
      ),
    );
  }
}

class _CollectionsBody extends StatelessWidget {
  final CollectionsDue data;
  const _CollectionsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final groups = data.grouped;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(l10n.collectionsSubtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.collectionsEmpty(collectionsDaysAhead)),
            ),
          )
        else
          for (final group in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
              child: Row(
                children: [
                  SettlementStateChip(state: group.key),
                  const SizedBox(width: 8),
                  Text(
                    // The envelope's count when the server reports one for
                    // this bucket, else what was listed.
                    '${data.counts.countFor(group.key) > 0 ? data.counts.countFor(group.key) : group.value.length}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            for (final row in group.value)
              _CollectionTile(row: row, currency: data.currency),
          ],
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final CollectionDueRow row;
  final String currency;
  const _CollectionTile({required this.row, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    String money(double amount) =>
        formatCurrency(context, amount, currencyCode: currency);

    final schedule = row.cycle.isEmpty
        ? l10n.collectionsNoTerms
        : (row.description.isNotEmpty &&
                !l10n.localeName.startsWith('ar'))
            ? row.description
            : settlementCycleLabel(l10n, row.cycle);

    final facts = <String>[
      if (row.overdueAmount > 0.005)
        l10n.collectionsOverdueAmount(money(row.overdueAmount))
      else if (row.dueNowAmount > 0.005)
        l10n.collectionsDueNow(money(row.dueNowAmount)),
      if (row.nextDueDate.isNotEmpty && row.nextDueAmount > 0.005)
        l10n.collectionsNextDue(
          money(row.nextDueAmount),
          formatDateString(context, row.nextDueDate),
        ),
    ];

    final color = settlementStateColor(row.state);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        title: Text(
          row.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (facts.isNotEmpty)
              Text(
                facts.join(' • '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(row.openBalance),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        onTap: () => context.push(
          AppRoutes.creditAccountDetail,
          extra: {
            'customer': row.customer,
            'customer_name': row.displayName,
          },
        ),
      ),
    );
  }
}

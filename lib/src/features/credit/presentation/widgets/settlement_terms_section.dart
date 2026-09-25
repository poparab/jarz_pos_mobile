import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/credit_repository.dart';
import '../../data/models/settlement_models.dart';
import '../../state/credit_providers.dart';
import 'settlement_terms_card.dart';
import 'settlement_terms_sheet.dart';

/// The "Payment terms" card wired to its party-keyed provider and the edit
/// sheet. Shared by the credit account screen (a Customer) and the B2B
/// account screen (a Customer, or a Lead before its first order).
class SettlementTermsSection extends ConsumerWidget {
  final SettlementParty party;
  final String partyName;

  /// On the B2B screen terms are an extra: when the caller may not read them
  /// or the server predates them ([SettlementTermsUnavailable]) the section
  /// renders nothing. The credit screen keeps its retry tile instead.
  final bool hideWhenUnavailable;

  const SettlementTermsSection({
    super.key,
    required this.party,
    this.partyName = '',
    this.hideWhenUnavailable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(settlementTermsProvider(party));

    return async.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, _) {
        if (hideWhenUnavailable && error is SettlementTermsUnavailable) {
          return const SizedBox.shrink();
        }
        return Card(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.event_note_outlined),
            title: Text(l10n.settlementTermsLoadFailed),
            trailing: IconButton(
              tooltip: l10n.commonRetry,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(settlementTermsProvider(party)),
            ),
          ),
        );
      },
      data: (data) => SettlementTermsCard(
        data: data,
        onEdit: data.canEdit
            ? () async {
                final saved = await SettlementTermsSheet.show(
                  context,
                  party: party,
                  customerName: partyName.isNotEmpty
                      ? partyName
                      : data.customerName,
                  initial: data.terms,
                );
                if (saved == null || !context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settlementSaved)),
                );
              }
            : null,
      ),
    );
  }
}

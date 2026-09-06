import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../../../core/network/user_service.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../providers/woo_duplicate_review_provider.dart';
import '../widgets/woo_duplicate_candidate_card.dart';

/// Duplicate-customer triage — READ-ONLY.
///
/// Shows the duplicate-phone groups the dedupe autopilot refused to
/// auto-merge (`customer_dedupe.review_report`), each rendered as a decision
/// with its candidates side by side. There is deliberately no merge action:
/// merging is System-Manager-only and stays in Desk. This screen exists so a
/// human can look at the evidence and flag/queue what an administrator should
/// merge next, not to perform the merge itself.
class WooDuplicatesScreen extends ConsumerWidget {
  const WooDuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canAccess = ref.watch(canAccessWooSyncProvider);

    if (!canAccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wooDuplicatesMenuTitle)),
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

    final groupsAsync = ref.watch(wooDuplicateReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wooDuplicatesMenuTitle),
        actions: [
          IconButton(
            tooltip: l10n.wooSyncRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(wooDuplicateReviewProvider),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(wooDuplicateReviewProvider),
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(child: Text(context.userErrorMessage(e.toString()))),
            ],
          ),
          data: (groups) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Read-only banner: unmissable, states the purpose plainly, and
              // makes clear the merge itself is not on mobile.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border(left: BorderSide(color: Colors.amber.shade700, width: 6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility_outlined, color: Colors.amber.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.wooDuplicatesIntro),
                          const SizedBox(height: 4),
                          Text(
                            l10n.wooDuplicatesReadOnlyBanner,
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text(l10n.wooDuplicatesEmpty)),
                )
              else
                for (final group in groups)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 6),
                              Text(group.phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.wooDuplicatesGroupSize(group.size),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.wooDuplicatesGroupReason(group.reason),
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final candidate in group.candidates)
                                  WooDuplicateCandidateCard(candidate: candidate),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

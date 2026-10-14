import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../data/courier_setup_repository.dart';
import '../models/courier_setup_models.dart';
import '../state/courier_setup_providers.dart';
import 'widgets/courier_setup_form_dialog.dart';
import 'widgets/courier_setup_widgets.dart';
import 'widgets/user_admin_widgets.dart';

/// Couriers: every employee with whether their courier login actually works,
/// plus "Set up courier" and "Reset PIN".
///
/// Reached from the Users screen, which only shows the entry when the
/// onboarding endpoint answers (jarz_courier installed, caller allowed).
class CourierSetupScreen extends ConsumerStatefulWidget {
  const CourierSetupScreen({super.key});

  @override
  ConsumerState<CourierSetupScreen> createState() => _CourierSetupScreenState();
}

class _CourierSetupScreenState extends ConsumerState<CourierSetupScreen> {
  /// Employee ids with a PIN reset in flight, so a button cannot fire twice.
  final Set<String> _busy = <String>{};

  void _refresh() => ref.invalidate(courierCandidatesProvider);

  Future<void> _setUp({
    required CourierCandidates candidates,
    CourierCandidate? employee,
  }) async {
    final outcome = await CourierSetupFormDialog.show(
      context,
      candidates: candidates,
      initialEmployee: employee,
    );
    if (outcome == null || !mounted) return;
    // The list now reflects the new account while the card is still open.
    _refresh();
    final r = outcome.result;
    await CourierResultDialog.show(
      context,
      signInId: r.signInId,
      pin: r.pin,
      displayName: outcome.displayName ?? r.diagnosis.displayName,
      links: r.links,
      diagnosis: r.diagnosis,
      phone: outcome.phone,
    );
  }

  Future<void> _resetPin(CourierCandidate c) async {
    final l10n = context.l10n;
    final user = c.user;
    if (user == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.courierSetupResetTitle),
        content: Text(l10n.courierSetupResetBody(c.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.courierSetupResetPin),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy.add(c.employee));
    try {
      final reset = await ref.read(courierSetupRepositoryProvider).resetPin(user);
      if (!mounted) return;
      await CourierResultDialog.show(
        context,
        signInId: reset.signInId,
        pin: reset.pin,
        displayName: c.displayName,
        isReset: true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(userAdminErrorText(context, e))));
    } finally {
      if (mounted) setState(() => _busy.remove(c.employee));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(courierCandidatesProvider);
    final candidates = async.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.courierSetupTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRetry,
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: candidates == null
          ? null
          : FloatingActionButton.extended(
              heroTag: 'courier-setup-add',
              onPressed: () => _setUp(candidates: candidates),
              icon: const Icon(Icons.two_wheeler),
              label: Text(l10n.courierSetupAction),
            ),
      body: async.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            UserAdminErrorPanel(error: e, onRetry: _refresh),
        data: (data) => _CandidatesList(
          candidates: data,
          busy: _busy,
          onSetUp: (c) => _setUp(candidates: data, employee: c),
          onResetPin: _resetPin,
        ),
      ),
    );
  }
}

class _CandidatesList extends ConsumerWidget {
  const _CandidatesList({
    required this.candidates,
    required this.busy,
    required this.onSetUp,
    required this.onResetPin,
  });

  final CourierCandidates candidates;
  final Set<String> busy;
  final void Function(CourierCandidate) onSetUp;
  final void Function(CourierCandidate) onResetPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(courierCandidatesSearchProvider);
    final rows = candidates.employees.where((c) => c.matches(query)).toList()
      // Couriers first, then anything broken, then the rest by name.
      ..sort((a, b) {
        int rank(CourierCandidate c) => c.isCourier ? 0 : 1;
        final byRank = rank(a).compareTo(rank(b));
        if (byRank != 0) return byRank;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });

    return RefreshIndicator(
      onRefresh: () => ref.refresh(courierCandidatesProvider.future),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.courierSetupSearchHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      ref.read(courierCandidatesSearchProvider.notifier).state =
                          v,
                ),
              ),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Text(
                      l10n.courierSetupEmpty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              for (final c in rows)
                _CandidateCard(
                  key: ValueKey(c.employee),
                  candidate: c,
                  busy: busy.contains(c.employee),
                  onSetUp: () => onSetUp(c),
                  onResetPin: () => onResetPin(c),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    super.key,
    required this.candidate,
    required this.busy,
    required this.onSetUp,
    required this.onResetPin,
  });

  final CourierCandidate candidate;
  final bool busy;
  final VoidCallback onSetUp;
  final VoidCallback onResetPin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = candidate;
    final subtitle = [
      if (c.branch != null) c.branch!,
      if (c.user != null) c.user!,
    ].join(' · ');

    final Widget status;
    if (c.isCourier && c.setupOk) {
      status = UserAdminTag(
        text: l10n.courierSetupStatusReady,
        color: Colors.green.shade700,
        icon: Icons.check_circle_outline,
      );
    } else if (c.isCourier) {
      status = UserAdminTag(
        text: l10n.courierSetupStatusNeedsFix,
        color: theme.colorScheme.error,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      status = UserAdminTag(
        text: l10n.courierSetupStatusNotCourier,
        color: theme.colorScheme.outline,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                status,
              ],
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (c.problems.isNotEmpty) ...[
              const SizedBox(height: 8),
              CourierProblemList(problems: c.problems),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (!c.isCourier || !c.setupOk)
                  FilledButton.tonalIcon(
                    onPressed: busy ? null : onSetUp,
                    icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                    label: Text(
                      c.isCourier
                          ? l10n.courierSetupFix
                          : l10n.courierSetupSetUp,
                    ),
                  ),
                if (c.hasUser && c.isCourier)
                  OutlinedButton.icon(
                    onPressed: busy ? null : onResetPin,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.password, size: 18),
                    label: Text(l10n.courierSetupResetPin),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

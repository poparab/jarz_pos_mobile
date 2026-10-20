import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../data/stock_handover_models.dart';
import '../data/stock_transfer_service.dart';
import '../state/match_plan.dart';
import '../state/stock_handover_providers.dart';
import 'widgets/handover_format.dart';
import 'widgets/handover_qty_input.dart';

/// The manager's match screen for one "sent out" batch: for every item, what
/// left the source and where each unit went. Confirm unlocks only when every
/// item adds up; the review sheet then shows just the nonzero splits.
///
/// Pops `true` when the batch was confirmed or rejected, so the caller
/// refreshes its list.
class StockHandoverMatchScreen extends ConsumerStatefulWidget {
  const StockHandoverMatchScreen({
    super.key,
    required this.group,
    required this.destinations,
    this.posProfile,
  });

  final MatchGroup group;

  /// Every warehouse the manager may add as a destination (from
  /// `get_context.counterparts`). The source itself is filtered out here.
  final List<HandoverSide> destinations;
  final String? posProfile;

  @override
  ConsumerState<StockHandoverMatchScreen> createState() =>
      _StockHandoverMatchScreenState();
}

class _StockHandoverMatchScreenState
    extends ConsumerState<StockHandoverMatchScreen> {
  late final MatchPlan _plan = MatchPlan.fromGroup(widget.group);
  bool _submitting = false;

  List<HandoverSide> get _candidates => [
        for (final d in widget.destinations)
          if (d.warehouse != widget.group.sourceWarehouse) d,
      ];

  Future<void> _addBranch(int index) async {
    final l10n = context.l10n;
    final plan = _plan.items[index];
    final options = [
      for (final c in _candidates)
        if (!plan.hasSplitFor(c.warehouse)) c,
    ];
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.stockHandoverMatchNoBranches)),
      );
      return;
    }
    final picked = await showModalBottomSheet<HandoverSide>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    l10n.stockHandoverMatchPickBranch,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: [
                      for (final option in options)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: ListTile(
                            minTileHeight: 56,
                            leading: Icon(
                              option.isFactory
                                  ? Icons.factory_outlined
                                  : Icons.storefront_outlined,
                            ),
                            title: Text(option.label),
                            onTap: () => Navigator.of(sheetCtx).pop(option),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _plan.addDestination(index, picked.warehouse, picked.label));
  }

  Future<void> _confirm() async {
    if (_submitting || !_plan.canConfirm) return;
    final note = await showModalBottomSheet<_ReviewResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _MatchReviewSheet(plan: _plan),
    );
    // The sheet was open for a while: a second tap may have started a submit.
    if (note == null || !mounted || _submitting) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);
    try {
      final outcome = await ref.read(stockTransferServiceProvider).confirmMatch(
            sourceWarehouse: widget.group.sourceWarehouse,
            members: widget.group.members,
            lines: _plan.toLines(),
            note: note.note,
          );
      ref.invalidate(stockHandoverListsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.stockHandoverMatchConfirmedSnack(
              handoverLtr(outcome.stockEntry ?? '-'),
            ),
          ),
        ),
      );
      if (mounted) navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      // userErrorMessage extracts the server's sentence out of the
      // DioException (a plain toString() never contains it).
      final message = context.userErrorMessage(e);
      messenger.showSnackBar(SnackBar(content: Text(message)));
      // The batch changed under the manager: what is on screen is stale, so
      // go back to the refreshed list instead of retrying on old numbers.
      if (message.contains('Something changed in this batch')) {
        ref.invalidate(stockHandoverListsProvider);
        navigator.pop(true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _rejectBatch() async {
    // The server refuses a reject from a manager who declared a member.
    if (_submitting || !widget.group.canConfirm) return;
    final l10n = context.l10n;
    final source = widget.group.sourceLabel;
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stockHandoverMatchRejectTitle(source)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.stockHandoverMatchRejectBody(source)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: l10n.stockHandoverRejectReasonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.stockHandoverReject),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text;
    // The dialog's TextField is still mounted during the exit animation, so
    // dispose only once the route transition is surely over.
    Future<void>.delayed(const Duration(seconds: 1), reasonCtrl.dispose);
    if (ok != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = ref.read(stockTransferServiceProvider);
    setState(() => _submitting = true);
    try {
      for (final name in widget.group.dispatches) {
        await service.respondToHandover(
          name: name,
          action: 'reject',
          reason: reason,
          posProfile: widget.posProfile,
        );
      }
      ref.invalidate(stockHandoverListsProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.stockHandoverMatchRejectedSnack)),
      );
      if (mounted) navigator.pop(true);
    } catch (e) {
      // Some dispatches may already be rejected, so what is on screen is
      // stale: refresh and go back to the list rather than stay on old data.
      ref.invalidate(stockHandoverListsProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
      navigator.pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final group = widget.group;
    final canConfirm = _plan.canConfirm && !_submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockHandoverMatchTitle(group.sourceLabel)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                if (!group.canConfirm)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline,
                              color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.stockHandoverMatchCannotConfirm,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (var i = 0; i < _plan.items.length; i++)
                  _ItemBlock(
                    key: ValueKey(_plan.items[i].item.itemCode),
                    plan: _plan.items[i],
                    enabled: group.canConfirm && !_submitting,
                    onChanged: () => setState(() {}),
                    onAddBranch: () => _addBranch(i),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: (_submitting || !group.canConfirm) ? null : _rejectBatch,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    icon: const Icon(Icons.block),
                    label: Text(l10n.stockHandoverMatchRejectBatch),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: canConfirm ? _confirm : null,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(l10n.stockHandoverMatchConfirm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One item: the sent quantity, a row per destination, and the live
/// "remaining" (green at zero, red otherwise).
class _ItemBlock extends StatelessWidget {
  const _ItemBlock({
    super.key,
    required this.plan,
    required this.enabled,
    required this.onChanged,
    required this.onAddBranch,
  });

  final MatchItemPlan plan;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback onAddBranch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final remaining = plan.remaining;
    final ok = plan.balanced;
    final color = ok ? Colors.green.shade700 : theme.colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.item.itemName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _QtyRow(
              label: l10n.stockHandoverMatchSent,
              value: plan.sent,
              bold: true,
              enabled: enabled,
              changedFrom: plan.sentChanged ? plan.originalSent : null,
              onChanged: (v) {
                plan.sent = v;
                onChanged();
              },
            ),
            const Divider(height: 16),
            for (final s in plan.splits)
              _QtyRow(
                key: ValueKey('${plan.item.itemCode}|${s.warehouse}'),
                label: s.label,
                value: s.qty,
                enabled: enabled,
                changedFrom: s.changed && s.claimed > 0 ? s.claimed : null,
                onChanged: (v) {
                  s.qty = v;
                  onChanged();
                },
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton.icon(
                  onPressed: enabled ? onAddBranch : null,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.stockHandoverMatchAddBranch),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.stockHandoverMatchRemaining(handoverQty(remaining)),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  const _QtyRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
    this.bold = false,
    this.changedFrom,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final bool bold;

  /// The number this replaced (a claim or the declared "sent"), shown small
  /// under the label so the manager sees what they changed.
  final double? changedFrom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: bold
                      ? theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)
                      : theme.textTheme.bodyLarge,
                ),
                if (changedFrom != null)
                  Text(
                    l10n.stockHandoverMatchWas(handoverQty(changedFrom!)),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.tertiary),
                  ),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: HandoverQtyField(
                value: value,
                bold: bold,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewResult {
  const _ReviewResult(this.note);
  final String? note;
}

/// "Review before confirming": only the nonzero splits, with what the manager
/// changed highlighted. Pops a [_ReviewResult] on confirm, null on dismiss.
class _MatchReviewSheet extends StatefulWidget {
  const _MatchReviewSheet({required this.plan});

  final MatchPlan plan;

  @override
  State<_MatchReviewSheet> createState() => _MatchReviewSheetState();
}

class _MatchReviewSheetState extends State<_MatchReviewSheet> {
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final plan = widget.plan;
    final lines = plan.reviewLines();
    final dropped = plan.droppedClaims();
    final sentChanges = plan.sentChanges;

    Widget row(MatchReviewLine line, {bool zero = false}) {
      final changed = line.changed;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stockHandoverRoute(line.fromLabel, line.toLabel),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  Text(line.itemName, style: theme.textTheme.titleSmall),
                  if (changed && line.claimed > 0)
                    Text(
                      l10n.stockHandoverMatchWas(handoverQty(line.claimed)),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.tertiary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              handoverQty(line.qty),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: zero
                    ? theme.colorScheme.error
                    : (changed ? theme.colorScheme.tertiary : null),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  l10n.stockHandoverMatchReviewTitle,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  children: [
                    for (final c in sentChanges)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          l10n.stockHandoverMatchSentChange(
                            c.item.itemName,
                            handoverQty(c.originalSent),
                            handoverQty(c.sent),
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    for (final line in lines) row(line),
                    for (final line in dropped) row(line, zero: true),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _note,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: l10n.stockHandoverMatchNoteHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.stockHandoverKeepEditing),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () => Navigator.of(context)
                            .pop(_ReviewResult(_note.text)),
                        icon: const Icon(Icons.check),
                        label: Text(l10n.stockHandoverMatchConfirm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

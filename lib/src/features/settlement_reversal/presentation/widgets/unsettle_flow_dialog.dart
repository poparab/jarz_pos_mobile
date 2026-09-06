// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/localized_formatters.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/models/unsettle_preview.dart';
import '../providers/unsettle_flow_notifier.dart';

/// Preview -> confirm -> result for reversing one courier settlement.
///
/// Deliberately the mirror image of `showSettlementConfirmDialog`
/// (`kanban/widgets/settlement_preview_dialog.dart`): that dialog explains
/// what a settlement is about to do, this one explains what undoing one will
/// do. Returns `true` once a reversal actually committed, so the caller can
/// refresh whatever list is showing the reversed settlement.
Future<bool> showUnsettleFlowDialog(
  BuildContext context,
  String journalEntry,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UnsettleFlowDialog(journalEntry: journalEntry),
  );
  return result ?? false;
}

class _UnsettleFlowDialog extends ConsumerStatefulWidget {
  final String journalEntry;
  const _UnsettleFlowDialog({required this.journalEntry});

  @override
  ConsumerState<_UnsettleFlowDialog> createState() => _UnsettleFlowDialogState();
}

class _UnsettleFlowDialogState extends ConsumerState<_UnsettleFlowDialog> {
  final _reasonController = TextEditingController();
  bool _acknowledged = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(unsettleFlowNotifierProvider(widget.journalEntry));

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.undo, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.unsettleDialogTitle)),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: _content(context, state)),
      ),
      actions: _actions(context, state),
    );
  }

  Widget _content(BuildContext context, UnsettleState state) {
    final l10n = context.l10n;
    switch (state.step) {
      case UnsettleStep.loadingPreview:
        return _loadingBody(l10n.unsettlePreviewLoading);
      case UnsettleStep.previewError:
        return _errorBody(context, l10n.unsettlePreviewErrorTitle, state.error);
      case UnsettleStep.previewReady:
        return _previewBody(context, state.preview!);
      case UnsettleStep.committing:
        return _loadingBody(l10n.unsettleCommitting);
      case UnsettleStep.commitError:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.preview != null) _previewBody(context, state.preview!),
            const SizedBox(height: 12),
            _errorBody(context, l10n.unsettleCommitErrorTitle, state.error),
          ],
        );
      case UnsettleStep.success:
        return _successBody(context, state.result);
    }
  }

  Widget _loadingBody(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _errorBody(BuildContext context, String title, Object? error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(context.userErrorMessage(error?.toString() ?? title)),
        ],
      ),
    );
  }

  Widget _previewBody(BuildContext context, UnsettlePreview preview) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.unsettleOriginalEntryLabel(preview.journalEntry),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if ((preview.partyLabel ?? preview.party) != null && (preview.partyLabel ?? preview.party)!.isNotEmpty)
                Text(l10n.unsettlePartyLabel((preview.partyLabel ?? preview.party)!)),
              if (preview.branch != null && preview.branch!.isNotEmpty)
                Text(l10n.unsettleBranchLabel(preview.branch!)),
              if (preview.postingDate != null && preview.postingDate!.isNotEmpty)
                Text(l10n.unsettlePostingDateLabel(preview.postingDate!)),
              if (preview.netAmount != null)
                Text(l10n.unsettleNetAmountLabel(formatCurrency(context, preview.netAmount!))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.indigo),
              const SizedBox(width: 6),
              Expanded(
                child: Text(l10n.unsettleAuditTrailNotice, style: const TextStyle(fontSize: 12, color: Colors.indigo)),
              ),
            ],
          ),
        ),
        if (preview.transactions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.unsettleWillReopenSectionTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...preview.transactions.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 14, color: Colors.teal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.amount != null
                            ? '${t.invoice} — ${l10n.unsettleTransactionLineSubtitle(t.city ?? '-', formatCurrency(context, t.amount!))}'
                            : t.invoice,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        if (preview.accountLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.unsettleAccountLinesSectionTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...preview.accountLines.map((line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 14, color: Colors.deepOrange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${line.account} — ${l10n.unsettleAccountLineSubtitle(formatCurrency(context, line.debit), formatCurrency(context, line.credit))}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        if (preview.transactions.isEmpty && preview.accountLines.isEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.unsettleNoBreakdownAvailable, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
        const SizedBox(height: 14),
        TextField(
          controller: _reasonController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: l10n.unsettleReasonFieldLabel,
            hintText: l10n.unsettleReasonFieldHint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => _acknowledged = !_acknowledged),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acknowledged,
                onChanged: (v) => setState(() => _acknowledged = v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(l10n.unsettleAckCheckboxLabel, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _successBody(BuildContext context, Map<String, dynamic>? result) {
    final l10n = context.l10n;
    final newJe = (result?['journal_entry'] ?? result?['reversal_journal_entry'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.unsettleSuccessTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(newJe.isNotEmpty
              ? l10n.unsettleSuccessBody(newJe)
              : l10n.unsettleSuccessBody(widget.journalEntry)),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context, UnsettleState state) {
    final l10n = context.l10n;
    switch (state.step) {
      case UnsettleStep.loadingPreview:
      case UnsettleStep.committing:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
        ];
      case UnsettleStep.previewError:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => ref
                .read(unsettleFlowNotifierProvider(widget.journalEntry).notifier)
                .refreshPreview(),
            child: Text(l10n.commonRetry),
          ),
        ];
      case UnsettleStep.previewReady:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            // Requires the explicit acknowledgement checkbox: this reverses
            // real money movement and must not be one accidental tap away.
            onPressed: _acknowledged
                ? () async {
                    final ok = await ref
                        .read(unsettleFlowNotifierProvider(widget.journalEntry).notifier)
                        .confirm(reason: _reasonController.text);
                    if (!ok) return; // stays open to show the commit error / refreshed preview
                  }
                : null,
            child: Text(l10n.unsettleConfirmButton),
          ),
        ];
      case UnsettleStep.commitError:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            // A stale/mismatched preview token is the most common cause here
            // (the 3-minute window lapsed) — re-preview rather than dead-end.
            onPressed: () => ref
                .read(unsettleFlowNotifierProvider(widget.journalEntry).notifier)
                .refreshPreview(),
            child: Text(l10n.unsettleRefreshAndRetry),
          ),
        ];
      case UnsettleStep.success:
        return [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDone),
          ),
        ];
    }
  }
}

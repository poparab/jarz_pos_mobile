import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../data/stock_handover_models.dart';
import '../data/stock_transfer_service.dart';
import '../state/handover_badge.dart';
import '../state/stock_handover_providers.dart';
import '../state/transit_allocation.dart';
import 'widgets/handover_format.dart';
import 'widgets/handover_qty_input.dart';

/// The manager's Transit board: receipts waiting to be matched with what was
/// sent out (prefilled from the engine's suggestions, so a confident one is a
/// single tap), and the sends still in transit (return or write off).
class StockTransitScreen extends ConsumerStatefulWidget {
  const StockTransitScreen({super.key, this.posProfile});

  final String? posProfile;

  @override
  ConsumerState<StockTransitScreen> createState() => _StockTransitScreenState();
}

class _StockTransitScreenState extends ConsumerState<StockTransitScreen> {
  /// The manager's working copies, rebuilt whenever the board's version moves.
  final Map<String, ReceiptAllocation> _allocs = {};
  String? _allocVersion;

  /// Receipts / sends with a request in flight.
  final Set<String> _busy = {};
  bool _batchRunning = false;

  StockTransferService get _service => ref.read(stockTransferServiceProvider);

  void _syncAllocations(TransitBoard board) {
    if (_allocVersion == board.version &&
        _allocs.length == board.receipts.length &&
        board.receipts.every((r) => _allocs.containsKey(r.name))) {
      return;
    }
    _allocs
      ..clear()
      ..addEntries(board.receipts.map(
        (r) => MapEntry(r.name, ReceiptAllocation.fromBoard(board, r)),
      ));
    _allocVersion = board.version;
  }

  Future<void> _reload() async {
    ref.invalidate(transitBoardProvider(widget.posProfile));
    ref.invalidate(stockHandoverListsProvider);
    try {
      await ref.read(transitBoardProvider(widget.posProfile).future);
    } catch (_) {
      // The board shows its own error.
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Shows a refusal; on drift, reloads the board instead of leaving stale
  /// numbers on screen.
  void _handleError(Object e) {
    if (!mounted) return;
    final message = context.userErrorMessage(e);
    if (isTransitDrift(message)) {
      _snack(context.l10n.stockTransitDriftSnack);
      _reload();
    } else {
      _snack(message);
    }
  }

  // ── Receipts ─────────────────────────────────────────────────────────────

  Future<void> _approve(ReceiptAllocation a) async {
    final l10n = context.l10n;
    final name = a.receipt.name;
    setState(() => _busy.add(name));
    try {
      final out = await _service.approveReceipt(
        receipt: name,
        allocations: a.allocationsPayload(),
        received: a.receivedPayload(),
        version: a.version,
        posProfile: widget.posProfile,
      );
      _snack(l10n.stockTransitApprovedSnack(
        a.receipt.targetLabel,
        handoverLtr(out.stockEntry ?? '-'),
      ));
      await _reload();
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _busy.remove(name));
    }
  }

  Future<void> _reject(TransitReceipt r) async {
    final l10n = context.l10n;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(
        title: l10n.stockTransitRejectTitle(r.targetLabel),
        body: l10n.stockTransitRejectBody,
        action: l10n.stockHandoverReject,
        destructive: true,
      ),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy.add(r.name));
    try {
      await _service.rejectReceipt(
        receipt: r.name,
        reason: reason,
        posProfile: widget.posProfile,
      );
      _snack(l10n.stockTransitRejectedSnack);
      await _reload();
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _busy.remove(r.name));
    }
  }

  Future<void> _editLine(
    TransitBoard board,
    ReceiptAllocation a,
    LineAllocation line,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AllocationSheet(
        board: board,
        line: line,
        onChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
    if (mounted) setState(() {});
  }

  /// One signature per allocation, so a receipt is approved in a batch only
  /// if the fresh board still suggests exactly what the manager reviewed.
  static String _signature(ReceiptAllocation a) {
    final rows = [
      for (final r in a.allocationsPayload())
        '${r['item_code']}|${r['dispatch'] ?? ''}|${r['source_warehouse']}|'
            '${round3((r['qty'] as num).toDouble())}',
    ]..sort();
    return rows.join(';');
  }

  Future<void> _approveConfident(TransitBoard board) async {
    final l10n = context.l10n;
    final list = confidentReceipts(board);
    if (list.isEmpty) {
      _snack(l10n.stockTransitApproveConfidentNone);
      return;
    }
    final go = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ConfidentReviewSheet(receipts: list),
    );
    if (go != true || !mounted) return;

    setState(() => _batchRunning = true);
    var ok = 0;
    var failed = 0;
    final changed = <String>[];
    for (final reviewed in list) {
      final name = reviewed.receipt.name;
      try {
        // Every approval moves the board's version, so each one is checked
        // against a fresh board and sent with that board's version.
        final fresh =
            await _service.getTransitBoard(posProfile: widget.posProfile);
        final r = fresh.receipts.where((x) => x.name == name).firstOrNull;
        final now = r == null ? null : ReceiptAllocation.fromBoard(fresh, r);
        if (now == null ||
            !now.isConfident ||
            _signature(now) != _signature(reviewed)) {
          failed++;
          changed.add(reviewed.receipt.targetLabel);
          continue;
        }
        await _service.approveReceipt(
          receipt: name,
          allocations: now.allocationsPayload(),
          received: now.receivedPayload(),
          version: now.version,
          posProfile: widget.posProfile,
        );
        ok++;
      } catch (_) {
        failed++;
      }
    }
    if (!mounted) return;
    setState(() => _batchRunning = false);
    final done = l10n.stockTransitApproveConfidentDone(ok, failed);
    _snack(changed.isEmpty
        ? done
        : '$done\n${l10n.stockTransitApproveConfidentChanged(changed.join('، '))}');
    await _reload();
  }

  // ── Sends ────────────────────────────────────────────────────────────────

  Future<void> _sendAction(TransitSend send, {required bool writeOff}) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<_SendActionResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SendActionSheet(send: send, writeOff: writeOff),
    );
    if (result == null || !mounted) return;
    if (writeOff) {
      final total = handoverQty(result.total);
      final sure = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: Text(l10n.stockTransitWriteOffConfirmTitle(total)),
          content: Text(l10n.stockTransitWriteOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dCtx).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dCtx).pop(true),
              child: Text(l10n.stockTransitWriteOffConfirm(total)),
            ),
          ],
        ),
      );
      if (sure != true || !mounted) return;
    }
    setState(() => _busy.add(send.name));
    try {
      if (writeOff) {
        await _service.writeOffTransit(
          dispatch: send.name,
          lines: result.lines,
          reason: result.reason,
          posProfile: widget.posProfile,
        );
        _snack(l10n.stockTransitWrittenOffSnack);
      } else {
        await _service.returnToSender(
          dispatch: send.name,
          lines: result.lines,
          reason: result.reason.isEmpty ? null : result.reason,
          posProfile: widget.posProfile,
        );
        _snack(l10n.stockTransitReturnedSnack(send.sourceLabel));
      }
      await _reload();
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _busy.remove(send.name));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final boardAsync = ref.watch(transitBoardProvider(widget.posProfile));
    final board = boardAsync.valueOrNull;
    if (board != null) _syncAllocations(board);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockTransitTitle),
        actions: [
          if (board != null && board.receipts.isNotEmpty)
            IconButton(
              tooltip: l10n.stockTransitApproveConfident,
              icon: const Icon(Icons.done_all),
              onPressed: _batchRunning ? null : () => _approveConfident(board),
            ),
        ],
        bottom: (_batchRunning || (boardAsync.isLoading && board != null))
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: board == null
          ? boardAsync.hasError
              ? _ErrorView(
                  text: l10n.stockHandoverLoadFailed(
                    context.userErrorMessage(boardAsync.error),
                  ),
                  onRetry: _reload,
                )
              : const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                    children: _content(board),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _content(TransitBoard board) {
    final l10n = context.l10n;
    final confident = _allocs.values.where((a) => a.isConfident).length;
    final out = <Widget>[
      _SummaryStrip(summary: board.summary),
      const SizedBox(height: 8),
      _Header(
        icon: Icons.fact_check_outlined,
        text: l10n.stockTransitSectionToApprove(board.receipts.length),
        emphasised: board.receipts.isNotEmpty,
        trailing: confident > 0
            ? FilledButton.tonalIcon(
                onPressed:
                    _batchRunning ? null : () => _approveConfident(board),
                icon: const Icon(Icons.done_all, size: 18),
                label: Text(l10n.stockTransitApproveConfidentButton(confident)),
              )
            : null,
      ),
    ];
    if (board.receipts.isEmpty) {
      out.add(_Muted(l10n.stockTransitNothingToApprove));
    }
    for (final r in board.receipts) {
      final a = _allocs[r.name];
      if (a == null) continue;
      out.add(_ReceiptCard(
        alloc: a,
        busy: _busy.contains(r.name) || _batchRunning,
        onLineTap: (line) => _editLine(board, a, line),
        onApprove: () => _approve(a),
        onReject: () => _reject(r),
      ));
    }

    out.add(const SizedBox(height: 8));
    out.add(_Header(
      icon: Icons.local_shipping_outlined,
      text: l10n.stockTransitSectionInTransit(board.sends.length),
    ));
    if (board.sends.isEmpty) {
      out.add(_Muted(l10n.stockTransitNothingInTransit));
    }
    for (final s in board.sends) {
      out.add(_SendCard(
        send: s,
        busy: _busy.contains(s.name) || _batchRunning,
        onReturn: () => _sendAction(s, writeOff: false),
        onWriteOff: () => _sendAction(s, writeOff: true),
      ));
    }
    return out;
  }
}

// ── Shared bits ─────────────────────────────────────────────────────────────

Color _confidenceColor(BuildContext context, TransitConfidence c) =>
    switch (c) {
      TransitConfidence.high => Colors.green.shade700,
      TransitConfidence.medium => Colors.amber.shade800,
      TransitConfidence.low => Theme.of(context).colorScheme.error,
      TransitConfidence.none => Theme.of(context).colorScheme.outline,
    };

String _confidenceLabel(AppLocalizations l10n, TransitConfidence c) =>
    switch (c) {
      TransitConfidence.high => l10n.stockTransitConfidenceHigh,
      TransitConfidence.medium => l10n.stockTransitConfidenceMedium,
      TransitConfidence.low => l10n.stockTransitConfidenceLow,
      TransitConfidence.none => '',
    };

/// One reason in the manager's language; empty for a code this build does
/// not know (a newer server), which is simply not shown.
String transitReasonText(
  AppLocalizations l10n,
  TransitReason r,
  TransitSuggestion s,
) =>
    switch (r.code) {
      'exact_qty' =>
        l10n.stockTransitReasonExact(s.sourceLabel, handoverQty(s.qty)),
      'only_sender' => l10n.stockTransitReasonOnlySender(s.sourceLabel),
      'same_shipment' => l10n.stockTransitReasonSameShipment,
      'sent_before' => l10n.stockTransitReasonSentBefore,
      'sent_after' => l10n.stockTransitReasonSentAfter,
      'usual_supplier' => l10n.stockTransitReasonUsual(
          s.sourceLabel, '${(r.share * 100).round()}'),
      'named_by_receiver' => l10n.stockTransitReasonNamed(s.sourceLabel),
      'split' => l10n.stockTransitReasonSplit,
      'no_send_declared' => l10n.stockTransitReasonNoSend,
      _ => '',
    };

/// The line's one-sentence "why": the reasons of its main suggestion.
String _whyLine(AppLocalizations l10n, LineAllocation line) {
  if (line.suggestions.isEmpty) return '';
  final main = line.suggestions.reduce((a, b) => b.qty > a.qty ? b : a);
  final parts = [
    if (line.suggestions.length > 1) l10n.stockTransitReasonSplit,
    for (final r in main.reasons)
      if (!(line.suggestions.length > 1 && r.code == 'split'))
        transitReasonText(l10n, r, main),
  ].where((t) => t.isNotEmpty).take(2);
  return parts.join(' · ');
}

String _ageText(AppLocalizations l10n, double hours) {
  final h = hours.isFinite && hours > 0 ? hours : 0.0;
  if (h < 24) return l10n.stockTransitAgeHours(h.floor());
  return l10n.stockTransitAgeDays((h / 24).floor());
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.text,
    this.emphasised = false,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final bool emphasised;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = emphasised ? theme.colorScheme.primary : null;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2, 8, 2, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 12),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final TransitSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget tile(String value, String label, {Color? color}) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: color ?? theme.colorScheme.outline),
              ),
            ],
          ),
        );
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            tile('${summary.toApprove}', l10n.stockTransitSummaryToApprove,
                color: summary.toApprove > 0 ? theme.colorScheme.primary : null),
            tile(handoverQty(summary.unitsInTransit),
                l10n.stockTransitSummaryUnits),
            tile('${summary.overdueSends}', l10n.stockTransitSummaryOverdue,
                color:
                    summary.overdueSends > 0 ? theme.colorScheme.error : null),
          ],
        ),
      ),
    );
  }
}

// ── Receipt card ────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.alloc,
    required this.busy,
    required this.onLineTap,
    required this.onApprove,
    required this.onReject,
  });

  final ReceiptAllocation alloc;
  final bool busy;
  final ValueChanged<LineAllocation> onLineTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final r = alloc.receipt;
    final confident = alloc.isConfident;
    final named = r.namedSourceLabel ?? r.namedSource;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: confident
              ? Colors.green.shade600
              : theme.colorScheme.outlineVariant,
          width: confident ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.move_to_inbox_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.stockTransitReceivedBy(r.targetLabel),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (confident)
                  _Pill(
                    text: l10n.stockTransitConfidenceHigh,
                    color: Colors.green.shade700,
                    icon: Icons.verified_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Pill(
                  text: (named == null || named.isEmpty)
                      ? l10n.stockTransitUnknownChip
                      : l10n.stockTransitNamedChip(named),
                  color: theme.colorScheme.secondary,
                  icon: (named == null || named.isEmpty)
                      ? Icons.help_outline
                      : Icons.record_voice_over_outlined,
                ),
                Text(
                  l10n.stockHandoverDeclaredBy(
                    r.declaredByName.isEmpty ? r.declaredBy : r.declaredByName,
                    handoverTime(context, r.declaredAt),
                  ),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
            const Divider(height: 18),
            for (final line in alloc.lines)
              _ReceiptLineRow(
                line: line,
                onTap: busy ? null : () => onLineTap(line),
              ),
            const SizedBox(height: 6),
            if (!r.canApprove)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l10n.stockTransitCannotApproveOwn,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            Row(
              children: [
                TextButton(
                  onPressed: busy ? null : onReject,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.stockHandoverReject),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: (busy || !alloc.canApprove) ? null : onApprove,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(l10n.stockTransitApprove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLineRow extends StatelessWidget {
  const _ReceiptLineRow({required this.line, required this.onTap});

  final LineAllocation line;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final kept = line.keptSuggestion;
    final left = line.leftToAssign;
    final unresolved = round3(line.line.unresolvedQty);

    // What is assigned right now, one chip per source.
    final chips = <Widget>[];
    for (final o in line.options) {
      final q = line.qtyFor(o.dispatch);
      if (round3(q) <= 0) continue;
      final s = line.suggestions
          .where((x) => x.dispatch == o.dispatch)
          .firstOrNull;
      chips.add(_Pill(
        text: '${o.sourceLabel} · ${handoverQty(q)}',
        color: kept && s != null
            ? _confidenceColor(context, s.confidence)
            : theme.colorScheme.primary,
        icon: Icons.outbox_outlined,
      ));
    }
    for (final d in line.direct) {
      if (round3(d.qty) <= 0) continue;
      final s = line.suggestions
          .where((x) => x.isDirect && x.sourceWarehouse == d.sourceWarehouse)
          .firstOrNull;
      chips.add(_Pill(
        text: '${d.sourceLabel} · ${handoverQty(d.qty)}',
        color: kept && s != null
            ? _confidenceColor(context, s.confidence)
            : theme.colorScheme.primary,
        icon: Icons.report_gmailerrorred_outlined,
      ));
    }

    final String? why = kept ? _whyLine(l10n, line) : null;
    // The line's weakest suggestion decides how sure it reads.
    final TransitConfidence? sureness = kept
        ? line.suggestions
            .map((s) => s.confidence)
            .reduce((a, b) => a.index >= b.index ? a : b)
        : null;
    if (sureness != null && sureness != TransitConfidence.none) {
      chips.add(_Pill(
        text: _confidenceLabel(l10n, sureness),
        color: _confidenceColor(context, sureness),
        icon: sureness == TransitConfidence.high
            ? Icons.check_circle_outline
            : Icons.help_outline,
      ));
    }
    final (String status, Color statusColor) = left > 0
        ? (l10n.stockTransitLeftToAssign(handoverQty(left)),
            theme.colorScheme.error)
        : left < 0
            ? (l10n.stockTransitOverAssigned(handoverQty(-left)),
                theme.colorScheme.error)
            : line.anyOverRemaining
                ? (l10n.stockTransitOverRemaining, theme.colorScheme.error)
                : (l10n.stockTransitAllAssigned, Colors.green.shade700);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.line.itemName.isEmpty
                              ? line.itemCode
                              : line.line.itemName,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${handoverQty(line.received)} ${line.line.stockUom}',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (line.receivedChanged)
                    Text(
                      l10n.stockTransitReceivedChanged(
                        handoverQty(line.line.qty),
                        handoverQty(line.received),
                      ),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.amber.shade900),
                    ),
                  const SizedBox(height: 4),
                  if (chips.isEmpty)
                    Text(
                      l10n.stockTransitTapToChoose,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Wrap(spacing: 6, runSpacing: 4, children: chips),
                  if (why != null && why.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      why,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                  if (!kept && chips.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      l10n.stockTransitEditedByYou,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                  if (kept && unresolved > 0)
                    Text(
                      l10n.stockTransitUnresolved(handoverQty(unresolved)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined,
                size: 18, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

// ── Allocation sheet ────────────────────────────────────────────────────────

class _AllocationSheet extends StatefulWidget {
  const _AllocationSheet({
    required this.board,
    required this.line,
    required this.onChanged,
  });

  final TransitBoard board;
  final LineAllocation line;
  final VoidCallback onChanged;

  @override
  State<_AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<_AllocationSheet> {
  /// Bumped on reset so every qty field rebuilds from the model.
  int _generation = 0;

  LineAllocation get _line => widget.line;

  void _edit(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  Future<void> _addDirect() async {
    final l10n = context.l10n;
    final taken = _line.direct.map((d) => d.sourceWarehouse).toSet();
    final options = widget.board.senders
        .where((s) =>
            s.warehouse != _line.targetWarehouse &&
            !taken.contains(s.warehouse))
        .toList();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.stockTransitNoSenders)),
      );
      return;
    }
    final pick = await showModalBottomSheet<HandoverSide>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                child: Text(
                  l10n.stockTransitPickSender,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  children: [
                    for (final s in options)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: ListTile(
                          minTileHeight: 56,
                          leading: Icon(s.isFactory
                              ? Icons.factory_outlined
                              : Icons.storefront_outlined),
                          title: Text(s.label),
                          onTap: () => Navigator.of(sheetCtx).pop(s),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (pick == null || !mounted) return;
    _edit(() => _line.addDirect(pick.warehouse, pick.label));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final line = _line;
    final left = line.leftToAssign;
    final suggested = {
      for (final s in line.suggestions)
        if (s.dispatch != null) s.dispatch!,
    };

    final (String status, Color statusColor) = left > 0
        ? (l10n.stockTransitLeftToAssign(handoverQty(left)),
            theme.colorScheme.error)
        : left < 0
            ? (l10n.stockTransitOverAssigned(handoverQty(-left)),
                theme.colorScheme.error)
            : (l10n.stockTransitAllAssigned, Colors.green.shade700);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 760,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
              child: Text(
                l10n.stockTransitSheetTitle(
                  line.line.itemName.isEmpty
                      ? line.itemCode
                      : line.line.itemName,
                ),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                children: [
                  // What actually arrived.
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.stockTransitActuallyReceived,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              l10n.stockTransitDeclaredQty(
                                '${handoverQty(line.line.qty)} '
                                '${line.line.stockUom}',
                              ),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      HandoverQtyField(
                        key: ValueKey('received-$_generation'),
                        value: line.received,
                        bold: true,
                        width: 92,
                        // Without `can_direct` the server refuses a
                        // correction above the declared qty; down is fine.
                        onChanged: (v) => _edit(() => line.received =
                            widget.board.canDirect || v <= line.line.qty
                                ? v
                                : line.line.qty),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.stockTransitOpenSends,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  if (line.options.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        l10n.stockTransitNoOpenSends,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                  for (final o in line.options)
                    _SendOptionRow(
                      key: ValueKey('${o.dispatch}-$_generation'),
                      option: o,
                      qty: line.qtyFor(o.dispatch),
                      suggested: suggested.contains(o.dispatch),
                      over: line.overRemaining(o.dispatch),
                      canFill: left > 0 &&
                          round3(o.remaining - line.qtyFor(o.dispatch)) > 0,
                      onChanged: (v) =>
                          _edit(() => line.setSendQty(o.dispatch, v)),
                      onFill: () => _edit(() => line.fillRestFrom(o.dispatch)),
                    ),
                  for (final d in line.direct)
                    _DirectRow(
                      key: ValueKey('direct-${d.sourceWarehouse}-$_generation'),
                      allocation: d,
                      onChanged: (v) => _edit(
                          () => line.setDirectQty(d.sourceWarehouse, v)),
                      onRemove: () =>
                          _edit(() => line.removeDirect(d.sourceWarehouse)),
                    ),
                  // A no-dispatch allocation is refused without `can_direct`.
                  if (widget.board.canDirect) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: _addDirect,
                        icon: const Icon(Icons.person_add_alt_outlined),
                        label: Text(l10n.stockTransitAddNotDeclared),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                child: Row(
                  children: [
                    if (line.suggestions.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _edit(() {
                          line.resetToSuggestion();
                          _generation++;
                        }),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n.stockTransitResetSuggestion),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.stockTransitDone),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendOptionRow extends StatelessWidget {
  const _SendOptionRow({
    super.key,
    required this.option,
    required this.qty,
    required this.suggested,
    required this.over,
    required this.canFill,
    required this.onChanged,
    required this.onFill,
  });

  final TransitSendOption option;
  final double qty;
  final bool suggested;
  final bool over;
  final bool canFill;
  final ValueChanged<double> onChanged;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final o = option;
    final meta = [
      if (o.declaredByName.isNotEmpty || o.declaredAt != null)
        l10n.stockTransitSentBy(
            o.declaredByName, handoverTime(context, o.declaredAt)),
      l10n.stockTransitSendLeft(handoverQty(o.remaining)),
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: suggested
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: over
            ? BorderSide(color: theme.colorScheme.error)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        o.sourceLabel,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (suggested)
                        _Pill(
                          text: l10n.stockTransitSuggested,
                          color: theme.colorScheme.primary,
                        ),
                      if (o.overdue)
                        _Pill(
                          text: l10n.stockTransitOverdue,
                          color: theme.colorScheme.error,
                        ),
                    ],
                  ),
                  Text(meta, style: theme.textTheme.bodySmall),
                  if (o.reservedElsewhere > 0)
                    Text(
                      l10n.stockTransitReservedElsewhere(
                          handoverQty(o.reservedElsewhere)),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.amber.shade900),
                    ),
                  if (over)
                    Text(
                      l10n.stockTransitOverRemaining,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (canFill)
              IconButton(
                tooltip: l10n.stockTransitFillRest,
                onPressed: onFill,
                icon: const Icon(Icons.playlist_add),
              ),
            HandoverQtyField(value: qty, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _DirectRow extends StatelessWidget {
  const _DirectRow({
    super.key,
    required this.allocation,
    required this.onChanged,
    required this.onRemove,
  });

  final DirectAllocation allocation;
  final ValueChanged<double> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.amber.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allocation.sourceLabel,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l10n.stockTransitNotDeclared,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),
            HandoverQtyField(value: allocation.qty, onChanged: onChanged),
            IconButton(
              tooltip: l10n.stockTransitRemove,
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Approve all confident ───────────────────────────────────────────────────

class _ConfidentReviewSheet extends StatelessWidget {
  const _ConfidentReviewSheet({required this.receipts});

  final List<ReceiptAllocation> receipts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 760,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 4),
            child: Text(
              l10n.stockTransitApproveConfidentTitle(receipts.length),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
            child: Text(l10n.stockTransitApproveConfidentBody,
                style: theme.textTheme.bodyMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
              children: [
                for (final a in receipts)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    color: Colors.green.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.stockTransitReceivedBy(a.receipt.targetLabel),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          for (final l in a.lines)
                            for (final o in l.options)
                              if (round3(l.qtyFor(o.dispatch)) > 0)
                                Text(
                                  '${l.line.itemName.isEmpty ? l.itemCode : l.line.itemName}'
                                  ' · ${handoverQty(l.qtyFor(o.dispatch))}'
                                  ' ← ${o.sourceLabel}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                          for (final l in a.lines)
                            for (final d in l.direct)
                              if (round3(d.qty) > 0)
                                Text(
                                  '${l.line.itemName.isEmpty ? l.itemCode : l.line.itemName}'
                                  ' · ${handoverQty(d.qty)}'
                                  ' ← ${d.sourceLabel}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.done_all),
                    label: Text(
                        l10n.stockTransitApproveConfidentButton(receipts.length)),
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

// ── Send card + return / write off ──────────────────────────────────────────

class _SendCard extends StatelessWidget {
  const _SendCard({
    required this.send,
    required this.busy,
    required this.onReturn,
    required this.onWriteOff,
  });

  final TransitSend send;
  final bool busy;
  final VoidCallback onReturn;
  final VoidCallback onWriteOff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = send;
    final ageColor = s.overdue ? theme.colorScheme.error : theme.colorScheme.outline;
    final open = s.openLines;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: s.overdue
              ? theme.colorScheme.error
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.outbox_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.sourceLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (s.overdue)
                  _Pill(
                    text: l10n.stockTransitOverdue,
                    color: theme.colorScheme.error,
                    icon: Icons.schedule,
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              l10n.stockTransitSentBy(
                s.declaredByName.isEmpty ? s.declaredBy : s.declaredByName,
                handoverTime(context, s.declaredAt),
              ),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            Text(
              _ageText(l10n, s.ageHours),
              style: theme.textTheme.bodySmall?.copyWith(
                color: ageColor,
                fontWeight: s.overdue ? FontWeight.w700 : null,
              ),
            ),
            const SizedBox(height: 6),
            for (final l in open)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.itemName.isEmpty ? l.itemCode : l.itemName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      l10n.stockTransitLeftOf(
                        handoverQty(l.remaining),
                        handoverQty(l.qty),
                      ),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (!s.canAct)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 6),
                child: Text(
                  l10n.stockTransitCannotActOwn,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              )
            else if (open.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : onReturn,
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.stockTransitReturn),
                  ),
                  TextButton.icon(
                    onPressed: busy ? null : onWriteOff,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: Text(l10n.stockTransitWriteOff),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SendActionResult {
  const _SendActionResult(this.lines, this.reason);

  final List<Map<String, dynamic>> lines;
  final String reason;

  double get total =>
      lines.fold(0.0, (s, l) => s + (l['qty'] as num).toDouble());
}

class _SendActionSheet extends StatefulWidget {
  const _SendActionSheet({required this.send, required this.writeOff});

  final TransitSend send;
  final bool writeOff;

  @override
  State<_SendActionSheet> createState() => _SendActionSheetState();
}

class _SendActionSheetState extends State<_SendActionSheet> {
  late final Map<String, double> _qty = {
    for (final l in widget.send.openLines) l.itemCode: l.remaining,
  };
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  double get _total => round3(_qty.values.fold(0.0, (s, q) => s + q));

  bool get _overAny => widget.send.openLines
      .any((l) => round3(_qty[l.itemCode] ?? 0) > round3(l.remaining));

  bool get _valid =>
      _total > 0 &&
      !_overAny &&
      (!widget.writeOff || _reason.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = widget.send;
    final total = handoverQty(_total);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 760,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 4),
              child: Text(
                widget.writeOff
                    ? l10n.stockTransitWriteOffTitle(s.sourceLabel)
                    : l10n.stockTransitReturnTitle(s.sourceLabel),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
              child: Text(
                widget.writeOff
                    ? l10n.stockTransitWriteOffBody
                    : l10n.stockTransitReturnBody(s.sourceLabel),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                children: [
                  for (final l in s.openLines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.itemName.isEmpty ? l.itemCode : l.itemName,
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  l10n.stockTransitSendLeft(
                                      handoverQty(l.remaining)),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: round3(_qty[l.itemCode] ?? 0) >
                                            round3(l.remaining)
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          HandoverQtyField(
                            value: _qty[l.itemCode] ?? 0,
                            onChanged: (v) =>
                                setState(() => _qty[l.itemCode] = v),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reason,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: widget.writeOff
                          ? l10n.stockTransitReasonRequiredHint
                          : l10n.stockHandoverRejectReasonHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                    const Spacer(),
                    FilledButton(
                      style: widget.writeOff
                          ? FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                            )
                          : null,
                      onPressed: _valid
                          ? () => Navigator.of(context).pop(_SendActionResult(
                                [
                                  for (final e in _qty.entries)
                                    if (round3(e.value) > 0)
                                      {'item_code': e.key, 'qty': round3(e.value)},
                                ],
                                _reason.text.trim(),
                              ))
                          : null,
                      child: Text(widget.writeOff
                          ? l10n.stockTransitWriteOffConfirm(total)
                          : l10n.stockTransitReturnConfirm(total)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reason dialog ───────────────────────────────────────────────────────────

/// Asks for a required reason; pops the trimmed text, or null on cancel.
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.body,
    required this.action,
    this.destructive = false,
  });

  final String title;
  final String body;
  final String action;
  final bool destructive;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final text = _ctrl.text.trim();
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.body),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.stockTransitReasonRequiredHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                )
              : null,
          onPressed: text.isEmpty ? null : () => Navigator.of(context).pop(text),
          child: Text(widget.action),
        ),
      ],
    );
  }
}

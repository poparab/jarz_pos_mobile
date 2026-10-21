import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/localization/user_error_message.dart';
import '../../data/stock_handover_models.dart';
import '../../data/stock_transfer_service.dart';
import '../../state/stock_handover_providers.dart';
import '../stock_handover_editor_screen.dart';
import '../stock_transit_screen.dart';
import 'handover_format.dart';
import 'stock_handover_card.dart';

/// Which handovers this user's screen lists. Managers (and anyone acting for
/// more than one side) see every side they may act for; a single-side user
/// sees exactly their side.
HandoverListQuery handoverListQueryFor(HandoverContext ctx, String? profile) {
  final String? myWarehouse = (!ctx.canManage && ctx.mySides.length == 1)
      ? ctx.mySides.first.warehouse
      : null;
  return (myWarehouse: myWarehouse, posProfile: profile);
}

/// The handover half of the Stock Transfer screen: what is waiting for this
/// user, the two big "I received" / "I sent out" buttons, what is waiting for
/// the other side, and the recent history. A manager also gets the Transit
/// entry on top: receipts waiting to be matched with what was sent out.
class StockHandoverView extends ConsumerStatefulWidget {
  const StockHandoverView({super.key});

  @override
  ConsumerState<StockHandoverView> createState() => _StockHandoverViewState();
}

class _StockHandoverViewState extends ConsumerState<StockHandoverView>
    with AutomaticKeepAliveClientMixin {
  String? _sideWarehouse;
  final Set<String> _busy = {};

  /// Handovers answered successfully whose refreshed list has not arrived yet.
  /// Their actions stay hidden so a second tap cannot answer them twice.
  final Set<String> _handled = {};

  @override
  bool get wantKeepAlive => true;

  HandoverSide? _selectedSide(HandoverContext ctx) {
    if (ctx.mySides.isEmpty) return null;
    return ctx.mySides.firstWhere(
      (s) => s.warehouse == _sideWarehouse,
      orElse: () => ctx.mySides.first,
    );
  }

  Future<void> _refresh(HandoverListQuery query) async {
    ref.invalidate(stockHandoverListsProvider(query));
    try {
      await ref.read(stockHandoverListsProvider(query).future);
    } catch (_) {
      // The list shows its own error.
    }
  }

  // ── Declare ──────────────────────────────────────────────────────────────

  Future<void> _startDeclare(
    HandoverContext ctx,
    HandoverSide side,
    HandoverEditMode mode,
    String? profile,
  ) async {
    final l10n = context.l10n;
    // "I sent out" has no destination: the user only says what left and a
    // manager matches it. Only "I received" asks from where, and "I don't
    // know who sent it" is its first, default answer.
    HandoverSide? counterpart;
    if (mode == HandoverEditMode.received) {
      final options = ctx.counterpartsFor(side);
      final choice =
          await _pickCounterpart(l10n.stockHandoverFromWhom, options);
      if (choice == null || !mounted) return;
      counterpart = choice.side;
    }
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StockHandoverEditorScreen.declare(
          mode: mode,
          mySide: side,
          counterpart: counterpart,
          posProfile: profile,
        ),
      ),
    );
    if (sent == true && mounted) {
      ref.invalidate(stockHandoverListsProvider);
    }
  }

  Future<_SenderChoice?> _pickCounterpart(
    String title,
    List<HandoverSide> options,
  ) {
    return showModalBottomSheet<_SenderChoice>(
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
                    title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: theme.colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 1.2,
                          ),
                        ),
                        child: ListTile(
                          minTileHeight: 64,
                          leading: const Icon(Icons.help_outline),
                          title: Text(
                            sheetCtx.l10n.stockHandoverUnknownSender,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            sheetCtx.l10n.stockHandoverUnknownSenderHint,
                          ),
                          onTap: () => Navigator.of(sheetCtx)
                              .pop(const _SenderChoice(null)),
                        ),
                      ),
                      for (final option in options)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: option.isFactory
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          child: ListTile(
                            minTileHeight: 60,
                            leading: Icon(
                              option.isFactory
                                  ? Icons.factory_outlined
                                  : Icons.storefront_outlined,
                            ),
                            title: Text(
                              option.label,
                              style: theme.textTheme.titleMedium,
                            ),
                            onTap: () => Navigator.of(sheetCtx)
                                .pop(_SenderChoice(option)),
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
  }

  // ── Respond ──────────────────────────────────────────────────────────────

  Future<void> _run(
    StockHandover h,
    Future<StockHandover?> Function(StockTransferService s) call,
    String Function(StockHandover? result) successMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(h.name));
    try {
      final result = await call(ref.read(stockTransferServiceProvider));
      messenger.showSnackBar(SnackBar(content: Text(successMessage(result))));
      if (mounted) setState(() => _handled.add(h.name));
      ref.invalidate(stockHandoverListsProvider);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(h.name));
    }
  }

  Future<void> _confirm(StockHandover h, String? profile) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stockHandoverConfirmTitle),
        content: Text(l10n.stockHandoverConfirmBody(h.fromLabel, h.toLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.stockHandoverConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(
      h,
      (s) => s.respondToHandover(
        name: h.name,
        action: 'confirm',
        posProfile: profile,
      ),
      (result) => l10n.stockHandoverConfirmedSnack(
        handoverLtr(result?.stockEntry ?? '-'),
      ),
    );
  }

  Future<void> _reject(StockHandover h, String? profile) async {
    final l10n = context.l10n;
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stockHandoverRejectTitle),
        content: TextField(
          controller: reasonCtrl,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: l10n.stockHandoverRejectReasonHint,
            border: const OutlineInputBorder(),
          ),
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
    await _run(
      h,
      (s) => s.respondToHandover(
        name: h.name,
        action: 'reject',
        reason: reason,
        posProfile: profile,
      ),
      (_) => l10n.stockHandoverRejectedSnack,
    );
  }

  Future<void> _cancel(StockHandover h, String? profile) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stockHandoverCancelTitle),
        content: Text(l10n.stockHandoverCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.stockHandoverKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.stockHandoverCancel),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(
      h,
      (s) => s.cancelHandover(name: h.name, posProfile: profile),
      (_) => l10n.stockHandoverCancelledSnack,
    );
  }

  Future<void> _change(StockHandover h, String? profile) async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StockHandoverEditorScreen.change(
          handover: h,
          posProfile: profile,
        ),
      ),
    );
    if (sent == true && mounted) {
      ref.invalidate(stockHandoverListsProvider);
    }
  }

  Future<void> _openTransit(String? profile) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StockTransitScreen(posProfile: profile),
      ),
    );
    // Approvals change the lists and the badge either way.
    if (mounted) ref.invalidate(stockHandoverListsProvider);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final ctxAsync = ref.watch(stockHandoverContextProvider);
    final profile = ref.watch(handoverSelectedProfileProvider);

    return ctxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Message(
        text: l10n.stockHandoverLoadFailed(context.userErrorMessage(e)),
        onRetry: () => ref.invalidate(stockHandoverContextProvider),
      ),
      data: (ctx) {
        if (!ctx.canDeclare && !ctx.canManage) {
          return _Message(
            text: l10n.stockHandoverNoAccess,
            onRetry: () => ref.invalidate(stockHandoverContextProvider),
          );
        }
        final query = handoverListQueryFor(ctx, profile);
        final listsAsync = ref.watch(stockHandoverListsProvider(query));
        final side = _selectedSide(ctx);

        // A fresh list means every pending "handled" mark has been resolved.
        ref.listen(stockHandoverListsProvider(query), (prev, next) {
          if (!next.isLoading && _handled.isNotEmpty) {
            setState(_handled.clear);
          }
        });

        final children = <Widget>[];
        final lists = listsAsync.valueOrNull;

        // Transit — managers only: the one way into matching.
        if (ctx.canMatchTransit) {
          children.add(_TransitEntryCard(
            toApprove: lists?.transitToMatch ?? 0,
            onTap: () => _openTransit(profile),
          ));
        }

        // Waiting for you — always on top.
        if (lists != null) {
          children.add(_SectionHeader(
            icon: Icons.notifications_active_outlined,
            text: l10n.stockHandoverWaitingForYou(lists.waitingForMe.length),
            emphasised: lists.waitingForMe.isNotEmpty,
          ));
          if (lists.waitingForMe.isEmpty) {
            children.add(Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.stockHandoverNothingWaiting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ));
          }
          for (final h in lists.waitingForMe) {
            children.add(StockHandoverCard(
              handover: h,
              highlight: true,
              busy: _busy.contains(h.name),
              handled: _handled.contains(h.name),
              onConfirm: () => _confirm(h, profile),
              onChange: () => _change(h, profile),
              onReject: () => _reject(h, profile),
              onCancel: () => _cancel(h, profile),
            ));
          }
        } else if (listsAsync.hasError) {
          children.add(_Message(
            text: l10n.stockHandoverLoadFailed(
              context.userErrorMessage(listsAsync.error),
            ),
            onRetry: () => _refresh(query),
            compact: true,
          ));
        } else {
          children.add(const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ));
        }

        // The two big buttons.
        if (side != null) {
          children.add(const SizedBox(height: 8));
          children.add(_DeclarePanel(
            ctx: ctx,
            selected: side,
            onSelectSide: (s) => setState(() => _sideWarehouse = s.warehouse),
            onDeclare: (mode) => _startDeclare(ctx, side, mode, profile),
          ));
        }

        if (lists != null) {
          if (lists.waitingForThem.isNotEmpty) {
            children.add(_SectionHeader(
              icon: Icons.hourglass_top,
              text:
                  l10n.stockHandoverWaitingForThem(lists.waitingForThem.length),
            ));
            for (final h in lists.waitingForThem) {
              children.add(StockHandoverCard(
                handover: h,
                busy: _busy.contains(h.name),
                handled: _handled.contains(h.name),
                onConfirm: () => _confirm(h, profile),
                onChange: () => _change(h, profile),
                onReject: () => _reject(h, profile),
                onCancel: () => _cancel(h, profile),
              ));
            }
          }
          if (lists.recent.isNotEmpty) {
            children.add(const SizedBox(height: 8));
            children.add(Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(l10n.stockHandoverRecent(lists.recent.length)),
                children: [
                  for (final h in lists.recent) StockHandoverCard(handover: h),
                ],
              ),
            ));
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(stockHandoverContextProvider);
            await _refresh(query);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            children: children,
          ),
        );
      },
    );
  }
}

class _DeclarePanel extends StatelessWidget {
  const _DeclarePanel({
    required this.ctx,
    required this.selected,
    required this.onSelectSide,
    required this.onDeclare,
  });

  final HandoverContext ctx;
  final HandoverSide selected;
  final ValueChanged<HandoverSide> onSelectSide;
  final ValueChanged<HandoverEditMode> onDeclare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final factory = selected.isFactory;

    final sentOut = (
      Icons.outbox_outlined,
      l10n.stockHandoverISentOut,
      HandoverEditMode.sentOut,
    );
    final received = (
      Icons.move_to_inbox_outlined,
      l10n.stockHandoverIReceived,
      HandoverEditMode.received,
    );
    final buttons = factory ? [sentOut, received] : [received, sentOut];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ctx.mySides.length > 1) ...[
          Row(
            children: [
              Text(l10n.stockHandoverActingAs,
                  style: theme.textTheme.labelLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in ctx.mySides)
                      ChoiceChip(
                        avatar: Icon(
                          s.isFactory
                              ? Icons.factory_outlined
                              : Icons.storefront_outlined,
                          size: 18,
                        ),
                        label: Text(s.label),
                        selected: s.warehouse == selected.warehouse,
                        onSelected: (_) => onSelectSide(s),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 88,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => onDeclare(buttons[i].$3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(buttons[i].$1, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          buttons[i].$2,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

//// Which sender the receiver picked: [side] null = "I don't know who sent it".
class _SenderChoice {
  const _SenderChoice(this.side);
  final HandoverSide? side;
}

/// The manager's way into the Transit board, with how many receipts wait.
class _TransitEntryCard extends StatelessWidget {
  const _TransitEntryCard({required this.toApprove, required this.onTap});

  final int toApprove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final waiting = toApprove > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: waiting ? 2 : 0,
      color: waiting
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: waiting
            ? BorderSide(color: theme.colorScheme.primary, width: 1.2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          child: Row(
            children: [
              Badge(
                isLabelVisible: waiting,
                label: Text('$toApprove'),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.stockTransitEntryTitle} — '
                      '${l10n.stockTransitEntryToApprove(toApprove)}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.stockTransitEntrySubtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.text,
    this.emphasised = false,
  });

  final IconData icon;
  final String text;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = emphasised ? theme.colorScheme.primary : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry, this.compact = false});

  final String text;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ],
      ),
    );
    return compact ? content : Center(child: content);
  }
}

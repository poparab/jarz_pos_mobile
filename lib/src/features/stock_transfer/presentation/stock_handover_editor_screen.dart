import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../data/stock_handover_models.dart';
import '../data/stock_transfer_service.dart';
import '../state/stock_handover_providers.dart';
import 'widgets/handover_format.dart';
import 'widgets/handover_qty_input.dart';

/// What the sentence on the review step says.
enum HandoverEditMode {
  /// Branch or factory: "I received from (counterpart)", direction `in`.
  received,

  /// "I sent out", direction `out`. No destination: the user only says what
  /// left, and a manager matches it with the branches that received it.
  sentOut,

  /// The awaiting side corrects the quantities of a pending handover.
  change,
}

enum _Step { items, review }

/// The two-step handover editor: (1) pick items and quantities, (2) review
/// only the lines with a quantity, then send. No dates anywhere — the stock
/// moves when the other side confirms, at that moment.
class StockHandoverEditorScreen extends ConsumerStatefulWidget {
  const StockHandoverEditorScreen._({
    required this.mode,
    required this.myWarehouse,
    this.myLabel = '',
    this.counterpartWarehouse,
    this.counterpartLabel,
    this.posProfile,
    this.handover,
  });

  /// A new declaration by [mySide]. For "I received", [counterpart] is the
  /// sender, or null when the receiver does not know who sent it (a manager
  /// matches it). Ignored for "I sent out".
  factory StockHandoverEditorScreen.declare({
    required HandoverEditMode mode,
    required HandoverSide mySide,
    HandoverSide? counterpart,
    String? posProfile,
  }) {
    assert(mode != HandoverEditMode.change);
    final other = mode == HandoverEditMode.sentOut ? null : counterpart;
    return StockHandoverEditorScreen._(
      mode: mode,
      myWarehouse: mySide.warehouse,
      myLabel: mySide.label,
      counterpartWarehouse: other?.warehouse,
      counterpartLabel: other?.label,
      posProfile: mySide.posProfile ?? posProfile,
    );
  }

  /// "Change" on a pending [handover]: prefilled with its quantities.
  factory StockHandoverEditorScreen.change({
    required StockHandover handover,
    String? posProfile,
  }) {
    final awaitingIsFrom = handover.awaitingSide == 'From';
    return StockHandoverEditorScreen._(
      mode: HandoverEditMode.change,
      myWarehouse: handover.awaitingWarehouse,
      counterpartWarehouse: handover.proposingWarehouse,
      counterpartLabel: awaitingIsFrom ? handover.toLabel : handover.fromLabel,
      posProfile: posProfile,
      handover: handover,
    );
  }

  final HandoverEditMode mode;
  final String myWarehouse;

  /// [myWarehouse]'s label, for the "leaves {side} now" line of "I sent out".
  final String myLabel;
  final String? counterpartWarehouse;
  final String? counterpartLabel;
  final String? posProfile;
  final StockHandover? handover;

  String get direction => mode == HandoverEditMode.received ? 'in' : 'out';

  /// "I received" with no sender named: a manager matches it.
  bool get isUnsourced =>
      mode == HandoverEditMode.received &&
      (counterpartWarehouse == null || counterpartWarehouse!.isEmpty);

  @override
  ConsumerState<StockHandoverEditorScreen> createState() =>
      _StockHandoverEditorScreenState();
}

class _StockHandoverEditorScreenState
    extends ConsumerState<StockHandoverEditorScreen> {
  final Map<String, double> _qty = {};
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  /// Item groups opened or closed by hand; "Small" defaults to closed.
  final Map<String, bool> _groupOpen = {};
  _Step _step = _Step.items;
  bool _submitting = false;
  bool _done = false;

  /// One id per editor session: a double tap or a retry after a lost reply
  /// makes the server hand back the first declaration instead of a second.
  final String _clientRequestId = const Uuid().v4();

  /// Names for lines that came with the handover, so a prefilled item still
  /// reads right even if the server's item list no longer offers it.
  final Map<String, HandoverItemOption> _extra = {};

  @override
  void initState() {
    super.initState();
    final h = widget.handover;
    if (h != null) {
      for (final line in h.items) {
        if (line.qty > 0) _qty[line.itemCode] = line.qty;
        _extra[line.itemCode] = HandoverItemOption(
          itemCode: line.itemCode,
          itemName: line.itemName,
          stockUom: line.stockUom,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  HandoverItemsQuery get _itemsQuery => (
    myWarehouse: widget.myWarehouse,
    counterpartWarehouse: widget.counterpartWarehouse,
    direction: widget.direction,
  );

  bool get _hasInput => _qty.values.any((q) => q > 0);

  bool get _isChange => widget.mode == HandoverEditMode.change;

  /// Change mode only: true while the quantities still equal what was
  /// proposed, so a "change" would say nothing the other side hasn't seen.
  bool get _unchanged {
    final h = widget.handover;
    if (h == null) return false;
    final before = {
      for (final l in h.items)
        if (l.qty > 0) l.itemCode: l.qty,
    };
    final now = {
      for (final e in _qty.entries)
        if (e.value > 0) e.key: e.value,
    };
    if (before.length != now.length) return false;
    for (final e in before.entries) {
      final v = now[e.key];
      if (v == null || (v - e.value).abs() > 1e-9) return false;
    }
    return true;
  }

  /// Review / Send are allowed: something typed, and in change mode, a real
  /// difference (F4).
  bool get _canProceed => _hasInput && !(_isChange && _unchanged);

  int get _lineCount => _qty.values.where((q) => q > 0).length;

  /// Server items first (grouped, sorted by the server), then any prefilled
  /// line the server did not list.
  List<HandoverItemOption> _allItems(List<HandoverItemOption> served) {
    final seen = served.map((o) => o.itemCode).toSet();
    return [
      ...served,
      for (final extra in _extra.values)
        if (!seen.contains(extra.itemCode)) extra,
    ];
  }

  void _setQty(String code, double value) {
    setState(() {
      if (value <= 0 || !value.isFinite) {
        _qty.remove(code);
      } else {
        _qty[code] = value;
      }
    });
  }

  Future<bool> _confirmDiscard() async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stockHandoverDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.stockHandoverKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.stockHandoverDiscard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    if (_submitting) return;
    if (_step == _Step.review) {
      setState(() => _step = _Step.items);
      return;
    }
    final isChange = _isChange;
    // A change starts filled in, so only a fresh declaration with nothing
    // typed can leave without asking.
    if (_hasInput || isChange) {
      if (!await _confirmDiscard()) return;
    }
    if (!mounted) return;
    _done = true;
    Navigator.of(context).pop();
  }

  Future<void> _submit(List<HandoverItemOption> items) async {
    if (_submitting || !_canProceed) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final lines = [
      for (final item in items)
        if ((_qty[item.itemCode] ?? 0) > 0)
          {'item_code': item.itemCode, 'qty': _qty[item.itemCode]!},
    ];
    setState(() => _submitting = true);
    try {
      final service = ref.read(stockTransferServiceProvider);
      final StockHandover? result;
      if (widget.mode == HandoverEditMode.change) {
        result = await service.respondToHandover(
          name: widget.handover!.name,
          action: 'change',
          lines: lines,
          posProfile: widget.posProfile,
        );
      } else {
        result = await service.declareHandover(
          myWarehouse: widget.myWarehouse,
          counterpartWarehouse: widget.counterpartWarehouse,
          direction: widget.direction,
          lines: lines,
          posProfile: widget.posProfile,
          clientRequestId: _clientRequestId,
        );
      }
      final waitingFor = (result?.awaitingLabel ?? '').isNotEmpty
          ? result!.awaitingLabel
          : (widget.counterpartLabel ?? '');
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == HandoverEditMode.sentOut
                ? l10n.stockHandoverSentOutSnack
                : (widget.isUnsourced ||
                      (result?.awaitsManager ?? false) ||
                      waitingFor.isEmpty)
                ? l10n.stockHandoverSentToManagerSnack
                : l10n.stockHandoverSentSnack(waitingFor),
          ),
        ),
      );
      ref.invalidate(stockHandoverListsProvider);
      _done = true;
      if (mounted) navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text(context.userErrorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final itemsAsync = ref.watch(stockHandoverItemsProvider(_itemsQuery));
    final isChange = _isChange;
    final title = _step == _Step.review
        ? l10n.stockHandoverReviewTitle
        : (isChange
              ? l10n.stockHandoverEditTitle
              : l10n.stockHandoverItemsTitle);

    return PopScope(
      canPop: _done,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const BackButtonIcon(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _handleBack,
          ),
        ),
        body: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorRetry(
            message: l10n.stockHandoverLoadFailed(context.userErrorMessage(e)),
            onRetry: () =>
                ref.invalidate(stockHandoverItemsProvider(_itemsQuery)),
          ),
          data: (served) {
            final items = _allItems(served);
            return _step == _Step.items
                ? _buildItemsStep(items)
                : _buildReviewStep(items);
          },
        ),
      ),
    );
  }

  // ── Step 1: items ────────────────────────────────────────────────────────

  Widget _buildItemsStep(List<HandoverItemOption> items) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final needle = _search.trim().toLowerCase();
    final visible = needle.isEmpty
        ? items
        : items
              .where(
                (o) =>
                    o.itemName.toLowerCase().contains(needle) ||
                    o.itemCode.toLowerCase().contains(needle),
              )
              .toList();

    final groupCounts = <String, int>{};
    for (final item in visible) {
      groupCounts[item.itemGroup] = (groupCounts[item.itemGroup] ?? 0) + 1;
    }
    // "Small" starts collapsed (rarely handed over); a search shows matches.
    bool groupOpen(String g) =>
        needle.isNotEmpty ||
        (_groupOpen[g] ?? g.trim().toLowerCase() != 'small');

    final rows = <Widget>[];
    String? group;
    for (final item in visible) {
      if (item.itemGroup != group) {
        group = item.itemGroup;
        if (group.isNotEmpty) {
          final g = group;
          final open = groupOpen(g);
          rows.add(
            InkWell(
              key: ValueKey('handover-group-$g'),
              onTap: needle.isNotEmpty
                  ? null
                  : () => setState(() => _groupOpen[g] = !open),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                child: Row(
                  children: [
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        g,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${groupCounts[g] ?? 0}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
      if (item.itemGroup.isNotEmpty && !groupOpen(item.itemGroup)) continue;
      rows.add(
        _HandoverQtyTile(
          key: ValueKey(item.itemCode),
          item: item,
          qty: _qty[item.itemCode] ?? 0,
          onChanged: (v) => _setQty(item.itemCode, v),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.commonSearchItems,
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    ),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.stockHandoverNoItems,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: rows,
                ),
        ),
        if (_isChange && _hasInput && _unchanged)
          _NoChangeHint(text: l10n.stockHandoverNoChangeHint),
        _BottomBar(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _canProceed
                    ? () {
                        FocusScope.of(context).unfocus();
                        setState(() => _step = _Step.review);
                      }
                    : null,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l10n.stockHandoverReviewButton(_lineCount)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: review ───────────────────────────────────────────────────────

  String _reviewHeader() {
    final l10n = context.l10n;
    final name = widget.counterpartLabel ?? '';
    switch (widget.mode) {
      case HandoverEditMode.received:
        return widget.isUnsourced
            ? l10n.stockHandoverReviewReceivedUnknown
            : l10n.stockHandoverReviewReceived(name);
      case HandoverEditMode.sentOut:
        return l10n.stockHandoverReviewSentOut;
      case HandoverEditMode.change:
        final h = widget.handover!;
        return l10n.stockHandoverReviewChange(h.fromLabel, h.toLabel);
    }
  }

  Widget _buildReviewStep(List<HandoverItemOption> items) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final chosen = [
      for (final item in items)
        if ((_qty[item.itemCode] ?? 0) > 0) item,
    ];
    final before = {
      for (final line in widget.handover?.items ?? const <StockHandoverLine>[])
        line.itemCode: line.qty,
    };
    final total = chosen.fold<double>(0, (s, i) => s + (_qty[i.itemCode] ?? 0));
    // F5: a line that was proposed and is now zero is removed. Show it with
    // its old quantity struck through and 0 after, so the other side's view
    // of what changed is complete.
    final removed = [
      for (final line in widget.handover?.items ?? const <StockHandoverLine>[])
        if (line.qty > 0 && (_qty[line.itemCode] ?? 0) <= 0) line,
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            children: [
              Text(
                _reviewHeader(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final item in chosen)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (widget.handover != null &&
                          before[item.itemCode] != _qty[item.itemCode]) ...[
                        Text(
                          handoverQty(before[item.itemCode] ?? 0),
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        handoverQty(_qty[item.itemCode] ?? 0),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (item.stockUom.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          item.stockUom,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              for (final line in removed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.itemName,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        handoverQty(line.qty),
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        handoverQty(0),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 24),
              Text(
                l10n.stockHandoverReviewTotal(handoverQty(total)),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (widget.mode == HandoverEditMode.sentOut)
                // "Leaves <side> now" is the one line here that moves stock
                // the moment Send is tapped: say it as a banner, not a hint.
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.stockHandoverReviewHintSentOut(widget.myLabel),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  widget.isUnsourced
                      ? l10n.stockHandoverReviewHintUnknown
                      : l10n.stockHandoverReviewHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
        if (_isChange && _unchanged)
          _NoChangeHint(text: l10n.stockHandoverNoChangeHint),
        _BottomBar(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _submitting
                    ? null
                    : () => setState(() => _step = _Step.items),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.stockHandoverBack),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _submitting || chosen.isEmpty || !_canProceed
                    ? null
                    : () => _submit(items),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.stockHandoverSend),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "No change. Confirm it instead": shown above a disabled Review / Send.
class _NoChangeHint extends StatelessWidget {
  const _NoChangeHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
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

/// One item with a big − / + stepper; the number itself can be tapped and
/// typed over. Stateful only to own the field's controller, so typing is not
/// fought by a rebuild re-formatting the text under the cursor.
class _HandoverQtyTile extends StatefulWidget {
  const _HandoverQtyTile({
    super.key,
    required this.item,
    required this.qty,
    required this.onChanged,
  });

  final HandoverItemOption item;
  final double qty;
  final ValueChanged<double> onChanged;

  @override
  State<_HandoverQtyTile> createState() => _HandoverQtyTileState();
}

class _HandoverQtyTileState extends State<_HandoverQtyTile> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.qty));
  }

  @override
  void didUpdateWidget(covariant _HandoverQtyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_parse(_ctrl.text) != widget.qty) {
      final text = _fmt(widget.qty);
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _fmt(double v) => v <= 0 ? '' : handoverQty(v);

  static double _parse(String text) => double.tryParse(text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = widget.qty > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      color: active
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.itemName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (widget.item.stockUom.isNotEmpty)
                    Text(
                      widget.item.stockUom,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            IconButton.filledTonal(
              iconSize: 26,
              onPressed: active
                  ? () => widget.onChanged(
                      (widget.qty - 1) < 0 ? 0 : widget.qty - 1,
                    )
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 68,
              child: TextField(
                controller: _ctrl,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: const [HandoverQtyInputFormatter()],
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _ctrl.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _ctrl.text.length,
                ),
                onChanged: (text) => widget.onChanged(_parse(text)),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              iconSize: 26,
              onPressed: () => widget.onChanged(widget.qty + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

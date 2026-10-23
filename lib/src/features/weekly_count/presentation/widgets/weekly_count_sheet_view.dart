import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/weekly_count_draft.dart';
import '../../data/weekly_count_models.dart';
import '../../data/weekly_count_service.dart';
import '../weekly_count_format.dart';
import 'weekly_count_keypad_dialog.dart';

/// Widget keys the tests (and nothing else) look rows up by.
abstract final class WeeklyCountSheetKeys {
  static const submit = ValueKey('weekly-count-submit');
  static const progress = ValueKey('weekly-count-progress');
  static ValueKey<String> row(String code) => ValueKey('wc-row-$code');
  static ValueKey<String> qty(String code) => ValueKey('wc-qty-$code');
  static ValueKey<String> inc(String code) => ValueKey('wc-inc-$code');
  static ValueKey<String> dec(String code) => ValueKey('wc-dec-$code');
  static ValueKey<String> allZero(String section) =>
      ValueKey('wc-zero-$section');
}

/// The blind count sheet: every item, a big stepper on each, and a submit
/// that stays locked until every item has a number.
///
/// Owns the draft (autosaved per branch and week) and the submit call. The
/// parent decides what comes after: [onSubmitted] with the server's answer,
/// [onReloadSheet] when the item list on the server moved, and [onClosed]
/// when the server says this week is already counted or waiting.
class WeeklyCountSheetView extends ConsumerStatefulWidget {
  const WeeklyCountSheetView({
    super.key,
    required this.sheet,
    required this.branchLabel,
    required this.onSubmitted,
    required this.onReloadSheet,
    required this.onClosed,
  });

  final WeeklyCountSheet sheet;
  final String branchLabel;
  final ValueChanged<WeeklyCountSubmitResult> onSubmitted;
  final VoidCallback onReloadSheet;
  final VoidCallback onClosed;

  @override
  ConsumerState<WeeklyCountSheetView> createState() =>
      _WeeklyCountSheetViewState();
}

class _WeeklyCountSheetViewState extends ConsumerState<WeeklyCountSheetView> {
  WeeklyCountDraft? _draft;
  bool _submitting = false;
  final Map<String, GlobalKey> _rowKeys = {};
  String? _pulseCode;
  int _pulseTick = 0;

  /// Sections the counter opened or closed by hand, by section key. A section
  /// not listed follows [_defaultOpen]: Small starts closed, nobody counts it
  /// much.
  final Map<String, bool> _open = {};

  static bool _defaultOpen(String sectionKey) =>
      sectionKey.trim().toLowerCase() != 'small';

  bool _isOpen(String sectionKey) =>
      _open[sectionKey] ?? _defaultOpen(sectionKey);

  WeeklyCountDraftStore get _store => ref.read(weeklyCountDraftStoreProvider);

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void didUpdateWidget(covariant WeeklyCountSheetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheet.posProfile != widget.sheet.posProfile ||
        oldWidget.sheet.weekStart != widget.sheet.weekStart) {
      setState(() => _draft = null);
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    final sheet = widget.sheet;
    // Drafts are per user: a shared branch tablet must not hand one
    // counter's numbers to the next. No user known = memory-only draft.
    var user = '';
    try {
      user = await ref.read(weeklyCountDraftUserProvider.future) ?? '';
    } catch (_) {
      // Roles unreachable: count anyway, just without autosave.
    }
    WeeklyCountDraft? saved;
    if (user.isNotEmpty) {
      try {
        saved = await _store.load(user, sheet.posProfile, sheet.weekStart);
      } catch (_) {
        // A broken cache only costs the counter a restart of the count.
      }
    }
    if (!mounted) return;
    if (widget.sheet.posProfile != sheet.posProfile ||
        widget.sheet.weekStart != sheet.weekStart) {
      return;
    }
    final draft =
        saved ??
        WeeklyCountDraft(
          user: user,
          posProfile: sheet.posProfile,
          weekStart: sheet.weekStart,
        );
    // A recount after a rejection never reuses the rejected submission's id.
    if (sheet.state == WeeklyCountState.rejected &&
        draft.renewRequestIdAfterRejection()) {
      unawaited(_persist(draft));
    }
    setState(() => _draft = draft);
  }

  void _change(void Function(WeeklyCountDraft d) edit) {
    final draft = _draft;
    if (draft == null || _submitting) return;
    setState(() => edit(draft));
    unawaited(_persist(draft));
  }

  Future<void> _persist(WeeklyCountDraft draft) async {
    if (draft.user.isEmpty) return;
    try {
      await _store.save(draft);
    } catch (_) {
      // Best-effort: the count is still on screen.
    }
  }

  Future<void> _deleteDraft(WeeklyCountDraft draft) async {
    if (draft.user.isEmpty) return;
    await _store.delete(draft.user, draft.posProfile, draft.weekStart);
  }

  GlobalKey _keyFor(String code) => _rowKeys.putIfAbsent(code, GlobalKey.new);

  Future<void> _openKeypad(WeeklyCountSheetItem item) async {
    final draft = _draft;
    if (draft == null || _submitting) return;
    final result = await showWeeklyCountKeypad(
      context,
      itemName: item.itemName,
      initial: draft.qtyOf(item.itemCode),
    );
    if (result == null || !mounted) return;
    _change((d) {
      if (result.uncount) {
        d.clear(item.itemCode);
      } else if (result.qty != null) {
        d.setQty(item.itemCode, result.qty!);
      }
    });
  }

  Future<void> _allZero(String sectionTitle, List<String> codes) async {
    final draft = _draft;
    if (draft == null || _submitting) return;
    final l10n = context.l10n;
    final missing = codes.length - draft.countedOf(codes);
    if (missing == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.weeklyCountAllZeroNothing)));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.weeklyCountAllZeroTitle),
        content: Text(l10n.weeklyCountAllZeroBody(missing, sectionTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.weeklyCountAllZero),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _change((d) => d.zeroUncounted(codes));
  }

  void _pointAtFirstUncounted(WeeklyCountDraft draft, List<String> codes) {
    final first = draft.firstUncounted(codes);
    if (first == null) return;
    final left = codes.length - draft.countedOf(codes);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.weeklyCountFinishFirst(left))),
      );
    // The row may sit in a collapsed section: open it first, scroll once it
    // has been built.
    final sectionKey = _sectionKeyOf(first);
    setState(() {
      _pulseCode = first;
      _pulseTick++;
      if (sectionKey != null) _open[sectionKey] = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rowContext = _rowKeys[first]?.currentContext;
      if (rowContext != null) {
        unawaited(
          Scrollable.ensureVisible(
            rowContext,
            alignment: 0.3,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  /// The key of the section (item or label) that holds [code], if any.
  String? _sectionKeyOf(String code) {
    for (final s in widget.sheet.sections) {
      if (s.items.any((i) => i.itemCode == code)) return s.key;
    }
    for (final s in widget.sheet.labelSections) {
      if (s.labels.any((l) => l.countKey == code)) return s.key;
    }
    return null;
  }

  Future<void> _submit() async {
    final draft = _draft;
    if (draft == null || _submitting) return;
    final codes = widget.sheet.countKeys;
    if (!draft.isComplete(codes)) {
      _pointAtFirstUncounted(draft, codes);
      return;
    }
    final l10n = context.l10n;
    final approver = widget.sheet.isApprover;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.weeklyCountSubmitConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weeklyCountSubmitConfirmSummary(
                widget.branchLabel,
                codes.length,
              ),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  approver ? Icons.bolt : Icons.hourglass_top,
                  color: approver
                      ? WeeklyCountColors.green
                      : WeeklyCountColors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    approver
                        ? l10n.weeklyCountSubmitConfirmApprover
                        : l10n.weeklyCountSubmitConfirmStaff,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.weeklyCountSubmitConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    // Saved first so the request id survives a crash mid-request: a retry
    // then returns the same document instead of a second one. The flag says
    // the id may now name a real document (see renewRequestIdAfterRejection).
    draft.submitAttempted = true;
    await _persist(draft);
    try {
      final result = await ref
          .read(weeklyCountServiceProvider)
          .submit(
            posProfile: widget.sheet.posProfile,
            lines: draft.linesFor(widget.sheet.itemCodes),
            labelLines: draft.labelLinesFor(widget.sheet.labelKeys),
            clientRequestId: draft.clientRequestId,
          );
      try {
        await _deleteDraft(draft);
      } catch (_) {
        // A leftover draft is harmless: next week has a new key.
      }
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onSubmitted(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final code = weeklyCountErrorCode(e);
      final message = weeklyCountErrorMessage(context.l10n, e);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
          ),
        );
      switch (code) {
        case WeeklyCountErrorCodes.missingItems:
        case WeeklyCountErrorCodes.unknownItems:
          widget.onReloadSheet();
        case WeeklyCountErrorCodes.alreadyPending:
        case WeeklyCountErrorCodes.alreadyDone:
          try {
            await _deleteDraft(draft);
          } catch (_) {
            // ignore: the week is closed either way.
          }
          widget.onClosed();
      }
    }
  }

  Widget _rowFor(WeeklyCountDraft draft, WeeklyCountSheetItem item) {
    final code = item.itemCode;
    return _CountRow(
      key: _keyFor(code),
      item: item,
      qty: draft.qtyOf(code),
      pulseTick: code == _pulseCode ? _pulseTick : 0,
      enabled: !_submitting,
      onIncrement: () => _change((d) => d.increment(code)),
      onDecrement: () => _change((d) => d.decrement(code)),
      onTapQty: () => _openKeypad(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    if (draft == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sheet = widget.sheet;
    final codes = sheet.countKeys;
    if (codes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.weeklyCountEmptySheet,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }
    final counted = draft.countedOf(codes);
    final total = codes.length;
    final complete = counted == total;

    final seen = <String>{};
    final sectionWidgets = <Widget>[];
    for (final section in sheet.sections) {
      final items = [
        for (final i in section.items)
          if (seen.add(i.itemCode)) i,
      ];
      if (items.isEmpty) continue;
      final sectionCodes = [for (final i in items) i.itemCode];
      final sectionTitle = weeklyCountSectionTitle(l10n, section);
      final open = _isOpen(section.key);
      sectionWidgets.add(
        _SectionHeader(
          key: ValueKey('wc-section-${section.key}'),
          title: sectionTitle,
          counted: draft.countedOf(sectionCodes),
          total: sectionCodes.length,
          zeroKey: WeeklyCountSheetKeys.allZero(section.key),
          onAllZero: () => _allZero(sectionTitle, sectionCodes),
          open: open,
          onToggle: () => setState(() => _open[section.key] = !open),
        ),
      );
      if (!open) continue;
      for (final item in items) {
        sectionWidgets.add(_rowFor(draft, item));
      }
    }

    if (sheet.hasLabels) {
      sectionWidgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              Icon(Icons.label, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.weeklyCountLabelsHeading,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      for (final section in sheet.labelSections) {
        final labels = [
          for (final l in section.labels)
            if (seen.add(l.countKey)) l,
        ];
        if (labels.isEmpty) continue;
        final sectionCodes = [for (final l in labels) l.countKey];
        final open = _isOpen(section.key);
        sectionWidgets.add(
          _SectionHeader(
            key: ValueKey('wc-section-${section.key}'),
            title: section.title,
            counted: draft.countedOf(sectionCodes),
            total: sectionCodes.length,
            zeroKey: WeeklyCountSheetKeys.allZero(section.key),
            onAllZero: () => _allZero(section.title, sectionCodes),
            open: open,
            onToggle: () => setState(() => _open[section.key] = !open),
            leadingIcon: Icons.sell_outlined,
          ),
        );
        if (!open) continue;
        for (final label in labels) {
          sectionWidgets.add(
            _rowFor(
              draft,
              WeeklyCountSheetItem(
                itemCode: label.countKey,
                itemName: label.title,
                stockUom: label.subtitle,
                image: label.image,
              ),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sticky: the scroll view below moves, this does not.
        Material(
          elevation: 2,
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.branchLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l10n.weeklyCountProgress(counted, total),
                      key: WeeklyCountSheetKeys.progress,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: complete
                            ? WeeklyCountColors.green
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : counted / total,
                    minHeight: 10,
                    color: complete ? WeeklyCountColors.green : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          // Not lazy on purpose: about 25 rows, and every row must exist for
          // "scroll to the first uncounted item" to find it.
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: sectionWidgets,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 58,
              child: FilledButton.icon(
                key: WeeklyCountSheetKeys.submit,
                // Always tappable: an early tap points at what is missing
                // instead of doing nothing. It only LOOKS disabled.
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: complete
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  foregroundColor: complete
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.weeklyCountSubmit),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.counted,
    required this.total,
    required this.zeroKey,
    required this.onAllZero,
    required this.open,
    required this.onToggle,
    this.leadingIcon,
  });

  final bool open;
  final VoidCallback onToggle;
  final IconData? leadingIcon;
  final String title;
  final int counted;
  final int total;
  final Key zeroKey;
  final VoidCallback onAllZero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = counted == total;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: theme.colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(open ? Icons.expand_less : Icons.expand_more),
              const SizedBox(width: 6),
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 20),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$counted / $total',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: done
                      ? WeeklyCountColors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (done) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: WeeklyCountColors.green,
                ),
              ],
              const Spacer(),
              TextButton(
                key: zeroKey,
                onPressed: onAllZero,
                child: Text(context.l10n.weeklyCountAllZero),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRow extends StatefulWidget {
  const _CountRow({
    super.key,
    required this.item,
    required this.qty,
    required this.pulseTick,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTapQty,
  });

  final WeeklyCountSheetItem item;
  final int? qty;
  final int pulseTick;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTapQty;

  @override
  State<_CountRow> createState() => _CountRowState();
}

class _CountRowState extends State<_CountRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(covariant _CountRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseTick != 0 && widget.pulseTick != oldWidget.pulseTick) {
      _pulse
        ..reset()
        ..repeat(reverse: true, count: 3);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final code = widget.item.itemCode;
    final qty = widget.qty;
    final counted = qty != null;

    final stepButtonStyle = IconButton.styleFrom(
      minimumSize: const Size(52, 52),
      backgroundColor: theme.colorScheme.secondaryContainer,
      foregroundColor: theme.colorScheme.onSecondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          WeeklyCountItemImage(path: widget.item.image, size: 46),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.item.stockUom.isNotEmpty)
                  Text(
                    widget.item.stockUom,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            key: WeeklyCountSheetKeys.dec(code),
            tooltip: l10n.inventoryCountDecrease,
            style: stepButtonStyle,
            onPressed: widget.enabled ? widget.onDecrement : null,
            icon: const Icon(Icons.remove, size: 26),
          ),
          const SizedBox(width: 6),
          Semantics(
            label: counted ? null : l10n.weeklyCountUncounted,
            button: true,
            child: InkWell(
              key: WeeklyCountSheetKeys.qty(code),
              onTap: widget.enabled ? widget.onTapQty : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 66,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: counted
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: counted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: counted ? 2 : 1.5,
                  ),
                ),
                child: Text(
                  counted ? '$qty' : '—',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: counted
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            key: WeeklyCountSheetKeys.inc(code),
            tooltip: l10n.inventoryCountIncrease,
            style: stepButtonStyle,
            onPressed: widget.enabled ? widget.onIncrement : null,
            icon: const Icon(Icons.add, size: 26),
          ),
          SizedBox(
            width: 26,
            child: counted
                ? const Icon(
                    Icons.check,
                    size: 20,
                    color: WeeklyCountColors.green,
                  )
                : null,
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(
            counted
                ? WeeklyCountColors.greenBg.withValues(alpha: 0.35)
                : Colors.transparent,
            WeeklyCountColors.amberBg,
            _pulse.value,
          ),
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: child,
      ),
      child: row,
    );
  }
}

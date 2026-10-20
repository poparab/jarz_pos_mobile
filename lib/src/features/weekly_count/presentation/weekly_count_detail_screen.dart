import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../data/weekly_count_models.dart';
import '../data/weekly_count_service.dart';
import 'weekly_count_format.dart';
import 'weekly_count_providers.dart';

/// `/weekly-count/:name`: one count. An approver sees counted vs system with
/// the differences first, and approves or rejects while it is pending. A
/// counter sees only what they counted.
class WeeklyCountDetailScreen extends ConsumerStatefulWidget {
  const WeeklyCountDetailScreen({super.key, required this.countName});

  final String countName;

  @override
  ConsumerState<WeeklyCountDetailScreen> createState() =>
      _WeeklyCountDetailScreenState();
}

class _WeeklyCountDetailScreenState
    extends ConsumerState<WeeklyCountDetailScreen> {
  bool _busy = false;
  bool _showUnchanged = false;

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.weeklyCountApprovals);
    }
  }

  Future<void> _approve() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.weeklyCountApproveTitle),
        content: Text(l10n.weeklyCountApproveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WeeklyCountColors.green,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.weeklyCountApprove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _act(
      () => ref.read(weeklyCountServiceProvider).approve(widget.countName),
      l10n.weeklyCountApprovedToast,
    );
  }

  Future<void> _reject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null || reason.trim().isEmpty || !mounted) return;
    await _act(
      () => ref
          .read(weeklyCountServiceProvider)
          .reject(widget.countName, reason.trim()),
      context.l10n.weeklyCountRejectedToast,
    );
  }

  Future<void> _act(Future<Object?> Function() call, String successText) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await call();
      if (!mounted) return;
      invalidateWeeklyCountState(ref, name: widget.countName);
      messenger.showSnackBar(SnackBar(content: Text(successText)));
      _leave();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      // Someone else acted first, or the state moved: show the fresh one.
      ref.invalidate(weeklyCountDetailProvider(widget.countName));
      messenger.showSnackBar(
        SnackBar(
          content: Text(weeklyCountErrorMessage(l10n, e)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(weeklyCountDetailProvider(widget.countName));
    final detail = async.valueOrNull;

    Widget body;
    Widget? bottom;
    if (detail == null) {
      body = async.hasError
          ? WeeklyCountErrorView(
              error: async.error!,
              onRetry: () =>
                  ref.invalidate(weeklyCountDetailProvider(widget.countName)),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      body = RefreshIndicator(
        onRefresh: () =>
            ref.refresh(weeklyCountDetailProvider(widget.countName).future),
        child: _DetailBody(
          detail: detail,
          showUnchanged: _showUnchanged,
          onToggleUnchanged: () =>
              setState(() => _showUnchanged = !_showUnchanged),
        ),
      );
      if (detail.canApprove) {
        bottom = _ActionBar(
          busy: _busy,
          onApprove: _approve,
          onReject: _reject,
        );
      }
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l10n.weeklyCountDetailTitle)),
      body: body,
      bottomNavigationBar: bottom,
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.detail,
    required this.showUnchanged,
    required this.onToggleUnchanged,
  });

  final WeeklyCountDetail detail;
  final bool showUnchanged;
  final VoidCallback onToggleUnchanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final h = detail.header;
    final withSystem = detail.showsSystemQty;

    final children = <Widget>[
      // Header
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      h.posProfile,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  WeeklyCountStatusChip(status: h.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.weeklyCountCountedBy(
                  h.counterLabel,
                  weeklyCountTimeLabel(context, h.countedAt),
                ),
                style: theme.textTheme.bodyLarge,
              ),
              if ((h.approvedByName ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(l10n.weeklyCountApprovedBy(h.approvedByName!)),
              ],
              if ((h.rejectionReason ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.weeklyCountRejectionReason(h.rejectionReason!),
                  style: const TextStyle(
                    color: WeeklyCountColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                [
                  l10n.weeklyCountItemsCount(detail.lines.length),
                  if (withSystem)
                    l10n.weeklyCountDifferences(detail.differenceLines.length),
                ].join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    if (!withSystem) {
      // Blind for the counter: only what they counted.
      children.add(_ColumnsHeader(withSystem: false));
      for (final line in detail.lines) {
        children.add(_LineRow(line: line, withSystem: false));
      }
    } else {
      final diffs = detail.differenceLines;
      final same = detail.unchangedLines;
      children.add(_ColumnsHeader(withSystem: true));
      for (final line in diffs) {
        children.add(_LineRow(line: line, withSystem: true));
      }
      if (same.isNotEmpty) {
        children.add(
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: onToggleUnchanged,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n.weeklyCountNoDifference(same.length)),
            trailing: Icon(
              showUnchanged ? Icons.expand_less : Icons.expand_more,
            ),
          ),
        );
        if (showUnchanged) {
          for (final line in same) {
            children.add(_LineRow(line: line, withSystem: true));
          }
        }
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: children,
    );
  }
}

class _ColumnsHeader extends StatelessWidget {
  const _ColumnsHeader({required this.withSystem});

  final bool withSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(l10n.commonItemLabel, style: style)),
          _cell(Text(l10n.weeklyCountColCounted, style: style)),
          if (withSystem) ...[
            _cell(Text(l10n.weeklyCountColSystem, style: style)),
            _cell(Text(l10n.weeklyCountColDifference, style: style)),
          ],
        ],
      ),
    );
  }
}

Widget _cell(Widget child) => SizedBox(width: 64, child: Center(child: child));

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.withSystem});

  final WeeklyCountLine line;
  final bool withSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = line.effectiveDifference;
    final diffColor = weeklyCountDifferenceColor(diff);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                if (line.itemGroup.isNotEmpty || line.stockUom.isNotEmpty)
                  Text(
                    [
                      line.itemGroup,
                      line.stockUom,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          _cell(
            Text(
              weeklyCountQty(line.countedQty),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          if (withSystem) ...[
            _cell(
              Text(
                line.systemQty == null ? '—' : weeklyCountQty(line.systemQty!),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _cell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  diff == null ? '—' : weeklyCountSignedQty(diff),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: diffColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WeeklyCountColors.red,
                      side: const BorderSide(
                        color: WeeklyCountColors.red,
                        width: 1.5,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: busy ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.weeklyCountReject),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: WeeklyCountColors.green,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: busy ? null : onApprove,
                    icon: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(l10n.weeklyCountApprove),
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

/// Reason is required; quick chips fill it in one tap.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quick = [
      l10n.weeklyCountRejectQuickCareful,
      l10n.weeklyCountRejectQuickUnreasonable,
      l10n.weeklyCountRejectQuickSizes,
    ];
    final text = _controller.text.trim();
    return AlertDialog(
      title: Text(l10n.weeklyCountRejectTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in quick)
                  ActionChip(
                    label: Text(q),
                    onPressed: () {
                      _controller.text = q;
                      _controller.selection = TextSelection.collapsed(
                        offset: q.length,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('weekly-count-reject-reason'),
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.weeklyCountRejectHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: WeeklyCountColors.red),
          onPressed: text.isEmpty
              ? null
              : () => Navigator.of(context).pop(text),
          child: Text(l10n.weeklyCountReject),
        ),
      ],
    );
  }
}

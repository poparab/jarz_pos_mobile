import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/network/frappe_error_message.dart';
import '../../data/models/sop.dart';
import '../../state/sop_providers.dart';
import '../widgets/sop_capture_field.dart';
import '../widgets/sop_progress_bar.dart';
import '../widgets/sop_step_card.dart';

/// What the SOP screen is opened with, carried through GoRouter's `extra`.
///
/// A Work Order wins over an item code: it resolves the SOP *version stamped at
/// start*, so an SOP edited mid-batch cannot rewrite the method the batch is
/// being made by.
@immutable
class SopLaunchArgs {
  const SopLaunchArgs({
    this.workOrder,
    this.itemCode,
    this.itemName,
    this.bom,
    this.batches = 1.0,
  });

  final String? workOrder;
  final String? itemCode;
  final String? itemName;
  final String? bom;
  final double batches;

  factory SopLaunchArgs.fromExtra(Object? extra) {
    if (extra is SopLaunchArgs) return extra;
    if (extra is! Map) return const SopLaunchArgs();

    final map = Map<String, dynamic>.from(extra);
    String? str(String key) {
      final value = map[key];
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final rawBatches = map['batches'];
    final batches = rawBatches is num
        ? rawBatches.toDouble()
        : double.tryParse((rawBatches ?? '').toString()) ?? 1.0;

    return SopLaunchArgs(
      workOrder: str('workOrder') ?? str('work_order'),
      itemCode: str('itemCode') ?? str('item_code'),
      itemName: str('itemName') ?? str('item_name'),
      bom: str('bom'),
      batches: batches <= 0 ? 1.0 : batches,
    );
  }

  Map<String, dynamic> toExtra() => <String, dynamic>{
        if (workOrder != null) 'workOrder': workOrder,
        if (itemCode != null) 'itemCode': itemCode,
        if (itemName != null) 'itemName': itemName,
        if (bom != null) 'bom': bom,
        'batches': batches,
      };

  bool get hasWorkOrder => (workOrder ?? '').isNotEmpty;

  /// Identity of this run for [sopExecutionProvider].
  String get executionKey =>
      hasWorkOrder ? workOrder! : (itemCode ?? '').trim();

  bool get isValid => executionKey.isNotEmpty;
}

/// Full-screen work-instruction execution: one step per page.
///
/// Not wrapped in `PhoneLandscapeScope` — unlike the Plan tab this is long
/// prose, and portrait gives it more lines per screen.
class SopExecuteScreen extends ConsumerWidget {
  const SopExecuteScreen({super.key, required this.args});

  final SopLaunchArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (!args.isValid) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sopTitle)),
        body: Center(child: Text(l10n.sopNoSopForItem)),
      );
    }

    final key = args.executionKey;
    final documentAsync = args.hasWorkOrder
        ? ref.watch(sopForWorkOrderProvider(args.workOrder!))
        : ref.watch(
            sopForItemProvider(
              SopRequest(
                itemCode: args.itemCode!,
                bom: args.bom,
                batches: args.batches,
              ),
            ),
          );

    // Watched here (not only inside the runner) so the auto-disposed execution
    // state survives the loading → data transition and the exit gate can see it.
    final execution = ref.watch(sopExecutionProvider(key));
    final hasProgress = execution.currentIndex > 0 || execution.satisfiedCount > 0;

    return PopScope(
      canPop: !hasProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!await _confirmExit(context)) return;
        if (context.mounted) _leave(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (hasProgress && !await _confirmExit(context)) return;
              if (context.mounted) _leave(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.sopTitle),
              if ((args.itemName ?? '').isNotEmpty)
                Text(
                  args.itemName!,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        body: documentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorRetry(
            message: extractFrappeErrorMessage(error, fallback: l10n.commonError),
            onRetry: () {
              if (args.hasWorkOrder) {
                ref.invalidate(sopForWorkOrderProvider(args.workOrder!));
              } else {
                ref.invalidate(
                  sopForItemProvider(
                    SopRequest(
                      itemCode: args.itemCode!,
                      bom: args.bom,
                      batches: args.batches,
                    ),
                  ),
                );
              }
            },
          ),
          data: (document) {
            if (document.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.sopNoSopForItem,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            }
            return _SopRunner(
              document: document,
              executionKey: key,
              workOrder: args.hasWorkOrder ? args.workOrder : null,
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.sopExitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Pops past the [PopScope] gate, or falls back to the manufacturing screen
  /// when the SOP was reached by `go` and there is nothing on the stack.
  void _leave(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      GoRouter.of(context).go(AppRoutes.manufacturing);
    }
  }
}

/// Drives the pager once the document has loaded.
class _SopRunner extends ConsumerStatefulWidget {
  const _SopRunner({
    required this.document,
    required this.executionKey,
    required this.workOrder,
  });

  final SopDocument document;
  final String executionKey;
  final String? workOrder;

  @override
  ConsumerState<_SopRunner> createState() => _SopRunnerState();
}

class _SopRunnerState extends ConsumerState<_SopRunner> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Post-frame: Riverpod forbids modifying a provider inside a widget
    // life-cycle, and binding the steps IS a modification.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }

  @override
  void didUpdateWidget(covariant _SopRunner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _bind() {
    if (!mounted) return;
    ref
        .read(sopExecutionProvider(widget.executionKey).notifier)
        .bindSteps(widget.document.steps);
  }

  SopExecutionNotifier get _notifier =>
      ref.read(sopExecutionProvider(widget.executionKey).notifier);

  void _animateTo(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final document = widget.document;
    final execution = ref.watch(sopExecutionProvider(widget.executionKey));

    if (execution.steps.length != document.steps.length) {
      // One frame, between first build and the post-frame bind.
      WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _SopHeader(document: document, execution: execution),
        if (document.hasUnresolvedTokens)
          _UnresolvedTokensBanner(tokens: document.unresolvedTokens),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SopProgressBar(
            satisfied: execution.satisfiedFlags,
            currentIndex: execution.currentIndex,
            onStepTap: (index) {
              if (_notifier.goTo(index)) _animateTo(index);
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            // Swiping is disabled on purpose: the gate below is the only way
            // forward, and a swipeable pager would walk straight past it.
            physics: const NeverScrollableScrollPhysics(),
            itemCount: execution.steps.length,
            itemBuilder: (context, index) {
              final step = execution.steps[index];
              final progress = execution.progressAt(index);
              return SopStepCard(
                step: step,
                stepIndex: index,
                progress: progress,
                onConfirmedChanged: (value) =>
                    _notifier.setConfirmed(index, value),
                captureField: step.needsCapture
                    ? SopCaptureField(
                        // Rebuilt from scratch when the step changes so the
                        // text field never shows the previous step's reading.
                        key: ValueKey('sop-capture-$index'),
                        step: step,
                        progress: progress,
                        workOrder: widget.workOrder,
                        onValueCaptured: (value) =>
                            _notifier.recordValue(index, value),
                        onPhotoCaptured: ({String? fileUrl, String? localPath}) =>
                            _notifier.recordPhoto(
                          index,
                          fileUrl: fileUrl,
                          localPath: localPath,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: execution.isOnFirstStep
                        ? null
                        : () {
                            _notifier.previous();
                            _animateTo(execution.currentIndex - 1);
                          },
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(l10n.sopPrevious),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: execution.isOnLastStep
                      ? FilledButton.icon(
                          onPressed: execution.isComplete
                              ? () => _finish(context)
                              : null,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(l10n.sopFinishExecution),
                        )
                      : FilledButton.icon(
                          onPressed: execution.canAdvance
                              ? () {
                                  if (_notifier.next()) {
                                    _animateTo(execution.currentIndex + 1);
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: Text(l10n.sopNext),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _finish(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      GoRouter.of(context).go(AppRoutes.manufacturing);
    }
  }
}

class _SopHeader extends StatelessWidget {
  const _SopHeader({required this.document, required this.execution});

  final SopDocument document;
  final SopExecutionState execution;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chips = <String>[
      if (document.batches > 0)
        l10n.sopScaledFor(formatSopNumber(document.batches)),
      if (document.version > 0) l10n.sopVersionLabel(document.version),
      if (document.totalDurationMins > 0)
        l10n.sopTotalDuration(formatSopNumber(document.totalDurationMins)),
      if (document.yieldPercent > 0)
        l10n.sopExpectedYield(formatSopNumber(document.yieldPercent)),
      if ((document.equipment ?? '').trim().isNotEmpty)
        '${l10n.sopEquipment}: ${document.equipment!.trim()}',
    ];

    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sopStepOf(execution.currentIndex + 1, execution.total),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              chips.join('  ·  '),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// A `{{item:CODE}}` the server could not resolve.
///
/// Loud on purpose: a broken reference in an instruction reads as a normal
/// sentence with a quantity silently missing, and nobody notices until the
/// wrong thing has been made.
class _UnresolvedTokensBanner extends StatelessWidget {
  const _UnresolvedTokensBanner({required this.tokens});

  final List<String> tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sopUnresolvedTokens(tokens.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tokens.join(', '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
              ],
            ),
          ),
        ],
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
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

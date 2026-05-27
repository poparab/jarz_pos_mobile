import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../auth/state/login_notifier.dart';
import '../../pos/presentation/widgets/courier_balances_dialog.dart';
import '../models/shift_models.dart';
import '../state/shift_notifier.dart';

String _normalizeShiftError(String error) {
  return error.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
}

String _localizedShiftError(BuildContext context, String error) {
  final l10n = context.l10n;
  final message = _normalizeShiftError(error);

  switch (message) {
    case 'Unexpected start shift response':
      return l10n.shiftUnexpectedStartResponse;
    case 'Unexpected shift summary response':
      return l10n.shiftUnexpectedSummaryResponse;
    case 'Unexpected end shift response':
      return l10n.shiftUnexpectedEndResponse;
    default:
      if (message.isEmpty) {
        return l10n.commonError;
      }
      return l10n.commonErrorWithDetails(message);
  }
}

double? _parseShiftAmount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final amount = double.tryParse(trimmed);
  if (amount == null || amount.isNaN || amount.isInfinite || amount < 0) {
    return null;
  }
  return amount;
}

String? _validateShiftAmount(BuildContext context, String text) {
  final l10n = context.l10n;
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return l10n.shiftCashCountRequired;
  }

  final amount = double.tryParse(trimmed);
  if (amount == null || amount.isNaN || amount.isInfinite) {
    return l10n.shiftCashCountInvalid;
  }

  if (amount < 0) {
    return l10n.shiftCashCountNegative;
  }

  return null;
}

class ShiftEndScreen extends ConsumerStatefulWidget {
  const ShiftEndScreen({super.key});

  @override
  ConsumerState<ShiftEndScreen> createState() => _ShiftEndScreenState();
}

class _ShiftEndScreenState extends ConsumerState<ShiftEndScreen> {
  final Map<String, TextEditingController> _controllers = {};
  ShiftSummary? _endResult;
  String? _validationError;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shiftState = ref.watch(shiftNotifierProvider);
    final activeShiftAsync = ref.watch(activeShiftProvider);

    // Show post-close summary if shift was just ended
    if (_endResult != null) {
      return _buildClosedSummary(context, _endResult!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftEndTitle)),
      body: activeShiftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l10n.shiftLoadActiveFailed(_normalizeShiftError(e.toString()))),
        ),
        data: (activeShift) {
          if (activeShift == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.shiftNoActive),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.pos),
                    child: Text(l10n.shiftBackToPos),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder(
            future: ref.read(shiftNotifierProvider.notifier).getCurrentShiftSummary(openingEntry: activeShift.name),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(_localizedShiftError(context, snapshot.error.toString())),
                );
              }

              final summary = snapshot.data;
              if (summary == null) {
                return Center(child: Text(l10n.shiftSummaryLoadFailed));
              }

              return _buildPreCloseView(context, summary, shiftState);
            },
          );
        },
      ),
    );
  }

  // ── Pre-close view: invoices table + closing input ──

  Widget _buildPreCloseView(BuildContext context, ShiftSummary summary, ShiftState shiftState) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final courierCloseBlock = summary.courierCloseBlock;
    final hasCourierCloseBlock = courierCloseBlock?.blocked == true;
    final displayError = _validationError ??
        (shiftState.error != null ? _localizedShiftError(context, shiftState.error!) : null);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.shiftLabel(summary.openingEntry), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _infoRow(l10n.shiftInvoices(summary.invoiceCount), Icons.receipt_long),
          const Divider(height: 24),

          Expanded(
            child: ListView(
              children: [
                if (hasCourierCloseBlock) ...[
                  _buildCourierCloseBlockCard(context, courierCloseBlock!),
                  const SizedBox(height: 14),
                ],
                Text(l10n.shiftClosingPrompt, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.shiftBlindCountHint,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                ...summary.paymentReconciliation.map((row) {
                  final controller = _controllers.putIfAbsent(
                    row.modeOfPayment,
                    () => TextEditingController(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.modeOfPayment),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) {
                            if (_validationError != null) {
                              setState(() {
                                _validationError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: l10n.shiftCountedClosingAmount,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          if (displayError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                displayError,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: shiftState.isLoading ? null : () => context.go(AppRoutes.pos),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.shiftBackToPos),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: shiftState.isLoading
                      ? null
                      : hasCourierCloseBlock
                      ? () => _handleCourierSettlementReview(summary)
                      : () => _handleEndShift(summary),
                  icon: Icon(
                    hasCourierCloseBlock ? Icons.local_shipping_outlined : Icons.task_alt_outlined,
                  ),
                  label: Text(
                    hasCourierCloseBlock ? l10n.shiftCourierReviewButton : l10n.shiftEndButton,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Post-close summary ──

  Widget _buildClosedSummary(BuildContext context, ShiftSummary result) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftClosedSummaryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.shiftEndedSuccess, style: theme.textTheme.titleMedium?.copyWith(color: Colors.green)),
            const SizedBox(height: 12),
            if (result.closingEntry != null)
              _infoRow('${l10n.shiftClosingEntry}: ${result.closingEntry}', Icons.check_circle),
            _infoRow(l10n.shiftInvoices(result.invoiceCount), Icons.receipt_long),
            if (result.journalEntry != null && result.journalEntry!.isNotEmpty && result.journalEntry != 'null')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.shiftJournalCreated}: ${result.journalEntry}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ...result.paymentReconciliation.map((row) {
                    final diff = row.difference;
                    final diffColor = diff == 0
                        ? theme.colorScheme.onSurface
                        : (diff > 0 ? Colors.green : theme.colorScheme.error);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.modeOfPayment,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (result.varianceVisible)
                            Text(
                              l10n.shiftExpectedAmount(
                                row.expectedAmount.toStringAsFixed(2),
                              ),
                            ),
                          Text(
                            '${l10n.shiftCountedClosingAmount}: ${row.closingAmount.toStringAsFixed(2)}',
                          ),
                          if (result.varianceVisible)
                            Text(
                              '${l10n.shiftDifference}: ${diff.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: diffColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  ref.invalidate(activeShiftProvider);
                  await ref.read(loginNotifierProvider.notifier).logout();
                  if (!context.mounted) return;
                  context.go(AppRoutes.login);
                },
                child: Text(l10n.shiftLogout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _infoRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildCourierCloseBlockCard(
    BuildContext context,
    ShiftCourierCloseBlock block,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final extraCouriers = block.partyCount - block.parties.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.local_shipping_outlined, color: Colors.orange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shiftCourierBlockTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.shiftCourierBlockBody(
                        block.transactionCount,
                        block.partyCount,
                        block.invoiceCount,
                        block.posProfile,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.shiftCourierBlockHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (block.parties.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...block.parties.map(
              (party) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.shiftCourierBlockPartySummary(
                          party.displayName.isNotEmpty ? party.displayName : party.party,
                          party.transactionCount,
                          party.invoiceCount,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.shiftCourierBlockNetBalance(
                        party.netBalance.toStringAsFixed(2),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (extraCouriers > 0)
            Text(
              l10n.shiftCourierBlockMore(extraCouriers),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCourierSettlementReview(ShiftSummary summary) async {
    final activeBlock = summary.courierCloseBlock?.parties ?? const <ShiftCourierCloseParty>[];
    final shouldFilterDialog = summary.courierCloseBlock != null &&
        summary.courierCloseBlock!.partyCount == activeBlock.length;

    await showCourierBalancesDialog(
      context,
      allowedPartyKeys: shouldFilterDialog
          ? activeBlock.map((party) => '${party.partyType}::${party.party}').toSet()
          : null,
    );
    if (!mounted) return;

    ref.read(shiftNotifierProvider.notifier).clearError();
    setState(() {
      _validationError = null;
    });
  }

  Future<void> _handleEndShift(ShiftSummary summary) async {
    final balances = <Map<String, dynamic>>[];
    for (final row in summary.paymentReconciliation) {
      final text = _controllers[row.modeOfPayment]?.text ?? '';
      final validationError = _validateShiftAmount(context, text);
      if (validationError != null) {
        setState(() {
          _validationError = validationError;
        });
        return;
      }

      balances.add(
        {
          'mode_of_payment': row.modeOfPayment,
          'closing_amount': _parseShiftAmount(text)!,
        },
      );
    }

    final result = await ref
        .read(shiftNotifierProvider.notifier)
        .endShift(
          closingBalances: balances,
          openingEntry: summary.openingEntry,
        );

    if (!mounted) return;
    if (result != null) {
      ref.invalidate(activeShiftProvider);
      setState(() {
        _validationError = null;
        _endResult = result;
      });
    }
  }
}

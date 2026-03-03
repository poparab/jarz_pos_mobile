import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization_extensions.dart';
import '../state/shift_notifier.dart';

class ShiftEndScreen extends ConsumerStatefulWidget {
  const ShiftEndScreen({super.key});

  @override
  ConsumerState<ShiftEndScreen> createState() => _ShiftEndScreenState();
}

class _ShiftEndScreenState extends ConsumerState<ShiftEndScreen> {
  final Map<String, TextEditingController> _controllers = {};

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftEndTitle)),
      body: activeShiftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load active shift: $e')),
        data: (activeShift) {
          if (activeShift == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.shiftNoActive),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/pos'),
                    child: Text(l10n.shiftBackToPos),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder(
            future: ref.read(shiftNotifierProvider.notifier).getCurrentShiftSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final summary = snapshot.data;
              if (summary == null) {
                return const Center(child: Text('Unable to load shift summary.'));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shift: ${summary.openingEntry}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(l10n.shiftInvoices(summary.invoiceCount)),
                    Text(l10n.shiftGrandTotal(summary.grandTotal.toStringAsFixed(2))),
                    const SizedBox(height: 12),
                    Text(l10n.shiftClosingPrompt),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: summary.paymentReconciliation.length,
                        itemBuilder: (context, index) {
                          final row = summary.paymentReconciliation[index];
                          final controller = _controllers.putIfAbsent(
                            row.modeOfPayment,
                            () => TextEditingController(text: row.expectedAmount.toStringAsFixed(2)),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${row.modeOfPayment} (${l10n.shiftExpectedAmount(row.expectedAmount.toStringAsFixed(2))})'),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: l10n.shiftClosingAmountLabel,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (shiftState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          shiftState.error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: shiftState.isLoading
                            ? null
                            : () async {
                                final router = GoRouter.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                final balances = summary.paymentReconciliation.map((row) {
                                  final text = _controllers[row.modeOfPayment]?.text ?? '0';
                                  final amount = double.tryParse(text) ?? 0;
                                  return {
                                    'mode_of_payment': row.modeOfPayment,
                                    'closing_amount': amount,
                                  };
                                }).toList();

                                final result = await ref
                                    .read(shiftNotifierProvider.notifier)
                                    .endShift(closingBalances: balances);

                                if (!mounted) return;
                                if (result != null) {
                                  ref.invalidate(activeShiftProvider);
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(l10n.shiftEndedSuccess)),
                                  );
                                  router.go('/pos');
                                }
                              },
                        child: Text(l10n.shiftEndButton),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

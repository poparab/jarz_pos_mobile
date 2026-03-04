import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../pos/state/pos_notifier.dart';
import '../state/shift_notifier.dart';

class ShiftStartScreen extends ConsumerStatefulWidget {
  const ShiftStartScreen({super.key});

  @override
  ConsumerState<ShiftStartScreen> createState() => _ShiftStartScreenState();
}

class _ShiftStartScreenState extends ConsumerState<ShiftStartScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _requestedProfile;
  double? _lastSystemBalance;

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
    final posState = ref.watch(posNotifierProvider);
    final shiftState = ref.watch(shiftNotifierProvider);

    final selectedFromState = (posState.selectedProfile?['name'] ?? '').toString();
    final posProfile = selectedFromState.isNotEmpty ? selectedFromState : null;

    if (posProfile == null && !posState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/pos');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (posProfile != null &&
        !shiftState.isLoading &&
        (_requestedProfile != posProfile || shiftState.paymentMethodsProfile != posProfile)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestedProfile = posProfile;
        ref.read(shiftNotifierProvider.notifier).loadPaymentMethods(posProfile);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftStartTitle)),
      body: posState.isLoading || (shiftState.isLoading && shiftState.paymentMethods.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('POS Profile: $posProfile', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(l10n.shiftOpeningPrompt),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (shiftState.paymentMethods.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final row = shiftState.paymentMethods.first;
                        final mode = (row['mode_of_payment'] ?? '').toString();
                        final account = (row['account'] ?? '').toString();
                        final currentBalance = ((row['current_balance'] as num?)?.toDouble() ??
                                (row['default_amount'] as num?)?.toDouble() ??
                                0)
                            .toDouble();

                        final controller = _controllers.putIfAbsent(
                          'single_account_opening',
                          () => TextEditingController(
                            text: currentBalance.toStringAsFixed(2),
                          ),
                        );

                        if (_lastSystemBalance == null || _lastSystemBalance != currentBalance) {
                          _lastSystemBalance = currentBalance;
                          controller.text = currentBalance.toStringAsFixed(2);
                        }

                        final confirmed = double.tryParse(controller.text) ?? 0;
                        final difference = confirmed - currentBalance;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mode, style: Theme.of(context).textTheme.titleSmall),
                            if (account.isNotEmpty) Text('Account: $account'),
                            Text('System Balance: ${currentBalance.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Confirmed Opening Amount',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Difference: ${difference.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: difference == 0
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
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
                              if (shiftState.paymentMethods.isEmpty) return;
                              final row = shiftState.paymentMethods.first;
                              final mode = (row['mode_of_payment'] ?? '').toString();
                              final account = (row['account'] ?? '').toString();
                              final systemBalance = ((row['current_balance'] as num?)?.toDouble() ??
                                      (row['default_amount'] as num?)?.toDouble() ??
                                      0)
                                  .toDouble();
                              final confirmedText = _controllers['single_account_opening']?.text ?? '0';
                              final confirmedAmount = double.tryParse(confirmedText) ?? 0;
                              final balances = [
                                {
                                  'mode_of_payment': mode,
                                  'account': account,
                                  'system_balance': systemBalance,
                                  'opening_amount': confirmedAmount,
                                  'difference': confirmedAmount - systemBalance,
                                }
                              ];

                              final openingEntry = await ref
                                  .read(shiftNotifierProvider.notifier)
                                  .startShift(posProfile: posProfile!, openingBalances: balances);

                              if (!mounted) return;
                              if (openingEntry != null) {
                                ref.invalidate(activeShiftProvider);
                                router.go('/kanban');
                              }
                            },
                      child: Text(l10n.shiftStartButton),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

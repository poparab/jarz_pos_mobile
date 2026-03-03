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
    final profile = posState.selectedProfile;

    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/pos');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final posProfile = (profile['name'] ?? '').toString();

    if (shiftState.paymentMethods.isEmpty && !shiftState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shiftNotifierProvider.notifier).loadPaymentMethods(posProfile);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftStartTitle)),
      body: shiftState.isLoading && shiftState.paymentMethods.isEmpty
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
                    child: ListView.builder(
                      itemCount: shiftState.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final row = shiftState.paymentMethods[index];
                        final mode = (row['mode_of_payment'] ?? '').toString();
                        final controller = _controllers.putIfAbsent(
                          mode,
                          () => TextEditingController(
                            text: ((row['default_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: mode,
                              border: const OutlineInputBorder(),
                            ),
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
                              final balances = shiftState.paymentMethods.map((row) {
                                final mode = (row['mode_of_payment'] ?? '').toString();
                                final text = _controllers[mode]?.text ?? '0';
                                final amount = double.tryParse(text) ?? 0;
                                return {
                                  'mode_of_payment': mode,
                                  'opening_amount': amount,
                                };
                              }).toList();

                              final openingEntry = await ref
                                  .read(shiftNotifierProvider.notifier)
                                  .startShift(posProfile: posProfile, openingBalances: balances);

                              if (!mounted) return;
                              if (openingEntry != null) {
                                ref.invalidate(activeShiftProvider);
                                router.go('/pos');
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

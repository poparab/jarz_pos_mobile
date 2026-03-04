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
  String? _selectedProfileName;

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

    if (posState.profiles.isEmpty && !posState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      });
    }

    final selectedFromState = (posState.selectedProfile?['name'] ?? '').toString();
    final posProfile = (_selectedProfileName?.isNotEmpty == true)
        ? _selectedProfileName!
        : (selectedFromState.isNotEmpty ? selectedFromState : null);
    final profileOptions = posState.profiles
      .map((profile) => (profile['name'] ?? '').toString())
      .where((name) => name.isNotEmpty)
      .toList();
    final dropdownValue = (posProfile != null && profileOptions.contains(posProfile))
      ? posProfile
      : null;

    if (posProfile != null &&
        !shiftState.isLoading &&
        (shiftState.paymentMethods.isEmpty || shiftState.paymentMethodsProfile != posProfile)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                  DropdownButtonFormField<String>(
                    initialValue: dropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'POS Profile',
                      border: OutlineInputBorder(),
                    ),
                    items: posState.profiles
                        .map(
                          (profile) => DropdownMenuItem<String>(
                            value: (profile['name'] ?? '').toString(),
                            child: Text((profile['name'] ?? '').toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null || value.isEmpty) return;
                      final selected = posState.profiles.firstWhere(
                        (profile) => (profile['name'] ?? '').toString() == value,
                      );
                      setState(() {
                        _selectedProfileName = value;
                      });
                      for (final c in _controllers.values) {
                        c.dispose();
                      }
                      _controllers.clear();
                      await ref.read(posNotifierProvider.notifier).selectProfile(selected);
                      if (!mounted) return;
                      await ref.read(shiftNotifierProvider.notifier).loadPaymentMethods(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.shiftOpeningPrompt),
                  const SizedBox(height: 12),
                  if (posProfile == null)
                    const Text('Select a POS Profile to load branch account balances.'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: posProfile == null ? 0 : shiftState.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final row = shiftState.paymentMethods[index];
                        final mode = (row['mode_of_payment'] ?? '').toString();
                        final account = (row['account'] ?? '').toString();
                        final currentBalance = ((row['current_balance'] as num?)?.toDouble() ??
                                (row['default_amount'] as num?)?.toDouble() ??
                                0)
                            .toDouble();
                        final controller = _controllers.putIfAbsent(
                          mode,
                          () => TextEditingController(
                            text: currentBalance.toStringAsFixed(2),
                          ),
                        );
                        final confirmed = double.tryParse(controller.text) ?? 0;
                        final difference = confirmed - currentBalance;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mode, style: Theme.of(context).textTheme.titleSmall),
                              if (account.isNotEmpty)
                                Text('Branch Account: $account'),
                              Text('System Balance: ${currentBalance.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: controller,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Confirmed Opening Amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Difference: ${difference.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: difference == 0
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.error,
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
                      onPressed: shiftState.isLoading || posProfile == null
                          ? null
                          : () async {
                              final router = GoRouter.of(context);
                              final balances = shiftState.paymentMethods.map((row) {
                                final mode = (row['mode_of_payment'] ?? '').toString();
                                final account = (row['account'] ?? '').toString();
                                final systemBalance = ((row['current_balance'] as num?)?.toDouble() ??
                                        (row['default_amount'] as num?)?.toDouble() ??
                                        0)
                                    .toDouble();
                                final text = _controllers[mode]?.text ?? '0';
                                final confirmedAmount = double.tryParse(text) ?? 0;
                                return {
                                  'mode_of_payment': mode,
                                  'account': account,
                                  'system_balance': systemBalance,
                                  'opening_amount': confirmedAmount,
                                  'difference': confirmedAmount - systemBalance,
                                };
                              }).toList();

                              final openingEntry = await ref
                                  .read(shiftNotifierProvider.notifier)
                                  .startShift(posProfile: posProfile, openingBalances: balances);

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

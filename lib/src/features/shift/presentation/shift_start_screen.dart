import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../pos/state/pos_notifier.dart';
import '../models/shift_models.dart';
import '../state/shift_notifier.dart';

bool _isShiftOwnedByCurrentUser(ShiftEntry shift, UserRoles? roles) {
  if (roles == null) return true;

  final currentUser = roles.user.trim().toLowerCase();
  final currentEmployee = (roles.employee ?? '').trim().toLowerCase();
  final currentName = (roles.fullName ?? roles.employeeName ?? '').trim().toLowerCase();
  final shiftUser = shift.openedByUser.trim().toLowerCase();
  final shiftName = shift.openedByName.trim().toLowerCase();

  if (shiftUser.isNotEmpty) {
    if (shiftUser == currentUser) return true;
    if (currentEmployee.isNotEmpty && shiftUser == currentEmployee) return true;
  }

  if (shiftName.isNotEmpty && currentName.isNotEmpty && shiftName == currentName) {
    return true;
  }

  return false;
}

String _shiftOwnerLabel(ShiftEntry shift) {
  if (shift.openedByName.trim().isNotEmpty) return shift.openedByName.trim();
  if (shift.openedByUser.trim().isNotEmpty) return shift.openedByUser.trim();
  return 'Unknown user';
}

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
    final activeShift = ref.watch(activeShiftProvider).valueOrNull;
    final userRoles = ref.watch(userRolesFutureProvider).valueOrNull;

    final selectedFromState = (posState.selectedProfile?['name'] ?? '').toString();
    final posProfile = selectedFromState.isNotEmpty ? selectedFromState : null;
    final hasBlockingOpenShift =
      activeShift != null &&
      posProfile != null &&
      activeShift.posProfile == posProfile &&
      !_isShiftOwnedByCurrentUser(activeShift, userRoles);

    if (posProfile == null && !posState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(AppRoutes.pos);
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

    if (hasBlockingOpenShift) {
      final opener = _shiftOwnerLabel(activeShift);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shiftStartTitle)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.shiftAlreadyOpenByAnotherTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(l10n.shiftAlreadyOpenByAnotherBody(posProfile, opener)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.pos),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.shiftBackToPos),
              ),
            ],
          ),
        ),
      );
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
                  Text(
                    l10n.shiftPosProfile(posProfile ?? ''),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                            if (account.isNotEmpty) Text(l10n.shiftAccount(account)),
                            Text(l10n.shiftSystemBalance(currentBalance.toStringAsFixed(2))),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: l10n.shiftConfirmedOpeningAmount,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.shiftDifferenceAmount(difference.toStringAsFixed(2)),
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
                                router.go(AppRoutes.pos);
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

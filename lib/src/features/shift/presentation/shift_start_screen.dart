import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../auth/state/login_notifier.dart';
import '../../pos/state/pos_notifier.dart';
import '../models/shift_models.dart';
import '../state/shift_notifier.dart';

String _shiftOwnerLabel(ShiftEntry shift) {
  if (shift.openedByName.trim().isNotEmpty) return shift.openedByName.trim();
  if (shift.openedByUser.trim().isNotEmpty) return shift.openedByUser.trim();
  return 'Unknown user';
}

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

class ShiftStartScreen extends ConsumerStatefulWidget {
  const ShiftStartScreen({super.key});

  @override
  ConsumerState<ShiftStartScreen> createState() => _ShiftStartScreenState();
}

class _ShiftStartScreenState extends ConsumerState<ShiftStartScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _requestedProfile;
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
    final posState = ref.watch(posNotifierProvider);
    final shiftState = ref.watch(shiftNotifierProvider);
    final activeShiftAsync = ref.watch(activeShiftProvider);
    final activeShift = activeShiftAsync.valueOrNull;
    final displayError = _validationError ??
      (shiftState.error != null ? _localizedShiftError(context, shiftState.error!) : null);

    final selectedFromState = (posState.selectedProfile?['name'] ?? '').toString();
    final posProfile = selectedFromState.isNotEmpty ? selectedFromState : null;

    // While shift data is still loading, show spinner
    if (activeShiftAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasActiveShiftForProfile =
        activeShift != null &&
        posProfile != null &&
        activeShift.posProfile == posProfile;

    // Same user owns the active shift on THIS profile → auto-redirect to POS
    // (router handles this too, but guard here to avoid any flicker).
    if (hasActiveShiftForProfile && activeShift.isCurrentUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.pos);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Different user owns the active shift on THIS profile → blocking message.
    final hasBlockingOpenShift = hasActiveShiftForProfile && !activeShift.isCurrentUser;

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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.block, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.shiftAlreadyOpenByAnotherTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.shiftAlreadyOpenByAnotherBody(posProfile, opener),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(activeShiftProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.shiftRefresh),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(loginNotifierProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.shiftLogout),
                  ),
                ],
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
                  const SizedBox(height: 4),
                  Text(
                    l10n.shiftBlindCountHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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

                        final controller = _controllers.putIfAbsent(
                          'single_account_opening',
                          () => TextEditingController(),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mode, style: Theme.of(context).textTheme.titleSmall),
                            if (account.isNotEmpty) Text(l10n.shiftAccount(account)),
                            const SizedBox(height: 8),
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
                                labelText: l10n.shiftCountedOpeningAmount,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (displayError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        displayError,
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
                              final confirmedText =
                                  _controllers['single_account_opening']?.text ?? '';
                              final validationError = _validateShiftAmount(
                                context,
                                confirmedText,
                              );
                              if (validationError != null) {
                                setState(() {
                                  _validationError = validationError;
                                });
                                return;
                              }

                              final confirmedAmount = _parseShiftAmount(confirmedText)!;
                              final balances = [
                                {
                                  'mode_of_payment': mode,
                                  'account': account,
                                  'opening_amount': confirmedAmount,
                                }
                              ];

                              final openingEntry = await ref
                                  .read(shiftNotifierProvider.notifier)
                                  .startShift(posProfile: posProfile!, openingBalances: balances);

                              if (!mounted) return;
                              if (openingEntry != null) {
                                setState(() {
                                  _validationError = null;
                                });
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

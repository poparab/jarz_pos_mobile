import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../../../core/network/user_service.dart';
import '../../pos/data/models/staff_customer_models.dart';
import '../../pos/data/repositories/staff_customer_repository.dart';

/// "Create missing staff customers" on the Employee Ledger.
///
/// Employee-purpose orders only reach the ledger (and payroll) when the order's
/// Customer is linked to an Employee. This backfills that link for every
/// active employee in one run, so the rows the ledger lists as "No employee
/// record" stop accumulating. Manager tier only, like the endpoint.
class SyncStaffCustomersAction extends ConsumerStatefulWidget {
  const SyncStaffCustomersAction({super.key, this.onSynced});

  /// Called after a successful run, so the ledger can refetch.
  final VoidCallback? onSynced;

  @override
  ConsumerState<SyncStaffCustomersAction> createState() =>
      _SyncStaffCustomersActionState();
}

class _SyncStaffCustomersActionState
    extends ConsumerState<SyncStaffCustomersAction> {
  bool _running = false;

  Future<void> _run() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final repository = ref.read(staffCustomerRepositoryProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.managerStaffCustomersSyncConfirmTitle),
        content: Text(l10n.managerStaffCustomersSyncConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('sync-staff-customers-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.managerStaffCustomersSyncConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _running = true);
    StaffCustomerSyncResult result;
    try {
      result = await repository.syncStaffCustomers();
    } catch (error) {
      if (!mounted) return;
      setState(() => _running = false);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            userErrorMessageFor(
              l10n,
              error,
              fallback: l10n.managerStaffCustomersSyncFailed,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _running = false);
    widget.onSynced?.call();
    await showDialog<void>(
      context: context,
      builder: (_) => StaffCustomersSyncResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(canAccessManagerDashboardRoleProvider)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton.icon(
        key: const ValueKey('sync-staff-customers'),
        onPressed: _running ? null : _run,
        icon: _running
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add_alt_1_outlined),
        label: Text(
          _running
              ? l10n.managerStaffCustomersSyncRunning
              : l10n.managerStaffCustomersSyncAction,
        ),
      ),
    );
  }
}

/// What one run did: counts per bucket, then every employee that still needs a
/// human (skipped, or matched by more than one customer).
class StaffCustomersSyncResultDialog extends StatelessWidget {
  const StaffCustomersSyncResultDialog({super.key, required this.result});

  final StaffCustomerSyncResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final nothingToDo =
        result.created.isEmpty &&
        result.adopted.isEmpty &&
        result.skipped.isEmpty &&
        result.conflicts.isEmpty;

    return AlertDialog(
      title: Text(l10n.managerStaffCustomersSyncResultTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nothingToDo) ...[
              Text(l10n.managerStaffCustomersSyncNothingToDo),
              const SizedBox(height: 8),
            ],
            Text(l10n.managerStaffCustomersSyncCreated(result.created.length)),
            Text(l10n.managerStaffCustomersSyncAdopted(result.adopted.length)),
            Text(
              l10n.managerStaffCustomersSyncExisting(result.existing.length),
            ),
            if (result.skipped.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.managerStaffCustomersSyncSkipped(result.skipped.length),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              for (final entry in result.skipped)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    entry.reason.isEmpty
                        ? entry.displayName
                        : '${entry.displayName} — ${entry.reason}',
                  ),
                ),
            ],
            if (result.conflicts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.managerStaffCustomersSyncConflicts(
                  result.conflicts.length,
                ),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.managerStaffCustomersSyncConflictsHint,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              for (final entry in result.conflicts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.customers.isNotEmpty)
                        Text(
                          l10n.managerStaffCustomersSyncMatchingCustomers(
                            entry.customers.join(', '),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

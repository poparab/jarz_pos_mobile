import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../models/user_admin_models.dart';
import '../../state/user_admin_providers.dart';
import 'user_admin_widgets.dart';

/// Search active employees and pick one. Pops the [UserAdminEmployee], or null.
///
/// An employee already linked to a different account is still offered - the
/// manager may be moving the link - but says whose it is.
class EmployeePickerDialog extends ConsumerStatefulWidget {
  const EmployeePickerDialog({super.key, this.currentUser});

  /// The account being edited; null when creating.
  final String? currentUser;

  @override
  ConsumerState<EmployeePickerDialog> createState() =>
      _EmployeePickerDialogState();
}

class _EmployeePickerDialogState extends ConsumerState<EmployeePickerDialog> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final results = ref.watch(userAdminEmployeesProvider(_query));

    Widget list = results.when(
      skipLoadingOnReload: true,
      data: (employees) {
        if (employees.isEmpty) {
          return UserAdminMessage(
            icon: Icons.person_off_outlined,
            message: l10n.userAdminEmployeeNoResults,
          );
        }
        return ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final e = employees[index];
            final elsewhere = e.linkedElsewhere(widget.currentUser);
            return ListTile(
              leading: Icon(
                elsewhere ? Icons.link : Icons.badge_outlined,
                color: elsewhere
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary,
              ),
              title: Text(e.displayName),
              subtitle: Text(
                [
                  e.name,
                  if (e.branch != null) e.branch!,
                  if (elsewhere) l10n.userAdminEmployeeLinkedTo(e.userId!),
                ].join(' · '),
              ),
              onTap: () => Navigator.of(context).pop(e),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => UserAdminErrorPanel(
        error: error,
        onRetry: () => ref.invalidate(userAdminEmployeesProvider(_query)),
      ),
    );

    return AlertDialog(
      title: Text(l10n.userAdminSectionEmployee),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.userAdminEmployeeSearchHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onChanged,
            ),
            const SizedBox(height: 8),
            Expanded(child: list),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}

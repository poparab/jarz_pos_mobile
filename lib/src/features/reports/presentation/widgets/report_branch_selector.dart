import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../state/reports_providers.dart';

/// Dropdown bound to the shared [reportBranchProvider]: "All branches" plus
/// every branch (POS Profile) from [reportBranchesProvider].
///
/// While the list loads, or if it fails, only "All branches" is offered
/// (plus the current selection, so a chosen branch never vanishes).
class ReportBranchSelector extends ConsumerWidget {
  /// Optional override of the label above the field.
  final String? label;

  const ReportBranchSelector({super.key, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(reportBranchProvider);
    final branchesAsync = ref.watch(reportBranchesProvider);
    final names = <String>[
      for (final b in branchesAsync.valueOrNull ?? const [])
        if (b.name.isNotEmpty) b.name,
    ];
    if (selected != null && selected.isNotEmpty && !names.contains(selected)) {
      names.insert(0, selected);
    }

    return DropdownButtonFormField<String?>(
      // Re-key on the selection so an external change (another screen) is
      // reflected; `initialValue` is only read on creation.
      key: ValueKey<String?>('report-branch-$selected'),
      initialValue: (selected == null || selected.isEmpty) ? null : selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label ?? l10n.rptBranchLabel,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 12),
        prefixIcon: const Icon(Icons.storefront_outlined, size: 18),
        suffixIcon: branchesAsync.isLoading
            ? const Padding(
                padding: EdgeInsetsDirectional.all(12),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.rptAllBranches, overflow: TextOverflow.ellipsis),
        ),
        for (final n in names)
          DropdownMenuItem<String?>(
            value: n,
            child: Text(n, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) => ref.read(reportBranchProvider.notifier).state =
          (v == null || v.isEmpty) ? null : v,
    );
  }
}

import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';

/// Shared dialog for filtering by POS branches (profiles).
/// - profiles: List of maps each containing at least 'name' and optionally 'title'
/// - initiallySelected: Set of profile names; empty set means "All"
/// Returns: a set of profile names (String); empty set means "All".
class BranchFilterDialog extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final Set<String> initiallySelected;
  final String title;

  const BranchFilterDialog({
    super.key,
    required this.profiles,
    required this.initiallySelected,
  this.title = '',
  });

  @override
  State<BranchFilterDialog> createState() => _BranchFilterDialogState();
}

class _BranchFilterDialogState extends State<BranchFilterDialog> {
  late Set<String> _selected;
  bool _all = false;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initiallySelected);
    _all = _selected.isEmpty; // empty -> All
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double dialogHeight = (screenSize.height * 0.6).clamp(260.0, 420.0);
    final double dialogWidth = (screenSize.width * 0.9).clamp(260.0, 420.0);
    final l10n = context.l10n;
    final dialogTitle = widget.title.isEmpty ? l10n.branchFilterTitle : widget.title;
    return AlertDialog(
      scrollable: true,
      title: Text(dialogTitle),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text(l10n.branchFilterAllBranches),
                selected: _all,
                onSelected: (sel) {
                  setState(() {
                    _all = sel;
                    if (_all) _selected.clear();
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                showCheckmark: true,
                avatar: const Icon(Icons.select_all, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in widget.profiles)
                      _BranchChip(
                        label: (p['title'] ?? p['name'] ?? '').toString(),
                        name: (p['name'] ?? '').toString(),
                        selected: !_all && _selected.contains((p['name'] ?? '').toString()),
                        onToggle: (name, isSelected) {
                          setState(() {
                            _all = false;
                            if (isSelected) {
                              _selected.add(name);
                            } else {
                              _selected.remove(name);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () => Navigator.pop(context, (_all || _selected.isEmpty) ? <String>{} : _selected),
          child: Text(l10n.branchFilterApply),
        ),
      ],
    );
  }
}

class _BranchChip extends StatelessWidget {
  final String label;
  final String name;
  final bool selected;
  final void Function(String name, bool isSelected) onToggle;

  const _BranchChip({
    required this.label,
    required this.name,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      selected: selected,
      onSelected: (sel) => onToggle(name, sel),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      showCheckmark: true,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

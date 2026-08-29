import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/lead.dart';
import '../leads_theme.dart';

/// A selectable filter chip for a lead category. When [category] is null it
/// renders an "All" chip.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    this.category,
    required this.selected,
    required this.onTap,
    this.allLabel,
  });

  final LeadCategory? category;
  final bool selected;
  final VoidCallback onTap;

  /// Text for the "no category" chip. Null resolves to the localized "All" —
  /// no caller passes it, so the old English default was what always rendered.
  final String? allLabel;

  Color _color() {
    final hex = category?.color;
    if (hex == null || hex.isEmpty) return LeadsTheme.berryPink;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value == null ? LeadsTheme.berryPink : Color(value);
  }

  @override
  Widget build(BuildContext context) {
    final label = category?.categoryName.isNotEmpty == true
        ? category!.categoryName
        : (category == null
            ? (allLabel ?? context.l10n.leadsFilterAll)
            : category!.name);
    final accent = category == null ? LeadsTheme.deepPlum : _color();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: LeadsTheme.fontFamilyFor(label),
            fontSize: 12,
            color: selected ? Colors.white : LeadsTheme.deepPlum,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: accent,
        side: BorderSide(
          color: selected ? accent : LeadsTheme.line,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

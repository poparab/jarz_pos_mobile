import 'package:flutter/material.dart';

/// An item's title with its Arabic name underneath in small, muted type.
///
/// Most purchasable items are named in English while the team reads Arabic.
/// The item search sends `item_name_ar`; it is blank for an item nobody has
/// translated (and for one already named in Arabic), and absent altogether
/// from a backend that predates the field. Without it this is a plain title.
class ItemTitleWithArabic extends StatelessWidget {
  const ItemTitleWithArabic({
    super.key,
    required this.title,
    this.arabicName,
  });

  final String title;
  final Object? arabicName;

  @override
  Widget build(BuildContext context) {
    final arabic = (arabicName ?? '').toString().trim();
    if (arabic.isEmpty) return Text(title);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        Text(
          arabic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/manufacturing_service.dart';

/// Recently submitted Work Orders, for confirming a batch actually landed.
Future<void> showRecentWorkOrders(BuildContext context, WidgetRef ref) async {
  final service = ref.read(manufacturingServiceProvider);
  final messenger = ScaffoldMessenger.of(context);

  List<Map<String, dynamic>> rows;
  try {
    rows = await service.listRecentWorkOrders(limit: 100);
  } catch (error) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          context.userErrorMessage(error, fallback: context.l10n.commonError),
        ),
      ),
    );
    return;
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;
      return AlertDialog(
        title: Text(l10n.manufacturingRecentWorkOrdersTitle),
        content: SizedBox(
          width: ResponsiveUtils.getDialogWidth(
            dialogContext,
            small: 400,
            medium: 520,
            large: 600,
          ),
          height: ResponsiveUtils.getDialogHeight(
            dialogContext,
            phoneFraction: 0.65,
            tabletFraction: 0.55,
            max: 400,
          ),
          child: rows.isEmpty
              ? Center(child: Text(l10n.manufacturingNoWorkOrders))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final row = rows[index];
                    final qty = (row['qty'] as num?)?.toDouble() ?? 0;
                    return ListTile(
                      dense: true,
                      title: Text(
                        l10n.manufacturingRecentWorkOrderTitle(
                          '${row['name']}',
                          '${row['status']}',
                        ),
                      ),
                      subtitle: Text(
                        l10n.manufacturingRecentWorkOrderSubtitle(
                          '${row['production_item']}',
                          qty.toString(),
                          '${row['bom_no'] ?? ''}',
                        ),
                      ),
                      trailing: Text('${row['creation'] ?? ''}'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      );
    },
  );
}

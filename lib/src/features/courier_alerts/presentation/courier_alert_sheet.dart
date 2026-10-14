import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../user_admin/presentation/widgets/user_admin_widgets.dart';
import '../data/courier_alert_models.dart';
import '../data/courier_alerts_repository.dart';
import 'courier_alert_labels.dart';

/// Opens the alert detail sheet. Resolves to true when the alert was
/// acknowledged (Reviewed or Dismissed), so the caller refreshes the list.
Future<bool?> showCourierAlertSheet(BuildContext context, CourierAlert alert) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => CourierAlertSheet(alert: alert),
  );
}

class CourierAlertSheet extends ConsumerStatefulWidget {
  const CourierAlertSheet({super.key, required this.alert});

  final CourierAlert alert;

  @override
  ConsumerState<CourierAlertSheet> createState() => _CourierAlertSheetState();
}

class _CourierAlertSheetState extends ConsumerState<CourierAlertSheet> {
  final _note = TextEditingController();
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _acknowledge(CourierAlertStatus status) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(courierAlertsRepositoryProvider)
          .acknowledge(
            name: widget.alert.name,
            status: status,
            note: _note.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.courierAlertsUpdated)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alert = widget.alert;
    final color = courierAlertSeverityColor(alert.severity);
    final detected = alert.detectedOn;

    Widget row(String label, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(child: SelectableText(value)),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      courierAlertTypeLabel(l10n, alert.anomalyType),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  UserAdminTag(
                    text: courierAlertSeverityLabel(l10n, alert.severity),
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              row(l10n.courierAlertsFieldCourier, alert.courierLabel),
              row(l10n.courierAlertsFieldInvoice, alert.invoice),
              row(l10n.courierAlertsFieldBranch, alert.branch),
              row(
                l10n.courierAlertsFieldDetected,
                detected == null
                    ? null
                    : formatDateTime(context, detected),
              ),
              row(
                l10n.courierAlertsFieldStatus,
                courierAlertStatusLabel(l10n, alert.status),
              ),
              row(l10n.courierAlertsFieldDetails, alert.details),
              row(l10n.courierAlertsFieldNote, alert.reviewNote),
              if (alert.isOpen) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _note,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.courierAlertsNoteLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    userAdminErrorText(context, _error),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _acknowledge(CourierAlertStatus.dismissed),
                        child: Text(l10n.courierAlertsDismiss),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _acknowledge(CourierAlertStatus.reviewed),
                        child: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.courierAlertsMarkReviewed),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

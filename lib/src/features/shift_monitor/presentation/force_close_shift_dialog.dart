import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../../../core/utils/responsive_utils.dart';
import '../data/shift_monitor_repository.dart';
import '../models/shift_monitor_models.dart';
import 'providers/shift_monitor_providers.dart';

/// Lets a manager close a shift somebody else opened.
///
/// A shift could previously only be closed by the user who opened it, and no
/// second shift could start on that branch until it was — so a staff member who
/// left with an open shift took the branch offline until an administrator fixed
/// it in Desk. This is the in-app way out.
///
/// The manager types the amount actually counted in the drawer, exactly as the
/// opener would have, so a genuine difference still posts a Cash Over/Short
/// entry rather than being quietly written off.
class ForceCloseShiftDialog extends ConsumerStatefulWidget {
  const ForceCloseShiftDialog({super.key, required this.openingEntry});

  final String openingEntry;

  static Future<bool?> show(BuildContext context, String openingEntry) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForceCloseShiftDialog(openingEntry: openingEntry),
    );
  }

  @override
  ConsumerState<ForceCloseShiftDialog> createState() =>
      _ForceCloseShiftDialogState();
}

class _ForceCloseShiftDialogState extends ConsumerState<ForceCloseShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final Map<String, TextEditingController> _amountControllers = {};

  ForceClosePreview? _preview;
  String? _loadError;
  bool _loading = true;
  bool _submitting = false;
  bool _acknowledgeUnsettled = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPreview() async {
    try {
      final repository = ref.read(shiftMonitorRepositoryProvider);
      final preview = await repository.fetchForceClosePreview(
        widget.openingEntry,
      );
      if (!mounted) return;
      setState(() {
        _preview = preview;
        for (final mode in preview.modesOfPayment) {
          _amountControllers[mode] = TextEditingController();
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final preview = _preview;
    if (preview == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final amounts = <String, double>{};
      for (final entry in _amountControllers.entries) {
        amounts[entry.key] = double.parse(entry.value.text.trim());
      }

      final repository = ref.read(shiftMonitorRepositoryProvider);
      await repository.forceCloseShift(
        openingEntry: widget.openingEntry,
        closingAmounts: amounts,
        reason: _reasonController.text.trim(),
        acknowledgeUnsettled: _acknowledgeUnsettled,
      );

      if (!mounted) return;
      // Refresh the monitor so the shift flips to closed straight away.
      ref.invalidate(shiftMonitorDataProvider);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _loadError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _preview;

    return AlertDialog(
      title: Text(
        preview == null
            ? l10n.shiftMonitorForceCloseAction
            : l10n.shiftMonitorForceCloseTitle(preview.userFullName),
      ),
      content: SizedBox(
        width: ResponsiveUtils.getDialogWidth(
          context,
          small: 320,
          medium: 420,
          large: 480,
        ),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: preview == null
                    ? Text(_loadError ?? '')
                    : _buildForm(context, preview),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: (_submitting || _loading || preview == null) ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.shiftMonitorForceCloseConfirm),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ForceClosePreview preview) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shiftMonitorForceCloseIntro(
              preview.userFullName,
              preview.posProfile,
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final mode in preview.modesOfPayment) ...[
            TextFormField(
              controller: _amountControllers[mode],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: l10n.shiftMonitorForceCloseCountLabel(mode),
                helperText: l10n.shiftMonitorForceCloseExpected(
                  formatCurrency(context, preview.expectedAmount),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null) {
                  return l10n.shiftMonitorForceCloseCountRequired(mode);
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _reasonController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.shiftMonitorForceCloseReasonLabel,
              hintText: l10n.shiftMonitorForceCloseReasonHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return l10n.shiftMonitorForceCloseReasonRequired;
              }
              return null;
            },
          ),
          if (preview.courierBlocked) ...[
            const SizedBox(height: 16),
            // Unsettled courier balances normally block a close outright. A
            // manager may override, but only after being shown exactly what
            // stays outstanding — the override is recorded on the shift.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.shiftMonitorForceCloseCourierWarning(
                            preview.courierTransactionCount,
                            preview.courierInvoiceCount,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _acknowledgeUnsettled,
                    onChanged: (value) => setState(
                      () => _acknowledgeUnsettled = value ?? false,
                    ),
                    title: Text(
                      l10n.shiftMonitorForceCloseCourierAck,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            Text(
              _loadError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

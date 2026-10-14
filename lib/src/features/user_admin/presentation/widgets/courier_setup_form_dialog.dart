import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/courier_setup_repository.dart';
import '../../models/courier_setup_models.dart';
import 'user_admin_widgets.dart';

/// What the form hands back on success.
class CourierSetupOutcome {
  const CourierSetupOutcome({
    required this.result,
    this.displayName,
    this.phone,
  });

  final CourierSetupResult result;

  /// The name to greet the courier with.
  final String? displayName;

  /// The mobile the manager typed, if any (existing employees keep theirs on
  /// the Employee record, which this screen does not read).
  final String? phone;
}

/// "Set up courier": pick an existing Employee, or give a name and mobile for
/// a new one, then a branch and optionally a POS profile.
///
/// The form makes the call itself so a refusal ("already linked to another
/// login", "System Manager account") shows inline with the server's own
/// sentence and the entered values are kept.
class CourierSetupFormDialog extends ConsumerStatefulWidget {
  const CourierSetupFormDialog({
    super.key,
    required this.candidates,
    this.initialEmployee,
  });

  final CourierCandidates candidates;
  final CourierCandidate? initialEmployee;

  static Future<CourierSetupOutcome?> show(
    BuildContext context, {
    required CourierCandidates candidates,
    CourierCandidate? initialEmployee,
  }) {
    return showDialog<CourierSetupOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CourierSetupFormDialog(
        candidates: candidates,
        initialEmployee: initialEmployee,
      ),
    );
  }

  @override
  ConsumerState<CourierSetupFormDialog> createState() =>
      _CourierSetupFormDialogState();
}

class _CourierSetupFormDialogState
    extends ConsumerState<CourierSetupFormDialog> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _posProfile = TextEditingController();
  late bool _existing;
  CourierCandidate? _employee;
  String? _branch;
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _employee = widget.initialEmployee;
    _existing = widget.initialEmployee != null || _canPickExisting;
    _branch = _validBranch(widget.initialEmployee?.branch);
  }

  bool get _canPickExisting => widget.candidates.employees.isNotEmpty;

  String? _validBranch(String? branch) =>
      branch != null && widget.candidates.branches.contains(branch)
      ? branch
      : null;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _posProfile.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_existing) return _employee != null;
    return _name.text.trim().isNotEmpty && _mobile.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(courierSetupRepositoryProvider);
      final result = await repo.setupCourier(
        employee: _existing ? _employee!.employee : null,
        fullName: _existing ? null : _name.text,
        mobileNo: _existing ? null : _mobile.text,
        branch: _branch,
        posProfile: _posProfile.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        CourierSetupOutcome(
          result: result,
          displayName: _existing ? _employee!.displayName : _name.text.trim(),
          phone: _existing ? null : _mobile.text.trim(),
        ),
      );
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

    return AlertDialog(
      title: Text(l10n.courierSetupFormTitle),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_canPickExisting && widget.initialEmployee == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.courierSetupModeExisting),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.courierSetupModeNew),
                      ),
                    ],
                    selected: {_existing},
                    onSelectionChanged: _busy
                        ? null
                        : (s) => setState(() => _existing = s.first),
                  ),
                ),
              if (_existing)
                _EmployeeField(
                  candidates: widget.candidates.employees,
                  selected: _employee,
                  enabled: !_busy && widget.initialEmployee == null,
                  onSelected: (c) => setState(() {
                    _employee = c;
                    _branch = _validBranch(c.branch) ?? _branch;
                  }),
                  onCleared: () => setState(() => _employee = null),
                )
              else ...[
                TextField(
                  controller: _name,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.courierSetupFullName,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mobile,
                  enabled: !_busy,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.courierSetupMobile,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: ValueKey('branch-${_branch ?? ''}'),
                initialValue: _branch,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.courierSetupBranch,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final b in widget.candidates.branches)
                    DropdownMenuItem<String?>(value: b, child: Text(b)),
                ],
                onChanged: _busy ? null : (v) => setState(() => _branch = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _posProfile,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: l10n.courierSetupPosProfile,
                  helperText: l10n.courierSetupPosProfileHelp,
                  helperMaxLines: 2,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  userAdminErrorText(context, _error),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _busy || !_valid ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.courierSetupSubmit),
        ),
      ],
    );
  }
}

/// Type-ahead picker over the candidate employees.
class _EmployeeField extends StatelessWidget {
  const _EmployeeField({
    required this.candidates,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    required this.onCleared,
  });

  final List<CourierCandidate> candidates;
  final CourierCandidate? selected;
  final bool enabled;
  final void Function(CourierCandidate) onSelected;

  /// The text no longer names the chosen employee.
  final VoidCallback onCleared;

  String _label(CourierCandidate c) =>
      c.branch == null ? c.displayName : '${c.displayName} · ${c.branch}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Autocomplete<CourierCandidate>(
      initialValue: TextEditingValue(
        text: selected == null ? '' : _label(selected!),
      ),
      displayStringForOption: _label,
      optionsBuilder: (value) {
        if (selected != null && value.text == _label(selected!)) {
          return const Iterable<CourierCandidate>.empty();
        }
        return candidates.where((c) => c.matches(value.text)).take(30);
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          onChanged: (text) {
            if (selected != null && text != _label(selected!)) onCleared();
          },
          decoration: InputDecoration(
            labelText: l10n.courierSetupEmployee,
            hintText: l10n.courierSetupEmployeeHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

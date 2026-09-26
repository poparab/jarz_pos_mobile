import 'package:flutter/material.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

/// Null when [value] is an acceptable password. The server enforces the same
/// minimum; this only saves a round trip.
String? validatePassword(AppLocalizations l10n, String? value, int minLength) {
  final text = value ?? '';
  if (text.isEmpty) return l10n.userAdminFieldRequired;
  if (text.length < minLength) return l10n.userAdminPasswordTooShort(minLength);
  return null;
}

class PasswordChoice {
  const PasswordChoice({required this.password, required this.signOut});

  final String password;

  /// End every session the user has open.
  final bool signOut;
}

/// New password + confirmation. Pops a [PasswordChoice], or null on cancel.
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({
    super.key,
    required this.userName,
    required this.minLength,
  });

  final String userName;
  final int minLength;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _signOut = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(PasswordChoice(password: _password.text, signOut: _signOut));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.userAdminPasswordDialogTitle(widget.userName)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('password-dialog-new'),
                  controller: _password,
                  autofocus: true,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.userAdminNewPassword,
                    helperText: l10n.userAdminPasswordTooShort(
                      widget.minLength,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscure
                          ? l10n.userAdminShowPassword
                          : l10n.userAdminHidePassword,
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (value) =>
                      validatePassword(l10n, value, widget.minLength),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('password-dialog-confirm'),
                  controller: _confirm,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.userAdminConfirmPassword,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value ?? '') != _password.text
                      ? l10n.userAdminPasswordMismatch
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _signOut,
                  onChanged: (v) => setState(() => _signOut = v ?? true),
                  title: Text(l10n.userAdminSignOutEverywhere),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('password-dialog-submit'),
          onPressed: _submit,
          child: Text(l10n.userAdminChangePassword),
        ),
      ],
    );
  }
}

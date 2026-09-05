import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/user_error_message.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/network/user_service.dart';
import '../state/login_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isPasswordObscured = true;

  String _normalizeErrorText(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  }

  String _localizedLoginError(Object error) {
    final l10n = context.l10n;
    final message = _normalizeErrorText(context.userErrorMessage(error));

    switch (message) {
      case 'Invalid credentials':
        return l10n.authInvalidCredentials;
      case 'Cannot reach server. Check Wi-Fi/VPN and backend URL, then try again.':
        return l10n.authCannotReachServer;
      case 'Connection failed. Please verify network and server availability.':
        return l10n.authConnectionFailed;
      case 'Login failed. Please try again.':
        return l10n.authLoginFailed;
      default:
        if (message.isEmpty) {
          return l10n.authLoginFailed;
        }
        return context.userErrorMessage(error, fallback: l10n.authLoginFailed);
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.authLoginTitle)),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context, small: 16, medium: 24, large: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: context.l10n.authUsernameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: context.l10n.authPasswordLabel,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                  tooltip: _isPasswordObscured
                      ? context.l10n.authShowPassword
                      : context.l10n.authHidePassword,
                ),
              ),
              obscureText: _isPasswordObscured,
            ),
            const SizedBox(height: 24),
            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      // Capture router before any await to avoid using context after async gap
                      final router = GoRouter.of(context);
                      final notifier = ref.read(loginNotifierProvider.notifier);
                      await notifier.login(
                        _usernameController.text.trim(),
                        _passwordController.text,
                      );
                      final success =
                          ref.read(loginNotifierProvider).value ?? false;
                      if (!mounted) return;
                      if (success) {
                        // The "Line Manager / Employee" mode prompt used to sit
                        // here. It only ever flipped a client-side flag that
                        // skipped the shift gate, which the server now enforces
                        // regardless — so the choice could not be honoured and
                        // was removed rather than left showing a promise the
                        // app no longer keeps.
                        //
                        // Resolve the correct home (Kanban for Jarz POS Staff,
                        // POS otherwise) before navigating.
                        final roles =
                            await ref.read(userRolesFutureProvider.future);
                        if (!mounted) return;
                        router.go(homeRouteFor(roles));
                      }
                    },
                    child: Text(context.l10n.authLoginTitle),
                  ),
            if (state.hasError) ...[
              const SizedBox(height: 16),
              Text(
                _localizedLoginError(state.error!),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

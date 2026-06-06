import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
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
    final message = _normalizeErrorText(error);

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
        return l10n.commonErrorWithDetails(message);
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
                        final showChoice =
                            ref.read(shouldShowLoginModeChoiceProvider);
                        if (showChoice) {
                          final chosen = await _showLoginModeDialog();
                          if (!mounted) return;
                          if (chosen == null) return; // dismissed
                          ref.read(loginModeProvider.notifier).state = chosen;
                        }
                        router.go(AppRoutes.pos);
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

  Future<LoginMode?> _showLoginModeDialog() {
    return showDialog<LoginMode>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.loginModeDialogTitle),
          content: SizedBox(
            width: ResponsiveUtils.getDialogWidth(ctx, small: 300, medium: 380, large: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LoginModeOption(
                  icon: Icons.supervisor_account,
                  title: l10n.loginModeLineManager,
                  subtitle: l10n.loginModeLineManagerDesc,
                  onTap: () => Navigator.of(ctx).pop(LoginMode.lineManager),
                ),
                const SizedBox(height: 12),
                _LoginModeOption(
                  icon: Icons.badge,
                  title: l10n.loginModeEmployee,
                  subtitle: l10n.loginModeEmployeeDesc,
                  onTap: () => Navigator.of(ctx).pop(LoginMode.employee),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginModeOption extends StatelessWidget {
  const _LoginModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}

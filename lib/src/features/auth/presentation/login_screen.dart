import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/login_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
                      final success = ref.read(loginNotifierProvider).value ?? false;
                      if (!mounted) return;
                      if (success) {
                        router.go('/pos');
                      }
                    },
                    child: const Text('Login'),
                  ),
            if (state.hasError) ...[
              const SizedBox(height: 16),
              Text(
                state.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

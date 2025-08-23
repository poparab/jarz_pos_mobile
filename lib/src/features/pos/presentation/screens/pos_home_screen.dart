import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/state/login_notifier.dart';
import '../../../../core/widgets/app_drawer.dart';

class PosHomeScreen extends ConsumerWidget {
  const PosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Jarz POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(loginNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Jarz POS',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}

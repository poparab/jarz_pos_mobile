import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_drawer.dart';

class PosHomeScreen extends ConsumerWidget {
  const PosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.maybeOf(ctx)?.openDrawer(),
          ),
        ),
        title: const Text('Jarz POS'),
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

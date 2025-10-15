import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/app_drawer.dart';

class PosHomeScreen extends ConsumerWidget {
  const PosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
            onPressed: () => Scaffold.maybeOf(ctx)?.openDrawer(),
          ),
        ),
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}

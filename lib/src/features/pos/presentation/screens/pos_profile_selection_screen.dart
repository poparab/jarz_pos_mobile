import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/pos_notifier.dart';
import '../../../../core/localization/localization_extensions.dart';

class PosProfileSelectionScreen extends ConsumerWidget {
  const PosProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(posNotifierProvider);
    if (!state.isLoading && state.profiles.isEmpty) {
      // Attempt reload after hot reload scenario
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(posNotifierProvider.notifier).loadProfiles();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posProfileSelectionTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? _buildError(context, state.error!, ref)
          : _buildProfileList(context, state.profiles, ref),
    );
  }

  Widget _buildError(BuildContext context, String error, WidgetRef ref) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.posProfileSelectionErrorTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(posNotifierProvider.notifier).loadProfiles(),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    List<Map<String, dynamic>> profiles,
    WidgetRef ref,
  ) {
    final l10n = context.l10n;
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.posProfileSelectionNoProfilesTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.posProfileSelectionNoProfilesBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Centered grid with slightly larger tiles to avoid overflow
    final media = MediaQuery.of(context);
    const maxGridWidth = 720.0;
    const desiredTileWidth = 200.0;
    const desiredTileHeight = 120.0;
    final crossAxisCount = (media.size.width.clamp(0.0, maxGridWidth) / desiredTileWidth)
        .floor()
        .clamp(2, 4);
    final childAspectRatio = desiredTileWidth / desiredTileHeight;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxGridWidth),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildProfileCard(context, profile, ref);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    Map<String, dynamic> profile,
    WidgetRef ref,
  ) {
    final l10n = context.l10n;
    final displayTitle = (profile['title'] ?? profile['name'])?.toString();
    final warehouse = profile['warehouse']?.toString();
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () async {
          if (ref.read(posNotifierProvider).isLoading) return; // prevent double taps
          await ref.read(posNotifierProvider.notifier).selectProfile(profile);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/pos');
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                displayTitle ?? l10n.posProfileSelectionUnknownProfile,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (warehouse != null)
                Text(
                  l10n.posProfileSelectionWarehouseLabel(warehouse),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

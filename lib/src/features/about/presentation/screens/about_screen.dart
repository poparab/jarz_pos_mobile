import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../data/about_release_info_repository.dart';
import '../providers/about_release_info_provider.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(aboutReleaseInfoProvider);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(aboutReleaseInfoProvider);
    try {
      await ref.read(aboutReleaseInfoProvider.future);
    } catch (_) {}
  }

  Future<void> _copyDiagnostics(AboutReleaseInfo info) async {
    final l10n = context.l10n;
    final text = <String>[
      '${l10n.aboutAppName}: ${info.appName}',
      '${l10n.aboutPackageName}: ${info.packageName}',
      '${l10n.aboutPlatform}: ${info.platformLabel}',
      '${l10n.aboutEnvironment}: ${info.environment}',
      '${l10n.aboutBuildName}: ${info.buildName}',
      '${l10n.aboutBuildNumber}: ${info.buildNumber}',
      '${l10n.aboutReleaseId}: ${_displayValue(info.releaseId, l10n.aboutNotAvailable)}',
      '${l10n.aboutReleaseDist}: ${_displayValue(info.releaseDist, l10n.aboutNotAvailable)}',
      '${l10n.aboutPatchNumber}: ${_patchNumberText(l10n, info.shorebird)}',
      '${l10n.aboutPatchStatus}: ${_patchStatusText(l10n, info.shorebird)}',
      if (info.shorebird.status == ShorebirdPatchStatus.unknown &&
          (info.shorebird.errorMessage?.trim().isNotEmpty ?? false))
        '${l10n.aboutPatchStatusUnknownDetail}: ${info.shorebird.errorMessage!.trim()}',
      '${l10n.aboutLastChecked}: ${_formatTimestamp(context, info.lastCheckedAt)}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.aboutCopiedDiagnostics)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aboutAsync = ref.watch(aboutReleaseInfoProvider);
    final l10n = context.l10n;
    final releaseInfo = aboutAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: l10n.aboutRefresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: l10n.aboutCopyDiagnostics,
            onPressed: releaseInfo == null ? null : () => _copyDiagnostics(releaseInfo),
            icon: const Icon(Icons.content_copy),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: aboutAsync.when(
        data: (info) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoSection(
                title: l10n.aboutAppSection,
                children: [
                  _InfoRow(label: l10n.aboutAppName, value: info.appName),
                  _InfoRow(
                    label: l10n.aboutPackageName,
                    value: info.packageName,
                  ),
                  _InfoRow(
                    label: l10n.aboutPlatform,
                    value: info.platformLabel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoSection(
                title: l10n.aboutReleaseSection,
                children: [
                  _InfoRow(label: l10n.aboutEnvironment, value: info.environment),
                  _InfoRow(label: l10n.aboutBuildName, value: info.buildName),
                  _InfoRow(label: l10n.aboutBuildNumber, value: info.buildNumber),
                  _InfoRow(
                    label: l10n.aboutReleaseId,
                    value: _displayValue(info.releaseId, l10n.aboutNotAvailable),
                  ),
                  _InfoRow(
                    label: l10n.aboutReleaseDist,
                    value: _displayValue(info.releaseDist, l10n.aboutNotAvailable),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ShorebirdStatusCard(
                sectionTitle: l10n.aboutShorebirdSection,
                diagnostics: info.shorebird,
                lastCheckedAt: info.lastCheckedAt,
                l10n: l10n,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.aboutError(error.toString()),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.aboutRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

String _displayValue(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value;

String _patchNumberText(AppLocalizations l10n, ShorebirdDiagnostics diagnostics) {
  if (diagnostics.status == ShorebirdPatchStatus.unavailable) {
    return l10n.aboutPatchUnavailable;
  }
  if (diagnostics.currentPatchNumber == null) {
    return l10n.aboutPatchNotInstalled;
  }
  return diagnostics.currentPatchNumber.toString();
}

String _patchStatusText(AppLocalizations l10n, ShorebirdDiagnostics diagnostics) {
  return switch (diagnostics.status) {
    ShorebirdPatchStatus.upToDate => l10n.aboutPatchStatusUpToDate,
    ShorebirdPatchStatus.updateAvailable => l10n.aboutPatchStatusUpdateAvailable,
    ShorebirdPatchStatus.restartRequired => l10n.aboutPatchStatusRestartRequired,
    ShorebirdPatchStatus.unavailable => l10n.aboutPatchStatusUnavailable,
    ShorebirdPatchStatus.unknown => l10n.aboutPatchStatusUnknown,
  };
}

String _formatTimestamp(BuildContext context, DateTime value) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ShorebirdStatusCard extends StatelessWidget {
  const _ShorebirdStatusCard({
    required this.sectionTitle,
    required this.diagnostics,
    required this.lastCheckedAt,
    required this.l10n,
  });

  final String sectionTitle;
  final ShorebirdDiagnostics diagnostics;
  final DateTime lastCheckedAt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (diagnostics.status) {
      ShorebirdPatchStatus.upToDate => (Icons.check_circle, Colors.green),
      ShorebirdPatchStatus.updateAvailable => (Icons.cloud_download, Colors.blue),
      ShorebirdPatchStatus.restartRequired => (Icons.restart_alt, Colors.orange),
      ShorebirdPatchStatus.unavailable => (Icons.block, Colors.grey),
      ShorebirdPatchStatus.unknown => (Icons.help_outline, Colors.grey),
    };

    final isRestartRequired =
        diagnostics.status == ShorebirdPatchStatus.restartRequired;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _patchStatusText(l10n, diagnostics),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: l10n.aboutPatchNumber,
                value: _patchNumberText(l10n, diagnostics),
              ),
              if (isRestartRequired && diagnostics.nextPatchNumber != null)
                _InfoRow(
                  label: l10n.aboutPatchPending,
                  value: diagnostics.nextPatchNumber.toString(),
                ),
              _InfoRow(
                label: l10n.aboutLastChecked,
                value: _formatTimestamp(context, lastCheckedAt),
              ),
              if (diagnostics.status == ShorebirdPatchStatus.unknown &&
                  (diagnostics.errorMessage?.trim().isNotEmpty ?? false))
                _InfoRow(
                  label: l10n.aboutPatchStatusUnknownDetail,
                  value: diagnostics.errorMessage!.trim(),
                ),
              if (isRestartRequired) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.aboutRestartInstruction,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange.shade800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

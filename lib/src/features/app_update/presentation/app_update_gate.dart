import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/localization_extensions.dart';
import '../data/app_update_service.dart';
import '../state/app_update_provider.dart';

/// Replaces the entire app with a non-dismissible update screen when the
/// server says this build may no longer run.
///
/// Wraps *above* routing and authentication on purpose: a stale build must be
/// stopped before it can reach a till, not after. It renders [child] untouched
/// in every other case, including while the check is still in flight - the
/// barrier goes up on a definite "no", never on the absence of an answer.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The observer lives here rather than in the authenticated bootstrap so
    // the check also runs for a device sitting on the login screen - which is
    // exactly where a device left overnight comes back.
    if (state == AppLifecycleState.resumed) {
      ref.read(appUpdateProvider.notifier).recheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocked = ref.watch(appUpdateBlockedProvider);
    if (!blocked) {
      return widget.child;
    }

    final requirement =
        ref.watch(appUpdateProvider).valueOrNull ?? AppUpdateRequirement.none;
    return _ForcedUpdateScreen(requirement: requirement);
  }
}

class _ForcedUpdateScreen extends ConsumerStatefulWidget {
  const _ForcedUpdateScreen({required this.requirement});

  final AppUpdateRequirement requirement;

  @override
  ConsumerState<_ForcedUpdateScreen> createState() =>
      _ForcedUpdateScreenState();
}

class _ForcedUpdateScreenState extends ConsumerState<_ForcedUpdateScreen> {
  bool _rechecking = false;

  Future<void> _openDownload() async {
    final url = widget.requirement.downloadUrl;
    var opened = false;
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        try {
          // externalApplication hands the APK to the browser, which owns the
          // "install from unknown sources" consent. Doing the install in-app
          // would need REQUEST_INSTALL_PACKAGES in the manifest.
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          opened = false;
        }
      }
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.appUpdateOpenFailed)),
      );
    }
  }

  Future<void> _recheck() async {
    setState(() => _rechecking = true);
    try {
      await ref.read(appUpdateProvider.notifier).recheck();
    } finally {
      if (mounted) {
        setState(() => _rechecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final requirement = widget.requirement;

    return PopScope(
      // The whole point: the back button must not dismiss this.
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.system_update,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.appUpdateRequiredTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      // A message configured in Jarz POS Settings replaces the
                      // generic text so an admin can say what actually broke.
                      requirement.message.isNotEmpty
                          ? requirement.message
                          : l10n.appUpdateRequiredBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _BuildNumbers(requirement: requirement),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _openDownload,
                      icon: const Icon(Icons.download),
                      label: Text(l10n.appUpdateDownloadButton),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _rechecking ? null : _recheck,
                      child: _rechecking
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.appUpdateRecheckButton),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.appUpdateInstallHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Installed vs required build, so a manager on the phone can read back the
/// two numbers that decide whether the device is allowed on.
class _BuildNumbers extends ConsumerWidget {
  const _BuildNumbers({required this.requirement});

  final AppUpdateRequirement requirement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final identity = ref.watch(appBuildIdentityProvider).valueOrNull;
    final current = identity?.buildNumber;
    if (current == null && requirement.minimumBuild == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.appUpdateBuildLine(
          '${current ?? '—'}',
          '${requirement.minimumBuild}',
        ),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

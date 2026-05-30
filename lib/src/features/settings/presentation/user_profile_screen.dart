import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/network/user_service.dart';
import '../../../core/constants/business_constants.dart';
import '../data/alarm_sound_service.dart';
import '../../pos/order_alert/order_alert_bridge.dart';
import '../../pos/order_alert/order_alert_native_channel.dart';
import '../../pos/order_alert/web_push_release_diagnostics.dart';
import '../../pos/order_alert/state/order_alert_controller.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isEnablingWebPush = false;
  String? _webPushDiagnosticMessage;

  @override
  void dispose() {
    // Stop any playing preview when leaving the screen
    OrderAlertNativeChannel.stopPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRolesAsync = ref.watch(userRolesFutureProvider);
    final selectedSound = ref.watch(selectedAlarmSoundProvider);
    final availableSoundsAsync = ref.watch(availableAlarmSoundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsUserProfileTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: userRolesAsync.when(
        data: (userRoles) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              _getInitials(userRoles.fullName ?? userRoles.user),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userRoles.fullName ?? 'User',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userRoles.user,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                if (userRoles.isJarzManager) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      RoleNames.jarzManager,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Roles Section
              Text(
                context.l10n.settingsRolesTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userRoles.roles.isEmpty)
                        Text(context.l10n.settingsNoRolesAssigned)
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: userRoles.roles.map((role) {
                            return Chip(
                              label: Text(role),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Alarm Sound Settings
              Text(
                context.l10n.settingsNotificationSettings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              if (kIsWeb) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.install_mobile,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'iPhone web push notifications',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Install this app to the iPhone Home Screen, then tap Enable Notifications to receive background alerts.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: _isEnablingWebPush
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.notifications_active_outlined),
                            label: Text(
                              _isEnablingWebPush
                                  ? 'Enabling notifications...'
                                  : 'Enable Notifications',
                            ),
                            onPressed: _isEnablingWebPush
                                ? null
                                : () => _enableWebPushNotifications(context),
                          ),
                        ),
                        if (_webPushDiagnosticMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _webPushDiagnosticMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Global Mute Toggle (only for authorized roles)
              if (userRoles.canMuteNotifications) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<bool>(
                      future: ref.read(orderAlertControllerProvider.notifier).getGlobalMuteState(),
                      builder: (context, snapshot) {
                        final isMuted = snapshot.data ?? false;
                        return SwitchListTile(
                          title: Row(
                            children: [
                              Icon(
                                isMuted ? Icons.notifications_off : Icons.notifications_active,
                                color: isMuted ? Colors.orange : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Notification Alerts',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0, start: 36.0),
                            child: Text(
                              isMuted 
                                ? 'All order notification alarms are currently muted'
                                : 'Order notification alarms are active',
                              style: TextStyle(
                                color: isMuted ? Colors.orange[700] : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          value: !isMuted,
                          onChanged: (bool value) async {
                            await ref.read(orderAlertControllerProvider.notifier).setGlobalMuteState(!value);
                            // Trigger rebuild
                            setState(() {});
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value 
                                      ? 'Notification alarms enabled on this device' 
                                      : 'Notification alarms muted on this device',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: value ? Colors.green : Colors.orange,
                                ),
                              );
                            }
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.settingsAlarmSoundLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose the in-app staff alarm sound:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Show loading or available sounds
                      availableSoundsAsync.when(
                        data: (availableSounds) {
                          if (availableSounds.isEmpty) {
                            return Text(context.l10n.settingsNoAlarmSounds);
                          }
                          
                          return Column(
                            children: availableSounds.map((sound) {
                              final isSelected = selectedSound?.uri == sound.uri;
                              return InkWell(
                                onTap: () async {
                                  final service = ref.read(alarmSoundServiceProvider);
                                  await service.setSelectedSound(sound.uri, sound.title);
                                  
                                  // Refresh the provider
                                  ref.invalidate(selectedAlarmSoundProvider);
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(context.l10n.settingsAlarmSoundChanged(sound.title)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                        color: isSelected 
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          sound.title,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected 
                                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                                : null,
                                          ),
                                        ),
                                      ),
                                      // Preview button
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        tooltip: context.l10n.commonPreview,
                                        onPressed: () async {
                                          final service = ref.read(alarmSoundServiceProvider);
                                          await service.previewSound(sound.uri);
                                          
                                          // Auto-stop preview after 3 seconds
                                          Future.delayed(const Duration(seconds: 3), () {
                                            service.stopPreview();
                                          });
                                        },
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            context.l10n.settingsFailedToLoadAlarmSounds(error.toString()),
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Browse files button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: Text(context.l10n.settingsBrowseCustomSoundFile),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          onPressed: () async {
                            try {
                              if (kDebugMode) {
                                debugPrint('Button pressed - opening file picker');
                              }
                              final service = ref.read(alarmSoundServiceProvider);
                              final customSound = await service.pickCustomAlarmSound();
                            
                              if (kDebugMode) {
                                debugPrint('Custom sound result: ${customSound?.title}');
                              }
                            
                              if (customSound != null) {
                                await service.setSelectedSound(customSound.uri, customSound.title);
                              
                                // Refresh the provider
                                ref.invalidate(selectedAlarmSoundProvider);
                              
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10n.settingsCustomAlarmSoundSet(customSound.title)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                } else {
                                  if (kDebugMode) {
                                    debugPrint('No custom sound selected');
                                  }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10n.settingsNoFileSelected),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                debugPrint('Error in button handler: $e');
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.commonErrorWithDetails(e.toString())),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      
                      // Show custom sound if selected
                      if (selectedSound != null && 
                          selectedSound.uri.startsWith('file://')) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.audio_file,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${context.l10n.settingsCustomSoundTitle}:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    Text(
                                      selectedSound.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                tooltip: context.l10n.commonPreview,
                                onPressed: () async {
                                  final service = ref.read(alarmSoundServiceProvider);
                                  await service.previewSound(selectedSound.uri);
                                  
                                  // Auto-stop preview after 3 seconds
                                  Future.delayed(const Duration(seconds: 3), () {
                                    service.stopPreview();
                                  });
                                },
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Additional Info Card
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This sound is used for the in-app staff alarm. Closed-app order notifications use the app order tone.',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load user profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userRolesFutureProvider),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enableWebPushNotifications(BuildContext context) async {
    setState(() {
      _isEnablingWebPush = true;
      _webPushDiagnosticMessage = null;
    });
    try {
      final result = await ref.read(orderAlertBridgeProvider).enableWebPushNotifications();
      final diagnostics = result.isSuccess
          ? null
          : await WebPushReleaseDiagnostics.load();
      if (!context.mounted) return;

      final diagnosticMessage = diagnostics?.toUserMessage();
      if (diagnosticMessage != null) {
        setState(() => _webPushDiagnosticMessage = diagnosticMessage);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            diagnosticMessage == null
                ? result.message
                : '${result.message}\n$diagnosticMessage',
          ),
          duration: Duration(seconds: result.isSuccess ? 3 : 6),
          backgroundColor: result.isSuccess ? Colors.green : Colors.orange,
        ),
      );
    } catch (error) {
      final diagnostics = await WebPushReleaseDiagnostics.load();
      if (!context.mounted) return;

      final diagnosticMessage = diagnostics.toUserMessage();
      setState(() => _webPushDiagnosticMessage = diagnosticMessage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to enable notifications. Reopen the Home Screen app and try again.\n$diagnosticMessage',
          ),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isEnablingWebPush = false);
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

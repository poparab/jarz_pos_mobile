import 'package:flutter/material.dart';
import '../../../../core/localization/localization_extensions.dart';

/// Result returned by [TerritoryProfileMismatchDialog.show].
class TerritoryProfileChoice {
  /// The POS profile name the user confirmed.
  final String profileName;

  /// Always `true` — the caller must send `pos_profile_override=1` to the
  /// backend whenever this result is returned.
  final bool override;

  const TerritoryProfileChoice({
    required this.profileName,
    this.override = true,
  });
}

/// AlertDialog that asks the user which POS profile to use when the
/// currently-selected profile differs from the customer's territory profile.
///
/// Returns a [TerritoryProfileChoice] when the user confirms, or `null` when
/// the user cancels.
class TerritoryProfileMismatchDialog extends StatefulWidget {
  /// The name of the profile currently selected in the POS screen.
  final String selectedProfile;

  /// The POS profile mapped to the customer's territory, or `null` when no
  /// mapping exists.
  final String? territoryProfile;

  const TerritoryProfileMismatchDialog({
    super.key,
    required this.selectedProfile,
    this.territoryProfile,
  });

  /// Convenience static helper — shows the dialog and returns the choice.
  static Future<TerritoryProfileChoice?> show(
    BuildContext context, {
    required String selectedProfile,
    String? territoryProfile,
  }) {
    return showDialog<TerritoryProfileChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TerritoryProfileMismatchDialog(
        selectedProfile: selectedProfile,
        territoryProfile: territoryProfile,
      ),
    );
  }

  @override
  State<TerritoryProfileMismatchDialog> createState() =>
      _TerritoryProfileMismatchDialogState();
}

class _TerritoryProfileMismatchDialogState
    extends State<TerritoryProfileMismatchDialog> {
  late String _chosen;

  @override
  void initState() {
    super.initState();
    // Default selection: territory profile when available, else selected profile.
    _chosen = widget.territoryProfile ?? widget.selectedProfile;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasTerritoryProfile = widget.territoryProfile != null &&
        widget.territoryProfile!.isNotEmpty;

    return AlertDialog(
      title: Text(l10n.posTerritoryMismatchTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.posTerritoryMismatchBody),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _chosen,
            onChanged: (v) => setState(() => _chosen = v!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option 1: Keep the currently-selected profile
                RadioListTile<String>(
                  title: Text(
                    l10n.posTerritoryMismatchUseSelected(widget.selectedProfile),
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: widget.selectedProfile,
                  contentPadding: EdgeInsets.zero,
                ),
                // Option 2: Switch to territory profile (hidden when not available)
                if (hasTerritoryProfile)
                  RadioListTile<String>(
                    title: Text(
                      l10n.posTerritoryMismatchUseTerritory(widget.territoryProfile!),
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: widget.territoryProfile!,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          if (!hasTerritoryProfile)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                l10n.posTerritoryMismatchNoTerritory(widget.selectedProfile),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.posTerritoryMismatchCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            TerritoryProfileChoice(profileName: _chosen),
          ),
          child: Text(l10n.posTerritoryMismatchConfirm),
        ),
      ],
    );
  }
}

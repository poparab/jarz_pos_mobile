import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../leads_theme.dart';

/// Shared helpers for the quick contact actions (call / instagram / website /
/// maps) used by lead cards, the detail screen, and branch rows.
abstract final class LeadActions {
  static Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> call(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return;
    await _open(Uri(scheme: 'tel', path: cleaned));
  }

  static Future<void> instagram(String handle) async {
    var value = handle.trim();
    if (value.isEmpty) return;
    if (value.startsWith('http')) {
      await _open(Uri.parse(value));
      return;
    }
    value = value.replaceAll('@', '');
    await _open(Uri.parse('https://instagram.com/$value'));
  }

  static Future<void> website(String url) async {
    var value = url.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('http')) value = 'https://$value';
    await _open(Uri.parse(value));
  }

  static Future<void> maps(String mapsUrl) async {
    final value = mapsUrl.trim();
    if (value.isEmpty) return;
    await _open(Uri.parse(value));
  }

  static Future<void> mapsAt(double lat, double lng) async {
    await _open(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
    );
  }
}

/// A round icon button used for the quick contact actions.
class LeadActionButton extends StatelessWidget {
  const LeadActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.tooltip,
    this.color = LeadsTheme.deepPlum,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final String? tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final button = InkResponse(
      onTap: enabled ? onTap : null,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? color : LeadsTheme.line,
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

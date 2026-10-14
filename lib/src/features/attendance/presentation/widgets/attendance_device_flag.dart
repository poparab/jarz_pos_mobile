import 'package:flutter/material.dart';

/// Buddy-punching markers: informational, manager-facing.
///
/// Labels are inline (not `.arb`) on purpose: a new `.arb` string forces a
/// full APK release, and these three words are all this feature needs. The
/// explanatory detail comes from the server in English and is shown as is.
const String kDeviceFlagShared = 'Shared Device';
const String kDeviceFlagNew = 'New Device';
const String kDeviceFlagNone = 'No Device';

bool _isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

/// Chip text for a wire flag. Unknown flags are shown verbatim.
String attendanceDeviceFlagLabel(BuildContext context, String flag) {
  final ar = _isArabic(context);
  return switch (flag) {
    kDeviceFlagShared => ar ? 'تليفون مشترك' : 'Shared phone',
    kDeviceFlagNew => ar ? 'تليفون جديد' : 'New phone',
    kDeviceFlagNone => ar ? 'مفيش تعريف للجهاز' : 'No device ID',
    _ => flag,
  };
}

/// Red-ish for a shared phone, amber for everything else.
Color attendanceDeviceFlagColor(String flag) => flag == kDeviceFlagShared
    ? const Color(0xFFD32F2F)
    : const Color(0xFFF59E0B);

/// Legend sentence.
String attendanceDeviceFlagLegend(BuildContext context) => _isArabic(context)
    ? 'علامة تليفون: ممكن حد بصّم بدل زميله'
    : 'Phone warning: someone may have punched for a colleague';

/// Small corner dot on a month-grid cell. Colour = worst (first) flag.
class AttendanceDeviceFlagDot extends StatelessWidget {
  const AttendanceDeviceFlagDot({super.key, required this.flags});

  final List<String> flags;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) return const SizedBox.shrink();
    return Container(
      key: const ValueKey('attendance-device-flag-dot'),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: attendanceDeviceFlagColor(flags.first),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}

/// One chip per flag, with the server's detail underneath when present.
class AttendanceDeviceFlagChips extends StatelessWidget {
  const AttendanceDeviceFlagChips({
    super.key,
    required this.flags,
    this.detail,
    this.dense = false,
  });

  final List<String> flags;
  final String? detail;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('attendance-device-flag-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final flag in flags)
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: attendanceDeviceFlagColor(
                    flag,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 12,
                      color: attendanceDeviceFlagColor(flag),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attendanceDeviceFlagLabel(context, flag),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: attendanceDeviceFlagColor(flag),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (detail != null && detail!.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 3),
            child: Text(
              detail!,
              maxLines: dense ? 3 : null,
              overflow: dense ? TextOverflow.ellipsis : null,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

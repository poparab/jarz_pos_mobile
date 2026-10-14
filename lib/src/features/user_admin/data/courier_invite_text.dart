/// The WhatsApp message that hands a courier their sign-in details.
///
/// Arabic on purpose and not tied to the app language: it goes to the courier
/// (like the follow-up apology text), not to the person operating the screen.
/// `*...*` is WhatsApp bold. The PIN appears here because sharing it is the
/// point; the text is built on demand from the on-screen card and never stored.
String buildCourierInviteText({
  required String signInId,
  required String pin,
  String? displayName,
  String? webUrl,
  String? apkUrl,
  bool isReset = false,
}) {
  final name = (displayName ?? '').trim();
  final sb = StringBuffer();
  sb.writeln(name.isEmpty ? 'أهلاً،' : 'أهلاً $name،');
  sb.writeln(
    isReset
        ? 'الرقم السري الجديد لتطبيق مناديب جارز:'
        : 'حسابك على تطبيق مناديب جارز جاهز.',
  );
  sb.writeln();
  sb.writeln('رقم الدخول: *$signInId*');
  sb.writeln('الرقم السري: *$pin*');
  final web = (webUrl ?? '').trim();
  final apk = (apkUrl ?? '').trim();
  if (web.isNotEmpty || apk.isNotEmpty) sb.writeln();
  if (web.isNotEmpty) sb.writeln('الرابط على الويب: $web');
  if (apk.isNotEmpty) sb.writeln('تطبيق الأندرويد: $apk');
  sb.writeln();
  sb.write('من فضلك ما تشاركش الرقم السري مع حد.');
  return sb.toString();
}

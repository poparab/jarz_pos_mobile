import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/user_error_message.dart';
import 'package:jarz_pos/src/features/pos/presentation/utils/amendment_refusal_message.dart';

// `submit_invoice_amendment` refuses with `success: false` and a human `error`.
// Most of those sentences are not validation-shaped, so the generic presenter
// reduced them to "something went wrong" (Woo #17862, 2026-10-06).
void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));
  const reason =
      'The order changed since you opened it. Reopen it and edit again.';

  test('the generic presenter drops this refusal (why the helper exists)', () {
    expect(userErrorMessageFor(en, reason), isNot(reason));
  });

  test('shows the server reason as written in English', () {
    expect(amendmentRefusalMessageFor(en, reason), reason);
  });

  test('keeps an English reason under the Arabic lead', () {
    expect(
      amendmentRefusalMessageFor(ar, reason),
      '${ar.kanbanAmendmentFailed}\n$reason',
    );
  });

  test('keeps an Arabic reason as is', () {
    const arabic = 'الطلب قيد التعديل من مستخدم آخر.';
    expect(amendmentRefusalMessageFor(ar, arabic), arabic);
  });

  test('falls back to the localized line for missing or technical text', () {
    expect(amendmentRefusalMessageFor(en, null), en.kanbanAmendmentFailed);
    expect(amendmentRefusalMessageFor(ar, ''), ar.kanbanAmendmentFailed);
    expect(
      amendmentRefusalMessageFor(en, 'Traceback (most recent call last): boom'),
      en.kanbanAmendmentFailed,
    );
  });
}

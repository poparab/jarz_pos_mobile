// Tracking link: JSON parsing, the bilingual share text, and the share sheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/tracking/data/tracking_link.dart';
import 'package:jarz_pos/src/features/tracking/domain/tracking_share_text.dart';
import 'package:jarz_pos/src/features/tracking/presentation/share_tracking_link.dart';

const _url = 'https://erp.orderjarz.com/track/abc123';

void main() {
  group('TrackingLink.fromJson', () {
    test('reads the contract shape', () {
      final link = TrackingLink.fromJson({
        'url': _url,
        'delivery_code': '4821',
        'code_required': true,
        'customer_phone': '01012345678',
      });
      expect(link.url, _url);
      expect(link.deliveryCode, '4821');
      expect(link.codeRequired, isTrue);
      expect(link.customerPhone, '01012345678');
      expect(link.hasCodeToShare, isTrue);
    });

    test('code_required accepts 1 / "1" and defaults to false', () {
      expect(
        TrackingLink.fromJson({'url': _url, 'code_required': 1}).codeRequired,
        isTrue,
      );
      expect(
        TrackingLink.fromJson({'url': _url, 'code_required': '1'}).codeRequired,
        isTrue,
      );
      expect(TrackingLink.fromJson({'url': _url}).codeRequired, isFalse);
    });

    test('a code the server returned but does not require is not shared', () {
      final link = TrackingLink.fromJson({
        'url': _url,
        'delivery_code': '4821',
        'code_required': false,
      });
      expect(link.deliveryCode, '4821');
      expect(link.hasCodeToShare, isFalse);
    });

    test('missing and blank fields degrade instead of throwing', () {
      final link = TrackingLink.fromJson({
        'delivery_code': '  ',
        'customer_phone': null,
      });
      expect(link.url, '');
      expect(link.deliveryCode, isNull);
      expect(link.customerPhone, isNull);
      expect(link.hasCodeToShare, isFalse);
    });
  });

  group('buildTrackingShareText', () {
    test('is Arabic + English with the link and no code line', () {
      final text = buildTrackingShareText(
        const TrackingLink(url: _url, deliveryCode: '4821'),
      );
      expect(text, contains('تابع طلبك'));
      expect(text, contains('Follow your Jarz order live'));
      expect(text, contains(_url));
      expect(text, isNot(contains('4821')));
      expect(text, isNot(contains('Delivery code')));
    });

    test('adds the code lines only when the code is required', () {
      final text = buildTrackingShareText(
        const TrackingLink(
          url: _url,
          deliveryCode: '4821',
          codeRequired: true,
        ),
      );
      expect(text, contains('كود الاستلام: 4821'));
      expect(text, contains('Delivery code: 4821'));
      expect(text, contains(_url));
    });
  });

  group('TrackingLinkSheet', () {
    Future<void> pump(WidgetTester tester, TrackingLink link) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => SingleChildScrollView(
                child: TrackingLinkSheet(
                  link: link,
                  messenger: ScaffoldMessenger.of(context),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows the link, the code and Copy code when required', (
      tester,
    ) async {
      await pump(
        tester,
        const TrackingLink(url: _url, deliveryCode: '4821', codeRequired: true),
      );
      expect(find.text(_url), findsOneWidget);
      expect(find.byKey(TrackingLinkSheet.codeKey), findsOneWidget);
      expect(find.text('4821'), findsOneWidget);
      expect(find.byKey(TrackingLinkSheet.copyCodeKey), findsOneWidget);
      expect(find.byKey(TrackingLinkSheet.whatsAppKey), findsOneWidget);
      expect(find.byKey(TrackingLinkSheet.shareKey), findsOneWidget);
    });

    testWidgets('hides the code and Copy code when not required', (
      tester,
    ) async {
      await pump(
        tester,
        const TrackingLink(url: _url, deliveryCode: '4821'),
      );
      expect(find.text(_url), findsOneWidget);
      expect(find.byKey(TrackingLinkSheet.codeKey), findsNothing);
      expect(find.byKey(TrackingLinkSheet.copyCodeKey), findsNothing);
      expect(find.text('4821'), findsNothing);
      // The link can always be copied.
      expect(find.byKey(TrackingLinkSheet.copyLinkKey), findsOneWidget);
    });
  });
}

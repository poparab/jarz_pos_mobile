import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/followups/data/followup_whatsapp.dart';
import 'package:jarz_pos/src/features/followups/data/models/followup_models.dart';

FollowupRow _row({String msisdn = '', String phone = '', String text = ''}) =>
    FollowupRow(
      name: 'CF-1',
      whatsappMsisdn: msisdn,
      phone: phone,
      messageText: text,
    );

void main() {
  group('followupMsisdn', () {
    test('prefers the server msisdn', () {
      expect(
        followupMsisdn(_row(msisdn: '201012345678', phone: '01199999999')),
        '201012345678',
      );
    });

    test('falls back to the client port on phone', () {
      expect(followupMsisdn(_row(phone: '010 1234 5678')), '201012345678');
      expect(followupMsisdn(_row(phone: '+20 101 234 5678')), '201012345678');
    });

    test('empty when neither has digits', () {
      expect(followupMsisdn(_row(phone: '  ')), '');
    });
  });

  group('followupWhatsappUri', () {
    test('builds wa.me with the url-encoded Arabic message', () {
      const text = 'أهلاً يا منى! طلبك وصل؟ & شكراً';
      final uri =
          followupWhatsappUri(_row(msisdn: '201012345678', text: text));

      expect(uri, isNotNull);
      expect(uri!.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/201012345678');
      expect(uri.queryParameters['text'], text);
      expect(
        uri.toString(),
        'https://wa.me/201012345678?text=${Uri.encodeComponent(text)}',
      );
      expect(uri.toString(), isNot(contains(' ')));
    });

    test('uses the phone fallback when msisdn is empty', () {
      final uri = followupWhatsappUri(_row(phone: '01012345678', text: 'hi'));
      expect(uri.toString(), 'https://wa.me/201012345678?text=hi');
    });

    test('null without a number (button disabled)', () {
      expect(followupWhatsappUri(_row(text: 'hi')), isNull);
    });

    test('apology link carries the code', () {
      final uri = followupWhatsappUriFor(
        '201012345678',
        followupApologyText('SORRY-7K2'),
      );
      expect(uri!.queryParameters['text'], contains('SORRY-7K2'));
    });
  });

  group('followupTelUri', () {
    test('keeps digits and a leading plus', () {
      expect(followupTelUri('010-1234 5678').toString(), 'tel:01012345678');
      expect(followupTelUri('+201012345678').toString(), 'tel:+201012345678');
    });

    test('null for no digits', () {
      expect(followupTelUri(''), isNull);
      expect(followupTelUri('+'), isNull);
    });
  });
}

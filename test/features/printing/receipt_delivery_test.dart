import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/printing/receipt/receipt_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('jarz/whatsapp_share');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

  late List<MethodCall> calls;
  void answer(Object? reply) {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return reply;
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('sendImagesToWhatsApp', () {
    test('with no number, WhatsApp opens its own chat list: no jid is sent', () async {
      answer('sent');
      final ok = await sendImagesToWhatsApp(
        [receiptImageFile(png, 'statement-07-10-2026'), receiptImageFile(png, 'receipt-17901')],
        caption: 'STATEMENT — Cafe Nour',
      );
      expect(ok, isTrue);
      expect(calls.single.method, 'shareImages');
      final args = calls.single.arguments as Map;
      expect(args['names'], ['statement-07-10-2026.png', 'receipt-17901.png']);
      expect(args['caption'], 'STATEMENT — Cafe Nour');
      expect((args['images'] as List).length, 2);
      expect(args.containsKey('jid'), isFalse);
    });

    test("the customer's number goes as a WhatsApp jid in international form", () async {
      answer('sent');
      await sendImagesToWhatsApp([receiptImageFile(png, 'r')], caption: 'c', phone: '01111034268');
      expect((calls.single.arguments as Map)['jid'], '201111034268@s.whatsapp.net');
    });

    test('no WhatsApp on the device reports false so the share sheet takes over', () async {
      answer('not_installed');
      expect(await sendImagesToWhatsApp([receiptImageFile(png, 'r')], caption: 'c'), isFalse);
    });

    test('an install without the native channel reports false, not an error', () async {
      expect(await sendImagesToWhatsApp([receiptImageFile(png, 'r')], caption: 'c'), isFalse);
    });
  });
}

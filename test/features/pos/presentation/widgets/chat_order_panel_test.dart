// The POS "From the chat" panel: lines to add by hand, warnings, notes and the
// customer's new details, with copy / add-address / open-map actions, the
// chat's promo codes and payment method, and a dismiss.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/src/features/chat_inbox/data/models/chat_models.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/chat_order_panel.dart';
import 'package:jarz_pos/src/features/pos/state/chat_order_apply.dart';

void main() {
  final order = ChatPrefillOrder.fromJson({
    'lines': [
      {'kind': 'item', 'item_code': 'Hazelnut L', 'item_name': 'Hazelnut L', 'qty': 2},
      {'kind': 'item', 'item_code': 'Mango Small', 'item_name': 'Mango Small', 'qty': 1},
    ],
    'address': {'text': '9 Street 5, Maadi'},
    'area': {'territory': 'EG6OCT', 'label': '6th of October', 'delivery_income': 60},
    'location': {
      'latitude': 30.06,
      'longitude': 31.2,
      'link': 'https://www.google.com/maps/search/?api=1&query=30.06,31.2',
    },
    'phone': '01012345678',
    'contact_name': 'Mona',
    'pickup': true,
    'notes': 'No nuts',
    'warnings': ['Quantity of Lotus unclear'],
    'promo_codes': ['BACKXQ33VV', 'OLD10', 'LATER'],
    'payment_method': 'instapay',
  });

  Future<void> pump(
    WidgetTester tester, {
    ChatPrefillOrder? forOrder,
    ChatOrderApplyResult? result,
    List<ChatPromoOutcome>? promoOutcomes,
    VoidCallback? onDismiss,
    VoidCallback? onAddAddress,
    ValueChanged<String>? onApplyPromo,
    ValueChanged<Uri>? onOpenMap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChatOrderPanel(
              order: forOrder ?? order,
              result: result,
              promoOutcomes: promoOutcomes,
              onDismiss: onDismiss ?? () {},
              onAddAddress: onAddAddress,
              onApplyPromo: onApplyPromo,
              onOpenMap: onOpenMap ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    // The panel body scrolls inside a 240px box.
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('shows what could not be added and what the customer said', (
    tester,
  ) async {
    var addressAsked = 0;
    await pump(
      tester,
      result: ChatOrderApplyResult(
        added: [order.lines.first],
        skipped: [
          ChatOrderSkippedLine(order.lines[1], ChatOrderSkipReason.notInCatalog),
        ],
      ),
      onAddAddress: () => addressAsked++,
    );

    expect(find.text('From the chat'), findsOneWidget);
    expect(find.text('1 added, 1 to add by hand'), findsOneWidget);
    expect(find.textContaining('Mango Small'), findsOneWidget);
    expect(find.textContaining('not on this branch menu'), findsOneWidget);
    expect(find.text('• Quantity of Lotus unclear'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-order-notes')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-order-phone')), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-order-name')), findsOneWidget);
    expect(find.textContaining('6th of October'), findsOneWidget);
    expect(find.textContaining('delivery 60'), findsOneWidget);
    expect(find.textContaining('pick the order up'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('chat-order-add-address')),
    );
    expect(addressAsked, 1);
  });

  testWidgets('lists the chat lines while the cart is still loading', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Adding the chat order to the cart…'), findsOneWidget);
    expect(find.text('• 2 × Hazelnut L'), findsOneWidget);
    expect(find.text('• 1 × Mango Small'), findsOneWidget);
    expect(find.textContaining('BACKXQ33VV — waiting for the cart'),
        findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-order-add-address')),
      findsNothing,
      reason: 'no add-address action without a handler',
    );
  });

  testWidgets('map pin: shown with copy and Open map', (tester) async {
    Uri? opened;
    await pump(tester, onOpenMap: (uri) => opened = uri);
    expect(find.byKey(const ValueKey('chat-order-location')), findsOneWidget);
    expect(find.textContaining('query=30.06,31.2'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('chat-order-open-map')));
    expect(opened.toString(),
        'https://www.google.com/maps/search/?api=1&query=30.06,31.2');
  });

  testWidgets('a pin without written address still offers Add as new address',
      (tester) async {
    var asked = 0;
    await pump(
      tester,
      forOrder: ChatPrefillOrder.fromJson({
        'location': {'link': 'https://maps.app.goo.gl/abc'},
      }),
      onAddAddress: () => asked++,
    );
    expect(find.byKey(const ValueKey('chat-order-address')), findsNothing);
    expect(find.textContaining('maps.app.goo.gl/abc'), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('chat-order-add-address')),
    );
    expect(asked, 1);
  });

  testWidgets('promo outcomes: applied, refused with reason, apply later', (
    tester,
  ) async {
    String? applyAsked;
    await pump(
      tester,
      result: const ChatOrderApplyResult(),
      promoOutcomes: const [
        ChatPromoOutcome('BACKXQ33VV', ChatPromoStatus.applied),
        ChatPromoOutcome('OLD10', ChatPromoStatus.refused,
            reason: 'This code has expired'),
        ChatPromoOutcome('LATER', ChatPromoStatus.notApplied),
      ],
      onApplyPromo: (code) => applyAsked = code,
    );
    expect(find.text('BACKXQ33VV — applied'), findsOneWidget);
    expect(find.text('OLD10 — refused: This code has expired'), findsOneWidget);
    expect(find.text('LATER — not applied (the cart was empty)'),
        findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-order-apply-promo-OLD10')),
      findsNothing,
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('chat-order-apply-promo-LATER')),
    );
    expect(applyAsked, 'LATER');
  });

  testWidgets('payment method is shown, display only', (tester) async {
    await pump(tester);
    expect(find.text('Customer said they will pay by InstaPay.'),
        findsOneWidget);
  });

  testWidgets('collapses and dismisses', (tester) async {
    var dismissed = false;
    await pump(tester, onDismiss: () => dismissed = true);
    await tester.tap(find.byKey(const ValueKey('chat-order-toggle')));
    await tester.pump();
    expect(find.text('• 2 × Hazelnut L'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat-order-dismiss')));
    expect(dismissed, isTrue);
  });

  group('chatLocationLinkValue (the address dialog prefill)', () {
    test('coordinates arrive as a confirmed pin with its link', () {
      final value = chatLocationLinkValue(order.location)!;
      expect(value.link, order.location!.link);
      expect(value.latitude, 30.06);
      expect(value.longitude, 31.2);
      expect(value.isConfirmed, isTrue);
      expect(value.toRequestFields(), {
        'location_link': order.location!.link,
        'latitude': '30.06',
        'longitude': '31.2',
      });
    });

    test('a short link arrives unresolved, for the field to check', () {
      final value = chatLocationLinkValue(
        const ChatPrefillLocation(link: 'https://maps.app.goo.gl/abc'),
      )!;
      expect(value.isConfirmed, isFalse);
      expect(value.toRequestFields(), {
        'location_link': 'https://maps.app.goo.gl/abc',
      });
    });

    test('coordinates without a link become a pasted pair', () {
      final value = chatLocationLinkValue(
        const ChatPrefillLocation(latitude: 30.1, longitude: 31.2),
      )!;
      expect(value.link, '30.1,31.2');
      expect(value.isConfirmed, isTrue);
      expect(chatLocationLinkValue(null), isNull);
    });
  });
}

// The POS "From the chat" panel: lines to add by hand, warnings, notes and the
// customer's new details, with copy / add-address actions and a dismiss.
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
    'phone': '01012345678',
    'contact_name': 'Mona',
    'pickup': true,
    'notes': 'No nuts',
    'warnings': ['Quantity of Lotus unclear'],
  });

  Future<void> pump(
    WidgetTester tester, {
    ChatOrderApplyResult? result,
    VoidCallback? onDismiss,
    ValueChanged<String>? onAddAddress,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChatOrderPanel(
              order: order,
              result: result,
              onDismiss: onDismiss ?? () {},
              onAddAddress: onAddAddress,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows what could not be added and what the customer said', (
    tester,
  ) async {
    String? addressAsked;
    await pump(
      tester,
      result: ChatOrderApplyResult(
        added: [order.lines.first],
        skipped: [
          ChatOrderSkippedLine(order.lines[1], ChatOrderSkipReason.notInCatalog),
        ],
      ),
      onAddAddress: (text) => addressAsked = text,
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

    // The panel body scrolls inside a 240px box.
    final addAddress = find.byKey(const ValueKey('chat-order-add-address'));
    await tester.ensureVisible(addAddress);
    await tester.pump();
    await tester.tap(addAddress);
    expect(addressAsked, '9 Street 5, Maadi');
  });

  testWidgets('lists the chat lines while the cart is still loading', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Adding the chat order to the cart…'), findsOneWidget);
    expect(find.text('• 2 × Hazelnut L'), findsOneWidget);
    expect(find.text('• 1 × Mango Small'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-order-add-address')),
      findsNothing,
      reason: 'no add-address action without a handler',
    );
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../chat_inbox/data/models/chat_models.dart';
import '../../../geo/presentation/widgets/location_link_field.dart'
    show LocationLinkValue;
import '../../state/chat_order_apply.dart';

/// Inline bilingual text. The chat-order panel deliberately carries no .arb
/// keys: an .arb edit turns a Dart-only Shorebird patch into a full APK.
String chatOrderText(BuildContext context, String en, String ar) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

String chatOrderSkipReasonText(
  BuildContext context,
  ChatOrderSkipReason reason,
) => switch (reason) {
  ChatOrderSkipReason.notInCatalog => chatOrderText(
    context,
    'not on this branch menu',
    'غير موجود في قائمة هذا الفرع',
  ),
  ChatOrderSkipReason.incompleteBundle => chatOrderText(
    context,
    'flavours not all chosen',
    'لم تُحدَّد كل النكهات',
  ),
  ChatOrderSkipReason.selectionNotInCatalog => chatOrderText(
    context,
    'a flavour is not offered in this bundle',
    'نكهة غير متاحة في هذه الباقة',
  ),
  ChatOrderSkipReason.outOfStock => chatOrderText(
    context,
    'a flavour is out of stock',
    'نكهة غير متوفرة في المخزون',
  ),
  ChatOrderSkipReason.unclearQuantity => chatOrderText(
    context,
    'quantity unclear',
    'الكمية غير واضحة',
  ),
  ChatOrderSkipReason.refused => chatOrderText(
    context,
    'the cart refused it',
    'رفضته السلة',
  ),
};

/// The chat's map pin as the address dialog's location value. With
/// coordinates the pin is already confirmed; a short link without them
/// arrives unresolved and the location field checks it like a pasted link.
LocationLinkValue? chatLocationLinkValue(ChatPrefillLocation? location) {
  if (location == null) return null;
  final link = location.link.isNotEmpty
      ? location.link
      : (location.hasCoordinates
            ? '${location.latitude},${location.longitude}'
            : '');
  if (link.isEmpty) return null;
  return LocationLinkValue(
    link: link,
    latitude: location.hasCoordinates ? location.latitude : null,
    longitude: location.hasCoordinates ? location.longitude : null,
  );
}

String chatPaymentMethodText(BuildContext context, String method) =>
    switch (method) {
      ChatPaymentMethods.cash => chatOrderText(context, 'cash', 'نقدًا'),
      ChatPaymentMethods.instapay => chatOrderText(
        context,
        'InstaPay',
        'إنستاباي',
      ),
      ChatPaymentMethods.wallet => chatOrderText(
        context,
        'mobile wallet',
        'محفظة إلكترونية',
      ),
      ChatPaymentMethods.card => chatOrderText(context, 'card', 'بطاقة'),
      _ => method,
    };

String _qty(double qty) =>
    qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString();

/// "From the chat" on the POS in chat_order mode: what the AI read from the
/// chat that is NOT (or could not be) in the cart — lines to add by hand,
/// warnings, notes, pickup, and a new address / phone / name / area for
/// staff to act on. Nothing here changes the customer record by itself.
class ChatOrderPanel extends StatefulWidget {
  const ChatOrderPanel({
    super.key,
    required this.order,
    required this.result,
    required this.onDismiss,
    this.promoOutcomes,
    this.onAddAddress,
    this.onApplyPromo,
    this.onOpenMap,
  });

  final ChatPrefillOrder order;

  /// Null while the cart is still waiting for the customer / menu to load.
  final ChatOrderApplyResult? result;
  final VoidCallback onDismiss;

  /// What the chat's promo codes did; null until they were tried.
  final List<ChatPromoOutcome>? promoOutcomes;

  /// Opens the POS address dialog on its new-address tab, prefilled with the
  /// chat's address text and map pin.
  final VoidCallback? onAddAddress;

  /// Applies one chat promo code through the POS promo path (for a code that
  /// was not tried because the cart was empty).
  final ValueChanged<String>? onApplyPromo;

  /// Opens a map URL; defaults to url_launcher (tests inject a fake).
  final ValueChanged<Uri>? onOpenMap;

  @override
  State<ChatOrderPanel> createState() => _ChatOrderPanelState();
}

class _ChatOrderPanelState extends State<ChatOrderPanel> {
  bool _expanded = true;

  String _t(String en, String ar) => chatOrderText(context, en, ar);

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_t('Copied', 'تم النسخ'))));
  }

  Future<void> _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final open = widget.onOpenMap;
    if (open != null) {
      open(uri);
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_t('Could not open the map', 'تعذّر فتح الخريطة'))),
        );
    }
  }

  String _status() {
    final result = widget.result;
    final order = widget.order;
    if (order.lines.isEmpty) {
      return _t('Nothing to add to the cart', 'لا شيء لإضافته إلى السلة');
    }
    if (result == null) {
      return _t(
        'Adding the chat order to the cart…',
        'جارٍ إضافة طلب المحادثة إلى السلة…',
      );
    }
    final added = result.added.length;
    final left = result.skipped.length;
    if (left == 0) {
      return _t('$added line(s) added to the cart', 'أُضيف $added سطر إلى السلة');
    }
    return _t(
      '$added added, $left to add by hand',
      'أُضيف $added، و$left للإضافة يدويًا',
    );
  }

  Widget _section(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          ...children,
        ],
      ),
    );
  }

  Widget _copyRow(String label, String value, {Key? key}) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: _t('Copy', 'نسخ'),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () => _copy(value),
        ),
      ],
    );
  }

  String _selectionsText(ChatPrefillLine line) => line.selections.values
      .expand((picks) => picks)
      .map((pick) => '${pick.itemCode} ×${pick.qty}')
      .join('، ');

  List<Widget> _promoRows() {
    final outcomes = widget.promoOutcomes;
    final rows = <Widget>[];
    for (final code in widget.order.promoCodes) {
      final outcome = outcomes?.cast<ChatPromoOutcome?>().firstWhere(
        (o) => o?.code == code,
        orElse: () => null,
      );
      final String status;
      Widget? action;
      switch (outcome?.status) {
        case null:
          status = _t('waiting for the cart', 'بانتظار السلة');
        case ChatPromoStatus.applied:
          status = outcome!.reason ?? _t('applied', 'تم التطبيق');
        case ChatPromoStatus.refused:
          status =
              '${_t('refused', 'مرفوض')}'
              '${outcome!.reason == null ? '' : ': ${outcome.reason}'}';
        case ChatPromoStatus.notApplied:
          status = _t(
            'not applied (the cart was empty)',
            'لم يُطبَّق (السلة كانت فارغة)',
          );
          final apply = widget.onApplyPromo;
          if (apply != null) {
            action = TextButton(
              key: ValueKey('chat-order-apply-promo-$code'),
              onPressed: () => apply(code),
              child: Text(_t('Apply', 'تطبيق')),
            );
          }
      }
      final icon = switch (outcome?.status) {
        ChatPromoStatus.applied => Icons.check_circle_outline,
        ChatPromoStatus.refused => Icons.error_outline,
        _ => Icons.local_offer_outlined,
      };
      rows.add(
        Row(
          key: ValueKey('chat-order-promo-$code'),
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Expanded(child: Text('$code — $status')),
            IconButton(
              tooltip: _t('Copy', 'نسخ'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copy(code),
            ),
            if (action != null) action,
          ],
        ),
      );
    }
    return rows;
  }

  List<Widget> _body() {
    final order = widget.order;
    final result = widget.result;
    final widgets = <Widget>[];

    if (result == null && order.lines.isNotEmpty) {
      widgets.add(
        _section(
          _t('Order in the chat', 'الطلب في المحادثة'),
          [
            for (final line in order.lines)
              Text('• ${_qty(line.qty)} × ${line.displayName}'),
          ],
        ),
      );
    }

    if (result != null && result.skipped.isNotEmpty) {
      widgets.add(
        _section(
          _t('Add these by hand', 'أضف هذه يدويًا'),
          [
            for (final skipped in result.skipped)
              Padding(
                key: ValueKey('chat-order-skipped-${skipped.line.displayName}'),
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${_qty(skipped.line.qty)} × ${skipped.line.displayName}'
                  ' — ${chatOrderSkipReasonText(context, skipped.reason)}'
                  '${skipped.line.isBundle && skipped.line.selections.isNotEmpty ? '\n   ${_selectionsText(skipped.line)}' : ''}',
                ),
              ),
          ],
        ),
      );
    }

    if (result != null && result.overStock.isNotEmpty) {
      widgets.add(
        _section(
          _t('More than in stock', 'أكثر من المتوفر في المخزون'),
          [Text(result.overStock.join('، '))],
        ),
      );
    }

    if (order.warnings.isNotEmpty) {
      widgets.add(
        _section(
          _t('Check with the customer', 'راجع مع العميل'),
          [for (final warning in order.warnings) Text('• $warning')],
        ),
      );
    }

    if (order.promoCodes.isNotEmpty) {
      widgets.add(_section(_t('Promo codes', 'أكواد الخصم'), _promoRows()));
    }

    final payment = order.paymentMethod;
    if (payment != null) {
      final method = chatPaymentMethodText(context, payment);
      widgets.add(
        _section(_t('Payment', 'الدفع'), [
          Text(
            _t(
              'Customer said they will pay by $method.',
              'قال العميل إنه سيدفع عن طريق $method.',
            ),
            key: const ValueKey('chat-order-payment'),
          ),
        ]),
      );
    }

    if (order.pickup) {
      widgets.add(
        _section(
          _t('Pickup', 'استلام من الفرع'),
          [
            Text(
              _t(
                'The customer will pick the order up (pickup is on).',
                'سيستلم العميل الطلب من الفرع (تم تفعيل الاستلام).',
              ),
            ),
          ],
        ),
      );
    }

    final notes = order.notes;
    if (notes != null) {
      widgets.add(
        _section(_t('Notes', 'ملاحظات'), [
          _copyRow(_t('Note', 'ملاحظة'), notes, key: const ValueKey('chat-order-notes')),
        ]),
      );
    }

    final details = <Widget>[];
    final address = order.addressText;
    if (address != null) {
      details.add(
        _copyRow(
          _t('New address', 'عنوان جديد'),
          address,
          key: const ValueKey('chat-order-address'),
        ),
      );
    }
    final location = order.location;
    if (location != null) {
      final shown = location.link.isNotEmpty
          ? location.link
          : '${location.latitude}, ${location.longitude}';
      final mapUrl = location.mapUrl;
      details.add(
        Row(
          key: const ValueKey('chat-order-location'),
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_t('Map pin', 'موقع على الخريطة')}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: shown),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: _t('Copy', 'نسخ'),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copy(shown),
            ),
            if (mapUrl != null)
              IconButton(
                key: const ValueKey('chat-order-open-map'),
                tooltip: _t('Open map', 'فتح الخريطة'),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.map_outlined, size: 18),
                onPressed: () => _openMap(mapUrl),
              ),
          ],
        ),
      );
    }
    final onAdd = widget.onAddAddress;
    if (order.hasNewAddress && onAdd != null) {
      details.add(
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('chat-order-add-address'),
            onPressed: onAdd,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: Text(_t('Add as new address', 'إضافة كعنوان جديد')),
          ),
        ),
      );
    }
    final area = order.area;
    if (area != null) {
      final fee = area.deliveryIncome;
      final label = area.label.isNotEmpty ? area.label : area.territory;
      details.add(
        Padding(
          key: const ValueKey('chat-order-area'),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            fee == null
                ? _t('Area: $label', 'المنطقة: $label')
                : _t(
                    'Area: $label — delivery ${fee.toStringAsFixed(fee == fee.roundToDouble() ? 0 : 2)}',
                    'المنطقة: $label — التوصيل ${fee.toStringAsFixed(fee == fee.roundToDouble() ? 0 : 2)}',
                  ),
          ),
        ),
      );
    }
    final phone = order.phone;
    if (phone != null) {
      details.add(
        _copyRow(_t('New phone', 'هاتف جديد'), phone, key: const ValueKey('chat-order-phone')),
      );
    }
    final name = order.contactName;
    if (name != null) {
      details.add(
        _copyRow(_t('Name', 'الاسم'), name, key: const ValueKey('chat-order-name')),
      );
    }
    if (details.isNotEmpty) {
      widgets.add(
        _section(
          _t('Customer said (not saved)', 'قال العميل (لم يُحفظ)'),
          details,
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = _body();
    return Container(
      key: const ValueKey('chat-order-panel'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('From the chat', 'من المحادثة'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _status(),
                        key: const ValueKey('chat-order-status'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (body.isNotEmpty)
                  IconButton(
                    key: const ValueKey('chat-order-toggle'),
                    tooltip: _expanded
                        ? _t('Hide', 'إخفاء')
                        : _t('Show', 'إظهار'),
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                IconButton(
                  key: const ValueKey('chat-order-dismiss'),
                  tooltip: _t('Dismiss', 'إغلاق'),
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
            if (_expanded && body.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: body,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

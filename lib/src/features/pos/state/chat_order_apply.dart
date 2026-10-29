// "Start order" from the chat inbox: matches the order the AI read from the
// chat against the POS catalog. Pure functions, no state: the notifier
// executes the plan through the same cart methods a cashier's taps use, so
// prices, rates and policy discounts come out identical to a hand-added line.
//
// Nothing is guessed. A line is added only when its item / bundle is in the
// loaded catalog and, for a bundle, every group is filled with flavours that
// group offers in exactly the group's quantity. Everything else is returned as
// skipped so the POS can list it for staff to add by hand.

import '../../chat_inbox/data/models/chat_models.dart';

/// Why a chat order line was not put in the cart.
enum ChatOrderSkipReason {
  /// The item / bundle is not in this branch's loaded catalog.
  notInCatalog,

  /// The reader could not fill every bundle group (or the counts are off).
  incompleteBundle,

  /// A picked flavour is not offered by that bundle group.
  selectionNotInCatalog,

  /// A picked flavour has less stock than the bundle needs.
  outOfStock,

  /// Quantity missing, zero or fractional.
  unclearQuantity,

  /// The cart refused the line (e.g. shipping items under a sales partner).
  refused,
}

class ChatOrderSkippedLine {
  final ChatPrefillLine line;
  final ChatOrderSkipReason reason;

  const ChatOrderSkippedLine(this.line, this.reason);
}

class ChatOrderItemAdd {
  final ChatPrefillLine line;

  /// The catalog row, exactly as the item grid hands it to `addToCart`.
  final Map<String, dynamic> item;
  final int qty;

  const ChatOrderItemAdd({
    required this.line,
    required this.item,
    required this.qty,
  });
}

class ChatOrderBundleAdd {
  final ChatPrefillLine line;

  /// The catalog bundle, exactly as the bundle dialog hands it over.
  final Map<String, dynamic> bundle;

  /// group key -> one entry per unit picked, the bundle dialog's shape.
  final Map<String, List<Map<String, dynamic>>> selectedItems;

  /// How many instances of this bundle to add (the contract sends 1).
  final int instances;

  const ChatOrderBundleAdd({
    required this.line,
    required this.bundle,
    required this.selectedItems,
    this.instances = 1,
  });
}

class ChatOrderPlan {
  final List<ChatOrderItemAdd> items;
  final List<ChatOrderBundleAdd> bundles;
  final List<ChatOrderSkippedLine> skipped;

  const ChatOrderPlan({
    this.items = const [],
    this.bundles = const [],
    this.skipped = const [],
  });
}

/// What [PosNotifier.applyChatOrder] did.
class ChatOrderApplyResult {
  /// Lines that are in the cart now.
  final List<ChatPrefillLine> added;

  /// Lines staff must add by hand, with the reason.
  final List<ChatOrderSkippedLine> skipped;

  /// Item names whose cart quantity now exceeds the branch stock.
  final List<String> overStock;

  const ChatOrderApplyResult({
    this.added = const [],
    this.skipped = const [],
    this.overStock = const [],
  });
}

String _str(dynamic value) => value?.toString().trim() ?? '';

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is bool) return value ? 1 : 0;
  return double.tryParse(_str(value)) ?? 0;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(_str(value)) ?? double.tryParse(_str(value))?.toInt();
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = _str(value).toLowerCase();
  return normalized == '1' ||
      normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'y';
}

/// A whole, positive quantity, or null when the reader's qty is unusable.
int? _wholeQty(double qty) {
  if (qty <= 0 || qty != qty.roundToDouble()) return null;
  return qty.round();
}

/// The catalog item whose code is [code] (`name` is the item code there).
Map<String, dynamic>? findCatalogItem(
  List<Map<String, dynamic>> items,
  String code,
) {
  final wanted = code.trim();
  if (wanted.isEmpty) return null;
  for (final item in items) {
    if (_str(item['name']) == wanted || _str(item['item_code']) == wanted) {
      return item;
    }
  }
  return null;
}

/// The catalog bundle for a chat bundle line: by `bundle_id` (= catalog `id`)
/// first, then by the bundle's ERPNext item code.
Map<String, dynamic>? findCatalogBundle(
  List<Map<String, dynamic>> bundles, {
  String? bundleId,
  String? itemCode,
}) {
  final id = bundleId?.trim() ?? '';
  if (id.isNotEmpty) {
    for (final bundle in bundles) {
      if (_str(bundle['id']) == id) return bundle;
    }
  }
  final code = itemCode?.trim() ?? '';
  if (code.isNotEmpty) {
    for (final bundle in bundles) {
      if (_str(bundle['erpnext_item']) == code ||
          _str(bundle['parent_item_code']) == code) {
        return bundle;
      }
    }
  }
  return null;
}

/// Same naming rule as the bundle selection dialog.
String bundleGroupName(Map<String, dynamic> group) {
  final value = _str(group['group_name'] ?? group['item_group'] ?? group['title']);
  return value.isEmpty ? 'Group' : value;
}

/// Same key rule as the bundle selection dialog, so the cart line's
/// `selected_items` is keyed exactly as a hand-built one.
String bundleGroupKey(Map<String, dynamic> group, int fallbackIndex) {
  final rawKey = _str(group['group_key'] ?? group['group_id'] ?? group['name']);
  if (rawKey.isNotEmpty) return rawKey;
  final rawIndex =
      _asInt(group['group_index'] ?? group['idx']) ?? (fallbackIndex + 1);
  return '${bundleGroupName(group)}::$rawIndex';
}

/// The bundle dialog's per-pick entry (`_addItemToSelection`).
Map<String, dynamic> bundleSelectionEntry(
  Map<String, dynamic> item,
  String groupName,
) => {
  'id': item['id'],
  'name': item['name'],
  'price': item['price'],
  'qty': item['qty'],
  'actual_qty': item['actual_qty'] ?? item['qty'],
  'allow_negative_stock': item['allow_negative_stock'],
  'group_name': groupName,
};

/// Builds the bundle dialog's `selectedItems` for [line] against [bundle], or
/// returns the reason it cannot be built without guessing.
({Map<String, List<Map<String, dynamic>>>? selected, ChatOrderSkipReason? reason})
buildBundleSelections(Map<String, dynamic> bundle, ChatPrefillLine line) {
  final rawGroups = bundle['item_groups'];
  final groups = rawGroups is List
      ? rawGroups.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : <Map<String, dynamic>>[];
  if (groups.isEmpty) {
    return (selected: null, reason: ChatOrderSkipReason.incompleteBundle);
  }

  final keys = <String>[
    for (var i = 0; i < groups.length; i++) bundleGroupKey(groups[i], i),
  ];
  // A selection for a group this bundle does not have: the reader and the
  // catalog disagree, so do not drop it silently.
  if (line.selections.keys.any((key) => !keys.contains(key))) {
    return (selected: null, reason: ChatOrderSkipReason.incompleteBundle);
  }

  final selected = <String, List<Map<String, dynamic>>>{};
  final pickedPerItem = <String, int>{};
  final stockPerItem = <String, double>{};
  final negativeAllowed = <String>{};

  for (var i = 0; i < groups.length; i++) {
    final group = groups[i];
    final key = keys[i];
    final groupName = bundleGroupName(group);
    final required = _asInt(group['quantity']) ?? 0;
    final rawItems = group['items'];
    final groupItems = rawItems is List
        ? rawItems.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : <Map<String, dynamic>>[];
    final entries = <Map<String, dynamic>>[];
    for (final pick in line.selections[key] ?? const <ChatPrefillSelection>[]) {
      if (pick.qty <= 0) {
        return (selected: null, reason: ChatOrderSkipReason.incompleteBundle);
      }
      final item = groupItems.cast<Map<String, dynamic>?>().firstWhere(
        (candidate) =>
            _str(candidate?['id']) == pick.itemCode ||
            _str(candidate?['item_code']) == pick.itemCode,
        orElse: () => null,
      );
      if (item == null) {
        return (
          selected: null,
          reason: ChatOrderSkipReason.selectionNotInCatalog,
        );
      }
      final id = _str(item['id']).isNotEmpty ? _str(item['id']) : pick.itemCode;
      pickedPerItem[id] = (pickedPerItem[id] ?? 0) + pick.qty;
      stockPerItem[id] = _asDouble(item['qty'] ?? item['actual_qty']);
      if (_asBool(item['allow_negative_stock'])) negativeAllowed.add(id);
      for (var n = 0; n < pick.qty; n++) {
        entries.add(bundleSelectionEntry(item, groupName));
      }
    }
    if (entries.length != required) {
      return (selected: null, reason: ChatOrderSkipReason.incompleteBundle);
    }
    selected[key] = entries;
  }

  // The dialog stops a flavour at its stock unless negative stock is allowed.
  for (final entry in pickedPerItem.entries) {
    if (negativeAllowed.contains(entry.key)) continue;
    if (entry.value > (stockPerItem[entry.key] ?? 0)) {
      return (selected: null, reason: ChatOrderSkipReason.outOfStock);
    }
  }
  return (selected: selected, reason: null);
}

/// Matches every line of [order] against the loaded catalog.
ChatOrderPlan planChatOrder(
  ChatPrefillOrder order, {
  required List<Map<String, dynamic>> items,
  required List<Map<String, dynamic>> bundles,
}) {
  final itemAdds = <ChatOrderItemAdd>[];
  final bundleAdds = <ChatOrderBundleAdd>[];
  final skipped = <ChatOrderSkippedLine>[];

  for (final line in order.lines) {
    final qty = _wholeQty(line.qty);
    if (qty == null) {
      skipped.add(ChatOrderSkippedLine(line, ChatOrderSkipReason.unclearQuantity));
      continue;
    }
    if (!line.isBundle) {
      final item = findCatalogItem(items, line.itemCode);
      if (item == null) {
        skipped.add(ChatOrderSkippedLine(line, ChatOrderSkipReason.notInCatalog));
        continue;
      }
      itemAdds.add(ChatOrderItemAdd(line: line, item: item, qty: qty));
      continue;
    }

    final bundle = findCatalogBundle(
      bundles,
      bundleId: line.bundleId,
      itemCode: line.itemCode,
    );
    if (bundle == null) {
      skipped.add(ChatOrderSkippedLine(line, ChatOrderSkipReason.notInCatalog));
      continue;
    }
    if (!line.complete) {
      skipped.add(
        ChatOrderSkippedLine(line, ChatOrderSkipReason.incompleteBundle),
      );
      continue;
    }
    final built = buildBundleSelections(bundle, line);
    if (built.selected == null) {
      skipped.add(ChatOrderSkippedLine(line, built.reason!));
      continue;
    }
    bundleAdds.add(
      ChatOrderBundleAdd(
        line: line,
        bundle: bundle,
        selectedItems: built.selected!,
        instances: qty,
      ),
    );
  }

  return ChatOrderPlan(items: itemAdds, bundles: bundleAdds, skipped: skipped);
}

import 'package:flutter/foundation.dart';

/// One combined recipe sheet per recipe family, for every size typed at once.
///
/// The kitchen makes every Tiramisu size in one go, so the sheet carries the
/// totals for the whole run plus each size's per-jar portion. Hand-written
/// rather than freezed: the shape is read-only and tolerant parsing is the
/// whole job — a missing key is a default, never a crash on the floor.
///
/// Wire: `get_recipe_sheet` → `{"message": {"sheets": [...]}}`.
@immutable
class RecipeSheetResponse {
  const RecipeSheetResponse({this.sheets = const <RecipeSheet>[]});

  factory RecipeSheetResponse.fromJson(Map<String, dynamic> json) =>
      RecipeSheetResponse(
        sheets: _mapList(json['sheets'], RecipeSheet.fromJson),
      );

  static const empty = RecipeSheetResponse();

  final List<RecipeSheet> sheets;

  bool get isEmpty => sheets.isEmpty;
}

@immutable
class RecipeSheet {
  const RecipeSheet({
    this.title = '',
    this.items = const <RecipeSheetItem>[],
    this.totalQty = 0,
    this.ingredients = const <RecipeSheetIngredient>[],
    this.steps = const <RecipeSheetStep>[],
    this.unresolvedTokens = const <String>[],
  });

  factory RecipeSheet.fromJson(Map<String, dynamic> json) => RecipeSheet(
    title: _str(json['title']),
    items: _mapList(json['items'], RecipeSheetItem.fromJson),
    totalQty: _num(json['total_qty']),
    ingredients: _mapList(json['ingredients'], RecipeSheetIngredient.fromJson),
    steps: _mapList(json['steps'], RecipeSheetStep.fromJson),
    unresolvedTokens: [
      if (json['unresolved_tokens'] is List)
        for (final token in json['unresolved_tokens'] as List)
          if (token != null && token.toString().trim().isNotEmpty)
            token.toString(),
    ],
  );

  /// The recipe family, e.g. "Tiramisu". May be English only.
  final String title;

  /// The sizes typed, each with its jar count.
  final List<RecipeSheetItem> items;

  /// Jars across every size.
  final double totalQty;

  /// Totals for the whole run, already formatted server-side in [display].
  final List<RecipeSheetIngredient> ingredients;
  final List<RecipeSheetStep> steps;
  final List<String> unresolvedTokens;
}

@immutable
class RecipeSheetItem {
  const RecipeSheetItem({this.itemCode = '', this.itemName = '', this.qty = 0});

  factory RecipeSheetItem.fromJson(Map<String, dynamic> json) =>
      RecipeSheetItem(
        itemCode: _str(json['item_code']),
        itemName: _str(json['item_name']),
        qty: _num(json['qty']),
      );

  final String itemCode;
  final String itemName;
  final double qty;

  String get displayName => itemName.isEmpty ? itemCode : itemName;
}

@immutable
class RecipeSheetIngredient {
  const RecipeSheetIngredient({
    this.itemCode = '',
    this.itemName = '',
    this.qty = 0,
    this.uom = '',
    this.display = '',
  });

  factory RecipeSheetIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeSheetIngredient(
        itemCode: _str(json['item_code']),
        itemName: _str(json['item_name']),
        qty: _num(json['qty']),
        uom: _str(json['uom']),
        display: _str(json['display']),
      );

  final String itemCode;
  final String itemName;
  final double qty;
  final String uom;

  /// "165.3 g" — the server picks the unit a person reads off a scale.
  final String display;

  String get displayName => itemName.isEmpty ? itemCode : itemName;
}

@immutable
class RecipeSheetStep {
  const RecipeSheetStep({
    this.stepNo = 0,
    this.title = '',
    this.text,
    this.perItem,
  });

  factory RecipeSheetStep.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'];
    final rawPerItem = json['per_item'];
    return RecipeSheetStep(
      stepNo: _num(json['step_no']).toInt(),
      title: _str(json['title']),
      text: rawText?.toString(),
      perItem: rawPerItem is List
          ? _mapList(rawPerItem, RecipeSheetStepLine.fromJson)
          : null,
    );
  }

  final int stepNo;
  final String title;

  /// One text for the whole run (totals), English and Arabic lines mixed.
  final String? text;

  /// Per-jar portions, one line per size. Null for a whole-run step.
  final List<RecipeSheetStepLine>? perItem;
}

@immutable
class RecipeSheetStepLine {
  const RecipeSheetStepLine({
    this.itemCode = '',
    this.itemName = '',
    this.qty = 0,
    this.text = '',
  });

  factory RecipeSheetStepLine.fromJson(Map<String, dynamic> json) =>
      RecipeSheetStepLine(
        itemCode: _str(json['item_code']),
        itemName: _str(json['item_name']),
        qty: _num(json['qty']),
        text: _str(json['text']),
      );

  final String itemCode;
  final String itemName;
  final double qty;
  final String text;

  String get displayName => itemName.isEmpty ? itemCode : itemName;
}

String _str(Object? value) => value == null ? '' : value.toString().trim();

double _num(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

List<T> _mapList<T>(Object? raw, T Function(Map<String, dynamic>) parse) {
  if (raw is! List) return List<T>.unmodifiable(<T>[]);
  return List<T>.unmodifiable([
    for (final entry in raw)
      if (entry is Map) parse(Map<String, dynamic>.from(entry)),
  ]);
}

class MaterialOptions {
  const MaterialOptions({
    required this.bomName,
    required this.qty,
    required this.components,
  });

  factory MaterialOptions.fromJson(
    Map<String, dynamic> json,
  ) => MaterialOptions(
    bomName: json['bom_name']?.toString() ?? '',
    qty: (json['qty'] as num?)?.toDouble() ?? 0,
    components: (json['components'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (row) =>
              MaterialOptionComponent.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false),
  );

  final String bomName;
  final double qty;
  final List<MaterialOptionComponent> components;
}

class MaterialOptionComponent {
  const MaterialOptionComponent({
    required this.originalItemCode,
    required this.originalItemName,
    required this.requiredQty,
    required this.stockUom,
    required this.combinedAvailableQty,
    required this.linkedItemsDisplay,
    required this.alternativeSelectionBlockedReason,
    required this.options,
  });

  factory MaterialOptionComponent.fromJson(Map<String, dynamic> json) =>
      MaterialOptionComponent(
        originalItemCode: json['original_item_code']?.toString() ?? '',
        originalItemName: json['original_item_name']?.toString() ?? '',
        requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0,
        stockUom: json['stock_uom']?.toString() ?? '',
        combinedAvailableQty:
            (json['combined_available_qty'] as num?)?.toDouble() ?? 0,
        linkedItemsDisplay: json['linked_items_display']?.toString() ?? '',
        alternativeSelectionBlockedReason:
            json['alternative_selection_blocked_reason']?.toString(),
        options: (json['options'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (row) => MaterialOption.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );

  final String originalItemCode;
  final String originalItemName;
  final double requiredQty;
  final String stockUom;
  final double combinedAvailableQty;
  final String linkedItemsDisplay;
  final String? alternativeSelectionBlockedReason;
  final List<MaterialOption> options;

  bool get hasAlternatives => options.length > 1;
  bool get selectionBlocked =>
      alternativeSelectionBlockedReason?.trim().isNotEmpty == true;
}

class MaterialOption {
  const MaterialOption({
    required this.itemCode,
    required this.itemName,
    required this.brand,
    required this.stockUom,
    required this.availableQty,
    required this.valuationRate,
    required this.isRecipeItem,
    required this.sourceWarehouse,
    required this.uoms,
  });

  factory MaterialOption.fromJson(Map<String, dynamic> json) => MaterialOption(
    itemCode: json['item_code']?.toString() ?? '',
    itemName: json['item_name']?.toString() ?? '',
    brand: json['brand']?.toString() ?? '',
    stockUom: json['stock_uom']?.toString() ?? '',
    availableQty: (json['available_qty'] as num?)?.toDouble() ?? 0,
    valuationRate: (json['valuation_rate'] as num?)?.toDouble() ?? 0,
    isRecipeItem: json['is_recipe_item'] == true || json['is_recipe_item'] == 1,
    sourceWarehouse: json['source_warehouse']?.toString() ?? '',
    uoms: (json['uoms'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false),
  );

  final String itemCode;
  final String itemName;
  final String brand;
  final String stockUom;
  final double availableQty;
  final double valuationRate;
  final bool isRecipeItem;
  final String sourceWarehouse;
  final List<Map<String, dynamic>> uoms;

  String get displayName => itemName.trim().isEmpty ? itemCode : itemName;
}

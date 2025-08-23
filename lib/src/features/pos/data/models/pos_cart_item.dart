class PosCartItem {
  final String itemCode;
  final double quantity;
  final double rate;
  final bool isBundle;
  final double? priceListRate;
  final double? discountAmount; // per-unit discount amount
  final double? discountPercentage; // alternative percentage

  PosCartItem({
    required this.itemCode,
    required this.quantity,
    required this.rate,
    this.isBundle = false,
    this.priceListRate,
    this.discountAmount,
    this.discountPercentage,
  });

  PosCartItem copyWith({
    String? itemCode,
    double? quantity,
    double? rate,
    bool? isBundle,
    double? priceListRate,
    double? discountAmount,
    double? discountPercentage,
  }) => PosCartItem(
        itemCode: itemCode ?? this.itemCode,
        quantity: quantity ?? this.quantity,
        rate: rate ?? this.rate,
        isBundle: isBundle ?? this.isBundle,
        priceListRate: priceListRate ?? this.priceListRate,
        discountAmount: discountAmount ?? this.discountAmount,
        discountPercentage: discountPercentage ?? this.discountPercentage,
      );
}
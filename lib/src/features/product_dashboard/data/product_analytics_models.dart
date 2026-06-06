class ProductAnalyticsData {
  final PeriodInfo period;
  final ProductAnalyticsSummary summary;
  final List<ProductTypeMetrics> byProductType;
  final List<TopProduct> topProducts;
  final List<TerritoryMetrics> byTerritory;
  final List<TrendPoint> trend;
  final List<BundleCompositionItem> bundleComposition;

  const ProductAnalyticsData({
    required this.period,
    required this.summary,
    required this.byProductType,
    required this.topProducts,
    required this.byTerritory,
    required this.trend,
    required this.bundleComposition,
  });

  factory ProductAnalyticsData.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsData(
      period: PeriodInfo.fromJson(_map(json['period'])),
      summary: ProductAnalyticsSummary.fromJson(_map(json['summary'])),
      byProductType: _list(json['by_product_type'])
          .map((e) => ProductTypeMetrics.fromJson(_map(e)))
          .toList(),
      topProducts: _list(json['top_products'])
          .map((e) => TopProduct.fromJson(_map(e)))
          .toList(),
      byTerritory: _list(json['by_territory'])
          .map((e) => TerritoryMetrics.fromJson(_map(e)))
          .toList(),
      trend: _list(json['trend'])
          .map((e) => TrendPoint.fromJson(_map(e)))
          .toList(),
      bundleComposition: _list(json['bundle_composition'])
          .map((e) => BundleCompositionItem.fromJson(_map(e)))
          .toList(),
    );
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : {};
  static List _list(dynamic v) => v is List ? v : [];
}

class PeriodInfo {
  final String dateFrom;
  final String dateTo;

  const PeriodInfo({required this.dateFrom, required this.dateTo});

  factory PeriodInfo.fromJson(Map<String, dynamic> json) => PeriodInfo(
        dateFrom: json['date_from']?.toString() ?? '',
        dateTo: json['date_to']?.toString() ?? '',
      );
}

class ProductAnalyticsSummary {
  final double totalRevenue;
  final int totalOrders;
  final double totalGrossProfit;
  final double avgOrderValue;
  final BestSellingProduct bestSellingProduct;
  final TopTerritorySummary topTerritory;

  const ProductAnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalGrossProfit,
    required this.avgOrderValue,
    required this.bestSellingProduct,
    required this.topTerritory,
  });

  factory ProductAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsSummary(
      totalRevenue: _dbl(json['total_revenue']),
      totalOrders: _int(json['total_orders']),
      totalGrossProfit: _dbl(json['total_gross_profit']),
      avgOrderValue: _dbl(json['avg_order_value']),
      bestSellingProduct: BestSellingProduct.fromJson(
          json['best_selling_product'] is Map
              ? Map<String, dynamic>.from(json['best_selling_product'] as Map)
              : {}),
      topTerritory: TopTerritorySummary.fromJson(
          json['top_territory'] is Map
              ? Map<String, dynamic>.from(json['top_territory'] as Map)
              : {}),
    );
  }
}

class BestSellingProduct {
  final String itemName;
  final double totalQty;

  const BestSellingProduct({required this.itemName, required this.totalQty});

  factory BestSellingProduct.fromJson(Map<String, dynamic> json) =>
      BestSellingProduct(
        itemName: json['item_name']?.toString() ?? '',
        totalQty: _dbl(json['total_qty']),
      );
}

class TopTerritorySummary {
  final String territory;
  final double revenue;

  const TopTerritorySummary({required this.territory, required this.revenue});

  factory TopTerritorySummary.fromJson(Map<String, dynamic> json) =>
      TopTerritorySummary(
        territory: json['territory']?.toString() ?? '',
        revenue: _dbl(json['revenue']),
      );
}

class ProductTypeMetrics {
  final String type;
  final int units;
  final double revenue;
  final double cost;
  final double profit;
  final double marginPct;

  const ProductTypeMetrics({
    required this.type,
    required this.units,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.marginPct,
  });

  factory ProductTypeMetrics.fromJson(Map<String, dynamic> json) =>
      ProductTypeMetrics(
        type: json['type']?.toString() ?? '',
        units: _int(json['units']),
        revenue: _dbl(json['revenue']),
        cost: _dbl(json['cost']),
        profit: _dbl(json['profit']),
        marginPct: _dbl(json['margin_pct']),
      );
}

class TopProduct {
  final String itemCode;
  final String itemName;
  final String type;
  final double totalQty;
  final double totalRevenue;
  final double bomCostPerUnit;
  final double totalCost;
  final double grossProfit;
  final double marginPct;

  const TopProduct({
    required this.itemCode,
    required this.itemName,
    required this.type,
    required this.totalQty,
    required this.totalRevenue,
    required this.bomCostPerUnit,
    required this.totalCost,
    required this.grossProfit,
    required this.marginPct,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        itemCode: json['item_code']?.toString() ?? '',
        itemName: json['item_name']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        totalQty: _dbl(json['total_qty']),
        totalRevenue: _dbl(json['total_revenue']),
        bomCostPerUnit: _dbl(json['bom_cost_per_unit']),
        totalCost: _dbl(json['total_cost']),
        grossProfit: _dbl(json['gross_profit']),
        marginPct: _dbl(json['margin_pct']),
      );
}

class TerritoryMetrics {
  final String territory;
  final int orders;
  final double revenue;
  final double profit;

  const TerritoryMetrics({
    required this.territory,
    required this.orders,
    required this.revenue,
    required this.profit,
  });

  factory TerritoryMetrics.fromJson(Map<String, dynamic> json) =>
      TerritoryMetrics(
        territory: json['territory']?.toString() ?? '',
        orders: _int(json['orders']),
        revenue: _dbl(json['revenue']),
        profit: _dbl(json['profit']),
      );
}

class TrendPoint {
  final String date;
  final double revenue;
  final int orders;

  const TrendPoint(
      {required this.date, required this.revenue, required this.orders});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
        date: json['date']?.toString() ?? '',
        revenue: _dbl(json['revenue']),
        orders: _int(json['orders']),
      );
}

class BundleCompositionItem {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final double timesInBundle;
  final double revenue;

  const BundleCompositionItem({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.timesInBundle,
    required this.revenue,
  });

  factory BundleCompositionItem.fromJson(Map<String, dynamic> json) =>
      BundleCompositionItem(
        itemCode: json['item_code']?.toString() ?? '',
        itemName: json['item_name']?.toString() ?? '',
        itemGroup: json['item_group']?.toString() ?? '',
        timesInBundle: _dbl(json['times_in_bundle']),
        revenue: _dbl(json['revenue']),
      );
}

double _dbl(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

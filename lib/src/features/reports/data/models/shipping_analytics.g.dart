// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShippingAnalyticsImpl _$$ShippingAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingAnalyticsImpl(
  summaryKpis: json['summary_kpis'] == null
      ? const ShippingSummaryKpis()
      : ShippingSummaryKpis.fromJson(
          json['summary_kpis'] as Map<String, dynamic>,
        ),
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => ShippingAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ShippingAlert>[],
  costByTerritory:
      (json['cost_by_territory'] as List<dynamic>?)
          ?.map(
            (e) => ShippingTerritoryCost.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ShippingTerritoryCost>[],
  costBySubTerritory:
      (json['cost_by_sub_territory'] as List<dynamic>?)
          ?.map(
            (e) => ShippingSubTerritoryCost.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ShippingSubTerritoryCost>[],
  costByPosProfile:
      (json['cost_by_pos_profile'] as List<dynamic>?)
          ?.map(
            (e) => ShippingPosProfileCost.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ShippingPosProfileCost>[],
  costByCourier:
      (json['cost_by_courier'] as List<dynamic>?)
          ?.map((e) => ShippingCourierCost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ShippingCourierCost>[],
  customShippingBreakdown: json['custom_shipping_breakdown'] == null
      ? const ShippingCustomBreakdown()
      : ShippingCustomBreakdown.fromJson(
          json['custom_shipping_breakdown'] as Map<String, dynamic>,
        ),
  doubleShippingImpact: json['double_shipping_impact'] == null
      ? const ShippingDoubleImpact()
      : ShippingDoubleImpact.fromJson(
          json['double_shipping_impact'] as Map<String, dynamic>,
        ),
  dailyTrend:
      (json['daily_trend'] as List<dynamic>?)
          ?.map(
            (e) => ShippingDailyTrendPoint.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ShippingDailyTrendPoint>[],
  pickupVsDeliverySplit: json['pickup_vs_delivery_split'] == null
      ? const ShippingPickupDeliverySplit()
      : ShippingPickupDeliverySplit.fromJson(
          json['pickup_vs_delivery_split'] as Map<String, dynamic>,
        ),
  unsettledCourierBalances:
      (json['unsettled_courier_balances'] as List<dynamic>?)
          ?.map(
            (e) => ShippingUnsettledCourierBalance.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <ShippingUnsettledCourierBalance>[],
  pickupDeliveryTrend:
      (json['pickup_delivery_trend'] as List<dynamic>?)
          ?.map(
            (e) => ShippingPickupDeliveryTrendPoint.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <ShippingPickupDeliveryTrendPoint>[],
);

Map<String, dynamic> _$$ShippingAnalyticsImplToJson(
  _$ShippingAnalyticsImpl instance,
) => <String, dynamic>{
  'summary_kpis': instance.summaryKpis,
  'alerts': instance.alerts,
  'cost_by_territory': instance.costByTerritory,
  'cost_by_sub_territory': instance.costBySubTerritory,
  'cost_by_pos_profile': instance.costByPosProfile,
  'cost_by_courier': instance.costByCourier,
  'custom_shipping_breakdown': instance.customShippingBreakdown,
  'double_shipping_impact': instance.doubleShippingImpact,
  'daily_trend': instance.dailyTrend,
  'pickup_vs_delivery_split': instance.pickupVsDeliverySplit,
  'unsettled_courier_balances': instance.unsettledCourierBalances,
  'pickup_delivery_trend': instance.pickupDeliveryTrend,
};

_$ShippingSummaryKpisImpl _$$ShippingSummaryKpisImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingSummaryKpisImpl(
  totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
  deliveryOrders: (json['delivery_orders'] as num?)?.toInt() ?? 0,
  pickupOrders: (json['pickup_orders'] as num?)?.toInt() ?? 0,
  totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
  totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
  netPl: (json['net_pl'] as num?)?.toDouble() ?? 0,
  avgCostPerOrder: (json['avg_cost_per_order'] as num?)?.toDouble() ?? 0,
  pendingCsrCount: (json['pending_csr_count'] as num?)?.toInt() ?? 0,
  unsettledCourierTotal:
      (json['unsettled_courier_total'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingSummaryKpisImplToJson(
  _$ShippingSummaryKpisImpl instance,
) => <String, dynamic>{
  'total_orders': instance.totalOrders,
  'delivery_orders': instance.deliveryOrders,
  'pickup_orders': instance.pickupOrders,
  'total_expense': instance.totalExpense,
  'total_income': instance.totalIncome,
  'net_pl': instance.netPl,
  'avg_cost_per_order': instance.avgCostPerOrder,
  'pending_csr_count': instance.pendingCsrCount,
  'unsettled_courier_total': instance.unsettledCourierTotal,
};

_$ShippingAlertImpl _$$ShippingAlertImplFromJson(Map<String, dynamic> json) =>
    _$ShippingAlertImpl(
      type: json['type'] as String? ?? 'info',
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$$ShippingAlertImplToJson(_$ShippingAlertImpl instance) =>
    <String, dynamic>{'type': instance.type, 'message': instance.message};

_$ShippingTerritoryCostImpl _$$ShippingTerritoryCostImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingTerritoryCostImpl(
  territory: json['territory'] as String? ?? '',
  orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
  totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
  totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
  netPl: (json['net_pl'] as num?)?.toDouble() ?? 0,
  avgCost: (json['avg_cost'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingTerritoryCostImplToJson(
  _$ShippingTerritoryCostImpl instance,
) => <String, dynamic>{
  'territory': instance.territory,
  'order_count': instance.orderCount,
  'total_expense': instance.totalExpense,
  'total_income': instance.totalIncome,
  'net_pl': instance.netPl,
  'avg_cost': instance.avgCost,
};

_$ShippingSubTerritoryCostImpl _$$ShippingSubTerritoryCostImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingSubTerritoryCostImpl(
  subTerritory: json['sub_territory'] as String? ?? '',
  totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingSubTerritoryCostImplToJson(
  _$ShippingSubTerritoryCostImpl instance,
) => <String, dynamic>{
  'sub_territory': instance.subTerritory,
  'total_expense': instance.totalExpense,
};

_$ShippingPosProfileCostImpl _$$ShippingPosProfileCostImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingPosProfileCostImpl(
  branch: json['branch'] as String? ?? '',
  totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
  totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
  avgCost: (json['avg_cost'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingPosProfileCostImplToJson(
  _$ShippingPosProfileCostImpl instance,
) => <String, dynamic>{
  'branch': instance.branch,
  'total_expense': instance.totalExpense,
  'total_income': instance.totalIncome,
  'avg_cost': instance.avgCost,
};

_$ShippingCourierCostImpl _$$ShippingCourierCostImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingCourierCostImpl(
  party: json['party'] as String? ?? '',
  settled: (json['settled'] as num?)?.toDouble() ?? 0,
  unsettled: (json['unsettled'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingCourierCostImplToJson(
  _$ShippingCourierCostImpl instance,
) => <String, dynamic>{
  'party': instance.party,
  'settled': instance.settled,
  'unsettled': instance.unsettled,
};

_$ShippingCustomBreakdownImpl _$$ShippingCustomBreakdownImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingCustomBreakdownImpl(
  summary: json['summary'] == null
      ? const ShippingCustomBreakdownSummary()
      : ShippingCustomBreakdownSummary.fromJson(
          json['summary'] as Map<String, dynamic>,
        ),
  rows:
      (json['rows'] as List<dynamic>?)
          ?.map(
            (e) =>
                ShippingCustomBreakdownRow.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ShippingCustomBreakdownRow>[],
);

Map<String, dynamic> _$$ShippingCustomBreakdownImplToJson(
  _$ShippingCustomBreakdownImpl instance,
) => <String, dynamic>{'summary': instance.summary, 'rows': instance.rows};

_$ShippingCustomBreakdownSummaryImpl
_$$ShippingCustomBreakdownSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ShippingCustomBreakdownSummaryImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      approvalRate: (json['approval_rate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$ShippingCustomBreakdownSummaryImplToJson(
  _$ShippingCustomBreakdownSummaryImpl instance,
) => <String, dynamic>{
  'total': instance.total,
  'approved': instance.approved,
  'rejected': instance.rejected,
  'pending': instance.pending,
  'approval_rate': instance.approvalRate,
};

_$ShippingCustomBreakdownRowImpl _$$ShippingCustomBreakdownRowImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingCustomBreakdownRowImpl(
  invoice: json['invoice'] as String? ?? '',
  wooOrderId: (json['woo_order_id'] as num?)?.toInt(),
  territory: json['territory'] as String? ?? '',
  originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0,
  requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0,
  delta: (json['delta'] as num?)?.toDouble() ?? 0,
  isLargeOverride: json['is_large_override'] as bool? ?? false,
  status: json['status'] as String? ?? '',
);

Map<String, dynamic> _$$ShippingCustomBreakdownRowImplToJson(
  _$ShippingCustomBreakdownRowImpl instance,
) => <String, dynamic>{
  'invoice': instance.invoice,
  'woo_order_id': instance.wooOrderId,
  'territory': instance.territory,
  'original_amount': instance.originalAmount,
  'requested_amount': instance.requestedAmount,
  'delta': instance.delta,
  'is_large_override': instance.isLargeOverride,
  'status': instance.status,
};

_$ShippingDoubleImpactImpl _$$ShippingDoubleImpactImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingDoubleImpactImpl(
  totalDoubleTrips: (json['total_double_trips'] as num?)?.toInt() ?? 0,
  totalExtraCost: (json['total_extra_cost'] as num?)?.toDouble() ?? 0,
  trips:
      (json['trips'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const <JsonMap>[],
);

Map<String, dynamic> _$$ShippingDoubleImpactImplToJson(
  _$ShippingDoubleImpactImpl instance,
) => <String, dynamic>{
  'total_double_trips': instance.totalDoubleTrips,
  'total_extra_cost': instance.totalExtraCost,
  'trips': instance.trips,
};

_$ShippingDailyTrendPointImpl _$$ShippingDailyTrendPointImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingDailyTrendPointImpl(
  postingDate: json['posting_date'] as String? ?? '',
  orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
  totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
  totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$ShippingDailyTrendPointImplToJson(
  _$ShippingDailyTrendPointImpl instance,
) => <String, dynamic>{
  'posting_date': instance.postingDate,
  'order_count': instance.orderCount,
  'total_expense': instance.totalExpense,
  'total_income': instance.totalIncome,
};

_$ShippingPickupDeliverySplitImpl _$$ShippingPickupDeliverySplitImplFromJson(
  Map<String, dynamic> json,
) => _$ShippingPickupDeliverySplitImpl(
  pickup: (json['pickup'] as num?)?.toInt() ?? 0,
  delivery: (json['delivery'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ShippingPickupDeliverySplitImplToJson(
  _$ShippingPickupDeliverySplitImpl instance,
) => <String, dynamic>{
  'pickup': instance.pickup,
  'delivery': instance.delivery,
};

_$ShippingUnsettledCourierBalanceImpl
_$$ShippingUnsettledCourierBalanceImplFromJson(Map<String, dynamic> json) =>
    _$ShippingUnsettledCourierBalanceImpl(
      party: json['party'] as String? ?? '',
      partyType: json['party_type'] as String? ?? '',
      orderCount: (json['order_count'] as num?)?.toInt() ?? 0,
      totalOwed: (json['total_owed'] as num?)?.toDouble() ?? 0,
      oldestDate: json['oldest_date'] as String? ?? '',
      daysAged: (json['days_aged'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ShippingUnsettledCourierBalanceImplToJson(
  _$ShippingUnsettledCourierBalanceImpl instance,
) => <String, dynamic>{
  'party': instance.party,
  'party_type': instance.partyType,
  'order_count': instance.orderCount,
  'total_owed': instance.totalOwed,
  'oldest_date': instance.oldestDate,
  'days_aged': instance.daysAged,
};

_$ShippingPickupDeliveryTrendPointImpl
_$$ShippingPickupDeliveryTrendPointImplFromJson(Map<String, dynamic> json) =>
    _$ShippingPickupDeliveryTrendPointImpl(
      postingDate: json['posting_date'] as String? ?? '',
      pickup: (json['pickup'] as num?)?.toInt() ?? 0,
      delivery: (json['delivery'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ShippingPickupDeliveryTrendPointImplToJson(
  _$ShippingPickupDeliveryTrendPointImpl instance,
) => <String, dynamic>{
  'posting_date': instance.postingDate,
  'pickup': instance.pickup,
  'delivery': instance.delivery,
};

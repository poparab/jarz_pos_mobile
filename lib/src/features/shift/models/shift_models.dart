class ShiftBalanceDetail {
  final String modeOfPayment;
  final double openingAmount;
  final double expectedAmount;
  final double closingAmount;
  final double difference;

  const ShiftBalanceDetail({
    required this.modeOfPayment,
    this.openingAmount = 0,
    this.expectedAmount = 0,
    this.closingAmount = 0,
    this.difference = 0,
  });

  factory ShiftBalanceDetail.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ShiftBalanceDetail(
      modeOfPayment: (json['mode_of_payment'] ?? '').toString(),
      openingAmount: toDouble(json['opening_amount']),
      expectedAmount: toDouble(json['expected_amount']),
      closingAmount: toDouble(json['closing_amount']),
      difference: toDouble(json['difference']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode_of_payment': modeOfPayment,
      'opening_amount': openingAmount,
      'expected_amount': expectedAmount,
      'closing_amount': closingAmount,
      'difference': difference,
    };
  }
}

class ShiftEntry {
  final String name;
  final String posProfile;
  final String status;
  final DateTime? periodStartDate;
  final List<ShiftBalanceDetail> balanceDetails;

  const ShiftEntry({
    required this.name,
    required this.posProfile,
    required this.status,
    this.periodStartDate,
    this.balanceDetails = const [],
  });

  factory ShiftEntry.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final balancesRaw = json['balance_details'];
    final balances = balancesRaw is List
        ? balancesRaw
            .whereType<Map>()
            .map((e) => ShiftBalanceDetail.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ShiftBalanceDetail>[];

    return ShiftEntry(
      name: (json['name'] ?? json['opening_entry'] ?? '').toString(),
      posProfile: (json['pos_profile'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      periodStartDate: parseDate(json['period_start_date']),
      balanceDetails: balances,
    );
  }
}

class ShiftSummary {
  final String openingEntry;
  final String status;
  final DateTime? periodStartDate;
  final int invoiceCount;
  final double grandTotal;
  final double netTotal;
  final List<ShiftBalanceDetail> paymentReconciliation;

  const ShiftSummary({
    required this.openingEntry,
    required this.status,
    this.periodStartDate,
    this.invoiceCount = 0,
    this.grandTotal = 0,
    this.netTotal = 0,
    this.paymentReconciliation = const [],
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    final reconciliationRaw = json['payment_reconciliation'];
    final reconciliation = reconciliationRaw is List
        ? reconciliationRaw
            .whereType<Map>()
            .map((e) => ShiftBalanceDetail.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ShiftBalanceDetail>[];

    return ShiftSummary(
      openingEntry: (json['opening_entry'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      periodStartDate: DateTime.tryParse((json['period_start_date'] ?? '').toString()),
      invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
      grandTotal: toDouble(json['grand_total']),
      netTotal: toDouble(json['net_total']),
      paymentReconciliation: reconciliation,
    );
  }
}

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

class ShiftInvoice {
  final String name;
  final String customer;
  final String customerName;
  final double grandTotal;
  final double netTotal;
  final String status;
  final String? postingDate;
  final String? creation;
  final String? deliveryStatus;

  const ShiftInvoice({
    required this.name,
    required this.customer,
    required this.customerName,
    this.grandTotal = 0,
    this.netTotal = 0,
    this.status = '',
    this.postingDate,
    this.creation,
    this.deliveryStatus,
  });

  factory ShiftInvoice.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ShiftInvoice(
      name: (json['name'] ?? '').toString(),
      customer: (json['customer'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      grandTotal: toDouble(json['grand_total']),
      netTotal: toDouble(json['net_total']),
      status: (json['status'] ?? '').toString(),
      postingDate: json['posting_date']?.toString(),
      creation: json['creation']?.toString(),
      deliveryStatus: json['delivery_status']?.toString(),
    );
  }
}

class ShiftAccountMovement {
  final String name;
  final String voucherType;
  final String voucherNo;
  final double debit;
  final double credit;
  final double amount;
  final String? postingDate;
  final String? creation;
  final String? against;
  final String? remarks;

  const ShiftAccountMovement({
    required this.name,
    required this.voucherType,
    required this.voucherNo,
    this.debit = 0,
    this.credit = 0,
    this.amount = 0,
    this.postingDate,
    this.creation,
    this.against,
    this.remarks,
  });

  factory ShiftAccountMovement.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ShiftAccountMovement(
      name: (json['name'] ?? '').toString(),
      voucherType: (json['voucher_type'] ?? '').toString(),
      voucherNo: (json['voucher_no'] ?? '').toString(),
      debit: toDouble(json['debit']),
      credit: toDouble(json['credit']),
      amount: toDouble(json['amount']),
      postingDate: json['posting_date']?.toString(),
      creation: json['creation']?.toString(),
      against: json['against']?.toString(),
      remarks: json['remarks']?.toString(),
    );
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
  final List<ShiftInvoice> salesInvoices;
  final List<ShiftAccountMovement> accountMovements;
  final String? account;
  final double accountBalance;
  final double totalSales;
  final double totalOutflows;
  final double netMovement;
  final String? journalEntry;
  final String? closingEntry;

  const ShiftSummary({
    required this.openingEntry,
    required this.status,
    this.periodStartDate,
    this.invoiceCount = 0,
    this.grandTotal = 0,
    this.netTotal = 0,
    this.paymentReconciliation = const [],
    this.salesInvoices = const [],
    this.accountMovements = const [],
    this.account,
    this.accountBalance = 0,
    this.totalSales = 0,
    this.totalOutflows = 0,
    this.netMovement = 0,
    this.journalEntry,
    this.closingEntry,
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

    final invoicesRaw = json['sales_invoices'];
    final invoices = invoicesRaw is List
        ? invoicesRaw
            .whereType<Map>()
            .map((e) => ShiftInvoice.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ShiftInvoice>[];

    final movementsRaw = json['account_movements'];
    final movements = movementsRaw is List
      ? movementsRaw
        .whereType<Map>()
        .map((e) => ShiftAccountMovement.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      : <ShiftAccountMovement>[];

    return ShiftSummary(
      openingEntry: (json['opening_entry'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      periodStartDate: DateTime.tryParse((json['period_start_date'] ?? '').toString()),
      invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
      grandTotal: toDouble(json['grand_total']),
      netTotal: toDouble(json['net_total']),
      paymentReconciliation: reconciliation,
      salesInvoices: invoices,
      accountMovements: movements,
      account: json['account']?.toString(),
      accountBalance: toDouble(json['account_balance']),
      totalSales: toDouble(json['total_sales']),
      totalOutflows: toDouble(json['total_outflows']),
      netMovement: toDouble(json['net_movement']),
      journalEntry: json['journal_entry']?.toString(),
      closingEntry: json['closing_entry']?.toString(),
    );
  }
}

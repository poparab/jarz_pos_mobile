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
  final String openedByUser;
  final String openedByName;
  final bool isCurrentUser;
  final DateTime? periodStartDate;
  final List<ShiftBalanceDetail> balanceDetails;

  const ShiftEntry({
    required this.name,
    required this.posProfile,
    required this.status,
    this.openedByUser = '',
    this.openedByName = '',
    this.isCurrentUser = true,
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
      openedByUser: (json['user'] ?? json['owner'] ?? json['created_by'] ?? '').toString(),
      openedByName: (
        json['employee_name'] ??
        json['full_name'] ??
        json['user_fullname'] ??
        json['user_full_name'] ??
        json['opened_by_name'] ??
        ''
      ).toString(),
      isCurrentUser: json['is_current_user'] == 1 || json['is_current_user'] == true,
      periodStartDate: parseDate(json['period_start_date']),
      balanceDetails: balances,
    );
  }
}

class ShiftCourierCloseParty {
  final String partyType;
  final String party;
  final String displayName;
  final int transactionCount;
  final int invoiceCount;
  final double netBalance;
  final List<String> invoices;

  const ShiftCourierCloseParty({
    required this.partyType,
    required this.party,
    required this.displayName,
    this.transactionCount = 0,
    this.invoiceCount = 0,
    this.netBalance = 0,
    this.invoices = const [],
  });

  factory ShiftCourierCloseParty.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final invoicesRaw = json['invoices'];
    final invoices = invoicesRaw is List
        ? invoicesRaw.map((invoice) => invoice.toString()).where((invoice) => invoice.isNotEmpty).toList()
        : <String>[];

    return ShiftCourierCloseParty(
      partyType: (json['party_type'] ?? '').toString(),
      party: (json['party'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      transactionCount: toInt(json['transaction_count']),
      invoiceCount: toInt(json['invoice_count']),
      netBalance: toDouble(json['net_balance']),
      invoices: invoices,
    );
  }
}

class ShiftCourierCloseBlock {
  final bool blocked;
  final String posProfile;
  final int transactionCount;
  final int invoiceCount;
  final int partyCount;
  final double netBalance;
  final List<ShiftCourierCloseParty> parties;

  const ShiftCourierCloseBlock({
    required this.blocked,
    required this.posProfile,
    this.transactionCount = 0,
    this.invoiceCount = 0,
    this.partyCount = 0,
    this.netBalance = 0,
    this.parties = const [],
  });

  factory ShiftCourierCloseBlock.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    final partiesRaw = json['parties'];
    final parties = partiesRaw is List
        ? partiesRaw
            .whereType<Map>()
            .map((party) => ShiftCourierCloseParty.fromJson(Map<String, dynamic>.from(party)))
            .toList()
        : <ShiftCourierCloseParty>[];

    return ShiftCourierCloseBlock(
      blocked: toBool(json['blocked']),
      posProfile: (json['pos_profile'] ?? '').toString(),
      transactionCount: toInt(json['transaction_count']),
      invoiceCount: toInt(json['invoice_count']),
      partyCount: toInt(json['party_count']),
      netBalance: toDouble(json['net_balance']),
      parties: parties,
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
  final bool amountsHidden;
  final bool varianceVisible;
  final ShiftCourierCloseBlock? courierCloseBlock;

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
    this.amountsHidden = false,
    this.varianceVisible = false,
    this.courierCloseBlock,
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
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
    final courierCloseBlockRaw = json['courier_close_block'];

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
      amountsHidden: toBool(json['amounts_hidden']),
      varianceVisible: toBool(json['variance_visible']),
      courierCloseBlock: courierCloseBlockRaw is Map
          ? ShiftCourierCloseBlock.fromJson(Map<String, dynamic>.from(courierCloseBlockRaw))
          : null,
    );
  }
}

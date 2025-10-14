import 'dart:convert';

import 'package:intl/intl.dart';

class ExpensePaymentSource {
  final String id;
  final String account;
  final String label;
  final String category;
  final double balance;
  final String? posProfile;

  const ExpensePaymentSource({
    required this.id,
    required this.account,
    required this.label,
    required this.category,
    required this.balance,
    this.posProfile,
  });

  bool get isPosProfile => category == 'pos_profile';
  bool get isCash => category == 'cash';
  bool get isBank => category == 'bank';
  bool get isMobile => category == 'mobile';

  String get displayBalance => NumberFormat.currency(symbol: '').format(balance);

  factory ExpensePaymentSource.fromJson(Map<String, dynamic> json) {
    double parseBalance(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return ExpensePaymentSource(
      id: (json['id'] ?? json['account'] ?? '').toString(),
      account: (json['account'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      category: (json['category'] ?? 'account').toString(),
      balance: parseBalance(json['balance']),
      posProfile: json['pos_profile']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'label': label,
      'category': category,
      'balance': balance,
      'pos_profile': posProfile,
    };
  }
}

class ExpenseReason {
  final String account;
  final String label;

  const ExpenseReason({required this.account, required this.label});

  factory ExpenseReason.fromJson(Map<String, dynamic> json) {
    return ExpenseReason(
      account: (json['account'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'account': account, 'label': label};
}

class ExpenseTimelineEvent {
  final String label;
  final DateTime? timestamp;
  final String? user;

  const ExpenseTimelineEvent({required this.label, this.timestamp, this.user});

  factory ExpenseTimelineEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseTs(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return ExpenseTimelineEvent(
      label: (json['label'] ?? '').toString(),
      timestamp: parseTs(json['timestamp']),
      user: json['user']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'timestamp': timestamp?.toIso8601String(),
        'user': user,
      };
}

class ExpenseRecord {
  final String name;
  final DateTime? expenseDate;
  final double amount;
  final String? currency;
  final String reasonAccount;
  final String reasonLabel;
  final String payingAccount;
  final String paymentLabel;
  final String? paymentSourceType;
  final String? posProfile;
  final bool requiresApproval;
  final int docstatus;
  final String status;
  final String? requestedBy;
  final String? approvedBy;
  final DateTime? approvedOn;
  final String? remarks;
  final String? journalEntry;
  final String? company;
  final DateTime? createdOn;
  final DateTime? modifiedOn;
  final List<ExpenseTimelineEvent> timeline;

  bool get isPending => docstatus == 0 && requiresApproval;
  bool get isApproved => docstatus == 1;

  const ExpenseRecord({
    required this.name,
    required this.expenseDate,
    required this.amount,
    required this.currency,
    required this.reasonAccount,
    required this.reasonLabel,
    required this.payingAccount,
    required this.paymentLabel,
    required this.paymentSourceType,
    required this.posProfile,
    required this.requiresApproval,
    required this.docstatus,
    required this.status,
    required this.requestedBy,
    required this.approvedBy,
    required this.approvedOn,
    required this.remarks,
    required this.journalEntry,
    required this.company,
    required this.createdOn,
    required this.modifiedOn,
    required this.timeline,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    double parseAmount(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    List<ExpenseTimelineEvent> parseTimeline(dynamic value) {
      if (value is List) {
        return value
            .map((item) => ExpenseTimelineEvent.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(value) as List;
          return decoded
              .map((item) => ExpenseTimelineEvent.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        } catch (_) {
          return const [];
        }
      }
      return const [];
    }

    return ExpenseRecord(
      name: (json['name'] ?? '').toString(),
      expenseDate: parseDate(json['expense_date']),
      amount: parseAmount(json['amount']),
      currency: json['currency']?.toString(),
      reasonAccount: (json['reason_account'] ?? '').toString(),
      reasonLabel: (json['reason_label'] ?? '').toString(),
      payingAccount: (json['paying_account'] ?? '').toString(),
      paymentLabel: (json['payment_label'] ?? '').toString(),
      paymentSourceType: json['payment_source_type']?.toString(),
      posProfile: json['pos_profile']?.toString(),
      requiresApproval: json['requires_approval'] == true || json['requires_approval'] == 1 || json['requires_approval'] == '1',
      docstatus: int.tryParse(json['docstatus']?.toString() ?? '') ?? 0,
      status: (json['status'] ?? '').toString(),
      requestedBy: json['requested_by']?.toString(),
      approvedBy: json['approved_by']?.toString(),
      approvedOn: parseDate(json['approved_on']),
      remarks: json['remarks']?.toString(),
      journalEntry: json['journal_entry']?.toString(),
      company: json['company']?.toString(),
      createdOn: parseDate(json['creation']),
      modifiedOn: parseDate(json['modified']),
      timeline: parseTimeline(json['timeline']),
    );
  }
}

class ExpenseSummary {
  final double totalAmount;
  final int pendingCount;
  final double pendingAmount;
  final int approvedCount;

  const ExpenseSummary({
    required this.totalAmount,
    required this.pendingCount,
    required this.pendingAmount,
    required this.approvedCount,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ExpenseSummary(
        totalAmount: 0,
        pendingCount: 0,
        pendingAmount: 0,
        approvedCount: 0,
      );
    }

    double parse(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return ExpenseSummary(
      totalAmount: parse(json['total_amount']),
      pendingCount: int.tryParse(json['pending_count']?.toString() ?? '') ?? 0,
      pendingAmount: parse(json['pending_amount']),
      approvedCount: int.tryParse(json['approved_count']?.toString() ?? '') ?? 0,
    );
  }
}

class ExpenseMonthOption {
  final String id;
  final String label;

  const ExpenseMonthOption({required this.id, required this.label});

  factory ExpenseMonthOption.fromJson(Map<String, dynamic> json) {
    return ExpenseMonthOption(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class ExpenseBootstrap {
  final bool isManager;
  final String currentMonth;
  final String requestedMonth;
  final List<ExpenseMonthOption> months;
  final List<ExpensePaymentSource> paymentSources;
  final List<ExpenseReason> reasons;
  final List<ExpenseRecord> expenses;
  final ExpenseSummary summary;
  final List<String> appliedPaymentIds;

  const ExpenseBootstrap({
    required this.isManager,
    required this.currentMonth,
    required this.requestedMonth,
    required this.months,
    required this.paymentSources,
    required this.reasons,
    required this.expenses,
    required this.summary,
    required this.appliedPaymentIds,
  });

  factory ExpenseBootstrap.fromJson(Map<String, dynamic> json) {
    final monthsData = (json['months'] as List?) ?? const [];
    final sourcesData = (json['payment_sources'] as List?) ?? const [];
    final reasonsData = (json['reasons'] as List?) ?? const [];
    final expensesData = (json['expenses'] as List?) ?? const [];
    final applied = (json['applied_filters']?['payment_ids'] as List?) ?? const [];

    return ExpenseBootstrap(
      isManager: json['is_manager'] == true,
      currentMonth: (json['current_month'] ?? '').toString(),
      requestedMonth: (json['requested_month'] ?? '').toString(),
      months: monthsData
          .map((item) => ExpenseMonthOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      paymentSources: sourcesData
          .map((item) => ExpensePaymentSource.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      reasons: reasonsData
          .map((item) => ExpenseReason.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      expenses: expensesData
          .map((item) => ExpenseRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      summary: ExpenseSummary.fromJson(json['summary'] as Map<String, dynamic>?),
      appliedPaymentIds: applied.map((e) => e.toString()).toList(),
    );
  }
}

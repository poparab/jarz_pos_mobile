import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

final managerApiProvider = Provider<ManagerApi>((ref) {
  final dio = ref.read(dioProvider);
  return ManagerApi(dio);
});

class ManagerApi {
  final Dio _dio;
  ManagerApi(this._dio);

  Future<DashboardSummary> getSummary({String? company}) async {
    final resp = await _dio.get(
      '/api/method/jarz_pos.jarz_pos.api.manager.get_manager_dashboard_summary',
      queryParameters: {if (company != null) 'company': company},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    return DashboardSummary.fromJson(data['message'] ?? data);
  }

  Future<List<ManagerInvoice>> getOrders({String? branch, String? state, int limit = 200}) async {
    final resp = await _dio.get(
      '/api/method/jarz_pos.jarz_pos.api.manager.get_manager_orders',
      queryParameters: {
        if (branch != null) 'branch': branch,
        if (state != null) 'state': state,
        'limit': limit,
      },
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final list = (data['message'] ?? data)['invoices'] as List<dynamic>? ?? const [];
    return list.map((j) => ManagerInvoice.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getStates() async {
    final resp = await _dio.get(
      '/api/method/jarz_pos.jarz_pos.api.manager.get_manager_states',
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final list = (data['message'] ?? data)['states'] as List<dynamic>? ?? const [];
    return list.map((e) => e.toString()).toList();
  }

  Future<void> updateInvoiceBranch({required String invoiceId, required String newBranch}) async {
    final resp = await _dio.post(
      '/api/method/jarz_pos.jarz_pos.api.manager.update_invoice_branch',
      data: {'invoice_id': invoiceId, 'new_branch': newBranch},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    if (!((data['message'] ?? data)['success'] == true)) {
      throw Exception('Failed to update branch');
    }
  }
}

class DashboardSummary {
  final List<BranchBalance> branches;
  final double totalBalance;
  DashboardSummary({required this.branches, required this.totalBalance});
  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        branches: (json['branches'] as List<dynamic>? ?? const [])
            .map((e) => BranchBalance.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      );
}

class BranchBalance {
  final String name;
  final String title;
  final String? cashAccount;
  final double balance;
  BranchBalance({required this.name, required this.title, required this.cashAccount, required this.balance});
  factory BranchBalance.fromJson(Map<String, dynamic> json) => BranchBalance(
        name: json['name'] as String,
        title: (json['title'] as String?) ?? json['name'] as String,
        cashAccount: json['cash_account'] as String?,
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      );
}

class ManagerInvoice {
  final String name;
  final String customer;
  final String customerName;
  final String postingDate;
  final String postingTime;
  final double grandTotal;
  final double netTotal;
  final String status;
  final String branch;
  // convenience for UI
  String get branchName => branch;
  ManagerInvoice({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.postingDate,
    required this.postingTime,
    required this.grandTotal,
    required this.netTotal,
    required this.status,
    required this.branch,
  });
  factory ManagerInvoice.fromJson(Map<String, dynamic> json) => ManagerInvoice(
        name: json['name'] as String,
        customer: json['customer'] as String,
        customerName: (json['customer_name'] as String?) ?? (json['customer'] as String),
        postingDate: json['posting_date'] as String,
        postingTime: json['posting_time'] as String,
        grandTotal: (json['grand_total'] as num).toDouble(),
        netTotal: (json['net_total'] as num).toDouble(),
        status: json['status'] as String,
        branch: json['branch'] as String,
      );
}

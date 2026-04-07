import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';

final managerApiProvider = Provider<ManagerApi>((ref) {
  final dio = ref.read(dioProvider);
  return ManagerApi(dio);
});

class ManagerApi {
  final Dio _dio;
  ManagerApi(this._dio);

  Future<DashboardSummary> getSummary({String? company}) async {
    final resp = await _dio.get(
      ApiEndpoints.getManagerDashboardSummary,
      queryParameters: {if (company != null) 'company': company},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    return DashboardSummary.fromJson(data['message'] ?? data);
  }

  Future<List<ManagerInvoice>> getOrders({String? branch, String? state, int limit = 200}) async {
    final resp = await _dio.get(
      ApiEndpoints.getManagerOrders,
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
      ApiEndpoints.getManagerStates,
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final list = (data['message'] ?? data)['states'] as List<dynamic>? ?? const [];
    return list.map((e) => e.toString()).toList();
  }

  Future<void> updateInvoiceBranch({required String invoiceId, required String newBranch}) async {
    final resp = await _dio.post(
      ApiEndpoints.updateInvoiceBranch,
      data: {'invoice_id': invoiceId, 'new_branch': newBranch},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    if (!((data['message'] ?? data)['success'] == true)) {
      throw Exception('Failed to update branch');
    }
  }

  Future<List<CustomShippingRequest>> getPendingCustomShippingRequests() async {
    final resp = await _dio.get(ApiEndpoints.getPendingCustomShippingRequests);
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    final ok = (msg is Map<String, dynamic>) ? (msg['success'] == true) : false;
    if (!ok) {
      throw Exception('Failed to fetch pending custom shipping requests');
    }
    final list = (msg['data'] as List<dynamic>? ?? const []);
    return list
        .map((j) => CustomShippingRequest.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveCustomShipping(String requestName) async {
    final resp = await _dio.post(
      ApiEndpoints.approveCustomShipping,
      data: {'request_name': requestName},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    if (!((msg is Map<String, dynamic>) && msg['success'] == true)) {
      throw Exception((msg is Map<String, dynamic>) ? (msg['message'] ?? 'Failed to approve') : 'Failed to approve');
    }
  }

  Future<void> rejectCustomShipping(String requestName, {String reason = ''}) async {
    final resp = await _dio.post(
      ApiEndpoints.rejectCustomShipping,
      data: {'request_name': requestName, 'rejection_reason': reason},
    );
    final data = resp.data is String ? json.decode(resp.data) : resp.data;
    final msg = data['message'] ?? data;
    if (!((msg is Map<String, dynamic>) && msg['success'] == true)) {
      throw Exception((msg is Map<String, dynamic>) ? (msg['message'] ?? 'Failed to reject') : 'Failed to reject');
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

class CustomShippingRequest {
  final String name;
  final String invoice;
  final String customerName;
  final String territory;
  final String? territoryNameAr;
  final double originalAmount;
  final double requestedAmount;
  final String reason;
  final String requestedBy;
  final String requestedOn;

  CustomShippingRequest({
    required this.name,
    required this.invoice,
    required this.customerName,
    required this.territory,
    this.territoryNameAr,
    required this.originalAmount,
    required this.requestedAmount,
    required this.reason,
    required this.requestedBy,
    required this.requestedOn,
  });

  factory CustomShippingRequest.fromJson(Map<String, dynamic> json) {
    return CustomShippingRequest(
      name: (json['name'] ?? '').toString(),
      invoice: (json['invoice'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      territory: (json['territory'] ?? '').toString(),
      territoryNameAr: json['territory_name_ar']?.toString(),
      originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0,
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] ?? '').toString(),
      requestedBy: (json['requested_by'] ?? '').toString(),
      requestedOn: (json['requested_on'] ?? '').toString(),
    );
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/credit/data/credit_repository.dart';

/// Answers every request with `{"message": message}`.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.message);

  final Map<String, dynamic> message;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'message': message}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CreditRepository _repo(_Adapter adapter) =>
    CreditRepository(Dio(BaseOptions(baseUrl: 'https://example.test'))..httpClientAdapter = adapter);

void main() {
  test('a shop with several branches gets each invoice\'s branch name', () async {
    final adapter = _Adapter({
      'success': true,
      'branch_count': 2,
      'invoices': {
        'INV-1': {'branch': 'ADDR-HEL', 'branch_name': 'Heliopolis'},
        'INV-2': {'branch': '', 'branch_name': ''},
      },
    });
    final branches = await _repo(adapter).getInvoiceShopBranches(customer: 'CUST-1', invoices: ['INV-1', 'INV-2']);
    expect(branches, {'INV-1': 'Heliopolis', 'INV-2': ''});
    final sent = adapter.requests.single.data as Map;
    expect(sent['customer'], 'CUST-1');
    expect(jsonDecode(sent['invoices'] as String), ['INV-1', 'INV-2']);
  });

  test('a single-branch shop answers nothing, so its statement stays flat', () async {
    final adapter = _Adapter({
      'success': true,
      'branch_count': 1,
      'invoices': {
        'INV-1': {'branch': 'ADDR-HEL', 'branch_name': 'Heliopolis'},
      },
    });
    final branches = await _repo(adapter).getInvoiceShopBranches(customer: 'CUST-1', invoices: ['INV-1']);
    expect(branches, isEmpty);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';

/// Records the last request and answers with [reply] under `message`.
class _FakeDio with DioMixin implements Dio {
  _FakeDio(this.reply);

  final Object? reply;
  String? method;
  String? path;
  Object? sentData;
  Map<String, dynamic>? sentQuery;
  BaseOptions _testOptions = BaseOptions();

  @override
  BaseOptions get options => _testOptions;

  @override
  set options(BaseOptions value) => _testOptions = value;

  Response<T> _respond<T>(String p) => Response<T>(
    requestOptions: RequestOptions(path: p),
    statusCode: 200,
    data: {'message': reply} as T,
  );

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    method = 'GET';
    this.path = path;
    sentQuery = queryParameters;
    return _respond<T>(path);
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    method = 'POST';
    this.path = path;
    sentData = data;
    return _respond<T>(path);
  }
}

void main() {
  test('getAccountInvoices sends the branch filter as query params', () async {
    final dio = _FakeDio({
      'customer': 'ILO-1',
      'branch': '__unassigned__',
      'invoices': <Object>[],
      'summary': {'invoice_count': 0},
      'truncated': false,
    });
    final repo = B2bRepository(dio);

    final page = await repo.getAccountInvoices(
      doctype: 'Customer',
      name: 'ILO-1',
      branch: B2bRepository.unassignedBranch,
    );

    expect(dio.method, 'GET');
    expect(dio.path, ApiEndpoints.getB2bAccountInvoices);
    expect(dio.sentQuery, {
      'doctype': 'Customer',
      'name': 'ILO-1',
      'branch': '__unassigned__',
      'limit': 100,
    });
    expect(page.customer, 'ILO-1');
  });

  test('getAccountInvoices omits branch for all invoices', () async {
    final dio = _FakeDio(const <String, dynamic>{});
    await B2bRepository(
      dio,
    ).getAccountInvoices(doctype: 'Lead', name: 'CRM-LEAD-1');
    expect(dio.sentQuery!.containsKey('branch'), isFalse);
  });

  test('searchMergeTargets posts the query and unwraps candidates', () async {
    final dio = _FakeDio({
      'candidates': [
        {'doctype': 'Lead', 'name': 'CRM-LEAD-2', 'title': 'ILO Zayed'},
        {'doctype': 'Customer', 'name': '', 'title': 'blank is dropped'},
      ],
    });
    final rows = await B2bRepository(
      dio,
    ).searchMergeTargets(doctype: 'Customer', name: 'ILO-1', query: '  ilo ');

    expect(dio.method, 'POST');
    expect(dio.path, ApiEndpoints.b2bSearchMergeTargets);
    expect(dio.sentData, {
      'doctype': 'Customer',
      'name': 'ILO-1',
      'query': 'ilo',
      'limit': 20,
    });
    expect(rows.single.name, 'CRM-LEAD-2');
  });

  test('previewMergeAsBranch posts source and target', () async {
    final dio = _FakeDio({'can_execute': true, 'warnings': <String>[]});
    final preview = await B2bRepository(dio).previewMergeAsBranch(
      sourceDoctype: 'Lead',
      sourceName: 'CRM-LEAD-2',
      targetDoctype: 'Customer',
      targetName: 'ILO-1',
    );

    expect(dio.path, ApiEndpoints.b2bPreviewMergeAsBranch);
    expect(dio.sentData, {
      'source_doctype': 'Lead',
      'source_name': 'CRM-LEAD-2',
      'target_doctype': 'Customer',
      'target_name': 'ILO-1',
    });
    expect(preview.canExecute, isTrue);
  });

  test('mergeAsBranch posts the trimmed branch name', () async {
    final dio = _FakeDio({
      'success': true,
      'target_doctype': 'Customer',
      'target_name': 'ILO-1',
      'customer': 'ILO-1',
      'moved_invoices': 3,
    });
    final result = await B2bRepository(dio).mergeAsBranch(
      sourceDoctype: 'Lead',
      sourceName: 'CRM-LEAD-2',
      targetDoctype: 'Customer',
      targetName: 'ILO-1',
      branchName: '  Zayed  ',
    );

    expect(dio.method, 'POST');
    expect(dio.path, ApiEndpoints.b2bMergeAsBranch);
    expect((dio.sentData as Map)['branch_name'], 'Zayed');
    expect(result.targetName, 'ILO-1');
    expect(result.movedInvoices, 3);
  });

  test('mergeAsBranch omits a blank branch name', () async {
    final dio = _FakeDio({'success': true});
    final result = await B2bRepository(dio).mergeAsBranch(
      sourceDoctype: 'Customer',
      sourceName: 'ILO-2',
      targetDoctype: 'Customer',
      targetName: 'ILO-1',
      branchName: '   ',
    );
    expect((dio.sentData as Map).containsKey('branch_name'), isFalse);
    // Falls back to the requested target when the server omits it.
    expect(result.targetDoctype, 'Customer');
    expect(result.targetName, 'ILO-1');
  });
}

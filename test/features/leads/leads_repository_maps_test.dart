// ignore_for_file: overridden_fields

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/core/constants/api_endpoints.dart';
import 'package:jarz_pos/src/features/leads/data/leads_repository.dart';

class _ScriptedDio with DioMixin implements Dio {
  _ScriptedDio(this.messages);

  final List<Map<String, dynamic>> messages;
  final List<({String path, Object? data})> calls = [];

  @override
  BaseOptions options = BaseOptions();

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
    calls.add((path: path, data: data));
    final message = messages.removeAt(0);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: <String, dynamic>{'message': message} as T,
    );
  }
}

void main() {
  test('polls a pending short link and returns the terminal preview', () async {
    final dio = _ScriptedDio([
      {
        'success': true,
        'pending': true,
        'request_id': 'request-1',
        'url': 'https://maps.app.goo.gl/short',
        'canonical_url': 'https://maps.app.goo.gl/short',
        'short_link': true,
        'resolved': false,
      },
      {
        'success': true,
        'pending': false,
        'resolved': true,
        'url': 'https://maps.app.goo.gl/short',
        'canonical_url': 'https://www.google.com/maps/place/Test',
        'latitude': 30.0444,
        'longitude': 31.2357,
        'suggestions': {'lead_name': 'Test Cafe'},
      },
    ]);
    final waits = <Duration>[];
    final repository = LeadsRepository(
      dio,
      leadMapsPollWait: (duration) async => waits.add(duration),
    );

    final preview = await repository.previewMapsLink(
      'https://maps.app.goo.gl/short',
    );

    expect(preview.pending, isFalse);
    expect(preview.hasCoordinates, isTrue);
    expect(preview.placeName, 'Test Cafe');
    expect(waits, [const Duration(milliseconds: 500)]);
    expect(dio.calls, hasLength(2));
    expect(dio.calls.first.path, ApiEndpoints.previewLeadMapsLink);
    expect(dio.calls.first.data, {'link': 'https://maps.app.goo.gl/short'});
    expect(dio.calls.last.data, {'request_id': 'request-1'});
  });

  test('stops polling when the form says the lookup is stale', () async {
    final dio = _ScriptedDio([
      {
        'success': true,
        'pending': true,
        'request_id': 'request-old',
        'url': 'https://maps.app.goo.gl/old',
        'resolved': false,
      },
    ]);
    var waited = false;
    final repository = LeadsRepository(
      dio,
      leadMapsPollWait: (_) async => waited = true,
    );

    final preview = await repository.previewMapsLink(
      'https://maps.app.goo.gl/old',
      keepPolling: () => false,
    );

    expect(preview.pending, isTrue);
    expect(dio.calls, hasLength(1));
    expect(waited, isFalse);
  });
}

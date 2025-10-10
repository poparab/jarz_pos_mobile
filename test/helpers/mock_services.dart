import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jarz_pos/src/core/connectivity/connectivity_service.dart';
import 'package:jarz_pos/src/core/offline/offline_queue.dart';
import 'package:jarz_pos/src/core/session/session_manager.dart';
import 'package:jarz_pos/src/core/websocket/websocket_service.dart';

/// Mock Session Manager for testing
class MockSessionManager extends SessionManager {
  String? _sessionId;

  @override
  Future<String?> getSessionId() async => _sessionId;

  @override
  Future<void> saveSessionId(String sessionId) async {
    _sessionId = sessionId;
  }

  @override
  Future<void> clearSession() async {
    _sessionId = null;
  }

  @override
  Future<bool> hasValidSession() async {
    return _sessionId != null && _sessionId!.isNotEmpty;
  }
}

/// Mock Connectivity Service for testing
class MockConnectivityService extends ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _online = true;

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  @override
  void startMonitoring() {}

  @override
  Future<bool> hasConnection() async => _online;

  @override
  bool get isOnline => _online;

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    _controller.add(value);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// Mock Offline Queue for testing
class MockOfflineQueue extends OfflineQueue {
  final List<Map<String, dynamic>> _transactions = [];

  @override
  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    _transactions.add({
      'id': (_transactions.length + 1).toString(),
      'data': transaction,
      'status': 'pending',
      'endpoint': transaction['endpoint'],
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    return _transactions
        .where((tx) => tx['status'] == 'pending')
        .map((tx) => Map<String, dynamic>.from(tx))
        .toList();
  }

  @override
  Future<void> markAsProcessed(String id) async {
    for (final tx in _transactions) {
      if (tx['id'] == id) {
        tx['status'] = 'processed';
      }
    }
  }

  @override
  Future<void> markAsError(String id, String error) async {
    for (final tx in _transactions) {
      if (tx['id'] == id) {
        tx['status'] = 'error';
        tx['error'] = error;
      }
    }
  }

  @override
  Future<int> getPendingCount() async {
    return _transactions.where((tx) => tx['status'] == 'pending').length;
  }

  @override
  Future<void> clearAll() async {
    _transactions.clear();
  }
}

/// Mock WebSocket Service for testing
class MockWebSocketService extends WebSocketService {
  final _kanbanController = StreamController<Map<String, dynamic>>.broadcast();
  final _invoiceController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  void connect() {}

  @override
  Stream<Map<String, dynamic>> get kanbanUpdates => _kanbanController.stream;

  @override
  Stream<Map<String, dynamic>> get invoiceStream => _invoiceController.stream;

  void emitKanbanUpdate(Map<String, dynamic> data) {
    _kanbanController.add(data);
  }

  void emitInvoiceUpdate(Map<String, dynamic> data) {
    _invoiceController.add(data);
  }

  @override
  void dispose() {
    _kanbanController.close();
    _invoiceController.close();
  }
}

/// Mock Dio Client for testing
class MockDio implements Dio {
  final Map<String, dynamic> _responses = {};
  final List<Map<String, dynamic>> _requestLog = [];

  @override
  BaseOptions options = BaseOptions();

  @override
  late HttpClientAdapter httpClientAdapter;

  @override
  late Transformer transformer;

  @override
  Interceptors interceptors = Interceptors();

  void setResponse(String path, dynamic data, {int statusCode = 200}) {
    _responses[path] = Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: path),
    );
  }

  void setError(String path, DioException error) {
    _responses[path] = error;
  }

  List<Map<String, dynamic>> get requestLog => _requestLog;

  void clearLog() {
    _requestLog.clear();
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _requestLog.add({'method': 'GET', 'path': path, 'data': data, 'queryParameters': queryParameters});
    
    final response = _responses[path];
    if (response is DioException) throw response;
    if (response is Response<T>) return response;
    
    return Response(
      data: null as T,
      statusCode: 404,
      requestOptions: RequestOptions(path: path),
    );
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
    _requestLog.add({'method': 'POST', 'path': path, 'data': data, 'queryParameters': queryParameters});
    
    final response = _responses[path];
    if (response is DioException) throw response;
    if (response is Response<T>) return response;
    
    return Response(
      data: null as T,
      statusCode: 404,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<Response<T>> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> deleteUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    FileAccessMode? fileAccessMode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> getUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> head<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> headUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patchUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> postUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> putUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> request<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> requestUri<T>(Uri uri, {Object? data, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnimplementedError();
  }

  @override
  Dio clone({
    BaseOptions? options,
    Interceptors? interceptors,
    HttpClientAdapter? httpClientAdapter,
    Transformer? transformer,
  }) {
    throw UnimplementedError();
  }
}

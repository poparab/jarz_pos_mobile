import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "../utils/logger.dart";

class ApiClient {
  final Logger _logger = Logger("ApiClient");
  late final Dio _dio;

  ApiClient(String baseUrl) {
    _logger.info("Initializing API client with base URL: $baseUrl");
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Content-Type": "application/json"},
      ),
    );
    // Add interceptors for logging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    _logger.debug(
      "GET $path ${queryParameters != null ? "with params: $queryParameters" : ""}",
    );
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    _logger.debug(
      "POST $path ${data != null ? "with data: $data" : ""} ${queryParameters != null ? "with params: $queryParameters" : ""}",
    );
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    _logger.debug(
      "PUT $path ${data != null ? "with data: $data" : ""} ${queryParameters != null ? "with params: $queryParameters" : ""}",
    );
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    _logger.debug(
      "DELETE $path ${data != null ? "with data: $data" : ""} ${queryParameters != null ? "with params: $queryParameters" : ""}",
    );
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  // Get base URL from environment configuration
  final baseUrl = dotenv.env["ERP_BASE_URL"] ?? "http://192.168.1.7:8000";
  final logger = Logger("ApiClientProvider");
  logger.info("Creating API client with base URL: $baseUrl");
  return ApiClient(baseUrl);
});

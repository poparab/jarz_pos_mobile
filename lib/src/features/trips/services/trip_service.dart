import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../models/trip_models.dart';

/// Service for Delivery Trip API interactions.
class TripService {
  final Dio _dio;
  final Logger _logger = Logger('TripService');

  TripService(this._dio);

  /// Retry helper for mutation calls.  Retries on network / timeout errors
  /// with exponential back-off (1s, 2s, 4s).  Non-retryable server errors
  /// (4xx) are thrown immediately.
  Future<Response<dynamic>> _postWithRetry(
    String path,
    Map<String, dynamic> data, {
    int maxAttempts = 3,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    late Object lastError;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final options = Options();
        if (sendTimeout != null || receiveTimeout != null) {
          options.sendTimeout = sendTimeout;
          options.receiveTimeout = receiveTimeout;
        }
        return await _dio.post(path, data: data, options: options);
      } on DioException catch (e) {
        lastError = e;
        // Don't retry client errors (validation, auth, etc.)
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 400 && statusCode < 500) rethrow;
        // Don't retry if we got a response with server error containing
        // a Frappe validation message — it would fail again.
        if (statusCode >= 500 && e.response?.data != null) {
          final respData = e.response!.data;
          if (respData is Map && respData['exc_type'] != null) rethrow;
        }
        if (attempt < maxAttempts) {
          _logger.info('Retry $attempt/$maxAttempts for $path after ${e.type}');
          await Future<void>.delayed(Duration(seconds: 1 << (attempt - 1)));
        }
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(seconds: 1 << (attempt - 1)));
        }
      }
    }
    throw lastError;
  }

  Future<DeliveryTrip> createTrip({
    required List<String> invoiceNames,
    required String partyType,
    required String party,
    String? posProfile,
  }) async {
    try {
      _logger.info('Creating trip with ${invoiceNames.length} invoices');
      final resp = await _postWithRetry(
        ApiEndpoints.createDeliveryTrip,
        {
          'invoice_names': json.encode(invoiceNames),
          'party_type': partyType,
          'party': party,
          if (posProfile != null && posProfile.trim().isNotEmpty)
            'pos_profile': posProfile.trim(),
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return DeliveryTrip.fromJson(Map<String, dynamic>.from(msg));
      }
      throw Exception(msg is Map ? msg['message'] ?? 'Failed' : 'Failed to create trip');
    } catch (e) {
      _logger.error('Failed to create trip', e);
      rethrow;
    }
  }

  Future<List<DeliveryTrip>> getTrips({
    String? status,
    String? courierParty,
    String? dateFrom,
    String? dateTo,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final resp = await _dio.get(
        ApiEndpoints.getDeliveryTrips,
        queryParameters: {
          if (status != null) 'status': status,
          if (courierParty != null) 'courier_party': courierParty,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          'limit': limit,
          'offset': offset,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        final listRaw = msg['data'] ?? msg['trips'] ?? [];
        return (listRaw as List? ?? [])
            .map((e) => DeliveryTrip.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      throw Exception('Failed to fetch trips');
    } catch (e) {
      _logger.error('Failed to fetch trips', e);
      rethrow;
    }
  }

  Future<DeliveryTrip> getTripDetails(String tripName) async {
    try {
      final resp = await _dio.get(
        ApiEndpoints.getTripDetails,
        queryParameters: {'trip_name': tripName},
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        final tripRaw = msg['trip'] ?? msg['data'] ?? msg;
        if (tripRaw is Map) {
          return DeliveryTrip.fromJson(Map<String, dynamic>.from(tripRaw));
        }
        throw Exception('Trip payload is missing');
      }
      throw Exception('Failed to fetch trip details');
    } catch (e) {
      _logger.error('Failed to fetch trip details', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendForDelivery(String tripName) async {
    return sendForDeliveryWithApproval(tripName);
  }

  Future<Map<String, dynamic>> previewForDelivery(String tripName) async {
    try {
      _logger.info('Previewing trip $tripName for delivery');
      final resp = await _dio.get(
        ApiEndpoints.previewTripForDelivery,
        queryParameters: {'trip_name': tripName},
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['error'] ?? 'Failed' : 'Failed to preview trip');
    } catch (e) {
      _logger.error('Failed to preview trip for delivery', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendForDeliveryWithApproval(
    String tripName, {
    bool shortageApproved = false,
    String? shortageReason,
  }) async {
    try {
      _logger.info('Sending trip $tripName for delivery');
      final payload = <String, dynamic>{'trip_name': tripName};
      if (shortageApproved) {
        payload['shortage_approved'] = 1;
      }
      if (shortageReason != null && shortageReason.trim().isNotEmpty) {
        payload['shortage_reason'] = shortageReason.trim();
      }
      final resp = await _postWithRetry(
        ApiEndpoints.sendTripForDelivery,
        payload,
        // Heavy operation: DN + courier + JE per invoice — give it time
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['message'] ?? 'Failed' : 'Failed to send trip');
    } catch (e) {
      _logger.error('Failed to send trip for delivery', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markAsDelivered(String tripName) async {
    try {
      _logger.info('Marking trip $tripName as delivered');
      final resp = await _postWithRetry(
        ApiEndpoints.markTripAsDelivered,
        {'trip_name': tripName},
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );
      final msg = resp.data['message'];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['message'] ?? 'Failed' : 'Failed to mark trip as delivered');
    } catch (e) {
      _logger.error('Failed to mark trip as delivered', e);
      rethrow;
    }
  }
}

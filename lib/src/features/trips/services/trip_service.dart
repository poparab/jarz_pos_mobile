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

  Future<DeliveryTrip> createTrip({
    required List<String> invoiceNames,
    required String partyType,
    required String party,
  }) async {
    try {
      _logger.info('Creating trip with ${invoiceNames.length} invoices');
      final resp = await _dio.post(
        ApiEndpoints.createDeliveryTrip,
        data: {
          'invoice_names': json.encode(invoiceNames),
          'party_type': partyType,
          'party': party,
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
        return (msg['data'] as List? ?? [])
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
        return DeliveryTrip.fromJson(Map<String, dynamic>.from(msg['trip'] as Map));
      }
      throw Exception('Failed to fetch trip details');
    } catch (e) {
      _logger.error('Failed to fetch trip details', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendForDelivery(String tripName) async {
    try {
      _logger.info('Sending trip $tripName for delivery');
      final resp = await _dio.post(
        ApiEndpoints.sendTripForDelivery,
        data: {'trip_name': tripName},
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
}

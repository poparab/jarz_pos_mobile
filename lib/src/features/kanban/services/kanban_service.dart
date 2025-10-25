import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import "../models/kanban_models.dart";
import "../models/kanban_filter_options.dart";
import "../../../core/utils/logger.dart";

/// Service for interacting with Kanban-related API endpoints
class KanbanService {
  // Replaced ApiClient with shared Dio (has SessionInterceptor -> cookies)
  final Dio _dio;
  final Logger _logger = Logger("KanbanService");

  KanbanService(this._dio);

  Future<dynamic> rawPost(String path, Map<String, dynamic> data) async {
    final resp = await _dio.post(path, data: data);
    return resp.data['message'] ?? resp.data;
  }

  /// Settlement preview for an invoice to reconcile paid/unpaid and amounts
  Future<Map<String, dynamic>> getInvoiceSettlementPreview({
    required String invoiceName,
    String? partyType,
    String? party,
  }) async {
    try {
      _logger.info('Fetching settlement preview for $invoiceName');
      final resp = await _dio.get(
        '/api/method/jarz_pos.api.invoices.get_invoice_settlement_preview',
        queryParameters: {
          'invoice_name': invoiceName,
          if (partyType != null) 'party_type': partyType,
          if (party != null) 'party': party,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception('Failed to fetch settlement preview');
    } catch (e) {
      _logger.error('Failed to get settlement preview', e);
      rethrow;
    }
  }

  Future<Map<String, List<InvoiceCard>>> fetchInvoices() async {
    return await getKanbanInvoices();
  }

  /// Fetch kanban columns from the API
  Future<List<KanbanColumn>> getKanbanColumns() async {
    try {
      _logger.info("Fetching kanban columns");
      final response = await _dio.get(
        "/api/method/jarz_pos.api.kanban.get_kanban_columns",
      );

      if (response.data["message"]["success"] == true) {
        final List<dynamic> columnsData = response.data["message"]["columns"];
        final columns = columnsData
            .map((column) => KanbanColumn.fromJson(column))
            .toList();
        _logger.debug("Retrieved ${columns.length} columns");
        return columns;
      } else {
        final error =
            response.data["message"]["error"] ??
            "Failed to load kanban columns";
        _logger.error("API error: $error");
        throw Exception(error);
      }
    } catch (e) {
      _logger.error("Failed to get kanban columns", e);
      throw Exception("Failed to get kanban columns: $e");
    }
  }

  /// Fetch kanban invoices from the API with optional filters
  Future<Map<String, List<InvoiceCard>>> getKanbanInvoices({
    Map<String, dynamic>? filters,
  }) async {
    try {
      _logger.info("Fetching kanban invoices with filters: $filters");
      final response = await _dio.post(
        "/api/method/jarz_pos.api.kanban.get_kanban_invoices",
        data: filters != null ? {"filters": jsonEncode(filters)} : {},
      );

      if (response.data["message"]["success"] == true) {
        final Map<String, dynamic> kanbanData =
            response.data["message"]["data"];
        final Map<String, List<InvoiceCard>> result = {};

        kanbanData.forEach((columnId, cardList) {
          if (cardList is List) {
            result[columnId] = cardList
                .map((card) => InvoiceCard.fromJson(card))
                .toList();
          }
        });

        int total = 0;
        result.forEach((key, cards) => total += cards.length);
        _logger.debug(
          "Retrieved $total cards across ${result.keys.length} columns",
        );

        return result;
      } else {
        final error =
            response.data["message"]["error"] ??
            "Failed to load kanban invoices";
        _logger.error("API error: $error");
        throw Exception(error);
      }
    } catch (e) {
      _logger.error("Failed to get kanban invoices", e);
      throw Exception("Failed to get kanban invoices: $e");
    }
  }

  /// Update the state of an invoice
  Future<bool> updateInvoiceState(String invoiceId, String newState) async {
    final response = await _dio.post(
      "/api/method/jarz_pos.api.kanban.update_invoice_state",
      data: {"invoice_id": invoiceId, "new_state": newState},
    );

    if (response.data["message"]["success"] == true) {
      _logger.debug("Invoice state updated successfully");
      return true;
    } else {
      final error =
          response.data["message"]["error"] ?? "Failed to update invoice state";
      _logger.error("API error: $error");
      throw Exception(error);
    }
  }

  /// Get detailed information about a specific invoice
  Future<InvoiceCard> getInvoiceDetails(String invoiceId) async {
    try {
      _logger.info("Fetching details for invoice: $invoiceId");
      final response = await _dio.get(
        "/api/method/jarz_pos.api.kanban.get_invoice_details",
        queryParameters: {"invoice_id": invoiceId},
      );

      if (response.data["message"]["success"] == true) {
        final cardData = response.data["message"]["data"];
        _logger.debug("Retrieved invoice details successfully");
        return InvoiceCard.fromJson(cardData);
      } else {
        final error =
            response.data["message"]["error"] ??
            "Failed to get invoice details";
        _logger.error("API error: $error");
        throw Exception(error);
      }
    } catch (e) {
      _logger.error("Failed to get invoice details", e);
      throw Exception("Failed to get invoice details: $e");
    }
  }

  /// Get filter options for the kanban board
  Future<KanbanFilterOptions> getKanbanFilters() async {
    try {
      _logger.info("Fetching kanban filter options");
      final response = await _dio.get(
        "/api/method/jarz_pos.api.kanban.get_kanban_filters",
      );

      if (response.data["message"]["success"] == true) {
        final data = response.data["message"];
        final customers =
            (data["customers"] as List?)
                ?.map((c) => FilterOption(value: c["value"], label: c["label"]))
                .toList() ??
            [];

        final states =
            (data["states"] as List?)
                ?.map((s) => FilterOption(value: s["value"], label: s["label"]))
                .toList() ??
            [];

        _logger.debug(
          "Retrieved ${customers.length} customers and ${states.length} states for filtering",
        );

        return KanbanFilterOptions(customers: customers, states: states);
      } else {
        final error =
            response.data["message"]["error"] ?? "Failed to get filter options";
        _logger.error("API error: $error");
        throw Exception(error);
      }
    } catch (e) {
      _logger.error("Failed to get kanban filters", e);
      throw Exception("Failed to get kanban filters: $e");
    }
  }

  /// Pay an invoice (creates Payment Entry) given payment mode and optional POS profile for Cash
  Future<Map<String, dynamic>> payInvoice({
    required String invoiceName,
    required String paymentMode,
    String? posProfile,
  }) async {
    try {
      _logger.info("Paying invoice $invoiceName via $paymentMode");
      final data = {
        "invoice_name": invoiceName,
        "payment_mode": paymentMode,
      };
      if (posProfile != null) data["pos_profile"] = posProfile;

      final response = await _dio.post(
        "/api/method/jarz_pos.api.invoices.pay_invoice",
        data: data,
      );
      final msg = response.data["message"];
      if (msg is Map && msg["success"] == true) {
        _logger.debug("Payment entry ${msg["payment_entry"]} created");
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg["error"] ?? "Payment failed" : "Payment failed");
    } catch (e) {
      _logger.error("Failed to pay invoice", e);
      // Surface backend error details if available (Frappe sends message/exc in JSON on non-200)
      if (e is DioException) {
        try {
          final data = e.response?.data;
          if (data is Map) {
            // Common Frappe error shapes
            final m = data['message'] ?? data['exception'] ?? data['exc'] ?? data['error'];
            if (m is String && m.trim().isNotEmpty) {
              throw Exception(m);
            }
            if (m is Map && (m['message'] != null || m['error'] != null)) {
              throw Exception((m['message'] ?? m['error']).toString());
            }
          }
          // If response has text body
          if (data is String && data.trim().isNotEmpty) {
            throw Exception(data);
          }
        } catch (_) {
          // fallthrough to generic path
        }
        // Include HTTP status text if present
        final status = e.response?.statusCode;
        final statusText = e.response?.statusMessage;
  throw Exception(status != null ? "Payment failed ($status ${statusText ?? ''}).".trim() : "Payment failed");
      }
      // Non-Dio error
      throw Exception(e.toString());
    }
  }

  /// Unified Out For Delivery transition (handles paid and unpaid per backend new rules)
  Future<Map<String, dynamic>> handleOutForDeliveryTransition({
    required String invoiceName,
    required String courier,
    required String mode, // pay_now only
    required String posProfile,
    required String idempotencyToken,
    String? partyType,
    String? party,
  }) async {
    try {
      _logger.info("OFD transition $invoiceName mode=$mode courier=$courier token=$idempotencyToken");
      final response = await _dio.post(
        "/api/method/jarz_pos.api.couriers.handle_out_for_delivery_transition",
        data: {
          "invoice_name": invoiceName,
          "courier": courier,
          "mode": mode,
            "pos_profile": posProfile,
            "idempotency_token": idempotencyToken,
          if (partyType != null) "party_type": partyType,
          if (party != null) "party": party,
        },
      );
      final msg = response.data["message"];
      if (msg is Map && msg['success'] == true) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['error'] ?? 'OFD transition failed' : 'OFD transition failed');
    } catch (e) {
      _logger.error('Failed unified OFD transition', e);
      rethrow;
    }
  }

  /// Helper to generate an idempotency token (not cryptographically secure)
  String generateIdempotencyToken() {
    final r = Random();
    return 'ofd-${DateTime.now().millisecondsSinceEpoch}-${r.nextInt(1<<32).toRadixString(16)}';
  }

  /// (Deprecated) Handle Out For Delivery Paid transition – kept for backward compatibility
  @Deprecated('Use handleOutForDeliveryTransition')
  Future<Map<String, dynamic>> handleOutForDeliveryPaid({
    required String invoiceName,
    required String courier,
    required String settlement, // 'cash_now' | 'later'
    required String posProfile,
  }) async {
    _logger.warning("handleOutForDeliveryPaid is deprecated, use handleOutForDeliveryTransition instead");
    return handleOutForDeliveryTransition(
      invoiceName: invoiceName,
      courier: courier,
      // New rule: only 'pay_now' is supported; legacy 'later' is ignored
      mode: 'pay_now',
      posProfile: posProfile,
      idempotencyToken: generateIdempotencyToken(),
    );
  }

  /// Fetch list of active couriers (name & courier_name)
  Future<List<Map<String, String>>> fetchCouriers() async {
    try {
      final resp = await _dio.get(
        '/api/method/jarz_pos.api.couriers.get_active_couriers',
      );
      final msg = resp.data['message'];
      if (msg is List) {
        // Unified shape from backend: { party_type, party, display_name }
        return msg.map<Map<String, String>>((e) {
          final display = (e['display_name'] ?? e['name'] ?? '').toString();
          final party = (e['party'] ?? '').toString();
          final partyType = (e['party_type'] ?? '').toString();
          return {
            'party_type': partyType,
            'party': party,
            'display_name': display,
            // legacy keys consumed by existing UI dropdown
            'courier_name': display,
            'name': party,
            if (e['branch'] != null) 'branch': (e['branch'] ?? '').toString(),
          };
        }).toList();
      }
      if (msg is Map && msg['error'] != null) {
        throw Exception(msg['error']);
      }
      return [];
    } catch (e) {
      _logger.error('Failed to fetch couriers', e);
      rethrow;
    }
  }

  /// Mark courier outstanding for UNPAID invoice: creates Payment Entry moving receivable to Courier Outstanding,
  /// creates Courier Transaction with amount = invoice outstanding and shipping_amount from city, and may create a
  /// shipping expense Journal Entry. Also sets state to Out for Delivery idempotently via backend and emits realtime.
  Future<Map<String, dynamic>> markCourierOutstanding({
    required String invoiceName,
    required String courier,
    String? partyType,
    String? party,
  }) async {
    try {
      _logger.info("Mark courier outstanding $invoiceName courier=$courier");
      final response = await _dio.post(
        "/api/method/jarz_pos.api.couriers.mark_courier_outstanding",
        data: {
          "invoice_name": invoiceName,
          "courier": courier,
          if (partyType != null) "party_type": partyType,
          if (party != null) "party": party,
        },
      );
      final msg = response.data["message"];
      if (msg is Map) {
        // Normalize: ensure a success flag so callers can treat as successful
        final map = Map<String, dynamic>.from(msg);
        map.putIfAbsent('success', () => true);
        map.putIfAbsent('invoice', () => invoiceName);
        return map;
      }
      // Some backends may return a bare string like "OK"; treat as success
      if (msg is String) {
        return {
          'success': true,
          'invoice': invoiceName,
          'message': msg,
        };
      }
      throw Exception("mark_courier_outstanding failed");
    } catch (e) {
      _logger.error('Failed to mark courier outstanding', e);
      rethrow;
    }
  }

  /// Create a new delivery party (Employee or Supplier) with phone & branch (pos profile name)
  Future<Map<String, String>> createDeliveryParty({
    required String partyType, // 'Employee' | 'Supplier'
    String? name, // optional if first/last provided
    String? firstName,
    String? lastName,
    required String phone,
    String? posProfile, // used as branch on backend
  }) async {
    try {
      _logger.info('Creating delivery party type=$partyType name=$name branch=$posProfile');
      final resp = await _dio.post(
        '/api/method/jarz_pos.api.couriers.create_delivery_party',
        data: {
          'party_type': partyType,
          if (name != null) 'name': name,
          'phone': phone,
          if (posProfile != null) 'pos_profile': posProfile,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map) {
        // Normalize output with legacy keys for UI reuse
        final map = {
          'party_type': (msg['party_type'] ?? '').toString(),
          'party': (msg['party'] ?? '').toString(),
          'display_name': (msg['display_name'] ?? name).toString(),
          'courier_name': (msg['display_name'] ?? name).toString(),
          'name': (msg['party'] ?? '').toString(),
          if (msg['branch'] != null) 'branch': (msg['branch'] ?? '').toString(),
          if (msg['phone'] != null) 'phone': (msg['phone'] ?? '').toString(),
        };
        return map;
      }
      throw Exception('Unexpected response creating delivery party');
    } catch (e) {
      _logger.error('Failed to create delivery party', e);
      rethrow;
    }
  }

  /// Settle a single already-paid invoice's courier shipping expense (one-by-one settlement)
  Future<Map<String, dynamic>> settleSingleInvoicePaid({
    required String invoiceName,
    required String posProfile,
    required String partyType,
    required String party,
  }) async {
    try {
      _logger.info('Single courier settlement invoice=$invoiceName party=$partyType/$party');
      final resp = await _dio.post(
        '/api/method/jarz_pos.api.couriers.settle_single_invoice_paid',
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': partyType,
          'party': party,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && (msg['success'] == true || msg['journal_entry'] != null)) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['error'] ?? 'Settlement failed' : 'Settlement failed');
    } catch (e) {
      _logger.error('Failed single invoice settlement', e);
      rethrow;
    }
  }

  /// Settle scenario where courier collected the full order amount from customer.
  /// Backend performs two-case JE logic netting order vs shipping expense.
  Future<Map<String, dynamic>> settleCourierCollectedPayment({
    required String invoiceName,
    required String posProfile,
    required String partyType,
    required String party,
  }) async {
    try {
      _logger.info('Courier collected settlement invoice=$invoiceName party=$partyType/$party');
      final resp = await _dio.post(
        '/api/method/jarz_pos.api.couriers.settle_courier_collected_payment',
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'party_type': partyType,
          'party': party,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && (msg['success'] == true || msg['journal_entry'] != null)) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? msg['error'] ?? 'Courier collected settlement failed' : 'Courier collected settlement failed');
    } catch (e) {
      _logger.error('Failed courier collected settlement', e);
      rethrow;
    }
  }

  /// Sales Partner UNPAID -> Out For Delivery fast-path (auto cash payment + DN + state change)
  Future<Map<String, dynamic>> salesPartnerUnpaidOutForDelivery({
    required String invoiceName,
    required String posProfile,
    String modeOfPayment = 'Cash',
  }) async {
    try {
      _logger.info('SalesPartner unpaid OFD invoice=$invoiceName pos_profile=$posProfile');
      final resp = await _dio.post(
        '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_unpaid_out_for_delivery',
        data: {
          'invoice_name': invoiceName,
          'pos_profile': posProfile,
          'mode_of_payment': modeOfPayment,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && (msg['success'] == true)) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? (msg['error'] ?? 'Sales partner unpaid OFD failed') : 'Sales partner unpaid OFD failed');
    } catch (e) {
      _logger.error('Failed sales partner unpaid OFD', e);
      rethrow;
    }
  }

  /// Sales Partner PAID -> Out For Delivery fast-path (ensure DN + state change)
  Future<Map<String, dynamic>> salesPartnerPaidOutForDelivery({
    required String invoiceId,
  }) async {
    try {
      _logger.info('SalesPartner paid OFD invoice=$invoiceId');
      final resp = await _dio.post(
        '/api/method/jarz_pos.jarz_pos.services.delivery_handling.sales_partner_paid_out_for_delivery',
        data: {
          'invoice_name': invoiceId,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && (msg['success'] == true)) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? (msg['error'] ?? 'Sales partner paid OFD failed') : 'Sales partner paid OFD failed');
    } catch (e) {
      _logger.error('Failed sales partner paid OFD', e);
      rethrow;
    }
  }

  /// Update customer's default address and phone number
  Future<Map<String, dynamic>> updateCustomerAddress({
    required String customer,
    required String address,
    required String phone,
  }) async {
    try {
      _logger.info('Updating customer address for $customer');
      final resp = await _dio.post(
        '/api/method/jarz_pos.api.customer.update_default_address',
        data: {
          'customer': customer,
          'address': address,
          'phone': phone,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && (msg['success'] == true)) {
        return Map<String, dynamic>.from(msg);
      }
      throw Exception(msg is Map ? (msg['error'] ?? 'Failed to update customer address') : 'Failed to update customer address');
    } catch (e) {
      _logger.error('Failed to update customer address', e);
      rethrow;
    }
  }

  /// Transfer invoice to a different POS profile
  Future<void> transferInvoice({
    required String invoiceId,
    required String newBranch,
  }) async {
    try {
      _logger.info('Transferring invoice $invoiceId to $newBranch');
      final resp = await _dio.post(
        '/api/method/jarz_pos.api.manager.update_invoice_branch',
        data: {
          'invoice_id': invoiceId,
          'new_branch': newBranch,
        },
      );
      final msg = resp.data['message'];
      if (msg is Map && !(msg['success'] == true)) {
        throw Exception(msg['error'] ?? 'Transfer failed');
      }
    } catch (e) {
      _logger.error('Failed to transfer invoice', e);
      rethrow;
    }
  }
}

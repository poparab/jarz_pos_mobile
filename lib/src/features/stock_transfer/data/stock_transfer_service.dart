import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import 'stock_handover_models.dart';

final stockTransferServiceProvider = Provider<StockTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return StockTransferService(dio);
});

class StockTransferService {
  final Dio _dio;
  StockTransferService(this._dio);

  Future<List<Map<String, dynamic>>> listPosProfiles() async {
    final resp = await _dio.post(ApiEndpoints.transferListPosProfiles, data: {});
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> listItemGroups({String? search}) async {
    final resp = await _dio.post(ApiEndpoints.transferListItemGroups, data: { if (search != null) 'search': search });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  Future<List<Map<String, dynamic>>> searchItemsWithStock({
    required String sourceWarehouse,
    required String targetWarehouse,
    String? search,
    String? itemGroup,
  }) async {
    final resp = await _dio.post(ApiEndpoints.searchItemsWithStock, data: {
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      if (search != null) 'search': search,
      if (itemGroup != null) 'item_group': itemGroup,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is List) return (payload['message'] as List).cast<Map<String, dynamic>>();
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    return [];
  }

  /// Past Material Transfer entries, newest first.
  ///
  /// Returns `(transfers, total)`; `total` is the count matching the filters,
  /// which is what the caller pages against.
  Future<({List<Map<String, dynamic>> transfers, int total})> listTransfers({
    int limit = 30,
    int page = 0,
    String? sourceWarehouse,
    String? targetWarehouse,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final resp = await _dio.post(ApiEndpoints.transferListHistory, data: {
      'limit': limit,
      'page': page,
      if (sourceWarehouse != null) 'source_warehouse': sourceWarehouse,
      if (targetWarehouse != null) 'target_warehouse': targetWarehouse,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final payload = resp.data;
    final message = (payload is Map && payload['message'] is Map)
        ? Map<String, dynamic>.from(payload['message'] as Map)
        : (payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{});
    final rows = (message['transfers'] as List?) ?? const [];
    return (
      transfers: rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      total: (message['total'] as num?)?.toInt() ?? rows.length,
    );
  }

  Future<Map<String, dynamic>> submitTransfer({
    required String sourceWarehouse,
    required String targetWarehouse,
    required List<Map<String, dynamic>> lines,
    String? postingDate,
    bool direct = false,
  }) async {
    final resp = await _dio.post(ApiEndpoints.submitTransfer, data: {
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      'lines': lines,
      if (postingDate != null) 'posting_date': postingDate,
      // One-step post of a branch pair (JARZ Manager only); omitted otherwise
      // so an older server sees exactly the request it always did.
      if (direct) 'direct': 1,
    });
    final payload = resp.data;
    if (payload is Map && payload['message'] is Map) return Map<String, dynamic>.from(payload['message'] as Map);
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw Exception('Unexpected submit transfer response');
  }

  // ── Stock Handover ──────────────────────────────────────────────────────

  /// Who the user is for handovers. [posProfile] is the branch of the open
  /// shift; the server derives the branch side from it — the user never
  /// picks their own branch.
  Future<HandoverContext> getHandoverContext({String? posProfile}) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverGetContext, data: {
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
    });
    return HandoverContext.fromJson(unwrapFrappeMap(resp.data));
  }

  /// The items that may be declared between the two sides (jars only). With
  /// no [counterpartWarehouse] ("I sent out") the server returns the union
  /// over every possible receiver.
  Future<List<HandoverItemOption>> listHandoverItems({
    required String myWarehouse,
    String? counterpartWarehouse,
    String? search,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverListItems, data: {
      'my_warehouse': myWarehouse,
      if (counterpartWarehouse != null && counterpartWarehouse.isNotEmpty)
        'counterpart_warehouse': counterpartWarehouse,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    final message = unwrapFrappeMessage(resp.data);
    final rows = message is Map
        ? message['items']
        : (message is List ? message : null);
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((e) => HandoverItemOption.fromJson(Map<String, dynamic>.from(e)))
        .where((o) => o.itemCode.isNotEmpty)
        .toList();
  }

  /// "I received from …" ([direction] `in`, needs [counterpartWarehouse]) or
  /// "I sent out" (`out`, no counterpart: a Dispatch a manager matches later).
  /// Lines without a positive quantity never leave the client.
  /// [clientRequestId] is generated once per editor session so a double tap
  /// returns the first handover instead of inserting a second.
  Future<StockHandover?> declareHandover({
    required String myWarehouse,
    String? counterpartWarehouse,
    required String direction,
    required List<Map<String, dynamic>> lines,
    String? posProfile,
    String? clientRequestId,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverDeclare, data: {
      'my_warehouse': myWarehouse,
      if (counterpartWarehouse != null && counterpartWarehouse.isNotEmpty)
        'counterpart_warehouse': counterpartWarehouse,
      'direction': direction,
      'lines': positiveHandoverLines(lines),
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
      if (clientRequestId != null && clientRequestId.isNotEmpty)
        'client_request_id': clientRequestId,
    });
    return _handoverFrom(resp.data);
  }

  Future<StockHandoverLists> listHandovers({
    String? myWarehouse,
    String? posProfile,
    int limit = 30,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverList, data: {
      if (myWarehouse != null && myWarehouse.isNotEmpty)
        'my_warehouse': myWarehouse,
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
      'limit': limit,
    });
    return StockHandoverLists.fromJson(unwrapFrappeMap(resp.data));
  }

  /// [action] is `confirm`, `change` (with [lines]) or `reject` (optional
  /// [reason]).
  Future<StockHandover?> respondToHandover({
    required String name,
    required String action,
    List<Map<String, dynamic>>? lines,
    String? reason,
    String? posProfile,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverRespond, data: {
      'name': name,
      'action': action,
      if (lines != null) 'lines': positiveHandoverLines(lines),
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
    });
    return _handoverFrom(resp.data);
  }

  Future<StockHandover?> cancelHandover({
    required String name,
    String? posProfile,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverCancel, data: {
      'name': name,
      if (posProfile != null && posProfile.isNotEmpty) 'pos_profile': posProfile,
    });
    return _handoverFrom(resp.data);
  }

  /// Manager confirms a whole "sent out" batch. [members] is the exact
  /// `dispatches + receipts` list the manager was shown (the server's
  /// concurrency token); [lines] is `[{item_code, sent, splits:[{warehouse,
  /// qty}]}]`. Zero or negative splits are dropped here.
  Future<MatchConfirmOutcome> confirmMatch({
    required String sourceWarehouse,
    required List<String> members,
    required List<Map<String, dynamic>> lines,
    String? note,
  }) async {
    final resp = await _dio.post(ApiEndpoints.stockHandoverConfirmMatch, data: {
      'source_warehouse': sourceWarehouse,
      'members': members,
      'lines': positiveMatchLines(lines),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    return MatchConfirmOutcome.fromJson(unwrapFrappeMap(resp.data));
  }

  /// `{"ok": true, "handover": {...}}`, or the handover itself.
  StockHandover? _handoverFrom(Object? payload) {
    final message = unwrapFrappeMap(payload);
    final inner = message['handover'];
    if (inner is Map) {
      return StockHandover.fromJson(Map<String, dynamic>.from(inner));
    }
    if (message.containsKey('name') && message.containsKey('status')) {
      return StockHandover.fromJson(message);
    }
    return null;
  }
}

/// `{item_code, qty}` for every line with a positive, finite quantity — the
/// review step and the server both ignore the rest, so they are never sent.
List<Map<String, dynamic>> positiveHandoverLines(
  List<Map<String, dynamic>> lines,
) {
  return [
    for (final l in lines)
      if (l['item_code'] != null &&
          l['qty'] is num &&
          (l['qty'] as num).isFinite &&
          (l['qty'] as num) > 0)
        {'item_code': l['item_code'], 'qty': (l['qty'] as num).toDouble()},
  ];
}

/// `{item_code, sent, splits:[{warehouse, qty}]}` keeping only positive,
/// finite splits. Every item keeps its line, even with sent 0 and no splits:
/// the server refuses a batch with "Every item in the batch needs a line"
/// when one is missing.
List<Map<String, dynamic>> positiveMatchLines(
  List<Map<String, dynamic>> lines,
) {
  bool positive(Object? v) => v is num && v.isFinite && v > 0;
  final out = <Map<String, dynamic>>[];
  for (final l in lines) {
    if (l['item_code'] == null) continue;
    final splits = <Map<String, dynamic>>[];
    final raw = l['splits'];
    if (raw is List) {
      for (final s in raw) {
        if (s is Map && s['warehouse'] != null && positive(s['qty'])) {
          splits.add({
            'warehouse': s['warehouse'],
            'qty': (s['qty'] as num).toDouble(),
          });
        }
      }
    }
    final sent = positive(l['sent']) ? (l['sent'] as num).toDouble() : 0.0;
    out.add({'item_code': l['item_code'], 'sent': sent, 'splits': splits});
  }
  return out;
}

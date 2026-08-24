import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import 'models/journey_note.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return JourneyRepository(dio);
});

/// Fallback editor options, used when the backend list cannot be fetched
/// (offline, or a site that has not migrated the DocType yet). Mirrors
/// `ENTRY_TYPES` / `OUTCOMES` in `jarz_pos/api/journey.py`; the server list
/// always wins when it is reachable, and the server rejects anything it does
/// not recognise.
const kFallbackJourneyEntryTypes = <String>[
  'Visit',
  'Call',
  'WhatsApp',
  'Sample Drop',
  'Meeting',
  'Email',
  'Other',
];

const kFallbackJourneyOutcomes = <String>[
  'Interested',
  'Needs Follow-up',
  'Sample Requested',
  'Order Placed',
  'Not Now',
  'Rejected',
];

/// The editor's Select options. Never fails: a network error degrades to the
/// bundled lists so a rep can still log a visit.
final journeyOptionsProvider = FutureProvider<JourneyOptions>((ref) async {
  try {
    final options = await ref.read(journeyRepositoryProvider).getOptions();
    if (options.entryTypes.isNotEmpty) return options;
  } catch (_) {
    // Fall through to the bundled lists.
  }
  return const JourneyOptions(
    entryTypes: kFallbackJourneyEntryTypes,
    outcomes: kFallbackJourneyOutcomes,
  );
});

/// HTTP repository for journey notes (`jarz_pos.api.journey.*`).
///
/// All endpoints are POST and return Frappe's `{ "message": ... }` envelope,
/// unwrapped by [_unwrap] exactly like the leads and B2B repositories.
class JourneyRepository {
  final Dio _dio;
  JourneyRepository(this._dio);

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('message')) {
      return data['message'];
    }
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  /// The full diary for one record, newest touch first.
  Future<List<JourneyNote>> getNotes({
    required String referenceDoctype,
    required String referenceName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getJourneyNotes,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
      },
    );
    final payload = _asMap(_unwrap(response));
    final raw = (payload['notes'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => JourneyNote.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<JourneyOptions> getOptions() async {
    final response = await _dio.post(ApiEndpoints.getJourneyOptions, data: {});
    return JourneyOptions.fromJson(_asMap(_unwrap(response)));
  }

  /// Logs one touch. A [nextActionDate] also schedules the follow-up reminder
  /// on the referenced record, server-side.
  Future<JourneyNote> addNote({
    required String referenceDoctype,
    required String referenceName,
    required String note,
    String? entryDate,
    String? entryType,
    String? contactPerson,
    String? contactRole,
    String? contactPhone,
    String? nextAction,
    String? nextActionDate,
    String? outcome,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.addJourneyNote,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'note': note,
        ..._optionalFields(
          entryDate: entryDate,
          entryType: entryType,
          contactPerson: contactPerson,
          contactRole: contactRole,
          contactPhone: contactPhone,
          nextAction: nextAction,
          nextActionDate: nextActionDate,
          outcome: outcome,
        ),
      },
    );
    return JourneyNote.fromJson(_asMap(_unwrap(response)));
  }

  /// Patches one note. Omitted fields are left alone; an empty string clears
  /// the field — which is why the optional fields here are sent whenever they
  /// are non-null, unlike the other repositories' non-empty-only payloads.
  Future<JourneyNote> updateNote({
    required String name,
    String? note,
    String? entryDate,
    String? entryType,
    String? contactPerson,
    String? contactRole,
    String? contactPhone,
    String? nextAction,
    String? nextActionDate,
    String? outcome,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.updateJourneyNote,
      data: {
        'name': name,
        if (note != null) 'note': note,
        ..._optionalFields(
          entryDate: entryDate,
          entryType: entryType,
          contactPerson: contactPerson,
          contactRole: contactRole,
          contactPhone: contactPhone,
          nextAction: nextAction,
          nextActionDate: nextActionDate,
          outcome: outcome,
          keepEmpty: true,
        ),
      },
    );
    return JourneyNote.fromJson(_asMap(_unwrap(response)));
  }

  /// The people already recorded on the account, newest roster from the
  /// server. Primary contact first.
  Future<JourneyContacts> getContacts({
    required String referenceDoctype,
    required String referenceName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.getJourneyContacts,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
      },
    );
    return JourneyContacts.fromJson(_asMap(_unwrap(response)));
  }

  /// Records one new person on the account and returns the whole roster back,
  /// with `added` naming the row that was just written.
  ///
  /// An append, not a replace: the rep who adds the barista they just met must
  /// not overwrite whatever a colleague is editing on the lead page.
  Future<JourneyContacts> addContact({
    required String referenceDoctype,
    required String referenceName,
    required String contactName,
    String? role,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.addJourneyContact,
      data: {
        'reference_doctype': referenceDoctype,
        'reference_name': referenceName,
        'contact_name': contactName,
        if ((role ?? '').trim().isNotEmpty) 'role': role!.trim(),
        if ((phone ?? '').trim().isNotEmpty) 'phone': phone!.trim(),
        if ((email ?? '').trim().isNotEmpty) 'email': email!.trim(),
        if ((notes ?? '').trim().isNotEmpty) 'notes': notes!.trim(),
      },
    );
    return JourneyContacts.fromJson(_asMap(_unwrap(response)));
  }

  Future<void> deleteNote(String name) async {
    await _dio.post(ApiEndpoints.deleteJourneyNote, data: {'name': name});
  }

  /// Shared payload builder. With [keepEmpty] the empty string is SENT (the
  /// edit path's way of clearing a field); without it, blank values are dropped
  /// so a create never writes empty strings the server would store as text.
  Map<String, dynamic> _optionalFields({
    String? entryDate,
    String? entryType,
    String? contactPerson,
    String? contactRole,
    String? contactPhone,
    String? nextAction,
    String? nextActionDate,
    String? outcome,
    bool keepEmpty = false,
  }) {
    final fields = <String, String?>{
      'entry_date': entryDate,
      'entry_type': entryType,
      'contact_person': contactPerson,
      'contact_role': contactRole,
      'contact_phone': contactPhone,
      'next_action': nextAction,
      'next_action_date': nextActionDate,
      'outcome': outcome,
    };
    final payload = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty && !keepEmpty) return;
      payload[key] = trimmed;
    });
    return payload;
  }
}

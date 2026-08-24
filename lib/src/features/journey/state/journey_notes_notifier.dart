import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../leads/data/models/lead.dart';
import '../data/journey_repository.dart';
import '../data/models/journey_note.dart';

/// The record a journey timeline hangs off. A plain value type (not a Dart
/// record) so the family key's equality is explicit and obvious at the call
/// sites that build one inline on every rebuild.
class JourneyRef {
  const JourneyRef({required this.doctype, required this.name});

  /// 'Lead' | 'Opportunity' | 'Customer'.
  final String doctype;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyRef && other.doctype == doctype && other.name == name);

  @override
  int get hashCode => Object.hash(doctype, name);

  @override
  String toString() => 'JourneyRef($doctype, $name)';
}

/// The journey diary for one record, newest touch first.
///
/// autoDispose: a rep opens many leads in a session and each one's timeline is
/// only interesting while its screen is up. Both surfaces that show it (the
/// lead detail and the B2B account) mount it fresh, so the list is never stale.
final journeyNotesProvider = AsyncNotifierProvider.autoDispose
    .family<JourneyNotesNotifier, List<JourneyNote>, JourneyRef>(
      JourneyNotesNotifier.new,
    );

class JourneyNotesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<JourneyNote>, JourneyRef> {
  JourneyRepository get _repo => ref.read(journeyRepositoryProvider);

  @override
  Future<List<JourneyNote>> build(JourneyRef arg) => _load();

  Future<List<JourneyNote>> _load() => _repo.getNotes(
    referenceDoctype: arg.doctype,
    referenceName: arg.name,
  );

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Logs a touch, then reloads so the timeline shows the server's version of
  /// the row (authorship and the cleaned note body are stamped server-side).
  Future<void> add({
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
    await _repo.addNote(
      referenceDoctype: arg.doctype,
      referenceName: arg.name,
      note: note,
      entryDate: entryDate,
      entryType: entryType,
      contactPerson: contactPerson,
      contactRole: contactRole,
      contactPhone: contactPhone,
      nextAction: nextAction,
      nextActionDate: nextActionDate,
      outcome: outcome,
    );
    await refresh();
  }

  /// Named `edit`, not `update`: AsyncNotifier already owns an `update`.
  Future<void> edit({
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
    await _repo.updateNote(
      name: name,
      note: note,
      entryDate: entryDate,
      entryType: entryType,
      contactPerson: contactPerson,
      contactRole: contactRole,
      contactPhone: contactPhone,
      nextAction: nextAction,
      nextActionDate: nextActionDate,
      outcome: outcome,
    );
    await refresh();
  }

  Future<void> remove(String name) async {
    await _repo.deleteNote(name);
    await refresh();
  }
}

/// The people on one account, for the note editor's WHO picker.
///
/// Its own provider rather than a field on the notes list: the roster changes
/// on a different cadence (a rep adds a person once, logs visits for months),
/// and the lead page edits the SAME rows through `save_lead_contacts` — so the
/// editor re-reads it when it opens instead of caching a copy per screen.
///
/// Never surfaces a hard failure to the editor: a site that cannot serve the
/// roster (no backing lead, pre-migrate child table) resolves to an empty,
/// non-addable payload and the editor falls back to its free-text boxes.
final journeyContactsProvider = AsyncNotifierProvider.autoDispose
    .family<JourneyContactsNotifier, JourneyContacts, JourneyRef>(
      JourneyContactsNotifier.new,
    );

class JourneyContactsNotifier
    extends AutoDisposeFamilyAsyncNotifier<JourneyContacts, JourneyRef> {
  JourneyRepository get _repo => ref.read(journeyRepositoryProvider);

  @override
  Future<JourneyContacts> build(JourneyRef arg) => _load();

  Future<JourneyContacts> _load() async {
    try {
      return await _repo.getContacts(
        referenceDoctype: arg.doctype,
        referenceName: arg.name,
      );
    } catch (_) {
      return const JourneyContacts();
    }
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _load());
  }

  /// Records a person and returns the stored row, so the caller can select it.
  /// Errors propagate here — a rep who typed a name deserves to be told it did
  /// not save, unlike the silent read above.
  Future<LeadContact?> addContact(LeadContact contact) async {
    final payload = await _repo.addContact(
      referenceDoctype: arg.doctype,
      referenceName: arg.name,
      contactName: contact.contactName,
      role: contact.role,
      phone: contact.phone,
      email: contact.email,
      notes: contact.notes,
    );
    state = AsyncValue.data(payload);
    return payload.added;
  }
}

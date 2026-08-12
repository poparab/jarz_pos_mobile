import 'package:flutter_riverpod/flutter_riverpod.dart';

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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/user_service.dart';

/// The counter's in-progress weekly count for one user, branch and week.
///
/// An item is either **uncounted** (absent from [counts]) or counted with a
/// whole number >= 0. The two are deliberately different: a 0 is a decision
/// ("there are none"), an absent entry is not, so nothing can count as done by
/// accident and the submit stays locked until every item has a number.
class WeeklyCountDraft {
  WeeklyCountDraft({
    required this.user,
    required this.posProfile,
    required this.weekStart,
    String? clientRequestId,
    this.submitAttempted = false,
    Map<String, int>? counts,
  }) : clientRequestId = clientRequestId ?? const Uuid().v4(),
       counts = {...?counts};

  /// The logged-in user this draft belongs to. Part of the key, so on a
  /// branch tablet shared between shifts one counter never opens (or
  /// submits) another counter's numbers.
  final String user;
  final String posProfile;
  final String weekStart;

  /// Sent with the submit so a retry after a dropped response returns the
  /// same document instead of creating a second one. Kept for the life of
  /// the draft (and therefore across an app kill), except after a rejection:
  /// see [renewRequestIdAfterRejection].
  String clientRequestId;

  /// Set (and saved) just before [clientRequestId] goes to the server. From
  /// then on the id may name a real document, even if the response was lost.
  bool submitAttempted;

  /// item_code -> counted qty. Absent = uncounted.
  final Map<String, int> counts;

  /// Hive key for one user, branch and week.
  static String storageKey(String user, String posProfile, String weekStart) =>
      'draft:$user:$posProfile:$weekStart';

  /// The key prefix of this user's drafts for one branch (any week).
  static String branchPrefix(String user, String posProfile) =>
      'draft:$user:$posProfile:';

  String get key => storageKey(user, posProfile, weekStart);

  /// The sheet opened while the branch is `rejected`. If this draft's id was
  /// already sent, it is the id of the submission that was rejected (one
  /// that went through later would have moved the branch out of `rejected`),
  /// and the server, idempotent on the id, would answer the recount with
  /// that rejected document. Give the recount a fresh id. A draft that never
  /// reached the server keeps its id: nothing was created under it.
  ///
  /// Returns true when it changed the draft (the caller saves it).
  bool renewRequestIdAfterRejection() {
    if (!submitAttempted) return false;
    clientRequestId = const Uuid().v4();
    submitAttempted = false;
    return true;
  }

  bool isCounted(String itemCode) => counts.containsKey(itemCode);

  int? qtyOf(String itemCode) => counts[itemCode];

  /// + on an uncounted item means "one"; otherwise one more.
  void increment(String itemCode) {
    final current = counts[itemCode];
    counts[itemCode] = current == null ? 1 : current + 1;
  }

  /// − on an uncounted item means "none"; never below zero.
  void decrement(String itemCode) {
    final current = counts[itemCode];
    counts[itemCode] = current == null ? 0 : (current > 0 ? current - 1 : 0);
  }

  void setQty(String itemCode, int qty) {
    counts[itemCode] = qty < 0 ? 0 : qty;
  }

  /// Back to uncounted.
  void clear(String itemCode) => counts.remove(itemCode);

  /// "All zero" for a section: sets only the items that are still uncounted
  /// to 0 and leaves every counted one alone. Returns how many it filled.
  int zeroUncounted(Iterable<String> itemCodes) {
    var filled = 0;
    for (final code in itemCodes) {
      if (!counts.containsKey(code)) {
        counts[code] = 0;
        filled++;
      }
    }
    return filled;
  }

  int countedOf(Iterable<String> itemCodes) =>
      itemCodes.where(counts.containsKey).length;

  bool isComplete(Iterable<String> itemCodes) =>
      itemCodes.every(counts.containsKey);

  /// The first item still to count, in the order given (sheet order).
  String? firstUncounted(Iterable<String> itemCodes) {
    for (final code in itemCodes) {
      if (!counts.containsKey(code)) return code;
    }
    return null;
  }

  /// The submit payload: one line per sheet item, in sheet order. Items that
  /// are no longer on the sheet are left out.
  List<Map<String, dynamic>> linesFor(Iterable<String> itemCodes) => [
    for (final code in itemCodes)
      if (counts.containsKey(code)) {'item_code': code, 'qty': counts[code]},
  ];

  /// The label payload: one `{label, qty}` per counted label key. Label keys
  /// share the counts map (and so the saved draft) under
  /// `label:<Jarz Customer Label name>`.
  List<Map<String, dynamic>> labelLinesFor(Iterable<String> labelKeys) => [
    for (final key in labelKeys)
      if (counts.containsKey(key))
        {
          'label': key.startsWith('label:') ? key.substring(6) : key,
          'qty': counts[key],
        },
  ];

  Map<String, dynamic> toJson() => {
    'user': user,
    'pos_profile': posProfile,
    'week_start': weekStart,
    'client_request_id': clientRequestId,
    'submit_attempted': submitAttempted,
    'counts': Map<String, int>.from(counts),
  };

  static WeeklyCountDraft? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final user = raw['user']?.toString() ?? '';
    final posProfile = raw['pos_profile']?.toString() ?? '';
    final weekStart = raw['week_start']?.toString() ?? '';
    if (user.isEmpty || posProfile.isEmpty || weekStart.isEmpty) return null;
    final rawCounts = raw['counts'];
    final counts = <String, int>{};
    if (rawCounts is Map) {
      rawCounts.forEach((k, v) {
        final n = v is num ? v.toInt() : int.tryParse('$v');
        if (n != null && n >= 0) counts[k.toString()] = n;
      });
    }
    final requestId = raw['client_request_id']?.toString() ?? '';
    return WeeklyCountDraft(
      user: user,
      posProfile: posProfile,
      weekStart: weekStart,
      clientRequestId: requestId.isEmpty ? null : requestId,
      submitAttempted: raw['submit_attempted'] == true,
      counts: counts,
    );
  }
}

/// Where drafts live between app runs. Abstract so tests run without Hive.
abstract class WeeklyCountDraftStore {
  Future<WeeklyCountDraft?> load(
    String user,
    String posProfile,
    String weekStart,
  );
  Future<void> save(WeeklyCountDraft draft);
  Future<void> delete(String user, String posProfile, String weekStart);
}

class HiveWeeklyCountDraftStore implements WeeklyCountDraftStore {
  Box<dynamic>? _box;

  Future<Box<dynamic>> _open() async {
    final existing = _box;
    if (existing != null && existing.isOpen) return existing;
    final box = Hive.isBoxOpen(HiveBoxes.weeklyCount)
        ? Hive.box(HiveBoxes.weeklyCount)
        : await Hive.openBox(HiveBoxes.weeklyCount);
    _box = box;
    return box;
  }

  @override
  Future<WeeklyCountDraft?> load(
    String user,
    String posProfile,
    String weekStart,
  ) async {
    final box = await _open();
    return WeeklyCountDraft.fromJson(
      box.get(WeeklyCountDraft.storageKey(user, posProfile, weekStart)),
    );
  }

  @override
  Future<void> save(WeeklyCountDraft draft) async {
    final box = await _open();
    // Drafts of past weeks are dead weight: the server only takes this week.
    final prefix = WeeklyCountDraft.branchPrefix(draft.user, draft.posProfile);
    final stale = box.keys
        .map((k) => k.toString())
        .where((k) => k.startsWith(prefix) && k != draft.key)
        .toList();
    if (stale.isNotEmpty) await box.deleteAll(stale);
    await box.put(draft.key, draft.toJson());
  }

  @override
  Future<void> delete(String user, String posProfile, String weekStart) async {
    final box = await _open();
    await box.delete(WeeklyCountDraft.storageKey(user, posProfile, weekStart));
  }
}

/// In-memory store for tests.
class MemoryWeeklyCountDraftStore implements WeeklyCountDraftStore {
  final Map<String, Map<String, dynamic>> data = {};

  @override
  Future<WeeklyCountDraft?> load(
    String user,
    String posProfile,
    String weekStart,
  ) async => WeeklyCountDraft.fromJson(
    data[WeeklyCountDraft.storageKey(user, posProfile, weekStart)],
  );

  @override
  Future<void> save(WeeklyCountDraft draft) async {
    data[draft.key] = draft.toJson();
  }

  @override
  Future<void> delete(String user, String posProfile, String weekStart) async {
    data.remove(WeeklyCountDraft.storageKey(user, posProfile, weekStart));
  }
}

final weeklyCountDraftStoreProvider = Provider<WeeklyCountDraftStore>(
  (ref) => HiveWeeklyCountDraftStore(),
);

/// Who the drafts belong to: the logged-in user, or null while unknown. With
/// no user the sheet keeps its draft in memory only, never under a shared key.
/// Follows [userRolesFutureProvider], which logout invalidates.
final weeklyCountDraftUserProvider = FutureProvider<String?>((ref) async {
  final roles = await ref.watch(userRolesFutureProvider.future);
  final user = roles.user.trim();
  return user.isEmpty ? null : user;
});

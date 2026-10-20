import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';

/// The counter's in-progress weekly count for one branch and one week.
///
/// An item is either **uncounted** (absent from [counts]) or counted with a
/// whole number >= 0. The two are deliberately different: a 0 is a decision
/// ("there are none"), an absent entry is not, so nothing can count as done by
/// accident and the submit stays locked until every item has a number.
class WeeklyCountDraft {
  WeeklyCountDraft({
    required this.posProfile,
    required this.weekStart,
    String? clientRequestId,
    Map<String, int>? counts,
  }) : clientRequestId = clientRequestId ?? const Uuid().v4(),
       counts = {...?counts};

  final String posProfile;
  final String weekStart;

  /// Sent with the submit so a retry after a dropped response returns the
  /// same document instead of creating a second one. Kept for the life of
  /// the draft (and therefore across an app kill).
  final String clientRequestId;

  /// item_code -> counted qty. Absent = uncounted.
  final Map<String, int> counts;

  /// Hive key for one branch-week.
  static String storageKey(String posProfile, String weekStart) =>
      'draft:$posProfile:$weekStart';

  String get key => storageKey(posProfile, weekStart);

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

  Map<String, dynamic> toJson() => {
    'pos_profile': posProfile,
    'week_start': weekStart,
    'client_request_id': clientRequestId,
    'counts': Map<String, int>.from(counts),
  };

  static WeeklyCountDraft? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final posProfile = raw['pos_profile']?.toString() ?? '';
    final weekStart = raw['week_start']?.toString() ?? '';
    if (posProfile.isEmpty || weekStart.isEmpty) return null;
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
      posProfile: posProfile,
      weekStart: weekStart,
      clientRequestId: requestId.isEmpty ? null : requestId,
      counts: counts,
    );
  }
}

/// Where drafts live between app runs. Abstract so tests run without Hive.
abstract class WeeklyCountDraftStore {
  Future<WeeklyCountDraft?> load(String posProfile, String weekStart);
  Future<void> save(WeeklyCountDraft draft);
  Future<void> delete(String posProfile, String weekStart);
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
  Future<WeeklyCountDraft?> load(String posProfile, String weekStart) async {
    final box = await _open();
    return WeeklyCountDraft.fromJson(
      box.get(WeeklyCountDraft.storageKey(posProfile, weekStart)),
    );
  }

  @override
  Future<void> save(WeeklyCountDraft draft) async {
    final box = await _open();
    // Drafts of past weeks are dead weight: the server only takes this week.
    final stale = box.keys
        .map((k) => k.toString())
        .where(
          (k) => k.startsWith('draft:${draft.posProfile}:') && k != draft.key,
        )
        .toList();
    if (stale.isNotEmpty) await box.deleteAll(stale);
    await box.put(draft.key, draft.toJson());
  }

  @override
  Future<void> delete(String posProfile, String weekStart) async {
    final box = await _open();
    await box.delete(WeeklyCountDraft.storageKey(posProfile, weekStart));
  }
}

/// In-memory store for tests.
class MemoryWeeklyCountDraftStore implements WeeklyCountDraftStore {
  final Map<String, Map<String, dynamic>> data = {};

  @override
  Future<WeeklyCountDraft?> load(String posProfile, String weekStart) async =>
      WeeklyCountDraft.fromJson(
        data[WeeklyCountDraft.storageKey(posProfile, weekStart)],
      );

  @override
  Future<void> save(WeeklyCountDraft draft) async {
    data[draft.key] = draft.toJson();
  }

  @override
  Future<void> delete(String posProfile, String weekStart) async {
    data.remove(WeeklyCountDraft.storageKey(posProfile, weekStart));
  }
}

final weeklyCountDraftStoreProvider = Provider<WeeklyCountDraftStore>(
  (ref) => HiveWeeklyCountDraftStore(),
);

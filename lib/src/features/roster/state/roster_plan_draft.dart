import '../models/roster_models.dart';
import '../models/roster_plan_models.dart';
import '../presentation/roster_shift_filter.dart';
import 'roster_providers.dart' show rosterIsoDate;

/// The rota plan wizard's working state, kept free of widgets so the rules
/// (period arithmetic, pre-fill, cover defaults, the payload) are testable on
/// their own.

/// The longest period `apply_plan` accepts.
const int rosterPlanMaxDays = 62;

enum RosterPlanPeriodKind { nextMonth, restOfMonth, custom }

/// An inclusive date range, held as UTC midnights (see [rosterWeeksOfMonth]
/// for why calendar arithmetic stays in UTC).
class RosterPlanPeriod {
  const RosterPlanPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get days => end.difference(start).inDays + 1;
  String get startIso => rosterIsoDate(start);
  String get endIso => rosterIsoDate(end);

  bool get isTooLong => days > rosterPlanMaxDays;
}

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

DateTime _lastOfMonth(DateTime d) => DateTime.utc(d.year, d.month + 1, 0);

/// The period a chip stands for, or null when it has none (no custom range
/// picked yet, or "rest of this month" on the month's last day).
///
/// "Next month" starts at the server's [suggestedStart] when it sent one, so
/// the phone's clock and the site's timezone cannot disagree about which month
/// is next; it ends on that month's last day.
RosterPlanPeriod? rosterPlanPeriodFor(
  RosterPlanPeriodKind kind, {
  required DateTime today,
  String? suggestedStart,
  RosterPlanPeriod? custom,
}) {
  final now = _day(today);
  switch (kind) {
    case RosterPlanPeriodKind.nextMonth:
      final parsed = DateTime.tryParse(suggestedStart ?? '');
      final start = parsed != null && !_day(parsed).isBefore(now)
          ? _day(parsed)
          : DateTime.utc(now.year, now.month + 1, 1);
      return RosterPlanPeriod(start, _lastOfMonth(start));
    case RosterPlanPeriodKind.restOfMonth:
      final start = now.add(const Duration(days: 1));
      final end = _lastOfMonth(now);
      if (start.isAfter(end)) return null;
      return RosterPlanPeriod(start, end);
    case RosterPlanPeriodKind.custom:
      if (custom == null) return null;
      return RosterPlanPeriod(_day(custom.start), _day(custom.end));
  }
}

/// One off weekday's cover, as the manager is filling it in.
class RosterPlanCoverDraft {
  RosterPlanCoverDraft({this.coveredBy, this.coverShiftType});

  String? coveredBy;
  String? coverShiftType;

  bool get isComplete =>
      coveredBy == null || (coverShiftType ?? '').trim().isNotEmpty;
}

/// One person's card on "Their week".
class RosterPlanRowDraft {
  RosterPlanRowDraft({
    required this.employee,
    this.shiftType,
    this.shiftLocation,
    Set<String>? offDays,
    this.useFridayVariant = true,
    Map<String, RosterPlanCoverDraft>? covers,
  }) : offDays = offDays ?? <String>{},
       covers = covers ?? <String, RosterPlanCoverDraft>{};

  final String employee;
  String? shiftType;
  String? shiftLocation;

  /// English weekday names.
  final Set<String> offDays;
  bool useFridayVariant;

  /// Keyed by English weekday; only weekdays in [offDays] are ever sent.
  final Map<String, RosterPlanCoverDraft> covers;

  factory RosterPlanRowDraft.fromDefaults(RosterPlanDefaultsEmployee d) =>
      RosterPlanRowDraft(
        employee: d.employee,
        shiftType: d.shiftType,
        shiftLocation: d.shiftLocation,
        offDays: d.offDays.toSet(),
        // Default ON: a Friday variant exists precisely because Friday hours
        // differ. The switch only shows when there is one.
        useFridayVariant: d.fridayShiftType == null ? true : d.useFridayVariant,
        covers: {
          for (final c in d.covers)
            if (d.offDays.contains(c.weekday))
              c.weekday: RosterPlanCoverDraft(
                coveredBy: c.coveredBy,
                coverShiftType: c.coverShiftType,
              ),
        },
      );

  void toggleOffDay(String weekday) {
    if (!offDays.remove(weekday)) {
      offDays.add(weekday);
    } else {
      covers.remove(weekday);
    }
  }

  /// "Same for everyone": take [source]'s shift and days off. Covers for a
  /// weekday that is no longer off are dropped; the rest are kept, since who
  /// covers whom is personal and never copied.
  void copyWeekFrom(RosterPlanRowDraft source) {
    shiftType = source.shiftType;
    useFridayVariant = source.useFridayVariant;
    offDays
      ..clear()
      ..addAll(source.offDays);
    covers.removeWhere((weekday, _) => !offDays.contains(weekday));
  }

  /// Ready to send: a shift, and every named coverer has a cover shift.
  bool get isComplete =>
      (shiftType ?? '').trim().isNotEmpty &&
      offDays.every((d) => covers[d]?.isComplete ?? true);
}

/// `<shift> - Friday` from [catalog] when it exists, else null.
String? rosterFridayVariantFor(String? shiftType, List<RosterShift> catalog) {
  final base = (shiftType ?? '').trim();
  if (base.isEmpty) return null;
  final wanted = '$base - friday'.toLowerCase();
  for (final shift in catalog) {
    if (shift.shiftType.trim().toLowerCase() == wanted) return shift.shiftType;
  }
  return null;
}

/// A [RosterEmployee] stand-in built from the plan defaults, so the existing
/// [rosterShiftsFor] filter can narrow the catalog to the person's group
/// (courier / factory / branch) exactly as the month screen does.
RosterEmployee rosterPlanEmployeeStub(
  RosterPlanDefaultsEmployee person, {
  String? shiftType,
}) {
  final shift = (shiftType ?? person.shiftType ?? '').trim();
  return RosterEmployee(
    employee: person.employee,
    employeeName: person.employeeName,
    designation: person.designation,
    isCourier: person.isCourier,
    shiftLocations: [
      if ((person.shiftLocation ?? '').isNotEmpty) person.shiftLocation!,
    ],
    days: {
      if (shift.isNotEmpty)
        '2000-01-03': RosterCell(date: '2000-01-03', shiftType: shift),
    },
  );
}

/// A Monday, so [rosterShiftsFor] leaves the `- Friday` variants out of the
/// weekly shift choice — the Friday switch handles those.
const List<String> rosterPlanAWeekday = ['2000-01-03'];

/// A Friday, for a cover on Fridays: the variants replace their weekday twin.
const List<String> rosterPlanAFriday = ['2000-01-07'];

/// The shifts to offer for [person]'s week, or — with [friday] — for a Friday
/// cover.
List<RosterShift> rosterPlanShiftsFor(
  RosterPlanDefaultsEmployee? person,
  List<RosterShift> catalog, {
  String? currentShift,
  String? selected,
  bool friday = false,
}) {
  if (person == null) {
    return catalog
        .where(
          (s) => friday || !s.shiftType.toLowerCase().endsWith(' - friday'),
        )
        .toList();
  }
  return rosterShiftsFor(
    rosterPlanEmployeeStub(person, shiftType: currentShift),
    catalog,
    dates: friday ? rosterPlanAFriday : rosterPlanAWeekday,
    selected: selected,
  );
}

/// The cover shift filled in when a coverer is picked.
///
/// The contract's rule: the coverer's group's full-day / cover shift when
/// there is exactly one (a cover usually stretches across both of the absent
/// person's overlapping shifts), else the coverer's own shift — their planned
/// one when they are in this plan, else their current one — else the absent
/// person's shift. On a Friday ([friday]) the result is swapped for its
/// `- Friday` variant when one exists, matching how the plan itself treats
/// Fridays.
String? rosterPlanDefaultCoverShift({
  required RosterPlanDefaultsEmployee? coverer,
  required List<RosterShift> catalog,
  String? covererPlannedShift,
  String? absentShift,
  bool friday = false,
}) {
  final base = _baseCoverShift(
    coverer: coverer,
    catalog: catalog,
    covererPlannedShift: covererPlannedShift,
    absentShift: absentShift,
  );
  if (!friday || base == null) return base;
  return rosterFridayVariantFor(base, catalog) ?? base;
}

String? _baseCoverShift({
  required RosterPlanDefaultsEmployee? coverer,
  required List<RosterShift> catalog,
  String? covererPlannedShift,
  String? absentShift,
}) {
  final own = (covererPlannedShift ?? coverer?.shiftType ?? '').trim();
  if (coverer != null) {
    final family = rosterPlanShiftsFor(
      coverer,
      catalog,
      currentShift: own.isEmpty ? null : own,
    );
    final coverShifts = family.where((s) {
      final name = s.shiftType.toLowerCase();
      return name.contains('cover') || name.contains('full day');
    }).toList();
    if (coverShifts.length == 1) return coverShifts.single.shiftType;
  }
  if (own.isNotEmpty) return own;
  final absent = (absentShift ?? '').trim();
  return absent.isEmpty ? null : absent;
}

/// The `apply_plan` payload for [rows], in the order given.
Map<String, dynamic> buildRosterPlanPayload({
  required RosterPlanPeriod period,
  required List<RosterPlanRowDraft> rows,
  required List<RosterShift> catalog,
  required bool replaceManual,
  required bool grantPosAccess,
}) {
  return {
    'start': period.startIso,
    'end': period.endIso,
    'replace_manual': replaceManual,
    'grant_pos_access': grantPosAccess,
    'rows': [
      for (final row in rows)
        {
          'employee': row.employee,
          'shift_type': row.shiftType,
          if ((row.shiftLocation ?? '').isNotEmpty)
            'shift_location': row.shiftLocation,
          // Saturday-first, the order the manager saw them in.
          'off_days': rosterPlanWeekdays.where(row.offDays.contains).toList(),
          // Only claimed when a variant exists: asking for one that does not
          // would just come back as a `no_friday_variant` note.
          'use_friday_variant':
              row.useFridayVariant &&
              rosterFridayVariantFor(row.shiftType, catalog) != null,
          'covers': [
            for (final weekday in rosterPlanWeekdays)
              if (row.offDays.contains(weekday) &&
                  (row.covers[weekday]?.coveredBy ?? '').isNotEmpty)
                {
                  'weekday': weekday,
                  'covered_by': row.covers[weekday]!.coveredBy,
                  'cover_shift_type': row.covers[weekday]!.coverShiftType,
                },
          ],
        },
    ],
  };
}

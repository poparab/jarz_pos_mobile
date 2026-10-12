import '../models/roster_models.dart';

/// Which group of people a shift type is for.
///
/// Read from the shift type's name because that is the only place the setup
/// records it: `Courier …`, `Factory`, and everything else is a branch shift
/// (`Branch Opening`, `Branch Closing`, `Branch Cover Full Day`).
enum RosterShiftFamily { courier, factory, branch }

const _fridaySuffix = ' - friday';

RosterShiftFamily rosterShiftFamily(String shiftType) {
  final name = shiftType.trim().toLowerCase();
  if (name.startsWith('courier')) return RosterShiftFamily.courier;
  if (name.contains('factory')) return RosterShiftFamily.factory;
  return RosterShiftFamily.branch;
}

bool _isFridayVariant(String shiftType) =>
    shiftType.trim().toLowerCase().endsWith(_fridaySuffix);

/// `Courier Nasr City - Friday` → `courier nasr city`.
String _baseName(String shiftType) {
  final name = shiftType.trim().toLowerCase();
  return name.endsWith(_fridaySuffix)
      ? name.substring(0, name.length - _fridaySuffix.length).trim()
      : name;
}

/// The group this person belongs to, or null when nothing says.
///
/// `Employee.designation` is empty for everyone, so this leans on what is
/// reliable: the server's courier flag, then the shifts the person actually
/// works this month, then the department (Dispatch / Production).
RosterShiftFamily? rosterEmployeeFamily(RosterEmployee employee) {
  if (employee.isCourier) return RosterShiftFamily.courier;

  final counts = <RosterShiftFamily, int>{};
  for (final cell in employee.days.values) {
    final type = cell.shiftType;
    if (type == null || type.isEmpty) continue;
    final family = rosterShiftFamily(type);
    counts[family] = (counts[family] ?? 0) + 1;
  }
  if (counts.isNotEmpty) {
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  final department = (employee.department ?? '').toLowerCase();
  if (department.contains('production') || department.contains('factory')) {
    return RosterShiftFamily.factory;
  }
  if (department.contains('dispatch') || department.contains('courier')) {
    return RosterShiftFamily.courier;
  }
  return null;
}

/// The shifts worth offering when changing [employee]'s day(s).
///
/// * Only the person's own group: couriers see courier shifts, factory staff
///   the factory shift, branch staff the branch shifts.
/// * A courier is narrowed further to their own route (Nasr City vs
///   6Oct-Dokki) when this month shows which one they ride.
/// * The `- Friday` variants appear only when every picked day is a Friday,
///   and then replace their weekday twin; a mixed selection shows both.
/// * [selected] is always kept, so the day's current shift stays visible.
///
/// Falls back to the whole catalog when the person's group is unknown or
/// the filter would leave nothing — a short list must never become no list.
List<RosterShift> rosterShiftsFor(
  RosterEmployee? employee,
  List<RosterShift> catalog, {
  Iterable<String> dates = const [],
  String? selected,
}) {
  if (employee == null || catalog.isEmpty) return catalog;
  final family = rosterEmployeeFamily(employee);
  if (family == null) return catalog;

  var shifts = catalog
      .where((s) => rosterShiftFamily(s.shiftType) == family)
      .toList();

  if (family == RosterShiftFamily.courier) {
    final routes = {
      for (final cell in employee.days.values)
        if (cell.shiftType != null &&
            rosterShiftFamily(cell.shiftType!) == RosterShiftFamily.courier)
          _baseName(cell.shiftType!),
    };
    final ownRoute = shifts
        .where((s) => routes.contains(_baseName(s.shiftType)))
        .toList();
    if (ownRoute.isNotEmpty) shifts = ownRoute;
  }

  final parsed = [
    for (final d in dates)
      if (DateTime.tryParse(d) != null) DateTime.parse(d),
  ];
  if (parsed.isNotEmpty) {
    final allFriday = parsed.every((d) => d.weekday == DateTime.friday);
    final noFriday = parsed.every((d) => d.weekday != DateTime.friday);
    if (noFriday) {
      shifts = shifts.where((s) => !_isFridayVariant(s.shiftType)).toList();
    } else if (allFriday) {
      final withFridayTwin = {
        for (final s in shifts)
          if (_isFridayVariant(s.shiftType)) _baseName(s.shiftType),
      };
      shifts = shifts
          .where(
            (s) =>
                _isFridayVariant(s.shiftType) ||
                !withFridayTwin.contains(_baseName(s.shiftType)),
          )
          .toList();
    }
  }

  if (shifts.isEmpty) return catalog;

  if (selected != null && !shifts.any((s) => s.shiftType == selected)) {
    for (final s in catalog) {
      if (s.shiftType == selected) {
        shifts = [...shifts, s];
        break;
      }
    }
  }
  return shifts;
}

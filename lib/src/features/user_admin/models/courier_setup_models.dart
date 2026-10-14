/// Models for `jarz_courier.api.onboarding.*` (courier setup from the Users
/// screen).
///
/// Parsing is defensive, in the style of `user_admin_models.dart`: the
/// endpoint ships from another app, so a missing or oddly typed field degrades
/// to blank/false instead of breaking the screen.
library;

/// Problem codes `diagnose_courier_setup` can report. Anything else is a code
/// from a newer server and is shown raw.
const knownCourierProblems = <String>[
  'no_identity',
  'no_pos_profile',
  'no_employee_branch',
  'branch_not_assigned',
];

/// One employee row from `list_courier_candidates`.
class CourierCandidate {
  const CourierCandidate({
    required this.employee,
    this.employeeName,
    this.branch,
    this.user,
    this.isCourier = false,
    this.setupOk = false,
    this.problems = const [],
  });

  final String employee;
  final String? employeeName;
  final String? branch;

  /// The linked login (email), if any.
  final String? user;
  final bool isCourier;
  final bool setupOk;
  final List<String> problems;

  String get displayName => employeeName ?? employee;

  bool get hasUser => user != null;

  /// Case-insensitive match on id, name, branch and login.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [employee, employeeName, branch, user].any(
      (v) => v != null && v.toLowerCase().contains(q),
    );
  }

  factory CourierCandidate.fromJson(Map<String, dynamic> json) =>
      CourierCandidate(
        employee: (json['employee'] ?? json['name'] ?? '').toString().trim(),
        employeeName: _nullIfBlank(json['employee_name']),
        branch: _nullIfBlank(json['branch']),
        user: _nullIfBlank(json['user'] ?? json['user_id']),
        isCourier: _toBool(json['is_courier']),
        setupOk: _toBool(json['setup_ok']),
        problems: _stringList(json['problems']),
      );
}

/// The `list_courier_candidates` answer.
class CourierCandidates {
  const CourierCandidates({this.employees = const [], this.branches = const []});

  final List<CourierCandidate> employees;

  /// Branch names for the setup form's picker.
  final List<String> branches;

  factory CourierCandidates.fromJson(Map<String, dynamic> json) {
    final rawEmployees = json['employees'];
    final employees = rawEmployees is List
        ? rawEmployees
              .whereType<Map>()
              .map((e) => CourierCandidate.fromJson(Map<String, dynamic>.from(e)))
              .where((c) => c.employee.isNotEmpty)
              .toList()
        : <CourierCandidate>[];
    return CourierCandidates(
      employees: employees,
      branches: parseBranchNames(json['branches']),
    );
  }
}

/// Branches arrive as plain names or as `{name|branch, ...}` maps; accept both.
List<String> parseBranchNames(dynamic value) {
  if (value is! List) return const [];
  final seen = <String>{};
  final out = <String>[];
  for (final item in value) {
    String? name;
    if (item is Map) {
      name = _nullIfBlank(item['name'] ?? item['branch']);
    } else {
      name = _nullIfBlank(item);
    }
    if (name != null && seen.add(name)) out.add(name);
  }
  return out;
}

/// The `diagnose_courier_setup` dict: whether a courier can actually log in
/// and receive runs, and what is missing when they cannot.
class CourierDiagnosis {
  const CourierDiagnosis({
    this.ok = false,
    this.user,
    this.displayName,
    this.employeeBranch,
    this.branch,
    this.posProfiles = const [],
    this.problems = const [],
    this.message,
  });

  final bool ok;
  final String? user;
  final String? displayName;
  final String? employeeBranch;
  final String? branch;
  final List<String> posProfiles;
  final List<String> problems;

  /// The server's own English sentence; shown only for codes we do not know.
  final String? message;

  factory CourierDiagnosis.fromJson(Map<String, dynamic> json) =>
      CourierDiagnosis(
        ok: _toBool(json['ok']),
        user: _nullIfBlank(json['user']),
        displayName: _nullIfBlank(json['display_name']),
        employeeBranch: _nullIfBlank(json['employee_branch']),
        branch: _nullIfBlank(json['branch']),
        posProfiles: _stringList(json['pos_profiles']),
        problems: _stringList(json['problems']),
        message: _nullIfBlank(json['message']),
      );
}

/// Where the courier signs in.
class CourierLinks {
  const CourierLinks({this.webUrl, this.apkUrl});

  final String? webUrl;
  final String? apkUrl;

  factory CourierLinks.fromJson(Map<String, dynamic> json) => CourierLinks(
    webUrl: _nullIfBlank(json['web_url']),
    apkUrl: _nullIfBlank(json['apk_url']),
  );
}

/// The `setup_courier` answer. The [pin] is returned once only: the screen
/// holds it in widget state for as long as the card is open and never writes
/// it anywhere (no provider, no storage, no log).
class CourierSetupResult {
  const CourierSetupResult({
    required this.user,
    this.employee,
    this.loginId,
    this.pin,
    this.diagnosis = const CourierDiagnosis(),
    this.links = const CourierLinks(),
  });

  final String user;
  final String? employee;
  final String? loginId;
  final String? pin;
  final CourierDiagnosis diagnosis;
  final CourierLinks links;

  /// What the courier types to sign in: the login id, else the user.
  String get signInId => loginId ?? user;

  factory CourierSetupResult.fromJson(Map<String, dynamic> json) =>
      CourierSetupResult(
        user: (json['user'] ?? '').toString().trim(),
        employee: _nullIfBlank(json['employee']),
        loginId: _nullIfBlank(json['login_id']),
        pin: _nullIfBlank(json['pin']),
        diagnosis: CourierDiagnosis.fromJson(_asMap(json['diagnosis'])),
        links: CourierLinks.fromJson(_asMap(json['links'])),
      );

  // Deliberately no PIN in the text form: a stray `print(result)` must not
  // leak it.
  @override
  String toString() => 'CourierSetupResult(user: $user, employee: $employee)';
}

/// The `reset_courier_pin` answer. Same one-time PIN rule as above.
class CourierPinReset {
  const CourierPinReset({required this.user, this.loginId, this.pin});

  final String user;
  final String? loginId;
  final String? pin;

  String get signInId => loginId ?? user;

  factory CourierPinReset.fromJson(Map<String, dynamic> json) => CourierPinReset(
    user: (json['user'] ?? '').toString().trim(),
    loginId: _nullIfBlank(json['login_id']),
    pin: _nullIfBlank(json['pin']),
  );

  @override
  String toString() => 'CourierPinReset(user: $user)';
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .where((e) => e != null)
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase() ?? '';
  return text == 'true' || text == '1';
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

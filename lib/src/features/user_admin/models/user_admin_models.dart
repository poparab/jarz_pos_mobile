/// User management models — ERPNext `User` accounts as the manager tier sees
/// them through `jarz_pos.api.user_admin.*`.
///
/// Plain classes with hand-written, defensive `fromJson` (the branch access
/// feature's style): every field tolerates absence, a null, or a 0/1 in place
/// of a bool, so a backend that adds or omits a key does not take the screen
/// down.
library;

/// The coarse bucket the server sorts every account into, from its roles.
enum UserTier {
  manager('manager'),
  lineManager('line_manager'),
  moderator('moderator'),
  b2b('b2b'),
  production('production'),
  staff('staff'),
  other('other');

  const UserTier(this.wire);

  /// The value the API sends.
  final String wire;

  static UserTier parse(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    for (final tier in UserTier.values) {
      if (tier.wire == text) return tier;
    }
    return UserTier.other;
  }
}

/// One Role Profile the caller could pick.
class RoleProfileOption {
  const RoleProfileOption({
    required this.name,
    this.roles = const [],
    this.tier = UserTier.other,
    this.privileged = false,
    this.assignable = false,
  });

  final String name;
  final List<String> roles;
  final UserTier tier;

  /// Grants a manager-level (or higher) role.
  final bool privileged;

  /// Whether the caller may give this profile to someone. The server refuses
  /// the rest, so the picker never offers them.
  final bool assignable;

  factory RoleProfileOption.fromJson(Map<String, dynamic> json) =>
      RoleProfileOption(
        name: (json['name'] ?? '').toString(),
        roles: _stringList(json['roles']),
        tier: UserTier.parse(json['tier']),
        privileged: _toBool(json['privileged']),
        assignable: _toBool(json['assignable']),
      );
}

/// What the caller may do, plus the choices the form offers.
class UserAdminContext {
  const UserAdminContext({
    this.canManage = false,
    this.isSystemManager = false,
    this.minPasswordLength = 8,
    this.roleProfiles = const [],
  });

  final bool canManage;
  final bool isSystemManager;
  final int minPasswordLength;
  final List<RoleProfileOption> roleProfiles;

  RoleProfileOption? profile(String name) {
    for (final p in roleProfiles) {
      if (p.name == name) return p;
    }
    return null;
  }

  factory UserAdminContext.fromJson(Map<String, dynamic> json) {
    final min = _toInt(json['min_password_length']);
    return UserAdminContext(
      canManage: _toBool(json['can_manage']),
      isSystemManager: _toBool(json['is_system_manager']),
      minPasswordLength: min == null || min < 1 ? 8 : min,
      roleProfiles: (json['role_profiles'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => RoleProfileOption.fromJson(Map<String, dynamic>.from(e)))
          .where((p) => p.name.isNotEmpty)
          .toList(),
    );
  }
}

/// One user account.
class UserAdminUser {
  const UserAdminUser({
    required this.name,
    this.email,
    this.fullName,
    this.firstName,
    this.lastName,
    this.mobileNo,
    this.enabled = true,
    this.requirePosShift = false,
    this.lastLogin,
    this.lastActive,
    this.creation,
    this.roleProfiles = const [],
    this.roles = const [],
    this.tier = UserTier.other,
    this.branches = const [],
    this.employee,
    this.employeeName,
    this.employeeBranch,
    this.isPrivileged = false,
    this.isSelf = false,
    this.canEdit = false,
  });

  /// The User document name — the login email.
  final String name;
  final String? email;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? mobileNo;
  final bool enabled;
  final bool requirePosShift;

  /// Server-local datetime strings, as Frappe sends them.
  final String? lastLogin;
  final String? lastActive;
  final String? creation;

  final List<String> roleProfiles;
  final List<String> roles;
  final UserTier tier;

  /// POS Profiles this user may open.
  final List<String> branches;
  final String? employee;
  final String? employeeName;
  final String? employeeBranch;
  final bool isPrivileged;
  final bool isSelf;

  /// False for accounts the caller may only look at (System Managers).
  final bool canEdit;

  String get displayName => fullName ?? employeeName ?? emailOrName;
  String get emailOrName => email ?? name;

  /// Up to two letters for the avatar.
  String get initials {
    final source = displayName.contains('@')
        ? displayName.split('@').first
        : displayName;
    final words = source
        .split(RegExp(r'[\s._-]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// This account with only [enabled] changed.
  UserAdminUser copyWithEnabled(bool enabled) => UserAdminUser(
    name: name,
    email: email,
    fullName: fullName,
    firstName: firstName,
    lastName: lastName,
    mobileNo: mobileNo,
    enabled: enabled,
    requirePosShift: requirePosShift,
    lastLogin: lastLogin,
    lastActive: lastActive,
    creation: creation,
    roleProfiles: roleProfiles,
    roles: roles,
    tier: tier,
    branches: branches,
    employee: employee,
    employeeName: employeeName,
    employeeBranch: employeeBranch,
    isPrivileged: isPrivileged,
    isSelf: isSelf,
    canEdit: canEdit,
  );

  DateTime? get lastLoginTime => _parseTime(lastLogin);
  DateTime? get creationTime => _parseTime(creation);

  /// Case-insensitive match on name, email, mobile, employee, profiles.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      name,
      email,
      fullName,
      mobileNo,
      employee,
      employeeName,
      ...roleProfiles,
    ].whereType<String>().any((v) => v.toLowerCase().contains(q));
  }

  factory UserAdminUser.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['email'] ?? '').toString();
    return UserAdminUser(
      name: name,
      email: _nullIfBlank(json['email']),
      fullName: _nullIfBlank(json['full_name']),
      firstName: _nullIfBlank(json['first_name']),
      lastName: _nullIfBlank(json['last_name']),
      mobileNo: _nullIfBlank(json['mobile_no']),
      // An absent key reads as enabled: a row the list returned is a live
      // account unless the server says otherwise.
      enabled: json.containsKey('enabled') ? _toBool(json['enabled']) : true,
      requirePosShift: _toBool(json['require_pos_shift']),
      lastLogin: _nullIfBlank(json['last_login']),
      lastActive: _nullIfBlank(json['last_active']),
      creation: _nullIfBlank(json['creation']),
      roleProfiles: _stringList(json['role_profiles']),
      roles: _stringList(json['roles']),
      tier: UserTier.parse(json['tier']),
      branches: _stringList(json['branches']),
      employee: _nullIfBlank(json['employee']),
      employeeName: _nullIfBlank(json['employee_name']),
      employeeBranch: _nullIfBlank(json['employee_branch']),
      isPrivileged: _toBool(json['is_privileged']),
      isSelf: _toBool(json['is_self']),
      canEdit: _toBool(json['can_edit']),
    );
  }
}

/// An active employee the account can be linked to.
class UserAdminEmployee {
  const UserAdminEmployee({
    required this.name,
    this.employeeName,
    this.branch,
    this.userId,
  });

  final String name;
  final String? employeeName;
  final String? branch;

  /// The account this employee is linked to right now, if any.
  final String? userId;

  String get displayName => employeeName ?? name;

  /// Linked to an account other than [user].
  bool linkedElsewhere(String? user) =>
      userId != null && (user == null || userId != user);

  factory UserAdminEmployee.fromJson(Map<String, dynamic> json) =>
      UserAdminEmployee(
        name: (json['name'] ?? '').toString(),
        employeeName: _nullIfBlank(json['employee_name']),
        branch: _nullIfBlank(json['branch']),
        userId: _nullIfBlank(json['user_id']),
      );
}

/// The `{ok, ...}` answer of reset_password / delete_user.
class UserAdminAck {
  const UserAdminAck({this.ok = false, this.user});

  final bool ok;
  final String? user;

  factory UserAdminAck.fromJson(Map<String, dynamic> json) => UserAdminAck(
    ok: _toBool(json['ok']),
    user: _nullIfBlank(json['user'] ?? json['deleted']),
  );
}

DateTime? _parseTime(String? value) =>
    value == null ? null : DateTime.tryParse(value);

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

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

String? _nullIfBlank(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/localization/localization_extensions.dart';
import '../../../core/localization/localized_formatters.dart';
import '../data/user_admin_repository.dart';
import '../models/user_admin_models.dart';
import '../state/user_admin_providers.dart';
import 'widgets/employee_picker_dialog.dart';
import 'widgets/password_dialog.dart';
import 'widgets/user_admin_widgets.dart';

/// Create a user ([userName] null) or view / edit one.
///
/// Loads `get_context` (role profiles, password rule) and, when editing, the
/// account itself; the form then works on its own copy and replaces it with
/// whatever each mutation returns, so it never re-fetches after a change.
class UserAdminFormScreen extends ConsumerWidget {
  const UserAdminFormScreen({super.key, this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = userName;
    final contextAsync = ref.watch(userAdminContextProvider);
    final userAsync = name == null
        ? const AsyncValue<UserAdminUser?>.data(null)
        : ref.watch(userAdminUserProvider(name));

    final error = contextAsync.error ?? userAsync.error;
    if (error != null && !(contextAsync.hasValue && userAsync.hasValue)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            name == null ? l10n.userAdminNewTitle : l10n.userAdminEditTitle,
          ),
        ),
        body: UserAdminErrorPanel(
          error: error,
          onRetry: () {
            ref.invalidate(userAdminContextProvider);
            if (name != null) ref.invalidate(userAdminUserProvider(name));
          },
        ),
      );
    }
    if (!contextAsync.hasValue || !userAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            name == null ? l10n.userAdminNewTitle : l10n.userAdminEditTitle,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return UserAdminForm(
      key: ValueKey(name ?? '__new__'),
      adminContext: contextAsync.requireValue,
      user: userAsync.valueOrNull,
    );
  }
}

class UserAdminForm extends ConsumerStatefulWidget {
  const UserAdminForm({super.key, required this.adminContext, this.user});

  final UserAdminContext adminContext;

  /// Null when creating.
  final UserAdminUser? user;

  static const maxFormWidth = 720.0;

  @override
  ConsumerState<UserAdminForm> createState() => _UserAdminFormState();
}

class _UserAdminFormState extends ConsumerState<UserAdminForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  /// The account as the server last described it. Null when creating.
  UserAdminUser? _user;
  Set<String> _profiles = {};
  bool _requireShift = false;

  /// A newly chosen employee (not yet saved).
  UserAdminEmployee? _employee;

  /// The existing link is to be removed on save.
  bool _employeeCleared = false;

  bool _obscure = true;
  bool _busy = false;
  bool _leaving = false;
  bool _profilesError = false;

  bool get _creating => _user == null;
  bool get _readOnly => _user != null && !_user!.canEdit;
  bool get _selfLocked => _user?.isSelf ?? false;

  @override
  void initState() {
    super.initState();
    _load(widget.user);
    for (final c in [_firstName, _lastName, _mobile, _email, _password]) {
      c.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() => setState(() {});

  void _load(UserAdminUser? user) {
    _user = user;
    _firstName.text = user?.firstName ?? '';
    _lastName.text = user?.lastName ?? '';
    _mobile.text = user?.mobileNo ?? '';
    _email.text = user?.emailOrName ?? '';
    _profiles = {...?user?.roleProfiles};
    _requireShift = user?.requirePosShift ?? false;
    _employee = null;
    _employeeCleared = false;
    _profilesError = false;
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _mobile,
      _email,
      _password,
      _confirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Change tracking ───────────────────────────────────────────────────

  bool get _firstNameChanged =>
      _firstName.text.trim() != (_user?.firstName ?? '');
  bool get _lastNameChanged => _lastName.text.trim() != (_user?.lastName ?? '');
  bool get _mobileChanged => _mobile.text.trim() != (_user?.mobileNo ?? '');
  bool get _profilesChanged {
    final original = {...?_user?.roleProfiles};
    return _profiles.length != original.length ||
        !_profiles.containsAll(original);
  }

  bool get _shiftChanged => _requireShift != (_user?.requirePosShift ?? false);
  bool get _employeeChanged =>
      _employee != null && _employee!.name != _user?.employee;
  bool get _clearEmployee => _employeeCleared && _user?.employee != null;

  bool get _dirty {
    if (_readOnly) return false;
    if (_creating) {
      return _firstName.text.trim().isNotEmpty ||
          _lastName.text.trim().isNotEmpty ||
          _mobile.text.trim().isNotEmpty ||
          _email.text.trim().isNotEmpty ||
          _password.text.isNotEmpty ||
          _profiles.isNotEmpty ||
          _employee != null;
    }
    return _firstNameChanged ||
        _lastNameChanged ||
        _mobileChanged ||
        _profilesChanged ||
        _shiftChanged ||
        _employeeChanged ||
        _clearEmployee;
  }

  // ── Actions ───────────────────────────────────────────────────────────

  /// Run one mutation; report success or the server's refusal.
  Future<void> _run(Future<String?> Function() action) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    setState(() => _busy = true);
    try {
      final message = await action();
      ref.invalidate(userAdminUsersProvider);
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(userAdminErrorText(context, error)),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Close the screen past the unsaved-changes guard.
  void _leave() {
    setState(() => _leaving = true);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final formOk = _formKey.currentState?.validate() ?? false;
    final profilesOk = _profiles.isNotEmpty;
    setState(() => _profilesError = !profilesOk);
    if (!formOk || !profilesOk) return;

    final repo = ref.read(userAdminRepositoryProvider);
    if (_creating) {
      await _run(() async {
        final created = await repo.createUser(
          email: _email.text.trim(),
          firstName: _firstName.text.trim(),
          password: _password.text,
          roleProfiles: _profiles.toList(),
          lastName: _lastName.text.trim(),
          mobileNo: _mobile.text.trim(),
          requirePosShift: _requireShift,
          employee: _employee?.name,
        );
        if (mounted) _leave();
        return l10n.userAdminCreatedMessage(created.displayName);
      });
      return;
    }

    if (!_dirty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.userAdminNoChanges)));
      return;
    }
    await _run(() async {
      final updated = await repo.updateUser(
        user: _user!.name,
        firstName: _firstNameChanged ? _firstName.text.trim() : null,
        lastName: _lastNameChanged ? _lastName.text.trim() : null,
        mobileNo: _mobileChanged ? _mobile.text.trim() : null,
        roleProfiles: _profilesChanged ? _profiles.toList() : null,
        requirePosShift: _shiftChanged ? _requireShift : null,
        employee: _employeeChanged ? _employee!.name : null,
        clearEmployee: _clearEmployee && !_employeeChanged,
      );
      if (mounted) setState(() => _load(updated));
      return l10n.userAdminSavedMessage(updated.displayName);
    });
  }

  Future<void> _changePassword() async {
    final user = _user!;
    final l10n = context.l10n;
    final choice = await showDialog<PasswordChoice>(
      context: context,
      builder: (_) => PasswordDialog(
        userName: user.displayName,
        minLength: widget.adminContext.minPasswordLength,
      ),
    );
    if (choice == null || !mounted) return;
    await _run(() async {
      await ref
          .read(userAdminRepositoryProvider)
          .resetPassword(
            user: user.name,
            newPassword: choice.password,
            signOut: choice.signOut,
          );
      return l10n.userAdminPasswordChangedMessage(user.displayName);
    });
  }

  Future<void> _toggleEnabled() async {
    final user = _user!;
    final l10n = context.l10n;
    final enable = !user.enabled;
    final confirmed = await _askConfirm(
      title: enable
          ? l10n.userAdminEnableTitle(user.displayName)
          : l10n.userAdminDisableTitle(user.displayName),
      body: enable ? l10n.userAdminEnableBody : l10n.userAdminDisableBody,
      action: enable ? l10n.userAdminEnable : l10n.userAdminDisable,
      destructive: !enable,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      final updated = await ref
          .read(userAdminRepositoryProvider)
          .setEnabled(user: user.name, enabled: enable);
      // Keep any unsaved edits; only the enabled state moved.
      if (mounted) {
        setState(() => _user = _user!.copyWithEnabled(updated.enabled));
      }
      return enable
          ? l10n.userAdminEnabledMessage(user.displayName)
          : l10n.userAdminDisabledMessage(user.displayName);
    });
  }

  Future<void> _delete() async {
    final user = _user!;
    final l10n = context.l10n;
    final confirmed = await _askConfirm(
      title: l10n.userAdminDeleteTitle(user.displayName),
      body: l10n.userAdminDeleteBody,
      action: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      await ref.read(userAdminRepositoryProvider).deleteUser(user.name);
      if (mounted) _leave();
      return l10n.userAdminDeletedMessage(user.displayName);
    });
  }

  Future<bool> _askConfirm({
    required String title,
    required String body,
    required String action,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.commonCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _pickEmployee() async {
    final picked = await showDialog<UserAdminEmployee>(
      context: context,
      builder: (_) => EmployeePickerDialog(currentUser: _user?.name),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (picked.name == _user?.employee) {
        _employee = null;
        _employeeCleared = false;
      } else {
        _employee = picked;
        _employeeCleared = false;
      }
    });
  }

  void _unlinkEmployee() => setState(() {
    _employee = null;
    _employeeCleared = true;
  });

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = _user;
    final canLeave = !_dirty || _leaving;

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _askConfirm(
          title: l10n.userAdminUnsavedTitle,
          body: l10n.userAdminUnsavedBody,
          action: l10n.userAdminDiscard,
          destructive: true,
        );
        if (discard && mounted) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            user == null ? l10n.userAdminNewTitle : user.displayName,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: _busy
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        bottomNavigationBar: _readOnly
            ? null
            : SafeArea(
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: UserAdminForm.maxFormWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('user-admin-save'),
                          onPressed: _busy ? null : _save,
                          icon: Icon(
                            _creating ? Icons.person_add_alt_1 : Icons.save,
                          ),
                          label: Text(
                            _creating ? l10n.userAdminCreate : l10n.commonSave,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UserAdminForm.maxFormWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (user != null) ..._header(user),
                      _accountSection(),
                      _rolesSection(),
                      _employeeSection(),
                      if (user != null) _infoSection(user),
                      if (user != null && !_readOnly) _actionsSection(user),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _header(UserAdminUser user) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Row(
          children: [
            UserAvatar(user: user, radius: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      TierTag(tier: user.tier),
                      if (user.isSelf) UserAdminTag(text: l10n.userAdminYouTag),
                      if (!user.enabled)
                        UserAdminTag(
                          text: l10n.userAdminDisabledTag,
                          color: theme.colorScheme.error,
                        ),
                      if (!user.canEdit)
                        UserAdminTag(
                          text: l10n.userAdminViewOnly,
                          icon: Icons.lock_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (_readOnly)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UserAdminBanner(
            icon: Icons.lock_outline,
            text: l10n.userAdminViewOnlyBanner,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      if (!user.enabled)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UserAdminBanner(
            icon: Icons.block,
            text: l10n.userAdminDisabledBanner,
            color: theme.colorScheme.error,
          ),
        ),
    ];
  }

  Widget _section(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _accountSection() {
    final l10n = context.l10n;
    final enabled = !_readOnly && !_busy;
    final min = widget.adminContext.minPasswordLength;
    const gap = SizedBox(height: 12);

    return _section(l10n.userAdminSectionAccount, [
      TextFormField(
        key: const ValueKey('user-admin-email'),
        controller: _email,
        enabled: _creating && enabled,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: l10n.userAdminEmail,
          helperText: _creating ? null : l10n.userAdminEmailReadOnly,
          prefixIcon: const Icon(Icons.alternate_email),
          border: const OutlineInputBorder(),
        ),
        validator: !_creating
            ? null
            : (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return l10n.userAdminFieldRequired;
                if (!isValidEmail(text)) return l10n.userAdminEmailInvalid;
                return null;
              },
      ),
      gap,
      LayoutBuilder(
        builder: (context, constraints) {
          final first = TextFormField(
            key: const ValueKey('user-admin-first-name'),
            controller: _firstName,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.userAdminFirstName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => (value?.trim() ?? '').isEmpty
                ? l10n.userAdminFieldRequired
                : null,
          );
          final last = TextFormField(
            controller: _lastName,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.userAdminLastName,
              border: const OutlineInputBorder(),
            ),
          );
          if (constraints.maxWidth < 480) {
            return Column(children: [first, gap, last]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: last),
            ],
          );
        },
      ),
      gap,
      TextFormField(
        controller: _mobile,
        enabled: enabled,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: l10n.userAdminMobile,
          prefixIcon: const Icon(Icons.phone_outlined),
          border: const OutlineInputBorder(),
        ),
      ),
      if (_creating) ...[
        gap,
        TextFormField(
          key: const ValueKey('user-admin-password'),
          controller: _password,
          enabled: enabled,
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.userAdminPassword,
            helperText: l10n.userAdminPasswordTooShort(min),
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _obscure
                  ? l10n.userAdminShowPassword
                  : l10n.userAdminHidePassword,
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: (value) => validatePassword(l10n, value, min),
        ),
        gap,
        TextFormField(
          key: const ValueKey('user-admin-confirm'),
          controller: _confirm,
          enabled: enabled,
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.userAdminConfirmPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
          ),
          validator: (value) => (value ?? '') != _password.text
              ? l10n.userAdminPasswordMismatch
              : null,
        ),
      ],
      gap,
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.userAdminRequirePosShift),
        subtitle: Text(l10n.userAdminRequirePosShiftHelp),
        value: _requireShift,
        onChanged: enabled ? (v) => setState(() => _requireShift = v) : null,
      ),
    ]);
  }

  Widget _rolesSection() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final ctx = widget.adminContext;
    final locked = _readOnly || _selfLocked || _busy;
    final original = {...?_user?.roleProfiles};

    // Offer what may be assigned; keep showing (greyed) anything the user
    // already holds that the caller could not give, so nothing looks missing.
    final options = <RoleProfileOption>[
      for (final p in ctx.roleProfiles)
        if (p.assignable ||
            original.contains(p.name) ||
            _profiles.contains(p.name))
          p,
      for (final name in original)
        if (ctx.profile(name) == null) RoleProfileOption(name: name),
    ];

    return _section(l10n.userAdminSectionRoles, [
      if (_selfLocked && !_readOnly)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UserAdminBanner(
            icon: Icons.lock_person_outlined,
            text: l10n.userAdminRoleProfilesSelfLocked,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      if (!_creating && _profilesChanged)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UserAdminBanner(
            key: const ValueKey('user-admin-roles-warning'),
            icon: Icons.warning_amber_rounded,
            text: l10n.userAdminRoleProfilesReplaceWarning,
            color: theme.colorScheme.tertiary,
          ),
        ),
      if (options.isEmpty)
        Text(l10n.userAdminNoRoleProfiles)
      else
        for (final option in options)
          _ProfileTile(
            option: option,
            selected: _profiles.contains(option.name),
            enabled: !locked && option.assignable,
            onChanged: (selected) => setState(() {
              if (selected) {
                _profiles.add(option.name);
              } else {
                _profiles.remove(option.name);
              }
              if (_profiles.isNotEmpty) _profilesError = false;
            }),
          ),
      if (_profilesError)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            l10n.userAdminRoleProfilesRequired,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
    ]);
  }

  Widget _employeeSection() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = _user;
    final enabled = !_readOnly && !_busy;

    String? title;
    String? subtitle;
    String? warning;
    if (_employee != null) {
      final e = _employee!;
      title = e.displayName;
      subtitle = [e.name, if (e.branch != null) e.branch!].join(' · ');
      if (e.linkedElsewhere(user?.name)) {
        warning = l10n.userAdminEmployeeLinkedWarning(e.userId!);
      }
    } else if (!_employeeCleared && user?.employee != null) {
      title = user!.employeeName ?? user.employee!;
      subtitle = [
        user.employee!,
        if (user.employeeBranch != null) user.employeeBranch!,
      ].join(' · ');
    }

    return _section(l10n.userAdminSectionEmployee, [
      Row(
        children: [
          Icon(
            title == null ? Icons.badge_outlined : Icons.badge,
            color: title == null
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? l10n.userAdminEmployeeNone,
                  style: theme.textTheme.bodyLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      if (warning != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: UserAdminBanner(
            icon: Icons.link,
            text: warning,
            color: theme.colorScheme.tertiary,
          ),
        ),
      if (_employeeCleared && user?.employee != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.userAdminEmployeeUnlinkPending,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
        ),
      if (enabled)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('user-admin-pick-employee'),
                onPressed: _pickEmployee,
                icon: const Icon(Icons.search),
                label: Text(
                  title == null
                      ? l10n.userAdminEmployeeChoose
                      : l10n.userAdminEmployeeChange,
                ),
              ),
              if (title != null)
                TextButton.icon(
                  onPressed: _employee != null && user?.employee == null
                      ? () => setState(() => _employee = null)
                      : _unlinkEmployee,
                  icon: const Icon(Icons.link_off),
                  label: Text(l10n.userAdminEmployeeUnlink),
                ),
            ],
          ),
        ),
    ]);
  }

  Widget _infoSection(UserAdminUser user) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lastLogin = user.lastLoginTime;
    final created = user.creationTime;
    const pattern = 'd MMM yyyy, HH:mm';

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );

    return _section(l10n.userAdminSectionBranches, [
      if (user.branches.isEmpty)
        Text(
          l10n.userAdminBranchesNone,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        )
      else
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final b in user.branches)
              Chip(
                avatar: const Icon(Icons.storefront_outlined, size: 16),
                label: Text(b),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => context.push(AppRoutes.branchAccess),
          icon: const Icon(Icons.store_mall_directory_outlined),
          label: Text(l10n.userAdminManageBranchAccess),
        ),
      ),
      const Divider(),
      row(
        l10n.userAdminLastLogin,
        lastLogin == null
            ? l10n.userAdminNever
            : formatDateTime(context, lastLogin, pattern: pattern),
      ),
      if (created != null)
        row(
          l10n.userAdminCreatedOn,
          formatDateTime(context, created, pattern: pattern),
        ),
    ]);
  }

  Widget _actionsSection(UserAdminUser user) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    final busy = _busy;
    return _section(l10n.userAdminSectionActions, [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('user-admin-change-password'),
            onPressed: busy ? null : _changePassword,
            icon: const Icon(Icons.password),
            label: Text(l10n.userAdminChangePassword),
          ),
          if (!user.isSelf)
            OutlinedButton.icon(
              key: const ValueKey('user-admin-toggle-enabled'),
              onPressed: busy ? null : _toggleEnabled,
              icon: Icon(
                user.enabled ? Icons.block : Icons.check_circle_outline,
              ),
              label: Text(
                user.enabled ? l10n.userAdminDisable : l10n.userAdminEnable,
              ),
            ),
          if (!user.isSelf)
            OutlinedButton.icon(
              key: const ValueKey('user-admin-delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: error,
                side: BorderSide(color: error),
              ),
              onPressed: busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.userAdminDelete),
            ),
        ],
      ),
    ]);
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final RoleProfileOption option;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tile = CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      title: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(option.name),
          if (option.tier != UserTier.other) TierTag(tier: option.tier),
          if (option.privileged)
            UserAdminTag(
              text: l10n.userAdminPrivilegedTag,
              icon: Icons.shield_outlined,
              color: theme.colorScheme.error,
            ),
        ],
      ),
      subtitle: option.roles.isEmpty
          ? null
          : Text(
              option.roles.join(', '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
    if (option.assignable) return tile;
    return Tooltip(
      message: l10n.userAdminRoleProfileNotAssignable,
      child: tile,
    );
  }
}

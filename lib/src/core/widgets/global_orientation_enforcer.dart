import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/responsive_utils.dart';

/// When `true`, the phone portrait-only lock is lifted so landscape is allowed.
/// Set to `true` only by [PhoneLandscapeScope] while the Reports route is active.
final allowPhoneLandscapeProvider = StateProvider<bool>((_) => false);

// ---------------------------------------------------------------------------
// Orientation constants
// ---------------------------------------------------------------------------

const _portraitOnly = <DeviceOrientation>[DeviceOrientation.portraitUp];

const _allOrientations = <DeviceOrientation>[
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

const _landscapeOnly = <DeviceOrientation>[
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

// ---------------------------------------------------------------------------
// GlobalOrientationEnforcer
// ---------------------------------------------------------------------------

/// Single, app-wide orientation enforcer mounted above the Navigator (in
/// [MaterialApp.builder]) so it governs every screen **and** every dialog /
/// bottom-sheet — eliminating the per-route dispose() race that caused the
/// Kanban rotation bug.
///
/// Policy:
///   - Tablet (shortestSide ≥ 600 dp): landscape-only.
///   - Phone + [allowPhoneLandscapeProvider] == true: all orientations.
///   - Phone (default): portrait-only.
class GlobalOrientationEnforcer extends ConsumerStatefulWidget {
  const GlobalOrientationEnforcer({super.key, required this.child});

  final Widget child;

  /// Call once before [runApp] to start in portrait.
  /// Tablets self-correct on the first frame when [GlobalOrientationEnforcer]
  /// builds and detects a large screen.
  static Future<void> applyStartupOrientation() {
    if (kIsWeb) return Future<void>.value();
    return SystemChrome.setPreferredOrientations(_portraitOnly);
  }

  @override
  ConsumerState<GlobalOrientationEnforcer> createState() =>
      _GlobalOrientationEnforcerState();
}

class _GlobalOrientationEnforcerState
    extends ConsumerState<GlobalOrientationEnforcer>
    with WidgetsBindingObserver {
  List<DeviceOrientation>? _lastApplied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleApply();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleApply();
  }

  @override
  void didChangeMetrics() {
    _scheduleApply();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleApply() {
    if (kIsWeb) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyPolicy();
    });
  }

  void _applyPolicy() {
    final orientations = _targetOrientations();
    if (listEquals(_lastApplied, orientations)) return;
    _lastApplied = orientations;
    unawaited(SystemChrome.setPreferredOrientations(orientations));
  }

  List<DeviceOrientation> _targetOrientations() {
    if (ResponsiveUtils.isPhone(context)) {
      final phoneLandscapeAllowed = ref.read(allowPhoneLandscapeProvider);
      return phoneLandscapeAllowed ? _allOrientations : _portraitOnly;
    }
    return _landscapeOnly;
  }

  @override
  Widget build(BuildContext context) {
    // Re-apply whenever the landscape-exception provider changes.
    ref.listen<bool>(allowPhoneLandscapeProvider, (previous, next) => _scheduleApply());
    return widget.child;
  }
}

// ---------------------------------------------------------------------------
// PhoneLandscapeScope
// ---------------------------------------------------------------------------

/// Wrap a single route's builder child to allow landscape on phones while
/// that route is mounted.  Used exclusively by the Reports route.
class PhoneLandscapeScope extends ConsumerStatefulWidget {
  const PhoneLandscapeScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PhoneLandscapeScope> createState() =>
      _PhoneLandscapeScopeState();
}

class _PhoneLandscapeScopeState extends ConsumerState<PhoneLandscapeScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(allowPhoneLandscapeProvider.notifier).state = true;
      }
    });
  }

  @override
  void dispose() {
    ref.read(allowPhoneLandscapeProvider.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

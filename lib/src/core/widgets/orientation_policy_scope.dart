import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/responsive_utils.dart';

enum AppOrientationPolicy {
  landscapeOnly,
  handsetAny,
}

class OrientationPolicyScope extends StatefulWidget {
  final AppOrientationPolicy policy;
  final Widget child;

  const OrientationPolicyScope({
    super.key,
    required this.policy,
    required this.child,
  });

  static const _landscapeOnly = <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static const _allOrientations = <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static Future<void> applyDefaultNativePolicy() {
    if (kIsWeb) return Future<void>.value();
    return SystemChrome.setPreferredOrientations(_landscapeOnly);
  }

  @override
  State<OrientationPolicyScope> createState() => _OrientationPolicyScopeState();
}

class _OrientationPolicyScopeState extends State<OrientationPolicyScope>
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
  void didUpdateWidget(covariant OrientationPolicyScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.policy != widget.policy) {
      _scheduleApply();
    }
  }

  @override
  void didChangeMetrics() {
    _scheduleApply();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb) {
      unawaited(OrientationPolicyScope.applyDefaultNativePolicy());
    }
    super.dispose();
  }

  void _scheduleApply() {
    if (kIsWeb) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyPolicy();
    });
  }

  void _applyPolicy() {
    final orientations = _orientationsForContext();
    if (listEquals(_lastApplied, orientations)) return;
    _lastApplied = orientations;
    unawaited(SystemChrome.setPreferredOrientations(orientations));
  }

  List<DeviceOrientation> _orientationsForContext() {
    switch (widget.policy) {
      case AppOrientationPolicy.handsetAny:
        if (ResponsiveUtils.isPhone(context)) {
          return OrientationPolicyScope._allOrientations;
        }
        return OrientationPolicyScope._landscapeOnly;
      case AppOrientationPolicy.landscapeOnly:
        return OrientationPolicyScope._landscapeOnly;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
import 'package:flutter/material.dart';

/// A widget that dismisses the keyboard when tapped outside of text fields.
/// 
/// This widget wraps its child with a [GestureDetector] that unfocuses
/// the current focus when tapped. This is useful for forms and screens
/// with text input fields where you want users to be able to dismiss
/// the keyboard by tapping anywhere on the screen.
/// 
/// Usage:
/// ```dart
/// KeyboardDismissibleWidget(
///   child: YourScreenContent(),
/// )
/// ```
class KeyboardDismissibleWidget extends StatelessWidget {
  /// The widget to wrap with keyboard dismissal functionality
  final Widget child;
  
  /// Whether to consume the tap event or allow it to propagate
  /// Set to false if you need the tap to reach widgets behind this detector
  final bool consumeTap;

  const KeyboardDismissibleWidget({
    super.key,
    required this.child,
    this.consumeTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _dismissKeyboard(context),
      behavior: consumeTap ? HitTestBehavior.opaque : HitTestBehavior.translucent,
      child: child,
    );
  }

  /// Dismisses the keyboard by unfocusing the current focus node
  void _dismissKeyboard(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

/// Extension to easily wrap any widget with keyboard dismissal functionality
extension KeyboardDismissibleExtension on Widget {
  /// Wraps this widget with keyboard dismissal functionality
  Widget dismissKeyboardOnTap({bool consumeTap = true}) {
    return KeyboardDismissibleWidget(
      consumeTap: consumeTap,
      child: this,
    );
  }
}

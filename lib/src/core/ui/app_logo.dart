import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withSpinner;
  final EdgeInsetsGeometry padding;

  const AppLogo({
    super.key,
    this.size = 120,
    this.withSpinner = false,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    if (!withSpinner) return Padding(padding: padding, child: logo);
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

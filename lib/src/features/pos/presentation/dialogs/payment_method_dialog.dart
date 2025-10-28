import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Payment method selection dialog
/// Shows Cash, Instapay, and Mobile Wallet options
class PaymentMethodDialog extends StatelessWidget {
  const PaymentMethodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(context, 24);
    final buttonSpacing = ResponsiveUtils.getSpacing(context, small: 12, medium: 14, large: 16);
    final padding = ResponsiveUtils.getCardPadding(context,
      small: const EdgeInsets.all(18),
      medium: const EdgeInsets.all(20),
      large: const EdgeInsets.all(24),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getDialogWidth(context, small: 320, medium: 380, large: 450),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: buttonSpacing * 1.5),
              
              // Cash option
              _PaymentMethodButton(
                icon: Icons.attach_money,
                label: 'Cash',
                color: Colors.green,
                onTap: () => Navigator.of(context).pop('Cash'),
              ),
              SizedBox(height: buttonSpacing),
              
              // Instapay option
              _PaymentMethodButton(
                icon: Icons.account_balance,
                label: 'Instapay',
                color: Colors.blue,
                onTap: () => Navigator.of(context).pop('Instapay'),
              ),
              SizedBox(height: buttonSpacing),
              
              // Mobile Wallet option
              _PaymentMethodButton(
                icon: Icons.phone_android,
                label: 'Mobile Wallet',
                color: Colors.purple,
                onTap: () => Navigator.of(context).pop('Mobile Wallet'),
              ),
              SizedBox(height: buttonSpacing),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the payment method dialog
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentMethodDialog(),
    );
  }
}

/// Payment method button widget
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveUtils.getIconSize(context, small: 26, medium: 29, large: 32);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 18);
    final padding = ResponsiveUtils.getCardPadding(context,
      small: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      medium: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
      large: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    );
    final spacing = ResponsiveUtils.getSpacing(context, small: 12, medium: 14, large: 16);
    
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: padding,
          child: Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: color,
              ),
              SizedBox(width: spacing),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

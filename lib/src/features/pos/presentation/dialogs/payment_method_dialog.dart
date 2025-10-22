import 'package:flutter/material.dart';

/// Payment method selection dialog
/// Shows Cash, Instapay, and Mobile Wallet options
class PaymentMethodDialog extends StatelessWidget {
  const PaymentMethodDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Cash option
            _PaymentMethodButton(
              icon: Icons.attach_money,
              label: 'Cash',
              color: Colors.green,
              onTap: () => Navigator.of(context).pop('Cash'),
            ),
            const SizedBox(height: 16),
            
            // Instapay option
            _PaymentMethodButton(
              icon: Icons.account_balance,
              label: 'Instapay',
              color: Colors.blue,
              onTap: () => Navigator.of(context).pop('Instapay'),
            ),
            const SizedBox(height: 16),
            
            // Mobile Wallet option
            _PaymentMethodButton(
              icon: Icons.phone_android,
              label: 'Mobile Wallet',
              color: Colors.purple,
              onTap: () => Navigator.of(context).pop('Mobile Wallet'),
            ),
            const SizedBox(height: 16),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
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
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
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

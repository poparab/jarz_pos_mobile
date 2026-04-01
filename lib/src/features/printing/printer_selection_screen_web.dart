import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web placeholder for the printer selection screen.
/// Bluetooth printing is not available in web browsers.
class PrinterSelectionScreen extends ConsumerStatefulWidget {
  const PrinterSelectionScreen({super.key});

  @override
  ConsumerState<PrinterSelectionScreen> createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends ConsumerState<PrinterSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Printers')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Printing is not available on web',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Use the mobile app for Bluetooth receipt printing.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

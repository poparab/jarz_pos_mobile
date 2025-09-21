// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'pos_printer_provider.dart';
import 'pos_printer_service.dart';
import 'printer_status.dart';

class PrinterSelectionScreen extends ConsumerStatefulWidget {
  const PrinterSelectionScreen({super.key});

  @override
  ConsumerState<PrinterSelectionScreen> createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends ConsumerState<PrinterSelectionScreen> {
  bool _scanning = false;
  List<ScanResult> _results = [];
  late final Stream<List<ScanResult>> _scanStream;

  @override
  void initState() {
    super.initState();
    final svc = ref.read(posPrinterServiceProvider);
    _scanStream = svc.scanStream;
    _scanStream.listen((r) {
      if (mounted) {
        setState(() => _results = r);
      }
    });
    _startScan();
  }

  Future<void> _startScan() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    final svc = ref.read(posPrinterServiceProvider);
    await svc.startScan();
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _showDiagnostics() async {
    final svc = ref.read(posPrinterServiceProvider);
    final statuses = await svc.permissionStatuses();
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final idController = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnostics', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Adapter: $adapterState'),
              Text('Perm scan: ${statuses['scan']}'),
              Text('Perm connect: ${statuses['connect']}'),
              Text('Perm location: ${statuses['location']}'),
              const Divider(height: 24),
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Device ID (MAC / Identifier)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final id = idController.text.trim();
                      if (id.isEmpty) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting by ID...')));
                      final ok = await svc.connectById(id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Connected' : 'Failed')));
                      if (ok) Navigator.of(context).pop(true);
                    },
                    child: const Text('Connect by ID'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '')); // no-op placeholder
                      Navigator.pop(ctx);
                    },
                    child: const Text('Close'),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _connect(ScanResult r) async {
    final svc = ref.read(posPrinterServiceProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting...')));
    final ok = await svc.connect(r.device);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printer connected')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(posPrinterServiceProvider);
    final lastId = printer.lastPrinterId;
  final classicDevices = printer.classicBonded; // ClassicBondedDevice list
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Printer'),
        actions: [
          IconButton(
            tooltip: 'Diagnostics',
            icon: const Icon(Icons.info_outline),
            onPressed: _showDiagnostics,
          ),
          if (printer.selectedDevice != null)
            IconButton(
              tooltip: 'Forget saved printer',
              icon: const Icon(Icons.link_off),
              onPressed: () async {
                await printer.forgetPrinter();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot saved printer')));
                }
              },
            ),
          IconButton(
            tooltip: 'Rescan',
            icon: _scanning ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.refresh),
            onPressed: _scanning ? null : _startScan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (printer.unifiedStatus == PrinterUnifiedStatus.error && printer.lastErrorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(printer.lastErrorMessage!, style: const TextStyle(color: Colors.red))),
                  TextButton(
                    onPressed: () => _startScan(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
          if (_results.isEmpty && !_scanning && lastId != null && printer.selectedDevice == null)
            Card(
              margin: const EdgeInsets.all(12),
              color: Colors.orange.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Last saved printer: $lastId\nIt is not currently advertising. You can still attempt to reconnect.')),
                    ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reconnecting...')));
                        final ok = await ref.read(posPrinterServiceProvider).connectLastSaved();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Reconnected' : 'Reconnect failed')));
                        if (ok) Navigator.of(context).pop(true);
                      },
                      child: const Text('Reconnect'),
                    )
                  ],
                ),
              ),
            ),
          if (printer.selectedDevice != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.print, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Connected: ${printer.selectedDevice!.platformName.isNotEmpty ? printer.selectedDevice!.platformName : printer.selectedDevice!.remoteId.str}')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final res = await printer.testPrint();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res == PrintResult.success ? 'Test print sent' : 'Test failed: $res')),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  )
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                // BLE Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth, size: 16),
                      const SizedBox(width: 6),
                      const Text('BLE Devices', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_scanning)
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      if (!_scanning)
                        IconButton(
                          tooltip: 'Rescan BLE',
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _startScan,
                        ),
                    ],
                  ),
                ),
                if (_results.isEmpty && !_scanning)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('No BLE devices discovered.'),
                  )
                else
                  ..._results.map((r) {
                    final name = r.device.platformName.isNotEmpty
                        ? r.device.platformName
                        : (r.advertisementData.advName.isNotEmpty
                            ? r.advertisementData.advName
                            : r.device.remoteId.str);
                    final connected = printer.selectedDevice?.remoteId == r.device.remoteId;
                    return ListTile(
                      leading: Icon(connected ? Icons.print : Icons.bluetooth),
                      title: Text(name.isEmpty ? 'Unknown Printer' : name),
                      subtitle: Text(r.device.remoteId.str),
                      trailing: connected
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _connect(r),
                              child: const Text('Connect'),
                            ),
                    );
                  }),
                const Divider(height: 32),
                // Classic Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.print, size: 16),
                      const SizedBox(width: 6),
                      const Text('Paired Classic Devices', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Refresh Classic List',
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () async {
                          // Just re-run scan (which triggers classic reload) but much faster
                          await ref.read(posPrinterServiceProvider).startScan(timeout: const Duration(seconds: 4));
                        },
                      ),
                    ],
                  ),
                ),
                if (classicDevices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'No paired classic printers found. Ensure the printer is paired in System Bluetooth settings and that Location (Android 8) is enabled.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  )
                else
                  ...classicDevices.map((d) {
                    final connectedClassic = printer.classicDevice?.mac == d.mac && printer.isClassicConnected;
                    return ListTile(
                      leading: Icon(connectedClassic ? Icons.print : Icons.print_outlined),
                      title: Text(d.name.isEmpty ? 'Unknown Printer' : d.name),
                      subtitle: Text('${d.mac}${connectedClassic ? '  (Classic)' : ''}'),
                      trailing: connectedClassic
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print_outlined),
                                  tooltip: 'Test Print',
                                  onPressed: () async {
                                    final res = await printer.testPrint();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res == PrintResult.success ? 'Test print sent' : 'Failed: $res')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.link_off),
                                  tooltip: 'Disconnect',
                                  onPressed: () async {
                                    await printer.disconnectClassic();
                                    if (!mounted) return;
                                    setState(() {});
                                  },
                                )
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting (Classic)...')));
                                final ok = await printer.connectClassic(d);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Connected' : 'Failed')));
                                if (ok) Navigator.of(context).pop(true);
                              },
                              child: const Text('Connect'),
                            ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import '../../core/constants/timing_config.dart';
import '../../core/localization/localization_extensions.dart';
import 'pos_printer_provider.dart';
import 'pos_printer_service.dart'
    if (dart.library.html) 'pos_printer_service_web.dart';
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

  String _connectResultText(AppLocalizations l10n, bool ok) {
    return ok ? l10n.printerConnected : l10n.printerConnectionFailed;
  }

  Future<void> _showDiagnostics() async {
    final svc = ref.read(posPrinterServiceProvider);
    final statuses = await svc.permissionStatuses();
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (!mounted) return;
    final l10n = context.l10n;
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
              Text(l10n.printerDiagnosticsTitle, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(l10n.printerDiagnosticsAdapter(adapterState.name)),
              Text(l10n.printerDiagnosticsScan(statuses['scan'].toString())),
              Text(l10n.printerDiagnosticsConnect(statuses['connect'].toString())),
              Text(l10n.printerDiagnosticsLocation(statuses['location'].toString())),
              const Divider(height: 24),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: l10n.printerDeviceIdLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final id = idController.text.trim();
                      if (id.isEmpty) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(l10n.printerConnectingById)));
                      final ok = await svc.connectById(id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(_connectResultText(l10n, ok))));
                      if (ok) Navigator.of(context).pop(true);
                    },
                    child: Text(l10n.printerConnectById),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: '')); // no-op placeholder
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.commonClose),
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
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.printerConnecting)));
    final ok = await svc.connect(r.device);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.printerConnected)));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.printerConnectionFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final printer = ref.watch(posPrinterServiceProvider);
    final lastId = printer.lastPrinterId;
  final classicDevices = printer.classicBonded; // ClassicBondedDevice list
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.printerSelectTitle),
        actions: [
          IconButton(
            tooltip: l10n.printerDiagnosticsTitle,
            icon: const Icon(Icons.info_outline),
            onPressed: _showDiagnostics,
          ),
          if (printer.selectedDevice != null)
            IconButton(
              tooltip: l10n.printerForgetSavedTooltip,
              icon: const Icon(Icons.link_off),
              onPressed: () async {
                await printer.forgetPrinter();
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.printerForgotSaved)));
                }
              },
            ),
          IconButton(
            tooltip: l10n.printerRescanTooltip,
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
                    child: Text(l10n.commonRetry),
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
                    Expanded(
                      child: Text(l10n.printerLastSavedNotAdvertising(lastId)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(l10n.printerReconnecting)));
                        final ok = await ref.read(posPrinterServiceProvider).connectLastSaved();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? l10n.printerReconnected : l10n.printerReconnectFailed)),
                        );
                        if (ok) Navigator.of(context).pop(true);
                      },
                      child: Text(l10n.printerReconnect),
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
                  Expanded(
                    child: Text(
                      l10n.printerConnectedTo(
                        printer.selectedDevice!.platformName.isNotEmpty
                            ? printer.selectedDevice!.platformName
                            : printer.selectedDevice!.remoteId.str,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final res = await printer.testPrint();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res == PrintResult.success
                                ? l10n.printerTestSent
                                : l10n.printerTestFailed(res.toString()),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: Text(l10n.printerTestPrint),
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
                      Text(l10n.printerBleDevices, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_scanning)
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      if (!_scanning)
                        IconButton(
                          tooltip: l10n.printerRescanBleTooltip,
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _startScan,
                        ),
                    ],
                  ),
                ),
                if (_results.isEmpty && !_scanning)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(l10n.printerNoBleDevices),
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
                      title: Text(name.isEmpty ? l10n.printerUnknownName : name),
                      subtitle: Text(r.device.remoteId.str),
                      trailing: connected
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _connect(r),
                              child: Text(l10n.printerConnect),
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
                      Text(l10n.printerClassicDevices, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.printerRefreshClassicTooltip,
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () async {
                          // Just re-run scan (which triggers classic reload) but much faster
                          await ref.read(posPrinterServiceProvider).startScan(timeout: BluetoothTimeouts.scan);
                        },
                      ),
                    ],
                  ),
                ),
                if (classicDevices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      l10n.printerNoClassicDevices,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  )
                else
                  ...classicDevices.map((d) {
                    final connectedClassic = printer.classicDevice?.mac == d.mac && printer.isClassicConnected;
                    return ListTile(
                      leading: Icon(connectedClassic ? Icons.print : Icons.print_outlined),
                      title: Text(d.name.isEmpty ? l10n.printerUnknownName : d.name),
                      subtitle: Text(
                        connectedClassic ? l10n.printerClassicMacConnected(d.mac) : d.mac,
                      ),
                      trailing: connectedClassic
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print_outlined),
                                  tooltip: l10n.printerTestPrint,
                                  onPressed: () async {
                                    final res = await printer.testPrint();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res == PrintResult.success
                                              ? l10n.printerTestSent
                                              : l10n.printerTestFailed(res.toString()),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.link_off),
                                  tooltip: l10n.printerDisconnect,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.printerConnectingClassic)),
                                );
                                final ok = await printer.connectClassic(d);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(_connectResultText(l10n, ok))));
                                if (ok) Navigator.of(context).pop(true);
                              },
                              child: Text(l10n.printerConnect),
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

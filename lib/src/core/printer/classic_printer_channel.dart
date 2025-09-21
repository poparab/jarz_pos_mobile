import 'dart:async';
import 'package:flutter/services.dart';

/// Lightweight wrapper around the Android classic printer method channel.
class ClassicPrinterChannel {
  ClassicPrinterChannel._();
  static final ClassicPrinterChannel instance = ClassicPrinterChannel._();

  static const _channel = MethodChannel('classic_printer');

  Future<List<ClassicBondedDevice>> getBondedDevices() async {
    final list = await _channel.invokeListMethod<dynamic>('getBondedDevices');
    if (list == null) return [];
    return list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ClassicBondedDevice(name: map['name'] ?? '', mac: map['mac'] ?? '');
    }).toList();
  }

  Future<bool> connect(String mac) async {
    final ok = await _channel.invokeMethod<bool>('connect', {'mac': mac});
    return ok == true;
  }

  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  Future<bool> isConnected() async {
    final ok = await _channel.invokeMethod<bool>('isConnected');
    return ok == true;
  }

  Future<bool> write(Uint8List data) async {
    final ok = await _channel.invokeMethod<bool>('write', {'data': data});
    return ok == true;
  }
}

class ClassicBondedDevice {
  final String name;
  final String mac;
  const ClassicBondedDevice({required this.name, required this.mac});
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import 'pos_printer_service.dart';

final posPrinterServiceProvider = ChangeNotifierProvider<PosPrinterService>((ref) {
  final dio = ref.watch(dioProvider);
  return PosPrinterService(dio: dio);
});

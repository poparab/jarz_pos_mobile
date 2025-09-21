import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pos_printer_service.dart';

final posPrinterServiceProvider = ChangeNotifierProvider<PosPrinterService>((ref) {
  return PosPrinterService();
});

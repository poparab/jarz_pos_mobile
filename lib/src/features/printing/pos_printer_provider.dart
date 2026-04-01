import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import 'pos_printer_service.dart'
    if (dart.library.html) 'pos_printer_service_web.dart';

final posPrinterServiceProvider = ChangeNotifierProvider<PosPrinterService>((ref) {
  final dio = ref.watch(dioProvider);
  return PosPrinterService(dio: dio);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/courier_service.dart';
import '../models/courier_balance.dart';

final courierRepositoryProvider = Provider<CourierRepository>((ref) {
  final service = ref.watch(courierServiceProvider);
  return CourierRepository(service);
});

class CourierRepository {
  final CourierService _service;
  CourierRepository(this._service);

  Future<List<CourierBalance>> getBalances() async {
    final list = await _service.getBalances();
    return list
        .map((e) => CourierBalance.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

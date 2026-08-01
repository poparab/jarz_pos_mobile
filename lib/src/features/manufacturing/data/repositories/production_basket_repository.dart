import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/storage_keys.dart';
import '../models/batch_line.dart';

/// Persists the in-progress production basket.
///
/// Planning a day's production takes real time; losing it to a phone call or an
/// app restart is the kind of small betrayal that stops people using a screen.
/// Stored as JSON rather than via a `TypeAdapter` because this app registers
/// none — every Hive box here holds plain JSON-safe values.
class ProductionBasketRepository {
  static const _key = 'current_basket';

  Box? _box;

  /// Opened lazily rather than in a constructor: Hive initialisation is async
  /// and a notifier that awaited it in its constructor would deadlock its own
  /// first read.
  Future<Box?> _open() async {
    if (_box != null) return _box;
    try {
      _box = Hive.isBoxOpen(HiveBoxes.productionBasket)
          ? Hive.box(HiveBoxes.productionBasket)
          : await Hive.openBox(HiveBoxes.productionBasket);
    } catch (_) {
      // Storage being unavailable must degrade to "basket is not persisted",
      // never to "the board will not open".
      _box = null;
    }
    return _box;
  }

  Future<ProductionBasket?> load() async {
    final box = await _open();
    if (box == null) return null;

    final raw = box.get(_key);
    if (raw is! String || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ProductionBasket.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      // A basket saved by an older build whose shape has since changed is not
      // worth crashing over — drop it and start clean.
      await clear();
      return null;
    }
  }

  Future<void> save(ProductionBasket basket) async {
    final box = await _open();
    if (box == null) return;

    if (basket.lines.isEmpty) {
      await box.delete(_key);
      return;
    }

    try {
      await box.put(_key, jsonEncode(basket.toJson()));
    } catch (_) {
      // A failed cache write must never break the live basket in memory.
    }
  }

  Future<void> clear() async {
    final box = await _open();
    await box?.delete(_key);
  }
}

final productionBasketRepositoryProvider =
    Provider<ProductionBasketRepository>((ref) => ProductionBasketRepository());

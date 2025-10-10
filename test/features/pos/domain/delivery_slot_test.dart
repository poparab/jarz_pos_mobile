import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/pos/domain/models/delivery_slot.dart';

void main() {
  group('DeliverySlot', () {
    test('fromJson creates DeliverySlot from valid JSON', () {
      final json = {
        'date': '2025-05-01',
        'time': '10:00:00',
        'datetime': '2025-05-01 10:00:00',
        'end_datetime': '2025-05-01 11:00:00',
        'label': 'Morning Slot',
        'day_label': 'Thu',
        'time_label': '10 AM - 11 AM',
        'is_default': true,
      };

      final slot = DeliverySlot.fromJson(json);

      expect(slot.date, equals('2025-05-01'));
      expect(slot.time, equals('10:00:00'));
      expect(slot.datetime, equals('2025-05-01 10:00:00'));
      expect(slot.endDatetime, equals('2025-05-01 11:00:00'));
      expect(slot.label, equals('Morning Slot'));
      expect(slot.dayLabel, equals('Thu'));
      expect(slot.timeLabel, equals('10 AM - 11 AM'));
      expect(slot.isDefault, isTrue);
    });

    test('fromJson defaults isDefault to false when not provided', () {
      final json = {
        'date': '2025-05-01',
        'time': '10:00:00',
        'datetime': '2025-05-01 10:00:00',
        'end_datetime': '2025-05-01 11:00:00',
        'label': 'Slot',
        'day_label': 'Thu',
        'time_label': '10 AM',
      };

      final slot = DeliverySlot.fromJson(json);

      expect(slot.isDefault, isFalse);
    });

    test('toJson converts DeliverySlot to JSON correctly', () {
      final slot = DeliverySlot(
        date: '2025-05-02',
        time: '14:00:00',
        datetime: '2025-05-02 14:00:00',
        endDatetime: '2025-05-02 15:00:00',
        label: 'Afternoon Slot',
        dayLabel: 'Fri',
        timeLabel: '2 PM - 3 PM',
        isDefault: false,
      );

      final json = slot.toJson();

      expect(json['date'], equals('2025-05-02'));
      expect(json['time'], equals('14:00:00'));
      expect(json['datetime'], equals('2025-05-02 14:00:00'));
      expect(json['end_datetime'], equals('2025-05-02 15:00:00'));
      expect(json['label'], equals('Afternoon Slot'));
      expect(json['day_label'], equals('Fri'));
      expect(json['time_label'], equals('2 PM - 3 PM'));
      expect(json['is_default'], isFalse);
    });

    test('toString returns formatted string', () {
      final slot = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      expect(slot.toString(), equals('DeliverySlot(label: Morning, datetime: 2025-05-01 10:00:00)'));
    });

    test('equality is based on datetime', () {
      final slot1 = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      final slot2 = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Different Label',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      final slot3 = DeliverySlot(
        date: '2025-05-01',
        time: '11:00:00',
        datetime: '2025-05-01 11:00:00',
        endDatetime: '2025-05-01 12:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '11 AM',
      );

      expect(slot1, equals(slot2)); // Same datetime, different label
      expect(slot1, isNot(equals(slot3))); // Different datetime
    });

    test('hashCode is based on datetime', () {
      final slot1 = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      final slot2 = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Different',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      expect(slot1.hashCode, equals(slot2.hashCode));
    });

    test('identical slots are equal', () {
      final slot = DeliverySlot(
        date: '2025-05-01',
        time: '10:00:00',
        datetime: '2025-05-01 10:00:00',
        endDatetime: '2025-05-01 11:00:00',
        label: 'Morning',
        dayLabel: 'Thu',
        timeLabel: '10 AM',
      );

      expect(slot, equals(slot)); // Same instance
    });
  });
}

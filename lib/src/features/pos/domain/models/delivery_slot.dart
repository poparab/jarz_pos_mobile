/// Represents a delivery time slot
class DeliverySlot {
  final String date;
  final String time;
  final String datetime;
  final String endDatetime;
  final String label;
  final String dayLabel;
  final String timeLabel;
  final bool isDefault;

  /// The slot has already started but not ended. The backend offers it so staff
  /// can still book the window that is running now; it is never the default.
  final bool isCurrent;

  const DeliverySlot({
    required this.date,
    required this.time,
    required this.datetime,
    required this.endDatetime,
    required this.label,
    required this.dayLabel,
    required this.timeLabel,
    this.isDefault = false,
    this.isCurrent = false,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      date: json['date'] as String,
      time: json['time'] as String,
      datetime: json['datetime'] as String,
      endDatetime: json['end_datetime'] as String,
      label: json['label'] as String,
      dayLabel: json['day_label'] as String,
      timeLabel: json['time_label'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'datetime': datetime,
      'end_datetime': endDatetime,
      'label': label,
      'day_label': dayLabel,
      'time_label': timeLabel,
      'is_default': isDefault,
      'is_current': isCurrent,
    };
  }

  /// This slot as an explicit operator pick.
  ///
  /// On a *selected* slot, [isDefault] means "pre-selected by the app": checkout
  /// moves such a slot to the next one once it has started, while a deliberate
  /// pick survives until the slot ends. Tapping the default slot in the picker is
  /// deliberate, so the copy the picker stores clears the flag.
  DeliverySlot asOperatorChoice() => _withDefault(false);

  /// Whether this selected slot was picked by the operator rather than
  /// pre-selected by the app. Checkout sends it as `delivery_slot_explicit`
  /// (1 or 0): the server books a slot that is already running when it was
  /// chosen on purpose, and snaps an aged auto-default to the next slot instead
  /// - even when the app's own stale-slot refresh failed or the device clock is
  /// off.
  bool get isOperatorChoice => !isDefault;

  DeliverySlot _withDefault(bool value) => DeliverySlot(
    date: date,
    time: time,
    datetime: datetime,
    endDatetime: endDatetime,
    label: label,
    dayLabel: dayLabel,
    timeLabel: timeLabel,
    isDefault: value,
    isCurrent: isCurrent,
  );

  /// The slot to pre-select: the one the backend marks default, otherwise the
  /// first slot that has not started. Never the running slot - picking that is
  /// always a deliberate choice. The fallback is marked default too, so a
  /// pre-selection is never mistaken for an operator pick.
  static DeliverySlot? pickDefault(List<DeliverySlot> slots) {
    for (final slot in slots) {
      if (slot.isDefault) return slot;
    }
    for (final slot in slots) {
      if (!slot.isCurrent) return slot._withDefault(true);
    }
    return null;
  }

  @override
  String toString() => 'DeliverySlot(label: $label, datetime: $datetime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliverySlot && other.datetime == datetime;
  }

  @override
  int get hashCode => datetime.hashCode;
}

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

  const DeliverySlot({
    required this.date,
    required this.time,
    required this.datetime,
    required this.endDatetime,
    required this.label,
    required this.dayLabel,
    required this.timeLabel,
    this.isDefault = false,
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
    };
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

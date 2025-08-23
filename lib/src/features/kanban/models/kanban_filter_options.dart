/// A model representing a filter option
class FilterOption {
  final String value;
  final String label;

  FilterOption({required this.value, required this.label});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }
}

/// A model representing kanban filter options
class KanbanFilterOptions {
  final List<FilterOption> customers;
  final List<FilterOption> states;

  KanbanFilterOptions({required this.customers, required this.states});
}

class CourierOption {
  final String partyType; // Employee | Supplier
  final String party;     // Employee.name or Supplier.name
  final String displayName;

  CourierOption({
    required this.partyType,
    required this.party,
    required this.displayName,
  });

  factory CourierOption.fromJson(Map<String, dynamic> json) {
    return CourierOption(
      partyType: (json['party_type'] ?? '').toString(),
      party: (json['party'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['name'] ?? json['party'] ?? '').toString(),
    );
  }

  Map<String, String> toMap() => {
        'party_type': partyType,
        'party': party,
        'display_name': displayName,
      };
}

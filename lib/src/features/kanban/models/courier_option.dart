class CourierOption {
  final String partyType; // Employee | Supplier
  final String party;     // Employee.name or Supplier.name
  final String displayName;
  final String? deliveryPartner; // Delivery Partner name if courier belongs to one

  bool get isPartnerCourier => deliveryPartner != null && deliveryPartner!.isNotEmpty;

  CourierOption({
    required this.partyType,
    required this.party,
    required this.displayName,
    this.deliveryPartner,
  });

  factory CourierOption.fromJson(Map<String, dynamic> json) {
    return CourierOption(
      partyType: (json['party_type'] ?? '').toString(),
      party: (json['party'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['name'] ?? json['party'] ?? '').toString(),
      deliveryPartner: (json['delivery_partner'] ?? '').toString().isEmpty
          ? null
          : json['delivery_partner'].toString(),
    );
  }

  Map<String, String> toMap() => {
        'party_type': partyType,
        'party': party,
        'display_name': displayName,
        if (deliveryPartner != null) 'delivery_partner': deliveryPartner!,
      };
}

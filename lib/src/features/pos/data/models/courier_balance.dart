class CourierBalance {
  final String courier;
  final String courierName;
  final double balance;
  final List<CourierBalanceDetail> details;
  final String partyType;
  final String party;

  CourierBalance({
    required this.courier,
    required this.courierName,
    required this.balance,
    required this.details,
  required this.partyType,
  required this.party,
  });

  factory CourierBalance.fromMap(Map<String, dynamic> map) {
    return CourierBalance(
      courier: (map['courier'] ?? '') as String,
      courierName: (map['courier_name'] ?? map['courierName'] ?? '') as String,
      balance: _toDouble(map['balance']),
      details: ((map['details'] as List?) ?? const [])
          .map((e) => CourierBalanceDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
  partyType: (map['party_type'] ?? '') as String,
  party: (map['party'] ?? '') as String,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class CourierBalanceDetail {
  final String invoice;
  final String city;
  final double amount;
  final double shipping;

  CourierBalanceDetail({
    required this.invoice,
    required this.city,
    required this.amount,
    required this.shipping,
  });

  factory CourierBalanceDetail.fromMap(Map<String, dynamic> map) {
    return CourierBalanceDetail(
      invoice: (map['invoice'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      amount: CourierBalance._toDouble(map['amount']),
      shipping: CourierBalance._toDouble(map['shipping']),
    );
  }
}

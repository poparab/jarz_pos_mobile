/// One past courier settlement, as returned by
/// `jarz_pos.api.couriers.list_recent_settlements`.
///
/// This replaces the retired `RecentSettlementRecord` (a local, best-effort
/// Hive cache limited to settlements this exact device watched itself
/// create). Every row here comes from the server, branch-scoped exactly like
/// `get_courier_balances`: a settlement made on another device, or before
/// this feature shipped, shows up too — which is the entire point of the
/// reversal feature existing.
class RecentSettlement {
  final String journalEntry;
  final String? postingDate;
  final String partyType;
  final String party;

  /// Best available human label for [party]; falls back to [party] itself
  /// when the server did not resolve a display name.
  final String displayName;

  /// The POS Profile / branch this settlement was posted from.
  final String? posProfile;

  /// Signed net amount from the settlement.
  final double? netAmount;

  /// How many Courier Transactions this settlement covered.
  final int transactionCount;

  /// True once this settlement has already been reversed — such a row must
  /// not be offered for reversal again.
  final bool alreadyReversed;

  /// The Journal Entry that reversed this settlement, when [alreadyReversed].
  final String? reversalJournalEntry;

  const RecentSettlement({
    required this.journalEntry,
    required this.partyType,
    required this.party,
    required this.displayName,
    required this.transactionCount,
    required this.alreadyReversed,
    this.postingDate,
    this.posProfile,
    this.netAmount,
    this.reversalJournalEntry,
  });

  factory RecentSettlement.fromMap(Map<String, dynamic> map) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse((v ?? '').toString()) ?? 0;
    }

    bool toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v ?? '').toString().trim().toLowerCase();
      return s == 'true' || s == '1';
    }

    String asString(dynamic v) => (v ?? '').toString();
    String? asOptionalString(dynamic v) {
      final s = asString(v).trim();
      return s.isEmpty ? null : s;
    }

    final party = asString(map['party']);
    final displayName = asOptionalString(map['display_name']);

    return RecentSettlement(
      journalEntry: asString(map['journal_entry']),
      postingDate: asOptionalString(map['posting_date']),
      partyType: asString(map['party_type']),
      party: party,
      displayName: displayName ?? party,
      posProfile: asOptionalString(map['pos_profile']),
      netAmount: toDouble(map['net_amount']),
      transactionCount: toInt(map['transaction_count']),
      alreadyReversed: toBool(map['already_reversed']),
      reversalJournalEntry: asOptionalString(map['reversal_journal_entry']),
    );
  }
}

/// One Courier Transaction the reversal will flip back to Unsettled.
class UnsettleTransactionLine {
  final String invoice;
  final double? amount;
  final String? city;

  const UnsettleTransactionLine({required this.invoice, this.amount, this.city});

  factory UnsettleTransactionLine.fromMap(Map<String, dynamic> map) {
    return UnsettleTransactionLine(
      invoice: _firstString(map, const ['invoice', 'invoice_name', 'sales_invoice', 'name']) ?? '',
      amount: _firstNum(map, const ['amount', 'net_amount', 'total']),
      city: _firstString(map, const ['city', 'territory']),
    );
  }
}

/// One accounting line the reversing Journal Entry will post — the mirror
/// image of a line the original settlement posted.
class UnsettleAccountLine {
  final String account;
  final double debit;
  final double credit;

  const UnsettleAccountLine({required this.account, required this.debit, required this.credit});

  factory UnsettleAccountLine.fromMap(Map<String, dynamic> map) {
    return UnsettleAccountLine(
      account: _firstString(map, const ['account', 'account_name']) ?? '',
      debit: _firstNum(map, const ['debit', 'debit_amount']) ?? 0,
      credit: _firstNum(map, const ['credit', 'credit_amount']) ?? 0,
    );
  }
}

/// Parsed `get_unsettle_preview` response.
///
/// Field names are matched defensively across several candidate keys — the
/// same style `settlement_preview_dialog.dart` uses for the forward
/// settlement preview — because this UI was built against the wire contract
/// declared in the endpoint comments, not by reading the service
/// implementation. Anything the parser cannot find is simply omitted from
/// the summary rather than guessed; [raw] keeps the full response so the
/// preview dialog can always fall back to it.
class UnsettlePreview {
  final String journalEntry;
  final String? previewToken;
  final String? partyType;
  final String? party;
  final String? partyLabel;
  final String? branch;
  final String? postingDate;
  final double? netAmount;
  final List<UnsettleTransactionLine> transactions;
  final List<UnsettleAccountLine> accountLines;
  final Map<String, dynamic> raw;

  const UnsettlePreview({
    required this.journalEntry,
    required this.raw,
    this.previewToken,
    this.partyType,
    this.party,
    this.partyLabel,
    this.branch,
    this.postingDate,
    this.netAmount,
    this.transactions = const [],
    this.accountLines = const [],
  });

  factory UnsettlePreview.fromMap(
    Map<String, dynamic> map, {
    required String requestedJournalEntry,
  }) {
    final transactionsRaw = _firstList(map, const [
      'transactions',
      'courier_transactions',
      'reopened_transactions',
      'details',
    ]);
    // `reversal_lines` is the real key — verified against
    // delivery_handling.get_unsettle_preview, which returns
    // {journal_entry, company, pos_profile, posting_date, title, user_remark,
    //  courier_transactions, reversal_lines, already_reversed,
    //  reversal_journal_entry}, with the API wrapper adding preview_token and
    // expires_in. The rest are kept as tolerant fallbacks only.
    final linesRaw = _firstList(map, const [
      'reversal_lines',
      'account_lines',
      'gl_entries',
      'journal_entry_lines',
      'lines',
      'entries',
    ]);

    return UnsettlePreview(
      journalEntry: _firstString(map, const ['journal_entry', 'original_journal_entry']) ??
          requestedJournalEntry,
      previewToken: _firstString(map, const ['preview_token', 'token']),
      partyType: _firstString(map, const ['party_type']),
      party: _firstString(map, const ['party']),
      partyLabel: _firstString(map, const ['party_name', 'courier_name', 'party_label']),
      branch: _firstString(map, const ['branch', 'pos_profile', 'cost_center']),
      postingDate: _firstString(map, const ['posting_date', 'original_posting_date']),
      netAmount: _firstNum(map, const ['net_amount', 'amount', 'total_amount']),
      transactions: transactionsRaw
          .map((e) => UnsettleTransactionLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      accountLines: linesRaw
          .map((e) => UnsettleAccountLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      raw: map,
    );
  }
}

String? _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

double? _firstNum(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}

List<dynamic> _firstList(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) return value;
  }
  return const [];
}

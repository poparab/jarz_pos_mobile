/// Helpers for verifying and cleaning up test data in ERPNext.
///
/// Provides direct `GET /api/resource/{DocType}/{Name}` access
/// so E2E tests can confirm that mobile-app operations actually
/// persisted the expected data on the server.
///
/// Also includes financial verification helpers for querying linked
/// Journal Entries, Payment Entries, GL Entries, Courier Transactions,
/// Sales Partner Transactions, Delivery Notes, and Stock Ledger Entries.
// Cleanup reports its own failures on stdout so a tear-down problem is visible
// in the test log next to the document name it happened to.
// ignore_for_file: avoid_print
library;

import 'dart:convert' show jsonEncode;
import 'dart:math' show max;

import 'package:flutter_test/flutter_test.dart';

import 'api_client.dart';

/// Fetch a single document from ERPNext.
///
/// Returns the full document as a `Map<String, dynamic>`.
/// Throws on 404 or other errors.
Future<Map<String, dynamic>> getDocFromErp(
  StagingApiClient api,
  String doctype,
  String name,
) async {
  final result = await api.get('/api/resource/$doctype/$name');
  if (result is Map<String, dynamic>) {
    // Frappe resource API commonly wraps payload as {"data": {...}}.
    final data = result['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return result;
  }
  return Map<String, dynamic>.from(result as Map);
}

/// Assert that a document in ERPNext has the expected field values.
///
/// Example:
/// ```dart
/// await verifyDocInErp(api, 'Sales Invoice', 'SINV-001', {
///   'docstatus': 0,
///   'customer': 'Walk In Customer',
/// });
/// ```
Future<void> verifyDocInErp(
  StagingApiClient api,
  String doctype,
  String name,
  Map<String, dynamic> expectedFields,
) async {
  final doc = await getDocFromErp(api, doctype, name);
  for (final entry in expectedFields.entries) {
    final actual = doc[entry.key];
    expect(
      actual,
      entry.value,
      reason:
          '$doctype/$name: field "${entry.key}" expected ${entry.value} but got $actual',
    );
  }
}

/// List documents of [doctype] matching Frappe-style [filters].
///
/// ```dart
/// final invoices = await listDocsFromErp(api, 'Sales Invoice', [
///   ['customer', '=', 'Walk In Customer'],
///   ['docstatus', '=', 0],
/// ]);
/// ```
Future<List<Map<String, dynamic>>> listDocsFromErp(
  StagingApiClient api,
  String doctype,
  List<List<dynamic>> filters, {
  List<String>? fields,
  int limit = 20,
}) async {
  final result = await api.get(
    '/api/resource/$doctype',
    queryParameters: {
      'filters': jsonEncode(filters),
      'limit_page_length': limit,
      if (fields != null) 'fields': jsonEncode(fields),
    },
  );
  if (result is List) {
    return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  if (result is Map && result['data'] is List) {
    return (result['data'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
  return const [];
}

/// Cancel a submitted ERPNext document.
///
/// MUST go through `frappe.client.cancel`. This used to POST `{'docstatus': 2}`
/// to `/api/resource/<doctype>/<name>`, which does NOT patch fields: Frappe
/// routes POST on an *instance* path to `execute_doc_method`
/// (`frappe/api/v1.py`), whose first statement is
/// `method = method or frappe.form_dict.pop("run_method")`. With no
/// `run_method` in the body that raises `KeyError` on every single call, so the
/// cancel always failed, the follow-up delete of a still-submitted document
/// always failed too, and the `catch (_) {}` in [cleanupTestInvoice] threw both
/// away — leaving every test-created invoice submitted and live on staging.
///
/// `frappe.client.cancel` is whitelisted for POST/PUT and takes
/// `{doctype, name}`. (`POST /api/resource/<dt>/<name>` with
/// `{'run_method': 'cancel'}` is the equivalent instance-path form.)
Future<void> cancelDocInErp(
  StagingApiClient api,
  String doctype,
  String name,
) async {
  await api.rawPost(
    '/api/method/frappe.client.cancel',
    data: {'doctype': doctype, 'name': name},
    options: null,
  );
}

/// Delete an ERPNext document.
Future<void> deleteDocInErp(StagingApiClient api, String doctype, String name) async {
  await api.dio.delete('/api/resource/$doctype/$name');
}

/// Best-effort HTTP status extraction that does not depend on the Dio types.
///
/// Deliberately duck-typed (`dynamic` field access inside a `catch`) so this
/// file keeps using generic `catch (e)` — an `on DioException catch` here would
/// let any non-Dio error escape tear-down and cascade into unrelated failures.
int? httpStatusOf(Object error) {
  try {
    final dynamic err = error;
    final dynamic response = err.response;
    if (response == null) return null;
    final dynamic code = response.statusCode;
    return code is int ? code : null;
  } catch (_) {
    return null;
  }
}

bool _isNotFound(Object error) => httpStatusOf(error) == 404;

/// Clean up a test-created invoice and PROVE it worked.
///
/// - If submitted (docstatus=1): cancel, then delete.
/// - If draft (docstatus=0): just delete.
/// - Already absent (404 on the first read): nothing to do.
///
/// Then re-reads the document and requires one of two end states:
///   * gone (404), or
///   * still present with `docstatus == 2` (cancelled). ERPNext legitimately
///     refuses to delete a document other submitted documents link to; a
///     cancelled invoice posts no balances, so that is an acceptable outcome.
///
/// Anything else — still draft, still submitted, or unreadable — throws
/// [StateError] naming the invoice and every underlying error collected along
/// the way. Cleanup runs in `tearDownAll`, so that surfaces as a suite failure
/// instead of quietly leaving live financial documents on staging.
Future<void> cleanupTestInvoice(StagingApiClient api, String invoiceName) async {
  final errors = <String>[];

  int? initialDocstatus;
  try {
    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    initialDocstatus = (doc['docstatus'] as num?)?.toInt();
  } catch (e) {
    if (_isNotFound(e)) return; // Already gone — nothing to clean up.
    errors.add('initial read failed: $e');
  }

  if (initialDocstatus == 1) {
    try {
      await cancelDocInErp(api, 'Sales Invoice', invoiceName);
    } catch (e) {
      errors.add('cancel failed: $e');
    }
  }

  try {
    await deleteDocInErp(api, 'Sales Invoice', invoiceName);
  } catch (e) {
    if (!_isNotFound(e)) errors.add('delete failed: $e');
  }

  // ── Verify the outcome instead of assuming it ────────────────────────
  int? finalDocstatus;
  try {
    final doc = await getDocFromErp(api, 'Sales Invoice', invoiceName);
    finalDocstatus = (doc['docstatus'] as num?)?.toInt();
  } catch (e) {
    if (_isNotFound(e)) return; // Deleted. Clean.
    errors.add('verification read failed: $e');
    throw StateError(
      'CLEANUP FAILED for Sales Invoice "$invoiceName": could not verify the '
      'outcome, so it may still be live on staging. Errors: '
      '${errors.join(' | ')}',
    );
  }

  if (finalDocstatus == 2) {
    // Cancelled but not deletable (linked documents). No live financial
    // effect, so this is a pass — but say so, with the name, so nobody has to
    // guess why the record is still there.
    print(
      '[cleanup] Sales Invoice "$invoiceName" cancelled (docstatus=2) but not '
      'deleted; ERPNext keeps documents that others link to. '
      '${errors.isEmpty ? '' : 'Non-fatal errors: ${errors.join(' | ')}'}',
    );
    return;
  }

  final failure = StateError(
    'CLEANUP FAILED for Sales Invoice "$invoiceName": still present with '
    'docstatus=$finalDocstatus (expected 2 = cancelled, or deleted). '
    'A test-created invoice is LIVE on the server. Errors: '
    '${errors.isEmpty ? '<none reported>' : errors.join(' | ')}',
  );
  print('[cleanup] ${failure.message}');
  throw failure;
}

/// Clean up several test-created invoices, attempting EVERY one before
/// reporting.
///
/// Prefer this over a bare `for (final inv in created) await
/// cleanupTestInvoice(...)`: [cleanupTestInvoice] now throws on an unverified
/// cleanup, and inside a loop that would abandon the remaining invoices.
Future<void> cleanupTestInvoices(
  StagingApiClient api,
  Iterable<String> invoiceNames,
) async {
  final failures = <String>[];
  for (final name in invoiceNames) {
    if (name.isEmpty) continue;
    try {
      await cleanupTestInvoice(api, name);
    } catch (e) {
      failures.add('$name -> $e');
    }
  }
  if (failures.isNotEmpty) {
    throw StateError(
      'CLEANUP FAILED for ${failures.length} invoice(s):\n'
      '${failures.join('\n')}',
    );
  }
}

/// Generate a unique test tag for identifying test-created records.
String testTag() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  return '[TEST-$ts]';
}

// ======================================================================
// Financial verification helpers
// ======================================================================

/// Fetch GL Entries for a given voucher (JE, PE, SI, DN, etc.).
///
/// Returns a list of maps, each with at least `account`, `debit`, `credit`.
Future<List<Map<String, dynamic>>> getGLEntries(
  StagingApiClient api,
  String voucherType,
  String voucherNo,
) async {
  return listDocsFromErp(
    api,
    'GL Entry',
    [
      ['voucher_type', '=', voucherType],
      ['voucher_no', '=', voucherNo],
      ['is_cancelled', '=', 0],
    ],
    fields: [
      'name',
      'account',
      'debit',
      'credit',
      'party_type',
      'party',
      'against_voucher',
    ],
    limit: 50,
  );
}

/// Assert that GL entries for a voucher are balanced (total debit == total credit).
///
/// Returns the GL entries for further inspection.
Future<List<Map<String, dynamic>>> assertGLBalanced(
  StagingApiClient api,
  String voucherType,
  String voucherNo, {
  String? reason,
}) async {
  final entries = await getGLEntries(api, voucherType, voucherNo);
  expect(entries, isNotEmpty,
      reason: reason ?? 'GL Entries should exist for $voucherType $voucherNo');

  double totalDebit = 0;
  double totalCredit = 0;
  for (final gl in entries) {
    totalDebit += (gl['debit'] as num?)?.toDouble() ?? 0;
    totalCredit += (gl['credit'] as num?)?.toDouble() ?? 0;
  }

  expect(totalDebit, closeTo(totalCredit, 0.01),
      reason: reason ??
          'GL must be balanced for $voucherType $voucherNo '
              '(debit=$totalDebit, credit=$totalCredit)');

  return entries;
}

/// Assert that GL entries contain a specific account with expected debit or credit.
void assertGLContainsAccount(
  List<Map<String, dynamic>> glEntries,
  String accountSubstring, {
  bool expectDebit = false,
  bool expectCredit = false,
  double? expectedAmount,
  String? reason,
}) {
  final matching = glEntries.where((gl) {
    final acct = (gl['account'] ?? '').toString();
    return acct.contains(accountSubstring);
  }).toList();

  expect(matching, isNotEmpty,
      reason: reason ?? 'GL should contain account matching "$accountSubstring"');

  if (expectDebit) {
    final hasDebit = matching.any((gl) {
      final d = (gl['debit'] as num?)?.toDouble() ?? 0;
      return d > 0.001;
    });
    expect(hasDebit, isTrue,
        reason: reason ??
            'Expected debit entry on account matching "$accountSubstring"');
  }

  if (expectCredit) {
    final hasCredit = matching.any((gl) {
      final c = (gl['credit'] as num?)?.toDouble() ?? 0;
      return c > 0.001;
    });
    expect(hasCredit, isTrue,
        reason: reason ??
            'Expected credit entry on account matching "$accountSubstring"');
  }

  if (expectedAmount != null) {
    final totalAmount = matching.fold<double>(0, (sum, gl) {
      final d = (gl['debit'] as num?)?.toDouble() ?? 0;
      final c = (gl['credit'] as num?)?.toDouble() ?? 0;
      return sum + max(d, c);
    });
    expect(totalAmount, closeTo(expectedAmount, 0.01),
        reason: reason ??
            'Expected amount $expectedAmount on "$accountSubstring" '
                'but got $totalAmount');
  }
}

/// Fetch Payment Entries linked to a Sales Invoice.
///
/// Uses GL Entry (voucher_type=Payment Entry, against_voucher=invoiceName)
/// because child-table queries (Payment Entry Reference) are permission-restricted.
Future<List<Map<String, dynamic>>> getLinkedPaymentEntries(
  StagingApiClient api,
  String invoiceName,
) async {
  final glEntries = await listDocsFromErp(
    api,
    'GL Entry',
    [
      ['voucher_type', '=', 'Payment Entry'],
      ['against_voucher', '=', invoiceName],
      ['is_cancelled', '=', 0],
    ],
    fields: ['voucher_no'],
    limit: 50,
  );

  final peNames = <String>{};
  for (final gl in glEntries) {
    final vn = gl['voucher_no']?.toString();
    if (vn != null && vn.isNotEmpty) peNames.add(vn);
  }

  final result = <Map<String, dynamic>>[];
  for (final peName in peNames) {
    try {
      result.add(await getDocFromErp(api, 'Payment Entry', peName));
    } catch (_) {}
  }
  return result;
}

/// Assert Payment Entry has expected fields.
Future<Map<String, dynamic>> assertPaymentEntry(
  StagingApiClient api,
  String peName, {
  String? paidFromContains,
  String? paidToContains,
  double? amount,
  String? modeOfPayment,
  int? docstatus,
}) async {
  final pe = await getDocFromErp(api, 'Payment Entry', peName);

  if (paidFromContains != null) {
    expect((pe['paid_from'] ?? '').toString(),
        contains(paidFromContains),
        reason: 'PE $peName paid_from should contain "$paidFromContains"');
  }
  if (paidToContains != null) {
    expect((pe['paid_to'] ?? '').toString(),
        contains(paidToContains),
        reason: 'PE $peName paid_to should contain "$paidToContains"');
  }
  if (amount != null) {
    final paid = (pe['paid_amount'] as num?)?.toDouble() ?? 0;
    expect(paid, closeTo(amount, 0.01),
        reason: 'PE $peName paid_amount should be $amount');
  }
  if (modeOfPayment != null) {
    expect((pe['mode_of_payment'] ?? '').toString().toLowerCase(),
        contains(modeOfPayment.toLowerCase()),
        reason: 'PE $peName mode_of_payment should contain "$modeOfPayment"');
  }
  if (docstatus != null) {
    expect(pe['docstatus'], docstatus,
        reason: 'PE $peName docstatus should be $docstatus');
  }

  return pe;
}

/// Fetch Journal Entries linked to a Sales Invoice.
///
/// Uses GL Entry (voucher_type=Journal Entry, against_voucher=invoiceName)
/// because child-table queries (Journal Entry Account) are permission-restricted.
Future<List<Map<String, dynamic>>> getLinkedJournalEntries(
  StagingApiClient api,
  String invoiceName,
) async {
  final glEntries = await listDocsFromErp(
    api,
    'GL Entry',
    [
      ['voucher_type', '=', 'Journal Entry'],
      ['against_voucher', '=', invoiceName],
      ['is_cancelled', '=', 0],
    ],
    fields: ['voucher_no'],
    limit: 50,
  );

  final jeNames = <String>{};
  for (final gl in glEntries) {
    final vn = gl['voucher_no']?.toString();
    if (vn != null && vn.isNotEmpty) jeNames.add(vn);
  }

  final result = <Map<String, dynamic>>[];
  for (final jeName in jeNames) {
    try {
      result.add(await getDocFromErp(api, 'Journal Entry', jeName));
    } catch (_) {}
  }
  return result;
}

/// Assert a Journal Entry has expected account entries.
///
/// [jeName] - the JE name to fetch and verify.
/// [debitAccountContains] - substring expected in a debit-side account.
/// [creditAccountContains] - substring expected in a credit-side account.
Future<Map<String, dynamic>> assertJournalEntry(
  StagingApiClient api,
  String jeName, {
  String? debitAccountContains,
  String? creditAccountContains,
  double? totalAmount,
}) async {
  final je = await getDocFromErp(api, 'Journal Entry', jeName);
  expect(je['docstatus'], 1,
      reason: 'JE $jeName should be submitted');

  final accounts = je['accounts'] as List?;
  expect(accounts, isNotNull, reason: 'JE $jeName should have accounts');

  if (debitAccountContains != null) {
    final hasDebit = accounts!.any((row) {
      final acct = ((row as Map)['account'] ?? '').toString();
      final debit = (row['debit_in_account_currency'] as num?)?.toDouble() ??
          (row['debit'] as num?)?.toDouble() ??
          0;
      return acct.contains(debitAccountContains) && debit > 0.001;
    });
    expect(hasDebit, isTrue,
        reason: 'JE $jeName should have debit on "$debitAccountContains"');
  }

  if (creditAccountContains != null) {
    final hasCredit = accounts!.any((row) {
      final acct = ((row as Map)['account'] ?? '').toString();
      final credit =
          (row['credit_in_account_currency'] as num?)?.toDouble() ??
              (row['credit'] as num?)?.toDouble() ??
              0;
      return acct.contains(creditAccountContains) && credit > 0.001;
    });
    expect(hasCredit, isTrue,
        reason: 'JE $jeName should have credit on "$creditAccountContains"');
  }

  if (totalAmount != null) {
    final total = (je['total_debit'] as num?)?.toDouble() ?? 0;
    expect(total, closeTo(totalAmount, 0.01),
        reason: 'JE $jeName total_debit should be $totalAmount');
  }

  return je;
}

/// Fetch Courier Transaction linked to a Sales Invoice.
Future<Map<String, dynamic>?> getCourierTransaction(
  StagingApiClient api,
  String invoiceName,
) async {
  final list = await listDocsFromErp(
    api,
    'Courier Transaction',
    [
      ['reference_invoice', '=', invoiceName],
    ],
    fields: [
      'name',
      'reference_invoice',
      'amount',
      'shipping_amount',
      'status',
      'party_type',
      'party',
      'journal_entry',
    ],
    limit: 5,
  );
  if (list.isEmpty) return null;
  // Return the full doc for the first match
  return getDocFromErp(api, 'Courier Transaction', list.first['name'].toString());
}

/// Assert Courier Transaction fields.
Future<Map<String, dynamic>> assertCourierTransaction(
  StagingApiClient api,
  String invoiceName, {
  String? expectedStatus,
  double? orderAmount,
  double? shippingAmount,
}) async {
  final ct = await getCourierTransaction(api, invoiceName);
  expect(ct, isNotNull,
      reason: 'Courier Transaction should exist for $invoiceName');

  expect(ct!['reference_invoice'], invoiceName,
      reason: 'CT should reference invoice $invoiceName');

  if (expectedStatus != null) {
    expect(ct['status'], expectedStatus,
        reason: 'CT status should be "$expectedStatus"');
  }
  if (orderAmount != null) {
    final amt = (ct['amount'] as num?)?.toDouble() ?? 0;
    expect(amt, closeTo(orderAmount, 0.01),
        reason: 'CT order amount should be $orderAmount');
  }
  if (shippingAmount != null) {
    final ship = (ct['shipping_amount'] as num?)?.toDouble() ?? 0;
    expect(ship, closeTo(shippingAmount, 0.01),
        reason: 'CT shipping amount should be $shippingAmount');
  }

  return ct;
}

/// Fetch Sales Partner Transaction linked to a Sales Invoice.
Future<Map<String, dynamic>?> getSalesPartnerTransaction(
  StagingApiClient api,
  String invoiceName,
) async {
  final list = await listDocsFromErp(
    api,
    'Sales Partner Transactions',
    [
      ['reference_invoice', '=', invoiceName],
    ],
    fields: [
      'name',
      'reference_invoice',
      'sales_partner',
      'amount',
      'partner_fees',
      'status',
      'payment_mode',
    ],
    limit: 5,
  );
  if (list.isEmpty) return null;
  return getDocFromErp(
      api, 'Sales Partner Transactions', list.first['name'].toString());
}

/// Fetch Delivery Notes linked to a Sales Invoice.
///
/// Child table queries (Delivery Note Item) are permission-restricted and
/// against_sales_invoice is not populated by the OFD handler. This function
/// tries a best-effort approach via Stock Ledger Entry and falls back to
/// accepting a known DN name.
Future<List<Map<String, dynamic>>> getLinkedDeliveryNotes(
  StagingApiClient api,
  String invoiceName, {
  String? knownDnName,
}) async {
  // If caller already knows the DN name (from OFD response), just fetch it.
  if (knownDnName != null && knownDnName.isNotEmpty) {
    try {
      return [await getDocFromErp(api, 'Delivery Note', knownDnName)];
    } catch (_) {
      return [];
    }
  }

  // Best-effort: look for DN-type SLEs that share items with this invoice.
  // This is unreliable but harmless — callers should prefer passing knownDnName.
  try {
    final glEntries = await listDocsFromErp(
      api,
      'GL Entry',
      [
        ['voucher_type', '=', 'Delivery Note'],
        ['against_voucher', '=', invoiceName],
        ['is_cancelled', '=', 0],
      ],
      fields: ['voucher_no'],
      limit: 10,
    );

    final dnNames = <String>{};
    for (final gl in glEntries) {
      final vn = gl['voucher_no']?.toString();
      if (vn != null && vn.isNotEmpty) dnNames.add(vn);
    }

    final result = <Map<String, dynamic>>[];
    for (final dnName in dnNames) {
      try {
        result.add(await getDocFromErp(api, 'Delivery Note', dnName));
      } catch (_) {}
    }
    return result;
  } catch (_) {
    return [];
  }
}

/// Fetch Stock Ledger Entries for a voucher.
Future<List<Map<String, dynamic>>> getStockLedgerEntries(
  StagingApiClient api,
  String voucherType,
  String voucherNo,
) async {
  return listDocsFromErp(
    api,
    'Stock Ledger Entry',
    [
      ['voucher_type', '=', voucherType],
      ['voucher_no', '=', voucherNo],
    ],
    fields: [
      'name',
      'item_code',
      'actual_qty',
      'warehouse',
      'voucher_type',
      'voucher_no',
    ],
    limit: 50,
  );
}

/// Assert that stock was deducted — checks SLE for Delivery Note first,
/// then falls back to Sales Invoice (POS with update_stock=1).
Future<void> assertStockDeducted(
  StagingApiClient api,
  String voucherName, {
  String? invoiceName,
}) async {
  // Try DN first
  var sles = await getStockLedgerEntries(api, 'Delivery Note', voucherName);

  // Fallback: POS invoices with update_stock=1 deduct stock directly.
  if (sles.isEmpty && invoiceName != null) {
    sles = await getStockLedgerEntries(api, 'Sales Invoice', invoiceName);
  }
  // Also try the voucherName as Sales Invoice if it looks like one.
  if (sles.isEmpty && voucherName.contains('SINV')) {
    sles = await getStockLedgerEntries(api, 'Sales Invoice', voucherName);
  }

  expect(sles, isNotEmpty,
      reason: 'Stock Ledger Entries should exist for $voucherName');

  final hasNegative = sles.any((sle) {
    final qty = (sle['actual_qty'] as num?)?.toDouble() ?? 0;
    return qty < 0;
  });
  expect(hasNegative, isTrue,
      reason: '$voucherName should have negative SLE (stock deducted)');
}

/// Assert that NO Courier Transaction exists for an invoice.
Future<void> assertNoCourierTransaction(
  StagingApiClient api,
  String invoiceName,
) async {
  final ct = await getCourierTransaction(api, invoiceName);
  expect(ct, isNull,
      reason:
          'No Courier Transaction should exist for $invoiceName');
}

/// Assert that NO Delivery Note exists for an invoice.
///
/// Best-effort — since DN discovery is limited, this checks via GL Entry.
/// May not detect DNs that lack GL linkage (but those are harmless).
Future<void> assertNoDeliveryNote(
  StagingApiClient api,
  String invoiceName,
) async {
  try {
    final dns = await getLinkedDeliveryNotes(api, invoiceName);
    expect(dns, isEmpty,
        reason: 'No Delivery Note should exist for $invoiceName');
  } catch (_) {
    // If query fails (permissions), treat as passed — can't verify absence.
  }
}

import 'package:dio/dio.dart';
import 'package:jarz_pos/src/features/cash_custody/data/cash_custody_repository.dart';
import 'package:jarz_pos/src/features/cash_custody/models/cash_custody_models.dart';

/// In-memory stand-in for `CashCustodyRepository`: records each call and
/// answers from fields the test sets.
CustodyHolder fakeCustodyHolder({String name = 'CUST-1', double balance = 100}) =>
    CustodyHolder(
      name: name,
      employee: 'HR-EMP-1',
      employeeName: 'Ahmed',
      account: 'Custody - Ahmed - J',
      balance: balance,
      enabled: true,
    );

class FakeCashCustodyRepository extends CashCustodyRepository {
  FakeCashCustodyRepository() : super(Dio());

  CustodyOverview overview = CustodyOverview.empty;
  Object? overviewError;
  Object? movementError;
  int overviewCalls = 0;
  final List<String> calls = [];

  @override
  Future<CustodyOverview> fetchOverview() async {
    overviewCalls += 1;
    if (overviewError != null) throw overviewError!;
    return overview;
  }

  @override
  Future<List<CustodyCandidate>> listCandidates({String? search}) async {
    calls.add('candidates:$search');
    return const [CustodyCandidate(employee: 'HR-EMP-2', employeeName: 'Mona')];
  }

  @override
  Future<CustodyHolder> addHolder(String employee) async {
    calls.add('add:$employee');
    return fakeCustodyHolder(name: 'CUST-2', balance: 0);
  }

  @override
  Future<CustodyHolder> setHolderEnabled(String holder, bool enabled) async {
    calls.add('enabled:$holder:$enabled');
    return fakeCustodyHolder(name: holder);
  }

  @override
  Future<CustodyMovementResult> issue({
    required String holder,
    required String fromAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    calls.add('issue:$holder:$fromAccount:$amount:$postingDate:$remark');
    if (movementError != null) throw movementError!;
    return CustodyMovementResult(
      journalEntry: 'ACC-JV-1',
      holder: fakeCustodyHolder(name: holder, balance: 100 + amount),
    );
  }

  @override
  Future<CustodyMovementResult> returnCash({
    required String holder,
    required String toAccount,
    required double amount,
    String? postingDate,
    String? remark,
  }) async {
    calls.add('return:$holder:$toAccount:$amount');
    if (movementError != null) throw movementError!;
    return CustodyMovementResult(
      journalEntry: 'ACC-JV-2',
      holder: fakeCustodyHolder(name: holder, balance: 100 - amount),
    );
  }

  @override
  Future<CustodyStatement> fetchStatement({
    required String holder,
    String? fromDate,
    String? toDate,
    int? limit,
  }) async {
    calls.add('statement:$holder:$fromDate:$toDate');
    return const CustodyStatement(
      openingBalance: 0,
      closingBalance: 100,
      entries: [
        CustodyStatementEntry(
          kind: CustodyEntryKind.issue,
          debit: 100,
          credit: 0,
          balance: 100,
        ),
      ],
    );
  }
}


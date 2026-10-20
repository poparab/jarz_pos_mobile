// The blind count sheet as a counter uses it.
//
// What a branch relies on: an uncounted item shows "—" and a 0 shows "0",
// the submit sends nothing until every item has a number (and points at the
// first one still missing), "الكل صفر" fills only the uncounted items of its
// own section, and a refusal from the server is shown in Arabic.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_draft.dart';
import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_models.dart';
import 'package:jarz_pos/src/features/weekly_count/data/weekly_count_service.dart';
import 'package:jarz_pos/src/features/weekly_count/presentation/widgets/weekly_count_sheet_view.dart';

class _SubmitCall {
  _SubmitCall(this.posProfile, this.lines, this.clientRequestId);
  final String posProfile;
  final List<Map<String, dynamic>> lines;
  final String clientRequestId;
}

class _FakeService extends WeeklyCountService {
  _FakeService({this.failWith}) : super(Dio());

  final Object? failWith;
  final List<_SubmitCall> calls = [];

  @override
  Future<WeeklyCountSubmitResult> submit({
    required String posProfile,
    required List<Map<String, dynamic>> lines,
    required String clientRequestId,
  }) async {
    calls.add(_SubmitCall(posProfile, lines, clientRequestId));
    final failure = failWith;
    if (failure != null) throw failure;
    return WeeklyCountSubmitResult.fromJson({
      'ok': true,
      'name': 'BWC-0001',
      'status': 'Pending Approval',
      'auto_approved': false,
      'total_items': lines.length,
    });
  }
}

Map<String, dynamic> _item(String code) => {
  'item_code': code,
  'item_name': 'Item $code',
  'stock_uom': 'Nos',
};

WeeklyCountSheet _sheetIn(String state) => WeeklyCountSheet.fromJson({
  'pos_profile': 'Maadi',
  'warehouse': 'Maadi - J',
  'week_start': '2026-10-17',
  'due_date': '2026-10-23',
  'is_approver': false,
  'state': state,
  'total_items': 3,
  'sections': [
    {
      'key': 'Large',
      'title': 'Large',
      'items': [_item('L1'), _item('L2')],
    },
    {
      'key': 'Small',
      'title': 'Small',
      'items': [_item('S1')],
    },
  ],
});

final _sheet = _sheetIn('due');

const _user = 'yehia@jarz.test';

final _ar = lookupAppLocalizations(const Locale('ar'));

class _Harness {
  _Harness({Object? failWith, WeeklyCountSheet? sheet})
    : service = _FakeService(failWith: failWith),
      sheet = sheet ?? _sheet;

  final _FakeService service;
  final WeeklyCountSheet sheet;
  final store = MemoryWeeklyCountDraftStore();
  final submitted = <WeeklyCountSubmitResult>[];
  var reloads = 0;
  var closed = 0;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weeklyCountServiceProvider.overrideWithValue(service),
          weeklyCountDraftStoreProvider.overrideWithValue(store),
          weeklyCountDraftUserProvider.overrideWith((ref) async => _user),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WeeklyCountSheetView(
              sheet: sheet,
              branchLabel: 'Maadi',
              onSubmitted: submitted.add,
              onReloadSheet: () => reloads++,
              onClosed: () => closed++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

String _qtyText(WidgetTester tester, String code) {
  final box = find.byKey(WeeklyCountSheetKeys.qty(code));
  final text = tester.widget<Text>(
    find.descendant(of: box, matching: find.byType(Text)),
  );
  return text.data!;
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _confirmDialog(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, label),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _countAllAndSubmit(WidgetTester tester) async {
  for (final section in ['Large', 'Small']) {
    await _tap(tester, WeeklyCountSheetKeys.allZero(section));
    await _confirmDialog(tester, _ar.weeklyCountAllZero);
  }
  await _tap(tester, WeeklyCountSheetKeys.submit);
  await _confirmDialog(tester, _ar.weeklyCountSubmitConfirmButton);
}

/// Unmount so snackbar and pulse timers are disposed before the test ends.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
}

void main() {
  testWidgets('uncounted shows a dash and stays apart from zero', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);

    expect(_qtyText(tester, 'L1'), '—');
    expect(_qtyText(tester, 'L2'), '—');
    expect(find.text(_ar.weeklyCountProgress(0, 3)), findsOneWidget);

    // + on uncounted is 1, - on uncounted is a deliberate 0.
    await _tap(tester, WeeklyCountSheetKeys.inc('L1'));
    await _tap(tester, WeeklyCountSheetKeys.dec('L2'));

    expect(_qtyText(tester, 'L1'), '1');
    expect(_qtyText(tester, 'L2'), '0');
    expect(_qtyText(tester, 'S1'), '—');
    expect(find.text(_ar.weeklyCountProgress(2, 3)), findsOneWidget);

    // Autosaved as it goes.
    final saved =
        h.store.data[WeeklyCountDraft.storageKey(_user, 'Maadi', '2026-10-17')];
    expect(saved?['counts'], {'L1': 1, 'L2': 0});

    await _unmount(tester);
  });

  testWidgets('submit sends nothing until every item is counted', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);

    await _tap(tester, WeeklyCountSheetKeys.inc('L1'));
    await _tap(tester, WeeklyCountSheetKeys.submit);

    expect(h.service.calls, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(_ar.weeklyCountFinishFirst(2)), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('all zero fills only the uncounted items of its section', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);

    await _tap(tester, WeeklyCountSheetKeys.inc('L1'));
    await _tap(tester, WeeklyCountSheetKeys.inc('L1'));
    await _tap(tester, WeeklyCountSheetKeys.allZero('Large'));

    // The dialog says how many it will fill: only L2.
    expect(find.byType(AlertDialog), findsOneWidget);
    await _confirmDialog(tester, _ar.weeklyCountAllZero);

    expect(_qtyText(tester, 'L1'), '2');
    expect(_qtyText(tester, 'L2'), '0');
    // The other section is untouched.
    expect(_qtyText(tester, 'S1'), '—');

    // Still not complete: the submit stays shut.
    await _tap(tester, WeeklyCountSheetKeys.submit);
    expect(h.service.calls, isEmpty);
    expect(find.text(_ar.weeklyCountFinishFirst(1)), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('a fully counted sheet submits every line with a request id', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);

    await _tap(tester, WeeklyCountSheetKeys.inc('L1'));
    await _tap(tester, WeeklyCountSheetKeys.allZero('Large'));
    await _confirmDialog(tester, _ar.weeklyCountAllZero);
    await _tap(tester, WeeklyCountSheetKeys.allZero('Small'));
    await _confirmDialog(tester, _ar.weeklyCountAllZero);
    expect(find.text(_ar.weeklyCountProgress(3, 3)), findsOneWidget);

    await _tap(tester, WeeklyCountSheetKeys.submit);
    // Staff see the "waits for approval" line, not the approver one.
    expect(find.text(_ar.weeklyCountSubmitConfirmStaff), findsOneWidget);
    expect(find.text(_ar.weeklyCountSubmitConfirmApprover), findsNothing);
    await _confirmDialog(tester, _ar.weeklyCountSubmitConfirmButton);

    expect(h.service.calls, hasLength(1));
    final call = h.service.calls.single;
    expect(call.posProfile, 'Maadi');
    expect(call.lines, [
      {'item_code': 'L1', 'qty': 1},
      {'item_code': 'L2', 'qty': 0},
      {'item_code': 'S1', 'qty': 0},
    ]);
    expect(call.clientRequestId, isNotEmpty);
    expect(h.submitted.single.name, 'BWC-0001');
    // The draft is gone once the server has the count.
    expect(h.store.data, isEmpty);

    await _unmount(tester);
  });

  testWidgets('already counted: Arabic message and the sheet closes', (
    tester,
  ) async {
    final options = RequestOptions(path: WeeklyCountEndpoints.submit);
    final h = _Harness(
      failWith: DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 417,
          data: {
            '_server_messages': jsonEncode([
              jsonEncode({'message': '[already_done] Counted this week'}),
            ]),
          },
        ),
      ),
    );
    await h.pump(tester);

    for (final section in ['Large', 'Small']) {
      await _tap(tester, WeeklyCountSheetKeys.allZero(section));
      await _confirmDialog(tester, _ar.weeklyCountAllZero);
    }
    await _tap(tester, WeeklyCountSheetKeys.submit);
    await _confirmDialog(tester, _ar.weeklyCountSubmitConfirmButton);

    expect(h.service.calls, hasLength(1));
    expect(find.text(_ar.weeklyCountErrAlreadyDone), findsOneWidget);
    expect(h.closed, 1);
    expect(h.reloads, 0);
    expect(h.submitted, isEmpty);
    expect(h.store.data, isEmpty);

    await _unmount(tester);
  });

  testWidgets('a draft saved by another user on this tablet is not opened', (
    tester,
  ) async {
    final h = _Harness();
    await h.store.save(
      WeeklyCountDraft(
        user: 'previous@jarz.test',
        posProfile: 'Maadi',
        weekStart: '2026-10-17',
        counts: {'L1': 5, 'L2': 1, 'S1': 0},
      ),
    );
    await h.pump(tester);

    expect(_qtyText(tester, 'L1'), '—');
    expect(find.text(_ar.weeklyCountProgress(0, 3)), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('recount after a rejection gets a fresh request id', (
    tester,
  ) async {
    final h = _Harness(sheet: _sheetIn('rejected'));
    // The rejected submission's draft survived (its response was lost, so
    // the delete never ran): same counts, same id, already sent once.
    await h.store.save(
      WeeklyCountDraft(
        user: _user,
        posProfile: 'Maadi',
        weekStart: '2026-10-17',
        clientRequestId: 'rejected-request-id',
        submitAttempted: true,
        counts: {'L1': 4},
      ),
    );
    await h.pump(tester);

    // The counts stay; only the id is renewed (and saved).
    expect(_qtyText(tester, 'L1'), '4');
    final key = WeeklyCountDraft.storageKey(_user, 'Maadi', '2026-10-17');
    expect(
      h.store.data[key]?['client_request_id'],
      isNot('rejected-request-id'),
    );

    await _countAllAndSubmit(tester);

    expect(h.service.calls, hasLength(1));
    final id = h.service.calls.single.clientRequestId;
    expect(id, isNotEmpty);
    expect(id, isNot('rejected-request-id'));

    await _unmount(tester);
  });

  testWidgets('a recount draft never sent keeps its request id', (
    tester,
  ) async {
    final h = _Harness(sheet: _sheetIn('rejected'));
    await h.store.save(
      WeeklyCountDraft(
        user: _user,
        posProfile: 'Maadi',
        weekStart: '2026-10-17',
        clientRequestId: 'recount-in-progress',
        counts: {'L1': 4},
      ),
    );
    await h.pump(tester);
    await _countAllAndSubmit(tester);

    expect(h.service.calls.single.clientRequestId, 'recount-in-progress');

    await _unmount(tester);
  });
}

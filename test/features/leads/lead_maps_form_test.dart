import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/leads/data/leads_repository.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead.dart';
import 'package:jarz_pos/src/features/leads/data/models/lead_maps_preview.dart';
import 'package:jarz_pos/src/features/leads/presentation/screens/lead_form_screen.dart';
import 'package:jarz_pos/src/features/leads/presentation/widgets/lead_maps_import_card.dart';
import 'package:jarz_pos/src/features/leads/state/leads_notifier.dart';
import 'package:jarz_pos/src/features/pos/presentation/widgets/customer_search_widget.dart'
    show territoriesProvider;

class _FakeLeadsRepository extends LeadsRepository {
  _FakeLeadsRepository() : super(Dio());

  final List<Map<String, dynamic>> savedPayloads = [];
  final List<String?> savedNames = [];
  var failNextAddress = false;

  @override
  Future<List<LeadCategory>> getLeadCategories() async => const [];

  @override
  Future<List<Lead>> getLeads({String? category, String? status}) async =>
      const [];

  @override
  Future<String> saveLead(Map<String, dynamic> payload, {String? name}) async {
    savedPayloads.add(Map<String, dynamic>.from(payload));
    savedNames.add(name);
    return name ?? 'LEAD-NEW-1';
  }

  @override
  Future<String> setLeadAddress({
    required String name,
    required String kind,
    required LeadAddress address,
  }) async {
    if (failNextAddress) {
      failNextAddress = false;
      throw Exception('address unavailable');
    }
    return 'ADDRESS-1';
  }
}

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());

  @override
  Future<List<String>> getLeadSources() async => const [];

  @override
  Future<B2bPipeline> getPipeline() async =>
      const B2bPipeline(stages: [], columns: {});
}

class _FakeLeadsNotifier extends LeadsNotifier {
  @override
  Future<List<Lead>> build() async => const [];

  @override
  Future<void> refresh() async {}
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required _FakeLeadsRepository repository,
  Lead? existing,
  LeadMapsPreviewResolver? resolver,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        leadsRepositoryProvider.overrideWithValue(repository),
        leadsProvider.overrideWith(_FakeLeadsNotifier.new),
        b2bRepositoryProvider.overrideWithValue(_FakeB2bRepository()),
        territoriesProvider.overrideWith((ref, search) async => const []),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: LeadFormScreen(existing: existing, mapsPreviewResolver: resolver),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

LeadMapsPreview _details(
  String link, {
  required String name,
  required String phone,
  double? latitude,
  double? longitude,
  String? addressLine1,
  String? city,
  String? country,
}) => LeadMapsPreview(
  success: true,
  resolved: latitude != null && longitude != null,
  url: link,
  canonicalUrl: link,
  placeName: name,
  phone: phone,
  latitude: latitude,
  longitude: longitude,
  addressLine1: addressLine1,
  city: city,
  country: country,
);

Future<void> _enterMapsLink(WidgetTester tester, String link) async {
  await tester.enterText(find.byKey(LeadMapsImportCard.inputKey), link);
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

Future<void> _pressSave(WidgetTester tester) async {
  final finder = find.byKey(LeadFormScreen.saveButtonKey);
  await tester.scrollUntilVisible(
    finder,
    400,
    scrollable: find.byType(Scrollable).first,
  );
  final button = tester.widget<FilledButton>(finder);
  expect(button.onPressed, isNotNull);
  button.onPressed!();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('manual typing wins when a Maps response arrives later', (
    tester,
  ) async {
    final repository = _FakeLeadsRepository();
    final response = Completer<LeadMapsPreview>();
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) => response.future,
    );

    await tester.enterText(
      find.byKey(LeadMapsImportCard.inputKey),
      'https://maps.app.goo.gl/slow',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.scrollUntilVisible(
      find.byKey(LeadFormScreen.fieldKey('lead_name')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(LeadFormScreen.fieldKey('lead_name')),
      'Name typed by rep',
    );
    response.complete(
      _details(
        'https://maps.app.goo.gl/slow',
        name: 'Google name',
        phone: '01000000000',
      ),
    );
    await tester.pumpAndSettle();

    await _pressSave(tester);
    final payload = repository.savedPayloads.single;
    expect(payload['lead_name'], 'Name typed by rep');
    expect(payload['phone'], '01000000000');
  });

  testWidgets('replacing link replaces untouched suggestions but keeps edits', (
    tester,
  ) async {
    final repository = _FakeLeadsRepository();
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) async => link.endsWith('/A')
          ? _details(link, name: 'Cafe A', phone: '010-A')
          : _details(link, name: 'Cafe B', phone: '010-B'),
    );

    await _enterMapsLink(tester, 'https://maps.example/A');
    await tester.scrollUntilVisible(
      find.byKey(LeadFormScreen.fieldKey('phone')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(LeadFormScreen.fieldKey('phone')),
      'manual phone',
    );

    await tester.scrollUntilVisible(
      find.byKey(LeadMapsImportCard.inputKey),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(LeadMapsImportCard.inputKey),
      'https://maps.example/B',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await _pressSave(tester);
    final payload = repository.savedPayloads.single;
    expect(payload['lead_name'], 'Cafe B');
    expect(payload['phone'], 'manual phone');
  });

  testWidgets(
    'changing a resolved link clears its stale coordinates immediately',
    (tester) async {
      LeadMapsValue? value;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: LeadMapsImportCard(
                resolver: (link, {keepPolling}) async => link.endsWith('/A')
                    ? _details(
                        link,
                        name: 'A',
                        phone: '',
                        latitude: 30,
                        longitude: 31,
                      )
                    : _details(
                        link,
                        name: 'B',
                        phone: '',
                        latitude: 32,
                        longitude: 33,
                      ),
                onChanged: (next) => value = next,
                previewBuilder: (context, point) =>
                    Text('MAP ${point.latitude},${point.longitude}'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _enterMapsLink(tester, 'https://maps.example/A');
      expect(value!.latitude, 30);

      await tester.enterText(
        find.byKey(LeadMapsImportCard.inputKey),
        'https://maps.example/B',
      );
      await tester.pump();
      expect(value!.latitude, isNull);
      expect(find.text('MAP 30.0,31.0'), findsNothing);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(value!.latitude, 32);
      expect(find.text('MAP 32.0,33.0'), findsOneWidget);
    },
  );

  testWidgets('lookup failure still saves the link without coordinates', (
    tester,
  ) async {
    final repository = _FakeLeadsRepository();
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) async => throw Exception('offline'),
    );
    await _enterMapsLink(tester, 'https://maps.app.goo.gl/offline');
    await tester.enterText(
      find.byKey(LeadFormScreen.fieldKey('lead_name')),
      'Manual Cafe',
    );

    await _pressSave(tester);

    final payload = repository.savedPayloads.single;
    expect(payload['maps_url'], 'https://maps.app.goo.gl/offline');
    expect(payload['latitude'], isNull);
    expect(payload['longitude'], isNull);
  });

  testWidgets('edit save preserves every prefilled flat lead field', (
    tester,
  ) async {
    final repository = _FakeLeadsRepository();
    const existing = Lead(
      name: 'LEAD-1',
      leadName: 'Existing Cafe',
      companyName: 'Existing Company',
      category: 'Legacy Category',
      phone: '022222222',
      mobileNo: '01011111111',
      emailId: 'owner@example.com',
      source: 'Legacy Source',
      territory: 'Legacy Territory',
      mapsUrl: 'https://maps.example/existing',
    );
    await _pumpForm(tester, repository: repository, existing: existing);

    await _pressSave(tester);

    final payload = repository.savedPayloads.single;
    expect(repository.savedNames.single, 'LEAD-1');
    expect(payload['company_name'], 'Existing Company');
    expect(payload['mobile_no'], '01011111111');
    expect(payload['email_id'], 'owner@example.com');
    expect(payload['category'], 'Legacy Category');
    expect(payload['source'], 'Legacy Source');
    expect(payload['territory'], 'Legacy Territory');
  });

  testWidgets('address failure retry updates the created lead', (tester) async {
    final repository = _FakeLeadsRepository()..failNextAddress = true;
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) async => _details(
        link,
        name: 'Retry Cafe',
        phone: '',
        addressLine1: '1 Nile Street',
        city: 'Cairo',
        country: 'Egypt',
      ),
    );
    await _enterMapsLink(tester, 'https://maps.example/retry');

    await _pressSave(tester);
    await _pressSave(tester);

    expect(repository.savedNames, [null, 'LEAD-NEW-1']);
  });

  // ---------------------------------------------------------------------
  // Area suggestion. The area is the leads catalog's MAIN filter, and with no
  // Google Places key the backend infers it from the pin's neighbours. That
  // inference must arrive in the field, must be labelled as an inference, and
  // must be correctable without retyping.
  // ---------------------------------------------------------------------

  LeadMapsPreview estimated({
    String area = 'Zamalek',
    String confidence = 'high',
    List<String> candidates = const ['Zamalek', 'Dokki'],
    String source = 'nearby_leads',
  }) => LeadMapsPreview(
    success: true,
    resolved: true,
    url: 'https://maps.example/pin',
    canonicalUrl: 'https://maps.example/pin',
    placeName: 'Corner Cafe',
    latitude: 30.06,
    longitude: 31.22,
    primaryArea: area,
    primaryAreaConfidence: confidence,
    primaryAreaSource: source,
    areaCandidates: candidates,
  );

  Future<void> revealArea(WidgetTester tester) => tester.scrollUntilVisible(
    find.byKey(LeadFormScreen.fieldKey('primary_area')),
    300,
    scrollable: find.byType(Scrollable).first,
  );

  testWidgets('an inferred area is filled in and flagged as an estimate', (
    tester,
  ) async {
    final repository = _FakeLeadsRepository();
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) async => estimated(),
    );
    await _enterMapsLink(tester, 'https://maps.example/pin');
    await revealArea(tester);

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(LeadFormScreen.fieldKey('primary_area')),
          )
          .controller
          ?.text,
      'Zamalek',
    );
    expect(find.textContaining('estimated from the map pin'), findsOneWidget);

    await _pressSave(tester);
    expect(repository.savedPayloads.single['primary_area'], 'Zamalek');
  });

  testWidgets('a runner-up area is one tap, not a retype', (tester) async {
    final repository = _FakeLeadsRepository();
    await _pumpForm(
      tester,
      repository: repository,
      resolver: (link, {keepPolling}) async => estimated(confidence: 'low'),
    );
    await _enterMapsLink(tester, 'https://maps.example/pin');
    await revealArea(tester);

    // The chosen area is not offered back to itself; the alternative is.
    expect(
      find.byKey(const ValueKey('lead_form_area_candidate_Zamalek')),
      findsNothing,
    );
    final chip = find.byKey(
      const ValueKey('lead_form_area_candidate_Dokki'),
    );
    // ensureVisible, not scrollUntilVisible: the form is one non-lazy
    // Column, so the chip is already in the tree and scrollUntilVisible
    // returns without scrolling it into the viewport.
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    await _pressSave(tester);
    expect(repository.savedPayloads.single['primary_area'], 'Dokki');
  });

  testWidgets('an area Google supplied is not labelled as a guess', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      repository: _FakeLeadsRepository(),
      resolver: (link, {keepPolling}) async =>
          estimated(source: 'google_places', candidates: const []),
    );
    await _enterMapsLink(tester, 'https://maps.example/pin');
    await revealArea(tester);

    expect(find.textContaining('estimated from the map pin'), findsNothing);
  });

  testWidgets('replacing the link drops the estimate it came with', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      repository: _FakeLeadsRepository(),
      resolver: (link, {keepPolling}) async => link.contains('pin')
          ? estimated()
          : LeadMapsPreview(
              success: false,
              resolved: false,
              url: link,
              canonicalUrl: link,
            ),
    );
    await _enterMapsLink(tester, 'https://maps.example/pin');
    await revealArea(tester);
    expect(find.textContaining('estimated from the map pin'), findsOneWidget);

    await _enterMapsLink(tester, 'https://maps.example/other');
    await revealArea(tester);

    expect(find.textContaining('estimated from the map pin'), findsNothing);
    expect(
      find.byKey(const ValueKey('lead_form_area_candidate_Dokki')),
      findsNothing,
    );
  });
}

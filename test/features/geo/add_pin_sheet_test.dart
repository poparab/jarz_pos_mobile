// "Add pin": the paste-a-link form and its sheet, plus the exc_type reader the
// cart uses to recognise an `AddressPinRequired` refusal.
//
// Fakes only — no test may reach a backend or a tile server.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/network/frappe_exc_type.dart';
import 'package:jarz_pos/src/features/geo/data/models/address_pin.dart';
import 'package:jarz_pos/src/features/geo/data/models/maps_link_preview.dart';
import 'package:jarz_pos/src/features/geo/data/models/pin_write_decision.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/address_pin_repository.dart';
import 'package:jarz_pos/src/features/geo/data/repositories/geo_repository.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/add_pin_sheet.dart';
import 'package:jarz_pos/src/features/geo/presentation/widgets/location_link_field.dart';

class _FakeGeoRepository implements GeoRepository {
  @override
  Future<MapsLinkPreview> previewMapsLink(String link) async =>
      const MapsLinkPreview(
        success: true,
        latitude: 30.0444,
        longitude: 31.2357,
        precision: 'pos_link',
        distanceFromBranchM: 1500,
      );
}

class _WriteCall {
  _WriteCall(this.address, this.link, this.latitude, this.longitude, this.source);

  final String address;
  final String? link;
  final double? latitude;
  final double? longitude;
  final String source;
}

class _FakeAddressPinRepository extends AddressPinRepository {
  _FakeAddressPinRepository({this.accepted = true, this.error})
    : super(Dio());

  final bool accepted;
  final Object? error;
  final List<_WriteCall> writes = [];

  @override
  Future<PinWriteDecision> setPin({
    required String address,
    String? link,
    double? latitude,
    double? longitude,
    required String source,
    double? accuracyM,
    String? note,
  }) async {
    writes.add(_WriteCall(address, link, latitude, longitude, source));
    if (error != null) throw error!;
    return PinWriteDecision(success: true, accepted: accepted);
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required _FakeAddressPinRepository pinRepository,
  required Widget child,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        geoRepositoryProvider.overrideWithValue(_FakeGeoRepository()),
        addressPinRepositoryProvider.overrideWithValue(pinRepository),
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
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: 420, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _paste(WidgetTester tester, String link) async {
  await tester.enterText(find.byKey(LocationLinkField.textFieldKey), link);
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump();
  await tester.pump();
}

FilledButton _saveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(AddPinForm.saveKey));

void main() {
  const link = 'https://www.google.com/maps/place/Cairo/@30.0444,31.2357,15z';

  group('AddPinForm', () {
    testWidgets('Save stays disabled until a link has resolved', (tester) async {
      final repo = _FakeAddressPinRepository();
      await _pump(
        tester,
        pinRepository: repo,
        child: AddPinForm(
          addressName: 'CUST-ADDR-1',
          onSaved: () {},
          previewBuilder: (context, point) => const Text('MAP'),
        ),
      );
      expect(_saveButton(tester).onPressed, isNull);

      await _paste(tester, link);
      expect(_saveButton(tester).onPressed, isNotNull);
      expect(repo.writes, isEmpty);
    });

    testWidgets('saves the pasted link as a pos_link pin and reports it', (
      tester,
    ) async {
      final repo = _FakeAddressPinRepository();
      var saved = 0;
      await _pump(
        tester,
        pinRepository: repo,
        child: AddPinForm(
          addressName: 'CUST-ADDR-1',
          onSaved: () => saved++,
          previewBuilder: (context, point) => const Text('MAP'),
        ),
      );
      await _paste(tester, link);

      await tester.tap(find.byKey(AddPinForm.saveKey));
      await tester.pump();
      await tester.pump();

      expect(saved, 1);
      expect(repo.writes, hasLength(1));
      final write = repo.writes.single;
      expect(write.address, 'CUST-ADDR-1');
      expect(write.link, link);
      expect(write.source, 'pos_link');
      expect(find.text('Pin saved.'), findsOneWidget);
    });

    testWidgets('a better existing pin is kept and still counts as saved', (
      tester,
    ) async {
      final repo = _FakeAddressPinRepository(accepted: false);
      var saved = 0;
      await _pump(
        tester,
        pinRepository: repo,
        child: AddPinForm(
          addressName: 'CUST-ADDR-1',
          onSaved: () => saved++,
          previewBuilder: (context, point) => const Text('MAP'),
        ),
      );
      await _paste(tester, link);
      await tester.tap(find.byKey(AddPinForm.saveKey));
      await tester.pump();
      await tester.pump();

      expect(saved, 1);
      expect(find.text('Pin saved.'), findsNothing);
    });

    testWidgets('a failed write shows an error and does not report saved', (
      tester,
    ) async {
      final repo = _FakeAddressPinRepository(error: Exception('no network'));
      var saved = 0;
      await _pump(
        tester,
        pinRepository: repo,
        child: AddPinForm(
          addressName: 'CUST-ADDR-1',
          onSaved: () => saved++,
          previewBuilder: (context, point) => const Text('MAP'),
        ),
      );
      await _paste(tester, link);
      await tester.tap(find.byKey(AddPinForm.saveKey));
      await tester.pump();
      await tester.pump();

      expect(saved, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      // Still usable: the cashier can retry.
      expect(_saveButton(tester).onPressed, isNotNull);
    });
  });

  group('AddPinSheet', () {
    testWidgets('has a title, the Pick on map action and pops true on save', (
      tester,
    ) async {
      final repo = _FakeAddressPinRepository();
      bool? result;
      await _pump(
        tester,
        pinRepository: repo,
        child: Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SingleChildScrollView(
                  child: AddPinSheet(
                    addressName: 'CUST-ADDR-1',
                    previewBuilder: (context, point) => const Text('MAP'),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byKey(AddPinSheet.titleKey), findsOneWidget);
      expect(find.byKey(AddPinForm.pickOnMapKey), findsOneWidget);

      await _paste(tester, link);
      await tester.tap(find.byKey(AddPinForm.saveKey));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(repo.writes.single.source, 'pos_link');
    });
  });

  group('AddressPin.isPinGrade', () {
    test('needs coordinates and a source above the territory centroid', () {
      expect(
        const AddressPin(
          address: 'A',
          latitude: 30.0,
          longitude: 31.0,
          source: 'pos_link',
        ).isPinGrade,
        isTrue,
      );
      expect(
        const AddressPin(
          address: 'A',
          latitude: 30.0,
          longitude: 31.0,
          source: 'territory_centroid',
        ).isPinGrade,
        isFalse,
      );
      expect(const AddressPin(address: 'A').isPinGrade, isFalse);
    });
  });

  group('frappeExcType', () {
    DioException refusal(Object? body) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 417,
        data: body,
      ),
      type: DioExceptionType.badResponse,
    );

    test('reads the exception class name of a structured refusal', () {
      expect(
        frappeExcType(refusal({'exc_type': 'AddressPinRequired'})),
        'AddressPinRequired',
      );
    });

    test('is null for anything else', () {
      expect(frappeExcType(refusal({'exc_type': ' '})), isNull);
      expect(frappeExcType(refusal('plain text')), isNull);
      expect(frappeExcType(refusal(null)), isNull);
      expect(frappeExcType(Exception('x')), isNull);
      expect(frappeExcType(null), isNull);
    });
  });
}

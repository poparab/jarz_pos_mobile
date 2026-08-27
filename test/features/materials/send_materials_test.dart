// Sending a price list on WhatsApp: what the app has to get right.
//
// The failure modes worth pinning are all silent ones — the rep taps send,
// WhatsApp opens, and only the prospect finds out something was wrong:
//
//   * the material list arrives whole. Dio form-encodes a Dart List into
//     repeated keys, which Frappe flattens to the LAST value only, so a
//     five-item pack would silently become one. The repository sends JSON.
//   * `{link}` survives the round trip untouched. The URL does not exist until
//     the share row is inserted, so the app must NOT try to fill it in — a
//     message about a price list that contains no price list is the one
//     outcome there is no recovering from.
//   * `{name}` IS filled in locally, because the rep has to read the greeting
//     they are about to send.
//   * the send sheet opens with something selected. A library where nothing is
//     flagged default would otherwise open with an empty basket and a disabled
//     button, which reads as broken rather than as empty.
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/materials/data/materials_repository.dart';
import 'package:jarz_pos/src/features/materials/data/models/sales_material.dart';
import 'package:jarz_pos/src/features/materials/state/materials_notifier.dart';

/// Records the last request so the test can assert on the wire shape, which is
/// the whole point: the bug this guards against is invisible in the Dart types.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.body);

  final Object body;
  RequestOptions? lastRequest;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastData = options.data;
    return ResponseBody.fromString(
      '{"message": ${_encode(body)}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  static String _encode(Object value) => value.toString();

  @override
  void close({bool force = false}) {}
}

Dio _dio(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('MaterialLibrary.previewFor', () {
    const library = MaterialLibrary(
      messageTemplate: 'Hi {name}\nhere it is:\n{link}\nthanks',
      namePlaceholder: '{name}',
      linkPlaceholder: '{link}',
      nameFallback: 'there',
    );

    test('fills the name so the rep can read what they are sending', () {
      expect(library.previewFor('Ahmed'), contains('Hi Ahmed'));
    });

    test('falls back rather than leaving a hole in the greeting', () {
      expect(library.previewFor(null), contains('Hi there'));
      expect(library.previewFor('   '), contains('Hi there'));
    });

    test('never substitutes the link — the server owns that', () {
      expect(library.previewFor('Ahmed'), contains('{link}'));
    });
  });

  group('SalesMaterial.label', () {
    test('prefers the server-resolved display title', () {
      const material = SalesMaterial(
        name: 'MAT-00001',
        title: 'Price List',
        titleAr: 'arabic',
        displayTitle: 'resolved',
      );
      expect(material.label, 'resolved');
    });

    test('falls back through Arabic, English, then the id', () {
      expect(
        const SalesMaterial(name: 'MAT-1', title: 'en', titleAr: 'ar').label,
        'ar',
      );
      expect(const SalesMaterial(name: 'MAT-1', title: 'en').label, 'en');
      expect(const SalesMaterial(name: 'MAT-1').label, 'MAT-1');
    });
  });

  group('MaterialShareSummary', () {
    test('an unopened link is not "opened"', () {
      expect(const MaterialShareSummary().opened, isFalse);
      expect(const MaterialShareSummary(viewCount: 2).opened, isTrue);
    });

    test('a blank or malformed timestamp is null, never an exception', () {
      expect(const MaterialShareSummary(sentOn: '').sentAt, isNull);
      expect(const MaterialShareSummary(sentOn: 'not a date').sentAt, isNull);
      expect(
        const MaterialShareSummary(sentOn: '2026-08-26 14:20:00').sentAt,
        isNotNull,
      );
    });
  });

  group('MaterialShareSummary engagement', () {
    test('an iOS phone reads as "iPhone", not "Phone · iOS"', () {
      const share = MaterialShareSummary(
        deviceType: 'Phone',
        os: 'iOS',
        browser: 'Safari',
      );
      expect(share.deviceLine, 'iPhone · Safari');
    });

    test('an iOS tablet reads as iPad', () {
      const share = MaterialShareSummary(deviceType: 'Tablet', os: 'iOS');
      expect(share.deviceLine, 'iPad');
    });

    test('anything else keeps the plain pairing', () {
      const share = MaterialShareSummary(
        deviceType: 'Phone',
        os: 'Android',
        browser: 'Chrome',
      );
      expect(share.deviceLine, 'Phone · Android · Chrome');
    });

    test('nothing known is an empty line, never a stray separator', () {
      expect(const MaterialShareSummary().deviceLine, '');
    });

    test('reading time is the shortest honest form', () {
      expect(const MaterialShareSummary(seconds: 0).readingTime, '');
      expect(const MaterialShareSummary(seconds: 45).readingTime, '45s');
      expect(const MaterialShareSummary(seconds: 120).readingTime, '2m');
      expect(const MaterialShareSummary(seconds: 134).readingTime, '2m 14s');
    });

    test('a fitted glance is not "zoomed in"', () {
      expect(const MaterialShareSummary(maxZoom: 1.0).zoomedIn, isFalse);
      expect(const MaterialShareSummary(maxZoom: 1.02).zoomedIn, isFalse);
      expect(const MaterialShareSummary(maxZoom: 2.6).zoomedIn, isTrue);
    });

    test('a share from before tracking existed reports no engagement', () {
      // It must render as "opened", not as "opened, 0s, 0 pages".
      expect(const MaterialShareSummary(viewCount: 3).hasEngagement, isFalse);
      expect(const MaterialShareSummary(viewCount: 3, seconds: 12).hasEngagement,
          isTrue);
      expect(const MaterialShareSummary(downloaded: true).hasEngagement, isTrue);
    });
  });

  group('MaterialsRepository.createShare', () {
    test('sends the material list as JSON, not as repeated form keys', () async {
      final adapter = _RecordingAdapter('{"token": "abc", "url": "u"}');
      final repository = MaterialsRepository(_dio(adapter));

      await repository.createShare(
        referenceName: 'CRM-LEAD-2026-00042',
        materials: const ['MAT-00001', 'MAT-00002', 'MAT-00003'],
        contactName: 'Ahmed',
        contactPhone: '01111034268',
        message: 'Hi Ahmed\n{link}',
      );

      final data = adapter.lastData as Map;
      expect(data['materials'], isA<String>());
      expect(data['materials'], '["MAT-00001","MAT-00002","MAT-00003"]');
      expect(data['reference_doctype'], 'Lead');
      expect(data['contact_phone'], '01111034268');
    });

    test('leaves the link placeholder for the server to fill', () async {
      final adapter = _RecordingAdapter('{"token": "abc"}');
      final repository = MaterialsRepository(_dio(adapter));

      await repository.createShare(
        referenceName: 'CRM-LEAD-2026-00042',
        materials: const ['MAT-00001'],
        message: 'Hi Ahmed\n{link}\nthanks',
      );

      expect((adapter.lastData as Map)['message'], contains('{link}'));
    });

    test('omits blank optional fields instead of sending empty strings', () async {
      final adapter = _RecordingAdapter('{"token": "abc"}');
      final repository = MaterialsRepository(_dio(adapter));

      await repository.createShare(
        referenceName: 'CRM-LEAD-2026-00042',
        materials: const ['MAT-00001'],
        contactName: '   ',
        contactPhone: '',
      );

      final data = adapter.lastData as Map;
      expect(data.containsKey('contact_name'), isFalse);
      expect(data.containsKey('contact_phone'), isFalse);
    });
  });

  group('materialSharesKey', () {
    test('round-trips a doctype and a name through one composite key', () {
      expect(materialSharesKey('Lead', 'CRM-LEAD-2026-00042'),
          'Lead|CRM-LEAD-2026-00042');
      expect(materialSharesKey('Customer', 'CUST-0001'), 'Customer|CUST-0001');
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/src/features/b2b/data/b2b_repository.dart';
import 'package:jarz_pos/src/features/b2b/data/models/b2b_models.dart';
import 'package:jarz_pos/src/features/b2b/state/b2b_pipeline_notifier.dart';

const _samplePayload = {
  'stages': [
    'Lead',
    'Qualify',
    'Sample',
    'Approved',
    'Trial',
    'Check-up',
    'Active',
    'Lost/On-hold',
  ],
  'columns': {
    'Lead': [
      {
        'doctype': 'Lead',
        'name': 'LEAD-001',
        'title': 'Acme Co',
        'stage': 'Lead',
        'owner': 'rep@x.com',
        'lead_score': 42,
        'customer': null,
        'last_activity': 'Called yesterday',
      },
    ],
    'Qualify': [
      {
        'doctype': 'Opportunity',
        'name': 'OPP-002',
        'title': 'Beta LLC',
        'stage': 'Qualify',
        'customer': 'CUST-002',
      },
    ],
  },
};

class _FakeB2bRepository extends B2bRepository {
  _FakeB2bRepository() : super(Dio());

  bool advanceShouldThrow = false;
  final List<String> advanceCalls = [];

  /// Fails the NEXT getPipeline call — used to reproduce the cold-start
  /// failure that used to freeze the board for the whole app session.
  bool pipelineShouldThrow = false;
  int pipelineCalls = 0;

  @override
  Future<B2bPipeline> getPipeline() async {
    pipelineCalls++;
    if (pipelineShouldThrow) throw Exception('pipeline unavailable');
    return B2bPipeline.fromJson(Map<String, dynamic>.from(_samplePayload));
  }

  @override
  Future<B2bCard> advanceStage({
    required String doctype,
    required String name,
    required String stage,
    String? reason,
    String? followUpDate,
  }) async {
    advanceCalls.add('$doctype:$name:$stage:$reason:$followUpDate');
    if (advanceShouldThrow) throw Exception('advance failed');
    return B2bCard(
      doctype: doctype,
      name: name,
      title: name,
      stage: stage,
    );
  }
}

ProviderContainer _container(_FakeB2bRepository repo) {
  final c = ProviderContainer(
    overrides: [b2bRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('refresh recovers a board that failed to load', () {
    test('a first load that fails leaves an error the refresh clears', () async {
      // The reported bug: b2bPipelineProvider is keep-alive, so build() runs
      // once per app process. A cold start that failed — before the session
      // was attached, or a moment offline — stayed failed until the header
      // Refresh was pressed, because nothing ever re-ran build().
      final repo = _FakeB2bRepository()..pipelineShouldThrow = true;
      final container = _container(repo);

      await expectLater(
        container.read(b2bPipelineProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(b2bPipelineProvider).hasError, isTrue);

      repo.pipelineShouldThrow = false;
      await container.read(b2bPipelineProvider.notifier).refresh();

      final state = container.read(b2bPipelineProvider);
      expect(state.hasError, isFalse);
      expect(state.value?.stages, hasLength(8));
    });

    test('keeps the board on screen while revalidating', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      await container.read(b2bPipelineProvider.future);

      final pending = container.read(b2bPipelineProvider.notifier).refresh();

      // Mid-flight: loading, but the columns are still there. A bare
      // AsyncValue.loading() would blank the board on every auto-refresh.
      final midFlight = container.read(b2bPipelineProvider);
      expect(midFlight.isLoading, isTrue);
      expect(midFlight.value?.stages, hasLength(8),
          reason: 'refresh must not drop the board it is revalidating');

      await pending;
      expect(container.read(b2bPipelineProvider).value?.stages, hasLength(8));
    });

    test('a failed revalidation keeps the last good board', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      await container.read(b2bPipelineProvider.future);

      repo.pipelineShouldThrow = true;
      await container.read(b2bPipelineProvider.notifier).refresh();

      final state = container.read(b2bPipelineProvider);
      expect(state.hasError, isFalse,
          reason: 'a dropped connection must not wipe the cards on screen');
      expect(state.value?.stages, hasLength(8));
    });

    test('each refresh actually re-fetches', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      await container.read(b2bPipelineProvider.future);
      expect(repo.pipelineCalls, 1);

      await container.read(b2bPipelineProvider.notifier).refresh();
      await container.read(b2bPipelineProvider.notifier).refresh();
      expect(repo.pipelineCalls, 3);
    });
  });

  group('B2bPipeline.fromJson', () {
    test('parses stages and columns from a mocked payload', () {
      final pipeline =
          B2bPipeline.fromJson(Map<String, dynamic>.from(_samplePayload));

      expect(pipeline.stages, hasLength(8));
      expect(pipeline.stages.first, 'Lead');
      expect(pipeline.stages.last, 'Lost/On-hold');

      final leadCards = pipeline.columns['Lead']!;
      expect(leadCards, hasLength(1));
      final lead = leadCards.first;
      expect(lead.doctype, 'Lead');
      expect(lead.name, 'LEAD-001');
      expect(lead.title, 'Acme Co');
      expect(lead.leadScore, 42);
      expect(lead.customer, isNull);

      final oppCards = pipeline.columns['Qualify']!;
      expect(oppCards.single.doctype, 'Opportunity');
      expect(oppCards.single.customer, 'CUST-002');
    });

    test('empty columns map yields empty stages safely', () {
      final pipeline = B2bPipeline.fromJson({'stages': [], 'columns': {}});
      expect(pipeline.stages, isEmpty);
      expect(pipeline.columns, isEmpty);
    });
  });

  group('B2bPipelineNotifier.advanceStage', () {
    test('optimistically moves card and calls the server', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);

      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await container
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, 'Qualify');

      final updated = container.read(b2bPipelineProvider).requireValue;
      // Card removed from Lead, present in Qualify with updated stage.
      expect(updated.columns['Lead'], isEmpty);
      final moved = updated.columns['Qualify']!
          .firstWhere((c) => c.name == 'LEAD-001');
      expect(moved.stage, 'Qualify');

      expect(repo.advanceCalls.single, 'Lead:LEAD-001:Qualify:null:null');
    });

    test('passes the reason through to the server', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await container
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, 'Lost/On-hold', reason: 'No budget');

      expect(
        repo.advanceCalls.single,
        'Lead:LEAD-001:Lost/On-hold:No budget:null',
      );
    });

    test('passes the follow_up_date through to the server', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await container
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, 'Qualify', followUpDate: '2026-07-13');

      expect(
        repo.advanceCalls.single,
        'Lead:LEAD-001:Qualify:null:2026-07-13',
      );
    });

    test('rolls back the optimistic move when the server throws', () async {
      final repo = _FakeB2bRepository()..advanceShouldThrow = true;
      final container = _container(repo);
      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await expectLater(
        container
            .read(b2bPipelineProvider.notifier)
            .advanceStage(card, 'Qualify'),
        throwsException,
      );

      final reverted = container.read(b2bPipelineProvider).requireValue;
      // Back to the original layout: card in Lead, not in Qualify.
      expect(reverted.columns['Lead']!.single.name, 'LEAD-001');
      expect(
        reverted.columns['Qualify']!.where((c) => c.name == 'LEAD-001'),
        isEmpty,
      );
    });

    test('no-op when target stage equals current stage', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await container
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, 'Lead');

      expect(repo.advanceCalls, isEmpty);
    });
  });
}

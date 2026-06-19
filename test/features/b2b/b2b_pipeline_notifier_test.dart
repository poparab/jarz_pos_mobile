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

  @override
  Future<B2bPipeline> getPipeline() async {
    return B2bPipeline.fromJson(Map<String, dynamic>.from(_samplePayload));
  }

  @override
  Future<B2bCard> advanceStage({
    required String doctype,
    required String name,
    required String stage,
    String? reason,
  }) async {
    advanceCalls.add('$doctype:$name:$stage:$reason');
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

      expect(repo.advanceCalls.single, 'Lead:LEAD-001:Qualify:null');
    });

    test('passes the reason through to the server', () async {
      final repo = _FakeB2bRepository();
      final container = _container(repo);
      final pipeline = await container.read(b2bPipelineProvider.future);
      final card = pipeline.columns['Lead']!.first;

      await container
          .read(b2bPipelineProvider.notifier)
          .advanceStage(card, 'Lost/On-hold', reason: 'No budget');

      expect(repo.advanceCalls.single, 'Lead:LEAD-001:Lost/On-hold:No budget');
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

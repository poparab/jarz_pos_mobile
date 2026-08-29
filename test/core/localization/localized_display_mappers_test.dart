import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/constants/business_constants.dart';
import 'package:jarz_pos/src/core/localization/localized_display_mappers.dart';
import 'package:jarz_pos/src/features/b2b/presentation/widgets/b2b_stage_chip.dart'
    show kB2bStages;
import 'package:jarz_pos/src/features/leads/state/not_suitable_reasons_notifier.dart'
    show kFallbackNotSuitableReasons;

Future<void> _pumpLocalizedApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  await tester.pumpAndSettle();
}

class _MapperProbe extends StatelessWidget {
  const _MapperProbe({required this.status, required this.method, required this.partyType});

  final String? status;
  final String? method;
  final String? partyType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(localizedStatusLabel(context, status)),
        Text(localizedPaymentMethodLabel(context, method)),
        Text(localizedPartyTypeLabel(context, partyType)),
      ],
    );
  }
}

void main() {
  group('localizedDisplayMappers', () {
    testWidgets('should map common raw values to Arabic labels', (tester) async {
      await _pumpLocalizedApp(
        tester,
        const _MapperProbe(status: 'Paid', method: 'Cash', partyType: 'Employee'),
      );

      expect(find.text('مدفوع'), findsOneWidget);
      expect(find.text('نقدي'), findsOneWidget);
      expect(find.text('موظف'), findsOneWidget);
    });

    testWidgets('should fall back to Arabic not-specified label for empty values', (tester) async {
      await _pumpLocalizedApp(
        tester,
        const _MapperProbe(status: '', method: '', partyType: ''),
      );

      expect(find.text('غير محدد'), findsNWidgets(3));
    });

    // "Online" is what the backend reports for a delivery-partner order the
    // partner collected for us. It used to arrive as "Cash" (see
    // jarz_pos/tests/test_kanban_payment_method.py), and once fixed it must not
    // then fall through to the untranslated English default here.
    testWidgets('should map the delivery-partner Online method to Arabic', (tester) async {
      await _pumpLocalizedApp(
        tester,
        const _MapperProbe(status: 'Paid', method: 'Online', partyType: 'Sales Partner'),
      );

      expect(find.text('دفع إلكتروني'), findsOneWidget);
      expect(find.text('Online'), findsNothing);
    });
  });

  _vocabularyTests();
}

// ── Server-driven lookup vocabularies ──────────────────────────────────────
//
// The bug this guards is not a missing ARB key — the two ARB files have been
// in perfect parity throughout. It is a *lookup* whose options reach the screen
// as raw English and get rendered verbatim. So the assertion is deliberately
// "the Arabic render is not the English input": a mapper that loses a case, or
// a call site that stops using one, fails here instead of shipping.

/// Renders one raw value through [mapper] in an Arabic app.
class _VocabProbe extends StatelessWidget {
  const _VocabProbe({required this.raw, required this.mapper});

  final String raw;
  final String Function(BuildContext, String?) mapper;

  @override
  Widget build(BuildContext context) => Text(mapper(context, raw));
}

Future<void> _expectAllTranslated(
  WidgetTester tester,
  String vocabulary,
  List<String> options,
  String Function(BuildContext, String?) mapper,
) async {
  for (final option in options) {
    await _pumpLocalizedApp(tester, _VocabProbe(raw: option, mapper: mapper));
    expect(
      find.text(option),
      findsNothing,
      reason: '$vocabulary option "$option" rendered untranslated in Arabic',
    );
  }
}

void _vocabularyTests() {
  group('lookup vocabularies', () {
    // Sales Invoice.custom_sales_invoice_state — the Kanban board columns.
    // "Recieved" is the real, misspelt option on the live sites.
    testWidgets('kanban columns are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'kanban state', const [
        'Recieved',
        'Received',
        'In Progress',
        'Ready',
        'Out for Delivery',
        'Delivered',
        'Cancelled',
        'Returned',
      ], localizedKanbanState);
    });

    testWidgets('cancellation reasons are Arabic', (tester) async {
      await _expectAllTranslated(
          tester, 'cancel reason', CancelReasons.defaults, localizedCancelReason);
    });

    // Lead.custom_not_suitable_reason. The bundled fallback mirrors the server
    // list, so covering it covers the dropdown a rep actually sees offline.
    testWidgets('lead disqualify reasons are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'not-suitable reason',
          kFallbackNotSuitableReasons, localizedNotSuitableReason);
    });

    testWidgets('lead sources are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'lead source', const [
        'Walk In',
        'Reference',
        'Campaign',
        'Existing Customer',
        'Cold Call',
        'Social Media',
      ], localizedLeadSource);
    });

    testWidgets('B2B pipeline stages are Arabic, long and short', (tester) async {
      await _expectAllTranslated(
          tester, 'B2B stage', kB2bStages, localizedLeadStage);
      await _expectAllTranslated(
          tester, 'B2B stage (short)', kB2bStages, localizedB2bStageShort);
    });

    testWidgets('customer segments are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'customer segment', const [
        'Champion',
        'Loyal',
        'Potential Loyalist',
        'New Customer',
        'At Risk',
        "Can't Lose Them",
        'Lost',
        'One-Time',
        'Unclassified',
      ], localizedCustomerSegment);
    });

    testWidgets('velocity trends are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'velocity trend', const [
        'Accelerating',
        'Stable',
        'Declining',
        'New Item',
        'No Sales',
      ], localizedVelocityTrend);
    });

    testWidgets('visit plan and stop statuses are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'visit status', const [
        'Draft',
        'Planned',
        'In Progress',
        'Completed',
        'Cancelled',
        'Visited',
        'Skipped',
      ], localizedVisitStatus);
    });

    testWidgets('sales material types are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'material type', const [
        'Price List',
        'Product Photos',
        'Catalog',
        'Certificate',
        'Other',
      ], localizedMaterialType);
    });

    testWidgets('label print statuses and movement types are Arabic',
        (tester) async {
      await _expectAllTranslated(tester, 'label print status', const [
        'Requested',
        'Printing',
        'Ready',
        'Received',
        'Cancelled',
      ], localizedLabelPrintStatus);
      await _expectAllTranslated(tester, 'label movement type', const [
        'Consumed',
        'Print Received',
        'Scrapped',
        'Adjustment',
      ], localizedLabelMovementType);
    });

    testWidgets('journey types and outcomes are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'journey type', const [
        'Visit',
        'Call',
        'WhatsApp',
        'Sample Drop',
        'Meeting',
        'Email',
        'Other',
      ], localizedJourneyType);
      await _expectAllTranslated(tester, 'journey outcome', const [
        'Interested',
        'Needs Follow-up',
        'Sample Requested',
        'Order Placed',
        'Not Now',
        'Rejected',
      ], localizedJourneyOutcome);
    });

    // The statuses that had no case at all before this sweep, so they rendered
    // as English inside an otherwise-Arabic chip.
    testWidgets('settlement and lifecycle statuses are Arabic', (tester) async {
      await _expectAllTranslated(tester, 'status', const [
        'Changed',
        'Settled',
        'Unsettled',
        'Accepted',
        'Active',
        'Paused',
        'Ended',
        'Closed',
        'In Progress',
      ], localizedStatusLabel);
    });

    // A Select option added in Desk after this release must still render as
    // itself rather than disappearing — every mapper falls through raw.
    testWidgets('an unknown option falls through to the raw value',
        (tester) async {
      await _pumpLocalizedApp(
        tester,
        const _VocabProbe(raw: 'Brand New Desk Option', mapper: localizedKanbanState),
      );
      expect(find.text('Brand New Desk Option'), findsOneWidget);
    });
  });
}

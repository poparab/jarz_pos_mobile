import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarz_pos/l10n/app_localizations.dart';
import 'package:jarz_pos/src/core/localization/localized_display_mappers.dart';

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
  });
}
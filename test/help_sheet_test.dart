import 'package:Snapdrop/l10n/app_localizations.dart';
import 'package:Snapdrop/widgets/help_sheet.dart';
import 'package:Snapdrop/widgets/qr_help_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Host with a button that opens the help sheet, so the test exercises the real
/// entry point (showHelpSheet) rather than the widget in isolation.
Widget _host({Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showHelpSheet(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('help sheet shows the three how-it-works steps', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l.onboarding_title), findsOneWidget);
    expect(find.text(l.onboarding_step1_title), findsOneWidget);
    expect(find.text(l.onboarding_step2_title), findsOneWidget);
    expect(find.text(l.onboarding_step3_title), findsOneWidget);
  });

  testWidgets('"Where\'s the QR code?" chains into the QR help sheet',
      (tester) async {
    // Regression: the chain used to run on the help sheet's own context, which
    // is defunct once that sheet pops — the QR sheet never opened.
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l.scan_help_link));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSheet), findsNothing);
    expect(find.byType(QrHelpSheet), findsOneWidget);
    expect(find.text(l.qr_help_step1), findsOneWidget);
  });

  testWidgets('renders in French when the device locale is fr', (tester) async {
    await tester.pumpWidget(_host(locale: const Locale('fr')));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final fr = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(fr.onboarding_title, isNot(equals('Send photos straight into Figma')));
    expect(find.text(fr.onboarding_title), findsOneWidget);
    expect(find.text(fr.scan_help_link), findsOneWidget);
  });
}

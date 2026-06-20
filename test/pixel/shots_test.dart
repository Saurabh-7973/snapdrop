import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Snapdrop/l10n/app_localizations.dart';
import 'package:Snapdrop/screen/onboard_screen.dart';
import 'package:Snapdrop/widgets/app_background.dart';
import 'package:Snapdrop/widgets/app_dialog.dart';

// Pixel-capture goldens. Render each pure screen at its mockup frame's logical
// size and dump to qa/app/<name>.png via --update-goldens. Real Inter font is
// loaded so text metrics match. Background is rendered but ignored in diffing.

Future<void> _loadFonts() async {
  final loader = FontLoader('Inter');
  for (final f in [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/Inter-ExtraBold.ttf',
  ]) {
    loader.addFont(
        File(f).readAsBytes().then((b) => ByteData.view(b.buffer)));
  }
  await loader.load();
}

Widget _harness(Widget child) {
  return MediaQuery(
    // Simulate a status-bar top inset so SafeArea pushes content down like the
    // mockup's status-bar row does.
    data: const MediaQueryData(padding: EdgeInsets.only(top: 30)),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
  });

  testWidgets('onboarding', (tester) async {
    tester.view.physicalSize = const Size(1032, 2238); // 344x746 @ DPR3
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(const OnboardScreen()));
    await tester.pump(const Duration(milliseconds: 1200)); // hero anim settle
    await tester.pump();

    await expectLater(
        find.byType(OnboardScreen), matchesGoldenFile('../../qa/app/onboarding.png'));
  });

  // ---- Dialog states (294x624 frames) ----
  Future<void> shootDialog(
    WidgetTester tester,
    String shot,
    Future<void> Function(BuildContext) open,
  ) async {
    tester.view.physicalSize = const Size(882, 1872); // 294x624 @ DPR3
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    late BuildContext ctx;
    await tester.pumpWidget(_harness(
      AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(builder: (c) {
            ctx = c;
            return const SizedBox.expand();
          }),
        ),
      ),
    ));
    // ignore: use_build_context_synchronously
    open(ctx);
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('../../qa/app/$shot.png'));
  }

  testWidgets('dialog_permission', (tester) async {
    await shootDialog(tester, 'dialog_permission', (c) async {
      final l = AppLocalizations.of(c)!;
      showAppDialog(
        context: c,
        icon: Icons.photo_library_outlined,
        title: l.permission_dialog_title,
        body: l.permission_dialog_body,
        primaryLabel: l.permission_dialog_allow,
        secondaryLabel: l.permission_dialog_exit,
      );
    });
  });

  testWidgets('dialog_exit', (tester) async {
    await shootDialog(tester, 'dialog_exit', (c) async {
      final l = AppLocalizations.of(c)!;
      showAppDialog(
        context: c,
        icon: Icons.logout_rounded,
        title: l.exit_dialog_title,
        body: l.exit_dialog_body,
        primaryLabel: l.exit_dialog_cancel,
        secondaryLabel: l.exit_dialog_exit,
      );
    });
  });

  testWidgets('dialog_share', (tester) async {
    await shootDialog(tester, 'dialog_share', (c) async {
      final l = AppLocalizations.of(c)!;
      showAppDialog(
        context: c,
        icon: Icons.share_outlined,
        title: l.share_dialog_title,
        body: l.share_dialog_body,
        primaryLabel: l.share_dialog_share,
        secondaryLabel: l.share_dialog_maybe_later,
      );
    });
  });
}

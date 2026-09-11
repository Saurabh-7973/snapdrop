@Tags(['walk'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidester/guidester.dart';
import 'package:guidester/src/screen_resolver.dart';

import 'package:Snapdrop/screen/home_screen.dart';
import 'package:Snapdrop/screen/onboard_screen.dart';
import 'package:Snapdrop/screen/qr_screen.dart';
import 'package:Snapdrop/screen/send_file_screen.dart';
import 'package:Snapdrop/widgets/dropdown_view.dart';

/// THE WALK — what the resolver actually answers on every screen of a
/// Navigator 1.0 app with no named routes.
///
/// Snapdrop was chosen as host #1 precisely because it is the hard case.
/// Everything verified on hardware so far went through layer 3, the router
/// URI. This app has no `Router` at all, and — established before any of this
/// was wired — **no named routes anywhere**: no `routes:` table, no
/// `onGenerateRoute`, no `pushNamed`. Nine `MaterialPageRoute` pushes, every
/// one of them anonymous.
///
/// That means layer 2 declines even with `Guidester.observer` attached, because
/// an anonymous route carries no `settings.name` to read. **This app is a pure
/// layer 4 sample**, which is the fallback every stranger's app lands in and the
/// one we have almost no data on.
///
/// This test reports rather than asserts a target. The instruction was
/// explicit: see how often the heuristic answers correctly BEFORE papering over
/// it with `setScreen` calls.

/// Pumps one screen under the overlay exactly as the app mounts it — the
/// overlay in `MaterialApp.builder`, the screen as its child — and asks the
/// resolver from the same context the overlay resolves from.
Future<ScreenResolution> walk(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => GuidesterOverlay(child: child!),
      home: screen,
    ),
  );
  await tester.pump();

  final ctx = tester.element(
    find
        .descendant(
          of: find.byType(GuidesterOverlay),
          matching: find.byType(RepaintBoundary),
        )
        .first,
  );
  return ScreenResolver.resolveDetailed(ctx, searchRoot: ctx as Element);
}

void main() {
  final report = <String, ScreenResolution>{};

  setUp(() {
    Guidester.debugReset();
    Guidester.debugLaunchPingEnabled = false;
    Guidester.debugMountWarningEnabled = false;
    ScreenResolver.debugRouteWarningEnabled = false;
    Guidester.init(apiKey: 'walk-key');
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('\n| Screen | Tag | Layer |');
    // ignore: avoid_print
    print('|---|---|---|');
    report.forEach((name, r) {
      // ignore: avoid_print
      print('| $name | ${r.name} | ${r.layer} |');
    });
  });

  testWidgets('OnboardScreen', (tester) async {
    report['OnboardScreen'] = await walk(tester, const OnboardScreen());
  });

  testWidgets('HomeScreen', (tester) async {
    report['HomeScreen'] = await walk(
      tester,
      HomeScreen(socketService: null, isIntentSharing: false),
    );
  });

  testWidgets('QRScreen', (tester) async {
    report['QRScreen'] = await walk(
      tester,
      const QRScreen(isIntentSharing: false),
    );
  });

  testWidgets('SendFile — the class that does not end in Screen/Page/View',
      (tester) async {
    report['SendFile'] = await walk(
      tester,
      const SendFile(
        roomId: 'r',
        imageCount: 0,
        isIntentSharing: false,
        socketService: null,
      ),
    );
  });

  testWidgets('DropDownView — a pushed route living in widgets/',
      (tester) async {
    report['DropDownView'] = await walk(
      tester,
      DropDownView(socketService: null, isIntentSharing: false),
    );
  });
}

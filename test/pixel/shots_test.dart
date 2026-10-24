import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'package:Snapdrop/l10n/app_localizations.dart';
import 'package:Snapdrop/screen/onboard_screen.dart';
import 'package:Snapdrop/screen/qr_screen.dart';
import 'package:Snapdrop/screen/send_file_screen.dart';
import 'package:Snapdrop/services/socket_service.dart';
import 'package:Snapdrop/widgets/app_background.dart';
import 'package:Snapdrop/widgets/app_dialog.dart';
import 'package:Snapdrop/widgets/app_toast.dart';

const _sessionId = 'DM0g7ImqFC3T_qjwAAAN';

/// Controllable fake of the transfer socket. Extends SocketService so it slots
/// into SendButton/SendFile (typed SocketService); overrides the surface used
/// by the transfer flow. No real network. The ack stream is driven by the test.
class FakeSocket extends SocketService {
  FakeSocket() : super(url: 'wss://x=$_sessionId');
  final _acks = StreamController<bool>.broadcast();

  void completeTransfer() => _acks.add(true); // flip to "Transfer Complete"

  @override
  void connectToSocketServer() {}
  @override
  void sendImages({String? name, String? type, Uint8List? file, String? userId}) {}
  @override
  Stream<bool> imageReceivedStream() => _acks.stream;
  @override
  String? get userId => _sessionId;
  @override
  String? get roomId => _sessionId;
  @override
  Future<Uint8List?> fileToBuffer(String filePath) async => null;
  @override
  Future<void> dispose() async {
    if (!_acks.isClosed) await _acks.close();
  }
}

// 1x1 PNG — a real, loadable file so Image.file doesn't error (tile content is
// excluded from diffing anyway).
final _pngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

List<SharedMediaFile> _seedMedia(int n) {
  final dir = Directory.systemTemp.createTempSync('snapdrop_seed');
  return List.generate(n, (i) {
    final f = File('${dir.path}/img_$i.png')..writeAsBytesSync(_pngBytes);
    return SharedMediaFile(path: f.path, type: SharedMediaType.image);
  });
}

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

Widget _harness(Widget child, {double topInset = 35}) {
  return MediaQuery(
    // Simulate a status-bar top inset so SafeArea pushes content down like the
    // mockup's status-bar row does. diff.py crops this strip from both sides.
    data: MediaQueryData(padding: EdgeInsets.only(top: topInset)),
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
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUpAll(() async {
    await _loadFonts();
    // reviewCounter=1 so the post-transfer review(==0)/share(==3) prompts don't
    // fire during the "complete" golden.
    SharedPreferences.setMockInitialValues(
        {'selectedLanguage': 'en', 'reviewCounter': 1, 'firstTimeLogin': false});

    // Make platform views (the QR camera) render blank instead of throwing.
    messenger.setMockMethodCallHandler(
        SystemChannels.platform_views, (call) async => 0);
    // Swallow the qr_code_scanner_plus controller channel calls. The view id
    // increments per QRView instance, so cover a range.
    for (var i = 0; i < 40; i++) {
      messenger.setMockMethodCallHandler(
          MethodChannel('net.touchcapture.qr.flutterqrplus/qrview_$i'),
          (call) async => null);
    }
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

  // ---- Transfer states (306x664 frames) ----
  // Seeded intent path: fake socket (fixed session id) + 5 seeded media. Grid
  // tiles render blank (files don't exist) — excluded content.
  Future<void> shootTransfer(WidgetTester tester, String shot,
      {required bool complete}) async {
    tester.view.physicalSize = const Size(918, 1992); // 306x664 @ DPR3
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final socket = FakeSocket();
    addTearDown(socket.dispose);
    await tester.pumpWidget(_harness(
      SendFile(
        roomId: _sessionId,
        socketService: socket,
        isIntentSharing: true,
        listOfMedia: _seedMedia(5),
        imageCount: 5,
      ),
      topInset: 31,
    ));
    await tester.pump(const Duration(milliseconds: 200));
    if (complete) {
      socket.completeTransfer();
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pump();
    await expectLater(
        find.byType(SendFile), matchesGoldenFile('../../qa/app/$shot.png'));
  }

  testWidgets('transfer_progress', (tester) async {
    await shootTransfer(tester, 'transfer_progress', complete: false);
  });
  testWidgets('transfer_complete', (tester) async {
    await shootTransfer(tester, 'transfer_complete', complete: true);
  });

  // ---- QR states (344x746 single; edge states 306x664) ----
  // The camera platform view renders blank (mocked); diff.py masks the viewport
  // interior. Everything around it (title, Figma line, brackets, button) is real.
  Future<void> shootQr(WidgetTester tester, String shot,
      {required Size physical,
      double topInset = 35,
      Duration settle = const Duration(milliseconds: 700),
      void Function(BuildContext)? after}) async {
    tester.view.physicalSize = physical;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(
      const QRScreen(isIntentSharing: true, listOfMedia: []),
      topInset: topInset,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(settle);
    if (after != null) {
      after(tester.element(find.byType(QRScreen)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await expectLater(
        find.byType(QRScreen), matchesGoldenFile('../../qa/app/$shot.png'));
  }

  testWidgets('qr', (tester) async {
    await shootQr(tester, 'qr', physical: const Size(1032, 2238));
  });

  testWidgets('qr_timeout', (tester) async {
    // The 20s timeout fires -> isTimeout state (no platform view).
    await shootQr(tester, 'qr_timeout',
        physical: const Size(918, 1992),
        topInset: 31,
        settle: const Duration(seconds: 21));
  });

  testWidgets('qr_nointernet', (tester) async {
    // Scanning viewport + the dark on-brand toast.
    await shootQr(tester, 'qr_nointernet',
        physical: const Size(918, 1992),
        topInset: 31,
        after: (c) => appToast(c, AppLocalizations.of(c)!.no_internet_connection));
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
      topInset: 30,
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

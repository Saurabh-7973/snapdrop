import 'dart:async';
import 'dart:typed_data';

import 'package:Snapdrop/constant/global_showcase_key.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../utils/firebase_initalization_class.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/send_file_screen.dart';
import '../services/check_internet_connectivity.dart';
import '../services/first_time_login.dart';
import '../services/session_controller.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';
import 'app_button.dart';
import 'app_toast.dart';
import 'figma_logo.dart';

class QRScanner extends StatefulWidget {
  final List<AssetEntity>? selectedAssetList;
  final List<SharedMediaFile>? listOfMedia;
  final bool isIntentSharing;

  const QRScanner(
      {super.key,
      this.selectedAssetList,
      required this.isIntentSharing,
      this.listOfMedia});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  bool scannerVisible = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _qrViewController;
  List<Uint8List>? bufferList = [];
  String? roomId;
  String? userId;
  bool connectionStatus = false;
  SocketService? socketService;
  Timer? _timeoutTimer;
  bool isTimeout = false;

  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          ShowCaseWidget.of(context)
              .startShowCase([GlobalShowcaseKeys.showcaseFour]);
        });
      } else {
        activateQrScanner();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _sweepController.dispose();
    // QRViewController self-disposes when QRView unmounts (its dispose() is
    // deprecated/no-op); just drop the reference.
    _qrViewController = null;
    super.dispose();
  }

  activateQrScanner() {
    setState(() {
      scannerVisible = true;
      isTimeout = false;
    });

    // Reset Timer
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (result == null) {
        _qrViewController?.pauseCamera();
        setState(() {
          isTimeout = true;
          scannerVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _scanLabel(context),
        const SizedBox(height: 22),
        widget.isIntentSharing == true
            ? qrContainer()
            : Showcase(
                key: GlobalShowcaseKeys.showcaseFour,
                targetBorderRadius: const BorderRadius.all(Radius.circular(22)),
                tooltipBackgroundColor: const Color(0xff161616),
                textColor: ThemeConstant.whiteColor,
                title: AppLocalizations.of(context)!.showcase_four_title,
                description:
                    AppLocalizations.of(context)!.showcase_four_subtitle,
                disposeOnTap: true,
                onBarrierClick: () => activateQrScanner(),
                onTargetClick: () => activateQrScanner(),
                onToolTipClick: () => activateQrScanner(),
                child: qrContainer()),
        if (isTimeout) ...[
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.qr_timed_out_message,
            textAlign: TextAlign.center,
            style: ThemeConstant.subtitleMuted.copyWith(fontSize: 14),
          ),
        ],
        const SizedBox(height: 22),
        widget.isIntentSharing == true
            ? _actionButton(context)
            : Showcase(
                targetPadding: const EdgeInsets.all(4),
                key: GlobalShowcaseKeys.showcaseFive,
                tooltipBackgroundColor: const Color(0xff161616),
                textColor: ThemeConstant.whiteColor,
                title: "Connect Button",
                description: 'Indicates successful QR code scan',
                onBarrierClick: () => debugPrint('qr connect clicked'),
                child: _actionButton(context)),
        const SizedBox(height: 26),
        if (connectionStatus) _confirmRow(context),
      ],
    );
  }

  /// Figma label above the viewport — or the dim "Scan timed out" header.
  Widget _scanLabel(BuildContext context) {
    if (isTimeout) {
      return Text(
        AppLocalizations.of(context)!.qr_timed_out_label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFF7C827F),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FigmaLogo(height: 18),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.qr_screen_herotext_3,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFFE7EAE8),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onQRViewController(QRViewController qrViewController) {
    _qrViewController = qrViewController;
    qrViewController.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        isTimeout = false;
      });

      _timeoutTimer?.cancel(); // Cancel the timeout when QR is scanned
      qrViewController.pauseCamera();
      connectSocket();
    });
  }

  Trace? _pairTrace;

  connectSocket() async {
    // Guard malformed QR codes: a valid pairing QR carries "...=<room>".
    // Without this, split('=')[1] throws RangeError and crashes the scan flow.
    final code = result?.code;
    if (code == null || SocketService.parseRoomId(code) == null) {
      FirebaseInitalizationClass.breadcrumb('pairing: invalid QR scanned');
      FirebaseInitalizationClass.eventTracker(
          'pairing_failed', {'reason': 'invalid_qr'});
      _qrViewController?.pauseCamera();
      setState(() {
        isTimeout = true;
        scannerVisible = false;
        connectionStatus = false;
      });
      return;
    }

    // Funnel: pairing started (additive — existing events unchanged). Trace
    // time-to-pair; stopped once the socket connection is established below.
    FirebaseInitalizationClass.setCustomKey('screen', 'qr_scanner');
    FirebaseInitalizationClass.breadcrumb('pairing_started');
    FirebaseInitalizationClass.eventTracker('pairing_started', {});
    _pairTrace = FirebaseInitalizationClass.newTrace('time_to_pair');
    await _pairTrace?.start();

    // Pair through the app-level session (persists across picker<->transfer so
    // subsequent sends skip the QR). Same SocketService/wire contract.
    sessionController.pair('${result!.code}');
    socketService = sessionController.socket;

    setState(() {
      connectionStatus = socketService != null;
    });

    FirebaseInitalizationClass.setCustomKey('paired', true);
    FirebaseInitalizationClass.breadcrumb('pairing_success');
    FirebaseInitalizationClass.eventTracker('pairing_success', {});
    await _pairTrace?.stop();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        if (widget.isIntentSharing) {
          return SendFile(
            listOfMedia: widget.listOfMedia,
            isIntentSharing: widget.isIntentSharing,
            imageCount: widget.listOfMedia!.length,
            roomId: '${result!.code}'.toString().split('=')[1],
            socketService: socketService,
          );
        } else {
          return SendFile(
            selectedAssetList: widget.selectedAssetList,
            isIntentSharing: widget.isIntentSharing,
            imageCount: widget.selectedAssetList!.length,
            roomId: '${result!.code}'.toString().split('=')[1],
            socketService: socketService,
          );
        }
      }));
    });
  }

  listDownAsset(List<AssetEntity> selectedAssetList) async {
    for (int i = 0; i < selectedAssetList.length; i++) {
      selectedAssetList[i].originBytes.then((value) async {
        bufferList!.add(value!);
      });
    }
  }

  /// Dark rounded viewport: corner brackets always; live camera + sweep when
  /// scanning; dim refresh glyph when timed out; idle camera icon otherwise.
  Widget qrContainer() {
    Widget inner;
    if (isTimeout) {
      inner = Center(
        child: Icon(Icons.refresh_rounded,
            color: Colors.white.withValues(alpha: 0.34), size: 38),
      );
    } else if (scannerVisible) {
      inner = Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: QRView(key: qrKey, onQRViewCreated: _onQRViewController),
            ),
          ),
          // subtle scan sweep
          AnimatedBuilder(
            animation: _sweepController,
            builder: (context, _) {
              return Positioned(
                left: 16,
                right: 16,
                top: 22 + _sweepController.value * 150,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(colors: [
                      Color(0x005ED296),
                      Color(0xD95ED296),
                      Color(0x005ED296),
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF5ED296).withValues(alpha: 0.6),
                          blurRadius: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else {
      inner = Center(
        child: Icon(Icons.camera_alt_rounded,
            color: Colors.white.withValues(alpha: 0.35), size: 22),
      );
    }

    return Container(
      width: 208,
      height: 208,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTimeout
              ? const [Color(0xFF141D18), Color(0xFF0C110E)]
              : const [Color(0xFF1B2C22), Color(0xFF0E1612)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: inner),
          ..._corners(),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    final color = Colors.white.withValues(alpha: isTimeout ? 0.18 : 0.5);
    Widget c(
            {double? top,
            double? left,
            double? right,
            double? bottom,
            required bool t,
            required bool l}) =>
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border(
                top: t ? BorderSide(color: color, width: 2.5) : BorderSide.none,
                bottom:
                    !t ? BorderSide(color: color, width: 2.5) : BorderSide.none,
                left:
                    l ? BorderSide(color: color, width: 2.5) : BorderSide.none,
                right:
                    !l ? BorderSide(color: color, width: 2.5) : BorderSide.none,
              ),
              borderRadius: BorderRadius.only(
                topLeft: t && l ? const Radius.circular(4) : Radius.zero,
                topRight: t && !l ? const Radius.circular(4) : Radius.zero,
                bottomLeft: !t && l ? const Radius.circular(4) : Radius.zero,
                bottomRight: !t && !l ? const Radius.circular(4) : Radius.zero,
              ),
            ),
          ),
        );
    return [
      c(top: 16, left: 16, t: true, l: true),
      c(top: 16, right: 16, t: true, l: false),
      c(bottom: 16, left: 16, t: false, l: true),
      c(bottom: 16, right: 16, t: false, l: false),
    ];
  }

  /// Restart Scan (timed out) or Connect (grey until a code reads, then white).
  Widget _actionButton(BuildContext context) {
    if (isTimeout) {
      return AppButton(
        label: AppLocalizations.of(context)!.qr_restart_scan,
        icon: Icons.refresh_rounded,
        width: 236,
        onTap: activateQrScanner,
      );
    }

    final bool ready = result != null;
    // Grey/disabled until a code reads, then a solid-white primary.
    if (!ready) {
      return SizedBox(
        width: 236,
        height: 52,
        child: Material(
          color: Colors.white.withValues(alpha: 0.13),
          shape: const StadiumBorder(),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.home_screen_button, // "Connect"
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }
    return AppButton(
      label: AppLocalizations.of(context)!.qr_screen_button_scanning_completed,
      width: 236,
      onTap: () async {
        final msg = AppLocalizations.of(context)!.no_internet_connection;
        final hasNet = await CheckInternetConnectivity.hasNetwork();
        if (!context.mounted) return;
        if (hasNet) {
          connectSocket();
        } else {
          appToast(context, msg);
        }
      },
    );
  }

  /// Quiet pair confirmation: green dot + small-caps label + session id.
  Widget _confirmRow(BuildContext context) {
    final id = result?.code != null
        ? (SocketService.parseRoomId('${result!.code}') ?? '')
        : '';
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF46C886),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!
                  .qr_screen_button_scanning_completed
                  .toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF8FA89A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        if (id.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            id,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFFEEF1EF),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

import 'dart:typed_data';

import 'package:Snapdrop/constant/global_showcase_key.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/send_file_screen.dart';
import '../services/check_internet_connectivity.dart';
import '../services/first_time_login.dart';
import '../services/socket_service.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRScanner extends StatefulWidget {
  // const QRScanner({super.key});

  List<AssetEntity>? selectedAssetList;
  List<SharedMediaFile>? listOfMedia;
  bool isIntentSharing = false;

  QRScanner(
      {super.key,
      this.selectedAssetList,
      required this.isIntentSharing,
      this.listOfMedia});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool scannerVisible = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _qrViewController;
  List<Uint8List>? bufferList = [];
  String? roomId;
  String? userId;
  bool connectionStatus = false;
  SocketService? socketService;

  @override
  void initState() {
    super.initState();
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

  activateQrScanner() {
    setState(() {
      scannerVisible = scannerVisible == true ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        widget.isIntentSharing == true
            ? qrContainer(screenHeight, screenWidth)
            : Showcase(
                key: GlobalShowcaseKeys.showcaseFour,
                targetBorderRadius: const BorderRadius.all(Radius.circular(15)),
                tooltipBackgroundColor: const Color(0xff161616),
                textColor: ThemeConstant.whiteColor,
                title: AppLocalizations.of(context)!.showcase_four_title,
                description:
                    AppLocalizations.of(context)!.showcase_four_subtitle,
                disposeOnTap: true,
                onBarrierClick: () => activateQrScanner(),
                onTargetClick: () => activateQrScanner(),
                onToolTipClick: () => activateQrScanner(),
                child: qrContainer(screenHeight, screenWidth)),
        const SizedBox(
          height: 10,
        ),
        widget.isIntentSharing == true
            ? qrConnectButton(screenWidth)
            : Showcase(
                targetPadding: const EdgeInsets.all(4),
                key: GlobalShowcaseKeys.showcaseFive,
                tooltipBackgroundColor: const Color(0xff161616),
                textColor: ThemeConstant.whiteColor,
                title: "Connect Button",
                description: 'Indicates successful QR code scan',
                onBarrierClick: () => debugPrint('qr connect clicked'),
                child: qrConnectButton(screenWidth)),
        const SizedBox(
          height: 45,
        ),
        Visibility(
          visible: connectionStatus,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.of(context)!
                          .qr_screen_button_scanning_completed,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (result != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${result!.code}'.toString().split('=')[
                            1], // If userId is null, an empty string is used
                        style: ThemeConstant.smallTextSizeLight,
                      ),
                    )
                  ],
                ),
            ],
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
      });
      qrViewController.pauseCamera();
      connectSocket();
    });
  }

  connectSocket() async {
    '${result!.code}'.toString().split('=')[1];

    socketService = SocketService(url: '${result!.code}');
    socketService!.connectToSocketServer();

    setState(() {
      socketService != null
          ? connectionStatus = true
          : connectionStatus = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
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

  Widget qrContainer(screenHeight, screenWidth) {
    return Container(
      height: screenHeight / 2.8,
      width: screenWidth / 1.3,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(15)),
      child: scannerVisible == false
          ? const Center(
              child: CircleAvatar(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewController,
              ),
            ),
    );
  }

  Widget qrConnectButton(screenWidth) {
    return SizedBox(
      width: screenWidth / 1.3,
      height: 50,
      child: ElevatedButton(
          onPressed: () async {
            await CheckInternetConnectivity.hasNetwork().then((value) {
              if (value) {
                if (result != null) {
                  connectSocket();
                }
              } else {
                var snackbarLimit = SnackBar(
                  backgroundColor: ThemeConstant.primaryAppColor,
                  content: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppLocalizations.of(context)!
                          .app_conditions_internet_connection,
                      style: ThemeConstant.smallTextSizeDarkFontWidth,
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbarLimit);
              }
            });
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: result != null ? Colors.green : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              result != null
                  ? AppLocalizations.of(context)!
                      .qr_screen_button_scanning_completed
                  : AppLocalizations.of(context)!.qr_screen_button_scanning,
              style: result != null
                  ? ThemeConstant.smallTextSizeWhiteFontWidth
                  : ThemeConstant.smallTextSizeDarkFontWidth,
            ),
          )),
    );
  }
}

import 'dart:developer';
import 'dart:typed_data';

import 'package:Snapdrop/constant/global_showcase_key.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/send_file_screen.dart';
import '../services/first_time_login.dart';
import '../services/socket_service.dart';

class QRScanner extends StatefulWidget {
  // const QRScanner({super.key});

  List<AssetEntity>? selectedAssetList;
  List<SharedMediaFile>? listOfMedia;
  bool isIntentSharing = false;

  QRScanner({super.key, this.selectedAssetList, required this.isIntentSharing, this.listOfMedia});

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
    // TODO: implement initState
    super.initState();
    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context).startShowCase([GlobalShowcaseKeys.showcaseFour, GlobalShowcaseKeys.showcaseFive]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // QRViewController qrViewController;

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    ThemeConstant themeConstant = ThemeConstant();

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              scannerVisible = scannerVisible == true ? false : true;
            });
          },
          child: Showcase(
            targetPadding: const EdgeInsets.all(4),
            key: GlobalShowcaseKeys.showcaseFour,
            title: "QR Scanner",
            description: 'CLick to Scan QR Code',
            onBarrierClick: () => debugPrint('qr scanner clicked'),
            child: Container(
              height: screenHeight / 2.8,
              width: screenWidth / 1.3,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), borderRadius: BorderRadius.circular(15)),
              child: scannerVisible == false
                  ? const Center(
                      // child: SvgPicture.asset(
                      //   'assets/svg_asset/camera.svg',
                      //   color: Colors.white,
                      // ),
                      child: CircleAvatar(
                        foregroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.grey,
                          size: 18,
                          //size: 36,
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
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Showcase(
          targetPadding: const EdgeInsets.all(4),
          key: GlobalShowcaseKeys.showcaseFive,
          title: "Connect Button",
          description: 'Indicates successful QR code scan',
          onBarrierClick: () => debugPrint('qr connect clicked'),
          child: SizedBox(
            width: screenWidth / 1.3,
            height: 40,
            child: ElevatedButton(
                onPressed: () {
                  if (result != null) {
                    connectSocket();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: result != null ? Colors.green : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Text(
                  "Connect",
                  style: result != null ? ThemeConstant.smallTextSizeLight : ThemeConstant.smallTextSizeDark,
                )),
          ),
        ),
        const SizedBox(
          height: 45,
        ),
        Visibility(
          visible: connectionStatus,
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Connected Successfully',
                    style: TextStyle(color: Colors.white70),
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
                    Text(
                      '${result!.code}'.toString().split('=')[1], // If userId is null, an empty string is used
                      style: ThemeConstant.smallTextSizeLight,
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
    });
  }

  connectSocket() async {
    '${result!.code}'.toString().split('=')[1];

    log('URL : ${result!.code}');
    log('URL : ${result!.code.toString().split('=')[1]}');

    socketService = SocketService(url: '${result!.code}');
    socketService!.connectToSocketServer();

    setState(() {
      socketService != null ? connectionStatus = true : connectionStatus = false;
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
        log(bufferList![i].toString());
      });
    }
  }
}

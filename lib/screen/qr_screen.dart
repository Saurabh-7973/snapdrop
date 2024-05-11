import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../wigets/app_bar_widget.dart';
import '../wigets/figma_display_helper.dart';
import '../wigets/hero_text.dart';
import '../wigets/qr_scanner.dart';

class QRScreen extends StatefulWidget {
  List<AssetEntity>? selectedAssetList;
  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;

  QRScreen(
      {super.key,
      this.selectedAssetList,
      required this.isIntentSharing,
      this.listOfMedia});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  @override
  Widget build(BuildContext context) {
    print('Intent Sharing : ${widget.isIntentSharing}');
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff206946), Color(0xff071414), Color(0xff040807)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const AppBarWidget(),
                HeroText(
                    firstLine: "Scan QR Code",
                    secondLine: "to Continue",
                    thirdLine: ""),
                const FigmaDisplayHelper(),
                const SizedBox(
                  height: 5,
                ),
                widget.isIntentSharing == true
                    ? Expanded(
                        flex: 6,
                        child: QRScanner(
                          isIntentSharing: widget.isIntentSharing,
                          listOfMedia: widget.listOfMedia,
                        ),
                      )
                    : Expanded(
                        flex: 6,
                        child: ShowCaseWidget(
                          blurValue: 1,
                          builder: Builder(
                            builder: (context) => QRScanner(
                              isIntentSharing: widget.isIntentSharing,
                              selectedAssetList: widget.selectedAssetList!,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

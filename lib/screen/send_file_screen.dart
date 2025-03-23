import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/connect.dart';
import '../wigets/floating_triangles.dart';
import '../wigets/hero_text.dart';
import '../wigets/intent_file_displayer.dart';
import '../wigets/room_displayer.dart';
import '../wigets/selected_images.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SendFile extends StatelessWidget {
  String roomId;
  List<AssetEntity>? selectedAssetList;
  SocketService? socketService;
  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;
  int imageCount;

  SendFile({
    super.key,
    this.selectedAssetList,
    this.listOfMedia,
    required this.imageCount,
    required this.isIntentSharing,
    required this.roomId,
    required this.socketService,
  });

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ThemeConstant.primaryAppColor,
      body: Stack(
        children: [
          /// ✅ **Background Gradient**
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConstant.primaryAppColor,
                  ThemeConstant.primaryAppColorGradient2,
                  ThemeConstant.primaryAppColorGradient3,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// ✅ **Floating Triangles Animation**
          Positioned.fill(
            child: FloatingSquares(),
          ),

          /// ✅ **Main Content**
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const AppBarWidget(),
                  HeroText(
                    firstLine:
                        '${AppLocalizations.of(context)!.send_screen_hero_text_1} $imageCount',
                    secondLine:
                        AppLocalizations.of(context)!.send_screen_hero_text_2,
                    thirdLine: '',
                  ),
                  const SizedBox(height: 15),

                  /// ✅ **Connected Room Info**
                  RoomDisplayer(
                    senderId: socketService!.userId!,
                    receiverId: roomId,
                    senderMessage:
                        AppLocalizations.of(context)!.send_screen_your_id,
                    receiverMessage:
                        AppLocalizations.of(context)!.send_screen_connected_to,
                  ),
                  const SizedBox(height: 10),

                  /// ✅ **Image Preview Section**
                  Expanded(
                    child: Container(
                      height: screenHeight / 2.2,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isIntentSharing == true
                          ? IntentFileDisplayer(
                              isIntentSharing: true,
                              listOfMedia: listOfMedia,
                              connectDisplayer: false,
                            )
                          : SelectedImagesViewer(
                              selectedAssetList: selectedAssetList!,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// ✅ **Send Button / Showcase**
                  isIntentSharing == true
                      ? SendButton(
                          socketService: socketService,
                          listOfMedia: listOfMedia,
                          isIntentSharing: isIntentSharing,
                        )
                      : ShowCaseWidget(
                          blurValue: 1,
                          builder: (context) => SendButton(
                            socketService: socketService,
                            selectedAssetList: selectedAssetList!,
                            isIntentSharing: isIntentSharing,
                          ),
                          autoPlayDelay: const Duration(seconds: 3),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

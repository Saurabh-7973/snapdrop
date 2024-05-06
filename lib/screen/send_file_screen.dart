import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/connect.dart';
import '../wigets/hero_text.dart';
import '../wigets/intent_file_displayer.dart';
import '../wigets/room_displayer.dart';
import '../wigets/selected_images.dart';

class SendFile extends StatelessWidget {
  String roomId;
  List<AssetEntity>? selectedAssetList;
  SocketService? socketService;
  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;
  int imageCount;

  SendFile(
      {super.key,
      this.selectedAssetList,
      this.listOfMedia,
      required this.imageCount,
      required this.isIntentSharing,
      required this.roomId,
      required this.socketService});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

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
                HeroText(firstLine: 'Transfer $imageCount', secondLine: 'Images', thirdLine: ''),
                RoomDisplayer(roomId: roomId, message: 'CONNECTED TO'),
                const SizedBox(
                  height: 10,
                ),
                RoomDisplayer(roomId: socketService!.userId, message: 'YOUR ID'),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: screenHeight / 2.2,
                    color: Colors.transparent,
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
                const SizedBox(
                  height: 10,
                ),
                isIntentSharing == true
                    ? SendButton(
                        socketService: socketService,
                        listOfMedia: listOfMedia,
                        isIntentSharing: isIntentSharing,
                      )
                    : ShowCaseWidget(
                        blurValue: 1,
                        builder: Builder(
                          builder: (context) => SendButton(
                            socketService: socketService,
                            selectedAssetList: selectedAssetList!,
                            isIntentSharing: isIntentSharing,
                          ),
                        ),
                        autoPlayDelay: const Duration(seconds: 3),
                        // child: DropDownView(
                        //   socketService: widget.socketService,
                        // ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

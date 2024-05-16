import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../services/socket_service.dart';

class IntentFileDisplayer extends StatelessWidget {
  List<AssetEntity>? selectedAssetList;
  SocketService? socketService;
  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;
  bool connectDisplayer = false;

  IntentFileDisplayer({
    super.key,
    required this.isIntentSharing,
    this.listOfMedia,
    this.socketService,
    this.selectedAssetList,
    required this.connectDisplayer,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.6,
          child: GridView.builder(
            itemCount: listOfMedia!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: (2 / 3),
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(listOfMedia![index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        Visibility(
            visible: connectDisplayer,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                width: screenWidth / 2.6,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScreen(
                            isIntentSharing: true,
                            listOfMedia: listOfMedia,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Connect",
                            style: ThemeConstant.smallTextSizeDark,
                          ),
                        ),
                        // const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

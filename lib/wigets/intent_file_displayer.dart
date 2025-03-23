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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        /// ✅ GridView displaying shared files
        SizedBox(
          height: screenHeight / 1.6,
          child: GridView.builder(
            itemCount: listOfMedia!.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: (2 / 3),
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // TODO: Optional: Implement Image Preview on tap
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(listOfMedia![index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        /// ✅ Connect Button with Smooth Transition
        if (connectDisplayer)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: screenWidth / 1.4,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Connect",
                      style: ThemeConstant.smallTextSizeDark.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

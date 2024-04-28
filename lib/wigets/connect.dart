import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../constant/theme_contants.dart';
import '../screen/home_screen.dart';
import '../services/socket_service.dart';

class SendButton extends StatefulWidget {
  SocketService? socketService;
  List<AssetEntity>? selectedAssetList;

  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;
  bool transferCompleted = false;

  SendButton(
      {super.key,
      required this.isIntentSharing,
      this.listOfMedia,
      required this.socketService,
      this.selectedAssetList});

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  List<SharedMediaFile>? listOfImageModal = [];

  List<Map<String, dynamic>>? listOfMaps;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    ThemeConstant themeConstant = ThemeConstant();

    return widget.transferCompleted == false
        ? SizedBox(
            width: screenWidth / 1.3,
            height: 40,
            child: ElevatedButton(
                onPressed: () async {
                  if (widget.isIntentSharing) {
                    await sendFilesToServerIntent();
                    await widget.socketService!
                        .transferCompleted()
                        .then((value) {
                      if (value == true) {
                        setState(() {
                          widget.transferCompleted = true;
                        });
                      } else {}
                    });
                  } else {
                    await sendFilesToServer();
                    await widget.socketService!
                        .transferCompleted()
                        .then((value) {
                      if (value == true) {
                        setState(() {
                          widget.transferCompleted = true;
                        });
                      }
                    });
                    // await widget.socketService!.transferCompleted();
                    // setState(() {
                    //   widget.transferCompleted = true;
                    // });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: Text(
                  "Send",
                  style: ThemeConstant.smallTextSizeDark,
                )),
          )
        : SizedBox(
            width: screenWidth,
            height: screenHeight / 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: screenWidth / 2.6,
                  height: 60,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      socketService: null,
                                    )),
                            (Route route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          // const Spacer(),
                          Text(
                            "Close",
                            style: ThemeConstant.smallTextSizeLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth / 2.6,
                  height: 60,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                    socketService: widget.socketService)),
                            (Route route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 18,
                          ),
                          Text(
                            "Send",
                            style: ThemeConstant.smallTextSizeDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
  }

  String getImageName(String filePath) {
    String fileName = filePath.split('/').last;

    int extensionIndex = fileName.lastIndexOf('.');
    if (extensionIndex != -1) {
      return fileName.substring(0, extensionIndex);
    }
    return fileName;
  }

  String getImageExtension(String filePath) {
    String fileName = filePath.split('/').last;
    int extensionIndex = fileName.lastIndexOf('.');
    if (extensionIndex != -1) {
      return fileName.substring(extensionIndex + 1);
    }
    return '';
  }

  sendFilesToServer() {
    for (int i = 0; i < widget.selectedAssetList!.length; i++) {
      widget.selectedAssetList![i].originFile.then((value) {
        String imageName = getImageName(value!.path);
        String imageExtension = getImageExtension(value.path);

        widget.socketService!.fileToBuffer(value.path).then((unitFile) {
          String? userId = widget.socketService!.userId;
          widget.socketService!.sendImages(
              name: imageName,
              type: imageExtension,
              file: unitFile,
              userId: userId);
        });
      });
    }
  }

  sendFilesToServerIntent() {
    for (int i = 0; i < widget.listOfMedia!.length; i++) {
      String imageName = getImageName("${widget.listOfMedia![i].path}}");
      String imageExtension = getImageExtension(widget.listOfMedia![i].path);

      widget.socketService!
          .fileToBuffer(widget.listOfMedia![i].path)
          .then((unitFile) {
        String? userId = widget.socketService!.userId;
        widget.socketService!.sendImages(
            name: imageName,
            type: imageExtension,
            file: unitFile,
            userId: userId);
      });
    }
  }
}

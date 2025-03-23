import 'dart:io';

import 'package:Snapdrop/constant/global_showcase_key.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/home_screen.dart';
import '../services/check_internet_connectivity.dart';
import '../services/first_time_login.dart';
import '../services/socket_service.dart';
import '../utils/firebase_initalization_class.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class _SendButtonState extends State<SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  List<SharedMediaFile>? listOfImageModal = [];

  List<Map<String, dynamic>>? listOfMaps;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Smooth glow effect
    )..repeat(reverse: true); // Creates a pulsing effect

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    super.initState();
    // FirstTimeLogin.checkFirstTimeLogin().then((value) {
    //   if (value == true) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) =>
    //         ShowCaseWidget.of(context).startShowCase([
    //           GlobalShowcaseKeys.showcaseSeven,
    //           GlobalShowcaseKeys.showcaseEight
    //         ]));
    //   }
    // });

    //Immediate File Transfer
    fileTransfer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  fileTransfer() async {
    if (widget.isIntentSharing) {
      await sendFilesToServerIntent();
      widget.socketService!.imageReceivedStream().listen((value) {
        if (value == true) {
          setState(() {
            widget.transferCompleted = true;
          });
        }
      });
      //Event (File Share)
      FirebaseInitalizationClass.eventTracker('file_share_completed', {
        'sharing_method': 'intent_sharing',
        //'image_count': widget.listOfMedia!.length
      });
    } else {
      await sendFilesToServer();
      //Commented for now ()
      widget.socketService!.imageReceivedStream().listen((value) {
        if (value == true) {
          setState(() {
            widget.transferCompleted = true;
          });
        }
      });
      //Event (File Share)
      FirebaseInitalizationClass.eventTracker('file_share_completed', {
        'sharing_method': 'non_intent_sharing',
        //'image_count': widget.listOfMedia!.length
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return widget.transferCompleted == false
        ? widget.isIntentSharing == true
            ? sendFilesToServerButton(screenWidth)
            // : sendFilesToServerButton(screenWidth)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _glowAnimation,
                    child: Text(
                      AppLocalizations.of(context)!.uploading_text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            blurRadius: 10, // Softer glow
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 5, // Sleek progress bar
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: LinearProgressIndicator(
                        value: null,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              )
        : SizedBox(
            width: screenWidth,
            height: screenHeight / 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                widget.isIntentSharing == true
                    ? closeButton(screenWidth)
                    : Showcase(
                        targetPadding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        key: GlobalShowcaseKeys.showcaseSeven,
                        tooltipBackgroundColor: const Color(0xff161616),
                        textColor: ThemeConstant.whiteColor,
                        title:
                            AppLocalizations.of(context)!.showcase_five_title,
                        description: AppLocalizations.of(context)!
                            .showcase_five_subtitle,
                        onBarrierClick: () =>
                            debugPrint('close button clicked'),
                        child: closeButton(screenWidth)),
                widget.isIntentSharing == true
                    ? sendMoreButton(screenWidth, widget.isIntentSharing)
                    : Showcase(
                        targetPadding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        key: GlobalShowcaseKeys.showcaseEight,
                        tooltipBackgroundColor: const Color(0xff161616),
                        textColor: ThemeConstant.whiteColor,
                        title: AppLocalizations.of(context)!.showcase_six_title,
                        description:
                            AppLocalizations.of(context)!.showcase_six_subtitle,
                        onBarrierClick: () =>
                            debugPrint('send more button clicked'),
                        child:
                            sendMoreButton(screenWidth, widget.isIntentSharing),
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

  Widget sendFilesToServerButton(screenWidth) {
    return SizedBox(
      width: screenWidth / 1.3,
      height: 50,
      child: ElevatedButton(
          onPressed: () async {
            await CheckInternetConnectivity.hasNetwork().then((value) async {
              if (value) {
                fileTransfer();
              } else {
                var snackbarLimit = SnackBar(
                    backgroundColor: ThemeConstant.primaryAppColor,
                    content: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context)!
                            .app_conditions_internet_connection,
                        style: ThemeConstant.smallTextSizeLight,
                      ),
                    ));
                ScaffoldMessenger.of(context).showSnackBar(snackbarLimit);
              }
            });
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context)!.send_screen_connect_button,
              style: ThemeConstant.smallTextSizeDarkFontWidth,
            ),
          )),
    );
  }

  Widget closeButton(screenWidth) {
    return Container(
      width: screenWidth / 2.6,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            exit(0);
          },
          style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth / 2.6, 50),
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
                size: 22,
              ),
              const SizedBox(
                width: 5,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.send_screen_close_button,
                  style: ThemeConstant.smallTextSizeWhiteFontWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sendMoreButton(screenWidth, isIntentSharing) {
    return Container(
      width: screenWidth / 2.6,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // this is for not showing the tutorial again
            FirstTimeLogin.setFirstTimeLoginFalse();
            //Event (Tutorial Completed)
            FirebaseInitalizationClass.eventTracker(
                'tutorial_completed', {'first_time': 'false'});

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          socketService: widget.socketService,
                          isIntentSharing: false,
                        )),
                (Route route) => false);
          },
          style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth / 2.6, 50),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Colors.black,
                size: 22,
              ),
              const SizedBox(
                width: 5,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.send_screen_send_more_button,
                  style: ThemeConstant.smallTextSizeDarkFontWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

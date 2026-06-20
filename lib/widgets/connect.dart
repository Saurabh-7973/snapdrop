import 'dart:async';

import 'package:flutter/services.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:Snapdrop/constant/global_showcase_key.dart';
import 'package:Snapdrop/services/in_app_review_service.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/home_screen.dart';
import '../services/first_time_login.dart';
import '../services/session_controller.dart';
import '../services/socket_service.dart';
import '../utils/firebase_initalization_class.dart';
import '../l10n/app_localizations.dart';

import 'app_button.dart';
import 'share_app_dialog.dart';

class SendButton extends StatefulWidget {
  final SocketService? socketService;
  final List<AssetEntity>? selectedAssetList;

  final bool isIntentSharing;
  final List<SharedMediaFile>? listOfMedia;

  /// Fired once the transfer is acknowledged complete, so the parent screen can
  /// switch the title to "Transfer Complete" and reveal the action buttons.
  final VoidCallback? onTransferCompleted;

  const SendButton(
      {super.key,
      required this.isIntentSharing,
      this.listOfMedia,
      required this.socketService,
      this.selectedAssetList,
      this.onTransferCompleted});

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  List<SharedMediaFile>? listOfImageModal = [];

  List<Map<String, dynamic>>? listOfMaps;

  bool transferCompleted = false;
  StreamSubscription<bool>? _ackSub;
  Trace? _transferTrace;

  @override
  void dispose() {
    _ackSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              ShowCaseWidget.of(context).startShowCase([
                GlobalShowcaseKeys.showcaseSeven,
                GlobalShowcaseKeys.showcaseEight
              ]));
        }
      }
    });

    //Immediate File Transfer
    sessionController.markTransferring();
    fileTransfer();
  }

  fileTransfer() async {
    int? reviewCounter;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Funnel: transfer started (additive — existing file_share_completed kept).
    final int imageCount = widget.isIntentSharing
        ? (widget.listOfMedia?.length ?? 0)
        : (widget.selectedAssetList?.length ?? 0);
    final String method =
        widget.isIntentSharing ? 'intent_sharing' : 'non_intent_sharing';
    FirebaseInitalizationClass.setCustomKey('transfer_state', 'started');
    FirebaseInitalizationClass.setCustomKey('image_count', imageCount);
    FirebaseInitalizationClass.breadcrumb(
        'transfer_started ($method, $imageCount)');
    FirebaseInitalizationClass.eventTracker('transfer_started',
        {'sharing_method': method, 'image_count': imageCount});
    _transferTrace = FirebaseInitalizationClass.newTrace('transfer_duration');
    await _transferTrace?.start();

    if (widget.isIntentSharing) {
      await sendFilesToServerIntent();
      _ackSub =
          widget.socketService!.imageReceivedStream().listen((value) async {
        //Asking for review
        reviewCounter = prefs.getInt('reviewCounter');
        if (value == true) {
          if (mounted) {
            setState(() {
              transferCompleted = true;
              FirstTimeLogin.setFirstTimeLoginFalse();
            });
            sessionController.markComplete();
            widget.onTransferCompleted?.call();
            // Funnel: transfer success (additive).
            FirebaseInitalizationClass.setCustomKey(
                'transfer_state', 'success');
            FirebaseInitalizationClass.eventTracker('transfer_success',
                {'sharing_method': method, 'image_count': imageCount});
            await _transferTrace?.stop();
            _transferTrace = null;
          }

          if (reviewCounter == 0) {
            InAppReviewService().checkForInAppReview();

            //Event (App Review)
            FirebaseInitalizationClass.eventTracker('app_review_called', {
              'sharing_method': 'intent_sharing',
              //'image_count': widget.listOfMedia!.length
            });
          }

          if (reviewCounter == 3 && mounted) {
            //App Share Widget
            showShareDialog(context);

            //Event (App share)
            FirebaseInitalizationClass.eventTracker('app_share_called', {
              'sharing_method': 'intent_sharing',
              //'image_count': widget.listOfMedia!.length
            });
          }
        }

        reviewCounter = (reviewCounter ?? 0) + 1;
        await prefs.setInt('reviewCounter', reviewCounter!);
      });
      //Event (File Share)
      FirebaseInitalizationClass.eventTracker('file_share_completed', {
        'sharing_method': 'intent_sharing',
        //'image_count': widget.listOfMedia!.length
      });
    } else {
      await sendFilesToServer();
      //Commented for now ()
      _ackSub =
          widget.socketService!.imageReceivedStream().listen((value) async {
        if (value == true) {
          if (mounted) {
            setState(() {
              transferCompleted = true;
              FirstTimeLogin.setFirstTimeLoginFalse();
            });
            sessionController.markComplete();
            widget.onTransferCompleted?.call();
            // Funnel: transfer success (additive).
            FirebaseInitalizationClass.setCustomKey(
                'transfer_state', 'success');
            FirebaseInitalizationClass.eventTracker('transfer_success',
                {'sharing_method': method, 'image_count': imageCount});
            await _transferTrace?.stop();
            _transferTrace = null;
          }

          //Asking for review
          reviewCounter = prefs.getInt('reviewCounter');

          if (reviewCounter == 0) {
            InAppReviewService().checkForInAppReview();

            //Event (App Review)
            FirebaseInitalizationClass.eventTracker('app_review_called', {
              'sharing_method': 'non_intent_sharing',
              //'image_count': widget.listOfMedia!.length
            });
          }

          if (reviewCounter == 3 && mounted) {
            //App Share Widget
            showShareDialog(context);

            //Event (App share)
            FirebaseInitalizationClass.eventTracker('app_share_called', {
              'sharing_method': 'non_intent_sharing',
              //'image_count': widget.listOfMedia!.length
            });
          }
        }

        reviewCounter = (reviewCounter ?? 0) + 1;
        await prefs.setInt('reviewCounter', reviewCounter!);
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
    // Buttons appear only once the transfer is complete; in-progress shows
    // nothing (matches snapdrop_transfer_faithful.html).
    if (!transferCompleted) return const SizedBox.shrink();

    final close = widget.isIntentSharing
        ? closeButton()
        : Showcase(
            targetPadding: const EdgeInsets.all(4),
            key: GlobalShowcaseKeys.showcaseSeven,
            tooltipBackgroundColor: const Color(0xff161616),
            textColor: ThemeConstant.whiteColor,
            title: AppLocalizations.of(context)!.showcase_five_title,
            description: AppLocalizations.of(context)!.showcase_five_subtitle,
            child: closeButton());
    final sendMore = widget.isIntentSharing
        ? sendMoreButton()
        : Showcase(
            targetPadding: const EdgeInsets.all(4),
            key: GlobalShowcaseKeys.showcaseEight,
            tooltipBackgroundColor: const Color(0xff161616),
            textColor: ThemeConstant.whiteColor,
            title: AppLocalizations.of(context)!.showcase_six_title,
            description: AppLocalizations.of(context)!.showcase_six_subtitle,
            child: sendMoreButton());

    // §5 two-button row: edge-to-edge within content padding, equal split,
    // 12dp gap, both 52dp.
    return Row(
      children: [
        Expanded(child: close),
        const SizedBox(width: 12),
        Expanded(child: sendMore),
      ],
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
    final assets = widget.selectedAssetList;
    if (assets == null) return;
    for (int i = 0; i < assets.length; i++) {
      assets[i].originFile.then((value) {
        // Guard: originFile can be null (asset file unavailable) -> was a crash.
        if (value == null) {
          FirebaseInitalizationClass.recordNonFatal(
              'originFile returned null', StackTrace.current,
              reason: 'transfer: asset file unavailable');
          return;
        }
        String imageName = getImageName(value.path);
        String imageExtension = getImageExtension(value.path);

        widget.socketService!.fileToBuffer(value.path).then((unitFile) {
          if (unitFile == null) {
            FirebaseInitalizationClass.recordNonFatal(
                'fileToBuffer returned null', StackTrace.current,
                reason: 'transfer: unreadable file ${value.path}');
          }
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
    final media = widget.listOfMedia;
    if (media == null) return;
    for (int i = 0; i < media.length; i++) {
      String imageName = getImageName("${media[i].path}}");
      String imageExtension = getImageExtension(media[i].path);

      widget.socketService!.fileToBuffer(media[i].path).then((unitFile) {
        if (unitFile == null) {
          FirebaseInitalizationClass.recordNonFatal(
              'fileToBuffer returned null', StackTrace.current,
              reason: 'transfer(intent): unreadable file ${media[i].path}');
        }
        String? userId = widget.socketService!.userId;
        widget.socketService!.sendImages(
            name: imageName,
            type: imageExtension,
            file: unitFile,
            userId: userId);
      });
    }
  }

  Widget closeButton() {
    return AppButton.secondary(
      label: AppLocalizations.of(context)!.send_screen_close_button,
      icon: Icons.close_rounded,
      onTap: () async {
        // Close ends the session cleanly (no zombie socket). Intent-share
        // variant exits the app; picker variant returns to Home disconnected.
        await sessionController.disconnect();
        if (!mounted) return;
        if (widget.isIntentSharing) {
          SystemNavigator.pop();
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                socketService: null,
                isIntentSharing: false,
              ),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  Widget sendMoreButton() {
    return AppButton(
      label: AppLocalizations.of(context)!.send_screen_send_more_button,
      icon: Icons.add,
      onTap: () {
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/figma_display_helper.dart';
import '../wigets/hero_text.dart';
import '../wigets/qr_scanner.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Container(
      color: ThemeConstant.primaryAppColor,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeConstant.primaryAppColor,
                ThemeConstant.primaryAppColorGradient2,
                ThemeConstant.primaryAppColorGradient3
              ],
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
                  Stack(
                    children: [
                      const AppBarWidget(),
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                var snackbarLimit = SnackBar(
                                  backgroundColor:
                                      ThemeConstant.primaryAppColor,
                                  content: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .qr_screen_info_button,
                                      style: ThemeConstant.smallTextSizeLight,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackbarLimit);
                              },
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  HeroText(
                      firstLine:
                          AppLocalizations.of(context)!.qr_screen_herotext_1,
                      secondLine:
                          AppLocalizations.of(context)!.qr_screen_herotext_2,
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
                            builder: (context) => QRScanner(
                              isIntentSharing: widget.isIntentSharing,
                              selectedAssetList: widget.selectedAssetList!,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

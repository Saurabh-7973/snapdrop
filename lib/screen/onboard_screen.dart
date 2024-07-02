import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_initalization_class.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_text.dart';
import '../widgets/intro_widget.dart';
import 'home_screen.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
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
                  const AppBarWidget(),
                  Expanded(
                    flex: 9,
                    child: HeroText(
                      firstLine:
                          AppLocalizations.of(context)!.onboard_hero_text_1,
                      secondLine:
                          AppLocalizations.of(context)!.onboard_hero_text_2,
                      thirdLine: "",
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: SizedBox(
                        width: screenWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IntroWidget(
                              icon: Icons.image_outlined,
                              text:
                                  AppLocalizations.of(context)!.onboard_step_1,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            IntroWidget(
                              icon: Icons.qr_code_scanner_outlined,
                              text:
                                  AppLocalizations.of(context)!.onboard_step_2,
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            IntroWidget(
                              icon: Icons.send_rounded,
                              text:
                                  AppLocalizations.of(context)!.onboard_step_3,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Event (Tutorial Begin)
                      FirebaseInitalizationClass.eventTracker(
                          'tutorial_begin', {'tutorial_begin': 'true'});
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => HomeScreen(
                                  socketService: null,
                                  isIntentSharing: false,
                                )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(screenWidth / 3, screenHeight / 16),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppLocalizations.of(context)!.onboard_button_text,
                            style: ThemeConstant.smallTextSizeDarkFontWidth,
                          ),
                        ),
                      ],
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

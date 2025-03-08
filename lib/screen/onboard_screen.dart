import 'dart:math';

import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/firebase_initalization_class.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/floating_triangles.dart';
import '../wigets/hero_text.dart';
import '../wigets/intro_widget.dart';
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
            body: Stack(
              children: [
                const FloatingSquares(),
                Padding(
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
                              spacing: 30,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IntroWidget(
                                  icon: Icons.image_outlined,
                                  text: AppLocalizations.of(context)!
                                      .onboard_step_1,
                                ),
                                IntroWidget(
                                  icon: Icons.qr_code_scanner_outlined,
                                  text: AppLocalizations.of(context)!
                                      .onboard_step_2,
                                ),
                                IntroWidget(
                                  icon: Icons.send_rounded,
                                  text: AppLocalizations.of(context)!
                                      .onboard_step_3,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseInitalizationClass.eventTracker(
                              'tutorial_begin', {'tutorial_begin': 'true'});

                          Navigator.of(context)
                              .pushReplacement(PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 1000),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    HomeScreen(
                              socketService: null,
                              isIntentSharing: false,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var fadeTween = Tween(begin: 0.0, end: 1.0)
                                  .animate(animation);
                              var slideTween = Tween(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero)
                                  .animate(animation);

                              return FadeTransition(
                                opacity: fadeTween,
                                child: SlideTransition(
                                  position: slideTween,
                                  child: child,
                                ),
                              );
                            },
                          ));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: screenHeight / 16,
                          width: screenWidth / 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.onboard_button_text,
                              style: ThemeConstant.smallTextSizeDarkFontWidth,
                            ),
                          ),
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
    );
  }
}

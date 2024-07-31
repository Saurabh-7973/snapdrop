import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';
import '../utils/firebase_initalization_class.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_text.dart';
import '../widgets/intro_widget.dart';
import 'home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _toggleButton() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward().whenComplete(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                socketService: null,
                isIntentSharing: false,
              ),
            ),
          );
        });
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      onPopInvoked: (didPop) => Navigator.pop(context),
      child: Container(
        color: ThemeConstant.primaryAppColor,
        child: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: Container(
            decoration: ThemeConstant.appBackgroundGradient,
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
                        padding: const EdgeInsets.only(left: 34.0),
                        child: SizedBox(
                          width: screenWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IntroWidget(
                                icon: Icons.image_outlined,
                                text: AppLocalizations.of(context)!
                                    .onboard_step_1,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              IntroWidget(
                                icon: Icons.qr_code_scanner_outlined,
                                text: AppLocalizations.of(context)!
                                    .onboard_step_2,
                              ),
                              const SizedBox(
                                height: 50,
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
                    Center(
                      child: Container(
                        width: screenWidth / 3, // Set the desired static width
                        height:
                            screenHeight / 16, // Set the desired static height
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white
                            ], // Static colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(30), // Static border radius
                        ),
                        child: SizedBox(
                          width: screenWidth, // Set the desired static width
                          height: screenHeight /
                              16, // Set the desired static height
                          child: GestureDetector(
                            onTap: _toggleButton, // Your onTap action
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(
                                    30), // Static border radius
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .language_selection_continue,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

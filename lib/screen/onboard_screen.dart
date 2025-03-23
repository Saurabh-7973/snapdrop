import 'dart:math';
import 'dart:ui';

import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/firebase_initalization_class.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/floating_triangles.dart';
import '../wigets/hero_text.dart';
import '../wigets/intro_widget.dart';

// Flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final List<Map<String, String>> _languages = [
    {"code": "en", "name": "English", "flag": "🇬🇧"},
    {"code": "es", "name": "Español", "flag": "🇪🇸"},
    {"code": "zh", "name": "中文", "flag": "🇨🇳"},
    {"code": "hi", "name": "हिन्दी", "flag": "🇮🇳"},
    {"code": "fr", "name": "Français", "flag": "🇫🇷"},
    {"code": "ar", "name": "العربية", "flag": "🇸🇦"},
  ];

  String _selectedLanguage = "en";

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  /// ✅ Load saved language from SharedPreferences
  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? "en";
    });
  }

  /// ✅ Change language and update UI instantly
  void _changeLanguage(String langCode) async {
    MyApp.setLocale(context, Locale(langCode)); // Change app language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', langCode);
    setState(() {
      _selectedLanguage = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: ThemeConstant.primaryAppColor,
      child: SafeArea(
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
                      Stack(
                        children: [
                          const AppBarWidget(),
                          _buildLanguageSelector(),
                        ],
                      ),

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
                              spacing: 20,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// ✅ **Get Started Button**
                      GestureDetector(
                        onTap: () {
                          FirebaseInitalizationClass.eventTracker(
                              'tutorial_begin', {'tutorial_begin': 'true'});

                          Navigator.of(context)
                              .pushReplacement(PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    HomeScreen(
                              socketService: null,
                              isIntentSharing: false,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var slideTween = Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation);

                              var fadeTween = Tween<double>(
                                begin: 0.3,
                                end: 1.0,
                              ).animate(animation);

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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: -5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.onboard_button_text,
                              style: ThemeConstant.smallTextSizeDarkFontWidth,
                            ),
                          ),
                        ),
                      )
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

  Widget _buildLanguageSelector() {
    return Positioned(
      top: 8,
      right: 15,
      child: GestureDetector(
        onTap: _showLanguageModal,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), // Dark overlay to blend in
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🌐 **Glowing Globe Icon (Using Stack)**
              Stack(
                alignment: Alignment.center,
                children: [
                  /// **Blurred White Glow Behind the Icon**
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  /// **Actual Icon**
                  const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(width: 6),

              /// ✨ **Glowing Text Effect**
              Text(
                _languages.firstWhere(
                    (lang) => lang["code"] == _selectedLanguage)["name"]!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95), // Brighter text
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal() {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Frosted Glass
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🌍 **Header with Divider**
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        const Text(
                          "🌍 Select Language",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 50,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// 🌟 **Language List**
                  Column(
                    children: _languages.map((lang) {
                      bool isSelected = lang["code"] == _selectedLanguage;
                      return GestureDetector(
                        onTap: () {
                          _changeLanguage(lang["code"]!);
                          Navigator.pop(context); // Close modal
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ThemeConstant.primaryAppColor.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? ThemeConstant.primaryAppColor
                                  : Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: ThemeConstant.primaryAppColor
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Text(lang["flag"]!,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lang["name"]!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),

                  /// ❌ **Cancel Button (Stylish)**
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: screenHeight / 16,
                      width: screenWidth / 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: -5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style:
                              ThemeConstant.smallTextSizeDarkFontWidth.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

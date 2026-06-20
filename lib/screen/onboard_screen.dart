import 'dart:ui';

import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../floating_squares.dart';
import '../main.dart';
import '../utils/firebase_initalization_class.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/intro_widget.dart';
import '../l10n/app_localizations.dart';

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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const FloatingSquares(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 6, 26, 16),
                child: Column(
                  children: [
                    const AppBarWidget(),
                    const SizedBox(height: 30),
                    Text(
                      '${AppLocalizations.of(context)!.onboard_hero_text_1}\n${AppLocalizations.of(context)!.onboard_hero_text_2}',
                      textAlign: TextAlign.center,
                      style: ThemeConstant.titleLarge
                          .copyWith(fontSize: 31, height: 1.12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.onboard_subline,
                      textAlign: TextAlign.center,
                      style: ThemeConstant.subtitleMuted,
                    ),
                    const SizedBox(height: 40),
                    IntroWidget(
                      icon: Icons.image_outlined,
                      text: AppLocalizations.of(context)!.onboard_step_1,
                    ),
                    const SizedBox(height: 22),
                    IntroWidget(
                      icon: Icons.qr_code_scanner_rounded,
                      text: AppLocalizations.of(context)!.onboard_step_2,
                    ),
                    const SizedBox(height: 22),
                    IntroWidget(
                      icon: Icons.brush_rounded,
                      text: AppLocalizations.of(context)!.onboard_step_3,
                    ),
                    const Spacer(),
                    _languageChip(),
                    const SizedBox(height: 18),
                    _getStartedButton(context),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageChip() {
    final name = _languages
        .firstWhere((lang) => lang["code"] == _selectedLanguage)["name"]!;
    return GestureDetector(
      onTap: _showLanguageModal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Color(0xFFCFD6D2), size: 15),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFCFD6D2),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFCFD6D2), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _getStartedButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FirebaseInitalizationClass.eventTracker(
            'tutorial_begin', {'tutorial_begin': 'true'});
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
            socketService: null,
            isIntentSharing: false,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);
            final fadeTween =
                Tween<double>(begin: 0.3, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: fadeTween,
              child: SlideTransition(position: slideTween, child: child),
            );
          },
        ));
      },
      child: Container(
        width: 260,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.onboard_button_text,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: ThemeConstant.buttonInk,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 9),
            const Icon(Icons.arrow_forward_rounded,
                color: ThemeConstant.buttonInk, size: 18),
          ],
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
                color: ThemeConstant.surface.withValues(alpha: 0.96),
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
                            color: Colors.white.withValues(alpha: 0.3),
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
                                ? ThemeConstant.accentGreen
                                    .withValues(alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? ThemeConstant.accentGreen
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
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
                              if (isSelected)
                                const Icon(Icons.check_rounded,
                                    color: ThemeConstant.accentGreen, size: 20),
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
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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

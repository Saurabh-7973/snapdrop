import 'dart:ui';

import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../floating_squares.dart';
import '../main.dart';
import '../services/selected_language.dart';
import '../utils/firebase_initalization_class.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/step_badge.dart';
import '../l10n/app_localizations.dart';

import 'home_screen.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  // Must match the app's supportedLocales (main.appLocales): en/es/zh/hi/ar/pt.
  // (Previously listed fr, which isn't supported, and omitted pt.)
  final List<Map<String, String>> _languages = [
    {"code": "en", "name": "English", "flag": "🇬🇧"},
    {"code": "es", "name": "Español", "flag": "🇪🇸"},
    {"code": "zh", "name": "中文", "flag": "🇨🇳"},
    {"code": "hi", "name": "हिन्दी", "flag": "🇮🇳"},
    {"code": "ar", "name": "العربية", "flag": "🇸🇦"},
    {"code": "pt", "name": "Português", "flag": "🇵🇹"},
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

  /// ✅ Change language and update UI instantly + persist across launches.
  void _changeLanguage(String langCode) async {
    MyApp.setLocale(context, Locale(langCode)); // instant rebuild
    final prefs = await SharedPreferences.getInstance();
    // Persist in the SAME form main._loadLocale restores ('selectedLanguageIndex',
    // an index into appLocales). The string key alone was never read back.
    final idx = appLocales.indexWhere((l) => l.languageCode == langCode);
    if (idx >= 0) {
      SelectedLanguage.selectedLanguageIndex = idx;
      await prefs.setInt('selectedLanguageIndex', idx);
    }
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 26),
                            Text(
                              AppLocalizations.of(context)!.onboarding_title,
                              textAlign: TextAlign.center,
                              style: ThemeConstant.titleLarge
                                  .copyWith(fontSize: 27, height: 1.16),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              AppLocalizations.of(context)!.onboarding_subtitle,
                              textAlign: TextAlign.center,
                              style: ThemeConstant.subtitleMuted
                                  .copyWith(fontSize: 14.5, height: 1.5),
                            ),
                            const SizedBox(height: 30),
                            _stepCard(
                              1,
                              AppLocalizations.of(context)!.onboarding_step1_title,
                              AppLocalizations.of(context)!.onboarding_step1_desc,
                            ),
                            const SizedBox(height: 11),
                            _stepCard(
                              2,
                              AppLocalizations.of(context)!.onboarding_step2_title,
                              AppLocalizations.of(context)!.onboarding_step2_desc,
                            ),
                            const SizedBox(height: 11),
                            _stepCard(
                              3,
                              AppLocalizations.of(context)!.onboarding_step3_title,
                              AppLocalizations.of(context)!.onboarding_step3_desc,
                            ),
                            const SizedBox(height: 16),
                            _note(AppLocalizations.of(context)!.onboarding_note),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _footer(context),
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

  /// One numbered onboarding step: badge + title + description in a hairline
  /// card. Mirrors under RTL (Row uses start/end, text aligned to start).
  Widget _stepCard(int number, String title, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepBadge(number),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF93A79C),
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clarifying note under the steps (info icon + text). Leading icon sits on
  /// the reading-start edge in both LTR and RTL.
  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded,
                size: 14, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF93A79C),
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer row: language chip + Get Started pill (fills remaining width).
  Widget _footer(BuildContext context) {
    return Row(
      children: [
        _languageChip(),
        const SizedBox(width: 12),
        Expanded(child: _getStartedButton(context)),
      ],
    );
  }

  Widget _languageChip() {
    final name = _languages
        .firstWhere((lang) => lang["code"] == _selectedLanguage)["name"]!;
    return GestureDetector(
      onTap: _showLanguageModal,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.onboarding_cta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: ThemeConstant.buttonInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 9),
            // Direction-aware: arrow points in the reading direction (flips RTL).
            Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: const Icon(Icons.arrow_forward_rounded,
                  color: ThemeConstant.buttonInk, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal() {
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
                  /// Grab handle + title
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 4, bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Text(
                    "Select Language",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 18),

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
                    child: Container(
                      height: 48,
                      width: screenWidth / 2.4,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.3),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFFD6DCD8),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

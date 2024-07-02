import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/theme_contants.dart';
import '../main.dart';
import '../services/selected_language.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_text.dart';
import 'onboard_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import generated AppLocalizations

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<Map<String, dynamic>> languages = [
    {'title': 'English', 'code': 'en', 'locale': const Locale('en')},
    {'title': 'Español', 'code': 'es', 'locale': const Locale('es')},
    {'title': '中文 - 简体', 'code': 'zh', 'locale': const Locale('zh')},
    {'title': 'हिन्दी', 'code': 'hi', 'locale': const Locale('hi')},
    {'title': 'العربية', 'code': 'ar', 'locale': const Locale('ar')},
    {'title': 'Português', 'code': 'pt', 'locale': const Locale('pt')},
  ];

  // String selectedLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
  }

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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const AppBarWidget(),
                  Expanded(
                    flex: 2,
                    child: HeroText(
                      firstLine: 'Select your',
                      secondLine: 'preferred language',
                      thirdLine: '',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 3,
                        ),
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              index == SelectedLanguage.selectedLanguageIndex;
                          return GestureDetector(
                            onTap: () {
                              SelectedLanguage.selectedLanguageIndex = index;
                              Locale newLocale = languages[index]['locale'];
                              // MyApp.setLocale(
                              //     context, newLocale); // Update the locale
                              setState(
                                  () {}); // Rebuild the widget tree to reflect language change// Rebuild the widget tree to reflect language change
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  if (isSelected)
                                    const BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: isSelected
                                      ? ThemeConstant.primaryAppColor
                                      : Colors.white,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  languages[index]['title']!,
                                  style: isSelected
                                      ? ThemeConstant.smallTextSizeDarkFontWidth
                                      : ThemeConstant
                                          .smallTextSizeWhiteFontWidth,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const OnboardScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(screenWidth / 3, screenHeight / 16),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppLocalizations.of(context)!
                                .language_selection_continue,
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/theme_contants.dart';
import '../floating_squares.dart'; // Importing FloatingSquares
import '../main.dart';
import '../services/selected_language.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hero_text.dart';
import 'onboard_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> languages = [
    {'title': 'English', 'code': 'en', 'locale': const Locale('en')},
    {'title': 'Español', 'code': 'es', 'locale': const Locale('es')},
    {'title': '中文 - 简体', 'code': 'zh', 'locale': const Locale('zh')},
    {'title': 'हिन्दी', 'code': 'hi', 'locale': const Locale('hi')},
    {'title': 'العربية', 'code': 'ar', 'locale': const Locale('ar')},
    {'title': 'Português', 'code': 'pt', 'locale': const Locale('pt')},
  ];

  int? _selectedLanguageIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguageIndex = prefs.getInt('selectedLanguageIndex');
    });
  }

  Future<void> _changeLanguage(int index) async {
    setState(() => _isLoading = true);
    Locale newLocale = languages[index]['locale'];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedLanguageIndex', index);
    await Future.delayed(const Duration(milliseconds: 500));

    MyApp.setLocale(context, newLocale);
    setState(() => _isLoading = false);
  }

  void _onContinue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned.fill(child: FloatingSquares()), // Ensuring full background
        Container(
          color: ThemeConstant.primaryAppColor,
          child: SafeArea(
            child: Container(
              decoration: ThemeConstant.appBackgroundGradient,
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
                          firstLine: AppLocalizations.of(context)!
                              .language_selection_herotext_1,
                          secondLine: AppLocalizations.of(context)!
                              .language_selection_herotext_2,
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
                              bool isSelected = index == _selectedLanguageIndex;

                              return GestureDetector(
                                onTap: () => _changeLanguage(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  transform: isSelected
                                      ? Matrix4.translationValues(0, -5, 0)
                                          .scaled(1.05, 1.05)
                                      : Matrix4.identity(),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ThemeConstant.primaryAppColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: isSelected
                                          ? ThemeConstant.primaryAppColor
                                          : Colors.white.withOpacity(0.5),
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      languages[index]['title']!,
                                      style: ThemeConstant
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
                      Center(
                        child: GestureDetector(
                          onTap: _onContinue,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: screenWidth / 3,
                            height: screenHeight / 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.95),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

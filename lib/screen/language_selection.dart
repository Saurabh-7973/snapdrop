import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/theme_contants.dart';
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
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedLanguageIndex = prefs.getInt('selectedLanguageIndex');
    if (mounted) {
      setState(() {}); // Rebuild to reflect any saved language selection
    }
  }

  void _onContinue() {
    if (mounted) {
      setState(() {
        _isExpanded = true;
      });
    }
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OnboardScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.ltr,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const AppBarWidget(),
                    Expanded(
                      flex: 2,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: _selectedLanguageIndex == null ? 1 : 1.1,
                        child: HeroText(
                          firstLine: AppLocalizations.of(context)!
                              .language_selection_herotext_1,
                          secondLine: AppLocalizations.of(context)!
                              .language_selection_herotext_2,
                          thirdLine: '',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: GridView.builder(
                            key: ValueKey<int?>(_selectedLanguageIndex),
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
                                onTap: () async {
                                  _selectedLanguageIndex = index;
                                  Locale newLocale = languages[index]['locale'];
                                  MyApp.setLocale(context, newLocale);
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setInt(
                                      'selectedLanguageIndex', index);
                                  if (mounted) {
                                    setState(
                                        () {}); // Rebuild the widget tree to reflect language change
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  transform: isSelected
                                      ? Matrix4.translationValues(0, -5, 0)
                                          .scaled(1.05, 1.05)
                                      : Matrix4.identity(),
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
                                          ? ThemeConstant
                                              .smallTextSizeDarkFontWidth
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
                    ),
                    const SizedBox(height: 20),
                    Center(
                      // Ensure the button is centered on the screen
                      child: Container(
                        width: screenWidth / 3, // Set to the desired width
                        height: screenHeight / 16, // Set to the desired height
                        child: GestureDetector(
                          onTap: _onContinue, // Your onTap action
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white
                                ], // Static color
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  30), // Static border radius
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .language_selection_continue,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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

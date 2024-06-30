import 'package:Snapdrop/screen/onboard_screen.dart';
import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/hero_text.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<String> languages = [
    'English',
    'Español',
    '中文 - 简体',
    'हिन्दी',
    'العربية',
    'Português'
  ];

  String selectedLanguage = 'English';

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
                      firstLine: 'Choose a',
                      secondLine: ' Language',
                      thirdLine: "",
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: SizedBox(
                        width: screenWidth,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3,
                          ),
                          itemCount: languages.length,
                          itemBuilder: (context, index) {
                            bool isSelected =
                                languages[index] == selectedLanguage;
                            return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedLanguage = languages[index];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(screenWidth / 2.6, 50),
                                backgroundColor: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected
                                      ? ThemeConstant.primaryAppColor
                                      : Colors.white,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  languages[index],
                                  style: isSelected
                                      ? ThemeConstant.smallTextSizeDarkFontWidth
                                      : ThemeConstant
                                          .smallTextSizeWhiteFontWidth,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => OnboardScreen()),
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
                            'Continue',
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

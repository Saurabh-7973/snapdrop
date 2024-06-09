import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/dropdown_view.dart';
import '../wigets/hero_text.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  SocketService? socketService;
  bool isIntentSharing = false;
  HomeScreen(
      {super.key, required this.socketService, required this.isIntentSharing});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
                    flex: 3,
                    child: HeroText(
                      firstLine:
                          AppLocalizations.of(context)!.home_screen_herotext_1,
                      secondLine:
                          AppLocalizations.of(context)!.home_screen_herotext_2,
                      thirdLine:
                          AppLocalizations.of(context)!.home_screen_herotext_3,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: ShowCaseWidget(
                      blurValue: 1,
                      builder: (context) => DropDownView(
                        socketService: widget.socketService,
                        isIntentSharing: widget.isIntentSharing,
                      ),
                      autoPlayDelay: const Duration(seconds: 3),
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

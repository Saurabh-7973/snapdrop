import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/dropdown_view.dart';
import '../wigets/hero_text.dart';

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
    return SafeArea(
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
                    firstLine: "Select Images",
                    secondLine: "to Continue",
                    thirdLine: "Upto 10 images",
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: ShowCaseWidget(
                    blurValue: 1,
                    builder: Builder(
                      builder: (context) => DropDownView(
                        socketService: widget.socketService,
                        isIntentSharing: widget.isIntentSharing,
                      ),
                    ),
                    autoPlayDelay: const Duration(seconds: 3),
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

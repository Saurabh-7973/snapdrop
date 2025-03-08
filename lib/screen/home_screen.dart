import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/dropdown_view.dart';
import '../wigets/hero_text.dart';
import '../wigets/floating_triangles.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
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
            body: Stack(
              children: [
                const FloatingSquares(),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const AppBarWidget(),
                      Expanded(
                        flex: 3,
                        child: TweenAnimationBuilder<Offset>(
                          tween: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutQuint,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: offset,
                              child: HeroText(
                                firstLine: AppLocalizations.of(context)!
                                    .home_screen_herotext_1,
                                secondLine: AppLocalizations.of(context)!
                                    .home_screen_herotext_2,
                                thirdLine: AppLocalizations.of(context)!
                                    .home_screen_herotext_3,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.85, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: AnimatedOpacity(
                                opacity: scale < 0.85
                                    ? 0.0
                                    : 1.0, // ✅ Prevent low opacity during transition
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOut,
                                child: ShowCaseWidget(
                                  blurValue: 1,
                                  builder: (context) => DropDownView(
                                    socketService: widget.socketService,
                                    isIntentSharing: widget.isIntentSharing,
                                  ),
                                  autoPlayDelay: const Duration(seconds: 3),
                                ),
                              ),
                            );
                          },
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
    );
  }
}

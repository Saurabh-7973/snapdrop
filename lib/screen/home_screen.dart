import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../floating_squares.dart';
import '../services/socket_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/dropdown_view.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final SocketService? socketService;
  final bool isIntentSharing;
  const HomeScreen(
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
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBarWidget(),
                    const SizedBox(height: 14),
                    Text(
                      '${AppLocalizations.of(context)!.home_screen_herotext_1}\n${AppLocalizations.of(context)!.home_screen_herotext_2}',
                      style: ThemeConstant.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.home_screen_herotext_3,
                      style: ThemeConstant.subtitleMuted,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0.03),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../floating_squares.dart';
import '../services/session_controller.dart';
import '../services/socket_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/dropdown_view.dart';
import 'qr_screen.dart';
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
    return _HomeBody(
      socketService: widget.socketService,
      isIntentSharing: widget.isIntentSharing,
    );
  }
}

/// Connection indicator (top of the picker content). Green dot + "Connected"
/// with the short room id when live; muted "Not connected — scan to connect"
/// otherwise (tapping it opens the QR screen). Reacts to the session.
class _ConnectionIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionController,
      builder: (context, _) {
        final connected = sessionController.isConnected;
        final l = AppLocalizations.of(context)!;
        return GestureDetector(
          onTap: connected
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QRScreen(isIntentSharing: false),
                    ),
                  ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected
                      ? const Color(0xFF46C886)
                      : ThemeConstant.muted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                connected
                    ? '${l.connection_connected} · ${sessionController.shortRoomId}'
                    : l.connection_not_connected,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: connected
                      ? const Color(0xFF8FA89A)
                      : ThemeConstant.muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeBody extends StatefulWidget {
  final SocketService? socketService;
  final bool isIntentSharing;
  const _HomeBody({required this.socketService, required this.isIntentSharing});
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
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
                    const SizedBox(height: 12),
                    _ConnectionIndicator(),
                    const SizedBox(height: 12),
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

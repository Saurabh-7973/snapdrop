import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../floating_squares.dart';
import '../services/session_controller.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';

import 'home_screen.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_button.dart';
import '../widgets/connect.dart';
import '../widgets/intent_file_displayer.dart';
import '../widgets/room_displayer.dart';
import '../widgets/selected_images.dart';

class SendFile extends StatefulWidget {
  final String roomId;
  final List<AssetEntity>? selectedAssetList;
  final SocketService? socketService;
  final bool isIntentSharing;
  final List<SharedMediaFile>? listOfMedia;
  final int imageCount;

  const SendFile({
    super.key,
    this.selectedAssetList,
    this.listOfMedia,
    required this.imageCount,
    required this.isIntentSharing,
    required this.roomId,
    required this.socketService,
  });

  @override
  State<SendFile> createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  bool _completed = false;

  void _onCompleted() {
    if (mounted) setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = _completed
        ? '${l.send_screen_complete_1}\n${l.send_screen_complete_2}'
        : '${l.send_screen_transferring} ${widget.imageCount}\n${l.send_screen_hero_text_2}';

    return ListenableBuilder(
      listenable: sessionController,
      builder: (context, _) => AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const Positioned.fill(child: FloatingSquares()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Column(
                  children: [
                    const AppBarWidget(),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: ThemeConstant.titleLarge
                          .copyWith(fontSize: 29, height: 1.13),
                    ),
                    const SizedBox(height: 22),
                    RoomDisplayer(
                      senderId: widget.socketService!.userId!,
                      receiverId: widget.roomId,
                      senderMessage: l.send_screen_your_id,
                      receiverMessage: l.send_screen_connected_to,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: widget.isIntentSharing == true
                          ? IntentFileDisplayer(
                              isIntentSharing: true,
                              listOfMedia: widget.listOfMedia,
                              connectDisplayer: false,
                            )
                          : SelectedImagesViewer(
                              selectedAssetList: widget.selectedAssetList!,
                            ),
                    ),
                    const SizedBox(height: 12),
                    widget.isIntentSharing == true
                        ? SendButton(
                            socketService: widget.socketService,
                            listOfMedia: widget.listOfMedia,
                            isIntentSharing: widget.isIntentSharing,
                            onTransferCompleted: _onCompleted,
                          )
                        : ShowCaseWidget(
                            blurValue: 1,
                            builder: (context) => SendButton(
                              socketService: widget.socketService,
                              selectedAssetList: widget.selectedAssetList!,
                              isIntentSharing: widget.isIntentSharing,
                              onTransferCompleted: _onCompleted,
                            ),
                            autoPlayDelay: const Duration(seconds: 3),
                          ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            if (sessionController.status == SessionStatus.lost)
              _lostOverlay(context, l),
          ],
        ),
      ),
      ),
    );
  }

  /// §4 negative path: socket dropped (after the one silent reconnect failed).
  /// Dark on-brand overlay with a Reconnect action (re-scan to re-pair).
  Widget _lostOverlay(BuildContext context, AppLocalizations l) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC060C09),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: ThemeConstant.softGreen, size: 40),
                const SizedBox(height: 16),
                Text(l.connection_lost,
                    style: ThemeConstant.titleLarge.copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Text(l.connection_lost_body,
                    textAlign: TextAlign.center,
                    style: ThemeConstant.subtitleMuted),
                const SizedBox(height: 22),
                AppButton(
                  label: l.reconnect_button,
                  icon: Icons.refresh_rounded,
                  width: 220,
                  onTap: () async {
                    await sessionController.disconnect();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                            socketService: null, isIntentSharing: false),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

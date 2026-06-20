import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../floating_squares.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';

import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
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

    return AppBackground(
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
          ],
        ),
      ),
    );
  }
}

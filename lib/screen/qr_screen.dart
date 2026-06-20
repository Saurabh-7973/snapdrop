import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../l10n/app_localizations.dart';

import '../floating_squares.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_dialog.dart';
import '../widgets/qr_scanner.dart';

class QRScreen extends StatefulWidget {
  final List<AssetEntity>? selectedAssetList;
  final bool isIntentSharing;
  final List<SharedMediaFile>? listOfMedia;

  const QRScreen({
    super.key,
    this.selectedAssetList,
    required this.isIntentSharing,
    this.listOfMedia,
  });

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Future<bool> _onWillPop() async {
    // Unified Exit confirmation (snapdrop_dialogs_inlanguage.html). Solid
    // primary = Cancel (stay, the easy action); ghost = Exit (leave).
    final stay = await showAppDialog(
      context: context,
      icon: Icons.logout_rounded,
      title: AppLocalizations.of(context)!.exit_dialog_title,
      body: AppLocalizations.of(context)!.exit_dialog_body,
      primaryLabel: AppLocalizations.of(context)!.exit_dialog_cancel,
      secondaryLabel: AppLocalizations.of(context)!.exit_dialog_exit,
    );
    return stay == false; // leave only when Exit (ghost) tapped
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              const Positioned.fill(child: FloatingSquares()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                  child: Column(
                    children: [
                      AppBarWidget(
                        showBackButton: true,
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '${AppLocalizations.of(context)!.qr_screen_herotext_1}\n${AppLocalizations.of(context)!.qr_screen_herotext_2}',
                        textAlign: TextAlign.center,
                        style: ThemeConstant.titleLarge.copyWith(height: 1.12),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 26, bottom: 20),
                            child: widget.isIntentSharing
                                ? QRScanner(
                                    isIntentSharing: widget.isIntentSharing,
                                    listOfMedia: widget.listOfMedia,
                                  )
                                : ShowCaseWidget(
                                    blurValue: 1,
                                    builder: (context) => QRScanner(
                                      isIntentSharing: widget.isIntentSharing,
                                      selectedAssetList:
                                          widget.selectedAssetList!,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

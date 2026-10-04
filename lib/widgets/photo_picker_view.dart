import 'dart:io';

import 'package:Snapdrop/services/check_internet_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/global_showcase_key.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../screen/send_file_screen.dart';
import '../services/file_image.dart';
import '../services/session_controller.dart';
import '../services/first_time_login.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';
import 'app_button.dart';
import '../utils/firebase_initalization_class.dart';

/// Home body: photos come from the system Photo Picker, so the app holds no
/// media permission at all. (The old in-app gallery grid needed
/// READ_MEDIA_IMAGES, which Play's photo & video permissions policy rejected.)
/// The picked photos show in a grid; tap × to drop one, "Add more" to pick
/// again, and the send bar carries on exactly as before.
class PhotoPickerView extends StatefulWidget {
  final SocketService? socketService;
  final bool isIntentSharing;
  const PhotoPickerView(
      {super.key, this.socketService, required this.isIntentSharing});

  @override
  State<PhotoPickerView> createState() => _PhotoPickerViewState();
}

class _PhotoPickerViewState extends State<PhotoPickerView> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _picked = [];
  bool _picking = false;

  /// Vertical room reserved under the grid for the send bar + its scrim.
  static const double _sendBarSpace = 108;

  @override
  void initState() {
    super.initState();
    _recoverLostPick();

    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ShowCaseWidget.of(context)
              .startShowCase([GlobalShowcaseKeys.showcaseOne]);
        });
      }
    });
  }

  /// Android can kill the app while the picker is open (low memory). The
  /// result is then delivered on the next launch instead of to the await.
  Future<void> _recoverLostPick() async {
    if (!Platform.isAndroid) return;
    try {
      final lost = await _picker.retrieveLostData();
      final files = lost.files;
      if (lost.isEmpty || files == null || files.isEmpty || !mounted) return;
      setState(() => _picked = [..._picked, ...files]);
    } catch (e, s) {
      FirebaseInitalizationClass.recordNonFatal(e, s,
          reason: 'picker lost-data recovery failed');
    }
  }

  Future<void> _pick() async {
    if (_picking) return;
    _picking = true;
    try {
      final files = await _picker.pickMultiImage(requestFullMetadata: false);
      if (!mounted || files.isEmpty) return;
      setState(() => _picked = [..._picked, ...files]);
      FirebaseInitalizationClass.eventTracker(
          'photos_picked', {'image_count': files.length});
    } catch (e, s) {
      FirebaseInitalizationClass.recordNonFatal(e, s,
          reason: 'photo picker failed');
    } finally {
      _picking = false;
    }
  }

  void _remove(XFile file) {
    HapticFeedback.selectionClick();
    setState(() => _picked = _picked.where((f) => f != file).toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_picked.isEmpty) return _emptyState(context);

    final l = AppLocalizations.of(context)!;
    return Stack(children: [
      GridView.builder(
        itemCount: _picked.length + 1,
        // Last row must clear the send bar + the gesture nav area.
        padding: EdgeInsets.only(
            bottom: _sendBarSpace + MediaQuery.of(context).padding.bottom),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: (2 / 3)),
        itemBuilder: (context, index) {
          if (index == _picked.length) return _addMoreTile(l);
          final file = _picked[index];
          return _PhotoTile(
            key: ValueKey(file.path),
            file: file,
            removeLabel: l.photo_remove,
            onRemove: () => _remove(file),
          );
        },
      ),
      // Bottom scrim: the grid scrolls under it instead of being chopped flat
      // at the screen edge, and it gives the send bar something to sit on.
      IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: _sendBarSpace + MediaQuery.of(context).padding.bottom,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ),
      ),
      _sendBar(context),
    ]);
  }

  Widget _addMoreTile(AppLocalizations l) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _pick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: ThemeConstant.softGreen.withValues(alpha: 0.85),
                size: 28),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                l.pick_more_button,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: ThemeConstant.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nothing picked yet: one framed, tappable panel with one clear action.
  /// This is the tour's only target. The hero above already says "select
  /// images", so no second heading here.
  Widget _emptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      // Clear the gesture nav area, plus a little air under the panel.
      padding:
          EdgeInsets.only(bottom: 20 + MediaQuery.of(context).padding.bottom),
      // The home column is start-aligned, so this child gets a loose width;
      // without the explicit fill the panel shrink-wraps and hugs the left.
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.white.withValues(alpha: 0.025),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _pick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: ThemeConstant.accentGreen.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: ThemeConstant.softGreen
                              .withValues(alpha: 0.18)),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: ThemeConstant.softGreen.withValues(alpha: 0.85),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      l.picker_empty_body,
                      textAlign: TextAlign.center,
                      style: ThemeConstant.subtitleMuted
                          .copyWith(fontSize: 15, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Showcase(
                    key: GlobalShowcaseKeys.showcaseOne,
                    targetBorderRadius: BorderRadius.circular(26),
                    tooltipBackgroundColor: const Color(0xff161616),
                    textColor: ThemeConstant.whiteColor,
                    title: l.showcase_one_title,
                    description: l.showcase_one_subtitle,
                    child: AppButton(
                      label: l.pick_photos_button,
                      icon: Icons.add_photo_alternate_outlined,
                      width: 240,
                      onTap: _pick,
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

  /// Docked action bar over the grid: selection count, then Connect (or Send
  /// on a live session).
  Widget _sendBar(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final count = _picked.length;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: Material(
          color: Colors.white,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.45),
          child: InkWell(
            onTap: () => _continue(context),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: ThemeConstant.base.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: ThemeConstant.buttonInk,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      sessionController.isConnected
                          ? l.send_button
                          : l.home_screen_button,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeConstant.smallTextSizeDarkFontWidth,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Points the reading way: matchTextDirection on the icon
                  // mirrors it under RTL, so no manual flip.
                  const Icon(Icons.arrow_forward_rounded,
                      color: ThemeConstant.buttonInk, size: 21),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Connect (or Send, on a live session) — network check, then the per-image
  /// relay ceiling.
  Future<void> _continue(BuildContext context) async {
    final selected = List<XFile>.of(_picked);
    if (selected.isEmpty) return;
    HapticFeedback.lightImpact();

    final l = AppLocalizations.of(context)!;
    final hasNetwork = await CheckInternetConnectivity.hasNetwork();
    if (!context.mounted) return;
    if (!hasNetwork) {
      _snack(context, l.app_conditions_internet_connection);
      return;
    }

    // The relay caps each image (one emit) at 10 MB — the limit is per image,
    // not total. Block only if the largest exceeds the cap.
    final size = await FileImageServices().getMaxImageSize(selected);
    if (!context.mounted) return;
    if (size >= FileImageServices.maxImageSizeMb) {
      _snack(
        context,
        l.size_limit_message(
          FileImageServices.maxImageSizeMb.toStringAsFixed(0),
          size.toStringAsFixed(2),
        ),
      );
      return;
    }

    // Live session -> send straight over the same socket (no QR).
    // Otherwise -> Connect (scan first).
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => sessionController.isConnected
            ? SendFile(
                selectedAssetList: selected,
                isIntentSharing: false,
                imageCount: selected.length,
                roomId: sessionController.roomId ?? '',
                socketService: sessionController.socket,
              )
            : QRScreen(
                selectedAssetList: selected,
                isIntentSharing: widget.isIntentSharing,
              ),
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// One picked photo: thumbnail decoded at tile size, size label, × to remove.
class _PhotoTile extends StatelessWidget {
  final XFile file;
  final String removeLabel;
  final VoidCallback onRemove;
  const _PhotoTile({
    super.key,
    required this.file,
    required this.removeLabel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: ThemeConstant.surface,
              borderRadius: BorderRadius.all(Radius.circular(11)),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(
              File(file.path),
              fit: BoxFit.cover,
              // Decode at tile size, not the photo's full resolution.
              cacheWidth: 250,
              // One unreadable file is a blank tile, not a crash.
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Semantics(
              button: true,
              label: removeLabel,
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 7),
              child: FutureBuilder<String>(
                future: FileImageServices().getImageSize(file),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  // Force LTR for the measurement: in an RTL locale the bidi
                  // algorithm renders "0.32 MB" as "MB 0.32".
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      "${snap.data} MB",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                              blurRadius: 3,
                              color: Color(0xB3000000),
                              offset: Offset(0, 1))
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:Snapdrop/services/check_internet_connectivity.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/global_showcase_key.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../screen/send_file_screen.dart';
import '../services/file_image.dart';
import '../services/session_controller.dart';
import '../services/first_time_login.dart';
import '../services/media_provider.dart';
import '../services/permission_provider.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';
import 'app_dialog.dart';
import '../utils/firebase_initalization_class.dart';

// P2: holds services + a ScrollController as widget fields and mutates
// isIntentSharing in initState — should move into State. Deferred (behavior-sensitive).
// ignore: must_be_immutable
class DropDownView extends StatefulWidget {
  SocketService? socketService;
  bool isIntentSharing;
  DropDownView({super.key, this.socketService, required this.isIntentSharing});

  final PermissionProviderServices _permissionProviderServices =
      PermissionProviderServices();
  final MediaProviderServices _mediaProviderServices = MediaProviderServices();

  final scrollController = ScrollController();

  @override
  State<DropDownView> createState() => _DropDownViewState();
}

class _DropDownViewState extends State<DropDownView> {
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  AssetPathEntity? selectedAlbum;
  // Selection held as an id-set in a ValueNotifier so a tap rebuilds only the
  // tiles whose membership flips (+ the send bar) — not the whole grid.
  final ValueNotifier<Set<String>> _selectedIds = ValueNotifier<Set<String>>({});
  final Map<String, AssetEntity> _assetById = {};
  // Paged album loading.
  int _page = 0;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool hasAll = false;
  bool hasNoData = false;
  // Assets (not just albums) have come back for the selected album.
  bool _assetsLoaded = false;

  /// Vertical room reserved under the grid for the send bar + its scrim.
  static const double _sendBarSpace = 108;

  TextEditingController searchController = TextEditingController();
  List<AssetPathEntity> filteredAlbumList = [];
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    initialMethod(hasAll);
    super.initState();
    widget.scrollController.addListener(_onScroll);

    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context).startShowCase([
                  GlobalShowcaseKeys.showcaseOne,
                  GlobalShowcaseKeys.showcaseTwo,
                  // showcaseThree removed: no widget targets that key, so it was
                  // a dangling third step in the first-run coach-mark sequence.
                ]));
      }
    });
    widget.isIntentSharing = false;
    // Listen to the focus changes
    searchFocusNode.addListener(() {
      setState(() {}); // Rebuild to update height when focus changes
    });
  }

  /// photo_manager can return an album with an empty [name] (e.g. a single
  /// unnamed image bucket on Android 13+). Fall back to a readable label so
  /// the dropdown never renders a blank row.
  String albumLabel(AssetPathEntity album) {
    if (album.name.trim().isNotEmpty) return album.name;
    return album.isAll ? 'Recent' : 'All Photos';
  }

  void filterAlbums() {
    if (mounted) {
      setState(() {
        filteredAlbumList = albumList
            .where((album) => albumLabel(album)
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      });

      // ✅ Force dropdown to rebuild itself
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    widget.scrollController.dispose();
    searchFocusNode.dispose();
    _selectedIds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        albumList.isEmpty == true
            ? hasNoData == true
                ? const SizedBox.shrink()
                : const Column(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  )
            : hasNoData == true
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 50,
                    child: Showcase(
                      targetPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      // Match the dropdown button's own corner radius (8).
                      targetBorderRadius: BorderRadius.circular(8),
                      key: GlobalShowcaseKeys.showcaseOne,
                      tooltipBackgroundColor: const Color(0xff161616),
                      textColor: ThemeConstant.whiteColor,
                      title: AppLocalizations.of(context)!.showcase_one_title,
                      description:
                          AppLocalizations.of(context)!.showcase_one_subtitle,
                      onBarrierClick: () {},
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<AssetPathEntity>(
                          key: ValueKey(filteredAlbumList.length),
                          isExpanded: true,
                          value: filteredAlbumList.isNotEmpty
                              ? selectedAlbum
                              : null,
                          customButton: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        selectedAlbum != null
                                            ? albumLabel(selectedAlbum!)
                                            : '',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white,
                                        size: 18),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!
                                    .home_album_view_all,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: ThemeConstant.accentGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          barrierColor: Colors.transparent,
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: searchFocusNode.hasFocus
                                ? MediaQuery.of(context).size.height * 0.25
                                : MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              color: ThemeConstant.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            // Fill the padded column exactly. A fixed
                            // screenWidth/1.075 was wider than the content
                            // column, so the album name and "View all" sat off
                            // the grid's left/right edges.
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: filteredAlbumList.isNotEmpty
                              ? filteredAlbumList
                                  .map<DropdownMenuItem<AssetPathEntity>>(
                                      (album) {
                                  bool isSelected = selectedAlbum == album;
                                  return DropdownMenuItem<AssetPathEntity>(
                                    value: album,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? ThemeConstant.accentGreen
                                                .withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              albumLabel(album),
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : ThemeConstant.muted,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_rounded,
                                              color: ThemeConstant.accentGreen,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem<AssetPathEntity>(
                                    value: null,
                                    enabled: false,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .album_search_empty,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: ThemeConstant.muted,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                          onChanged: (AssetPathEntity? album) {
                            if (filteredAlbumList.isEmpty) return;
                            if (mounted) {
                              setState(() {
                                selectedAlbum = album;
                                // Back to the skeleton until the new album's
                                // assets arrive — never to the empty state.
                                _assetsLoaded = false;
                                assetList = [];
                              });
                            }
                            FocusScope.of(context).unfocus();
                            if (selectedAlbum != null) {
                              _resetAndLoad(selectedAlbum!);
                            }
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return albumList
                                .map<Widget>((AssetPathEntity album) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    albumLabel(album),
                                    overflow: TextOverflow.ellipsis,
                                    style: ThemeConstant.smallTextSizeLight
                                        .copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: searchController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                              child: TextFormField(
                                controller: searchController,
                                focusNode: searchFocusNode,
                                cursorColor: ThemeConstant.accentGreen,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 14.5,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor:
                                      Colors.white.withValues(alpha: 0.05),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: ThemeConstant.muted, size: 19),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 38, minHeight: 0),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  hintText: AppLocalizations.of(context)!
                                      .album_search_hint,
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: ThemeConstant.muted,
                                    fontSize: 14.5,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: ThemeConstant.accentGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
        SizedBox(
          height: 10,
        ),
        // Empty state only once the album's assets have actually been queried.
        // Keying it off hasDataLoaded (set as soon as the ALBUM list arrived)
        // flashed "No images here yet" for a frame on every launch and every
        // album switch — the confusing empty state testers hit.
        (hasNoData == true || (_assetsLoaded && assetList.isEmpty))
            ? _emptyState(context)
            : _assetsLoaded
                ? Expanded(
                    child: Stack(children: [
                      GridView.builder(
                          controller: widget.scrollController,
                          itemCount: assetList.length,
                          // Last row must clear the send bar + the gesture nav
                          // area; without it the grid ran under both and the
                          // bottom row was sliced mid-tile.
                          padding: EdgeInsets.only(
                              bottom: _sendBarSpace +
                                  MediaQuery.of(context).padding.bottom),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: (2 / 3)),
                          itemBuilder: (context, index) {
                            final asset = assetList[index];
                            final tile = _PhotoTile(
                              asset: asset,
                              selection: _selectedIds,
                              onTap: () => _toggle(asset),
                            );
                            if (index != 0) return tile;
                            return Showcase(
                              key: GlobalShowcaseKeys.showcaseTwo,
                              targetBorderRadius: BorderRadius.circular(11),
                              tooltipBackgroundColor: const Color(0xff161616),
                              textColor: ThemeConstant.whiteColor,
                              title:
                                  AppLocalizations.of(context)!.showcase_two_title,
                              description: AppLocalizations.of(context)!
                                  .showcase_two_subtitle,
                              onBarrierClick: () {},
                              child: tile,
                            );
                          }),
                      // Bottom scrim: the grid scrolls under it instead of being
                      // chopped flat at the screen edge (the "tearing" report),
                      // and it gives the send bar something to sit on.
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: _sendBarSpace +
                                MediaQuery.of(context).padding.bottom,
                            // Black, not base green: AppBackground's layer 4
                            // fades to black down here, so a green scrim would
                            // read as a band instead of a continuation.
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
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: _selectedIds,
                        builder: (context, sel, _) => _sendBar(context, sel),
                      ),
                    ]),
                  )
                : const _SkeletonGrid()

        // : const Expanded(
        //     child: Center(
        //         child: CircularProgressIndicator(
        //       color: ThemeConstant.whiteColor,
        //     )),
        //   )
      ],
    );
  }

  /// Docked action bar over the grid: selection count on the left, Connect/Send
  /// on the right, full content width. It used to be a half-width pill floating
  /// in a transparent 120dp band — a big target, but detached from the grid and
  /// easy to miss on first use (tester report). Now it reads as one bar sitting
  /// directly under the photos, and it says how many are selected.
  Widget _sendBar(BuildContext context, Set<String> selection) {
    final l = AppLocalizations.of(context)!;
    final count = selection.length;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: count == 0 ? const Offset(0, 1.4) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: count == 0 ? 0 : 1,
            child: Material(
              color: Colors.white,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.45),
              child: InkWell(
                onTap: count == 0 ? null : () => _continue(context),
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
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
                      // Points the reading way, so it mirrors under RTL.
                      Transform.flip(
                        flipX: Directionality.of(context) == TextDirection.rtl,
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: ThemeConstant.buttonInk, size: 21),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Connect (or Send, on a live session) — same checks as before: network,
  /// then the per-image relay ceiling.
  Future<void> _continue(BuildContext context) async {
    final selected = selectedAssetList;
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

  /// Quiet empty/void block (snapdrop_empty_inlanguage.html) — replaces the
  /// loud void.json Lottie. Header + album switcher stay; only the grid area
  /// becomes this calm block. No Connect button here.
  Widget _emptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Two different situations, two different explanations: the phone has no
    // photos at all vs. the album you're looking at is empty (switch above).
    final bool noPhotosAtAll = hasNoData;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: ThemeConstant.accentGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Icon(
                Icons.image_outlined,
                color: ThemeConstant.softGreen.withValues(alpha: 0.7),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              noPhotosAtAll ? l.empty_state_none_title : l.empty_state_title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFE9ECE9),
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 240,
              child: Text(
                noPhotosAtAll ? l.empty_state_none_body : l.empty_state_body,
                textAlign: TextAlign.center,
                style: ThemeConstant.subtitleMuted.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            // A way out of the dead end: re-read the gallery (covers the case
            // where photos were granted or added after this screen loaded).
            SizedBox(
              height: 46,
              child: Material(
                color: Colors.white.withValues(alpha: 0.04),
                shape: StadiumBorder(
                  side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.16), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      hasNoData = false;
                      _assetsLoaded = false;
                    });
                    initialMethod(hasAll);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.85)),
                        const SizedBox(width: 8),
                        Text(
                          l.empty_state_refresh,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: ThemeConstant.muted,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  initialMethod(bool hasAll) {
    // CRASHLYTICS: this chain had no error handler at all. A rejected
    // permission future, or any failure inside loadAlbums, escaped to
    // PlatformDispatcher.onError and was logged FATAL — during the first
    // seconds of the session, which is exactly where the crash-free-users
    // number was being lost.
    widget._permissionProviderServices
        .requestMediaAccessPermission()
        .catchError((Object e, StackTrace s) {
      FirebaseInitalizationClass.recordNonFatal(e, s,
          reason: 'media permission chain failed');
      return false;
    }).then((permission) async {
      if (permission == true) {
        widget._mediaProviderServices.loadAlbums(hasAll).then((listOfAlbum) {
          if (listOfAlbum.isNotEmpty) {
            // Sort the list alphabetically by album name
            listOfAlbum.sort((a, b) => albumLabel(a)
                .toLowerCase()
                .compareTo(albumLabel(b).toLowerCase()));

            // CRASHLYTICS, and this is the big one: `selectedAlbum` is assigned
            // ONLY inside the `mounted` guard, and `_resetAndLoad(selectedAlbum!)`
            // sat OUTSIDE it. Anyone who left this screen while the album list
            // was still loading came back to a null and a force-unwrap — "Null
            // check operator used on a null value", in a closure inside a
            // closure off a Future, in the first seconds of the session.
            //
            // Read the local list rather than the field: the field is state
            // that may not have been written, the local is the value we
            // actually have.
            if (!mounted) return;
            setState(() {
              albumList = listOfAlbum;
              selectedAlbum = listOfAlbum.first;
            });
            filterAlbums();
            _resetAndLoad(listOfAlbum.first);
          } else {
            if (mounted) {
              setState(() {
                albumList = listOfAlbum;
                hasNoData = true;
              });
            }
          }
        });
      } else {
        _showMyDialog();
      }
    });
  }

  List<AssetEntity> get selectedAssetList => _selectedIds.value
      .map((id) => _assetById[id])
      .whereType<AssetEntity>()
      .toList();

  void _toggle(AssetEntity asset) {
    final ids = Set<String>.from(_selectedIds.value);
    if (ids.contains(asset.id)) {
      ids.remove(asset.id);
    } else {
      ids.add(asset.id);
      _assetById[asset.id] = asset;
    }
    _selectedIds.value = ids;
  }

  void _onScroll() {
    final c = widget.scrollController;
    if (!c.hasClients || _loadingMore || !_hasMore) return;
    if (c.position.pixels >= c.position.maxScrollExtent - 600) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (selectedAlbum == null || _loadingMore || !_hasMore) return;
    _loadingMore = true;
    final next = await widget._mediaProviderServices
        .loadAssetPage(selectedAlbum!, _page);
    if (!mounted) {
      _loadingMore = false;
      return;
    }
    setState(() {
      assetList = [...assetList, ...next];
      _page += 1;
      _hasMore = next.length >= MediaProviderServices.pageSize;
      _loadingMore = false;
    });
  }

  Future<void> _resetAndLoad(AssetPathEntity album) async {
    _page = 0;
    _hasMore = true;
    final first =
        await widget._mediaProviderServices.loadAssetPage(album, _page);
    if (!mounted) return;
    setState(() {
      assetList = first;
      _page = 1;
      _hasMore = first.length >= MediaProviderServices.pageSize;
      _assetsLoaded = true;
    });
  }

  Future<void> _showMyDialog() async {
    await showAppDialog(
      context: context,
      barrierDismissible: false,
      icon: Icons.photo_library_outlined,
      title: AppLocalizations.of(context)!.permission_dialog_title,
      body: AppLocalizations.of(context)!.permission_dialog_body,
      primaryLabel: AppLocalizations.of(context)!.permission_dialog_allow,
      secondaryLabel: AppLocalizations.of(context)!.permission_dialog_exit,
      onPrimary: () => initialMethod(hasAll),
      onSecondary: () => _handleExit(),
    );
  }

  void _handleExit() async {
    await showAppDialog(
      context: context,
      barrierDismissible: false,
      icon: Icons.logout_rounded,
      title: AppLocalizations.of(context)!.exit_dialog_title,
      body: AppLocalizations.of(context)!.exit_dialog_body,
      primaryLabel: AppLocalizations.of(context)!.exit_dialog_cancel,
      secondaryLabel: AppLocalizations.of(context)!.exit_dialog_exit,
      onSecondary: () => exit(0),
    );
  }
}


/// A single photo-grid cell. The thumbnail (AssetEntityImage) sits OUTSIDE the
/// selection ValueListenableBuilder, so toggling selection rebuilds only the
/// lightweight overlay — never re-decodes the image. RepaintBoundary keeps a
/// tile's raster from invalidating its neighbours.
class _PhotoTile extends StatelessWidget {
  final AssetEntity asset;
  final ValueListenable<Set<String>> selection;
  final VoidCallback onTap;
  const _PhotoTile({
    required this.asset,
    required this.selection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Flat placeholder behind. StackFit.expand forces both this and the
            // image to fill the whole tile, so the thumbnail (BoxFit.cover)
            // covers the 2:3 cell instead of sitting at its natural size.
            const DecoratedBox(
              decoration: BoxDecoration(
                color: ThemeConstant.surface,
                borderRadius: BorderRadius.all(Radius.circular(11)),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                thumbnailFormat: ThumbnailFormat.jpeg,
                fit: BoxFit.cover,
                // CRASHLYTICS: `PlatformException(Thumbnail request error …
                // MediaMetadataRetriever failed to retrieve a frame …)`.
                // A single unreadable file in the camera roll — a corrupt
                // download, a video the decoder refuses — used to take the
                // whole grid down. One tile failing is a blank tile, not a
                // crash.
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                frameBuilder: (context, child, frame, wasSync) {
                  // Fade in over the placeholder without changing layout — the
                  // image keeps the tile's full constraints (no switcher).
                  if (wasSync) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
            ValueListenableBuilder<Set<String>>(
              valueListenable: selection,
              builder: (context, ids, _) {
                final selected = ids.contains(asset.id);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (selected)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: selected
                            ? Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.check,
                                    size: 15, color: ThemeConstant.base),
                              )
                            : Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.4),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                      ),
                    ),
                    if (selected)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 7),
                          child: FutureBuilder<String>(
                            future: FileImageServices().getImageSize(asset),
                            builder: (context, snap) {
                              if (!snap.hasData) return const SizedBox.shrink();
                              // Force LTR for the measurement: in an RTL locale
                              // the bidi algorithm renders "0.32 MB" as
                              // "MB 0.32".
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// First-load placeholder: surface tiles under one slow, coherent shimmer sweep
/// (not independent per-tile shimmers) — same radius/spacing/aspect as the real
/// grid so the swap is seamless.
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: ThemeConstant.surface,
        highlightColor: Colors.white.withValues(alpha: 0.06),
        period: const Duration(milliseconds: 1400),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2 / 3,
          ),
          itemBuilder: (context, index) => DecoratedBox(
            decoration: BoxDecoration(
              color: ThemeConstant.surface,
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ),
    );
  }
}

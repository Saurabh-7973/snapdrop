import 'dart:io';

import 'package:Snapdrop/services/check_internet_connectivity.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/global_showcase_key.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../services/file_image.dart';
import '../services/first_time_login.dart';
import '../services/media_provider.dart';
import '../services/permission_provider.dart';
import '../services/socket_service.dart';
import '../l10n/app_localizations.dart';
import 'app_dialog.dart';

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
  List<AssetEntity> selectedAssetList = [];
  bool hasAll = false;
  bool hasNoData = false;
  bool hasDataLoaded = false;

  TextEditingController searchController = TextEditingController();
  List<AssetPathEntity> filteredAlbumList = [];
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    initialMethod(hasAll);
    super.initState();

    FirstTimeLogin.checkFirstTimeLogin().then((value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => ShowCaseWidget.of(context).startShowCase([
                  GlobalShowcaseKeys.showcaseOne,
                  GlobalShowcaseKeys.showcaseTwo,
                  GlobalShowcaseKeys.showcaseThree
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
    widget.scrollController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

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
                      key: GlobalShowcaseKeys.showcaseOne,
                      tooltipBackgroundColor: const Color(0xff161616),
                      textColor: ThemeConstant.whiteColor,
                      title: AppLocalizations.of(context)!.showcase_one_title,
                      description:
                          AppLocalizations.of(context)!.showcase_one_subtitle,
                      onBarrierClick: () => debugPrint('menu clicked'),
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
                            width: MediaQuery.of(context).size.width / 1.075,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
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
                                          'No albums with that name found',
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
                                hasDataLoaded = false;
                              });
                            }
                            FocusScope.of(context).unfocus();
                            if (selectedAlbum != null) {
                              widget._mediaProviderServices
                                  .loadAsset(selectedAlbum!)
                                  .then((value) {
                                if (mounted) {
                                  setState(() {
                                    assetList = value;
                                    hasDataLoaded = true;
                                  });
                                }
                              });
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
                                  hintText: 'Search album',
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
        (hasNoData == true || (hasDataLoaded == true && assetList.isEmpty))
            ? _emptyState(context)
            : hasDataLoaded == true
                ? Expanded(
                    child: Stack(children: [
                      GridView.builder(
                          controller: widget.scrollController,
                          itemCount: assetList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: (2 / 3)),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  if (selectedAssetList
                                      .contains(assetList[index])) {
                                    if (mounted) {
                                      setState(() {
                                        selectedAssetList
                                            .remove(assetList[index]);
                                      });
                                    }
                                  } else {
                                    if (mounted) {
                                      setState(() {
                                        selectedAssetList.add(assetList[index]);
                                      });
                                    }
                                  }
                                },
                                child: index == 0
                                    ? Showcase(
                                        targetPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 0),
                                        key: GlobalShowcaseKeys.showcaseTwo,
                                        tooltipBackgroundColor:
                                            const Color(0xff161616),
                                        textColor: ThemeConstant.whiteColor,
                                        title: AppLocalizations.of(context)!
                                            .showcase_two_title,
                                        description:
                                            AppLocalizations.of(context)!
                                                .showcase_two_subtitle,
                                        onBarrierClick: () =>
                                            debugPrint('image clicked'),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                child: AssetEntityImage(
                                                  assetList[index],
                                                  thumbnailSize:
                                                      const ThumbnailSize
                                                          .square(250),
                                                  fit: BoxFit.cover,
                                                  frameBuilder: (context,
                                                      child,
                                                      frame,
                                                      wasSynchronouslyLoaded) {
                                                    return AnimatedOpacity(
                                                      opacity:
                                                          frame == null ? 0 : 1,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      child: child,
                                                    );
                                                  },
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[800]!,
                                                      highlightColor:
                                                          Colors.grey[600]!,
                                                      child: Container(
                                                        color: Colors.grey[850],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (selectedAssetList
                                                .contains(assetList[index]))
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                height: double.infinity,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  color: Colors.black
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: selectedAssetList.contains(
                                                      assetList[index])
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(6.0),
                                                        child: Container(
                                                            width: 22,
                                                            height: 22,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white),
                                                            child: const Icon(
                                                                Icons.check,
                                                                size: 15,
                                                                color:
                                                                    ThemeConstant
                                                                        .base)),
                                                      ),
                                                    )
                                                  : Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child:
                                                            AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          height: 25,
                                                          width: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.4),
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            if (selectedAssetList
                                                .contains(assetList[index]))
                                              FutureBuilder(
                                                  future: FileImageServices()
                                                      .getImageSize(
                                                          assetList[index]),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                    return Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    bottom: 7),
                                                            child: Text(
                                                                "${snapshot.data} MB",
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 10.5,
                                                                    fontWeight: FontWeight.w500,
                                                                    shadows: [
                                                                      Shadow(
                                                                          blurRadius:
                                                                              3,
                                                                          color: Color(
                                                                              0xB3000000),
                                                                          offset: Offset(
                                                                              0,
                                                                              1))
                                                                    ]))));
                                                  }),
                                          ],
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              child: AssetEntityImage(
                                                assetList[index],
                                                thumbnailSize:
                                                    const ThumbnailSize.square(
                                                        250),
                                                fit: BoxFit.cover,
                                                frameBuilder: (context,
                                                    child,
                                                    frame,
                                                    wasSynchronouslyLoaded) {
                                                  return AnimatedOpacity(
                                                    opacity:
                                                        frame == null ? 0 : 1,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    child: child,
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[800]!,
                                                    highlightColor:
                                                        Colors.grey[600]!,
                                                    child: Container(
                                                      color: Colors.grey[850],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          if (selectedAssetList
                                              .contains(assetList[index]))
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              height: double.infinity,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: selectedAssetList
                                                    .contains(assetList[index])
                                                ? Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Container(
                                                          width: 22,
                                                          height: 22,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .white),
                                                          child: const Icon(
                                                              Icons.check,
                                                              size: 15,
                                                              color:
                                                                  ThemeConstant
                                                                      .base)),
                                                    ),
                                                  )
                                                : Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        height: 25,
                                                        width: 25,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: 0.4),
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          if (selectedAssetList
                                              .contains(assetList[index]))
                                            FutureBuilder(
                                                future: FileImageServices()
                                                    .getImageSize(
                                                        assetList[index]),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8,
                                                                  bottom: 7),
                                                          child: Text(
                                                              "${snapshot.data} MB",
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      10.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  shadows: [
                                                                    Shadow(
                                                                        blurRadius:
                                                                            3,
                                                                        color: Color(
                                                                            0xB3000000),
                                                                        offset: Offset(
                                                                            0,
                                                                            1))
                                                                  ]))));
                                                }),
                                        ],
                                      ));
                          }),
                      if (selectedAssetList.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 120,
                            width: screenWidth,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AnimatedScale(
                                  scale:
                                      selectedAssetList.isNotEmpty ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutBack,
                                  child: GestureDetector(
                                    onTap: selectedAssetList.isNotEmpty
                                        ? () async {
                                            HapticFeedback.lightImpact();
                                            final isConnected =
                                                await CheckInternetConnectivity
                                                    .hasNetwork();
                                            if (isConnected) {
                                              final size =
                                                  await FileImageServices()
                                                      .getTotalImageSize(
                                                          selectedAssetList);
                                              if (!context.mounted) return;
                                              if (size < 5.0) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        QRScreen(
                                                      selectedAssetList:
                                                          selectedAssetList,
                                                      isIntentSharing: widget
                                                          .isIntentSharing,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Size limit exceeded. (${size.toStringAsFixed(2)} MB > 5 MB)",
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        : null,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: screenWidth / 2.6,
                                      height: 50,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          if (selectedAssetList.isNotEmpty)
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.15),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 10),
                                            ),
                                        ],
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.grey.shade200,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder: (Widget child,
                                              Animation<double> animation) {
                                            return ScaleTransition(
                                                scale: animation, child: child);
                                          },
                                          child: selectedAssetList.isNotEmpty
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .home_screen_button,
                                                      style: ThemeConstant
                                                          .smallTextSizeDarkFontWidth,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: Colors.black,
                                                      size: 22,
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                  )
                : Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 9, // Keeping 9 shimmer items
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: (2 / 3),
                      ),
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            double opacity = scale.clamp(0.0, 1.0);
                            return FadeTransition(
                              opacity: AlwaysStoppedAnimation(opacity),
                              child: Transform.scale(
                                scale: scale,
                                child: Shimmer.fromColors(
                                  baseColor: ThemeConstant.primaryThemeColor
                                      .withValues(alpha: 0.6),
                                  highlightColor: ThemeConstant.greenAccentColor
                                      .withValues(alpha: 0.6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ThemeConstant.primaryThemeColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )

        // : const Expanded(
        //     child: Center(
        //         child: CircularProgressIndicator(
        //       color: ThemeConstant.whiteColor,
        //     )),
        //   )
      ],
    );
  }

  /// Quiet empty/void block (snapdrop_empty_inlanguage.html) — replaces the
  /// loud void.json Lottie. Header + album switcher stay; only the grid area
  /// becomes this calm block. No Connect button here.
  Widget _emptyState(BuildContext context) {
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
              AppLocalizations.of(context)!.empty_state_title,
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
              width: 220,
              child: Text(
                AppLocalizations.of(context)!.empty_state_body,
                textAlign: TextAlign.center,
                style: ThemeConstant.subtitleMuted.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  initialMethod(bool hasAll) {
    widget._permissionProviderServices
        .requestMediaAccessPermission()
        .then((permission) async {
      if (permission == true) {
        widget._mediaProviderServices.loadAlbums(hasAll).then((listOfAlbum) {
          if (listOfAlbum.isNotEmpty) {
            // Sort the list alphabetically by album name
            listOfAlbum.sort((a, b) => albumLabel(a)
                .toLowerCase()
                .compareTo(albumLabel(b).toLowerCase()));
            if (mounted) {
              setState(() {
                albumList = listOfAlbum;
                selectedAlbum = listOfAlbum[0];
                hasDataLoaded = true;
              });
              filterAlbums();
            }
            widget._mediaProviderServices
                .loadAsset(selectedAlbum!)
                .then((listOfAsset) {
              if (mounted) {
                setState(() {
                  assetList = listOfAsset;
                });
              }
            });
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

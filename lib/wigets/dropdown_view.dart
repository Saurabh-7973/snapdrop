import 'dart:io';

import 'package:Snapdrop/services/check_app_version.dart';
import 'package:Snapdrop/services/check_internet_connectivity.dart';
import 'package:Snapdrop/wigets/app_update_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/global_showcase_key.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../screen/send_file_screen.dart';
import '../services/file_image.dart';
import '../services/first_time_login.dart';
import '../services/media_provider.dart';
import '../services/permission_provider.dart';
import '../services/socket_service.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DropDownView extends StatefulWidget {
  // bool isTransferCompleted;
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

  void filterAlbums() {
    if (mounted) {
      setState(() {
        filteredAlbumList = albumList
            .where((album) => album.name
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
    var screenHeight = MediaQuery.of(context).size.height;

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
                : Row(
                    children: [
                      Showcase(
                        targetPadding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 0),
                        key: GlobalShowcaseKeys.showcaseOne,
                        tooltipBackgroundColor: const Color(0xff161616),
                        textColor: ThemeConstant.whiteColor,
                        title: AppLocalizations.of(context)!.showcase_one_title,
                        description:
                            AppLocalizations.of(context)!.showcase_one_subtitle,
                        onBarrierClick: () => debugPrint('menu clicked'),
                        child: SizedBox(
                          width: screenWidth / 1.08,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<AssetPathEntity>(
                              key: ValueKey(filteredAlbumList.length),
                              isExpanded: true,
                              value: filteredAlbumList.isNotEmpty
                                  ? selectedAlbum
                                  : null,
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              barrierColor: Colors.transparent,
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: searchFocusNode.hasFocus
                                    ? MediaQuery.of(context).size.height * 0.25
                                    : MediaQuery.of(context).size.height * 0.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xff161616),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              buttonStyleData: ButtonStyleData(
                                width:
                                    MediaQuery.of(context).size.width / 1.075,
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
                                          padding: const EdgeInsets.only(
                                              top: 12,
                                              bottom: 12,
                                              left: 16,
                                              right: 16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? ThemeConstant.primaryAppColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  album.name,
                                                  style: ThemeConstant
                                                      .smallTextSizeLight
                                                      .copyWith(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
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
                                              style: ThemeConstant
                                                  .smallTextSizeLight
                                                  .copyWith(
                                                color: Colors.grey,
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
                                        album.name,
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
                                  padding: const EdgeInsets.all(8),
                                  child: TextFormField(
                                    controller: searchController,
                                    focusNode: searchFocusNode,
                                    cursorColor: ThemeConstant.primaryAppColor,
                                    style: ThemeConstant.smallTextSizeLight
                                        .copyWith(
                                      color: ThemeConstant.primaryAppColor,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 12,
                                      ),
                                      hintText: 'Search Album...',
                                      hintStyle: ThemeConstant
                                          .smallTextSizeLight
                                          .copyWith(
                                        color: ThemeConstant.primaryAppColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: ThemeConstant.primaryAppColor,
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
                      const Spacer(),
                    ],
                  ),
        hasNoData == true
            ? Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight / 4,
                    ),
                    Lottie.asset('assets/animations/void.json'),
                    SizedBox(
                      height: screenHeight / 8,
                    ),
                    //Feels like a Void, Nothing to show for Now!
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Feels like a Void, No Images to Display!',
                        style: ThemeConstant.largeTextSize,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Add images to get started',
                        style: ThemeConstant.smallTextSizeLight,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : hasDataLoaded == true
                ? Expanded(
                    child: Stack(children: [
                      GridView.builder(
                          controller: widget.scrollController,
                          itemCount: assetList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
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
                                                    BorderRadius.circular(5),
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
                                                    if (loadingProgress == null)
                                                      return child;
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
                                                      BorderRadius.circular(5),
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: selectedAssetList.contains(
                                                      assetList[index])
                                                  ? const Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(6.0),
                                                        child: Icon(
                                                          Icons
                                                              .check_circle_rounded,
                                                          size: 30,
                                                          color: Colors.white,
                                                        ),
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
                                                                .withOpacity(
                                                                    0.4),
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
                                                  if (snapshot.hasData) {
                                                    return Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.35),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 4,
                                                              horizontal: 8,
                                                            ),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                "${snapshot.data} MB",
                                                                style: ThemeConstant
                                                                    .smallTextSizeLight,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        height: 10,
                                                        width: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                                  if (loadingProgress == null)
                                                    return child;
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
                                                    BorderRadius.circular(5),
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: selectedAssetList
                                                    .contains(assetList[index])
                                                ? const Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(6.0),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        size: 30,
                                                        color: Colors.white,
                                                      ),
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
                                                              .withOpacity(0.4),
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
                                                if (snapshot.hasData) {
                                                  return Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.35),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 4,
                                                            horizontal: 8,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              "${snapshot.data} MB",
                                                              style: ThemeConstant
                                                                  .smallTextSizeLight,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      height: 10,
                                                      width: 10,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
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

                                              if (size < 5.0) {
                                                if (!mounted) return;
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
                                                  .withOpacity(0.15),
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
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
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
                                      .withOpacity(0.6),
                                  highlightColor: ThemeConstant.greenAccentColor
                                      .withOpacity(0.6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ThemeConstant.primaryThemeColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
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

  initialMethod(bool hasAll) {
    widget._permissionProviderServices
        .requestMediaAccessPermission()
        .then((permission) async {
      if (permission == true) {
        widget._mediaProviderServices.loadAlbums(hasAll).then((listOfAlbum) {
          if (listOfAlbum.isNotEmpty) {
            // Sort the list alphabetically by album name
            listOfAlbum.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const FittedBox(
              fit: BoxFit.scaleDown, child: Text('Permission Required')),
          backgroundColor: ThemeConstant.whiteColor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'This app requires Storage Permission to Work.',
                    style: ThemeConstant.smallTextSizeDark,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Would you like to allow the Permission? ',
                    style: ThemeConstant.smallTextSizeDark,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const FittedBox(
                  fit: BoxFit.scaleDown, child: Text('Approve')),
              onPressed: () {
                Navigator.of(context).pop();
                initialMethod(hasAll);
              },
            ),
            TextButton(
              child:
                  const FittedBox(fit: BoxFit.scaleDown, child: Text('Exit!')),
              onPressed: () {
                _handleExit();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleExit() async {
    showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Are you sure you want to exit?')),
            content: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Unsaved data will be lost')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const FittedBox(
                    fit: BoxFit.scaleDown, child: Text('Cancel')),
              ),
              TextButton(
                onPressed: () => exit(0),
                child:
                    const FittedBox(fit: BoxFit.scaleDown, child: Text('Exit')),
              ),
            ],
          );
        });
  }
}

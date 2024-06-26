import 'dart:io';
import 'package:Snapdrop/services/check_internet_connectivity.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
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
                        //onBarrierClick: () => debugPrint('menu clicked'),
                        child: SizedBox(
                          width: screenWidth / 1.1,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<AssetPathEntity>(
                                isExpanded: true,
                                dropdownColor: const Color(0xff161616),
                                value: selectedAlbum,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                items: albumList
                                    .map<DropdownMenuItem<AssetPathEntity>>(
                                        (album) {
                                  return DropdownMenuItem<AssetPathEntity>(
                                    value: album,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        album.name,
                                        style: ThemeConstant.smallTextSizeLight,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (AssetPathEntity? album) {
                                  if (mounted) {
                                    setState(() {
                                      selectedAlbum = album;
                                      hasDataLoaded = false;
                                    });
                                  }

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
                                }),
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
                                      targetPadding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                      key: GlobalShowcaseKeys.showcaseTwo,
                                      tooltipBackgroundColor:
                                          const Color(0xff161616),
                                      textColor: ThemeConstant.whiteColor,
                                      title: AppLocalizations.of(context)!
                                          .showcase_two_title,
                                      description: AppLocalizations.of(context)!
                                          .showcase_two_subtitle,
                                      // onBarrierClick: () =>
                                      //     debugPrint('image clicked'),
                                      child: Stack(children: [
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
                                            ),
                                          ),
                                        ),
                                        if (selectedAssetList
                                                .contains(assetList[index]) ==
                                            true)
                                          Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.black
                                                    .withOpacity(0.6)),
                                          ),
                                        selectedAssetList.contains(
                                                    assetList[index]) ==
                                                true
                                            ? const Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: 25,
                                                    width: 25,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2)),
                                                    child: Container(),
                                                  ),
                                                ),
                                              ),
                                        if (selectedAssetList
                                                .contains(assetList[index]) ==
                                            true)
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
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.35)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4,
                                                                  horizontal:
                                                                      8),
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
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                      ]),
                                    )
                                  : Stack(children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: AssetEntityImage(
                                            assetList[index],
                                            thumbnailSize:
                                                const ThumbnailSize.square(250),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (selectedAssetList
                                              .contains(assetList[index]) ==
                                          true)
                                        Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.black
                                                  .withOpacity(0.5)),
                                        ),
                                      selectedAssetList
                                                  .contains(assetList[index]) ==
                                              true
                                          ? const Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2)),
                                                  child: Container(),
                                                ),
                                              ),
                                            ),
                                      if (selectedAssetList
                                              .contains(assetList[index]) ==
                                          true)
                                        FutureBuilder(
                                            future: FileImageServices()
                                                .getImageSize(assetList[index]),
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
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.3)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 8),
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
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
                                                  padding: EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    height: 10,
                                                    width: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                    ]),
                            );
                          }),
                      if (selectedAssetList.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 120,
                            width: screenWidth,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Showcase(
                                  targetPadding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  key: GlobalShowcaseKeys.showcaseThree,
                                  tooltipBackgroundColor:
                                      const Color(0xff161616),
                                  textColor: ThemeConstant.whiteColor,
                                  title: AppLocalizations.of(context)!
                                      .showcase_three_title,
                                  description: AppLocalizations.of(context)!
                                      .showcase_three_subtitle,
                                  // onBarrierClick: () =>
                                  //     debugPrint('connect clicked'),
                                  child: Container(
                                    width: screenWidth / 2.6,
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await CheckInternetConnectivity
                                                .hasNetwork()
                                            .then((value) {
                                          if (value) {
                                            if (selectedAssetList.length >=
                                                10) {
                                              var snackbarLimit = SnackBar(
                                                  backgroundColor: ThemeConstant
                                                      .primaryAppColor,
                                                  content: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .app_conditions_image_selection_limit,
                                                      style: ThemeConstant
                                                          .smallTextSizeLight,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbarLimit);
                                            } else {
                                              FileImageServices()
                                                  .getTotalImageSize(
                                                      selectedAssetList)
                                                  .then((value) {
                                                if (value < 5.0) {
                                                  if (widget.socketService !=
                                                      null) {
                                                    String? roomId = widget
                                                        .socketService!.roomId;
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SendFile(
                                                          socketService: widget
                                                              .socketService,
                                                          selectedAssetList:
                                                              selectedAssetList,
                                                          imageCount:
                                                              selectedAssetList
                                                                  .length,
                                                          isIntentSharing: widget
                                                              .isIntentSharing,
                                                          roomId: roomId!,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
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
                                                  }
                                                } else {
                                                  var snackbarLimit = SnackBar(
                                                      backgroundColor:
                                                          const Color(
                                                              0xff206946),
                                                      content: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          "${AppLocalizations.of(context)!.app_conditions_size_limit} (${value.toStringAsFixed(2)}) > 5 MB",
                                                          style: ThemeConstant
                                                              .smallTextSizeLight,
                                                        ),
                                                      ));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          snackbarLimit);
                                                }
                                              });
                                            }
                                          } else {
                                            var snackbarLimit = SnackBar(
                                                backgroundColor: ThemeConstant
                                                    .primaryAppColor,
                                                content: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .app_conditions_internet_connection,
                                                    style: ThemeConstant
                                                        .smallTextSizeLight,
                                                  ),
                                                ));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackbarLimit);
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                              screenWidth, screenHeight / 6),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .home_screen_button,
                                              style: ThemeConstant
                                                  .smallTextSizeDarkFontWidth,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.black,
                                            size: 22,
                                          )
                                        ],
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
                    child: Shimmer.fromColors(
                      baseColor: ThemeConstant.primaryThemeColor,
                      highlightColor: ThemeConstant.greenAccentColor,
                      child: GridView.builder(
                        itemCount: 9, // Number of shimmering items
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: (2 / 3),
                        ),
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            color: ThemeConstant.primaryThemeColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
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
            if (mounted) {
              setState(() {
                albumList = listOfAlbum;
                selectedAlbum = listOfAlbum[0];
                hasDataLoaded = true;
              });
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../screen/send_file_screen.dart';
import '../services/file_image.dart';
import '../services/first_time_login.dart';
import '../services/media_provider.dart';
import '../services/permission_provider.dart';
import '../services/socket_service.dart';

class DropDownView extends StatefulWidget {
  // bool isTransferCompleted;
  SocketService? socketService;
  DropDownView({super.key, this.socketService});

  final PermissionProviderServices _permissionProviderServices = PermissionProviderServices();
  final MediaProviderServices _mediaProviderServices = MediaProviderServices();
  final ThemeConstant _themeConstant = ThemeConstant();

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

  //For Showcase Widget
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();

  final scrollController = ScrollController();

  @override
  void initState() {
    initialMethod(hasAll);
    super.initState();
    var firstTimeOpen = FirstTimeLogin.checkFirstTimeLogin();
    if (firstTimeOpen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([_one, _two, _three]));
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeConstant = ThemeConstant();
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        albumList.isEmpty == true
            ? hasNoData == true
                ? const SizedBox.shrink()
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
            : hasNoData == true
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Showcase(
                        targetPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: -5),
                        key: _one,
                        title: "Dropdown Button",
                        description: 'Select albums you wan to choose photos from',
                        onBarrierClick: () => debugPrint('menu clicked'),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AssetPathEntity>(
                              dropdownColor: const Color(0xff071414),
                              value: selectedAlbum,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              items: albumList.map<DropdownMenuItem<AssetPathEntity>>((album) {
                                return DropdownMenuItem<AssetPathEntity>(
                                  value: album,
                                  child: Text(
                                    "${album.name}",
                                    style: ThemeConstant.smallTextSizeLight,
                                  ),
                                );
                              }).toList(),
                              onChanged: (AssetPathEntity? album) {
                                setState(() {
                                  selectedAlbum = album;
                                  hasDataLoaded = false;
                                });

                                widget._mediaProviderServices.loadAsset(selectedAlbum!).then((value) {
                                  setState(() {
                                    assetList = value;
                                    hasDataLoaded = true;
                                  });
                                });
                              }),
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
                    const Text(
                      'Feels like a Void, No Images to Display!',
                      style: ThemeConstant.largeTextSize,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Add images to get started',
                      style: ThemeConstant.smallTextSizeLight,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : hasDataLoaded == true
                ? Expanded(
                    child: Stack(children: [
                      GridView.builder(
                          controller: scrollController,
                          itemCount: assetList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: (2 / 3)),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (selectedAssetList.contains(assetList[index])) {
                                  setState(() {
                                    selectedAssetList.remove(assetList[index]);
                                  });
                                } else {
                                  setState(() {
                                    selectedAssetList.add(assetList[index]);
                                  });
                                }
                              },
                              child: Showcase(
                                targetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                key: _two,
                                title: "Select Images",
                                description: 'Select Images you want to share',
                                onBarrierClick: () => debugPrint('image clicked'),
                                child: Stack(children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: AssetEntityImage(
                                        assetList[index],
                                        thumbnailSize: const ThumbnailSize.square(250),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (selectedAssetList.contains(assetList[index]) == true)
                                    Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black.withOpacity(0.5)),
                                    ),
                                  selectedAssetList.contains(assetList[index]) == true
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black.withOpacity(0.4),
                                                  border: Border.all(color: Colors.white, width: 2)),
                                              child: Container(),
                                            ),
                                          ),
                                        ),
                                  if (selectedAssetList.contains(assetList[index]) == true)
                                    FutureBuilder(
                                        future: FileImageServices().getImageSize(assetList[index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.8)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4),
                                                    child: Text(
                                                      "${snapshot.data} MB",
                                                      style: ThemeConstant.smallTextSizeLight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const Align(
                                            alignment: Alignment.bottomRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 10,
                                                width: 10,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                ]),
                              ),
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
                                  targetPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: -5),
                                  key: _three,
                                  title: "Connect Button",
                                  description: 'Proceed to next step',
                                  onBarrierClick: () => debugPrint('connect clicked'),
                                  child: Container(
                                    width: screenWidth / 2.6,
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (selectedAssetList.length >= 10) {
                                          var snackbarLimit = SnackBar(
                                              backgroundColor: const Color(0xff206946),
                                              content: Text(
                                                "Can Only select upto 10 Images !",
                                                style: ThemeConstant.smallTextSizeLight,
                                                textAlign: TextAlign.center,
                                              ));
                                          ScaffoldMessenger.of(context).showSnackBar(snackbarLimit);
                                        } else {
                                          FileImageServices().getTotalImageSize(selectedAssetList).then((value) {
                                            if (value < 5.0) {
                                              if (widget.socketService != null) {
                                                String? roomId = widget.socketService!.roomId;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SendFile(
                                                      socketService: widget.socketService,
                                                      selectedAssetList: selectedAssetList,
                                                      imageCount: selectedAssetList.length,
                                                      isIntentSharing: false,
                                                      roomId: roomId!,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => QRScreen(
                                                      selectedAssetList: selectedAssetList,
                                                      isIntentSharing: false,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              var snackbarLimit = SnackBar(
                                                  backgroundColor: const Color(0xff206946),
                                                  content: Text(
                                                    "File Size Limit Exceded (${value.toStringAsFixed(2)}) > 5 MB",
                                                    style: ThemeConstant.smallTextSizeLight,
                                                  ));
                                              ScaffoldMessenger.of(context).showSnackBar(snackbarLimit);
                                            }
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Connect",
                                            style: ThemeConstant.smallTextSizeDark,
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.black,
                                            size: 18,
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
                : const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                      color: ThemeConstant.whiteColor,
                    )),
                  )
      ],
    );
  }

  initialMethod(bool hasAll) {
    widget._permissionProviderServices.requestMediaAccessPermission().then((permission) async {
      if (permission == true) {
        widget._mediaProviderServices.loadAlbums(hasAll).then((listOfAlbum) {
          if (listOfAlbum.isNotEmpty) {
            setState(() {
              albumList = listOfAlbum;
              selectedAlbum = listOfAlbum[0];
              hasDataLoaded = true;
            });
            widget._mediaProviderServices.loadAsset(selectedAlbum!).then((listOfAsset) {
              setState(() {
                assetList = listOfAsset;
              });
            });
          } else {
            setState(() {
              albumList = listOfAlbum;
              hasNoData = true;
            });
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
          title: const Text('Permission Required'),
          backgroundColor: ThemeConstant.whiteColor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This app requires Storage Permission to Work.',
                  style: ThemeConstant.smallTextSizeDark,
                ),
                Text(
                  'Would you like to allow the Permission? ',
                  style: ThemeConstant.smallTextSizeDark,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                initialMethod(hasAll);
              },
            ),
            TextButton(
              child: const Text('Exit!'),
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
            title: Text('Are you sure you want to exit?'),
            content: Text('Unsaved data will be lost'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text('Exit'),
              ),
            ],
          );
        });
  }
}

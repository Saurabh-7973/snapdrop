import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../constant/theme_contants.dart';
import '../screen/qr_screen.dart';
import '../screen/send_file_screen.dart';
import '../services/file_image.dart';
import '../services/media_provider.dart';
import '../services/permission_provider.dart';
import '../services/socket_service.dart';

class DropDownView extends StatefulWidget {
  // bool isTransferCompleted;
  SocketService? socketService;
  DropDownView({super.key, this.socketService});

  final PermissionProviderServices _permissionProviderServices =
      PermissionProviderServices();
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

  @override
  void initState() {
    initialMethod(hasAll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeConstant = ThemeConstant();
    var screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        albumList.isEmpty == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Row(
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<AssetPathEntity>(
                        dropdownColor: const Color(0xff071414),
                        value: selectedAlbum,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        items: albumList
                            .map<DropdownMenuItem<AssetPathEntity>>((album) {
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
                          });

                          widget._mediaProviderServices
                              .loadAsset(selectedAlbum!)
                              .then((value) {
                            setState(() {
                              assetList = value;
                            });
                          });
                        }),
                  ),
                  const Spacer(),
                ],
              ),
        Expanded(
          child: Stack(children: [
            GridView.builder(
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: (2 / 3)),
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
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.5)),
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
                                      border: Border.all(
                                          color: Colors.white, width: 2)),
                                  child: Container(),
                                ),
                              ),
                            ),
                      if (selectedAssetList.contains(assetList[index]) == true)
                        FutureBuilder(
                            future: FileImageServices()
                                .getImageSize(assetList[index]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color:
                                                Colors.grey.withOpacity(0.8)),
                                        child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              "${snapshot.data} MB",
                                              style: ThemeConstant
                                                  .smallTextSizeLight,
                                            ))),
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
                                        ))),
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
                      Container(
                        width: screenWidth / 2.6,
                        height: 40,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackbarLimit);
                            } else {
                              FileImageServices()
                                  .getTotalImageSize(selectedAssetList)
                                  .then((value) {
                                if (value < 5.0) {
                                  if (widget.socketService != null) {
                                    String? roomId =
                                        widget.socketService!.roomId;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SendFile(
                                                  socketService:
                                                      widget.socketService,
                                                  selectedAssetList:
                                                      selectedAssetList,
                                                  imageCount:
                                                      selectedAssetList.length,
                                                  isIntentSharing: false,
                                                  roomId: roomId!,
                                                )));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => QRScreen(
                                                  selectedAssetList:
                                                      selectedAssetList,
                                                  isIntentSharing: false,
                                                )));
                                  }
                                } else {
                                  var snackbarLimit = SnackBar(
                                      backgroundColor: const Color(0xff206946),
                                      content: Text(
                                        "File Size Limit Exceded (${value.toStringAsFixed(2)}) > 5 MB",
                                        style: ThemeConstant.smallTextSizeLight,
                                      ));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackbarLimit);
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
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
                    ],
                  ),
                ),
              ),
          ]),
        )
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
            setState(() {
              albumList = listOfAlbum;
              selectedAlbum = listOfAlbum[0];
            });
            widget._mediaProviderServices
                .loadAsset(selectedAlbum!)
                .then((listOfAsset) {
              setState(() {
                assetList = listOfAsset;
              });
            });
          }
        });
      }
    });
  }
}

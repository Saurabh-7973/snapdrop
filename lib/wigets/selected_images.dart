import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
// import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SelectedImagesViewer extends StatelessWidget {
  List<AssetEntity> selectedAssetList;

  SelectedImagesViewer({super.key, required this.selectedAssetList});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
        height: screenHeight / 2.5,
        child: GridView.builder(
            itemCount: selectedAssetList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: (2 / 3),
            ),
            itemBuilder: (context, index) {
              AssetEntity currentAsset = selectedAssetList[index];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: AssetEntityImage(
                      currentAsset,
                      fit: BoxFit.cover,
                    )),
              );
            }));
  }
}

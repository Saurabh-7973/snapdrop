import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SelectedImagesViewer extends StatelessWidget {
  List<AssetEntity> selectedAssetList;

  SelectedImagesViewer({super.key, required this.selectedAssetList});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight / 2.4,
      child: GridView.builder(
        itemCount: selectedAssetList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: (2 / 3),
        ),
        itemBuilder: (context, index) {
          AssetEntity currentAsset = selectedAssetList[index];

          return GestureDetector(
            onTap: () {
              // Optional: You can add an image preview here if you want
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AssetEntityImage(
                  currentAsset,
                  fit: BoxFit.cover,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

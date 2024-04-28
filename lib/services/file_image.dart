import 'package:photo_manager/photo_manager.dart';

class FileImageServices {
  Future<String> getImageSize(AssetEntity assetFile) async {
    String size = '0.0';
    await assetFile.file.then(
      (value) async {
        await value?.length().then((length) {
          size = (length / (1024 * 1024)).toStringAsFixed(2);
          return size;
        });
      },
    );
    return size;
  }

  Future<double> getTotalImageSize(List<AssetEntity> selectedAssetList) async {
    double totalSize = 0.0;
    List<Future<void>> futures = [];

    for (int i = 0; i < selectedAssetList.length; i++) {
      Future<void> getSize() async {
        String value = await getImageSize(selectedAssetList[i]);
        totalSize += double.parse(value);
      }

      futures.add(getSize());
    }
    await Future.wait(futures);

    return totalSize;
  }
}

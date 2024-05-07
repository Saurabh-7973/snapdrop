import 'package:photo_manager/photo_manager.dart';

class MediaProviderServices {
  Future<List<AssetPathEntity>> loadAlbums(bool hasAll) async {
    List<AssetPathEntity> albumList = [];
    albumList = await PhotoManager.getAssetPathList(type: RequestType.image, hasAll: hasAll);
    return albumList;
  }

  // Future loadAsset(AssetPathEntity selectedAlbum) async {
  //   List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
  //       start: 0, end: selectedAlbum.assetCount);
  //   return assetList;
  // }

  Future<List<AssetEntity>> loadAsset(AssetPathEntity selectedAlbum) async {
    // Call getAssetCount to retrieve the asset count first
    int assetCount = await selectedAlbum.assetCountAsync;
    if (assetCount > 0) {
      assetCount - 1;
    }
    print("Asset Count : $assetCount");
    // Use the retrieved asset count to get the asset list
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(start: 0, end: assetCount); // Adjust end index for zero-based counting
    return assetList;
  }

  static Future<int> getAssetCount(AssetPathEntity selectedAlbum) async {
    int assetCount;
    assetCount = await selectedAlbum.assetCountAsync;
    if (assetCount > 0) {
      assetCount - 1;
    }
    return assetCount;
  }
}

import 'package:photo_manager/photo_manager.dart';

class MediaProviderServices {
  Future<List<AssetPathEntity>> loadAlbums(bool hasAll) async {
    List<AssetPathEntity> albumList = [];
    albumList = await PhotoManager.getAssetPathList(type: RequestType.image, hasAll: hasAll);
    return albumList;
  }

  Future<List<AssetEntity>> loadAsset(AssetPathEntity selectedAlbum) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    if (assetCount > 0) {
      assetCount - 1;
    }
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(start: 0, end: assetCount);
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
